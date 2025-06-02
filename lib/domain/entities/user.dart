import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String deviceId;
  final UserSubscription? subscription;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime lastActiveAt;

  const User({
    required this.id,
    required this.deviceId,
    this.subscription,
    required this.preferences,
    required this.createdAt,
    required this.lastActiveAt,
  });

  bool get isPremium => subscription?.isActive ?? false;
  bool get isExpired => subscription?.isExpired ?? true;

  User copyWith({
    String? id,
    String? deviceId,
    String? name,
    String? email,
    UserSubscription? subscription,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return User(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      subscription: subscription ?? this.subscription,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
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

class UserSubscription extends Equatable {
  final String productId;
  final String? transactionId;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final bool isActive;
  final SubscriptionPlan plan;

  const UserSubscription({
    required this.productId,
    this.transactionId,
    required this.purchaseDate,
    required this.expiryDate,
    required this.isActive,
    required this.plan,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);

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

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final PlanType type;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, description, price, currency, type];
}

enum PlanType { monthly, yearly, lifetime }

class UserPreferences extends Equatable {
  final String languageCode;
  final String countryCode;
  final bool autoConnect;
  final bool showAds;
  final String selectedServerId;

  const UserPreferences({
    this.languageCode = 'en',
    this.countryCode = 'US',
    this.autoConnect = false,
    this.showAds = true,
    this.selectedServerId = '',
  });

  UserPreferences copyWith({
    String? languageCode,
    String? countryCode,
    bool? autoConnect,
    bool? showAds,
    String? selectedServerId,
  }) {
    return UserPreferences(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      autoConnect: autoConnect ?? this.autoConnect,
      showAds: showAds ?? this.showAds,
      selectedServerId: selectedServerId ?? this.selectedServerId,
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
