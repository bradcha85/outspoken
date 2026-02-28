# 프로젝트 컨텍스트

이 문서는 화면별 코드 생성 시 AI 세션 간 맥락을 공유하기 위한 living document입니다.
각 화면 구현 완료 후 반드시 이 문서를 갱신해주세요.

## 설계 요약
설계 문서 작성이 완료되었습니다.

---

## 완료된 작업

**영어회화 학습 앱 "OutSpoken" 설계 문서 작성**

8개 섹션 모두 포함한 `DESIGN.md` 생성:

1. **기술 스택** — Expo (React Native) + TypeScript + Zustand + Claude API 조합 추천
2. **화면 목록** — 총 12개 화면 (Splash ~ Settings)
3. **UI 요소** — 각 화면별 구체적인 컴포넌트와 레이아웃 정의
4. **데이터 모델** — Phrase, Category, UserProgress, DailyRecord, ChatSession 5개 인터페이스
5. **상태 관리** — Zustand 스토어 4개 분리 (Phrase / Progress / Chat / Settings)
6. **폴더 구조** — Expo Router 기반 app/ 디렉토리 구조, 총 7개 최상위 폴더
7. **색상 팔레트** — 메인 12색 + 카테고리별 8색 + 다크모드 대응 정의
8. **개발 순서** — 5단계 Phase로 순차 개발 로드맵 (약 7~10주 예상)

## 변경된 파일
- `/Users/bccha/projects/app_1772117535286_20260226/DESIGN.md` (신규 생성)

## 주의사항
- AI Chat 기능은 Claude API 키 발급 후 Phase 4에서 구현
- TTS는 Expo 기본 제공이지만, STT(음성 입력)는 `expo-speech` 대신 서드파티 라이브러리 검토 필요 (`@react-native-voice/voice` 추천)
- 첫 릴리스 데이터는 정적 파일(80개 표현)로 시작하고, 이후 서버/CMS 연동 고려


## 실행 계획
실행 계획서 작성이 완료되었습니다.

---

**완료된 작업:**
`IMPLEMENTATION_PLAN.md` 파일을 신규 생성했습니다. 아래 구조로 작성되었습니다:

---

**변경된 파일:**
- `/Users/bccha/projects/app_1772117535286_20260226/IMPLEMENTATION_PLAN.md` (신규 생성)

---

**계획서 주요 내용 요약:**

### 1. 공통 모듈 (선행 구현)
| 모듈 | 파일 |
|------|------|
| 테마/색상 | `constants/colors.ts`, `typography.ts`, `layout.ts` |
| 라우터 | `app/_layout.tsx`, `app/(tabs)/_layout.tsx` |
| 데이터 모델 | `types/index.ts` + `data/` 정적 데이터 8개 파일 |
| 상태 관리 | `stores/` 4개 + `services/` 3개 |

### 2. 화면 구현 순서 (12개)
- **Phase 1**: Splash → Onboarding
- **Phase 2**: Home → Category → Phrase List → Phrase Detail → Favorites
- **Phase 3**: Practice → Quiz → Progress
- **Phase 4**: AI Chat
- **Phase 5**: Settings + 마무리

### 3. 주요 주의사항
1. Claude API 키는 `.env` 환경변수로 관리 (`.gitignore` 필수)
2. STT(`@react-native-voice/voice`)와 MMKV는 Expo Go 미지원 → `expo run:ios/android` 환경 필요
3. 공통 모듈을 반드시 먼저 구현해야 이후 화면 빌드 에러 방지


## 공통 모듈

### 상태 관리 (Provider 패턴)
Flutter에서 Zustand 역할 = `provider` 패키지의 `ChangeNotifier` + `MultiProvider`

| 스토어 | 클래스 | 파일 | 역할 | 초기화 |
|--------|--------|------|------|--------|
| Phrase | `PhraseProvider` | `lib/providers/phrase_provider.dart` | 표현/카테고리 목록, 검색·필터 상태, 현재 표현 | 즉시 (정적 데이터) |
| Progress | `ProgressProvider` | `lib/providers/progress_provider.dart` | 학습 진도, 즐겨찾기, 스트릭, 일별 기록 | `load()` (SharedPreferences) |
| Chat | `ChatProvider` | `lib/providers/chat_provider.dart` | AI 대화 세션, 메시지, 로딩/에러 상태 | 즉시 |
| Settings | `SettingsProvider` | `lib/providers/settings_provider.dart` | 레벨, 일별 목표, TTS 속도, 알림 설정 | `load()` (SharedPreferences) |

**등록 위치**: `lib/main.dart` → `MultiProvider`

**사용법 (화면에서 읽기)**:
```dart
final phraseProvider = context.watch<PhraseProvider>();
```

**사용법 (액션 호출, 리빌드 불필요)**:
```dart
context.read<ProgressProvider>().markPhraseAsLearned(id);
```

### 라우터
- 패키지: `go_router ^14.6.3`
- 파일: `lib/routes/app_router.dart`
- 초기 경로: `/splash`
- ShellRoute 적용 경로: `/home`, `/categories`, `/progress`, `/settings` (하단 탭 바)

### 색상 상수 & 테마
- 파일: `lib/constants/colors.dart` → `AppColors` 클래스
- 파일: `lib/constants/app_theme.dart` → `AppTheme` 클래스 (라이트/다크 `ThemeData`)

**메인 12색 (라이트)**
| 변수 | 값 | 용도 |
|------|----|------|
| `primary` | `#3B82F6` | Vivid Blue — 메인 버튼/액센트 |
| `primaryDark` | `#1D4ED8` | Deep Blue — 강조 |
| `secondary` | `#10B981` | Soft Emerald — 완료/성공 |
| `accent` | `#F59E0B` | Warm Amber — 즐겨찾기/포인트 |
| `error` | `#EF4444` | Coral Red — 오류 |
| `background` | `#F8FAFC` | Off White — 배경 |
| `surface` | `#FFFFFF` | 카드/시트 배경 |
| `surfaceAlt` | `#F1F5F9` | 입력창/섹션 배경 |
| `textPrimary` | `#1E293B` | 본문 텍스트 |
| `textSecondary` | `#64748B` | 보조 텍스트 |
| `textDisabled` | `#CBD5E1` | 비활성 텍스트 |
| `border` | `#E2E8F0` | 구분선/테두리 |

**다크모드 12색** — 변수명에 `dark` 접두어 (예: `darkPrimary`, `darkBackground`)

**카테고리 8색**
`catGreetings(Indigo)`, `catShopping(Pink)`, `catRestaurant(Orange)`, `catTravel(Cyan)`,
`catWorkplace(Purple)`, `catEmergency(Red)`, `catDaily(Emerald)`, `catEmotion(Amber)`

**컨텍스트 헬퍼 메서드** (자동 라이트/다크 전환):
```dart
AppColors.bg(context)             // 배경색
AppColors.surfaceColor(context)   // 카드 배경
AppColors.textPrimaryColor(context)
AppColors.primaryColor(context)
// 기타 동일 패턴
```

**테마 적용**: `AppTheme.light` / `AppTheme.dark` — `main.dart`에서 `Consumer<SettingsProvider>`로 `themeMode` 연동

**다크모드 전환**: `context.read<SettingsProvider>().setThemeMode(ThemeMode.dark)`

## 공유 위젯
(구현하면서 추가 — 위젯명, 파일 경로, 주요 props)

## 데이터 모델

| 클래스 | 파일 | 주요 필드 | 메서드 |
|--------|------|-----------|--------|
| `Difficulty` (enum) | `lib/models/phrase.dart` | `beginner, intermediate, advanced` | - |
| `Example` | `lib/models/phrase.dart` | `english, korean` | `fromJson, toJson` |
| `Phrase` | `lib/models/phrase.dart` | `id, english, korean, pronunciation, categoryId, examples, difficulty, tags` | `fromJson, toJson` |
| `Category` | `lib/models/category.dart` | `id, name, nameEn, icon(IconData), color(Color), phraseCount` | `copyWith` |
| `DailyRecord` | `lib/models/user_progress.dart` | `date(YYYY-MM-DD), phrasesLearned, quizScore, studyMinutes` | `fromJson, toJson, copyWith` |
| `UserProgress` | `lib/models/user_progress.dart` | `userId, level(Difficulty), learnedPhraseIds, favoritePhraseIds, streakDays, lastStudyDate, dailyGoal, totalStudyMinutes` | `fromJson, toJson, copyWith, initial()` |
| `ChatMessage` | `lib/models/user_progress.dart` | `role('user'/'assistant'), content, feedback?, timestamp(DateTime)` | `fromJson, toJson, copyWith` |
| `ChatSession` | `lib/models/user_progress.dart` | `id, scenario, messages, createdAt(DateTime)` | `fromJson, toJson, copyWith` |

**주의**: `Category`는 정적 데이터(`lib/data/categories_data.dart`)로만 사용되어 fromJson/toJson 없음. icon/color는 Flutter 타입 직접 사용.

## 완료된 화면

| 화면 | 파일 | 사용한 모듈 | 비고 |
|------|------|-------------|------|
| 데이터 모델 | `lib/models/phrase.dart`, `lib/models/category.dart`, `lib/models/user_progress.dart` | - | Phrase, Category, UserProgress, DailyRecord, ChatSession 5개 완성 |
| 상태 관리 (4개 Provider) | `lib/providers/phrase_provider.dart`<br>`lib/providers/progress_provider.dart`<br>`lib/providers/chat_provider.dart`<br>`lib/providers/settings_provider.dart` | models, data, SharedPreferences | `MultiProvider`로 `main.dart`에 등록. Progress·Settings는 앱 시작 시 `load()` 자동 호출 |
| 색상 팔레트 & 다크모드 | `lib/constants/colors.dart`<br>`lib/constants/app_theme.dart`<br>`lib/providers/settings_provider.dart`<br>`lib/main.dart` | AppColors, AppTheme, SettingsProvider | 메인12색+다크12색+카테고리8색 정의. `SettingsProvider.themeMode`로 런타임 전환 지원 |
| 개발 로드맵 (Roadmap) | `lib/screens/roadmap_screen.dart` | AppColors, AppTextStyles, AppLayout | Provider 의존성 없음. 정적 데이터만 사용. SliverAppBar + 타임라인 카드 UI. 탭 토글로 태스크 목록 펼침 지원 |
