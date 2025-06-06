import 'package:equatable/equatable.dart';
import 'server.dart';

class UserProfile extends Equatable {
  final String username;
  final String status;
  final ProxyConfig proxies;
  final Map<String, List<String>> inbounds;
  final DateTime? expire;
  final int? dataLimit;
  final String dataLimitResetStrategy;
  final int usedTraffic;
  final int lifetimeUsedTraffic;
  final List<String> links;
  final String subscriptionUrl;
  final DateTime createdAt;
  final List<Server> servers;

  const UserProfile({
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
    required this.servers,
  });

  bool get isPremium => dataLimit == null || dataLimit == 0;
  bool get isActive => status == 'active';
  
  double get usagePercentage {
    if (dataLimit == null || dataLimit == 0) return 0.0;
    return (usedTraffic / dataLimit!) * 100;
  }

  @override
  List<Object?> get props => [
        username,
        status,
        proxies,
        inbounds,
        expire,
        dataLimit,
        dataLimitResetStrategy,
        usedTraffic,
        lifetimeUsedTraffic,
        links,
        subscriptionUrl,
        createdAt,
        servers,
      ];
}

class ProxyConfig extends Equatable {
  final VmessConfig? vmess;
  final VlessConfig? vless;
  final Map<String, dynamic>? trojan;
  final Map<String, dynamic>? shadowsocks;

  const ProxyConfig({
    this.vmess,
    this.vless,
    this.trojan,
    this.shadowsocks,
  });

  @override
  List<Object?> get props => [vmess, vless, trojan, shadowsocks];
}

class VmessConfig extends Equatable {
  final String id;

  const VmessConfig({required this.id});

  @override
  List<Object?> get props => [id];
}

class VlessConfig extends Equatable {
  final String id;
  final String flow;

  const VlessConfig({
    required this.id,
    this.flow = '',
  });

  @override
  List<Object?> get props => [id, flow];
}
