// lib/core/services/revenuecat_service.dart - Fixed with flutter_udid
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_udid/flutter_udid.dart';
import '../../domain/entities/user.dart';
import '../errors/exceptions.dart';

class RevenueCatService {
  static final String _apiKey = Platform.isIOS
      ? 'appl_YOUR_IOS_API_KEY'  // Replace with your iOS API key
      : 'goog_YOUR_ANDROID_API_KEY';  // Replace with your Android API key

  static final String monthlyProductId = Platform.isIOS
      ? 'monthly_360'
      : 'monthly_360_android';

  static final String yearlyProductId = Platform.isIOS
      ? 'yearly_360'
      : 'yearly_360_android';

  static RevenueCatService? _instance;
  static RevenueCatService get instance => _instance ??= RevenueCatService._();
  RevenueCatService._();

  String? _deviceId;
  String? _userId;

  // Stream controller for customer info updates
  final StreamController<CustomerInfo> _customerInfoController = 
      StreamController<CustomerInfo>.broadcast();

  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;

  Future<void> initialize() async {
    try {
      // Get device ID using flutter_udid
      _deviceId = await FlutterUdid.udid;
      _userId = _deviceId; // Use device ID as user ID

      print('Got device ID from flutter_udid: $_deviceId');

      // Configure RevenueCat
      await Purchases.setLogLevel(LogLevel.info);

      PurchasesConfiguration configuration = PurchasesConfiguration(_apiKey)
        ..appUserID = _userId;

      await Purchases.configure(configuration);

      // Set up customer info listener
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _customerInfoController.add(customerInfo);
      });

      print('RevenueCat initialized with device ID: $_deviceId');
    } catch (e) {
      print('Error initializing RevenueCat: $e');
      throw VpnException('Failed to initialize RevenueCat: $e');
    }
  }

  String? get deviceId => _deviceId;
  String get getUserId => _userId ?? _deviceId ?? '';

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
      _customerInfoController.add(customerInfo);
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
      final customerInfo = await Purchases.restorePurchases();
      _customerInfoController.add(customerInfo);
      return customerInfo;
    } catch (e) {
      throw VpnException('Failed to restore purchases: $e');
    }
  }

  // Check if user has active premium subscription
  bool isPremium(CustomerInfo customerInfo) {
    try {
      // Check if user has any active entitlement
      for (EntitlementInfo entitlement in customerInfo.entitlements.all.values) {
        if (entitlement.isActive) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

  // Check if user's subscription is expired
  bool isExpired(CustomerInfo customerInfo) {
    try {
      // If user has no entitlements, consider as expired/free user
      if (customerInfo.entitlements.all.isEmpty) {
        return true;
      }

      // Check if any entitlement is expired
      for (EntitlementInfo entitlement in customerInfo.entitlements.all.values) {
        if (!entitlement.isActive) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error checking expiration status: $e');
      return true; // Default to expired if we can't determine
    }
  }

  // Get expiration date of current subscription
  DateTime? getExpirationDate(CustomerInfo customerInfo) {
    try {
      for (EntitlementInfo entitlement in customerInfo.entitlements.all.values) {
        if (entitlement.isActive && entitlement.expirationDate != null) {
          return DateTime.parse(entitlement.expirationDate!);
        }
      }
      return null;
    } catch (e) {
      print('Error getting expiration date: $e');
      return null;
    }
  }

  // Get current subscription product ID
  String? getCurrentProductId(CustomerInfo customerInfo) {
    try {
      for (EntitlementInfo entitlement in customerInfo.entitlements.all.values) {
        if (entitlement.isActive) {
          return entitlement.productIdentifier;
        }
      }
      return null;
    } catch (e) {
      print('Error getting current product ID: $e');
      return null;
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
      return isPremium(customerInfo);
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
      for (EntitlementInfo entitlement in customerInfo.entitlements.all.values) {
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

  // Helper method to check subscription status without throwing errors
  Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await getCustomerInfo();
      return isPremium(customerInfo);
    } catch (e) {
      print('Error checking subscription status: $e');
      return false;
    }
  }

  // Helper method to get subscription info safely
  Future<Map<String, dynamic>> getSubscriptionInfo() async {
    try {
      final customerInfo = await getCustomerInfo();
      return {
        'isPremium': isPremium(customerInfo),
        'isExpired': isExpired(customerInfo),
        'expirationDate': getExpirationDate(customerInfo),
        'productId': getCurrentProductId(customerInfo),
      };
    } catch (e) {
      print('Error getting subscription info: $e');
      return {
        'isPremium': false,
        'isExpired': true,
        'expirationDate': null,
        'productId': null,
      };
    }
  }

  void dispose() {
    _customerInfoController.close();
  }
}