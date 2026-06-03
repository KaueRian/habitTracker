import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../shared/storage_service.dart';
import '../premium/premium_provider.dart';

class Habit {
  final String id;
  final String name;
  final String category; // movement, mental, nutrition, hydration, sleep, social, financial, spiritual
  final DateTime createdAt;
  final List<String> completions; // List of 'YYYY-MM-DD' strings

  Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.createdAt,
    required this.completions,
  });

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      completions: List<String>.from(map['completions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'completions': completions,
    };
  }

  Habit copyWith({
    String? name,
    String? category,
    List<String>? completions,
  }) {
    return Habit(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      createdAt: createdAt,
      completions: completions ?? this.completions,
    );
  }
}

class HabitNotifier extends StateNotifier<List<Habit>> {
  final Ref _ref;
  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  HabitNotifier(this._ref) : super([]) {
    _loadHabits();
  }

  void _loadHabits() {
    final list = StorageService.getHabits();
    state = list.map((m) => Habit.fromMap(m)).toList();
  }

  bool addHabit(String name, String category) {
    final isPremium = _ref.read(premiumProvider).isPremium;
    if (!isPremium && state.length >= 4) {
      // Free users can track up to 4 habits
      return false;
    }

    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      category: category,
      createdAt: DateTime.now(),
      completions: [],
    );

    state = [...state, habit];
    StorageService.saveHabit(habit.toMap());
    return true;
  }

  void toggleCompletion(String id, DateTime date) {
    final dateStr = _formatter.format(date);
    state = [
      for (final h in state)
        if (h.id == id)
          _toggleHabitCompletion(h, dateStr)
        else
          h
    ];
  }

  Habit _toggleHabitCompletion(Habit habit, String dateStr) {
    final list = List<String>.from(habit.completions);
    if (list.contains(dateStr)) {
      list.remove(dateStr);
    } else {
      list.add(dateStr);
    }
    final updated = habit.copyWith(completions: list);
    StorageService.saveHabit(updated.toMap());
    return updated;
  }

  void editHabit(String id, String name, String category) {
    state = [
      for (final h in state)
        if (h.id == id)
          _updateHabit(h, name, category)
        else
          h
    ];
  }

  Habit _updateHabit(Habit habit, String name, String category) {
    final updated = habit.copyWith(name: name, category: category);
    StorageService.saveHabit(updated.toMap());
    return updated;
  }

  void deleteHabit(String id) {
    state = state.where((h) => h.id != id).toList();
    StorageService.deleteHabit(id);
  }

  void clearAllData() {
    state = [];
    StorageService.clearAll();
  }
}

final habitProvider = StateNotifierProvider<HabitNotifier, List<Habit>>((ref) {
  return HabitNotifier(ref);
});

// Selector for daily energy levels
class EnergyNotifier extends StateNotifier<String> {
  EnergyNotifier() : super('Média') {
    _loadEnergy();
  }

  String get _dateStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _loadEnergy() {
    state = StorageService.getEnergyLevel(_dateStr);
  }

  void setEnergy(String level) {
    state = level;
    StorageService.saveEnergyLevel(_dateStr, level);
  }
}

final energyProvider = StateNotifierProvider<EnergyNotifier, String>((ref) {
  return EnergyNotifier();
});
