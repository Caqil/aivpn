import 'package:equatable/equatable.dart';
import '../../domain/entities/server.dart';

class ServerModel extends Equatable {
  final String id;
  final String name;
  final String country;
  final String address;
  final int port;
  final String protocol;
  final String? configUrl;
  final bool isPremium;
  final int ping;

  const ServerModel({
    required this.id,
    required this.name,
    required this.country,
    required this.address,
    required this.port,
    required this.protocol,
    this.configUrl,
    this.isPremium = false,
    this.ping = 0,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      address: json['address'] ?? '',
      port: json['port'] ?? 0,
      protocol: json['protocol'] ?? 'vmess',
      configUrl: json['config_url'],
      isPremium: json['is_premium'] ?? false,
      ping: json['ping'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'address': address,
      'port': port,
      'protocol': protocol,
      'config_url': configUrl,
      'is_premium': isPremium,
      'ping': ping,
    };
  }

  Server toEntity() {
    return Server(
      id: id,
      name: name,
      country: country,
      address: address,
      port: port,
      protocol: protocol,
      configUrl: configUrl,
      isPremium: isPremium,
      ping: ping,
    );
  }

  factory ServerModel.fromEntity(Server server) {
    return ServerModel(
      id: server.id,
      name: server.name,
      country: server.country,
      address: server.address,
      port: server.port,
      protocol: server.protocol,
      configUrl: server.configUrl,
      isPremium: server.isPremium,
      ping: server.ping,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        country,
        address,
        port,
        protocol,
        configUrl,
        isPremium,
        ping,
      ];
}
