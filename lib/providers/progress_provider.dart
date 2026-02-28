import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_progress.dart';
import '../models/phrase.dart';

class ProgressProvider extends ChangeNotifier {
  UserProgress _progress = UserProgress.initial();
  List<DailyRecord> _dailyRecords = [];

  UserProgress get progress => _progress;
  List<DailyRecord> get dailyRecords => _dailyRecords;

  int get todayLearned {
    final today = _todayString();
    final record = _dailyRecords.where((r) => r.date == today).firstOrNull;
    return record?.phrasesLearned ?? 0;
  }

  bool get isGoalCompleted => todayLearned >= _progress.dailyGoal;

  double get todayProgress =>
      _progress.dailyGoal > 0 ? todayLearned / _progress.dailyGoal : 0.0;

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('user_progress');
    final recordsJson = prefs.getString('daily_records');

    if (progressJson != null) {
      final map = json.decode(progressJson);
      _progress = UserProgress(
        userId: map['userId'],
        level: Difficulty.values.firstWhere(
          (d) => d.name == map['level'],
          orElse: () => Difficulty.beginner,
        ),
        learnedPhraseIds: List<String>.from(map['learnedPhraseIds']),
        favoritePhraseIds: List<String>.from(map['favoritePhraseIds']),
        streakDays: map['streakDays'],
        lastStudyDate: map['lastStudyDate'],
        dailyGoal: map['dailyGoal'],
        totalStudyMinutes: map['totalStudyMinutes'],
      );
    }

    if (recordsJson != null) {
      final list = json.decode(recordsJson) as List;
      _dailyRecords = list.map((e) => DailyRecord.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_progress', json.encode({
      'userId': _progress.userId,
      'level': _progress.level.name,
      'learnedPhraseIds': _progress.learnedPhraseIds,
      'favoritePhraseIds': _progress.favoritePhraseIds,
      'streakDays': _progress.streakDays,
      'lastStudyDate': _progress.lastStudyDate,
      'dailyGoal': _progress.dailyGoal,
      'totalStudyMinutes': _progress.totalStudyMinutes,
    }));
    await prefs.setString(
      'daily_records',
      json.encode(_dailyRecords.map((r) => r.toJson()).toList()),
    );
  }

  Future<void> markPhraseAsLearned(String phraseId) async {
    if (_progress.learnedPhraseIds.contains(phraseId)) return;
    final newIds = [..._progress.learnedPhraseIds, phraseId];
    _progress = _progress.copyWith(learnedPhraseIds: newIds);
    _updateDailyRecord(phrasesLearned: 1);
    _updateStreak();
    await _save();
    notifyListeners();
  }

  Future<void> toggleFavorite(String phraseId) async {
    final favs = [..._progress.favoritePhraseIds];
    if (favs.contains(phraseId)) {
      favs.remove(phraseId);
    } else {
      favs.add(phraseId);
    }
    _progress = _progress.copyWith(favoritePhraseIds: favs);
    await _save();
    notifyListeners();
  }

  bool isFavorite(String phraseId) =>
      _progress.favoritePhraseIds.contains(phraseId);

  bool isLearned(String phraseId) =>
      _progress.learnedPhraseIds.contains(phraseId);

  void _updateDailyRecord({int phrasesLearned = 0, int studyMinutes = 0, int quizScore = 0}) {
    final today = _todayString();
    final idx = _dailyRecords.indexWhere((r) => r.date == today);
    if (idx >= 0) {
      final r = _dailyRecords[idx];
      _dailyRecords[idx] = DailyRecord(
        date: today,
        phrasesLearned: r.phrasesLearned + phrasesLearned,
        studyMinutes: r.studyMinutes + studyMinutes,
        quizScore: quizScore > 0 ? quizScore : r.quizScore,
      );
    } else {
      _dailyRecords.add(DailyRecord(
        date: today,
        phrasesLearned: phrasesLearned,
        studyMinutes: studyMinutes,
        quizScore: quizScore,
      ));
    }
  }

  void _updateStreak() {
    final today = _todayString();
    if (_progress.lastStudyDate == today) return;

    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yStr = '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}';

    int newStreak = _progress.lastStudyDate == yStr
        ? _progress.streakDays + 1
        : 1;

    _progress = _progress.copyWith(
      streakDays: newStreak,
      lastStudyDate: today,
    );
  }

  Future<void> setLevel(Difficulty level) async {
    _progress = _progress.copyWith(level: level);
    await _save();
    notifyListeners();
  }

  Future<void> setDailyGoal(int goal) async {
    _progress = _progress.copyWith(dailyGoal: goal);
    await _save();
    notifyListeners();
  }

  Future<void> recordQuizResult(int score) async {
    _updateDailyRecord(quizScore: score);
    await _save();
    notifyListeners();
  }

  // 이번 주 데이터 (최근 7일)
  List<DailyRecord> get weeklyRecords {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      final dStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return _dailyRecords.firstWhere(
        (r) => r.date == dStr,
        orElse: () => DailyRecord(date: dStr, phrasesLearned: 0, quizScore: 0, studyMinutes: 0),
      );
    });
  }

  // 카테고리별 달성률
  Map<String, double> categoryProgress(Map<String, List<String>> categoryPhraseIds) {
    final result = <String, double>{};
    categoryPhraseIds.forEach((catId, phraseIds) {
      if (phraseIds.isEmpty) {
        result[catId] = 0.0;
        return;
      }
      final learned = phraseIds.where((id) => _progress.learnedPhraseIds.contains(id)).length;
      result[catId] = learned / phraseIds.length;
    });
    return result;
  }
}
