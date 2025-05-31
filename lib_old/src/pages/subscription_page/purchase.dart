import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:safer_vpn/src/constants/index.dart';
import 'package:safer_vpn/src/features/index.dart';
import 'package:safer_vpn/src/pages/subscription_page/consumable.dart';
import 'package:http/http.dart' as http;
import 'package:safer_vpn/src/toast/flutter_styled_toast.dart';

bool get isAppstore {
  if (kIsWeb) return false;
  return [
    TargetPlatform.iOS,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

bool get isMobile {
  if (kIsWeb) return false;
  return [
    TargetPlatform.iOS,
    TargetPlatform.android,
  ].contains(defaultTargetPlatform);
}

class PurchaseWidget extends StatefulWidget {
  final bool? showYearlyOnly;
  const PurchaseWidget({super.key, this.showYearlyOnly});

  @override
  State<PurchaseWidget> createState() => _PurchaseWidgetState();
}

class _PurchaseWidgetState extends State<PurchaseWidget> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];
  List<PurchaseDetails> _purchases = <PurchaseDetails>[];
  List<String> _consumables = <String>[];
  bool _isAvailable = false;
  bool _loading = true;
  String? _queryProductError;
  bool _purchasePending = false;
  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated =
        _inAppPurchase.purchaseStream;
    _subscription =
        purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (Object error) {
      // handle error here.
    });
    initStoreInfo();
    super.initState();
  }

  showLoading(BuildContext context,
      {bool? isDismissible, bool? useLogo = false}) {
    showCupertinoDialog(
        context: context,
        barrierDismissible: isDismissible ?? false,
        builder: (BuildContext context) {
          return const CupertinoActivityIndicator();
        });
  }

  Future<void> hideLoadingDialog(BuildContext context, {dynamic result}) async {
    Navigator.pop(context, result);
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();

    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = <ProductDetails>[];
        _purchases = <PurchaseDetails>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });

      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(listProductIds.toSet());
    if (productDetailResponse.error != null) {
      if (mounted) {
        setState(() {
          _queryProductError = productDetailResponse.error!.message;
          _isAvailable = isAvailable;
          _products = productDetailResponse.productDetails;
          _purchases = <PurchaseDetails>[];
          _consumables = <String>[];
          _purchasePending = false;
          _loading = false;
        });
      }
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = <PurchaseDetails>[];
        _consumables = <String>[];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    final List<String> consumables = await ConsumableStore.load();
    if (mounted) {
      setState(() {
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _consumables = consumables;
        _purchasePending = false;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    showLoading(context);

    var uri = '${Apis.baseUrl + Apis.api}/update-subscription';
    var headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $userToken",
    };
    final response = await http.post(Uri.parse(uri), headers: headers, body: {
      "platform": isAppstore ? "itunes" : "googleplay",
      "plan": purchaseDetails.productID.contains(yearly360) ? "9" : "3",
      "payment_gateway_id": isAppstore ? "5" : "6",
      "receipt_data": purchaseDetails.verificationData.serverVerificationData,
    });
    if (response.statusCode == HttpStatus.ok) {
      hideLoadingDialog(context);
      _purchasePending = false;
    } else {
      hideLoadingDialog(context);
      _purchasePending = false;
    }
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    _purchasePending = false;
    showToast(
      "invalid purchase",
      backgroundColor: CupertinoColors.systemRed,
      context: context,
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.center,
      animDuration: const Duration(seconds: 1),
      duration: const Duration(seconds: 4),
      curve: Curves.elasticOut,
      reverseCurve: Curves.linear,
    );
  }

  Widget _discountAmount(double value) {
    final currencyFormatter =
        NumberFormat.decimalPatternDigits(decimalDigits: 2);
    double calDipper = value;
    double p;
    p = (calDipper / 1200) * 100;

    value = p;
    return Text(
      "${currencyFormatter.format(value).replaceAll(',', '.')} /Month",
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Future<void> consume(String id) async {
    await ConsumableStore.consume(id);
    final List<String> consumables = await ConsumableStore.load();
    setState(() {
      _consumables = consumables;
    });
  }

  void showPendingUI() {
    setState(() {
      showLoading(context);
      _purchasePending = true;
    });
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.canceled) {
          hideLoadingDialog(context);
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          showToast(
            "invalid purchase",
            backgroundColor: CupertinoColors.systemRed,
            context: context,
            animation: StyledToastAnimation.scale,
            reverseAnimation: StyledToastAnimation.fade,
            position: StyledToastPosition.center,
            animDuration: const Duration(seconds: 1),
            duration: const Duration(seconds: 4),
            curve: Curves.elasticOut,
            reverseCurve: Curves.linear,
          );
        } else if (purchaseDetails.status == PurchaseStatus.restored) {
          showLoading(context);
          Future.delayed(const Duration(seconds: 3), () {
            hideLoadingDialog(context);
          });
        } else if (purchaseDetails.status == PurchaseStatus.purchased) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails)
                .then((value) => hideLoadingDialog(context));
          }
        } else {
          _handleInvalidPurchase(purchaseDetails);
          Future.delayed(const Duration(seconds: 1), () {
            hideLoadingDialog(context);
          });
          return;
        }
        if (Platform.isAndroid) {
          if (!autoConsume && purchaseDetails.productID == consumableId) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> confirmPriceChange(BuildContext context) async {
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iapStoreKitPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iapStoreKitPlatformAddition.showPriceConsentIfNeeded();
    }
  }

  GooglePlayPurchaseDetails? _getOldSubscription(
      ProductDetails productDetails, Map<String, PurchaseDetails> purchases) {
    GooglePlayPurchaseDetails? oldSubscription;
    if (productDetails.id == monthly360 && purchases[monthly360] != null) {
      oldSubscription = purchases[monthly360]! as GooglePlayPurchaseDetails;
    } else if (productDetails.id == yearly360 && purchases[yearly360] != null) {
      oldSubscription = purchases[yearly360]! as GooglePlayPurchaseDetails;
    }
    return oldSubscription;
  }

  _buildProductList() {
    AuthNotifier userNotifier = Provider.of(context, listen: false);
    userNotifier.getProfiles(context);
    if (_loading) {
      return const Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [CupertinoActivityIndicator()],
      ));
    }
    if (!_isAvailable) {
      return Container();
    }
    final List<Padding> productList = <Padding>[];
    final Map<String, PurchaseDetails> purchases =
        Map<String, PurchaseDetails>.fromEntries(
            _purchases.map((PurchaseDetails purchase) {
      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
      return MapEntry<String, PurchaseDetails>(purchase.productID, purchase);
    }));
    productList.addAll(_products.map(
      (ProductDetails productDetails) {
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5.0),
            child: productDetails.title.contains('year')
                ? Stack(
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2,
                                    color: CupertinoColors.systemBlue),
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: CupertinoListTile(
                                title: Text(productDetails.title,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge),
                                trailing:
                                    _discountAmount(productDetails.rawPrice),
                                subtitle: Text(
                                  productDetails.price,
                                  style: const TextStyle(
                                      color: CupertinoColors.activeGreen),
                                ),
                                onTap: () async {
                                  late PurchaseParam purchaseParam;
                                  if (Platform.isAndroid) {
                                    final GooglePlayPurchaseDetails?
                                        oldSubscription = _getOldSubscription(
                                            productDetails, purchases);

                                    purchaseParam = GooglePlayPurchaseParam(
                                        productDetails: productDetails,
                                        changeSubscriptionParam:
                                            (oldSubscription != null)
                                                ? ChangeSubscriptionParam(
                                                    oldPurchaseDetails:
                                                        oldSubscription,
                                                  )
                                                : null);
                                  } else {
                                    purchaseParam = PurchaseParam(
                                      productDetails: productDetails,
                                    );
                                  }

                                  if (productDetails.id == consumableId) {
                                    _inAppPurchase.buyConsumable(
                                        purchaseParam: purchaseParam,
                                        autoConsume: autoConsume);
                                  } else {
                                    _inAppPurchase.buyNonConsumable(
                                        purchaseParam: purchaseParam);
                                  }
                                  HapticFeedback.selectionClick();
                                },
                              ))),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              width: 2, color: CupertinoColors.systemBlue),
                          borderRadius: BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: CupertinoListTile(
                          title: Text(
                            productDetails.title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          trailing: Text(
                            productDetails.price,
                            style: const TextStyle(),
                          ),
                          subtitle: Text(productDetails.price,
                              style: const TextStyle(
                                  color: CupertinoColors.activeGreen)),
                          onTap: () async {
                            late PurchaseParam purchaseParam;
                            if (Platform.isAndroid) {
                              final GooglePlayPurchaseDetails? oldSubscription =
                                  _getOldSubscription(
                                      productDetails, purchases);

                              purchaseParam = GooglePlayPurchaseParam(
                                  applicationUserName: userNotifier.user.email,
                                  productDetails: productDetails,
                                  changeSubscriptionParam: (oldSubscription !=
                                          null)
                                      ? ChangeSubscriptionParam(
                                          oldPurchaseDetails: oldSubscription,
                                        )
                                      : null);
                            } else {
                              purchaseParam = PurchaseParam(
                                applicationUserName: userNotifier.user.email,
                                productDetails: productDetails,
                              );
                            }

                            if (productDetails.id == consumableId) {
                              _inAppPurchase.buyConsumable(
                                  purchaseParam: purchaseParam,
                                  autoConsume: autoConsume);
                            } else {
                              _inAppPurchase.buyNonConsumable(
                                  purchaseParam: purchaseParam);
                            }
                            HapticFeedback.selectionClick();
                          },
                        ))));
      },
    ));

    return Column(children: productList);
  }

  @override
  Widget build(BuildContext context) {
    return _buildProductList();
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
