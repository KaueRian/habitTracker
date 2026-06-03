import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configurações do RevenueCat para o projeto Leve.
/// Os valores são carregados do arquivo .env na raiz do projeto.
/// Copie .env.example → .env e preencha com as suas credenciais.
class PremiumConfig {
  // API Key do SDK (sandbox: test_, produção Google Play: goog_)
  static String get androidApiKey =>
      dotenv.env['REVENUECAT_ANDROID_API_KEY'] ?? '';

  // O Identifier da Entitlement configurada no console do RevenueCat.
  // IMPORTANTE: Use o "Identifier", NÃO o "Display Name".
  static String get entitlementId =>
      dotenv.env['REVENUECAT_ENTITLEMENT_ID'] ?? '';
}
