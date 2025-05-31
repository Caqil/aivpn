import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/core/index.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/core/infrastructure/server/ovpn.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:http/http.dart' as http;

class ServersNotifier with ChangeNotifier {
  late List<Servers> _servers;
  bool? _isConnected;
  String? _vpnStage;
  List<Servers> get servers => _servers;
  static Future<void> getStateVPN(BuildContext context, [String? stage]) async {
    ServersNotifier vpnProvider =
        Provider.of<ServersNotifier>(context, listen: false);
    vpnProvider.vpnStage = stage ?? await OVPN.stage();
    vpnProvider.isConnected = await OVPN.isConnected();
  }

  ///Set current isConnected status and hit the notify
  set isConnected(bool? status) {
    _isConnected = status;
    notifyListeners();
  }

  ///Set current VPNStage and hit the notify
  set vpnStage(String? stage) {
    _vpnStage = stage;
    notifyListeners();
  }

  String? get vpnStage => _vpnStage?.toLowerCase();

  bool? get isConnected => _isConnected!;

  Future<List<Servers>> getAllServer({
    Function? onSuccess,
    Function? onError,
  }) async {
    final response = await http.post(Uri.parse(Apis.serverApi), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
      'X-Api-Key':
          "06RhtKyQB5BxdGOFaHhysy3jx1eZQ23fS56FH3dIKStdskaO4nyLvqOoH5ok8zem"
    });
    final List body = jsonDecode(response.body)['data'];
    if (response.statusCode == HttpStatus.ok) {
      _servers = body.map((e) => Servers.fromJson(e)).toList();
      notifyListeners();
      return _servers;
    } else {
      throw 'Failed to fetch server data!';
    }
  }

  Future<List<Servers>> getFreeServer({
    Function? onSuccess,
    Function? onError,
  }) async {
    final response = await http.post(Uri.parse(Apis.serverApi), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
      'X-Api-Key':
          "06RhtKyQB5BxdGOFaHhysy3jx1eZQ23fS56FH3dIKStdskaO4nyLvqOoH5ok8zem"
    }, body: {
      "is_premium": "0"
    });
    final List body = jsonDecode(response.body)['data'];
    if (response.statusCode == HttpStatus.ok) {
      _servers = body.map((e) => Servers.fromJson(e)).toList();
      notifyListeners();
      return _servers;
    } else {
      throw 'Failed to fetch server data!';
    }
  }

  Future<List<Servers>> getProServer({
    Function? onSuccess,
    Function? onError,
  }) async {
    final response = await http.post(Uri.parse(Apis.serverApi), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
      'X-Api-Key':
          "06RhtKyQB5BxdGOFaHhysy3jx1eZQ23fS56FH3dIKStdskaO4nyLvqOoH5ok8zem"
    }, body: {
      "is_premium": "1"
    });
    final List body = jsonDecode(response.body)['data'];
    if (response.statusCode == HttpStatus.ok) {
      _servers = body.map((e) => Servers.fromJson(e)).toList();
      notifyListeners();
      return _servers;
    } else {
      throw 'Failed to fetch server data!';
    }
  }

  Future<void> updateServer(BuildContext context, int? serverId) async {
    isConnected = await OVPN.isConnected();
    Map<String, String> requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
    };

    final response = await http.post(Uri.parse(Apis.profilesApi),
        headers: requestHeaders, body: {"server_id": "$serverId"});
    if (response.statusCode == HttpStatus.ok) {
      if (context.mounted) {
        Provider.of<AuthNotifier>(context, listen: false).getProfiles(context);
      }
      notifyListeners();
    } else {
      throw 'Failed to update server';
    }

    notifyListeners();
  }

  static ServersNotifier instance(BuildContext context) =>
      Provider.of(context, listen: false);
}
