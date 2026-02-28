// [AI Chat 기능 비활성화 — 백엔드 구현 후 복원 예정]
//
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../models/user_progress.dart';
//
// class ChatProvider extends ChangeNotifier {
//   ChatSession? _currentSession;
//   bool _isLoading = false;
//   String _errorMessage = '';
//
//   ChatSession? get currentSession => _currentSession;
//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;
//
//   // Gemini API 키 (flutter run --dart-define=GEMINI_API_KEY=AIza...)
//   static const String _apiKey = String.fromEnvironment(
//     'GEMINI_API_KEY',
//     defaultValue: 'YOUR_GEMINI_API_KEY',
//   );
//   static const String _apiUrl =
//       'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';
//
//   void startNewSession(String scenario) {
//     _currentSession = ChatSession(
//       id: DateTime.now().millisecondsSinceEpoch.toString(),
//       scenario: scenario,
//       messages: [],
//       createdAt: DateTime.now(),
//     );
//     _errorMessage = '';
//     notifyListeners();
//   }
//
//   Future<void> sendMessage(String content) async {
//     if (_currentSession == null || content.trim().isEmpty) return;
//
//     final userMsg = ChatMessage(
//       role: 'user',
//       content: content,
//       timestamp: DateTime.now(),
//     );
//
//     _currentSession = ChatSession(
//       id: _currentSession!.id,
//       scenario: _currentSession!.scenario,
//       messages: [..._currentSession!.messages, userMsg],
//       createdAt: _currentSession!.createdAt,
//     );
//     _isLoading = true;
//     _errorMessage = '';
//     notifyListeners();
//
//     try {
//       final response = await _callGeminiApi(content);
//       final assistantMsg = ChatMessage(
//         role: 'assistant',
//         content: response['reply'] ?? '',
//         feedback: response['feedback'],
//         timestamp: DateTime.now(),
//       );
//
//       _currentSession = ChatSession(
//         id: _currentSession!.id,
//         scenario: _currentSession!.scenario,
//         messages: [..._currentSession!.messages, assistantMsg],
//         createdAt: _currentSession!.createdAt,
//       );
//     } catch (e) {
//       _errorMessage = 'AI 응답을 받지 못했습니다. 다시 시도해 주세요.';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<Map<String, String?>> _callGeminiApi(String userMessage) async {
//     if (_apiKey == 'YOUR_GEMINI_API_KEY') {
//       // 데모 응답
//       await Future.delayed(const Duration(milliseconds: 800));
//       return {
//         'reply': 'That sounds great! Could you tell me more about what you\'re looking for?',
//         'feedback': null,
//       };
//     }
//
//     final systemPrompt = '''You are an English conversation practice assistant.
// Scenario: ${_currentSession!.scenario}
// Help the user practice English conversation. After responding naturally, if the user made any grammar mistakes, provide brief feedback in Korean starting with "💡 피드백:" followed by the correction.
// Keep responses concise and conversational.''';
//
//     // Gemini API: role은 'user' 또는 'model'
//     final contents = _currentSession!.messages.map((m) {
//       return {
//         'role': m.role == 'assistant' ? 'model' : 'user',
//         'parts': [{'text': m.content}],
//       };
//     }).toList();
//
//     final response = await http.post(
//       Uri.parse('$_apiUrl?key=$_apiKey'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'system_instruction': {
//           'parts': [{'text': systemPrompt}],
//         },
//         'contents': contents,
//         'generationConfig': {
//           'maxOutputTokens': 500,
//         },
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final text =
//           data['candidates'][0]['content']['parts'][0]['text'] as String;
//
//       String reply = text;
//       String? feedback;
//
//       if (text.contains('💡 피드백:')) {
//         final parts = text.split('💡 피드백:');
//         reply = parts[0].trim();
//         feedback = '💡 피드백:${parts[1].trim()}';
//       }
//
//       return {'reply': reply, 'feedback': feedback};
//     } else {
//       throw Exception('API error: ${response.statusCode}');
//     }
//   }
//
//   void clearSession() {
//     _currentSession = null;
//     notifyListeners();
//   }
// }
//
// const List<Map<String, String>> aiScenarios = [
//   {'title': '카페에서 주문하기', 'description': '당신은 뉴욕의 카페에 있습니다. 음료를 주문해 보세요.', 'icon': '☕'},
//   {'title': '호텔 체크인', 'description': '당신은 호텔 프론트에 있습니다. 체크인을 해보세요.', 'icon': '🏨'},
//   {'title': '길 물어보기', 'description': '당신은 낯선 도시에 있습니다. 관광지로 가는 길을 물어보세요.', 'icon': '🗺️'},
//   {'title': '직장 인터뷰', 'description': '영어 면접 상황입니다. 자기소개와 질문에 답해보세요.', 'icon': '💼'},
//   {'title': '병원 방문', 'description': '당신은 아파서 병원을 방문했습니다. 증상을 설명해보세요.', 'icon': '🏥'},
//   {'title': '쇼핑하기', 'description': '당신은 옷 가게에 있습니다. 원하는 옷을 찾아보세요.', 'icon': '🛍️'},
// ];
