class Plan {
  int? id;
  String? name;
  String? shortDescription;
  int? interval;
  int? advertisements;
  int? isFree;
  int? loginRequire;
  int? isFeatured;
  String? createdAt;
  String? updatedAt;

  Plan(
      {this.id,
      this.name,
      this.shortDescription,
      this.interval,
      this.advertisements,
      this.isFree,
      this.loginRequire,
      this.isFeatured,
      this.createdAt,
      this.updatedAt});

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    shortDescription = json['short_description'];
    interval = json['interval'];
    advertisements = json['advertisements'];
    isFree = json['is_free'];
    loginRequire = json['login_require'];
    isFeatured = json['is_featured'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['short_description'] = shortDescription;
    data['interval'] = interval;
    data['advertisements'] = advertisements;
    data['is_free'] = isFree;
    data['login_require'] = loginRequire;
    data['is_featured'] = isFeatured;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
