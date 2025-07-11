// lib/data/datasources/server_api.dart - Updated with mock support and better error handling
import 'package:dio/dio.dart';
import '../models/server_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';

abstract class ServerApi {
  Future<List<ServerModel>> getServers();
}

class ServerApiImpl implements ServerApi {
  final Dio dio;

  // Development mode flag
  static const bool _useMockServers =
      true; // Set to false when you have real API

  ServerApiImpl(this.dio);

  @override
  Future<List<ServerModel>> getServers() async {
    try {
      print('🌐 ServerApi: Getting servers...');

      // Try to get real servers from API
      final response = await dio.get(
        "${ApiConstants.baseUrl}/api/user",
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> serversJson =
            response.data['servers'] ?? response.data;
        final servers = serversJson
            .map((json) => ServerModel.fromJson(json))
            .toList();
        print('✅ Got ${servers.length} servers from API');
        return servers;
      } else {
        throw ServerException('Failed to load servers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('⚠️ API request failed: ${_handleDioError(e)}');

      // Fall back to mock servers if API fails
      print('🔧 Falling back to mock servers');
      return _getMockServers();
    } catch (e) {
      print('⚠️ Unexpected error: $e');

      // Fall back to mock servers for any other error
      print('🔧 Falling back to mock servers');
      return _getMockServers();
    }
  }

  List<ServerModel> _getMockServers() {
    print('🔧 Generating mock servers...');

    // Generate mock servers for development/testing
    return [
      const ServerModel(
        id: 'mock_us_1',
        name: 'US East Coast',
        country: 'United States',
        address: '192.168.1.100',
        port: 1080,
        protocol: 'vmess',
        configUrl: 'vmess://mock_config_1',
        isPremium: false,
        ping: 45,
      ),
      const ServerModel(
        id: 'mock_us_2',
        name: 'US West Coast',
        country: 'United States',
        address: '192.168.1.101',
        port: 1080,
        protocol: 'vless',
        configUrl: 'vless://mock_config_2',
        isPremium: true,
        ping: 35,
      ),
      const ServerModel(
        id: 'mock_uk_1',
        name: 'London Server',
        country: 'United Kingdom',
        address: '192.168.1.102',
        port: 2080,
        protocol: 'trojan',
        configUrl: 'trojan://mock_config_3',
        isPremium: false,
        ping: 65,
      ),
      const ServerModel(
        id: 'mock_de_1',
        name: 'Frankfurt Server',
        country: 'Germany',
        address: '192.168.1.103',
        port: 3080,
        protocol: 'shadowsocks',
        configUrl: 'ss://mock_config_4',
        isPremium: true,
        ping: 55,
      ),
      const ServerModel(
        id: 'mock_sg_1',
        name: 'Singapore Server',
        country: 'Singapore',
        address: '192.168.1.104',
        port: 4080,
        protocol: 'vmess',
        configUrl: 'vmess://mock_config_5',
        isPremium: false,
        ping: 85,
      ),
      const ServerModel(
        id: 'mock_jp_1',
        name: 'Tokyo Server',
        country: 'Japan',
        address: '192.168.1.105',
        port: 5080,
        protocol: 'vless',
        configUrl: 'vless://mock_config_6',
        isPremium: true,
        ping: 75,
      ),
      const ServerModel(
        id: 'mock_au_1',
        name: 'Sydney Server',
        country: 'Australia',
        address: '192.168.1.106',
        port: 6080,
        protocol: 'trojan',
        configUrl: 'trojan://mock_config_7',
        isPremium: false,
        ping: 125,
      ),
      const ServerModel(
        id: 'mock_ca_1',
        name: 'Toronto Server',
        country: 'Canada',
        address: '192.168.1.107',
        port: 7080,
        protocol: 'shadowsocks',
        configUrl: 'ss://mock_config_8',
        isPremium: true,
        ping: 40,
      ),
    ];
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
      case DioExceptionType.connectionError:
        return 'Connection error - server may be unavailable';
      default:
        return 'Network error';
    }
  }

  // Method to test if API is available
  Future<bool> isApiAvailable() async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/health',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Method to get server stats
  Future<Map<String, dynamic>> getServerStats() async {
    if (_useMockServers) {
      return {
        'total_servers': 8,
        'online_servers': 7,
        'premium_servers': 4,
        'free_servers': 3,
        'average_ping': 67,
      };
    }

    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/api/servers/stats',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException('Failed to get server stats');
      }
    } catch (e) {
      throw ServerException('Failed to get server stats: $e');
    }
  }
}
