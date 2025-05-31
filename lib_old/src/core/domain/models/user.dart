import 'package:safer_vpn/src/core/index.dart';

const String tableServer = 'id';
const String columnCountryName = 'country';
const String columnCity = 'state';
const String columnStatus = 'status';
const String columnIp = 'ipAddress';
const String columnIsRecommended = 'recommended';
const String columnIsFree = 'isPremium';

class User {
  int? id;
  String? name;
  String? firstname;
  String? lastname;
  String? email;
  Address? address;
  String? avatar;
  String? apiToken;
  String? emailVerifiedAt;
  String? emailToken;
  String? verificationCode;
  int? google2faStatus;
  int? status;
  int? isViewed;
  String? dns;
  int? download;
  int? upload;
  int? serverId;
  String? createdAt;
  String? updatedAt;
  Subscription? subscription;
  Servers? servers;
  Logs? logs;

  User(
      {this.id,
      this.name,
      this.firstname,
      this.lastname,
      this.email,
      this.address,
      this.avatar,
      this.apiToken,
      this.emailVerifiedAt,
      this.emailToken,
      this.verificationCode,
      this.google2faStatus,
      this.status,
      this.isViewed,
      this.dns,
      this.download,
      this.upload,
      this.serverId,
      this.createdAt,
      this.updatedAt,
      this.subscription,
      this.servers,
      this.logs});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    email = json['email'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    avatar = json['avatar'];
    apiToken = json['api_token'];
    emailVerifiedAt = json['email_verified_at'];
    emailToken = json['email_token'];
    verificationCode = json['verification_code'];
    google2faStatus = json['google2fa_status'];
    status = json['status'];
    isViewed = json['is_viewed'];
    dns = json['dns'];
    download = json['download'];
    upload = json['upload'];
    serverId = json['server_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    subscription = json['subscription'] != null
        ? Subscription.fromJson(json['subscription'])
        : null;
    servers =
        json['servers'] != null ? Servers.fromJson(json['servers']) : null;
    logs = json['logs'] != null ? Logs.fromJson(json['logs']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['email'] = email;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['avatar'] = avatar;
    data['api_token'] = apiToken;
    data['email_verified_at'] = emailVerifiedAt;
    data['email_token'] = emailToken;
    data['verification_code'] = verificationCode;
    data['google2fa_status'] = google2faStatus;
    data['status'] = status;
    data['is_viewed'] = isViewed;
    data['dns'] = dns;
    data['download'] = download;
    data['upload'] = upload;
    data['server_id'] = serverId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    if (servers != null) {
      data['servers'] = servers!.toJson();
    }
    if (logs != null) {
      data['logs'] = logs!.toJson();
    }
    return data;
  }
}

class Address {
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? zip;
  String? country;

  Address(
      {this.address1,
      this.address2,
      this.city,
      this.state,
      this.zip,
      this.country});

  Address.fromJson(Map<String, dynamic> json) {
    address1 = json['address_1'];
    address2 = json['address_2'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address_1'] = address1;
    data['address_2'] = address2;
    data['city'] = city;
    data['state'] = state;
    data['zip'] = zip;
    data['country'] = country;
    return data;
  }
}
