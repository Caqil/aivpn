import 'package:dio/dio.dart';
import '../models/server_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';

abstract class ServerApi {
  Future<List<ServerModel>> getServers();
}

class ServerApiImpl implements ServerApi {
  final Dio dio;

  ServerApiImpl(this.dio);

  @override
  Future<List<ServerModel>> getServers() async {
    try {
      final response = await dio.get(
        ApiConstants.serversEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${ApiConstants.apiToken}',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> serversJson =
            response.data['servers'] ?? response.data;
        return serversJson.map((json) => ServerModel.fromJson(json)).toList();
      } else {
        throw ServerException('Failed to load servers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ServerException(_handleDioError(e));
    } catch (e) {
      throw ServerException('Unexpected error: $e');
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
