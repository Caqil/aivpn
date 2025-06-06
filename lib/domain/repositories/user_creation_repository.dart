// lib/domain/repositories/user_creation_repository.dart
import '../entities/user_profile.dart';

abstract class UserCreationRepository {
  Future<UserProfile> createUser({
    required String userId,
    required bool isPremium,
  });
  
  Future<bool> checkUserExists(String userId);
  Future<UserProfile> fetchUserProfile(String userId);
  Future<void> updateUserStatus({
    required String userId,
    required bool isPremium,
  });
}
