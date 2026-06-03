import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusTimerState {
  final int totalSeconds;
  final int secondsRemaining;
  final bool isRunning;
  final int selectedMinutes;

  FocusTimerState({
    required this.totalSeconds,
    required this.secondsRemaining,
    required this.isRunning,
    required this.selectedMinutes,
  });

  FocusTimerState copyWith({
    int? totalSeconds,
    int? secondsRemaining,
    bool? isRunning,
    int? selectedMinutes,
  }) {
    return FocusTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      isRunning: isRunning ?? this.isRunning,
      selectedMinutes: selectedMinutes ?? this.selectedMinutes,
    );
  }
}

class FocusTimerNotifier extends StateNotifier<FocusTimerState> {
  Timer? _timer;

  FocusTimerNotifier()
      : super(FocusTimerState(
          totalSeconds: 600,
          secondsRemaining: 600,
          isRunning: false,
          selectedMinutes: 10,
        ));

  void selectDuration(int minutes) {
    if (state.isRunning) return;
    state = FocusTimerState(
      totalSeconds: minutes * 60,
      secondsRemaining: minutes * 60,
      isRunning: false,
      selectedMinutes: minutes,
    );
  }

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.secondsRemaining <= 1) {
        stop();
      } else {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void stop() {
    _timer?.cancel();
    state = FocusTimerState(
      totalSeconds: state.selectedMinutes * 60,
      secondsRemaining: state.selectedMinutes * 60,
      isRunning: false,
      selectedMinutes: state.selectedMinutes,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider = StateNotifierProvider<FocusTimerNotifier, FocusTimerState>((ref) {
  return FocusTimerNotifier();
});
