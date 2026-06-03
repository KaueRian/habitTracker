import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/leve_theme.dart';
import '../settings/preferences_provider.dart';
import 'journal_provider.dart';

class IdentityPrompts {
  final String morningTitle;
  final String morningSubtitle;
  final String morningHint;
  final String eveningTitle;
  final String eveningSubtitle;
  final List<String> reflectionLabels;

  const IdentityPrompts({
    required this.morningTitle,
    required this.morningSubtitle,
    required this.morningHint,
    required this.eveningTitle,
    required this.eveningSubtitle,
    required this.reflectionLabels,
  });

  static IdentityPrompts getPrompts(String identity) {
    switch (identity.toLowerCase()) {
      case 'bem-estar silencioso':
        return const IdentityPrompts(
          morningTitle: 'INTENÇÃO DE PAZ',
          morningSubtitle: 'Escolha uma palavra para guiar sua serenidade hoje.',
          morningHint: 'ex: calma, silêncio, paz',
          eveningTitle: 'REFLEXÃO SILENCIOSA',
          eveningSubtitle: 'Escreva 3 coisas que trouxeram calma ao seu dia.',
          reflectionLabels: ['1. Momento de silêncio', '2. O que me trouxe paz', '3. Sou grato(a) por...'],
        );
      case 'protagonista':
        return const IdentityPrompts(
          morningTitle: 'FOCO DE PODER',
          morningSubtitle: 'Qual será a sua intenção de vitória para hoje?',
          morningHint: 'ex: foco, força, conquista',
          eveningTitle: 'DIÁRIO DE CONQUISTAS',
          eveningSubtitle: 'Escreva 3 vitórias ou conquistas de hoje.',
          reflectionLabels: ['1. Maior vitória', '2. Como me orgulhei', '3. O que conquistei'],
        );
      case 'vida desacelerada':
        return const IdentityPrompts(
          morningTitle: 'RITMO DO DIA',
          morningSubtitle: 'Qual ritmo você escolhe para vivenciar hoje?',
          morningHint: 'ex: devagar, presença, leve',
          eveningTitle: 'MOMENTOS PRESENTES',
          eveningSubtitle: 'Escreva 3 pequenos detalhes bonitos do seu dia.',
          reflectionLabels: ['1. Detalhe bonito que notei', '2. Momento sem pressa', '3. Do que desfrutei'],
        );
      case 'saúde suave':
      default:
        return const IdentityPrompts(
          morningTitle: 'INTENÇÃO DA MANHÃ',
          morningSubtitle: 'Escolha uma palavra de cuidado para o seu dia.',
          morningHint: 'ex: cuidado, energia, fluir',
          eveningTitle: 'REFLEXÃO DA NOITE',
          eveningSubtitle: 'Escreva 3 pequenas coisas boas que aconteceram hoje.',
          reflectionLabels: ['1. Como me cuidei hoje', '2. O que meu corpo agradece', '3. Momento de descanso'],
        );
    }
  }
}

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(journalProvider); // watch changes
    final notifier = ref.read(journalProvider.notifier);
    final identity = ref.watch(identityProvider);
    final prompts = IdentityPrompts.getPrompts(identity);
    
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final entry = notifier.getEntryForDate(todayStr);
    
    final formattedDate = DateFormat('d MMMM', 'pt_BR').format(DateTime.now());

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
                    'diário.',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate.toLowerCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: LeveTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
              
              Text(
                'HOJE',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LeveTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Morning Intention Card
              _buildIntentionCard(context, ref, entry, prompts),

              const SizedBox(height: 16),

              // Evening Reflection Card
              _buildReflectionCard(context, ref, entry, prompts),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntentionCard(BuildContext context, WidgetRef ref, JournalEntry entry, IdentityPrompts prompts) {
    final hasIntention = entry.intention.isNotEmpty;

    return InkWell(
      onTap: () => _showIntentionDialog(context, ref, entry, prompts),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFBF4EF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wb_sunny_outlined, color: LeveTheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prompts.morningTitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: LeveTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hasIntention ? entry.intention : 'uma palavra para o dia →',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: hasIntention ? FontWeight.w600 : FontWeight.w400,
                      color: hasIntention ? LeveTheme.textPrimary : LeveTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, WidgetRef ref, JournalEntry entry, IdentityPrompts prompts) {
    final hasReflections = entry.reflection1.isNotEmpty ||
        entry.reflection2.isNotEmpty ||
        entry.reflection3.isNotEmpty;

    return InkWell(
      onTap: () => _showReflectionDialog(context, ref, entry, prompts),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF4EFFB),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.mode_night_outlined, color: LeveTheme.tertiary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prompts.eveningTitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: LeveTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (hasReflections) ...[
                    if (entry.reflection1.isNotEmpty)
                      _buildBulletItem(entry.reflection1),
                    if (entry.reflection2.isNotEmpty)
                      _buildBulletItem(entry.reflection2),
                    if (entry.reflection3.isNotEmpty)
                      _buildBulletItem(entry.reflection3),
                  ] else ...[
                    Text(
                      'refletir sobre o dia →',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: LeveTheme.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.inter(color: LeveTheme.textPrimary, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: LeveTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIntentionDialog(BuildContext context, WidgetRef ref, JournalEntry entry, IdentityPrompts prompts) {
    final controller = TextEditingController(text: entry.intention);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            prompts.morningTitle.toLowerCase(),
            style: GoogleFonts.dmSerifDisplay(color: LeveTheme.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prompts.morningSubtitle,
                style: GoogleFonts.inter(fontSize: 13, color: LeveTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 24,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: LeveTheme.primary),
                decoration: InputDecoration(
                  hintText: prompts.morningHint,
                  hintStyle: GoogleFonts.inter(fontSize: 16, color: LeveTheme.textLight),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE5DDD5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: LeveTheme.primary, width: 1.5),
                  ),
                ),
              ),
            ],
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
                ref.read(journalProvider.notifier).updateIntention(entry.dateStr, controller.text.trim());
                Navigator.pop(context);
              },
              child: Text('definir', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showReflectionDialog(BuildContext context, WidgetRef ref, JournalEntry entry, IdentityPrompts prompts) {
    final c1 = TextEditingController(text: entry.reflection1);
    final c2 = TextEditingController(text: entry.reflection2);
    final c3 = TextEditingController(text: entry.reflection3);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            prompts.eveningTitle.toLowerCase(),
            style: GoogleFonts.dmSerifDisplay(color: LeveTheme.textPrimary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  prompts.eveningSubtitle,
                  style: GoogleFonts.inter(fontSize: 13, color: LeveTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                _buildReflectionField(c1, prompts.reflectionLabels[0]),
                const SizedBox(height: 12),
                _buildReflectionField(c2, prompts.reflectionLabels[1]),
                const SizedBox(height: 12),
                _buildReflectionField(c3, prompts.reflectionLabels[2]),
              ],
            ),
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
                ref.read(journalProvider.notifier).updateReflections(
                      entry.dateStr,
                      c1.text.trim(),
                      c2.text.trim(),
                      c3.text.trim(),
                    );
                Navigator.pop(context);
              },
              child: Text('salvar', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReflectionField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      style: GoogleFonts.inter(fontSize: 14, color: LeveTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(fontSize: 12, color: LeveTheme.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5DDD5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: LeveTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
