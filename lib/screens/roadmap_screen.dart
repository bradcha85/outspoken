import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/layout.dart';

// Phase 데이터 모델 (화면 전용 내부 클래스)
class _PhaseData {
  final int number;
  final String title;
  final String subtitle;
  final String duration;
  final Color color;
  final IconData icon;
  final List<_PhaseTask> tasks;

  const _PhaseData({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.color,
    required this.icon,
    required this.tasks,
  });
}

class _PhaseTask {
  final String label;
  final String? detail;

  const _PhaseTask(this.label, {this.detail});
}

// ─── 5개 Phase 정적 데이터 ───────────────────────────────────────────────────
const _phases = [
  _PhaseData(
    number: 1,
    title: '기반 구축',
    subtitle: 'Foundation',
    duration: '1–2주',
    color: Color(0xFF6366F1), // Indigo
    icon: Icons.layers_outlined,
    tasks: [
      _PhaseTask('색상·타이포·레이아웃 상수', detail: 'colors / typography / layout'),
      _PhaseTask('앱 라우터 설정', detail: 'go_router — ShellRoute + GoRoute'),
      _PhaseTask('데이터 모델 정의', detail: 'Phrase / Category / UserProgress / ChatSession'),
      _PhaseTask('4개 Provider 구현', detail: 'Phrase · Progress · Chat · Settings'),
      _PhaseTask('정적 데이터 파일 작성', detail: '80개 표현 · 8개 카테고리'),
    ],
  ),
  _PhaseData(
    number: 2,
    title: '핵심 학습',
    subtitle: 'Core Learning',
    duration: '2–3주',
    color: Color(0xFF3B82F6), // Blue
    icon: Icons.menu_book_outlined,
    tasks: [
      _PhaseTask('Splash 화면', detail: '애니메이션 로고 + 자동 이동'),
      _PhaseTask('Onboarding 화면', detail: '레벨 선택 + 목표 설정'),
      _PhaseTask('Home 화면', detail: '오늘의 표현 + 진도 요약'),
      _PhaseTask('Category 화면', detail: '8개 카테고리 그리드'),
      _PhaseTask('Phrase List 화면', detail: '카드 목록 + 필터'),
      _PhaseTask('Phrase Detail 화면', detail: 'TTS + 예문 + 즐겨찾기'),
      _PhaseTask('Favorites 화면', detail: '즐겨찾기 표현 모음'),
    ],
  ),
  _PhaseData(
    number: 3,
    title: '연습',
    subtitle: 'Practice',
    duration: '1–2주',
    color: Color(0xFF10B981), // Emerald
    icon: Icons.fitness_center_outlined,
    tasks: [
      _PhaseTask('Practice 화면', detail: '카드 플립 + TTS 반복'),
      _PhaseTask('Quiz 화면', detail: '4지선다 퀴즈 + 점수'),
      _PhaseTask('Progress 화면', detail: '주간 차트 + 카테고리별 달성률'),
    ],
  ),
  _PhaseData(
    number: 4,
    title: 'AI 대화',
    subtitle: 'AI Chat',
    duration: '1–2주',
    color: Color(0xFF8B5CF6), // Purple
    icon: Icons.chat_bubble_outline,
    tasks: [
      _PhaseTask('AI Chat 화면', detail: '시나리오 선택 + 채팅 UI'),
      _PhaseTask('Claude API 연동', detail: 'claude-sonnet-4-6 · streaming'),
      _PhaseTask('.env 환경변수 관리', detail: 'ANTHROPIC_API_KEY'),
    ],
  ),
  _PhaseData(
    number: 5,
    title: '마무리',
    subtitle: 'Polish & Release',
    duration: '1–2주',
    color: Color(0xFFF59E0B), // Amber
    icon: Icons.rocket_launch_outlined,
    tasks: [
      _PhaseTask('Settings 화면', detail: '레벨 · 알림 · 음성속도 · 다크모드'),
      _PhaseTask('앱 아이콘 & 스플래시 이미지'),
      _PhaseTask('성능 최적화', detail: 'MMKV 마이그레이션 · 메모리 관리'),
      _PhaseTask('테스트 & 배포', detail: 'Flutter test · App Store · Play Store'),
    ],
  ),
];

// ─── 메인 화면 ────────────────────────────────────────────────────────────────
class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.screenPadding,
              vertical: AppLayout.paddingMD,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < _phases.length) {
                    return _PhaseCard(
                      phase: _phases[index],
                      isLast: index == _phases.length - 1,
                    );
                  }
                  // 하단 총 기간 배지
                  return _TotalDurationBadge();
                },
                childCount: _phases.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '개발 로드맵',
          style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.screenPadding,
              80,
              AppLayout.screenPadding,
              AppLayout.paddingXL,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'OutSpoken 앱 · 5단계 Phase',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '총 7–10주 예상',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Phase 카드 ───────────────────────────────────────────────────────────────
class _PhaseCard extends StatefulWidget {
  final _PhaseData phase;
  final bool isLast;

  const _PhaseCard({required this.phase, required this.isLast});

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final phase = widget.phase;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타임라인 라인 + 번호 뱃지
          _TimelineColumn(
            number: phase.number,
            color: phase.color,
            isLast: widget.isLast,
          ),
          const SizedBox(width: AppLayout.paddingMD),

          // 카드 본문
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppLayout.paddingMD),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor(context),
                  borderRadius: BorderRadius.circular(AppLayout.radiusLG),
                  border: Border.all(
                    color: _expanded
                        ? phase.color.withValues(alpha: 0.4)
                        : AppColors.borderColor(context),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: phase.color.withValues(alpha: _expanded ? 0.08 : 0.0),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카드 헤더
                    _CardHeader(phase: phase, expanded: _expanded),

                    // 태스크 목록 (펼침)
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _TaskList(phase: phase),
                      crossFadeState: _expanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 250),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 타임라인 컬럼 ────────────────────────────────────────────────────────────
class _TimelineColumn extends StatelessWidget {
  final int number;
  final Color color;
  final bool isLast;

  const _TimelineColumn({
    required this.number,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          // 번호 뱃지
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'P$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // 연결선
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withValues(alpha: 0.6),
                      color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── 카드 헤더 ────────────────────────────────────────────────────────────────
class _CardHeader extends StatelessWidget {
  final _PhaseData phase;
  final bool expanded;

  const _CardHeader({required this.phase, required this.expanded});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppLayout.paddingMD),
      child: Row(
        children: [
          // 아이콘 컨테이너
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: phase.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppLayout.radiusSM),
            ),
            child: Icon(phase.icon, color: phase.color, size: AppLayout.iconSM + 2),
          ),
          const SizedBox(width: AppLayout.paddingMD),

          // 제목·부제목
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(phase.title, style: AppTextStyles.titleLarge),
                    const SizedBox(width: AppLayout.gapSM),
                    Text(
                      phase.subtitle,
                      style: AppTextStyles.caption.copyWith(color: phase.color),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.schedule_outlined,
                        size: 12, color: AppColors.textSecondaryColor(context)),
                    const SizedBox(width: 3),
                    Text(
                      phase.duration,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(width: AppLayout.gapSM),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: phase.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
                      ),
                      child: Text(
                        '${phase.tasks.length}개 작업',
                        style: AppTextStyles.caption.copyWith(color: phase.color),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 펼침 아이콘
          AnimatedRotation(
            turns: expanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondaryColor(context),
              size: AppLayout.iconMD,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 태스크 목록 ──────────────────────────────────────────────────────────────
class _TaskList extends StatelessWidget {
  final _PhaseData phase;

  const _TaskList({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: AppColors.borderColor(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppLayout.paddingMD,
            AppLayout.paddingMD,
            AppLayout.paddingMD,
            AppLayout.paddingMD,
          ),
          child: Column(
            children: phase.tasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < phase.tasks.length - 1 ? AppLayout.gapMD : 0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 체크 아이콘 (완료 스타일)
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: phase.color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        size: 11,
                        color: phase.color,
                      ),
                    ),
                    const SizedBox(width: AppLayout.gapMD),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.label, style: AppTextStyles.bodyMedium),
                          if (task.detail != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                task.detail!,
                                style: AppTextStyles.caption,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── 총 기간 배지 ─────────────────────────────────────────────────────────────
class _TotalDurationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: AppLayout.paddingSM,
        bottom: AppLayout.paddingXXL,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.paddingLG,
        vertical: AppLayout.paddingMD,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF6366F1)],
        ),
        borderRadius: BorderRadius.circular(AppLayout.radiusLG),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag_rounded, color: Colors.white, size: AppLayout.iconMD),
          const SizedBox(width: AppLayout.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '총 개발 기간',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '약 7 – 10주 예상',
                  style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppLayout.radiusCircle),
            ),
            child: Text(
              '5 Phase',
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
