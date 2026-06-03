import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  static const String habitsBoxName = 'habits';
  static const String journalBoxName = 'journal';
  static const String dailyBoxName = 'daily'; // Stores energy level, settings, etc.

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(habitsBoxName);
    await Hive.openBox(journalBoxName);
    await Hive.openBox(dailyBoxName);
  }

  // --- Habits Operations ---
  static List<Map<String, dynamic>> getHabits() {
    final box = Hive.box(habitsBoxName);
    final List<Map<String, dynamic>> list = [];
    for (var key in box.keys) {
      final val = box.get(key);
      if (val is Map) {
        // Safe conversion of Map<dynamic, dynamic> to Map<String, dynamic>
        list.add(Map<String, dynamic>.from(val));
      }
    }
    return list;
  }

  static Future<void> saveHabit(Map<String, dynamic> habit) async {
    final box = Hive.box(habitsBoxName);
    await box.put(habit['id'], habit);
  }

  static Future<void> deleteHabit(String id) async {
    final box = Hive.box(habitsBoxName);
    await box.delete(id);
  }

  static Future<void> clearAll() async {
    await Hive.box(habitsBoxName).clear();
    await Hive.box(journalBoxName).clear();
    await Hive.box(dailyBoxName).clear();
  }

  // --- Journal Operations ---
  static Map<String, dynamic>? getJournalEntry(String dateStr) {
    final box = Hive.box(journalBoxName);
    final data = box.get(dateStr);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> saveJournalEntry(String dateStr, Map<String, dynamic> entry) async {
    final box = Hive.box(journalBoxName);
    await box.put(dateStr, entry);
  }

  // --- Daily Config (Energy level, etc.) ---
  static String getEnergyLevel(String dateStr) {
    final box = Hive.box(dailyBoxName);
    return box.get('energy_$dateStr', defaultValue: 'Média');
  }

  static Future<void> saveEnergyLevel(String dateStr, String level) async {
    final box = Hive.box(dailyBoxName);
    await box.put('energy_$dateStr', level);
  }

  // --- Personalization Preferences ---
  static String getIdentity() {
    final box = Hive.box(dailyBoxName);
    return box.get('user_identity', defaultValue: 'saúde suave');
  }

  static Future<void> saveIdentity(String identity) async {
    final box = Hive.box(dailyBoxName);
    await box.put('user_identity', identity);
  }

  static String getSeasonalTheme() {
    final box = Hive.box(dailyBoxName);
    return box.get('seasonal_theme', defaultValue: 'tropical');
  }

  static Future<void> saveSeasonalTheme(String theme) async {
    final box = Hive.box(dailyBoxName);
    await box.put('seasonal_theme', theme);
  }
}
