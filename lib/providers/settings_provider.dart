import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/phrase.dart';

class SettingsProvider extends ChangeNotifier {
  Difficulty _level = Difficulty.beginner;
  int _dailyGoal = 10;
  double _speechRate = 0.5;
  int _ttsSpeakerId = 109;
  bool _isNotificationEnabled = false;
  String _notificationTime = '09:00';
  ThemeMode _themeMode = ThemeMode.system;

  Difficulty get level => _level;
  int get dailyGoal => _dailyGoal;
  double get speechRate => _speechRate;
  int get ttsSpeakerId => _ttsSpeakerId;
  bool get isNotificationEnabled => _isNotificationEnabled;
  String get notificationTime => _notificationTime;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final levelStr = prefs.getString('level') ?? 'beginner';
    _level = Difficulty.values.firstWhere(
      (d) => d.name == levelStr,
      orElse: () => Difficulty.beginner,
    );
    _dailyGoal = prefs.getInt('dailyGoal') ?? 10;
    _speechRate = prefs.getDouble('speechRate') ?? 0.5;
    _ttsSpeakerId = prefs.getInt('ttsSpeakerId') ?? 109;
    _isNotificationEnabled = prefs.getBool('isNotificationEnabled') ?? false;
    _notificationTime = prefs.getString('notificationTime') ?? '09:00';
    final themeModeStr = prefs.getString('themeMode') ?? 'system';
    _themeMode = _themeModeFromString(themeModeStr);
    notifyListeners();
  }

  static ThemeMode _themeModeFromString(String value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _themeModeToString(ThemeMode mode) => switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };

  Future<void> setLevel(Difficulty level) async {
    _level = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('level', level.name);
    notifyListeners();
  }

  Future<void> setDailyGoal(int goal) async {
    _dailyGoal = goal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', goal);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speechRate', rate);
    notifyListeners();
  }

  Future<void> setTtsSpeakerId(int id) async {
    _ttsSpeakerId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ttsSpeakerId', id);
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    _isNotificationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isNotificationEnabled', enabled);
    notifyListeners();
  }

  Future<void> setNotificationTime(String time) async {
    _notificationTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationTime', time);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeModeToString(mode));
    notifyListeners();
  }
}
