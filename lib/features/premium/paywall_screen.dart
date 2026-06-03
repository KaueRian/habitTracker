import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../theme/leve_theme.dart';
import 'premium_provider.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumState = ref.watch(premiumProvider);

    return Scaffold(
      backgroundColor: LeveTheme.surfaceWarm,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: LeveTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header
              Center(
                child: Column(
                  children: [
                    Text(
                      'leve+',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 56,
                            color: LeveTheme.primary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Desbloqueie o seu melhor ritmo',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: LeveTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cultive hábitos sem pressão, com inteligência.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: LeveTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Features Checklist
              _buildFeatureItem(
                context,
                Icons.all_inclusive,
                'Hábitos Ilimitados',
                'Adicione quantos hábitos quiser. A versão gratuita é limitada a 4.',
              ),
              const SizedBox(height: 20),
              _buildFeatureItem(
                context,
                Icons.analytics_outlined,
                'Análises Avançadas',
                'Acesse o radar de saúde e histórico de hábitos de 30 dias.',
              ),
              const SizedBox(height: 20),
              _buildFeatureItem(
                context,
                Icons.timer_outlined,
                'Timer de Foco Estendido',
                'Desbloqueie sessões de 15, 25 e 45 minutos no foco compartilhado.',
              ),
              const SizedBox(height: 20),
              _buildFeatureItem(
                context,
                Icons.spa_outlined,
                'Temas & Tons Personalizados',
                'Adapte as mensagens e cores do app ao seu estilo preferido.',
              ),

              const SizedBox(height: 56),

              // Mock Subscription Plans (Standard in Paywalls if RC offerings are empty)
              if (premiumState.offerings.isEmpty) ...[
                _buildMockPlanCard(
                  context,
                  title: 'Plano Anual (Leve+)',
                  price: 'R\$ 49,90 / ano',
                  subtitle: 'Apenas R\$ 4,15 por mês (Economize 58%)',
                  isPopular: true,
                  onTap: () {
                    // Purchase Mock Simulation
                    ref.read(premiumProvider.notifier).togglePremiumSimulated();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Leve+ Ativado com sucesso (Modo Demonstração).')),
                    );
                    Navigator.of(context).pop();
                  },
                ),
                const SizedBox(height: 16),
                _buildMockPlanCard(
                  context,
                  title: 'Plano Mensal',
                  price: 'R\$ 9,90 / mês',
                  subtitle: 'Cancele a qualquer momento',
                  isPopular: false,
                  onTap: () {
                    ref.read(premiumProvider.notifier).togglePremiumSimulated();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Leve+ Ativado com sucesso (Modo Demonstração).')),
                    );
                    Navigator.of(context).pop();
                  },
                ),
              ] else ...[
                // Render real RevenueCat Packages
                ...premiumState.offerings.map((package) {
                  final isAnnual = package.packageType == PackageType.annual;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    key: ValueKey(package.identifier),
                    child: _buildMockPlanCard(
                      context,
                      title: package.storeProduct.title,
                      price: package.storeProduct.priceString,
                      subtitle: isAnnual ? 'Melhor valor' : 'Cobrança mensal',
                      isPopular: isAnnual,
                      onTap: () async {
                        final success = await ref.read(premiumProvider.notifier).purchasePackage(package);
                        if (success && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );
                }),
              ],

              const SizedBox(height: 32),

              // Restore purchases link & info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      await ref.read(premiumProvider.notifier).restorePurchases();
                      if (ref.read(premiumProvider).isPremium && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Assinatura restaurada! Obrigado.')),
                        );
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Restaurar Compras',
                      style: GoogleFonts.inter(color: LeveTheme.primary, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Demo Toggle button for testing helper
                      ref.read(premiumProvider.notifier).togglePremiumSimulated();
                      final current = ref.read(premiumProvider).isPremium;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(current ? 'Leve+ Ativado (Simulado)' : 'Leve+ Desativado (Simulado)')),
                      );
                    },
                    child: Text(
                      'Simular Leve+ (Teste)',
                      style: GoogleFonts.inter(color: LeveTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: LeveTheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: LeveTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: LeveTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMockPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String subtitle,
    required bool isPopular,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPopular ? Colors.white : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: isPopular
              ? Border.all(color: LeveTheme.primary, width: 2)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: LeveTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'MAIS POPULAR',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: LeveTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: LeveTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: LeveTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              price,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: LeveTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
