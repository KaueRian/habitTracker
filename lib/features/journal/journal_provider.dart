import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/storage_service.dart';

class JournalEntry {
  final String dateStr;
  final String intention;
  final String reflection1;
  final String reflection2;
  final String reflection3;

  JournalEntry({
    required this.dateStr,
    this.intention = '',
    this.reflection1 = '',
    this.reflection2 = '',
    this.reflection3 = '',
  });

  factory JournalEntry.fromMap(String dateStr, Map<String, dynamic> map) {
    return JournalEntry(
      dateStr: dateStr,
      intention: map['intention'] as String? ?? '',
      reflection1: map['reflection1'] as String? ?? '',
      reflection2: map['reflection2'] as String? ?? '',
      reflection3: map['reflection3'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'intention': intention,
      'reflection1': reflection1,
      'reflection2': reflection2,
      'reflection3': reflection3,
    };
  }

  JournalEntry copyWith({
    String? intention,
    String? reflection1,
    String? reflection2,
    String? reflection3,
  }) {
    return JournalEntry(
      dateStr: dateStr,
      intention: intention ?? this.intention,
      reflection1: reflection1 ?? this.reflection1,
      reflection2: reflection2 ?? this.reflection2,
      reflection3: reflection3 ?? this.reflection3,
    );
  }
}

class JournalNotifier extends StateNotifier<Map<String, JournalEntry>> {
  JournalNotifier() : super({});

  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  JournalEntry getTodayEntry() {
    return getEntryForDate(_todayStr);
  }

  JournalEntry getEntryForDate(String dateStr) {
    if (state.containsKey(dateStr)) {
      return state[dateStr]!;
    }
    
    final map = StorageService.getJournalEntry(dateStr);
    return map != null ? JournalEntry.fromMap(dateStr, map) : JournalEntry(dateStr: dateStr);
  }

  void updateIntention(String dateStr, String intention) {
    final entry = getEntryForDate(dateStr).copyWith(intention: intention);
    state = {...state, dateStr: entry};
    StorageService.saveJournalEntry(dateStr, entry.toMap());
  }

  void updateReflections(String dateStr, String ref1, String ref2, String ref3) {
    final entry = getEntryForDate(dateStr).copyWith(
      reflection1: ref1,
      reflection2: ref2,
      reflection3: ref3,
    );
    state = {...state, dateStr: entry};
    StorageService.saveJournalEntry(dateStr, entry.toMap());
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, Map<String, JournalEntry>>((ref) {
  return JournalNotifier();
});
