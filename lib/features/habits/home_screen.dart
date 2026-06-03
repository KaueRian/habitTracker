import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/leve_theme.dart';
import '../premium/paywall_screen.dart';
import '../premium/premium_provider.dart';
import 'add_habit_screen.dart';
import 'elastic_streak.dart';
import 'habit_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'bom dia';
    if (hour < 18) return 'boa tarde';
    return 'boa noite';
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'movimento':
        return Icons.directions_run_outlined;
      case 'mental':
        return Icons.spa_outlined;
      case 'nutrição':
        return Icons.restaurant_outlined;
      case 'hidratação':
        return Icons.water_drop_outlined;
      case 'sono':
        return Icons.bedtime_outlined;
      case 'social':
        return Icons.people_outline;
      case 'financeiro':
        return Icons.monetization_on_outlined;
      case 'espiritual':
        return Icons.self_improvement_outlined;
      default:
        return Icons.star_border;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'movimento':
        return const Color(0xFFE5D4C0);
      case 'mental':
        return LeveTheme.tertiary;
      case 'nutrição':
        return const Color(0xFFF3D2C1);
      case 'hidratação':
        return const Color(0xFFC0D6DF);
      case 'sono':
        return const Color(0xFFD8CCD6);
      case 'social':
        return const Color(0xFFD6E2E2);
      case 'financeiro':
        return const Color(0xFFDFE2CC);
      case 'espiritual':
        return const Color(0xFFEAD8C9);
      default:
        return LeveTheme.background;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final energy = ref.watch(energyProvider);
    final premiumState = ref.watch(premiumProvider);

    final todayStr = DateFormat('d MMMM', 'pt_BR').format(DateTime.now());
    final isLowEnergy = energy == 'Baixa';

    // Energy aware logic: filter to top 3 habits on low-energy days to prevent anxiety.
    final displayedHabits = isLowEnergy ? habits.take(3).toList() : habits;

    return Scaffold(
      backgroundColor: isLowEnergy ? const Color(0xFFF8F3ED) : LeveTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()}.',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        todayStr.toLowerCase(),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: LeveTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!premiumState.isPremium) {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PaywallScreen()),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: premiumState.isPremium ? LeveTheme.primary.withValues(alpha: 0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: premiumState.isPremium ? LeveTheme.primary : const Color(0xFFE5DDD5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: premiumState.isPremium ? LeveTheme.primary : LeveTheme.textLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            premiumState.isPremium ? 'Leve+' : 'Grátis',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: premiumState.isPremium ? LeveTheme.primary : LeveTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Energy Level Selector Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLowEnergy ? LeveTheme.surfaceWarm : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ENERGIA HOJE',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: LeveTheme.textSecondary,
                          ),
                        ),
                        Text(
                          energy.toLowerCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: LeveTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ['Baixa', 'Média', 'Alta'].map((level) {
                        final isSelected = energy == level;
                        Color barColor = const Color(0xFFE5DDD5);
                        if (isSelected) {
                          if (level == 'Baixa') barColor = LeveTheme.accentYellow;
                          if (level == 'Média') barColor = LeveTheme.primary;
                          if (level == 'Alta') barColor = LeveTheme.secondary;
                        }
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => ref.read(energyProvider.notifier).setEnergy(level),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (isLowEnergy) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: LeveTheme.accentYellow.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: LeveTheme.primary, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tudo bem ir devagar hoje 💛 Focando apenas nas 3 prioridades.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: LeveTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HÁBITOS',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: LeveTheme.textSecondary,
                    ),
                  ),
                  if (habits.isNotEmpty)
                    Text(
                      '${habits.length}/4',
                      style: GoogleFonts.inter(fontSize: 12, color: LeveTheme.textSecondary),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (displayedHabits.isEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.spa_outlined, size: 48, color: LeveTheme.textLight),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum hábito cadastrado.',
                        style: GoogleFonts.inter(fontSize: 14, color: LeveTheme.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Comece pequeno e no seu tempo.',
                        style: GoogleFonts.inter(fontSize: 12, color: LeveTheme.textLight),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // ListView of Habits
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayedHabits.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final habit = displayedHabits[index];
                    final todayOnlyStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                    final isDone = habit.completions.contains(todayOnlyStr);
                    final streakCount = ElasticStreak.calculate(habit.completions);

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDone ? LeveTheme.secondary.withValues(alpha: 0.15) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isDone
                            ? Border.all(color: LeveTheme.secondary.withValues(alpha: 0.4), width: 1.5)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              ref.read(habitProvider.notifier).toggleCompletion(habit.id, DateTime.now());
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isDone ? LeveTheme.secondary : const Color(0xFFF2ECE4),
                                shape: BoxShape.circle,
                              ),
                              child: isDone
                                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDone ? LeveTheme.textSecondary : LeveTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(habit.category),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getCategoryIcon(habit.category),
                                            size: 10,
                                            color: LeveTheme.textPrimary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            habit.category,
                                            style: GoogleFonts.inter(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                              color: LeveTheme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (streakCount > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '🔥 $streakCount dias',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: LeveTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz, color: LeveTheme.textLight),
                            onPressed: () {
                              _showHabitOptions(context, ref, habit);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Button to Add Habit
              ElevatedButton(
                onPressed: () {
                  if (!premiumState.isPremium && habits.length >= 4) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const PaywallScreen()),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
                    );
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'adicionar hábito',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
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

  void _showHabitOptions(BuildContext context, WidgetRef ref, Habit habit) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  habit.name,
                  style: GoogleFonts.dmSerifDisplay(fontSize: 20),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: LeveTheme.textPrimary),
                  title: Text('Editar Hábito', style: GoogleFonts.inter()),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddHabitScreen(habit: habit),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_outline, color: LeveTheme.primary),
                  title: Text('Excluir Hábito', style: GoogleFonts.inter(color: LeveTheme.primary)),
                  onTap: () {
                    ref.read(habitProvider.notifier).deleteHabit(habit.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hábito excluído.')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
