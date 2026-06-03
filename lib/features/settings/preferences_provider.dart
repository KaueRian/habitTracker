import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/storage_service.dart';

// Identity: 'saúde suave' (soft health), 'bem-estar silencioso' (quiet wellness), 'protagonista' (main character), 'vida desacelerada' (slow living)
class IdentityNotifier extends StateNotifier<String> {
  IdentityNotifier() : super(StorageService.getIdentity());

  void setIdentity(String identity) {
    state = identity;
    StorageService.saveIdentity(identity);
  }
}

final identityProvider = StateNotifierProvider<IdentityNotifier, String>((ref) {
  return IdentityNotifier();
});

// Seasonal Theme: 'tropical', 'spring', 'summer', 'autumn', 'winter'
class SeasonalThemeNotifier extends StateNotifier<String> {
  SeasonalThemeNotifier() : super(StorageService.getSeasonalTheme());

  void setTheme(String theme) {
    state = theme;
    StorageService.saveSeasonalTheme(theme);
  }
}

final seasonalThemeProvider = StateNotifierProvider<SeasonalThemeNotifier, String>((ref) {
  return SeasonalThemeNotifier();
});
