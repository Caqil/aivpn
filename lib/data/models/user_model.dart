import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

class UserModel extends Equatable {
  final String id;
  final String deviceId;
  final String? name;
  final String? email;
  final UserSubscriptionModel? subscription;
  final UserPreferencesModel preferences;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const UserModel({
    required this.id,
    required this.deviceId,
    this.name,
    this.email,
    this.subscription,
    required this.preferences,
    required this.createdAt,
    required this.lastActiveAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      deviceId: json['device_id'] ?? '',
      name: json['name'],
      email: json['email'],
      subscription: json['subscription'] != null
          ? UserSubscriptionModel.fromJson(json['subscription'])
          : null,
      preferences: UserPreferencesModel.fromJson(
        json['preferences'] ?? <String, dynamic>{},
      ),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      lastActiveAt: DateTime.parse(
        json['last_active_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'subscription': subscription?.toJson(),
      'preferences': preferences.toJson(),
      'created_at': createdAt.toIso8601String(),
      'last_active_at': lastActiveAt.toIso8601String(),
    };
  }

  User toEntity() {
    return User(
      id: id,
      deviceId: deviceId,
      subscription: subscription?.toEntity(),
      preferences: preferences.toEntity(),
      createdAt: createdAt,
      lastActiveAt: lastActiveAt,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      deviceId: user.deviceId,
      subscription: user.subscription != null
          ? UserSubscriptionModel.fromEntity(user.subscription!)
          : null,
      preferences: UserPreferencesModel.fromEntity(user.preferences),
      createdAt: user.createdAt,
      lastActiveAt: user.lastActiveAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    subscription,
    preferences,
    createdAt,
    lastActiveAt,
  ];
}

class UserSubscriptionModel extends Equatable {
  final String productId;
  final String? transactionId;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final bool isActive;
  final SubscriptionPlanModel plan;

  const UserSubscriptionModel({
    required this.productId,
    this.transactionId,
    required this.purchaseDate,
    required this.expiryDate,
    required this.isActive,
    required this.plan,
  });

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      productId: json['product_id'] ?? '',
      transactionId: json['transaction_id'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      expiryDate: DateTime.parse(json['expiry_date']),
      isActive: json['is_active'] ?? false,
      plan: SubscriptionPlanModel.fromJson(json['plan'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'transaction_id': transactionId,
      'purchase_date': purchaseDate.toIso8601String(),
      'expiry_date': expiryDate.toIso8601String(),
      'is_active': isActive,
      'plan': plan.toJson(),
    };
  }

  UserSubscription toEntity() {
    return UserSubscription(
      productId: productId,
      transactionId: transactionId,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      isActive: isActive,
      plan: plan.toEntity(),
    );
  }

  factory UserSubscriptionModel.fromEntity(UserSubscription subscription) {
    return UserSubscriptionModel(
      productId: subscription.productId,
      transactionId: subscription.transactionId,
      purchaseDate: subscription.purchaseDate,
      expiryDate: subscription.expiryDate,
      isActive: subscription.isActive,
      plan: SubscriptionPlanModel.fromEntity(subscription.plan),
    );
  }

  @override
  List<Object?> get props => [
    productId,
    transactionId,
    purchaseDate,
    expiryDate,
    isActive,
    plan,
  ];
}

class SubscriptionPlanModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final PlanType type;

  const SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.type,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      type: _parsePlanType(json['type']),
    );
  }

  static PlanType _parsePlanType(String? type) {
    switch (type?.toLowerCase()) {
      case 'monthly':
        return PlanType.monthly;
      case 'yearly':
        return PlanType.yearly;
      case 'lifetime':
        return PlanType.lifetime;
      default:
        return PlanType.monthly;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'currency': currency,
      'type': type.name,
    };
  }

  SubscriptionPlan toEntity() {
    return SubscriptionPlan(
      id: id,
      name: name,
      description: description,
      price: price,
      currency: currency,
      type: type,
    );
  }

  factory SubscriptionPlanModel.fromEntity(SubscriptionPlan plan) {
    return SubscriptionPlanModel(
      id: plan.id,
      name: plan.name,
      description: plan.description,
      price: plan.price,
      currency: plan.currency,
      type: plan.type,
    );
  }

  @override
  List<Object?> get props => [id, name, description, price, currency, type];
}

class UserPreferencesModel extends Equatable {
  final String languageCode;
  final String countryCode;
  final bool autoConnect;
  final bool showAds;
  final String selectedServerId;

  const UserPreferencesModel({
    this.languageCode = 'en',
    this.countryCode = 'US',
    this.autoConnect = false,
    this.showAds = true,
    this.selectedServerId = '',
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      languageCode: json['language_code'] ?? 'en',
      countryCode: json['country_code'] ?? 'US',
      autoConnect: json['auto_connect'] ?? false,
      showAds: json['show_ads'] ?? true,
      selectedServerId: json['selected_server_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language_code': languageCode,
      'country_code': countryCode,
      'auto_connect': autoConnect,
      'show_ads': showAds,
      'selected_server_id': selectedServerId,
    };
  }

  UserPreferences toEntity() {
    return UserPreferences(
      languageCode: languageCode,
      countryCode: countryCode,
      autoConnect: autoConnect,
      showAds: showAds,
      selectedServerId: selectedServerId,
    );
  }

  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      languageCode: preferences.languageCode,
      countryCode: preferences.countryCode,
      autoConnect: preferences.autoConnect,
      showAds: preferences.showAds,
      selectedServerId: preferences.selectedServerId,
    );
  }

  @override
  List<Object?> get props => [
    languageCode,
    countryCode,
    autoConnect,
    showAds,
    selectedServerId,
  ];
}
