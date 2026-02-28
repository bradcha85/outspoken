import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/scenario.dart';
import '../data/scenarios_data.dart';

class ScenarioProvider extends ChangeNotifier {
  // Static data
  final List<Scenario> _scenarios = allScenarios;

  // Persisted results
  List<ScenarioResult> _results = [];

  // In-memory session state
  String? _activeScenarioId;
  int _currentTurnIndex = 0;
  List<ChoiceResult> _currentChoiceHistory = [];

  // ── Getters ──

  List<Scenario> get scenarios => _scenarios;
  List<ScenarioResult> get results => _results;

  Scenario? get activeScenario {
    if (_activeScenarioId == null) return null;
    return _scenarios.where((s) => s.id == _activeScenarioId).firstOrNull;
  }

  ScenarioTurn? get currentTurn {
    final scenario = activeScenario;
    if (scenario == null) return null;
    if (_currentTurnIndex >= scenario.turns.length) return null;
    return scenario.turns[_currentTurnIndex];
  }

  bool get isLastTurn {
    final scenario = activeScenario;
    if (scenario == null) return false;
    return _currentTurnIndex >= scenario.turns.length - 1;
  }

  int get currentTurnIndex => _currentTurnIndex;
  List<ChoiceResult> get currentChoiceHistory => _currentChoiceHistory;

  // ── Persistence ──

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('scenario_results');
    if (json != null) {
      final list = jsonDecode(json) as List;
      _results = list.map((e) => ScenarioResult.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'scenario_results',
      jsonEncode(_results.map((r) => r.toJson()).toList()),
    );
  }

  // ── Game Session ──

  void startScenario(String id) {
    _activeScenarioId = id;
    _currentTurnIndex = 0;
    _currentChoiceHistory = [];
    notifyListeners();
  }

  void makeChoice(ChoiceResult result) {
    _currentChoiceHistory.add(result);
    notifyListeners();
  }

  void advanceToNextTurn() {
    if (_currentTurnIndex < (activeScenario?.turns.length ?? 0) - 1) {
      _currentTurnIndex++;
    }
    notifyListeners();
  }

  ScenarioResult finishScenario() {
    final perfectCount = _currentChoiceHistory.where((c) => c == ChoiceResult.perfect).length;
    final awkwardCount = _currentChoiceHistory.where((c) => c == ChoiceResult.awkward).length;
    final failCount = _currentChoiceHistory.where((c) => c == ChoiceResult.fail).length;
    final grade = calculateGrade(perfectCount, awkwardCount, failCount);

    final result = ScenarioResult(
      scenarioId: _activeScenarioId!,
      grade: grade,
      perfectCount: perfectCount,
      awkwardCount: awkwardCount,
      failCount: failCount,
      turnsCompleted: _currentChoiceHistory.length,
      choiceHistory: List.from(_currentChoiceHistory),
      playedAt: DateTime.now().toIso8601String(),
    );

    _results.add(result);
    _save();
    notifyListeners();
    return result;
  }

  void resetSession() {
    _activeScenarioId = null;
    _currentTurnIndex = 0;
    _currentChoiceHistory = [];
    notifyListeners();
  }

  ScenarioGrade? bestGrade(String scenarioId) {
    final grades = _results
        .where((r) => r.scenarioId == scenarioId)
        .map((r) => r.grade)
        .toList();
    if (grades.isEmpty) return null;
    // S < A < B < C < F in enum order, so min index = best
    return grades.reduce((a, b) => a.index <= b.index ? a : b);
  }

  int playCount(String scenarioId) {
    return _results.where((r) => r.scenarioId == scenarioId).length;
  }
}
