// import 'dart:async';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import 'package:safer_vpn/src/constants/index.dart';

// class InAppPurchaseService {
//   static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
//   static final List<String> _productIds = <String>[
//     monthly360, // Replace with your product id
//     yearly360, // Replace with your product id
//   ];
//   final List<ProductDetails> _products = [];
//   final List<PurchaseDetails> _purchases = [];
//   StreamSubscription<List<PurchaseDetails>>? _subscription;

//   InAppPurchaseService() {
//     final purchaseUpdated = _inAppPurchase.purchaseStream;
//     _subscription = purchaseUpdated.listen(_onPurchaseUpdated);
//   }

//   Future<void> initialize() async {
//     final bool available = await _inAppPurchase.isAvailable();
//     if (!available) {
//       // Handle the error.
//       return;
//     }

//     final ProductDetailsResponse response =
//         await _inAppPurchase.queryProductDetails(_productIds.toSet());
//     if (response.notFoundIDs.isNotEmpty) {
//       // Handle the error.
//     }

//     _products.addAll(response.productDetails);
//   }

//   void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
//     for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
//       if (purchaseDetails.status == PurchaseStatus.purchased) {
//         _verifyPurchase(purchaseDetails);
//       }
//       if (purchaseDetails.pendingCompletePurchase) {
//         _inAppPurchase.completePurchase(purchaseDetails);
//       }
//     }
//   }

//   Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
//     // Verify the purchase
//   }

//   Future<void> buyProduct(ProductDetails productDetails) async {
//     final PurchaseParam purchaseParam =
//         PurchaseParam(productDetails: productDetails);
//     if (productDetails.id == 'consumable_product_id') {
//       await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
//     } else {
//       await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
//     }
//   }

//   List<ProductDetails> get products => _products;
//   List<PurchaseDetails> get purchases => _purchases;

//   void dispose() {
//     _subscription?.cancel();
//   }
// }
