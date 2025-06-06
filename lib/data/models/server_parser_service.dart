// lib/data/models/server_parser_service.dart
import 'dart:convert';
import '../../domain/entities/server.dart';

class ServerParserService {
  static List<Server> parseServerLinks(List<String> links) {
    final servers = <Server>[];

    for (String link in links) {
      try {
        if (link == "False") continue; // Skip invalid links

        Server? server;

        if (link.startsWith('vmess://')) {
          server = _parseVmessLink(link);
        } else if (link.startsWith('vless://')) {
          server = _parseVlessLink(link);
        } else if (link.startsWith('trojan://')) {
          server = _parseTrojanLink(link);
        } else if (link.startsWith('ss://')) {
          server = _parseShadowsocksLink(link);
        }

        if (server != null) {
          servers.add(server);
        }
      } catch (e) {
        print('Error parsing server link: $e');
        continue;
      }
    }

    return servers;
  }

  static Server? _parseVmessLink(String link) {
    try {
      final base64Content = link.substring(8); // Remove 'vmess://'
      final decodedBytes = base64Decode(base64Content);
      final decodedString = utf8.decode(decodedBytes);
      final config = json.decode(decodedString);

      final String address = config['add'] ?? '';
      final int port = int.tryParse(config['port']?.toString() ?? '0') ?? 0;
      final String name = config['ps'] ?? 'VMess Server';
      final String country = _extractCountryFromName(name);

      return Server(
        id: '${address}_${port}_vmess',
        name: name,
        country: country,
        address: address,
        port: port,
        protocol: 'vmess',
        configUrl: link,
        isPremium: false,
        ping: 0,
      );
    } catch (e) {
      print('Error parsing VMess link: $e');
      return null;
    }
  }

  static Server? _parseVlessLink(String link) {
    try {
      final uri = Uri.parse(link);
      final address = uri.host;
      final port = uri.port;
      final name = Uri.decodeComponent(
        uri.fragment.isNotEmpty ? uri.fragment : 'VLESS Server',
      );
      final country = _extractCountryFromName(name);

      return Server(
        id: '${address}_${port}_vless',
        name: name,
        country: country,
        address: address,
        port: port,
        protocol: 'vless',
        configUrl: link,
        isPremium: false,
        ping: 0,
      );
    } catch (e) {
      print('Error parsing VLESS link: $e');
      return null;
    }
  }

  static Server? _parseTrojanLink(String link) {
    try {
      final uri = Uri.parse(link);
      final address = uri.host;
      final port = uri.port;
      final name = Uri.decodeComponent(
        uri.fragment.isNotEmpty ? uri.fragment : 'Trojan Server',
      );
      final country = _extractCountryFromName(name);

      return Server(
        id: '${address}_${port}_trojan',
        name: name,
        country: country,
        address: address,
        port: port,
        protocol: 'trojan',
        configUrl: link,
        isPremium: false,
        ping: 0,
      );
    } catch (e) {
      print('Error parsing Trojan link: $e');
      return null;
    }
  }

  static Server? _parseShadowsocksLink(String link) {
    try {
      final uri = Uri.parse(link);
      final address = uri.host;
      final port = uri.port;
      final name = Uri.decodeComponent(
        uri.fragment.isNotEmpty ? uri.fragment : 'Shadowsocks Server',
      );
      final country = _extractCountryFromName(name);

      return Server(
        id: '${address}_${port}_ss',
        name: name,
        country: country,
        address: address,
        port: port,
        protocol: 'shadowsocks',
        configUrl: link,
        isPremium: false,
        ping: 0,
      );
    } catch (e) {
      print('Error parsing Shadowsocks link: $e');
      return null;
    }
  }

  static String _extractCountryFromName(String name) {
    // Extract country from server name
    // Look for common patterns like country codes or country names
    final lowerName = name.toLowerCase();

    // Common country mappings
    final countryMappings = {
      'us': 'United States',
      'usa': 'United States',
      'united states': 'United States',
      'uk': 'United Kingdom',
      'gb': 'United Kingdom',
      'de': 'Germany',
      'germany': 'Germany',
      'fr': 'France',
      'france': 'France',
      'jp': 'Japan',
      'japan': 'Japan',
      'sg': 'Singapore',
      'singapore': 'Singapore',
      'hk': 'Hong Kong',
      'hong kong': 'Hong Kong',
      'ca': 'Canada',
      'canada': 'Canada',
      'au': 'Australia',
      'australia': 'Australia',
      'nl': 'Netherlands',
      'netherlands': 'Netherlands',
      'se': 'Sweden',
      'sweden': 'Sweden',
      'no': 'Norway',
      'norway': 'Norway',
      'ch': 'Switzerland',
      'switzerland': 'Switzerland',
      'in': 'India',
      'india': 'India',
      'kr': 'South Korea',
      'south korea': 'South Korea',
      'korea': 'South Korea',
      'br': 'Brazil',
      'brazil': 'Brazil',
      'ar': 'Argentina',
      'argentina': 'Argentina',
      'mx': 'Mexico',
      'mexico': 'Mexico',
      'ru': 'Russia',
      'russia': 'Russia',
      'tr': 'Turkey',
      'turkey': 'Turkey',
      'ae': 'UAE',
      'uae': 'UAE',
      'sa': 'Saudi Arabia',
      'saudi arabia': 'Saudi Arabia',
      'il': 'Israel',
      'israel': 'Israel',
      'eg': 'Egypt',
      'egypt': 'Egypt',
      'za': 'South Africa',
      'south africa': 'South Africa',
      'ng': 'Nigeria',
      'nigeria': 'Nigeria',
      'ke': 'Kenya',
      'kenya': 'Kenya',
      'marz': 'Iran', // Based on the example data
    };

    for (final entry in countryMappings.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Try to extract from common patterns
    final patterns = [
      RegExp(r'\b([A-Z]{2})\b'), // Two letter country codes
      RegExp(r'\b([A-Za-z]+)\s*\('), // Country before parentheses
      RegExp(r'🚀\s*([A-Za-z\s]+)\s*\('), // Flag emoji pattern
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(name);
      if (match != null && match.group(1) != null) {
        final extracted = match.group(1)!.trim();
        final mapped = countryMappings[extracted.toLowerCase()];
        if (mapped != null) {
          return mapped;
        }
        return extracted;
      }
    }

    return 'Unknown';
  }

  static Map<String, dynamic> parseVmessConfig(String link) {
    try {
      final base64Content = link.substring(8);
      final decodedBytes = base64Decode(base64Content);
      final decodedString = utf8.decode(decodedBytes);
      return json.decode(decodedString);
    } catch (e) {
      throw Exception('Failed to parse VMess config: $e');
    }
  }

  static Map<String, String> parseVlessConfig(String link) {
    try {
      final uri = Uri.parse(link);
      final config = <String, String>{};

      config['address'] = uri.host;
      config['port'] = uri.port.toString();
      config['id'] = uri.userInfo;

      uri.queryParameters.forEach((key, value) {
        config[key] = value;
      });

      return config;
    } catch (e) {
      throw Exception('Failed to parse VLESS config: $e');
    }
  }
}
