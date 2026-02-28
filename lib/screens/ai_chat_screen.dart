// [AI Chat 기능 비활성화 — 백엔드 구현 후 복원 예정]
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../constants/colors.dart';
// import '../constants/typography.dart';
// import '../constants/layout.dart';
// import '../providers/chat_provider.dart';
// import '../widgets/chat/chat_bubble.dart';
//
// class AiChatScreen extends StatefulWidget {
//   const AiChatScreen({super.key});
//
//   @override
//   State<AiChatScreen> createState() => _AiChatScreenState();
// }
//
// class _AiChatScreenState extends State<AiChatScreen> {
//   final _scrollController = ScrollController();
//   final _textController = TextEditingController();
//   bool _sessionStarted = false;
//   String? _selectedScenario;
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }
//
//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void _startSession(String scenario, String title) {
//     context.read<ChatProvider>().startNewSession(scenario);
//     setState(() {
//       _sessionStarted = true;
//       _selectedScenario = title;
//     });
//   }
//
//   Future<void> _sendMessage() async {
//     final text = _textController.text.trim();
//     if (text.isEmpty) return;
//     _textController.clear();
//     await context.read<ChatProvider>().sendMessage(text);
//     _scrollToBottom();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg(context),
//       appBar: AppBar(
//         backgroundColor: AppColors.surfaceColor(context),
//         elevation: 0,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('AI 대화 연습', style: AppTextStyles.headlineSmall),
//             if (_selectedScenario != null)
//               Text(_selectedScenario!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary)),
//           ],
//         ),
//         actions: [
//           if (_sessionStarted)
//             TextButton(
//               onPressed: () {
//                 context.read<ChatProvider>().clearSession();
//                 setState(() {
//                   _sessionStarted = false;
//                   _selectedScenario = null;
//                 });
//               },
//               child: Text('종료', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error)),
//             ),
//         ],
//       ),
//       body: _sessionStarted ? _buildChatUI() : _buildScenarioPicker(),
//     );
//   }
//
//   Widget _buildScenarioPicker() {
//     return Padding(
//       padding: const EdgeInsets.all(AppLayout.screenPadding),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: AppLayout.paddingSM),
//           Text('상황을 선택해주세요', style: AppTextStyles.headlineMedium),
//           const SizedBox(height: AppLayout.paddingSM),
//           Text(
//             'AI와 실제 상황을 연습하며 영어 회화 실력을 키워보세요.',
//             style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryColor(context)),
//           ),
//           const SizedBox(height: AppLayout.paddingXL),
//           Expanded(
//             child: ListView.separated(
//               itemCount: aiScenarios.length,
//               separatorBuilder: (_, __) => const SizedBox(height: AppLayout.gapMD),
//               itemBuilder: (context, i) {
//                 final scenario = aiScenarios[i];
//                 return GestureDetector(
//                   onTap: () => _startSession(scenario['description']!, scenario['title']!),
//                   child: Container(
//                     padding: const EdgeInsets.all(AppLayout.paddingMD),
//                     decoration: BoxDecoration(
//                       color: AppColors.surfaceColor(context),
//                       borderRadius: BorderRadius.circular(AppLayout.radiusLG),
//                       border: Border.all(color: AppColors.borderColor(context)),
//                     ),
//                     child: Row(
//                       children: [
//                         Text(scenario['icon']!, style: const TextStyle(fontSize: 32)),
//                         const SizedBox(width: AppLayout.paddingMD),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(scenario['title']!, style: AppTextStyles.titleLarge),
//                               const SizedBox(height: 4),
//                               Text(
//                                 scenario['description']!,
//                                 style: AppTextStyles.bodySmall,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Icon(Icons.chevron_right, color: AppColors.textSecondaryColor(context)),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChatUI() {
//     return Consumer<ChatProvider>(
//       builder: (context, chat, _) {
//         final messages = chat.currentSession?.messages ?? [];
//         if (messages.isNotEmpty) _scrollToBottom();
//
//         return Column(
//           children: [
//             // 상황 설명 배너
//             if (chat.currentSession != null)
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppLayout.screenPadding,
//                   vertical: AppLayout.paddingSM,
//                 ),
//                 color: AppColors.primary.withValues(alpha: 0.08),
//                 child: Text(
//                   chat.currentSession!.scenario,
//                   style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//
//             // 메시지 목록
//             Expanded(
//               child: messages.isEmpty
//                   ? Center(
//                       child: Text(
//                         '첫 인사를 해보세요! 👋',
//                         style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondaryColor(context)),
//                       ),
//                     )
//                   : ListView.builder(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.all(AppLayout.paddingMD),
//                       itemCount: messages.length + (chat.isLoading ? 1 : 0),
//                       itemBuilder: (context, i) {
//                         if (i == messages.length) {
//                           return const _TypingIndicator();
//                         }
//                         final msg = messages[i];
//                         return ChatBubble(
//                           message: msg,
//                         );
//                       },
//                     ),
//             ),
//
//             // 에러 메시지
//             if (chat.errorMessage.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppLayout.screenPadding,
//                   vertical: AppLayout.paddingSM,
//                 ),
//                 child: Text(
//                   chat.errorMessage,
//                   style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//
//             // 입력 영역
//             Container(
//               color: AppColors.surfaceColor(context),
//               padding: EdgeInsets.only(
//                 left: AppLayout.screenPadding,
//                 right: AppLayout.screenPadding,
//                 top: AppLayout.paddingSM,
//                 bottom: MediaQuery.of(context).viewInsets.bottom + AppLayout.paddingMD,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _textController,
//                       decoration: InputDecoration(
//                         hintText: '영어로 말해보세요...',
//                         hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabledColor(context)),
//                         filled: true,
//                         fillColor: AppColors.surfaceAltColor(context),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: AppLayout.paddingMD,
//                           vertical: AppLayout.paddingSM,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       textInputAction: TextInputAction.send,
//                       onSubmitted: (_) => _sendMessage(),
//                     ),
//                   ),
//                   const SizedBox(width: AppLayout.gapSM),
//                   GestureDetector(
//                     onTap: chat.isLoading ? null : _sendMessage,
//                     child: Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: chat.isLoading ? AppColors.textDisabledColor(context) : AppColors.primary,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
//
// class _TypingIndicator extends StatelessWidget {
//   const _TypingIndicator();
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: AppLayout.paddingMD),
//       child: Row(
//         children: [
//           Container(
//             width: 36,
//             height: 36,
//             decoration: const BoxDecoration(
//               color: AppColors.primary,
//               shape: BoxShape.circle,
//             ),
//             child: const Center(
//               child: Text('AI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
//             ),
//           ),
//           const SizedBox(width: AppLayout.gapSM),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: AppColors.surfaceAltColor(context),
//               borderRadius: BorderRadius.circular(AppLayout.radiusLG),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: List.generate(3, (i) => _Dot(delay: i * 200)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Dot extends StatefulWidget {
//   final int delay;
//
//   const _Dot({required this.delay});
//
//   @override
//   State<_Dot> createState() => _DotState();
// }
//
// class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     Future.delayed(Duration(milliseconds: widget.delay), () {
//       if (mounted) _ctrl.repeat(reverse: true);
//     });
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 2),
//       child: FadeTransition(
//         opacity: _ctrl,
//         child: Container(
//           width: 6,
//           height: 6,
//           decoration: BoxDecoration(color: AppColors.textSecondaryColor(context), shape: BoxShape.circle),
//         ),
//       ),
//     );
//   }
// }
