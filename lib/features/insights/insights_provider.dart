import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../habits/habit_provider.dart';

class InsightStats {
  final double weeklyCompletionRate; // e.g. 0.75 (75%)
  final int activeDaysCount;        // active days this week (out of 7)
  final String bestDay;             // e.g. 'Quarta-feira'
  final int bestStreak;             // maximum streak among all habits
  final List<double> dailyCompletionRates; // completion rate for each of the last 7 days

  InsightStats({
    required this.weeklyCompletionRate,
    required this.activeDaysCount,
    required this.bestDay,
    required this.bestStreak,
    required this.dailyCompletionRates,
  });
}

final insightsProvider = Provider<InsightStats>((ref) {
  final habits = ref.watch(habitProvider);
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  final DateFormat dayOfWeekFormatter = DateFormat('EEEE', 'pt_BR');

  if (habits.isEmpty) {
    return InsightStats(
      weeklyCompletionRate: 0.0,
      activeDaysCount: 0,
      bestDay: 'Nenhum dia ainda',
      bestStreak: 0,
      dailyCompletionRates: List.filled(7, 0.0),
    );
  }

  final DateTime today = DateTime.now();
  final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

  // Analyze the last 7 days (including today)
  final List<DateTime> last7Days = List.generate(7, (i) => todayDateOnly.subtract(Duration(days: 6 - i)));

  // Calculate completions per day
  final Map<DateTime, int> completionsPerDay = {};
  for (var date in last7Days) {
    completionsPerDay[date] = 0;
  }

  int totalPossibleCompletions = habits.length * 7;
  int totalActualCompletions = 0;

  for (final habit in habits) {
    for (final completionStr in habit.completions) {
      try {
        final date = DateTime.parse(completionStr);
        final dateMidnight = DateTime(date.year, date.month, date.day);
        if (completionsPerDay.containsKey(dateMidnight)) {
          completionsPerDay[dateMidnight] = completionsPerDay[dateMidnight]! + 1;
          totalActualCompletions++;
        }
      } catch (_) {}
    }
  }

  // Active days this week: days with at least 1 habit completed
  int activeDays = 0;
  completionsPerDay.forEach((date, count) {
    if (count > 0) activeDays++;
  });

  // Calculate daily completion rates
  final List<double> dailyRates = last7Days.map((date) {
    final count = completionsPerDay[date] ?? 0;
    return habits.isNotEmpty ? count / habits.length : 0.0;
  }).toList();

  // Find best day of the week
  DateTime? bestDateTime;
  int maxCompletions = -1;
  completionsPerDay.forEach((date, count) {
    if (count > maxCompletions) {
      maxCompletions = count;
      bestDateTime = date;
    }
  });

  String bestDayStr = 'Nenhum';
  if (bestDateTime != null && maxCompletions > 0) {
    bestDayStr = dayOfWeekFormatter.format(bestDateTime!);
    // Capitalize first letter
    bestDayStr = bestDayStr[0].toUpperCase() + bestDayStr.substring(1);
  } else {
    bestDayStr = 'Segunda-feira'; // Fallback display
  }

  // Max streak among all habits
  int maxStreak = 0;
  // Standard simple calculation to show in statistics
  for (final habit in habits) {
    int streak = 0;
    // Simple verification
    final Set<String> datesSet = Set.from(habit.completions);
    DateTime d = todayDateOnly;
    while (datesSet.contains(formatter.format(d))) {
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    if (streak > maxStreak) maxStreak = streak;
  }

  final double weeklyRate = totalPossibleCompletions > 0
      ? totalActualCompletions / totalPossibleCompletions
      : 0.0;

  return InsightStats(
    weeklyCompletionRate: weeklyRate,
    activeDaysCount: activeDays,
    bestDay: bestDayStr,
    bestStreak: maxStreak,
    dailyCompletionRates: dailyRates,
  );
});
