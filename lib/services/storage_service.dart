import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // ─── Keys ───────────────────────────────────────────────────────────────────
  static const String _keyToken = 'auth_token';
  static const String _keyIsGuest = 'is_guest';
  static const String _keyDarkMode = 'is_dark_mode';

  // ─── Token ──────────────────────────────────────────────────────────────────
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  // ─── Guest Status ───────────────────────────────────────────────────────────
  Future<void> setGuestStatus(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsGuest, isGuest);
  }

  Future<bool> getGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsGuest) ?? false;
  }

  // ─── Dark Mode ──────────────────────────────────────────────────────────────
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  // ─── Clear Session ──────────────────────────────────────────────────────────
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyIsGuest);
  }
}