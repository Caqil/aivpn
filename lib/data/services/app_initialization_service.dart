
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/revenuecat_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/server.dart';
import '../../domain/repositories/user_creation_repository.dart';
import '../../domain/repositories/server_repository.dart';
import '../models/user_profile_model.dart';

class AppInitializationService {
  final UserCreationRepository userCreationRepository;
  final ServerRepository serverRepository;
  final RevenueCatService revenueCatService;
  final SharedPreferences sharedPreferences;

  static const String _userProfileKey = 'user_profile';
  static const String _lastInitTimeKey = 'last_init_time';
  static const Duration _initCacheTimeout = Duration(hours: 1);

  AppInitializationService({
    required this.userCreationRepository,
    required this.serverRepository,
    required this.revenueCatService,
    required this.sharedPreferences,
  });

  Future<AppInitializationResult> initializeApp() async {
    try {
      // Initialize RevenueCat first
      await revenueCatService.initialize();
      final userId = revenueCatService.deviceId ?? '';

      if (userId.isEmpty) {
        throw AppInitializationException('Failed to get device ID');
      }

      // Check if we need to initialize (cache timeout or first time)
      final shouldInitialize = await _shouldPerformInitialization();

      UserProfile? userProfile;

      if (shouldInitialize) {
        userProfile = await _handleUserInitialization(userId);
        await _cacheUserProfile(userProfile);
        await _updateLastInitTime();
      } else {
        // Try to load from cache first
        userProfile = await _getCachedUserProfile();
        if (userProfile == null) {
          userProfile = await _handleUserInitialization(userId);
          await _cacheUserProfile(userProfile);
        }
      }

      // Update servers in the server repository
      await _updateServersInRepository(userProfile.servers);

      return AppInitializationResult(
        success: true,
        userProfile: userProfile,
        message: 'App initialized successfully',
      );
    } on TimeoutException catch (e) {
      throw AppInitializationException(
        'Request timed out. Please check your connection.',
        originalError: e,
      );
    } catch (e) {
      throw AppInitializationException(
        'Failed to initialize app: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<UserProfile> _handleUserInitialization(String userId) async {
    try {
      // Check if user exists
      final userExists = await userCreationRepository.checkUserExists(userId);

      if (userExists) {
        // User exists, fetch profile
        return await _handleExistingUser(userId);
      } else {
        // User doesn't exist, create new user
        return await _handleNewUser(userId);
      }
    } catch (e) {
      throw AppInitializationException('Failed to initialize user: $e');
    }
  }

  Future<UserProfile> _handleNewUser(String userId) async {
    try {
      // Clear any cached data
      await _clearUserPreferences();

      // Get subscription status from RevenueCat
      final customerInfo = await revenueCatService.getCustomerInfo();
      final isPremium = revenueCatService.isPremium(customerInfo);

      // Create new user
      final userProfile = await userCreationRepository.createUser(
        userId: userId,
        isPremium: isPremium,
      );

      return userProfile;
    } catch (e) {
      throw AppInitializationException('Failed to create new user: $e');
    }
  }

  Future<UserProfile> _handleExistingUser(String userId) async {
    try {
      // Get current subscription status
      final customerInfo = await revenueCatService.getCustomerInfo();
      final isPremium = revenueCatService.isPremium(customerInfo);
      final isExpired = revenueCatService.isExpired(customerInfo);

      // Fetch current user profile
      final userProfile = await userCreationRepository.fetchUserProfile(userId);

      // Check if user status needs updating
      final needsUpdate = await _checkIfUserNeedsUpdate(
        userProfile,
        isPremium,
        isExpired,
      );

      if (needsUpdate) {
        // Update user status
        await userCreationRepository.updateUserStatus(
          userId: userId,
          isPremium: isPremium && !isExpired,
        );

        // Fetch updated profile
        return await userCreationRepository.fetchUserProfile(userId);
      }

      return userProfile;
    } catch (e) {
      throw AppInitializationException('Failed to handle existing user: $e');
    }
  }

  Future<bool> _checkIfUserNeedsUpdate(
    UserProfile userProfile,
    bool isPremium,
    bool isExpired,
  ) async {
    // Get last known status
    final lastPremiumStatus = sharedPreferences.getBool('was_premium') ?? false;
    final lastExpiredStatus = sharedPreferences.getBool('was_expired') ?? false;
    final lastUpdateTime = _getLastUpdateTime();

    final currentPremiumStatus = isPremium && !isExpired;

    // Check if status changed
    final statusChanged =
        lastPremiumStatus != currentPremiumStatus ||
        lastExpiredStatus != isExpired;

    // Check if daily update is needed for expired users
    final needsDailyUpdate =
        isExpired && _shouldPerformDailyUpdate(lastUpdateTime);

    // Check for invalid config
    final hasInvalidConfig = _checkInvalidConfig(
      userProfile,
      currentPremiumStatus,
    );

    if (statusChanged || needsDailyUpdate || hasInvalidConfig) {
      // Save current status
      await sharedPreferences.setBool('was_premium', currentPremiumStatus);
      await sharedPreferences.setBool('was_expired', isExpired);
      await sharedPreferences.setInt(
        'last_update_time',
        DateTime.now().millisecondsSinceEpoch,
      );
      return true;
    }

    return false;
  }

  bool _checkInvalidConfig(UserProfile userProfile, bool isPremium) {
    if (isPremium) {
      // Premium users should have no data limit and no_reset strategy
      return userProfile.dataLimit != null && userProfile.dataLimit! > 0 ||
          userProfile.dataLimitResetStrategy != 'no_reset';
    } else {
      // Free users should have data limit and month reset strategy
      return userProfile.dataLimit == null ||
          userProfile.dataLimit == 0 ||
          userProfile.dataLimitResetStrategy == 'no_reset';
    }
  }

  DateTime? _getLastUpdateTime() {
    final timestamp = sharedPreferences.getInt('last_update_time');
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  bool _shouldPerformDailyUpdate(DateTime? lastUpdate) {
    if (lastUpdate == null) return true;
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    return difference.inHours >= 24;
  }

  Future<bool> _shouldPerformInitialization() async {
    final lastInitTime = sharedPreferences.getInt(_lastInitTimeKey);
    if (lastInitTime == null) return true;

    final lastInit = DateTime.fromMillisecondsSinceEpoch(lastInitTime);
    final now = DateTime.now();
    final timeSinceLastInit = now.difference(lastInit);

    return timeSinceLastInit > _initCacheTimeout;
  }

  Future<void> _updateLastInitTime() async {
    await sharedPreferences.setInt(
      _lastInitTimeKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<UserProfile?> _getCachedUserProfile() async {
    try {
      final cachedData = sharedPreferences.getString(_userProfileKey);
      if (cachedData != null) {
        final Map<String, dynamic> json = Map<String, dynamic>.from(
          jsonDecode(cachedData),
        );
        return UserProfileModel.fromJson(json).toEntity();
      }
    } catch (e) {
      print('Error loading cached user profile: $e');
    }
    return null;
  }

  Future<void> _cacheUserProfile(UserProfile userProfile) async {
    try {
      final userProfileModel = UserProfileModel(
        username: userProfile.username,
        status: userProfile.status,
        proxies: ProxyConfigModel(
          vmess: userProfile.proxies.vmess != null
              ? VmessConfigModel(id: userProfile.proxies.vmess!.id)
              : null,
          vless: userProfile.proxies.vless != null
              ? VlessConfigModel(
                  id: userProfile.proxies.vless!.id,
                  flow: userProfile.proxies.vless!.flow,
                )
              : null,
          trojan: userProfile.proxies.trojan,
          shadowsocks: userProfile.proxies.shadowsocks,
        ),
        inbounds: userProfile.inbounds,
        expire: userProfile.expire,
        dataLimit: userProfile.dataLimit,
        dataLimitResetStrategy: userProfile.dataLimitResetStrategy,
        usedTraffic: userProfile.usedTraffic,
        lifetimeUsedTraffic: userProfile.lifetimeUsedTraffic,
        links: userProfile.links,
        subscriptionUrl: userProfile.subscriptionUrl,
        createdAt: userProfile.createdAt,
      );

      final jsonString = jsonEncode(userProfileModel.toJson());
      await sharedPreferences.setString(_userProfileKey, jsonString);
    } catch (e) {
      print('Error caching user profile: $e');
    }
  }

  Future<void> _updateServersInRepository(List<Server> servers) async {
    try {
      // Clear existing servers and add new ones
      await serverRepository.clearSelectedServer();

      // If there are servers available, you might want to select the first one
      if (servers.isNotEmpty) {
        await serverRepository.saveSelectedServer(servers.first);
      }
    } catch (e) {
      print('Error updating servers in repository: $e');
    }
  }

  Future<void> _clearUserPreferences() async {
    await Future.wait([
      sharedPreferences.remove('nodes_cache'),
      sharedPreferences.remove('conf'),
      sharedPreferences.remove('country'),
      sharedPreferences.remove('ip'),
      sharedPreferences.remove(_userProfileKey),
    ]);
  }
}

class AppInitializationResult {
  final bool success;
  final UserProfile? userProfile;
  final String message;
  final Exception? error;

  AppInitializationResult({
    required this.success,
    this.userProfile,
    required this.message,
    this.error,
  });
}

class AppInitializationException implements Exception {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  AppInitializationException(
    this.message, {
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => 'AppInitializationException: $message';
}
