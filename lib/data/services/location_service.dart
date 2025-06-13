// lib/core/services/location_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';

class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();
  LocationService._();

  final Dio _dio = Dio();
  UserLocation? _cachedLocation;
  DateTime? _lastFetchTime;
  static const Duration _cacheTimeout = Duration(hours: 1);

  Future<UserLocation> getCurrentLocation() async {
    // Check if we have cached location that's still valid
    if (_cachedLocation != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheTimeout) {
      return _cachedLocation!;
    }

    try {
      final response = await _dio.get(
        'http://ip-api.com/json/',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == 'success') {
          _cachedLocation = UserLocation(
            country: data['country'] ?? 'Unknown',
            city: data['city'] ?? 'Unknown',
            region: data['regionName'] ?? 'Unknown',
            latitude: (data['lat'] ?? 0.0).toDouble(),
            longitude: (data['lon'] ?? 0.0).toDouble(),
            ip: data['query'] ?? 'Unknown',
            timezone: data['timezone'] ?? 'Unknown',
            countryCode: data['countryCode'] ?? 'UN',
          );
          _lastFetchTime = DateTime.now();
          return _cachedLocation!;
        } else {
          throw LocationException('IP-API returned error: ${data['message']}');
        }
      } else {
        throw LocationException(
          'Failed to get location: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw LocationException(_handleDioError(e));
    } catch (e) {
      throw LocationException('Unexpected error getting location: $e');
    }
  }

  Future<GlobeCoordinates> getUserCoordinates() async {
    try {
      final location = await getCurrentLocation();
      return GlobeCoordinates(location.latitude, location.longitude);
    } catch (e) {
      // Fallback to default coordinates (London) if location fetch fails
      print('Failed to get user location, using default: $e');
      return const GlobeCoordinates(51.5072, -0.1276); // London
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout while getting location';
      case DioExceptionType.sendTimeout:
        return 'Send timeout while getting location';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout while getting location';
      case DioExceptionType.badResponse:
        return 'Server error while getting location: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Location request cancelled';
      default:
        return 'Network error while getting location';
    }
  }

  void clearCache() {
    _cachedLocation = null;
    _lastFetchTime = null;
  }
}

class UserLocation {
  final String country;
  final String city;
  final String region;
  final double latitude;
  final double longitude;
  final String ip;
  final String timezone;
  final String countryCode;

  UserLocation({
    required this.country,
    required this.city,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.ip,
    required this.timezone,
    required this.countryCode,
  });

  String get displayName => '$city, $country';

  GlobeCoordinates get coordinates => GlobeCoordinates(latitude, longitude);

  @override
  String toString() {
    return 'UserLocation(country: $country, city: $city, lat: $latitude, lng: $longitude)';
  }
}

class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}
