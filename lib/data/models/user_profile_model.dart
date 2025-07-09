// lib/data/models/user_profile_model.dart - Fixed to handle API response format
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/server.dart';
import 'server_parser_service.dart';

class UserProfileModel {
  final String username;
  final String status;
  final ProxyConfigModel proxies;
  final Map<String, List<String>> inbounds;
  final DateTime? expire;
  final int? dataLimit;
  final String dataLimitResetStrategy;
  final int usedTraffic;
  final int lifetimeUsedTraffic;
  final List<String> links;
  final String subscriptionUrl;
  final DateTime createdAt;

  const UserProfileModel({
    required this.username,
    required this.status,
    required this.proxies,
    required this.inbounds,
    this.expire,
    this.dataLimit,
    required this.dataLimitResetStrategy,
    required this.usedTraffic,
    required this.lifetimeUsedTraffic,
    required this.links,
    required this.subscriptionUrl,
    required this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    print('📥 Parsing user profile JSON: ${json.keys.toList()}');

    return UserProfileModel(
      username: json['username'] ?? '',
      status: json['status'] ?? 'active',
      proxies: ProxyConfigModel.fromJson(json['proxies'] ?? {}),
      inbounds: _parseInbounds(json['inbounds']),
      expire: _parseExpire(json['expire']),
      dataLimit: _parseDataLimit(json['data_limit']),
      dataLimitResetStrategy: json['data_limit_reset_strategy'] ?? 'no_reset',
      usedTraffic: json['used_traffic'] ?? 0,
      lifetimeUsedTraffic: json['lifetime_used_traffic'] ?? 0,
      links: List<String>.from(json['links'] ?? []),
      subscriptionUrl: json['subscription_url'] ?? '',
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'status': status,
      'proxies': proxies.toJson(),
      'inbounds': inbounds,
      'expire': expire?.toIso8601String(),
      'data_limit': dataLimit,
      'data_limit_reset_strategy': dataLimitResetStrategy,
      'used_traffic': usedTraffic,
      'lifetime_used_traffic': lifetimeUsedTraffic,
      'links': links,
      'subscription_url': subscriptionUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserProfile toEntity() {
    print('🔄 Converting to entity. Links count: ${links.length}');

    // Parse servers from links
    final servers = ServerParserService.parseServerLinks(links);
    print('📡 Parsed ${servers.length} servers from links');

    return UserProfile(
      username: username,
      status: status,
      proxies: proxies.toEntity(),
      inbounds: inbounds,
      expire: expire,
      dataLimit: dataLimit,
      dataLimitResetStrategy: dataLimitResetStrategy,
      usedTraffic: usedTraffic,
      lifetimeUsedTraffic: lifetimeUsedTraffic,
      links: links,
      subscriptionUrl: subscriptionUrl,
      createdAt: createdAt,
      servers: servers,
    );
  }

  // Helper method to parse inbounds - handle both empty and populated cases
  static Map<String, List<String>> _parseInbounds(dynamic inbounds) {
    if (inbounds == null) {
      print('📝 Inbounds is null, returning empty map');
      return {};
    }

    if (inbounds is Map<String, dynamic>) {
      if (inbounds.isEmpty) {
        print('📝 Inbounds is empty map');
        return {};
      }

      final result = <String, List<String>>{};
      inbounds.forEach((key, value) {
        if (value is List) {
          result[key] = List<String>.from(value);
        } else {
          result[key] = <String>[];
        }
      });
      print('📝 Parsed inbounds: ${result.keys.toList()}');
      return result;
    }

    print('📝 Inbounds is not a map, returning empty');
    return {};
  }

  // Helper method to parse expire field
  static DateTime? _parseExpire(dynamic expire) {
    if (expire == null || expire == 0) {
      return null;
    }

    if (expire is String) {
      try {
        return DateTime.parse(expire);
      } catch (e) {
        print('❌ Error parsing expire date string: $e');
        return null;
      }
    }

    if (expire is int) {
      if (expire == 0) return null;
      try {
        // Handle both seconds and milliseconds timestamps
        final timestamp = expire > 1000000000000 ? expire : expire * 1000;
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        print('❌ Error parsing expire timestamp: $e');
        return null;
      }
    }

    return null;
  }

  // Helper method to parse data limit
  static int? _parseDataLimit(dynamic dataLimit) {
    if (dataLimit == null) return null;

    if (dataLimit is int) {
      return dataLimit == 0 ? null : dataLimit;
    }

    if (dataLimit is String) {
      try {
        final parsed = int.parse(dataLimit);
        return parsed == 0 ? null : parsed;
      } catch (e) {
        print('❌ Error parsing data limit: $e');
        return null;
      }
    }

    return null;
  }

  // Helper method to parse created_at date
  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) {
      print('⚠️ DateTime is null, using current time');
      return DateTime.now();
    }

    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        print('❌ Error parsing date string: $e');
        return DateTime.now();
      }
    }

    print('⚠️ DateTime is not a string, using current time');
    return DateTime.now();
  }
}

class ProxyConfigModel {
  final VmessConfigModel? vmess;
  final VlessConfigModel? vless;
  final Map<String, dynamic>? trojan;
  final Map<String, dynamic>? shadowsocks;

  const ProxyConfigModel({
    this.vmess,
    this.vless,
    this.trojan,
    this.shadowsocks,
  });

  factory ProxyConfigModel.fromJson(Map<String, dynamic> json) {
    return ProxyConfigModel(
      vmess:
          json['vmess'] != null &&
              json['vmess'] is Map<String, dynamic> &&
              (json['vmess'] as Map).isNotEmpty
          ? VmessConfigModel.fromJson(Map<String, dynamic>.from(json['vmess']))
          : null,
      vless:
          json['vless'] != null &&
              json['vless'] is Map<String, dynamic> &&
              (json['vless'] as Map).isNotEmpty
          ? VlessConfigModel.fromJson(Map<String, dynamic>.from(json['vless']))
          : null,
      trojan:
          json['trojan'] is Map<String, dynamic> &&
              (json['trojan'] as Map).isNotEmpty
          ? Map<String, dynamic>.from(json['trojan'])
          : null,
      shadowsocks:
          json['shadowsocks'] is Map<String, dynamic> &&
              (json['shadowsocks'] as Map).isNotEmpty
          ? Map<String, dynamic>.from(json['shadowsocks'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (vmess != null) 'vmess': vmess!.toJson(),
      if (vless != null) 'vless': vless!.toJson(),
      if (trojan != null) 'trojan': trojan,
      if (shadowsocks != null) 'shadowsocks': shadowsocks,
    };
  }

  ProxyConfig toEntity() {
    return ProxyConfig(
      vmess: vmess?.toEntity(),
      vless: vless?.toEntity(),
      trojan: trojan,
      shadowsocks: shadowsocks,
    );
  }
}

class VmessConfigModel {
  final String id;

  const VmessConfigModel({required this.id});

  factory VmessConfigModel.fromJson(Map<String, dynamic> json) {
    return VmessConfigModel(id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }

  VmessConfig toEntity() {
    return VmessConfig(id: id);
  }
}

class VlessConfigModel {
  final String id;
  final String flow;

  const VlessConfigModel({required this.id, this.flow = ''});

  factory VlessConfigModel.fromJson(Map<String, dynamic> json) {
    return VlessConfigModel(id: json['id'] ?? '', flow: json['flow'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, if (flow.isNotEmpty) 'flow': flow};
  }

  VlessConfig toEntity() {
    return VlessConfig(id: id, flow: flow);
  }
}
