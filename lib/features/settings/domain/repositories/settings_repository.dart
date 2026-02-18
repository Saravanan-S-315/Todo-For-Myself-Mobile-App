abstract interface class SettingsRepository {
  Future<bool> loadDarkModeEnabled();
  Future<void> setDarkModeEnabled(bool enabled);
}
