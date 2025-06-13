// lib/core/services/server_coordinates_service.dart
import 'package:flutter_earth_globe/globe_coordinates.dart';
import '../../domain/entities/server.dart';

class ServerCoordinatesService {
  static ServerCoordinatesService? _instance;
  static ServerCoordinatesService get instance =>
      _instance ??= ServerCoordinatesService._();
  ServerCoordinatesService._();

  // Map of country names to their approximate coordinates (capital cities)
  static const Map<String, GlobeCoordinates> _countryCoordinates = {
    // North America
    'United States': GlobeCoordinates(39.8283, -98.5795),
    'Canada': GlobeCoordinates(56.1304, -106.3468),
    'Mexico': GlobeCoordinates(23.6345, -102.5528),

    // Europe
    'United Kingdom': GlobeCoordinates(55.3781, -3.4360),
    'Germany': GlobeCoordinates(51.1657, 10.4515),
    'France': GlobeCoordinates(46.2276, 2.2137),
    'Netherlands': GlobeCoordinates(52.1326, 5.2913),
    'Switzerland': GlobeCoordinates(46.8182, 8.2275),
    'Sweden': GlobeCoordinates(60.1282, 18.6435),
    'Norway': GlobeCoordinates(60.4720, 8.4689),
    'Russia': GlobeCoordinates(61.5240, 105.3188),
    'Turkey': GlobeCoordinates(38.9637, 35.2433),

    // Asia
    'Japan': GlobeCoordinates(36.2048, 138.2529),
    'Singapore': GlobeCoordinates(1.3521, 103.8198),
    'Hong Kong': GlobeCoordinates(22.3193, 114.1694),
    'South Korea': GlobeCoordinates(35.9078, 127.7669),
    'India': GlobeCoordinates(20.5937, 78.9629),
    'China': GlobeCoordinates(35.8617, 104.1954),
    'Iran': GlobeCoordinates(32.4279, 53.6880),

    // Middle East
    'UAE': GlobeCoordinates(23.4241, 53.8478),
    'Saudi Arabia': GlobeCoordinates(23.8859, 45.0792),
    'Israel': GlobeCoordinates(31.0461, 34.8516),
    'Egypt': GlobeCoordinates(26.0975, 30.0444),

    // Oceania
    'Australia': GlobeCoordinates(-25.2744, 133.7751),

    // South America
    'Brazil': GlobeCoordinates(-14.2350, -51.9253),
    'Argentina': GlobeCoordinates(-38.4161, -63.6167),

    // Africa
    'South Africa': GlobeCoordinates(-30.5595, 22.9375),
    'Nigeria': GlobeCoordinates(9.0820, 8.6753),
    'Kenya': GlobeCoordinates(-0.0236, 37.9062),

    // Default fallback
    'Unknown': GlobeCoordinates(0.0, 0.0),
  };

  // Map of country codes to coordinates
  static const Map<String, GlobeCoordinates> _countryCodeCoordinates = {
    'US': GlobeCoordinates(39.8283, -98.5795),
    'CA': GlobeCoordinates(56.1304, -106.3468),
    'MX': GlobeCoordinates(23.6345, -102.5528),
    'UK': GlobeCoordinates(55.3781, -3.4360),
    'GB': GlobeCoordinates(55.3781, -3.4360),
    'DE': GlobeCoordinates(51.1657, 10.4515),
    'FR': GlobeCoordinates(46.2276, 2.2137),
    'NL': GlobeCoordinates(52.1326, 5.2913),
    'CH': GlobeCoordinates(46.8182, 8.2275),
    'SE': GlobeCoordinates(60.1282, 18.6435),
    'NO': GlobeCoordinates(60.4720, 8.4689),
    'RU': GlobeCoordinates(61.5240, 105.3188),
    'TR': GlobeCoordinates(38.9637, 35.2433),
    'JP': GlobeCoordinates(36.2048, 138.2529),
    'SG': GlobeCoordinates(1.3521, 103.8198),
    'HK': GlobeCoordinates(22.3193, 114.1694),
    'KR': GlobeCoordinates(35.9078, 127.7669),
    'IN': GlobeCoordinates(20.5937, 78.9629),
    'CN': GlobeCoordinates(35.8617, 104.1954),
    'IR': GlobeCoordinates(32.4279, 53.6880),
    'AE': GlobeCoordinates(23.4241, 53.8478),
    'SA': GlobeCoordinates(23.8859, 45.0792),
    'IL': GlobeCoordinates(31.0461, 34.8516),
    'EG': GlobeCoordinates(26.0975, 30.0444),
    'AU': GlobeCoordinates(-25.2744, 133.7751),
    'BR': GlobeCoordinates(-14.2350, -51.9253),
    'AR': GlobeCoordinates(-38.4161, -63.6167),
    'ZA': GlobeCoordinates(-30.5595, 22.9375),
    'NG': GlobeCoordinates(9.0820, 8.6753),
    'KE': GlobeCoordinates(-0.0236, 37.9062),
  };

  GlobeCoordinates getServerCoordinates(Server server) {
    // First try to match by full country name
    GlobeCoordinates? coordinates = _countryCoordinates[server.country];

    if (coordinates != null) {
      return coordinates;
    }

    // Try to match by country code (first 2 characters if it looks like a code)
    if (server.country.length == 2) {
      coordinates = _countryCodeCoordinates[server.country.toUpperCase()];
      if (coordinates != null) {
        return coordinates;
      }
    }

    // Try partial matching for country names
    final lowerCountry = server.country.toLowerCase();
    for (final entry in _countryCoordinates.entries) {
      if (entry.key.toLowerCase().contains(lowerCountry) ||
          lowerCountry.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Try partial matching for country codes
    for (final entry in _countryCodeCoordinates.entries) {
      if (entry.key.toLowerCase() == lowerCountry ||
          lowerCountry.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    // Fallback: try to parse from server name if it contains country info
    coordinates = _parseCoordinatesFromServerName(server.name);
    if (coordinates != null) {
      return coordinates;
    }

    print('Unknown server location: ${server.country}, ${server.name}');
    // Default fallback coordinates (somewhere in the Atlantic Ocean)
    return const GlobeCoordinates(0.0, 0.0);
  }

  GlobeCoordinates? _parseCoordinatesFromServerName(String serverName) {
    final lowerName = serverName.toLowerCase();

    // Check if server name contains any known country names or codes
    for (final entry in _countryCoordinates.entries) {
      if (lowerName.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    for (final entry in _countryCodeCoordinates.entries) {
      if (lowerName.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    return null;
  }

  // Get a list of all supported countries
  List<String> getSupportedCountries() {
    return _countryCoordinates.keys.toList()..sort();
  }

  // Check if a country is supported
  bool isCountrySupported(String country) {
    return _countryCoordinates.containsKey(country) ||
        _countryCodeCoordinates.containsKey(country.toUpperCase());
  }

  // Add custom coordinates for a server (for future enhancement)
  void addCustomServerCoordinates(
    String serverId,
    GlobeCoordinates coordinates,
  ) {
    // This could be stored in shared preferences or a database
    // For now, we'll just log it
    print('Custom coordinates for $serverId: $coordinates');
  }
}
