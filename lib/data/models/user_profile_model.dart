import 'dart:convert';
import 'package:uuid/uuid.dart';
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
    return UserProfileModel(
      username: json['username'] ?? '',
      status: json['status'] ?? 'active',
      proxies: ProxyConfigModel.fromJson(json['proxies'] ?? {}),
      inbounds: Map<String, List<String>>.from(
        json['inbounds']?.map((k, v) => MapEntry(k, List<String>.from(v))) ??
            {},
      ),
      expire: json['expire'] != null ? DateTime.parse(json['expire']) : null,
      dataLimit: json['data_limit'],
      dataLimitResetStrategy: json['data_limit_reset_strategy'] ?? 'no_reset',
      usedTraffic: json['used_traffic'] ?? 0,
      lifetimeUsedTraffic: json['lifetime_used_traffic'] ?? 0,
      links: List<String>.from(json['links'] ?? []),
      subscriptionUrl: json['subscription_url'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
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
    final servers = ServerParserService.parseServerLinks(links);

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

  static Map<String, dynamic> createUserRequest({
    required String userId,
    required bool isPremium,
  }) {
    final vmessId = const Uuid().v4();
    final vlessId = const Uuid().v4();

    return {
      "username": userId,
      "proxies": {
        "trojan": {},
        "shadowsocks": {"method": "aes-128-gcm"},
        "vmess": {"id": vmessId},
        "vless": {"id": vlessId, "flow": ""},
      },
      "inbounds": {
        "trojan": ["Trojan Websocket TLS"],
        "shadowsocks": ["Shadowsocks TCP"],
        "vmess": ["VMess TCP", "VMess Websocket"],
        "vless": ["VLESS TCP REALITY", "VLESS GRPC REALITY"],
      },
      "expire": isPremium ? null : null,
      "data_limit": isPremium ? null : 2147483648,
      "data_limit_reset_strategy": isPremium ? "no_reset" : "month",
      "status": "active",
      "note": "",
    };
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
      vmess: json['vmess'] != null
          ? VmessConfigModel.fromJson(json['vmess'])
          : null,
      vless: json['vless'] != null
          ? VlessConfigModel.fromJson(json['vless'])
          : null,
      trojan: json['trojan'],
      shadowsocks: json['shadowsocks'],
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
    return {'id': id, 'flow': flow};
  }

  VlessConfig toEntity() {
    return VlessConfig(id: id, flow: flow);
  }
}
