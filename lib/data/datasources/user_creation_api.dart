import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/app_constants.dart';
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
      final requestData = UserProfileModel.createUserRequest(
        userId: userId,
        isPremium: isPremium,
      );

      final response = await dio.post(
        '${ApiConstants.baseUrl}/api/user',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // User created successfully, now fetch the full profile
        return await fetchUserProfile(userId);
      } else {
        throw ServerException('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw ServerException('Failed to create user: $e');
    }
  }

  @override
  Future<bool> checkUserExists(String userId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/user/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Accept': 'application/json',
          },
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
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/user/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
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
      final vmessId = const Uuid().v4();
      final vlessId = const Uuid().v4();

      Map<String, dynamic> updateData;

      if (isPremium) {
        // Premium user configuration
        updateData = {
          "proxies": {
            "vmess": {"id": vmessId},
            "vless": {"id": vlessId, "flow": ""},
            "trojan": {},
            "shadowsocks": {"method": "aes-128-gcm"},
          },
          "inbounds": {
            "trojan": ["Trojan Websocket TLS"],
            "shadowsocks": ["Shadowsocks TCP"],
            "vmess": ["VMess TCP", "VMess Websocket"],
            "vless": ["VLESS TCP REALITY", "VLESS GRPC REALITY"],
          },
          "expire": null,
          "data_limit": null,
          "data_limit_reset_strategy": "no_reset",
        };
      } else {
        // Free user configuration
        updateData = {
          "proxies": {
            "vmess": {"id": vmessId},
            "vless": {"id": vlessId, "flow": ""},
            "trojan": {},
            "shadowsocks": {"method": "aes-128-gcm"},
          },
          "inbounds": {
            "trojan": ["Trojan Websocket TLS"],
            "shadowsocks": ["Shadowsocks TCP"],
            "vmess": ["VMess TCP", "VMess Websocket"],
            "vless": ["VLESS TCP REALITY", "VLESS GRPC REALITY"],
          },
          "expire": null,
          "data_limit": 2147483648, // 2GB
          "data_limit_reset_strategy": "month",
          "status": "active",
          "note": "",
        };
      }

      final response = await dio.put(
        '${ApiConstants.baseUrl}/api/user/$userId',
        data: updateData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
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
}
