// [AI Chat 기능 비활성화 — 백엔드 구현 후 복원 예정]
//
// import 'package:flutter/material.dart';
// import '../../constants/colors.dart';
// import '../../constants/layout.dart';
// import '../../constants/typography.dart';
// import '../../models/user_progress.dart';
//
// class ChatBubble extends StatelessWidget {
//   final ChatMessage message;
//
//   const ChatBubble({super.key, required this.message});
//
//   bool get isUser => message.role == 'user';
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppLayout.screenPadding,
//         vertical: AppLayout.gapSM / 2,
//       ),
//       child: Column(
//         crossAxisAlignment:
//             isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment:
//                 isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (!isUser) ...[
//                 const CircleAvatar(
//                   radius: 16,
//                   backgroundColor: AppColors.primary,
//                   child: Text('AI', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
//                 ),
//                 const SizedBox(width: AppLayout.gapSM),
//               ],
//               Flexible(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppLayout.paddingMD,
//                     vertical: AppLayout.paddingSM + 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: isUser ? AppColors.primary : AppColors.surfaceColor(context),
//                     borderRadius: BorderRadius.only(
//                       topLeft: const Radius.circular(AppLayout.radiusMD),
//                       topRight: const Radius.circular(AppLayout.radiusMD),
//                       bottomLeft: Radius.circular(isUser ? AppLayout.radiusMD : 4),
//                       bottomRight: Radius.circular(isUser ? 4 : AppLayout.radiusMD),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withValues(alpha: 0.06),
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     message.content,
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: isUser ? Colors.white : AppColors.textPrimaryColor(context),
//                     ),
//                   ),
//                 ),
//               ),
//               if (isUser) ...[
//                 const SizedBox(width: AppLayout.gapSM),
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundColor: AppColors.surfaceAltColor(context),
//                   child: Icon(Icons.person, size: 18, color: AppColors.textSecondaryColor(context)),
//                 ),
//               ],
//             ],
//           ),
//           // 피드백 칩
//           if (!isUser && message.feedback != null) ...[
//             const SizedBox(height: AppLayout.gapSM),
//             Container(
//               margin: const EdgeInsets.only(left: 40),
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppLayout.paddingMD,
//                 vertical: AppLayout.paddingSM,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.accent.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(AppLayout.radiusSM),
//                 border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
//               ),
//               child: Text(
//                 message.feedback!,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textPrimaryColor(context),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
