class Servers {
  int? id;
  String? country;
  String? state;
  String? latitude;
  String? longitude;
  int? status;
  String? ipAddress;
  int? recommended;
  int? isPremium;
  int? isOvpn;
  String? ovpnConfig;
  String? createdAt;
  String? updatedAt;

  Servers(
      {this.id,
      this.country,
      this.state,
      this.latitude,
      this.longitude,
      this.status,
      this.ipAddress,
      this.recommended,
      this.isPremium,
      this.isOvpn,
      this.ovpnConfig,
      this.createdAt,
      this.updatedAt});

  Servers.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    country = json['country'];
    state = json['state'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    ipAddress = json['ip_address'];
    recommended = json['recommended'];
    isPremium = json['is_premium'];
    isOvpn = json['is_ovpn'];
    ovpnConfig = json['ovpn_config'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country'] = country;
    data['state'] = state;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['ip_address'] = ipAddress;
    data['recommended'] = recommended;
    data['is_premium'] = isPremium;
    data['is_ovpn'] = isOvpn;
    data['ovpn_config'] = ovpnConfig;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
