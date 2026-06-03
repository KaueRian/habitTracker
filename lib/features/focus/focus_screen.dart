import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/leve_theme.dart';
import '../premium/paywall_screen.dart';
import '../premium/premium_provider.dart';
import 'focus_provider.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(focusTimerProvider);
    final premiumState = ref.watch(premiumProvider);
    final notifier = ref.read(focusTimerProvider.notifier);

    final progress = timerState.totalSeconds > 0
        ? timerState.secondsRemaining / timerState.totalSeconds
        : 0.0;

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
                    'foco.',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'espaço compartilhado de concentração',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: LeveTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Simulated "Body Doubling" companion widget
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: LeveTheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_outline, color: LeveTheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SESSÃO ATIVA',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                              color: LeveTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Trabalhando junto com 3 outras pessoas agora.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: LeveTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Avatars list
                    SizedBox(
                      width: 50,
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: LeveTheme.primary.withValues(alpha: 0.4),
                              child: Text('A', style: GoogleFonts.inter(fontSize: 8, color: Colors.white)),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: LeveTheme.tertiary,
                              child: Text('M', style: GoogleFonts.inter(fontSize: 8, color: Colors.white)),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: LeveTheme.secondary,
                              child: Text('F', style: GoogleFonts.inter(fontSize: 8, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Circular Timer Display
              Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(LeveTheme.primary),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatTime(timerState.secondsRemaining),
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 48,
                              color: LeveTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            timerState.isRunning ? 'FOCANDO' : 'PRONTO',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: LeveTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Duration selector chips
              Text(
                'DURAÇÃO DA SESSÃO',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LeveTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [10, 15, 25, 45].map((mins) {
                  final isSelected = timerState.selectedMinutes == mins;
                  final isPremiumGated = mins > 10;

                  return GestureDetector(
                    onTap: () {
                      if (isPremiumGated && !premiumState.isPremium) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PaywallScreen()),
                        );
                      } else {
                        notifier.selectDuration(mins);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? LeveTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '$mins min',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : LeveTheme.textPrimary,
                            ),
                          ),
                          if (isPremiumGated && !premiumState.isPremium) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.lock_outline, size: 12, color: LeveTheme.textSecondary),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),

              // Action Control Button
              ElevatedButton(
                onPressed: () {
                  if (timerState.isRunning) {
                    notifier.pause();
                  } else {
                    notifier.start();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LeveTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  timerState.isRunning ? 'pausar foco' : 'iniciar foco',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              if (timerState.isRunning || timerState.secondsRemaining < timerState.totalSeconds) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => notifier.stop(),
                  child: Text(
                    'abandonar sessão',
                    style: GoogleFonts.inter(color: LeveTheme.primary, fontSize: 14),
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Explain Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'O QUE É BODY DOUBLING?',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: LeveTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trabalhar ou estudar ao lado de outras pessoas (mesmo que virtualmente) ajuda a manter o foco, reduz a procrastinação e traz um sentimento de leveza na execução.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: LeveTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
