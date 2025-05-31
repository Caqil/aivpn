import 'package:equatable/equatable.dart';

class Server extends Equatable {
  final String id;
  final String name;
  final String country;
  final String address;
  final int port;
  final String protocol;
  final String? configUrl;
  final bool isPremium;
  final int ping;

  const Server({
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

  String get flagAsset =>
      'assets/flags/${country.toLowerCase().replaceAll(' ', '_')}.svg';

  String get displayName => '$name - $country';

  String get connectionString => '$address:$port';

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
