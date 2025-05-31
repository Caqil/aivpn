import 'package:safer_vpn/src/core/index.dart';

class Subscription {
  int? id;
  int? userId;
  int? planId;
  int? status;
  DateTime? expiryAt;
  int? aboutToExpireReminder;
  int? expiredReminder;
  int? isViewed;
  String? createdAt;
  String? updatedAt;
  Plan? plan;

  Subscription(
      {this.id,
      this.userId,
      this.planId,
      this.status,
      this.expiryAt,
      this.aboutToExpireReminder,
      this.expiredReminder,
      this.isViewed,
      this.createdAt,
      this.updatedAt,
      this.plan});

  Subscription.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    planId = json['plan_id'];
    status = json['status'];
    expiryAt = DateTime.parse(json['expiry_at']);
    aboutToExpireReminder = json['about_to_expire_reminder'];
    expiredReminder = json['expired_reminder'];
    isViewed = json['is_viewed'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    plan = json['plan'] != null ? Plan.fromJson(json['plan']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['plan_id'] = planId;
    data['status'] = status;
    data['expiry_at'] = expiryAt;
    data['about_to_expire_reminder'] = aboutToExpireReminder;
    data['expired_reminder'] = expiredReminder;
    data['is_viewed'] = isViewed;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (plan != null) {
      data['plan'] = plan!.toJson();
    }
    return data;
  }
}
