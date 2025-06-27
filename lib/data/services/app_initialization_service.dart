// lib/data/services/app_initialization_service.dart - Fixed
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
  static const String _userCreatedKey = 'user_created';
  static const Duration _initCacheTimeout = Duration(hours: 1);

  AppInitializationService({
    required this.userCreationRepository,
    required this.serverRepository,
    required this.revenueCatService,
    required this.sharedPreferences,
  });

  Future<AppInitializationResult> initializeApp() async {
    try {
      print('Starting app initialization...');

      // Step 1: Initialize RevenueCat first to get device ID
      await revenueCatService.initialize();
      final userId = revenueCatService.deviceId;

      if (userId == null || userId.isEmpty) {
        throw AppInitializationException(
          'Failed to get device ID from RevenueCat',
        );
      }

      print('Device ID obtained: $userId');

      // Step 2: Check subscription status
      final customerInfo = await revenueCatService.getCustomerInfo();
      final isPremium = revenueCatService.isPremium(customerInfo);
      final isExpired = revenueCatService.isExpired(customerInfo);

      print('Subscription status - Premium: $isPremium, Expired: $isExpired');

      // Step 3: Handle user creation/loading
      UserProfile? userProfile = await _handleUserInitialization(
        userId: userId,
        isPremium: isPremium && !isExpired,
      );

      if (userProfile == null) {
        throw AppInitializationException('Failed to initialize user profile');
      }

      print('User profile loaded successfully: ${userProfile.username}');

      // Step 4: Cache the user profile
      await _cacheUserProfile(userProfile);
      await _updateLastInitTime();

      // Step 5: Update servers in the server repository
      await _updateServersInRepository(userProfile.servers);

      print('App initialization completed successfully');

      return AppInitializationResult(
        success: true,
        userProfile: userProfile,
        message: 'App initialized successfully',
      );
    } on TimeoutException catch (e) {
      print('Initialization timeout: $e');
      throw AppInitializationException(
        'Request timed out. Please check your connection.',
        originalError: e,
      );
    } catch (e) {
      print('Initialization error: $e');
      throw AppInitializationException(
        'Failed to initialize app: ${e.toString()}',
        originalError: e,
      );
    }
  }

  Future<UserProfile?> _handleUserInitialization({
    required String userId,
    required bool isPremium,
  }) async {
    try {
      print('Handling user initialization for: $userId');

      // First, try to load from cache if recent
      if (!await _shouldPerformInitialization()) {
        final cachedProfile = await _getCachedUserProfile();
        if (cachedProfile != null) {
          print('Using cached user profile');
          return cachedProfile;
        }
      }

      // Check if user exists on the server
      final userExists = await userCreationRepository.checkUserExists(userId);
      print('User exists on server: $userExists');

      UserProfile userProfile;

      if (userExists) {
        // User exists, fetch current profile
        userProfile = await _handleExistingUser(userId, isPremium);
      } else {
        // User doesn't exist, create new user
        userProfile = await _handleNewUser(userId, isPremium);
      }

      // Mark user as created locally
      await sharedPreferences.setBool(_userCreatedKey, true);

      return userProfile;
    } catch (e) {
      print('Error in user initialization: $e');
      throw AppInitializationException('Failed to initialize user: $e');
    }
  }

  Future<UserProfile> _handleNewUser(String userId, bool isPremium) async {
    try {
      print('Creating new user: $userId (Premium: $isPremium)');

      // Clear any cached data for fresh start
      await _clearUserPreferences();

      // Create new user on the server
      final userProfile = await userCreationRepository.createUser(
        userId: userId,
        isPremium: isPremium,
      );

      print('New user created successfully');
      return userProfile;
    } catch (e) {
      print('Error creating new user: $e');
      throw AppInitializationException('Failed to create new user: $e');
    }
  }

  Future<UserProfile> _handleExistingUser(String userId, bool isPremium) async {
    try {
      print('Handling existing user: $userId');

      // Fetch current user profile
      final userProfile = await userCreationRepository.fetchUserProfile(userId);

      // Check if user status needs updating based on subscription
      final needsUpdate = await _checkIfUserNeedsUpdate(userProfile, isPremium);

      if (needsUpdate) {
        print('User needs status update - updating to Premium: $isPremium');

        // Update user status on server
        await userCreationRepository.updateUserStatus(
          userId: userId,
          isPremium: isPremium,
        );

        // Fetch updated profile
        return await userCreationRepository.fetchUserProfile(userId);
      }

      print('Using existing user profile without updates');
      return userProfile;
    } catch (e) {
      print('Error handling existing user: $e');
      throw AppInitializationException('Failed to handle existing user: $e');
    }
  }

  Future<bool> _checkIfUserNeedsUpdate(
    UserProfile userProfile,
    bool isPremium,
  ) async {
    // Get last known status
    final lastPremiumStatus = sharedPreferences.getBool('was_premium') ?? false;
    final lastUpdateTime = _getLastUpdateTime();

    // Current status based on subscription
    final currentPremiumStatus = isPremium;

    // Check if status changed
    final statusChanged = lastPremiumStatus != currentPremiumStatus;

    // Check for invalid config (mismatch between subscription and user config)
    final hasInvalidConfig = _checkInvalidConfig(
      userProfile,
      currentPremiumStatus,
    );

    // Force update if it's been more than 24 hours
    final needsDailyUpdate = _shouldPerformDailyUpdate(lastUpdateTime);

    if (statusChanged || hasInvalidConfig || needsDailyUpdate) {
      print(
        'User needs update - Status changed: $statusChanged, Invalid config: $hasInvalidConfig, Daily update: $needsDailyUpdate',
      );

      // Save current status
      await sharedPreferences.setBool('was_premium', currentPremiumStatus);
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
      print('Updating ${servers.length} servers in repository');

      // Clear existing selected server
      await serverRepository.clearSelectedServer();

      // If there are servers available, select the first one
      if (servers.isNotEmpty) {
        await serverRepository.saveSelectedServer(servers.first);
        print('Selected first server: ${servers.first.name}');
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
      sharedPreferences.remove(_userCreatedKey),
    ]);
  }

  // Public method to check if user has been created
  bool hasUserBeenCreated() {
    return sharedPreferences.getBool(_userCreatedKey) ?? false;
  }

  // Public method to force user creation
  Future<AppInitializationResult> forceUserCreation() async {
    await _clearUserPreferences();
    return initializeApp();
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
