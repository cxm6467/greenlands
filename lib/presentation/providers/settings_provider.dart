import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../core/services/settings_storage_service.dart';

/// Provider for settings storage service
final settingsStorageProvider = Provider<SettingsStorageService>((ref) {
  return getIt<SettingsStorageService>();
});

/// Provider for authentication state
final settingsAuthProvider = StateNotifierProvider<SettingsAuthNotifier, bool>(
  (ref) => SettingsAuthNotifier(ref.read(settingsStorageProvider)),
);

class SettingsAuthNotifier extends StateNotifier<bool> {
  final SettingsStorageService _storage;

  SettingsAuthNotifier(this._storage) : super(false);

  Future<bool> checkPassword(String password) async {
    final isValid = await _storage.verifyAdminPassword(password);
    state = isValid;
    return isValid;
  }

  Future<void> setPassword(String password) async {
    await _storage.setAdminPassword(password);
    state = true;
  }

  Future<bool> hasPassword() async {
    return await _storage.hasAdminPassword();
  }

  void logout() {
    state = false;
  }
}
