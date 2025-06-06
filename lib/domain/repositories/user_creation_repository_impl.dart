import 'package:dio/dio.dart';
import '../../core/errors/exceptions.dart';
import '../../data/datasources/user_creation_api.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_creation_repository.dart';
class UserCreationRepositoryImpl implements UserCreationRepository {
  final UserCreationApi userCreationApi;

  UserCreationRepositoryImpl({required this.userCreationApi});

  @override
  Future<UserProfile> createUser({
    required String userId,
    required bool isPremium,
  }) async {
    try {
      final userProfileModel = await userCreationApi.createUser(
        userId: userId,
        isPremium: isPremium,
      );
      return userProfileModel.toEntity();
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to create user: $e');
    }
  }

  @override
  Future<bool> checkUserExists(String userId) async {
    try {
      return await userCreationApi.checkUserExists(userId);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to check user existence: $e');
    }
  }

  @override
  Future<UserProfile> fetchUserProfile(String userId) async {
    try {
      final userProfileModel = await userCreationApi.fetchUserProfile(userId);
      return userProfileModel.toEntity();
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<void> updateUserStatus({
    required String userId,
    required bool isPremium,
  }) async {
    try {
      await userCreationApi.updateUserStatus(
        userId: userId,
        isPremium: isPremium,
      );
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to update user status: $e');
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error';
    }
  }
}
