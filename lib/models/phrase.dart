class Example {
  final String english;
  final String korean;

  const Example({required this.english, required this.korean});

  factory Example.fromJson(Map<String, dynamic> json) {
    return Example(english: json['english'], korean: json['korean']);
  }

  Map<String, dynamic> toJson() => {
    'english': english,
    'korean': korean,
  };
}

enum Difficulty { beginner, intermediate, advanced }

class Phrase {
  final String id;
  final String english;
  final String korean;
  final String pronunciation;
  final String categoryId;
  final List<Example> examples;
  final Difficulty difficulty;
  final List<String> tags;

  const Phrase({
    required this.id,
    required this.english,
    required this.korean,
    required this.pronunciation,
    required this.categoryId,
    required this.examples,
    required this.difficulty,
    this.tags = const [],
  });

  factory Phrase.fromJson(Map<String, dynamic> json) {
    return Phrase(
      id: json['id'],
      english: json['english'],
      korean: json['korean'],
      pronunciation: json['pronunciation'],
      categoryId: json['categoryId'],
      examples: (json['examples'] as List)
          .map((e) => Example.fromJson(e))
          .toList(),
      difficulty: Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.beginner,
      ),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'english': english,
    'korean': korean,
    'pronunciation': pronunciation,
    'categoryId': categoryId,
    'examples': examples.map((e) => e.toJson()).toList(),
    'difficulty': difficulty.name,
    'tags': tags,
  };
}
