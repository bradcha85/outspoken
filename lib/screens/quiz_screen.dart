import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../models/phrase.dart';
import '../providers/phrase_provider.dart';
import '../providers/progress_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<_QuizQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _buildQuiz());
  }

  void _buildQuiz() {
    final phraseProvider = context.read<PhraseProvider>();
    final allPhrases = phraseProvider.phrases;
    if (allPhrases.length < 4) return;

    final shuffled = [...allPhrases]..shuffle(Random());
    final selected = shuffled.take(10).toList();
    final questions = <_QuizQuestion>[];

    for (final phrase in selected) {
      final distractors = allPhrases
          .where((p) => p.id != phrase.id)
          .toList()
        ..shuffle(Random());
      final options = [phrase, ...distractors.take(3)]..shuffle(Random());
      questions.add(_QuizQuestion(
        phrase: phrase,
        options: options,
        correctIndex: options.indexWhere((p) => p.id == phrase.id),
      ));
    }

    setState(() {
      _questions = questions;
      _isReady = true;
    });
  }

  void _onSelectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _next() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    final percent = (_score / _questions.length * 100).round();
    context.read<ProgressProvider>().recordQuizResult(percent);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppLayout.radiusLG)),
        title: Text(
          percent >= 80 ? '훌륭해요! 🎉' : percent >= 50 ? '잘했어요! 👍' : '더 연습해봐요! 💪',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_score / ${_questions.length}',
              style: AppTextStyles.displayLarge.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppLayout.gapSM),
            Text('$percent점', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppLayout.gapMD),
            LinearProgressIndicator(
              value: _score / _questions.length,
              backgroundColor: AppColors.surfaceAltColor(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 80 ? AppColors.secondary : percent >= 50 ? AppColors.accent : AppColors.error,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('홈으로'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _currentIndex = 0;
                _score = 0;
                _selectedAnswer = null;
                _answered = false;
              });
              _buildQuiz();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('다시 풀기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${_questions.length}',
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppLayout.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 진행 바
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: AppColors.surfaceAltColor(context),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
            ),
            const SizedBox(height: AppLayout.paddingXL),

            // 문제
            Text('다음 영어 표현의 뜻은?', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryColor(context))),
            const SizedBox(height: AppLayout.paddingMD),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppLayout.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor(context),
                borderRadius: BorderRadius.circular(AppLayout.radiusLG),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    question.phrase.english,
                    style: AppTextStyles.phraseDisplay,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppLayout.gapSM),
                  Text(
                    question.phrase.pronunciation,
                    style: AppTextStyles.pronunciation,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppLayout.paddingXL),

            // 선택지
            Text('보기', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryColor(context))),
            const SizedBox(height: AppLayout.gapMD),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppLayout.gapMD),
                itemBuilder: (context, i) {
                  final option = question.options[i];
                  final isSelected = _selectedAnswer == i;
                  final isCorrect = i == question.correctIndex;

                  Color borderColor = AppColors.borderColor(context);
                  Color bgColor = AppColors.surfaceColor(context);
                  Color textColor = AppColors.textPrimaryColor(context);

                  if (_answered) {
                    if (isCorrect) {
                      borderColor = AppColors.secondary;
                      bgColor = AppColors.secondary.withValues(alpha: 0.08);
                      textColor = AppColors.secondary;
                    } else if (isSelected) {
                      borderColor = AppColors.error;
                      bgColor = AppColors.error.withValues(alpha: 0.08);
                      textColor = AppColors.error;
                    }
                  } else if (isSelected) {
                    borderColor = AppColors.primary;
                    bgColor = AppColors.primary.withValues(alpha: 0.08);
                  }

                  return GestureDetector(
                    onTap: () => _onSelectAnswer(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppLayout.paddingMD),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: borderColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(
                                  color: borderColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppLayout.gapMD),
                          Expanded(
                            child: Text(option.korean, style: AppTextStyles.bodyLarge.copyWith(color: textColor)),
                          ),
                          if (_answered && isCorrect)
                            const Icon(Icons.check_circle, color: AppColors.secondary, size: 20),
                          if (_answered && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: AppColors.error, size: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // 다음 버튼
            if (_answered) ...[
              const SizedBox(height: AppLayout.paddingMD),
              SizedBox(
                width: double.infinity,
                height: AppLayout.buttonHeight,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? '다음 문제' : '결과 보기',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppLayout.paddingMD),
          ],
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final Phrase phrase;
  final List<Phrase> options;
  final int correctIndex;

  const _QuizQuestion({
    required this.phrase,
    required this.options,
    required this.correctIndex,
  });
}
