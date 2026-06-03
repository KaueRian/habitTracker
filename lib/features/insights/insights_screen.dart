import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/leve_theme.dart';
import '../premium/paywall_screen.dart';
import '../premium/premium_provider.dart';
import 'insights_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(insightsProvider);
    final premiumState = ref.watch(premiumProvider);

    final List<String> weekDays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

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
                    'revisão.',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'sua jornada e padrões de bem-estar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: LeveTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Weekly Insight Card (Calm inspiration)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: LeveTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_twilight, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'INSIGHT SEMANAL',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '«Diminuir o ritmo em dias de baixa energia não é falhar. É escolher durar mais.»',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 18,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Statistics Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '${stats.activeDaysCount}/7',
                      'Dias Ativos',
                      Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      '${(stats.weeklyCompletionRate * 100).toInt()}%',
                      'Taxa de Sucesso',
                      Icons.analytics_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLargeStatCard(
                context,
                title: stats.bestDay,
                subtitle: 'Seu melhor dia de hábitos esta semana',
                icon: Icons.star_outline,
              ),

              const SizedBox(height: 28),

              // Completion Rate Chart Title
              Text(
                'COMPLEMENTO DIÁRIO',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LeveTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),

              // Minimalist Bar Chart
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        final rate = stats.dailyCompletionRates[index];
                        final height = 100 * rate; // Max 100 logical pixels

                        return Column(
                          children: [
                            Container(
                              width: 16,
                              height: 100,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2ECE4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 16,
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: rate > 0.7 ? LeveTheme.secondary : LeveTheme.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              weekDays[index],
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: LeveTheme.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Premium Section (Health Radar)
              Text(
                'RADAR DE SAÚDE LEVE+',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: LeveTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              _buildHealthRadar(context, premiumState.isPremium),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: LeveTheme.primary, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              color: LeveTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: LeveTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeStatCard(BuildContext context, {required String title, required String subtitle, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8F0),
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
                    fontWeight: FontWeight.w700,
                    color: LeveTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
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
        ],
      ),
    );
  }

  Widget _buildHealthRadar(BuildContext context, bool isPremium) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          // Simulated Radar Graphic using lines and rings
          Center(
            child: Opacity(
              opacity: isPremium ? 0.8 : 0.25,
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF2ECE4), width: 1.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF2ECE4), width: 1.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF2ECE4), width: 1.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Hexagonal custom simulation
                    Transform.rotate(
                      angle: 0.5,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: LeveTheme.primary.withValues(alpha: 0.15),
                          border: Border.all(color: LeveTheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (!isPremium)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 28, color: LeveTheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Radar de Saúde Bloqueado',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: LeveTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assine o Leve+ para liberar o gráfico de bem-estar',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: LeveTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PaywallScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LeveTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Desbloquear Leve+',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
