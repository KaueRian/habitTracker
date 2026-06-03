import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/leve_theme.dart';
import '../auth/auth_provider.dart';
import '../habits/habit_provider.dart';
import '../premium/paywall_screen.dart';
import '../premium/premium_provider.dart';
import 'preferences_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _openUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final premiumState = ref.watch(premiumProvider);
    final identity = ref.watch(identityProvider);
    final seasonalTheme = ref.watch(seasonalThemeProvider);

    final email = authState.user?.email ?? (authState.isGuest ? 'Visitante Anônimo' : 'Sem e-mail');

    return Scaffold(
      backgroundColor: LeveTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ajustes.',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'suas preferências e privacidade',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: LeveTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Profile / Account Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: LeveTheme.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.person_outline, color: LeveTheme.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: LeveTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            premiumState.isPremium ? 'Membro Leve+ Premium 🌸' : 'Plano Gratuito',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: premiumState.isPremium ? LeveTheme.primary : LeveTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Subscription Promo / Management Card
              if (!premiumState.isPremium) ...[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PaywallScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: LeveTheme.primary.withValues(alpha: 0.1),
                      border: Border.all(color: LeveTheme.primary.withValues(alpha: 0.3), width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star_outline, color: LeveTheme.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Experimentar Leve+ Premium',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: LeveTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hábitos ilimitados, radar de saúde e mais.',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: LeveTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: LeveTheme.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // PERSONALIZAÇÃO
              Text(
                'PERSONALIZAÇÃO',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LeveTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.self_improvement, color: LeveTheme.primary),
                      title: Text('Sua Identidade', style: GoogleFonts.inter(fontSize: 14)),
                      subtitle: Text(
                        identity.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: LeveTheme.primary),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => _showIdentityPicker(context, ref, identity),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Icon(Icons.palette_outlined, color: LeveTheme.primary),
                      title: Text('Tema Sazonal', style: GoogleFonts.inter(fontSize: 14)),
                      subtitle: Text(
                        seasonalTheme.toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: LeveTheme.primary),
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => _showThemePicker(context, ref, seasonalTheme),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Options List
              Text(
                'GERAL',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LeveTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline, color: LeveTheme.textSecondary),
                      title: Text('Termos de Uso', style: GoogleFonts.inter(fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => _openUrl('https://leve-app.web.app/terms.html'),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined, color: LeveTheme.textSecondary),
                      title: Text('Política de Privacidade', style: GoogleFonts.inter(fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => _openUrl('https://leve-app.web.app/privacy.html'),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: const Icon(Icons.help_outline, color: LeveTheme.textSecondary),
                      title: Text('Contato & Suporte', style: GoogleFonts.inter(fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right, size: 18),
                      onTap: () => _openUrl('mailto:suporte@leve.app'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'CONTA & SEGURANÇA',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LeveTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.logout, color: LeveTheme.textSecondary),
                      title: Text('Sair da Conta', style: GoogleFonts.inter(fontSize: 14)),
                      onTap: () {
                        ref.read(authProvider.notifier).signOut();
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: Icon(Icons.delete_forever_outlined, color: LeveTheme.primary),
                      title: Text('Excluir Conta', style: GoogleFonts.inter(fontSize: 14, color: LeveTheme.primary)),
                      subtitle: Text('Esta ação apagará permanentemente todos os seus dados.', style: GoogleFonts.inter(fontSize: 11)),
                      onTap: () => _showDeleteConfirmation(context, ref),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),
              Center(
                child: Text(
                  'Leve v1.0.0 — Feito com 💛 no Brasil',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: LeveTheme.textLight,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Tem certeza?',
            style: GoogleFonts.dmSerifDisplay(color: LeveTheme.textPrimary),
          ),
          content: Text(
            'Ao excluir sua conta, todos os seus hábitos, histórico de diário e assinaturas serão apagados permanentemente dos nossos servidores. Esta ação não pode ser desfeita.',
            style: GoogleFonts.inter(fontSize: 13, color: LeveTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancelar', style: GoogleFonts.inter(color: LeveTheme.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: LeveTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Clear all local database settings as well
                ref.read(habitProvider.notifier).clearAllData();
                ref.read(authProvider.notifier).deleteAccount();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sua conta e dados foram apagados.')),
                );
              },
              child: Text('excluir', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showIdentityPicker(BuildContext context, WidgetRef ref, String currentIdentity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LeveTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final identities = [
          {
            'key': 'saúde suave',
            'name': 'Saúde Suave (soft health)',
            'desc': 'Foco em nutrição, hidratação, sono e cuidado gentil com o corpo.',
            'icon': Icons.spa_outlined,
          },
          {
            'key': 'bem-estar silencioso',
            'name': 'Bem-Estar Silencioso (quiet wellness)',
            'desc': 'Foco em meditação, silêncio interno, respiração e paz mental.',
            'icon': Icons.self_improvement_outlined,
          },
          {
            'key': 'protagonista',
            'name': 'Protagonista (main character)',
            'desc': 'Foco em treinos, conquistas diárias, autodesenvolvimento e foco.',
            'icon': Icons.bolt_outlined,
          },
          {
            'key': 'vida desacelerada',
            'name': 'Vida Desacelerada (slow living)',
            'desc': 'Foco em pausas, apreciar detalhes, café sem pressa e ritmo suave.',
            'icon': Icons.hourglass_empty_outlined,
          },
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Escolha sua Identidade',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: LeveTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Isso mudará suas sugestões de hábitos e perguntas do diário.',
                  style: GoogleFonts.inter(fontSize: 12, color: LeveTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...identities.map((id) {
                  final isSelected = currentIdentity.toLowerCase() == id['key'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      tileColor: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      leading: Icon(id['icon'] as IconData, color: LeveTheme.primary),
                      title: Text(
                        id['name'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: LeveTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        id['desc'] as String,
                        style: GoogleFonts.inter(fontSize: 11, color: LeveTheme.textSecondary),
                      ),
                      trailing: isSelected ? Icon(Icons.check_circle, color: LeveTheme.primary) : null,
                      onTap: () {
                        ref.read(identityProvider.notifier).setIdentity(id['key'] as String);
                        Navigator.pop(context);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref, String currentTheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LeveTheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final themes = [
          {'key': 'tropical', 'name': 'Tropical Minimalista', 'icon': Icons.wb_sunny_outlined, 'desc': 'Original (Terracota, Verde, Lavanda)'},
          {'key': 'spring', 'name': 'Primavera', 'icon': Icons.local_florist_outlined, 'desc': 'Tons de Rosa Pastel, Menta e Primrose'},
          {'key': 'summer', 'name': 'Verão', 'icon': Icons.beach_access_outlined, 'desc': 'Tons de Coral Quente, Ocean Blue e Dourado'},
          {'key': 'autumn', 'name': 'Outono', 'icon': Icons.eco_outlined, 'desc': 'Tons de Ferrugem, Sálvia e Maple Amber'},
          {'key': 'winter', 'name': 'Inverno', 'icon': Icons.ac_unit_outlined, 'desc': 'Tons Glaciais, Slate Grey e Dusk Indigo'},
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Escolha o Tema Sazonal',
                  style: GoogleFonts.dmSerifDisplay(fontSize: 20, color: LeveTheme.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Muda instantaneamente todas as cores do aplicativo.',
                  style: GoogleFonts.inter(fontSize: 12, color: LeveTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...themes.map((t) {
                  final isSelected = currentTheme.toLowerCase() == t['key'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      tileColor: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                      leading: Icon(t['icon'] as IconData, color: LeveTheme.primary),
                      title: Text(
                        t['name'] as String,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: LeveTheme.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        t['desc'] as String,
                        style: GoogleFonts.inter(fontSize: 11, color: LeveTheme.textSecondary),
                      ),
                      trailing: isSelected ? Icon(Icons.check_circle, color: LeveTheme.primary) : null,
                      onTap: () {
                        ref.read(seasonalThemeProvider.notifier).setTheme(t['key'] as String);
                        Navigator.pop(context);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
