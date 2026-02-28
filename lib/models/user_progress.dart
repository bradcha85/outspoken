import '../models/phrase.dart';

class DailyRecord {
  final String date; // YYYY-MM-DD
  final int phrasesLearned;
  final int quizScore; // 0-100
  final int studyMinutes;

  const DailyRecord({
    required this.date,
    required this.phrasesLearned,
    required this.quizScore,
    required this.studyMinutes,
  });

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: json['date'],
      phrasesLearned: json['phrasesLearned'],
      quizScore: json['quizScore'],
      studyMinutes: json['studyMinutes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'phrasesLearned': phrasesLearned,
    'quizScore': quizScore,
    'studyMinutes': studyMinutes,
  };

  DailyRecord copyWith({
    String? date,
    int? phrasesLearned,
    int? quizScore,
    int? studyMinutes,
  }) {
    return DailyRecord(
      date: date ?? this.date,
      phrasesLearned: phrasesLearned ?? this.phrasesLearned,
      quizScore: quizScore ?? this.quizScore,
      studyMinutes: studyMinutes ?? this.studyMinutes,
    );
  }
}

class UserProgress {
  final String userId;
  final Difficulty level;
  final List<String> learnedPhraseIds;
  final List<String> favoritePhraseIds;
  final int streakDays;
  final String lastStudyDate;
  final int dailyGoal;
  final int totalStudyMinutes;

  const UserProgress({
    required this.userId,
    required this.level,
    required this.learnedPhraseIds,
    required this.favoritePhraseIds,
    required this.streakDays,
    required this.lastStudyDate,
    required this.dailyGoal,
    required this.totalStudyMinutes,
  });

  factory UserProgress.initial() => UserProgress(
    userId: 'user_1',
    level: Difficulty.beginner,
    learnedPhraseIds: [],
    favoritePhraseIds: [],
    streakDays: 0,
    lastStudyDate: '',
    dailyGoal: 10,
    totalStudyMinutes: 0,
  );

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      userId: json['userId'],
      level: Difficulty.values.firstWhere(
        (d) => d.name == json['level'],
        orElse: () => Difficulty.beginner,
      ),
      learnedPhraseIds: List<String>.from(json['learnedPhraseIds'] ?? []),
      favoritePhraseIds: List<String>.from(json['favoritePhraseIds'] ?? []),
      streakDays: json['streakDays'] ?? 0,
      lastStudyDate: json['lastStudyDate'] ?? '',
      dailyGoal: json['dailyGoal'] ?? 10,
      totalStudyMinutes: json['totalStudyMinutes'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'level': level.name,
    'learnedPhraseIds': learnedPhraseIds,
    'favoritePhraseIds': favoritePhraseIds,
    'streakDays': streakDays,
    'lastStudyDate': lastStudyDate,
    'dailyGoal': dailyGoal,
    'totalStudyMinutes': totalStudyMinutes,
  };

  UserProgress copyWith({
    Difficulty? level,
    List<String>? learnedPhraseIds,
    List<String>? favoritePhraseIds,
    int? streakDays,
    String? lastStudyDate,
    int? dailyGoal,
    int? totalStudyMinutes,
  }) {
    return UserProgress(
      userId: userId,
      level: level ?? this.level,
      learnedPhraseIds: learnedPhraseIds ?? this.learnedPhraseIds,
      favoritePhraseIds: favoritePhraseIds ?? this.favoritePhraseIds,
      streakDays: streakDays ?? this.streakDays,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
    );
  }
}

// [AI Chat 기능 비활성화 — 백엔드 구현 후 복원 예정]
// class ChatMessage {
//   final String role; // 'user' | 'assistant'
//   final String content;
//   final String? feedback;
//   final DateTime timestamp;
//
//   const ChatMessage({
//     required this.role,
//     required this.content,
//     this.feedback,
//     required this.timestamp,
//   });
//
//   factory ChatMessage.fromJson(Map<String, dynamic> json) {
//     return ChatMessage(
//       role: json['role'],
//       content: json['content'],
//       feedback: json['feedback'],
//       timestamp: DateTime.parse(json['timestamp']),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'role': role,
//     'content': content,
//     'feedback': feedback,
//     'timestamp': timestamp.toIso8601String(),
//   };
//
//   ChatMessage copyWith({
//     String? role,
//     String? content,
//     String? feedback,
//     DateTime? timestamp,
//   }) {
//     return ChatMessage(
//       role: role ?? this.role,
//       content: content ?? this.content,
//       feedback: feedback ?? this.feedback,
//       timestamp: timestamp ?? this.timestamp,
//     );
//   }
// }
//
// class ChatSession {
//   final String id;
//   final String scenario;
//   final List<ChatMessage> messages;
//   final DateTime createdAt;
//
//   const ChatSession({
//     required this.id,
//     required this.scenario,
//     required this.messages,
//     required this.createdAt,
//   });
//
//   factory ChatSession.fromJson(Map<String, dynamic> json) {
//     return ChatSession(
//       id: json['id'],
//       scenario: json['scenario'],
//       messages: (json['messages'] as List)
//           .map((m) => ChatMessage.fromJson(m))
//           .toList(),
//       createdAt: DateTime.parse(json['createdAt']),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'scenario': scenario,
//     'messages': messages.map((m) => m.toJson()).toList(),
//     'createdAt': createdAt.toIso8601String(),
//   };
//
//   ChatSession copyWith({
//     String? id,
//     String? scenario,
//     List<ChatMessage>? messages,
//     DateTime? createdAt,
//   }) {
//     return ChatSession(
//       id: id ?? this.id,
//       scenario: scenario ?? this.scenario,
//       messages: messages ?? this.messages,
//       createdAt: createdAt ?? this.createdAt,
//     );
//   }
// }
