import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../domain/entities/user.dart';
import '../errors/exceptions.dart';

class RevenueCatService {
  static final String _apiKey = Platform.isIOS
      ? 'appl_YOUR_IOS_API_KEY'
      : 'goog_YOUR_ANDROID_API_KEY';

  static final String monthlyProductId = Platform.isIOS
      ? 'monthly_360'
      : 'monthly_360_android';

  static final String yearlyProductId = Platform.isIOS
      ? 'yearly_360'
      : 'yearly_360_android';

  static RevenueCatService? _instance;
  static RevenueCatService get instance => _instance ??= RevenueCatService._();
  RevenueCatService._();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _deviceId;

  Future<void> initialize() async {
    try {
      // Get device ID
      _deviceId = await _getDeviceId();

      // Configure RevenueCat
      await Purchases.setLogLevel(LogLevel.info);

      PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey)
        ..appUserID = _deviceId;

      await Purchases.configure(configuration);

      print('RevenueCat initialized with device ID: $_deviceId');
    } catch (e) {
      throw VpnException('Failed to initialize RevenueCat: $e');
    }
  }

  Future<String> _getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }
      return 'unknown_device';
    } catch (e) {
      return 'unknown_device_error';
    }
  }

  String? get deviceId => _deviceId;

  Future<CustomerInfo> getCustomerInfo() async {
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      throw VpnException('Failed to get customer info: $e');
    }
  }

  Future<Offerings> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      throw VpnException('Failed to get offerings: $e');
    }
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      CustomerInfo customerInfo = await Purchases.purchasePackage(package);
      return customerInfo;
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw VpnException('Purchase was cancelled by user');
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        throw VpnException('Payment is pending');
      } else {
        throw VpnException('Purchase failed: ${e.message}');
      }
    } catch (e) {
      throw VpnException('Purchase failed: $e');
    }
  }

  Future<CustomerInfo> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      throw VpnException('Failed to restore purchases: $e');
    }
  }

  Future<List<SubscriptionPlan>> getAvailableSubscriptions() async {
    try {
      final offerings = await getOfferings();
      final currentOffering = offerings.current;

      if (currentOffering == null) {
        return [];
      }

      List<SubscriptionPlan> plans = [];

      for (Package package in currentOffering.availablePackages) {
        final product = package.storeProduct;

        PlanType planType;
        if (product.identifier.contains('monthly')) {
          planType = PlanType.monthly;
        } else if (product.identifier.contains('yearly')) {
          planType = PlanType.yearly;
        } else {
          planType = PlanType.lifetime;
        }

        plans.add(
          SubscriptionPlan(
            id: product.identifier,
            name: product.title,
            description: product.description,
            price: product.price,
            currency: product.currencyCode,
            type: planType,
          ),
        );
      }

      return plans;
    } catch (e) {
      throw VpnException('Failed to get available subscriptions: $e');
    }
  }

  Future<bool> purchaseProduct(String productId) async {
    try {
      final offerings = await getOfferings();
      final currentOffering = offerings.current;

      if (currentOffering == null) {
        throw VpnException('No current offering available');
      }

      Package? packageToPurchase;
      for (Package package in currentOffering.availablePackages) {
        if (package.storeProduct.identifier == productId) {
          packageToPurchase = package;
          break;
        }
      }

      if (packageToPurchase == null) {
        throw VpnException('Product not found: $productId');
      }

      final customerInfo = await purchasePackage(packageToPurchase);
      return customerInfo.entitlements.all.isNotEmpty &&
          customerInfo.entitlements.all.values.any(
            (entitlement) => entitlement.isActive,
          );
    } catch (e) {
      if (e is VpnException) rethrow;
      throw VpnException('Purchase failed: $e');
    }
  }

  UserSubscription? parseSubscriptionFromCustomerInfo(
    CustomerInfo customerInfo,
  ) {
    try {
      if (customerInfo.entitlements.all.isEmpty) {
        return null;
      }

      // Get the first active entitlement
      EntitlementInfo? activeEntitlement;
      for (EntitlementInfo entitlement
          in customerInfo.entitlements.all.values) {
        if (entitlement.isActive) {
          activeEntitlement = entitlement;
          break;
        }
      }

      if (activeEntitlement == null) {
        return null;
      }

      PlanType planType;
      if (activeEntitlement.productIdentifier.contains('monthly')) {
        planType = PlanType.monthly;
      } else if (activeEntitlement.productIdentifier.contains('yearly')) {
        planType = PlanType.yearly;
      } else {
        planType = PlanType.lifetime;
      }

      // Parse dates from strings
      DateTime purchaseDate;
      DateTime expiryDate;

      try {
        purchaseDate = DateTime.parse(activeEntitlement.originalPurchaseDate);
      } catch (e) {
        purchaseDate = DateTime.now();
      }

      try {
        expiryDate = activeEntitlement.expirationDate != null
            ? DateTime.parse(activeEntitlement.expirationDate!)
            : DateTime.now().add(const Duration(days: 365));
      } catch (e) {
        expiryDate = DateTime.now().add(const Duration(days: 365));
      }

      return UserSubscription(
        productId: activeEntitlement.productIdentifier,
        transactionId: customerInfo.originalPurchaseDate,
        purchaseDate: purchaseDate,
        expiryDate: expiryDate,
        isActive: activeEntitlement.isActive,
        plan: SubscriptionPlan(
          id: activeEntitlement.productIdentifier,
          name: planType == PlanType.monthly ? 'Monthly Plan' : 'Yearly Plan',
          description: 'VPN Premium ${planType.name}',
          price: 0.0, // We don't have price info in entitlement
          currency: 'USD',
          type: planType,
        ),
      );
    } catch (e) {
      print('Error parsing subscription: $e');
      return null;
    }
  }
}
