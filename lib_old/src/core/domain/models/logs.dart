class Logs {
  int? id;
  int? userId;
  String? ip;
  String? country;
  String? countryCode;
  String? timezone;
  String? location;
  String? latitude;
  String? longitude;
  String? browser;
  String? os;
  String? createdAt;
  String? updatedAt;

  Logs(
      {this.id,
      this.userId,
      this.ip,
      this.country,
      this.countryCode,
      this.timezone,
      this.location,
      this.latitude,
      this.longitude,
      this.browser,
      this.os,
      this.createdAt,
      this.updatedAt});

  Logs.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    ip = json['ip'];
    country = json['country'];
    countryCode = json['country_code'];
    timezone = json['timezone'];
    location = json['location'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    browser = json['browser'];
    os = json['os'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['ip'] = ip;
    data['country'] = country;
    data['country_code'] = countryCode;
    data['timezone'] = timezone;
    data['location'] = location;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['browser'] = browser;
    data['os'] = os;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
