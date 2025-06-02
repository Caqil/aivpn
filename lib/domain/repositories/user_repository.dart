import '../entities/user.dart';

abstract class UserRepository {
  Future<User?> getCurrentUser();
  Future<User> createOrUpdateUser();
  Future<void> updateUserPreferences(UserPreferences preferences);
  Future<bool> purchaseSubscription(String productId);
  Future<bool> restorePurchases();
  Future<List<SubscriptionPlan>> getAvailableSubscriptions();
  Future<void> logOut();
  Stream<User?> get userStream;
}
