import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'premium_config.dart';

class PremiumState {
  final bool isPremium;
  final bool isLoading;
  final String? errorMessage;
  final List<Package> offerings;

  PremiumState({
    required this.isPremium,
    this.isLoading = false,
    this.errorMessage,
    this.offerings = const [],
  });

  PremiumState copyWith({
    bool? isPremium,
    bool? isLoading,
    String? errorMessage,
    List<Package>? offerings,
  }) {
    return PremiumState(
      isPremium: isPremium ?? this.isPremium,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      offerings: offerings ?? this.offerings,
    );
  }
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  PremiumNotifier() : super(PremiumState(isPremium: false)) {
    _initRevenueCat();
  }

  // Set to true to bypass RevenueCat and force premium for simulation/local testing
  bool _forcePremiumSimulated = false;

  Future<void> _initRevenueCat() async {
    if (kIsWeb) {
      // RevenueCat purchases_flutter is not fully supported on Web directly without custom configurations.
      // We will default web views to allow simulated premium testing.
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);
      
      final apiKey = PremiumConfig.androidApiKey;
      
      // Only configure if a valid API Key has been provided
      if (apiKey.isEmpty || apiKey.startsWith('COLE_AQUI')) {
        debugPrint("RevenueCat: No active API Key found in PremiumConfig. Running in local simulation mode.");
        return;
      }
      
      await Purchases.configure(PurchasesConfiguration(apiKey));
      
      // Check customer info
      final customerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(customerInfo);

      // Listen for updates
      Purchases.addCustomerInfoUpdateListener((info) {
        _updatePremiumStatus(info);
      });

      _loadOfferings();
    } catch (e) {
      debugPrint("RevenueCat failed to initialize: $e");
    }
  }

  void _updatePremiumStatus(CustomerInfo info) {
    // Check for entitlement or active subscriptions
    final ent = info.entitlements.all[PremiumConfig.entitlementId];
    final isPrem = (ent != null && ent.isActive) || _forcePremiumSimulated;
    state = state.copyWith(isPremium: isPrem);
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current != null) {
        state = state.copyWith(offerings: offerings.current!.availablePackages);
      }
    } catch (e) {
      debugPrint("Error fetching offerings: $e");
    }
  }

  Future<bool> purchasePackage(Package package) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final info = await Purchases.purchasePackage(package);
      _updatePremiumStatus(info);
      return state.isPremium;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'A compra não pôde ser concluída. Tente novamente.',
      );
      return false;
    }
  }

  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final info = await Purchases.restorePurchases();
      _updatePremiumStatus(info);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Não foi possível restaurar suas compras.',
      );
    }
  }

  // Toggle for developer demonstration
  void togglePremiumSimulated() {
    _forcePremiumSimulated = !_forcePremiumSimulated;
    state = state.copyWith(isPremium: _forcePremiumSimulated);
  }
}

final premiumProvider = StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  return PremiumNotifier();
});
