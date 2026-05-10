import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../core/config/app_config.dart';

class BillingService extends ChangeNotifier {
  BillingService._();
  static final BillingService instance = BillingService._();

  CustomerInfo? _customerInfo;
  bool _isLoading = false;
  String? _error;

  CustomerInfo? get customerInfo => _customerInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ─── Init ───────────────────────────────────────────────────────────────────

  Future<void> configure({String? firebaseUid}) async {
    if (kDebugMode) await Purchases.setLogLevel(LogLevel.debug);

    final config = PurchasesConfiguration(AppConfig.revenueCatApiKey)
      ..appUserID = firebaseUid;

    await Purchases.configure(config);
    Purchases.addCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
    await _fetchCustomerInfo();
  }

  // ─── Auth sync ──────────────────────────────────────────────────────────────

  Future<void> login(String firebaseUid) async {
    try {
      final result = await Purchases.logIn(firebaseUid);
      _handleCustomerInfoUpdate(result.customerInfo);
    } on PlatformException catch (e) {
      _setError('Login fehlgeschlagen: ${e.message}');
    }
  }

  Future<void> logout() async {
    try {
      final info = await Purchases.logOut();
      _handleCustomerInfoUpdate(info);
    } on PlatformException catch (e) {
      _setError('Logout fehlgeschlagen: ${e.message}');
    }
  }

  // ─── Customer info ──────────────────────────────────────────────────────────

  Future<void> refreshCustomerInfo() => _fetchCustomerInfo();

  Future<void> _fetchCustomerInfo() async {
    _setLoading(true);
    try {
      final info = await Purchases.getCustomerInfo();
      _handleCustomerInfoUpdate(info);
    } on PlatformException catch (e) {
      _setError('Kundendaten konnten nicht geladen werden: ${e.message}');
    } finally {
      _setLoading(false);
    }
  }

  void _handleCustomerInfoUpdate(CustomerInfo info) {
    _customerInfo = info;
    _error = null;
    notifyListeners();
  }

  // ─── Purchases ──────────────────────────────────────────────────────────────

  Future<bool> purchasePackage(Package package) async {
    _setLoading(true);
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _handleCustomerInfoUpdate(result.customerInfo);
      return result.customerInfo.entitlements.active.containsKey(AppConfig.entitlementId);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code != PurchasesErrorCode.purchaseCancelledError) {
        _setError('Kauf fehlgeschlagen: ${e.message}');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> restorePurchases() async {
    _setLoading(true);
    try {
      final info = await Purchases.restorePurchases();
      _handleCustomerInfoUpdate(info);
      return info.entitlements.active.containsKey(AppConfig.entitlementId);
    } on PlatformException catch (e) {
      _setError('Wiederherstellung fehlgeschlagen: ${e.message}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Paywall ─────────────────────────────────────────────────────────────────

  /// Always shows the paywall regardless of entitlement status.
  Future<PaywallResult> presentPaywall({
    Offering? offering,
    bool displayCloseButton = true,
  }) async {
    return RevenueCatUI.presentPaywall(
      offering: offering,
      displayCloseButton: displayCloseButton,
    );
  }

  /// Shows paywall only if the user does NOT have the pro entitlement.
  /// Returns [PaywallResult.notPresented] if they already have access.
  Future<PaywallResult> presentPaywallIfNeeded({
    Offering? offering,
    bool displayCloseButton = true,
  }) async {
    return RevenueCatUI.presentPaywallIfNeeded(
      AppConfig.entitlementId,
      offering: offering,
      displayCloseButton: displayCloseButton,
    );
  }

  // ─── Customer Center ────────────────────────────────────────────────────────

  /// Shows the RevenueCat Customer Center (manage subscriptions, get support).
  /// Automatically refreshes customer info if the user restores a purchase.
  Future<void> presentCustomerCenter() async {
    await RevenueCatUI.presentCustomerCenter(
      onRestoreCompleted: (info) => _handleCustomerInfoUpdate(info),
    );
  }

  // ─── Debug ───────────────────────────────────────────────────────────────────

  bool _debugProOverride = false;

  bool get isPro =>
      _debugProOverride ||
      (_customerInfo?.entitlements.active
              .containsKey(AppConfig.entitlementId) ??
          false);

  /// Only callable in debug builds. Bypasses paywall gate for UI testing.
  Future<void> debugSkipPaywall() async {
    _debugProOverride = true;
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _error = msg;
    debugPrint('[BillingService] $msg');
    notifyListeners();
  }

  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_handleCustomerInfoUpdate);
    super.dispose();
  }
}
