import 'package:intl/intl.dart';

class ElasticStreak {
  /// Calculates the current streak of a habit given its completion dates.
  /// Format of dates: 'YYYY-MM-DD'
  /// Allows at most 1 missed day ("gap day") in any rolling 7-day window.
  static int calculate(List<String> completionDates) {
    if (completionDates.isEmpty) return 0;

    // Convert to Set for O(1) lookups
    final Set<String> completedSet = Set.from(completionDates);

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    // Let's find when our streak starts checking.
    // If the habit was not done today AND not done yesterday, the streak is broken (0),
    // unless today is a gap day but yesterday was done.
    final String todayStr = formatter.format(todayDateOnly);
    final String yesterdayStr = formatter.format(todayDateOnly.subtract(const Duration(days: 1)));

    final bool doneToday = completedSet.contains(todayStr);
    final bool doneYesterday = completedSet.contains(yesterdayStr);

    if (!doneToday && !doneYesterday) {
      // Check if we can forgive today as a gap day.
      // That means we completed yesterday. If we completed yesterday, then we are in a 1-day gap (today).
      // We can continue checking.
      // But if yesterday was also missed, it's definitely broken.
      final String dayBeforeYesterdayStr = formatter.format(todayDateOnly.subtract(const Duration(days: 2)));
      final bool doneDayBefore = completedSet.contains(dayBeforeYesterdayStr);
      if (!doneDayBefore) {
        return 0; // Missed 2 consecutive days, streak is 0
      }
    }

    int streak = 0;
    DateTime checkDate = doneToday
        ? todayDateOnly
        : (doneYesterday ? todayDateOnly.subtract(const Duration(days: 1)) : todayDateOnly.subtract(const Duration(days: 2)));

    // Track missed days in rolling windows.
    // We will traverse backwards day-by-day.
    // At each day, we maintain the counts of misses in the 7 days ahead of it.
    final List<DateTime> traversedDates = [];
    int consecutiveMisses = 0;

    while (true) {
      final String checkStr = formatter.format(checkDate);
      final bool isCompleted = completedSet.contains(checkStr);

      if (isCompleted) {
        streak++;
        consecutiveMisses = 0;
        traversedDates.add(checkDate);
      } else {
        consecutiveMisses++;
        if (consecutiveMisses >= 2) {
          // 2 consecutive misses always breaks a streak
          break;
        }

        // Check if we can afford a gap day.
        // Look at the rolling 7-day window forward from this checkDate.
        // That means we count how many misses are in the range [checkDate, checkDate + 6 days].
        int missesInWindow = 1; // including today
        for (int i = 1; i < 7; i++) {
          final DateTime futureDate = checkDate.add(Duration(days: i));
          if (futureDate.isAfter(todayDateOnly)) continue;
          
          final String futureStr = formatter.format(futureDate);
          if (!completedSet.contains(futureStr)) {
            missesInWindow++;
          }
        }

        if (missesInWindow > 1) {
          // Already have another miss in this 7-day window. Cannot forgive this gap day.
          break;
        }
        
        // Forgiven as gap day, streak does not reset, but doesn't increment.
        traversedDates.add(checkDate);
      }

      // Go back 1 day
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Returns true if a gap day has been used in the last 7 days.
  static bool isGapDayUsedInLast7Days(List<String> completionDates) {
    if (completionDates.isEmpty) return false;
    final Set<String> completedSet = Set.from(completionDates);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    int misses = 0;
    for (int i = 0; i < 7; i++) {
      final DateTime date = todayDateOnly.subtract(Duration(days: i));
      final String dateStr = formatter.format(date);
      if (!completedSet.contains(dateStr)) {
        // If today is missed, it's a potential gap day.
        // We only count it as a gap day if the user actually completed yesterday.
        if (i == 0) {
          final String yesterdayStr = formatter.format(todayDateOnly.subtract(const Duration(days: 1)));
          if (completedSet.contains(yesterdayStr)) {
            misses++;
          }
        } else {
          misses++;
        }
      }
    }
    return misses > 0;
  }
}
