import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import '../../core/services/revenuecat_service.dart';
import '../../core/errors/exceptions.dart';

class UserRepositoryImpl implements UserRepository {
  final SharedPreferences sharedPreferences;
  final RevenueCatService revenueCatService;

  static const String _userKey = 'current_user';
  static const String _preferencesKey = 'user_preferences';

  UserRepositoryImpl({
    required this.sharedPreferences,
    required this.revenueCatService,
  });

  StreamController<User?>? _userController;

  @override
  Stream<User?> get userStream {
    _userController ??= StreamController<User?>.broadcast();
    return _userController!.stream;
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userJson = sharedPreferences.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson);
        final userModel = UserModel.fromJson(userMap);
        return userModel.toEntity();
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<User> createOrUpdateUser() async {
    try {
      await revenueCatService.initialize();

      final deviceId = revenueCatService.deviceId ?? 'unknown_device';
      final existingUser = await getCurrentUser();

      User user;

      if (existingUser != null) {
        // Update existing user
        user = existingUser.copyWith(lastActiveAt: DateTime.now());
      } else {
        // Create new user
        user = User(
          id: deviceId,
          deviceId: deviceId,
          preferences: const UserPreferences(),
          createdAt: DateTime.now(),
          lastActiveAt: DateTime.now(),
        );
      }

      // Get current subscription status from RevenueCat
      try {
        final customerInfo = await revenueCatService.getCustomerInfo();
        final subscription = revenueCatService
            .parseSubscriptionFromCustomerInfo(customerInfo);
        user = user.copyWith(subscription: subscription);
      } catch (e) {
        print('Error getting customer info: $e');
      }

      await _saveUser(user);
      _userController?.add(user);

      return user;
    } catch (e) {
      throw CacheException('Failed to create or update user: $e');
    }
  }

  @override
  Future<void> updateUserPreferences(UserPreferences preferences) async {
    try {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(
          preferences: preferences,
          lastActiveAt: DateTime.now(),
        );
        await _saveUser(updatedUser);
        _userController?.add(updatedUser);
      }
    } catch (e) {
      throw CacheException('Failed to update user preferences: $e');
    }
  }

  @override
  Future<bool> purchaseSubscription(String productId) async {
    try {
      final success = await revenueCatService.purchaseProduct(productId);

      if (success) {
        // Refresh user subscription info
        final customerInfo = await revenueCatService.getCustomerInfo();
        final subscription = revenueCatService
            .parseSubscriptionFromCustomerInfo(customerInfo);

        final currentUser = await getCurrentUser();
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(subscription: subscription);
          await _saveUser(updatedUser);
          _userController?.add(updatedUser);
        }
      }

      return success;
    } catch (e) {
      if (e is VpnException) rethrow;
      throw VpnException('Purchase failed: $e');
    }
  }

  @override
  Future<bool> restorePurchases() async {
    try {
      final customerInfo = await revenueCatService.restorePurchases();
      final subscription = revenueCatService.parseSubscriptionFromCustomerInfo(
        customerInfo,
      );

      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(subscription: subscription);
        await _saveUser(updatedUser);
        _userController?.add(updatedUser);

        return subscription != null && subscription.isActive;
      }

      return false;
    } catch (e) {
      if (e is VpnException) rethrow;
      throw VpnException('Restore purchases failed: $e');
    }
  }

  @override
  Future<List<SubscriptionPlan>> getAvailableSubscriptions() async {
    try {
      return await revenueCatService.getAvailableSubscriptions();
    } catch (e) {
      if (e is VpnException) rethrow;
      throw VpnException('Failed to get available subscriptions: $e');
    }
  }

  @override
  Future<void> logOut() async {
    try {
      await sharedPreferences.remove(_userKey);
      await sharedPreferences.remove(_preferencesKey);
      _userController?.add(null);
    } catch (e) {
      throw CacheException('Failed to log out: $e');
    }
  }

  Future<void> _saveUser(User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      final userJson = json.encode(userModel.toJson());
      await sharedPreferences.setString(_userKey, userJson);
    } catch (e) {
      throw CacheException('Failed to save user: $e');
    }
  }

  void dispose() {
    _userController?.close();
  }
}
