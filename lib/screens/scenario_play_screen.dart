import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';
import '../models/scenario.dart';
import '../providers/scenario_provider.dart';
import '../providers/settings_provider.dart';
import '../services/sherpa_tts_service.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/progress_bar_widget.dart';

class ScenarioPlayScreen extends StatefulWidget {
  final String scenarioId;

  const ScenarioPlayScreen({super.key, required this.scenarioId});

  @override
  State<ScenarioPlayScreen> createState() => _ScenarioPlayScreenState();
}

class _ScenarioPlayScreenState extends State<ScenarioPlayScreen>
    with SingleTickerProviderStateMixin {
  // ── TTS ──
  final SherpaTtsService _ttsService = SherpaTtsService.instance;
  String? _speakingMode;
  Timer? _playbackTimer;

  // ── Animation ──
  late AnimationController _reactionController;
  late Animation<double> _reactionFade;

  // ── UI state ──
  bool _introShown = false;
  bool _showReaction = false;
  bool _showKorean = false;
  ScenarioChoice? _selectedChoice;

  @override
  void initState() {
    super.initState();
    _reactionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _reactionFade = CurvedAnimation(
      parent: _reactionController,
      curve: Curves.easeInOut,
    );
    _warmUpTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScenarioProvider>().startScenario(widget.scenarioId);
    });
  }

  Future<void> _warmUpTts() async {
    try {
      await _ttsService.initialize();
    } catch (_) {}
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _ttsService.stop();
    _reactionController.dispose();
    super.dispose();
  }

  // ── TTS ──

  Future<void> _speak(String text) async {
    if (_speakingMode != null) {
      _playbackTimer?.cancel();
      await _ttsService.stop();
      setState(() => _speakingMode = null);
      return;
    }
    setState(() => _speakingMode = 'normal');
    try {
      final settingsProvider = context.read<SettingsProvider>();
      final duration = await _ttsService.speak(
        text,
        speed: SherpaTtsService.mapUiRateToSpeed(settingsProvider.speechRate),
        sid: settingsProvider.ttsSpeakerId,
      );
      _playbackTimer?.cancel();
      _playbackTimer = Timer(duration + const Duration(milliseconds: 120), () {
        if (mounted) setState(() => _speakingMode = null);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _speakingMode = null);
    }
  }

  // ── Actions ──

  void _startScenario() {
    setState(() => _introShown = true);
  }

  void _selectChoice(int index, ScenarioChoice choice) {
    if (_showReaction) return;
    setState(() {
      _selectedChoice = choice;
      _showReaction = true;
    });
    context.read<ScenarioProvider>().makeChoice(choice.result);
    _reactionController.forward(from: 0);
    if (choice.result == ChoiceResult.perfect) {
      _speak(choice.english);
    }
  }

  void _nextTurn() {
    final provider = context.read<ScenarioProvider>();
    if (provider.isLastTurn) {
      provider.finishScenario();
      context.pushReplacement('/scenario-result/${widget.scenarioId}');
      return;
    }
    provider.advanceToNextTurn();
    setState(() {
      _showReaction = false;
      _selectedChoice = null;
      _showKorean = false;
    });
    _reactionController.reset();
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScenarioProvider>();
    final scenario = provider.activeScenario;

    if (scenario == null) {
      return Scaffold(
        backgroundColor: AppColors.bg(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final categoryColor =
        AppColors.categoryColors[scenario.categoryId] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: _buildAppBar(provider, scenario),
      body: !_introShown
          ? _buildIntro(scenario, categoryColor)
          : _buildTurnBody(scenario, provider, categoryColor),
    );
  }

  PreferredSizeWidget _buildAppBar(
      ScenarioProvider provider, Scenario scenario) {
    return AppBar(
      backgroundColor: AppColors.surfaceColor(context),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () {
          provider.resetSession();
          context.pop();
        },
      ),
      title: _introShown
          ? Text(
              '${provider.currentTurnIndex + 1} / ${scenario.turns.length}',
              style: AppTextStyles.titleMedium,
            )
          : null,
      centerTitle: true,
    );
  }

  // ── State 1: Intro ──

  Widget _buildIntro(Scenario scenario, Color categoryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppLayout.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Setting tag
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.paddingSM,
              vertical: AppLayout.paddingXS,
            ),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppLayout.radiusSM),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.place, size: AppLayout.iconSM, color: categoryColor),
                const SizedBox(width: AppLayout.gapXS),
                Text(
                  scenario.setting,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: categoryColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.gapXL),

          // Intro card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppLayout.paddingLG),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(AppLayout.radiusLG),
              border: Border.all(color: AppColors.borderColor(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: AppLayout.elevationMD,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.title,
                  style: AppTextStyles.headlineLarge.copyWith(
                    color: AppColors.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: AppLayout.gapSM),
                Text(
                  scenario.titleEn,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: AppLayout.gapLG),
                Text(
                  scenario.description,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: AppLayout.gapLG),
                Row(
                  children: [
                    Icon(Icons.record_voice_over,
                        size: AppLayout.iconSM, color: categoryColor),
                    const SizedBox(width: AppLayout.gapXS),
                    Text(
                      scenario.npcName,
                      style: AppTextStyles.titleMedium
                          .copyWith(color: categoryColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.paddingXL),

          // Start button
          Semantics(
            button: true,
            label: '시나리오 시작하기',
            child: CustomButton(
              label: '시작하기',
              onPressed: _startScenario,
            ),
          ),
        ],
      ),
    );
  }

  // ── State 2 & 3: Turn body ──

  Widget _buildTurnBody(
      Scenario scenario, ScenarioProvider provider, Color categoryColor) {
    final turn = provider.currentTurn;
    if (turn == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.screenPadding,
          ),
          child: ProgressBarWidget(
            value: (provider.currentTurnIndex + 1) / scenario.turns.length,
            color: categoryColor,
          ),
        ),
        const SizedBox(height: AppLayout.gapLG),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Situation text
                Text(
                  turn.getSituation(provider.previousTurnResult),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryColor(context),
                  ),
                ),
                const SizedBox(height: AppLayout.gapLG),

                // NPC speech bubble
                _buildNpcBubble(scenario, turn, categoryColor),
                const SizedBox(height: AppLayout.gapXL),

                // Choices or Reaction
                if (_showReaction)
                  _buildReaction(turn, categoryColor)
                else
                  _buildChoices(turn, categoryColor),

                const SizedBox(height: AppLayout.paddingLG),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNpcBubble(
      Scenario scenario, ScenarioTurn turn, Color categoryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.paddingMD),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppLayout.radiusMD),
        border: Border.all(color: categoryColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NPC name + TTS button
          Row(
            children: [
              Icon(Icons.record_voice_over,
                  size: AppLayout.iconSM, color: categoryColor),
              const SizedBox(width: AppLayout.gapXS),
              Expanded(
                child: Text(
                  scenario.npcName,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: categoryColor),
                ),
              ),
              Semantics(
                button: true,
                label: 'NPC 대사 듣기',
                child: GestureDetector(
                  onTap: () => _speak(turn.npcDialogue),
                  child: Container(
                    padding: const EdgeInsets.all(AppLayout.paddingXS),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppLayout.radiusCircle),
                    ),
                    child: Icon(
                      _speakingMode != null
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                      size: AppLayout.iconSM,
                      color: categoryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppLayout.gapSM),

          // NPC dialogue (English)
          Text(
            turn.npcDialogue,
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimaryColor(context),
            ),
          ),
          const SizedBox(height: AppLayout.gapSM),

          // Korean toggle
          GestureDetector(
            onTap: () => setState(() => _showKorean = !_showKorean),
            child: _showKorean
                ? Text(
                    turn.npcDialogueKo,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondaryColor(context),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_outlined,
                          color: AppColors.textSecondaryColor(context),
                          size: AppLayout.iconSM),
                      const SizedBox(width: AppLayout.gapXS),
                      Text(
                        '한국어 해석 보기',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondaryColor(context),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Choices ──

  Widget _buildChoices(ScenarioTurn turn, Color categoryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(turn.choices.length, (i) {
        final choice = turn.choices[i];
        final label = String.fromCharCode(65 + i); // A, B, C

        return Padding(
          padding: EdgeInsets.only(
            bottom: i < turn.choices.length - 1 ? AppLayout.gapMD : 0,
          ),
          child: Semantics(
            button: true,
            label: '선택지 $label: ${choice.korean}',
            child: GestureDetector(
              onTap: () => _selectChoice(i, choice),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(AppLayout.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor(context),
                  borderRadius: BorderRadius.circular(AppLayout.radiusMD),
                  border: Border.all(color: AppColors.borderColor(context)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label badge
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppLayout.radiusCircle),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: categoryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppLayout.gapMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            choice.english,
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.textPrimaryColor(context),
                            ),
                          ),
                          const SizedBox(height: AppLayout.gapXS),
                          Text(
                            choice.korean,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── State 3: Reaction ──

  Widget _buildReaction(ScenarioTurn turn, Color categoryColor) {
    if (_selectedChoice == null) return const SizedBox.shrink();
    final choice = _selectedChoice!;
    final provider = context.read<ScenarioProvider>();

    final resultColor = switch (choice.result) {
      ChoiceResult.perfect => AppColors.secondary,
      ChoiceResult.awkward => AppColors.accent,
      ChoiceResult.fail => AppColors.error,
    };
    final resultIcon = switch (choice.result) {
      ChoiceResult.perfect => '✅',
      ChoiceResult.awkward => '⚠️',
      ChoiceResult.fail => '💀',
    };
    final resultLabel = switch (choice.result) {
      ChoiceResult.perfect => 'Perfect!',
      ChoiceResult.awkward => 'Awkward!',
      ChoiceResult.fail => 'Fail!',
    };

    return FadeTransition(
      opacity: _reactionFade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppLayout.paddingSM,
              horizontal: AppLayout.paddingMD,
            ),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppLayout.radiusMD),
              border: Border.all(color: resultColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(resultIcon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: AppLayout.gapSM),
                Text(
                  resultLabel,
                  style: AppTextStyles.headlineSmall
                      .copyWith(color: resultColor),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.gapLG),

          // My choice highlight
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppLayout.paddingMD),
            decoration: BoxDecoration(
              color: resultColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppLayout.radiusMD),
              border: Border.all(color: resultColor.withValues(alpha: 0.25)),
            ),
            child: Text(
              choice.english,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimaryColor(context),
              ),
            ),
          ),
          const SizedBox(height: AppLayout.gapLG),

          // NPC reaction
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppLayout.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(context),
              borderRadius: BorderRadius.circular(AppLayout.radiusMD),
              border: Border.all(color: AppColors.borderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.record_voice_over,
                        size: AppLayout.iconSM, color: categoryColor),
                    const SizedBox(width: AppLayout.gapXS),
                    Text(
                      provider.activeScenario?.npcName ?? '',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: categoryColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppLayout.gapSM),
                Text(
                  choice.reaction,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.textPrimaryColor(context),
                  ),
                ),
                const SizedBox(height: AppLayout.gapXS),
                Text(
                  choice.reactionKo,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.gapLG),

          // Explanation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppLayout.paddingMD),
            decoration: BoxDecoration(
              color: AppColors.surfaceAltColor(context),
              borderRadius: BorderRadius.circular(AppLayout.radiusMD),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppLayout.gapSM),
                Expanded(
                  child: Text(
                    choice.explanation,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimaryColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppLayout.gapXL),

          // Next button
          Semantics(
            button: true,
            label: provider.isLastTurn
                ? '결과 보기'
                : '다음 턴으로 이동',
            child: CustomButton(
              label: provider.isLastTurn
                  ? '결과 보기'
                  : '다음 턴 →',
              onPressed: _nextTurn,
            ),
          ),
        ],
      ),
    );
  }

}
