# OutSpoken — 코드 구현 실행 계획서

> 작성일: 2026-02-27
> 참조: DESIGN.md, ui-design.html
> 예상 기간: 7~10주 (Phase 1~5)

---

## 실행 계획서

---

### 1. 공통 모듈 (먼저 구현)

공통 모듈은 모든 화면에서 의존하므로 **최우선 구현** 대상입니다.

#### 1-1. 테마 / 색상

| 파일 경로 | 내용 |
|-----------|------|
| `constants/colors.ts` | 메인 팔레트 12색 + 카테고리 8색 + 다크모드 토큰 |
| `constants/typography.ts` | 폰트 사이즈, 웨이트, 라인하이트 스케일 |
| `constants/layout.ts` | spacing, borderRadius, shadow 프리셋 |

```typescript
// constants/colors.ts — 핵심 토큰 예시
export const Colors = {
  primary:       '#3B82F6',
  primaryDark:   '#1D4ED8',
  secondary:     '#10B981',
  accent:        '#F59E0B',
  error:         '#EF4444',
  bg:            '#F8FAFC',
  surface:       '#FFFFFF',
  surfaceAlt:    '#F1F5F9',
  textPrimary:   '#1E293B',
  textSecondary: '#64748B',
  textDisabled:  '#CBD5E1',
  border:        '#E2E8F0',
  // 카테고리
  catGreet:  '#6366F1',
  catShop:   '#EC4899',
  catRest:   '#F97316',
  catTravel: '#06B6D4',
  catWork:   '#8B5CF6',
  catEmerg:  '#EF4444',
  catDaily:  '#10B981',
  catEmotion:'#F59E0B',
} as const;
```

---

#### 1-2. 라우터 설정

| 파일 경로 | 내용 |
|-----------|------|
| `app/_layout.tsx` | Root Layout — Expo Router + 탭/스택 중첩 설정 |
| `app/(tabs)/_layout.tsx` | 하단 탭 4개 (Home / Category / Progress / Settings) |
| `app/onboarding.tsx` | 최초 진입 여부 판단 후 분기 |

**라우팅 구조 다이어그램**
```
_layout.tsx (Root Stack)
├── onboarding.tsx              ← 최초 1회
├── (tabs)/_layout.tsx          ← 메인 탭
│   ├── index.tsx               (Home)
│   ├── categories.tsx          (Category)
│   ├── progress.tsx            (Progress)
│   └── settings.tsx            (Settings)
├── category/[id].tsx           ← Phrase List (Stack)
├── phrase/[id].tsx             ← Phrase Detail (Stack)
├── phrase/practice.tsx         ← Practice (Stack)
├── quiz.tsx                    ← Quiz (Stack)
├── chat.tsx                    ← AI Chat (Stack)
└── favorites.tsx               ← Favorites (Stack)
```

**의존 패키지 (설치 필요)**
```bash
npx expo install expo-router react-native-safe-area-context \
  react-native-screens @react-navigation/bottom-tabs
```

---

#### 1-3. 데이터 모델

| 파일 경로 | 내용 |
|-----------|------|
| `types/index.ts` | 모든 TypeScript 인터페이스 정의 |
| `data/categories.ts` | 카테고리 6개 정적 배열 |
| `data/phrases/greetings.ts` | 인사/소개 15개 표현 |
| `data/phrases/shopping.ts` | 쇼핑 10개 표현 |
| `data/phrases/restaurant.ts` | 식당 15개 표현 |
| `data/phrases/travel.ts` | 여행 15개 표현 |
| `data/phrases/workplace.ts` | 직장 15개 표현 |
| `data/phrases/emergency.ts` | 긴급상황 10개 표현 |
| `data/scenarios.ts` | AI 채팅 시나리오 목록 |

```typescript
// types/index.ts — 핵심 인터페이스
export interface Phrase {
  id: string;
  english: string;
  korean: string;
  pronunciation: string;
  categoryId: string;
  examples: { english: string; korean: string }[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  tags: string[];
}

export interface Category {
  id: string;
  name: string;       // 한국어
  nameEn: string;     // 영어
  icon: string;       // Ionicon name
  color: string;      // hex
  phraseCount: number;
}

export interface UserProgress {
  userId: string;
  level: 'beginner' | 'intermediate' | 'advanced';
  learnedPhraseIds: string[];
  favoritePhraseIds: string[];
  streakDays: number;
  lastStudyDate: string;
  dailyGoal: number;
  totalStudyMinutes: number;
}

export interface DailyRecord {
  date: string;
  phrasesLearned: number;
  quizScore: number;
  studyMinutes: number;
}

export interface ChatSession {
  id: string;
  scenario: string;
  messages: ChatMessage[];
  createdAt: string;
}

export interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
  feedback?: string;
  timestamp: string;
}
```

---

#### 1-4. 상태 관리

| 파일 경로 | 담당 스토어 | 의존 |
|-----------|------------|------|
| `stores/usePhraseStore.ts` | 표현 데이터, 카테고리, 검색/필터 | `types`, `data/` |
| `stores/useProgressStore.ts` | 학습 진도, 스트릭, 즐겨찾기 | `types`, `services/storage` |
| `stores/useChatStore.ts` | AI 채팅 세션, 메시지 | `types`, `services/claudeApi` |
| `stores/useSettingsStore.ts` | 레벨, 목표, 음성속도, 알림 | `services/storage` |
| `services/storage.ts` | AsyncStorage/MMKV 래퍼 | — |
| `services/claudeApi.ts` | Claude API 클라이언트 | — |
| `services/notifications.ts` | 로컬 푸시 알림 | — |

```bash
# 패키지 설치
npx expo install zustand @react-native-async-storage/async-storage
npm install react-native-mmkv
```

---

### 2. 화면별 구현 순서

> 의존 그래프 기준 상위 → 하위 순서로 구현합니다.

---

#### [Phase 1] 기반 화면

---

##### 화면 1 — Splash Screen
- **파일**: `app/index.tsx` (혹은 `app/splash.tsx`)
- **의존 모듈**: `constants/colors`, `constants/typography`, Expo Reanimated
- **주요 위젯/기능**:
  - 중앙 로고 + 앱명 `OutSpoken`
  - 타이핑 텍스트 애니메이션 (Reanimated 또는 간단한 setInterval)
  - ProgressBar (가짜 로딩 1.5초 후 Onboarding 또는 Home 분기)
  - `useProgressStore`에서 최초 실행 여부 확인

```bash
npx expo install react-native-reanimated
```

---

##### 화면 2 — Onboarding Screen
- **파일**: `app/onboarding.tsx`
- **의존 모듈**: `stores/useSettingsStore`, `constants/colors`, `components/common/Button`, `components/common/Card`
- **주요 위젯/기능**:
  - 레벨 선택 카드 3개 (초급 / 중급 / 고급) — 탭 시 선택 강조
  - 각 카드에 아이콘 + 설명 텍스트
  - "시작하기" 버튼 → `useSettingsStore.setLevel()` 호출 후 `(tabs)` 이동
  - 선택 완료 여부를 `storage`에 영구 저장

---

#### [Phase 2] 핵심 학습 화면

---

##### 화면 3 — Home Screen
- **파일**: `app/(tabs)/index.tsx`
- **의존 모듈**: `stores/useProgressStore`, `stores/usePhraseStore`, `components/common/ProgressBar`, `components/progress/StreakBadge`, `components/phrase/PhraseCard`
- **주요 위젯/기능**:
  - 상단: 스트릭 배지 (`StreakBadge`) + 현재 날짜
  - 일일 목표 진행 바 (`ProgressBar`) — `todayLearned / dailyGoal`
  - "오늘의 표현" 카드 — 랜덤 Phrase 1개 (`PhraseCard`)
  - 빠른 시작 버튼 → 마지막 카테고리로 이동
  - 카테고리 바로가기 그리드 4개 (FlatList 2열)

---

##### 화면 4 — Category Screen
- **파일**: `app/(tabs)/categories.tsx`
- **의존 모듈**: `stores/usePhraseStore`, `stores/useProgressStore`, `components/common/SearchBar`, `data/categories`
- **주요 위젯/기능**:
  - SearchBar — `usePhraseStore.searchPhrases()` 연동
  - FlatList 2열 그리드 — 카테고리 카드 (아이콘, 이름, 표현 수, 완료율)
  - 카테고리별 완료율: `learnedPhraseIds` 기반 계산
  - 카드 탭 → `category/[id]` 이동

---

##### 화면 5 — Phrase List Screen
- **파일**: `app/category/[id].tsx`
- **의존 모듈**: `stores/usePhraseStore`, `stores/useProgressStore`, `components/phrase/PhraseListItem`
- **주요 위젯/기능**:
  - 헤더: 카테고리명 + 진행률
  - FlatList — `PhraseListItem` (영어 + 한국어, 즐겨찾기 버튼, 완료 체크)
  - 정렬 옵션 (난이도순 / 학습순)
  - 항목 탭 → `phrase/[id]` 이동
  - 즐겨찾기 → `useProgressStore.toggleFavorite()` 호출

---

##### 화면 6 — Phrase Detail Screen
- **파일**: `app/phrase/[id].tsx`
- **의존 모듈**: `stores/usePhraseStore`, `stores/useProgressStore`, `hooks/useSpeech`, `components/phrase/AudioPlayer`, `components/common/Button`
- **주요 위젯/기능**:
  - 대형 영어 표현 텍스트
  - 한국어 번역, 발음 기호 (IPA)
  - 음성 재생 버튼 (`useSpeech` → `expo-speech`)
  - 예문 2~3개 카드 (영어 + 한국어)
  - 따라 말하기 버튼 (녹음 트리거) + 파형 시각화
  - 이전/다음 버튼 — 동일 카테고리 내 이동
  - 학습 완료 시 `markPhraseAsLearned()` 호출

```bash
npx expo install expo-speech expo-av
```

---

##### 화면 11 — Favorites Screen
- **파일**: `app/favorites.tsx`
- **의존 모듈**: `stores/useProgressStore`, `stores/usePhraseStore`, `components/phrase/PhraseListItem`
- **주요 위젯/기능**:
  - 즐겨찾기 표현 FlatList (스와이프로 해제 — `react-native-gesture-handler`)
  - 빈 상태 메시지 (즐겨찾기 없을 때)
  - "즐겨찾기 퀴즈 시작" 버튼 → `quiz.tsx`로 이동 (favorites 모드 파라미터 전달)

```bash
npx expo install react-native-gesture-handler
```

---

#### [Phase 3] 연습 화면

---

##### 화면 7 — Practice Screen
- **파일**: `app/phrase/practice.tsx`
- **의존 모듈**: `stores/usePhraseStore`, `hooks/useSpeech`, `components/phrase/AudioPlayer`, Reanimated (카드 flip)
- **주요 위젯/기능**:
  - 상단 탭: 플래시카드 / 받아쓰기 / 말하기 모드
  - **플래시카드**: 카드 탭 시 3D flip 애니메이션 (앞=영어, 뒤=한국어)
  - 진행 표시 (3/10)
  - "알았어요 / 모르겠어요" 버튼 — 결과 기록 후 다음 카드
  - **받아쓰기**: TextInput 입력 → 정답 비교
  - **말하기**: 녹음 후 TTS와 비교 (Phase 4에서 고도화)

---

##### 화면 9 — Quiz Screen
- **파일**: `app/quiz.tsx`
- **의존 모듈**: `hooks/useQuiz`, `stores/useProgressStore`, `components/quiz/MultipleChoice`, `components/quiz/FillBlank`, `components/quiz/ResultCard`
- **주요 위젯/기능**:
  - 상단 진행 바 + 문제 번호
  - 문제 유형 3종 (객관식 / 빈칸 채우기 / 듣고 고르기)
  - 정답/오답 즉각 피드백 (컬러 + Reanimated shake/bounce)
  - 결과 화면: 점수 + 틀린 문제 목록 + "다시 도전" 버튼
  - `useProgressStore.recordDailyStudy()` 로 점수 기록

```typescript
// hooks/useQuiz.ts — 퀴즈 로직
// - 문제 셔플 (Fisher-Yates)
// - 오답 보기 생성 (동일 카테고리 내 랜덤)
// - 점수 집계
```

---

##### 화면 10 — Progress Screen
- **파일**: `app/(tabs)/progress.tsx`
- **의존 모듈**: `stores/useProgressStore`, `hooks/useStreak`, `components/progress/WeeklyChart`, `components/progress/DonutChart`, `components/progress/StreakBadge`
- **주요 위젯/기능**:
  - 통계 헤더: 총 학습 표현 수 / 완료율 / 연속 학습일
  - 주간 막대 그래프 (`WeeklyChart`) — 최근 7일 학습량
  - 카테고리별 달성률 도넛 차트 (`DonutChart`)
  - 획득 배지 목록 (스트릭 7일/30일, 카테고리 완주 등)

```bash
# 차트 라이브러리 (택 1)
npm install react-native-gifted-charts
# 또는 react-native-svg 기반 직접 구현
npx expo install react-native-svg
```

---

#### [Phase 4] AI 대화 화면

---

##### 화면 8 — AI Chat Screen
- **파일**: `app/chat.tsx`
- **의존 모듈**: `stores/useChatStore`, `hooks/useClaudeChat`, `services/claudeApi`, `components/chat/ChatBubble`, `components/chat/FeedbackChip`, `components/chat/VoiceInput`
- **주요 위젯/기능**:
  - 상단: 시나리오 설명 배너 (예: "당신은 카페에 있습니다")
  - FlatList — 채팅 말풍선 (`ChatBubble`, user/assistant 구분)
  - AI 피드백 칩 (`FeedbackChip`) — 문법 교정, 자연스러운 표현 제안
  - 힌트 보기 버튼 (접이식)
  - 하단: TextInput + 음성 입력 버튼 (`VoiceInput`)
  - Claude API 스트리밍 응답 처리 (`services/claudeApi`)

```typescript
// services/claudeApi.ts
// - Anthropic SDK 사용
// - 시스템 프롬프트: 영어 회화 코치 역할
// - 문법 피드백을 JSON으로 파싱하여 FeedbackChip에 표시
// - 환경변수: EXPO_PUBLIC_CLAUDE_API_KEY
```

```bash
npm install @anthropic-ai/sdk
# STT (음성 입력)
npm install @react-native-voice/voice
```

---

#### [Phase 5] 마무리 화면

---

##### 화면 12 — Settings Screen
- **파일**: `app/(tabs)/settings.tsx`
- **의존 모듈**: `stores/useSettingsStore`, `services/notifications`, `hooks/useSpeech`
- **주요 위젯/기능**:
  - 일일 학습 목표 선택 (5 / 10 / 20) — 라디오 버튼
  - 학습 알림 시간 설정 — TimePicker
  - 학습 레벨 변경 — 선택 시 `useSettingsStore.setLevel()` 호출
  - 음성 속도 슬라이더 (0.5 ~ 1.5) — `useSpeech` 훅에 반영
  - 앱 정보 / 피드백 링크

```bash
npx expo install expo-notifications
```

---

### 3. 통합 및 검증

#### 3-1. 네비게이션 연결 체크리스트

| 출발 화면 | 도착 화면 | 파라미터 |
|-----------|-----------|---------|
| Splash | Onboarding or Home | isFirstLaunch |
| Onboarding | Home | — |
| Home | Category/[id] | categoryId |
| Home | Phrase/[id] | phraseId |
| Category List | Category/[id] | categoryId |
| Phrase List | Phrase/[id] | phraseId |
| Phrase Detail | Practice | categoryId, startIndex |
| Home | Quiz | mode: 'daily' |
| Favorites | Quiz | mode: 'favorites', phraseIds |
| Tab Bar | Chat | — |
| Tab Bar | Favorites | — |

#### 3-2. 상태 연결 체크리스트

- [ ] `usePhraseStore` — 앱 시작 시 `data/` 정적 데이터 로드
- [ ] `useProgressStore` — AsyncStorage에서 학습 기록 복원
- [ ] `useSettingsStore` — MMKV에서 설정 복원 (빠른 동기 읽기)
- [ ] `useStreak` 훅 — 앱 포그라운드 진입 시 날짜 비교 후 스트릭 업데이트

#### 3-3. 전체 빌드 확인 순서

```bash
# 1. 의존성 설치 확인
npx expo install

# 2. TypeScript 타입 체크
npx tsc --noEmit

# 3. 개발 서버 실행
npx expo start

# 4. iOS 시뮬레이터
npx expo run:ios

# 5. Android 에뮬레이터
npx expo run:android

# 6. 프로덕션 빌드 (EAS)
eas build --platform all --profile preview
```

#### 3-4. 공통 컴포넌트 구현 우선순위

| 컴포넌트 | 파일 경로 | Phase |
|----------|-----------|-------|
| Button | `components/common/Button.tsx` | 1 |
| Card | `components/common/Card.tsx` | 1 |
| Badge | `components/common/Badge.tsx` | 1 |
| ProgressBar | `components/common/ProgressBar.tsx` | 1 |
| SearchBar | `components/common/SearchBar.tsx` | 1 |
| PhraseCard | `components/phrase/PhraseCard.tsx` | 2 |
| PhraseListItem | `components/phrase/PhraseListItem.tsx` | 2 |
| AudioPlayer | `components/phrase/AudioPlayer.tsx` | 2 |
| StreakBadge | `components/progress/StreakBadge.tsx` | 2 |
| WeeklyChart | `components/progress/WeeklyChart.tsx` | 3 |
| DonutChart | `components/progress/DonutChart.tsx` | 3 |
| MultipleChoice | `components/quiz/MultipleChoice.tsx` | 3 |
| FillBlank | `components/quiz/FillBlank.tsx` | 3 |
| ResultCard | `components/quiz/ResultCard.tsx` | 3 |
| ChatBubble | `components/chat/ChatBubble.tsx` | 4 |
| FeedbackChip | `components/chat/FeedbackChip.tsx` | 4 |
| VoiceInput | `components/chat/VoiceInput.tsx` | 4 |

---

### 4. 패키지 설치 전체 목록

```bash
# 필수 (Phase 1)
npx expo install expo-router react-native-safe-area-context \
  react-native-screens @react-navigation/bottom-tabs \
  react-native-reanimated zustand \
  @react-native-async-storage/async-storage

# 음성 (Phase 2)
npx expo install expo-speech expo-av

# 제스처 (Phase 2~3)
npx expo install react-native-gesture-handler

# 차트 (Phase 3)
npx expo install react-native-svg
npm install react-native-gifted-charts

# AI / STT (Phase 4)
npm install @anthropic-ai/sdk @react-native-voice/voice

# 알림 (Phase 5)
npx expo install expo-notifications

# MMKV (Phase 1)
npm install react-native-mmkv
```

---

## 완료된 작업

- `IMPLEMENTATION_PLAN.md` 실행 계획서 신규 작성

## 변경된 파일

- `/Users/bccha/projects/app_1772117535286_20260226/IMPLEMENTATION_PLAN.md` (신규 생성)

## 주의사항

1. **Claude API 키**: `EXPO_PUBLIC_CLAUDE_API_KEY` 환경변수로 관리, `.env` 파일은 `.gitignore`에 추가
2. **STT 라이브러리**: `@react-native-voice/voice`는 Expo Go 미지원 → `expo run:ios/android` 필요
3. **MMKV**: Expo Go 미지원 → 개발 초기에는 AsyncStorage로 대체 후 나중에 교체
4. **차트 라이브러리**: `react-native-gifted-charts`는 `react-native-svg` 선행 설치 필수
5. **NativeWind**: `tailwind.config.js` + `babel.config.js` 설정 필요 (`nativewind/babel` 플러그인)
6. **Phase 순서 준수**: 공통 모듈 → Phase 1 → Phase 2 순으로 진행해야 빌드 에러 최소화
7. **데이터 파일**: 정적 표현 데이터(80개)는 Phase 1에서 모두 작성해두면 이후 화면 개발 시 실제 데이터로 테스트 가능
