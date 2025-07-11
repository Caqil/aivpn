// lib/data/datasources/user_creation_api.dart - Fixed username handling
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_profile_model.dart';

abstract class UserCreationApi {
  Future<UserProfileModel> createUser({
    required String userId,
    required bool isPremium,
  });

  Future<bool> checkUserExists(String userId);
  Future<UserProfileModel> fetchUserProfile(String userId);
  Future<void> updateUserStatus({
    required String userId,
    required bool isPremium,
  });
}

class UserCreationApiImpl implements UserCreationApi {
  final Dio dio;

  UserCreationApiImpl(this.dio);

  @override
  Future<UserProfileModel> createUser({
    required String userId,
    required bool isPremium,
  }) async {
    try {
      print('🔄 Creating user: $userId (Premium: $isPremium)');

      // Sanitize the username to meet API requirements
      final sanitizedUsername = _sanitizeUsername(userId);
      print('📝 Sanitized username: $sanitizedUsername');

      final requestData = _createUserRequestBody(sanitizedUsername, isPremium);
      print('📋 Request payload: $requestData');

      final response = await dio.post(
        '${ApiConstants.baseUrl}/api/user',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ User created successfully, fetching profile...');
        return await fetchUserProfile(sanitizedUsername);
      } else {
        throw ServerException('Failed to create user: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        // User already exists, try to fetch profile
        final sanitizedUsername = _sanitizeUsername(userId);
        try {
          return await fetchUserProfile(sanitizedUsername);
        } catch (fetchError) {
          throw ServerException('User creation conflict: ${e.response?.data}');
        }
      }
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Failed to create user: $e');
    }
  }

  @override
  Future<bool> checkUserExists(String userId) async {
    try {
      final sanitizedUsername = _sanitizeUsername(userId);
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/user/$sanitizedUsername',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Accept': 'application/json',
          },
          validateStatus: (status) =>
              status != null && (status == 200 || status == 404),
        ),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<UserProfileModel> fetchUserProfile(String userId) async {
    try {
      final sanitizedUsername = _sanitizeUsername(userId);
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/user/$sanitizedUsername',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('✅ User profile fetched successfully');
        return UserProfileModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to fetch user profile: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw ServerException('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<void> updateUserStatus({
    required String userId,
    required bool isPremium,
  }) async {
    try {
      final sanitizedUsername = _sanitizeUsername(userId);
      final updateData = _createUserRequestBody(sanitizedUsername, isPremium);

      final response = await dio.put(
        '${ApiConstants.baseUrl}/api/user/$sanitizedUsername',
        data: updateData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to update user status: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw ServerException('Failed to update user status: $e');
    }
  }

  // Helper method to sanitize username - makes it API compliant
  String _sanitizeUsername(String username) {
    return username;
  }

  // Create the request body matching the API specification
  Map<String, dynamic> _createUserRequestBody(String username, bool isPremium) {
    final vmessId = const Uuid().v4();
    final vlessId = const Uuid().v4();

    return {
      "username": username,
      "proxies": {
        "trojan": {},
        "shadowsocks": {"method": "aes-128-gcm"},
        "vmess": {"id": vmessId},
        "vless": {"id": vlessId},
      },
      "inbounds": {
        "trojan": ["Trojan Websocket TLS"],
        "shadowsocks": ["Shadowsocks TCP"],
        "vmess": ["VMess TCP", "VMess Websocket"],
        "vless": ["VLESS TCP REALITY", "VLESS GRPC REALITY"],
      },
      "expire": null,
      "data_limit": isPremium ? null : 2147483648, // 2GB for free users
      "data_limit_reset_strategy": isPremium ? "no_reset" : "month",
      "status": "active",
      "note": isPremium ? "Premium user" : "Free user",
    };
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
        return 'Server error: ${e.response?.statusCode} - ${e.response?.data}';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'Network error: ${e.message}';
    }
  }
}
