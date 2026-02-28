enum ChoiceResult { perfect, awkward, fail }

enum ScenarioGrade { S, A, B, C, F }

ScenarioGrade calculateGrade(int perfectCount, int awkwardCount, int failCount) {
  if (perfectCount == 5) return ScenarioGrade.S;
  if (perfectCount >= 4) return ScenarioGrade.A;
  if (perfectCount >= 3) return ScenarioGrade.B;
  if (perfectCount >= 2) return ScenarioGrade.C;
  return ScenarioGrade.F;
}

class ScenarioChoice {
  final String english;
  final String korean;
  final ChoiceResult result;
  final String reaction;
  final String reactionKo;
  final String explanation;
  final String? relatedPhraseId;

  const ScenarioChoice({
    required this.english,
    required this.korean,
    required this.result,
    required this.reaction,
    required this.reactionKo,
    required this.explanation,
    this.relatedPhraseId,
  });
}

class ScenarioTurn {
  final int turnNumber;
  final String situation;
  final String npcDialogue;
  final String npcDialogueKo;
  final List<ScenarioChoice> choices;

  const ScenarioTurn({
    required this.turnNumber,
    required this.situation,
    required this.npcDialogue,
    required this.npcDialogueKo,
    required this.choices,
  });
}

class Scenario {
  final String id;
  final String categoryId;
  final String title;
  final String titleEn;
  final String description;
  final String setting;
  final String npcName;
  final List<ScenarioTurn> turns;

  const Scenario({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.titleEn,
    required this.description,
    required this.setting,
    required this.npcName,
    required this.turns,
  });
}

class ScenarioResult {
  final String scenarioId;
  final ScenarioGrade grade;
  final int perfectCount;
  final int awkwardCount;
  final int failCount;
  final int turnsCompleted;
  final List<ChoiceResult> choiceHistory;
  final String playedAt;

  const ScenarioResult({
    required this.scenarioId,
    required this.grade,
    required this.perfectCount,
    required this.awkwardCount,
    required this.failCount,
    required this.turnsCompleted,
    required this.choiceHistory,
    required this.playedAt,
  });

  ScenarioResult copyWith({
    String? scenarioId,
    ScenarioGrade? grade,
    int? perfectCount,
    int? awkwardCount,
    int? failCount,
    int? turnsCompleted,
    List<ChoiceResult>? choiceHistory,
    String? playedAt,
  }) {
    return ScenarioResult(
      scenarioId: scenarioId ?? this.scenarioId,
      grade: grade ?? this.grade,
      perfectCount: perfectCount ?? this.perfectCount,
      awkwardCount: awkwardCount ?? this.awkwardCount,
      failCount: failCount ?? this.failCount,
      turnsCompleted: turnsCompleted ?? this.turnsCompleted,
      choiceHistory: choiceHistory ?? this.choiceHistory,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'scenarioId': scenarioId,
    'grade': grade.name,
    'perfectCount': perfectCount,
    'awkwardCount': awkwardCount,
    'failCount': failCount,
    'turnsCompleted': turnsCompleted,
    'choiceHistory': choiceHistory.map((c) => c.name).toList(),
    'playedAt': playedAt,
  };

  factory ScenarioResult.fromJson(Map<String, dynamic> json) {
    return ScenarioResult(
      scenarioId: json['scenarioId'],
      grade: ScenarioGrade.values.firstWhere(
        (g) => g.name == json['grade'],
        orElse: () => ScenarioGrade.F,
      ),
      perfectCount: json['perfectCount'],
      awkwardCount: json['awkwardCount'],
      failCount: json['failCount'],
      turnsCompleted: json['turnsCompleted'],
      choiceHistory: (json['choiceHistory'] as List)
          .map((c) => ChoiceResult.values.firstWhere(
                (r) => r.name == c,
                orElse: () => ChoiceResult.fail,
              ))
          .toList(),
      playedAt: json['playedAt'],
    );
  }
}
