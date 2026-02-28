# 영어회화 학습 앱 설계 문서

> **앱 이름**: OutSpoken - 영어회화 연습
> **목적**: 일상적인 영어 회화 표현을 쉽고 재미있게 학습

---

## 1. 추천 기술 스택

| 분류 | 기술 | 이유 |
|------|------|------|
| 프레임워크 | React Native (Expo) | 단일 코드베이스로 iOS/Android 동시 지원, 빠른 개발 |
| 언어 | TypeScript | 타입 안정성, 유지보수 용이 |
| 상태 관리 | Zustand | 가볍고 직관적, 보일러플레이트 최소 |
| 네비게이션 | React Navigation v7 (Stack + Tab) | Expo와 완벽 호환 |
| 스타일 | NativeWind (Tailwind CSS) | 빠른 UI 구성 |
| 음성 | expo-speech (TTS) + expo-av (녹음) | 발음 듣기 및 따라 말하기 |
| 로컬 DB | AsyncStorage + MMKV | 학습 진도 저장 |
| AI 연동 | Anthropic Claude API | 대화 연습 및 피드백 |
| 애니메이션 | React Native Reanimated 3 | 자연스러운 전환 효과 |
| 아이콘 | Expo Vector Icons (Ionicons) | 풍부한 아이콘 세트 |

---

## 2. 화면 목록 (Screen List)

```
1. Splash Screen          - 앱 시작 로딩
2. Onboarding Screen      - 레벨 선택 (초급/중급/고급)
3. Home Screen            - 오늘의 학습 대시보드
4. Category Screen        - 주제별 회화 카테고리 목록
5. Phrase List Screen     - 선택 주제의 표현 목록
6. Phrase Detail Screen   - 표현 상세 (뜻, 발음, 예문)
7. Practice Screen        - 표현 연습 (듣기/따라하기)
8. AI Chat Screen         - AI와 실전 대화 연습
9. Quiz Screen            - 오늘 배운 표현 퀴즈
10. Progress Screen       - 학습 통계 및 진도
11. Favorites Screen      - 저장한 표현 모음
12. Settings Screen       - 알림, 학습 목표, 언어 설정
```

---

## 3. 각 화면의 주요 UI 요소

### 3.1 Splash Screen
- 앱 로고 (중앙)
- 영어 문장 애니메이션 타이핑 효과
- 진행 표시줄

### 3.2 Onboarding Screen
- 환영 메시지
- 3단계 레벨 선택 카드 (초급 / 중급 / 고급)
- 각 레벨별 간단한 설명
- "시작하기" 버튼

### 3.3 Home Screen
- 상단: 현재 연속 학습일 (Streak) 배지
- 오늘의 학습 목표 진행 바 (예: 5/10 표현)
- "오늘의 표현" 카드 (랜덤 1개)
- 빠른 시작 버튼 (오늘 학습 계속하기)
- 하단: 카테고리 바로가기 그리드 (4개)

### 3.4 Category Screen
- 검색 바
- 카테고리 그리드 카드 (아이콘 + 이름 + 표현 수)
  - 인사/소개, 쇼핑, 식당, 여행, 직장, 긴급상황 등
- 각 카드에 학습 완료율 표시

### 3.5 Phrase List Screen
- 카테고리명 헤더
- 표현 목록 (한국어 뜻 + 영어 표현)
- 각 항목: 즐겨찾기 버튼, 완료 체크 표시
- 정렬/필터 옵션

### 3.6 Phrase Detail Screen
- 영어 표현 (대형 텍스트)
- 한국어 번역
- 발음 기호 (IPA)
- 음성 재생 버튼 (TTS)
- 예문 2~3개
- 따라 말하기 버튼 (녹음 + 파형 시각화)
- 이전/다음 표현 네비게이션

### 3.7 Practice Screen
- 학습 모드 탭 (플래시카드 / 받아쓰기 / 말하기)
- 플래시카드: 앞면(영어) 뒤집으면 한국어
- 진행 표시 (3/10)
- 알았어요 / 모르겠어요 버튼

### 3.8 AI Chat Screen
- 상단: 상황 설명 (예: "당신은 카페에 있습니다")
- 채팅 말풍선 UI (사용자/AI)
- 하단: 텍스트 입력 + 음성 입력 버튼
- AI 피드백 칩 (문법 교정, 자연스러운 표현 제안)
- 힌트 보기 버튼

### 3.9 Quiz Screen
- 진행 바 + 문제 번호
- 문제 유형: 객관식 / 빈칸 채우기 / 듣고 고르기
- 정답/오답 즉각 피드백 (애니메이션)
- 결과 화면: 점수 + 틀린 문제 복습

### 3.10 Progress Screen
- 주간/월간 학습 그래프 (막대 차트)
- 학습 통계 (총 표현 수, 완료율, 연속 학습일)
- 카테고리별 달성률 도넛 차트
- 획득 배지 목록

### 3.11 Favorites Screen
- 즐겨찾기한 표현 리스트
- 스와이프로 즐겨찾기 해제
- 즐겨찾기 전용 퀴즈 시작 버튼

### 3.12 Settings Screen
- 일일 학습 목표 설정 (5 / 10 / 20 표현)
- 학습 알림 시간 설정
- 학습 레벨 변경
- 음성 속도 조절 (슬라이더)
- 앱 정보 / 피드백

---

## 4. 데이터 모델

```typescript
// 표현(Phrase) 모델
interface Phrase {
  id: string;
  english: string;           // 영어 표현
  korean: string;            // 한국어 번역
  pronunciation: string;     // 발음 기호
  categoryId: string;
  examples: Example[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  tags: string[];
}

interface Example {
  english: string;
  korean: string;
}

// 카테고리 모델
interface Category {
  id: string;
  name: string;              // 한국어 이름
  nameEn: string;            // 영어 이름
  icon: string;              // Ionicon 이름
  color: string;             // 카드 배경 hex
  phraseCount: number;
}

// 사용자 학습 진도
interface UserProgress {
  userId: string;
  level: 'beginner' | 'intermediate' | 'advanced';
  learnedPhraseIds: string[];
  favoritePhraseIds: string[];
  streakDays: number;
  lastStudyDate: string;     // ISO 8601
  dailyGoal: number;         // 일일 목표 표현 수
  totalStudyMinutes: number;
}

// 일일 학습 기록
interface DailyRecord {
  date: string;              // YYYY-MM-DD
  phrasesLearned: number;
  quizScore: number;         // 0-100
  studyMinutes: number;
}

// AI 채팅 세션
interface ChatSession {
  id: string;
  scenario: string;          // 상황 설명
  messages: ChatMessage[];
  createdAt: string;
}

interface ChatMessage {
  role: 'user' | 'assistant';
  content: string;
  feedback?: string;         // AI 문법 피드백
  timestamp: string;
}
```

---

## 5. 상태 관리 구조

Zustand 스토어를 기능별로 분리:

```typescript
// stores/usePhraseStore.ts
interface PhraseStore {
  phrases: Phrase[];
  categories: Category[];
  currentPhrase: Phrase | null;
  filteredPhrases: Phrase[];
  setCurrentPhrase: (phrase: Phrase) => void;
  filterByCategory: (categoryId: string) => void;
  searchPhrases: (query: string) => void;
}

// stores/useProgressStore.ts
interface ProgressStore {
  progress: UserProgress;
  dailyRecords: DailyRecord[];
  todayLearned: number;
  isGoalCompleted: boolean;
  markPhraseAsLearned: (phraseId: string) => void;
  toggleFavorite: (phraseId: string) => void;
  updateStreak: () => void;
  recordDailyStudy: (minutes: number, score: number) => void;
}

// stores/useChatStore.ts
interface ChatStore {
  sessions: ChatSession[];
  currentSession: ChatSession | null;
  isLoading: boolean;
  startNewSession: (scenario: string) => void;
  sendMessage: (content: string) => Promise<void>;
  clearCurrentSession: () => void;
}

// stores/useSettingsStore.ts
interface SettingsStore {
  level: 'beginner' | 'intermediate' | 'advanced';
  dailyGoal: number;
  notificationTime: string | null;
  speechRate: number;        // 0.5 ~ 1.5
  setLevel: (level: string) => void;
  setDailyGoal: (goal: number) => void;
  setSpeechRate: (rate: number) => void;
}
```

---

## 6. 폴더 구조

```
speakup/
├── app/                        # Expo Router 기반 파일 라우팅
│   ├── (tabs)/
│   │   ├── index.tsx           # Home
│   │   ├── categories.tsx      # Categories
│   │   ├── progress.tsx        # Progress
│   │   └── settings.tsx        # Settings
│   ├── phrase/
│   │   ├── [id].tsx            # Phrase Detail
│   │   └── practice.tsx        # Practice
│   ├── category/
│   │   └── [id].tsx            # Phrase List
│   ├── quiz.tsx                # Quiz
│   ├── chat.tsx                # AI Chat
│   ├── favorites.tsx           # Favorites
│   ├── onboarding.tsx          # Onboarding
│   └── _layout.tsx
│
├── components/
│   ├── common/
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Badge.tsx
│   │   ├── ProgressBar.tsx
│   │   └── SearchBar.tsx
│   ├── phrase/
│   │   ├── PhraseCard.tsx
│   │   ├── PhraseListItem.tsx
│   │   └── AudioPlayer.tsx
│   ├── chat/
│   │   ├── ChatBubble.tsx
│   │   ├── FeedbackChip.tsx
│   │   └── VoiceInput.tsx
│   ├── progress/
│   │   ├── StreakBadge.tsx
│   │   ├── WeeklyChart.tsx
│   │   └── DonutChart.tsx
│   └── quiz/
│       ├── MultipleChoice.tsx
│       ├── FillBlank.tsx
│       └── ResultCard.tsx
│
├── stores/
│   ├── usePhraseStore.ts
│   ├── useProgressStore.ts
│   ├── useChatStore.ts
│   └── useSettingsStore.ts
│
├── data/
│   ├── categories.ts           # 카테고리 정적 데이터
│   ├── phrases/
│   │   ├── greetings.ts        # 인사/소개 표현
│   │   ├── shopping.ts         # 쇼핑 표현
│   │   ├── restaurant.ts       # 식당 표현
│   │   ├── travel.ts           # 여행 표현
│   │   ├── workplace.ts        # 직장 표현
│   │   └── emergency.ts        # 긴급상황 표현
│   └── scenarios.ts            # AI 채팅 시나리오 목록
│
├── hooks/
│   ├── useSpeech.ts            # TTS/STT 훅
│   ├── useQuiz.ts              # 퀴즈 로직 훅
│   ├── useStreak.ts            # 연속 학습 계산 훅
│   └── useClaudeChat.ts        # Claude API 연동 훅
│
├── services/
│   ├── claudeApi.ts            # Claude API 클라이언트
│   ├── storage.ts              # AsyncStorage/MMKV 래퍼
│   └── notifications.ts        # 푸시 알림 서비스
│
├── constants/
│   ├── colors.ts               # 색상 팔레트
│   ├── typography.ts           # 폰트 스타일
│   └── layout.ts               # 공통 레이아웃 값
│
├── types/
│   └── index.ts                # TypeScript 인터페이스
│
├── utils/
│   ├── dateUtils.ts
│   └── phraseUtils.ts
│
├── assets/
│   ├── images/
│   └── animations/             # Lottie 파일
│
├── app.json
├── package.json
├── tsconfig.json
└── babel.config.js
```

---

## 7. 색상 팔레트

### 메인 팔레트 — "Fresh & Motivating"

| 역할 | 색상명 | Hex | 사용처 |
|------|--------|-----|--------|
| Primary | Vivid Blue | `#3B82F6` | 주요 버튼, 탭 아이콘 활성 |
| Primary Dark | Deep Blue | `#1D4ED8` | 버튼 프레스 상태 |
| Secondary | Soft Emerald | `#10B981` | 완료/정답 피드백, 스트릭 배지 |
| Accent | Warm Amber | `#F59E0B` | 즐겨찾기, 배지, 경고 |
| Error | Coral Red | `#EF4444` | 오답 피드백, 에러 |
| Background | Off White | `#F8FAFC` | 앱 전체 배경 |
| Surface | Pure White | `#FFFFFF` | 카드, 모달 배경 |
| Surface Alt | Light Gray | `#F1F5F9` | 비활성 카드, 입력 배경 |
| Text Primary | Charcoal | `#1E293B` | 메인 텍스트 |
| Text Secondary | Cool Gray | `#64748B` | 부가 텍스트, 힌트 |
| Text Disabled | Light Gray | `#CBD5E1` | 비활성 텍스트 |
| Border | Soft Gray | `#E2E8F0` | 구분선, 테두리 |

### 카테고리별 컬러

| 카테고리 | Hex | 설명 |
|----------|-----|------|
| 인사/소개 | `#6366F1` | 인디고 |
| 쇼핑 | `#EC4899` | 핑크 |
| 식당 | `#F97316` | 오렌지 |
| 여행 | `#06B6D4` | 시안 |
| 직장 | `#8B5CF6` | 퍼플 |
| 긴급상황 | `#EF4444` | 레드 |
| 일상대화 | `#10B981` | 에메랄드 |
| 감정표현 | `#F59E0B` | 앰버 |

### 다크모드 대응 (선택사항)

| 역할 | Light | Dark |
|------|-------|------|
| Background | `#F8FAFC` | `#0F172A` |
| Surface | `#FFFFFF` | `#1E293B` |
| Text Primary | `#1E293B` | `#F1F5F9` |
| Text Secondary | `#64748B` | `#94A3B8` |

---

## 8. 개발 순서

### Phase 1 — 기반 구축 (1~2주)
1. Expo 프로젝트 초기 설정 (TypeScript, NativeWind)
2. React Navigation 구조 설정 (Tab + Stack)
3. 색상 팔레트, 타이포그래피 상수 정의
4. 공통 컴포넌트 작성 (Button, Card, ProgressBar)
5. Zustand 스토어 스켈레톤 작성
6. 정적 데이터 작성 (카테고리 6개, 각 10개 표현)

### Phase 2 — 핵심 학습 기능 (2~3주)
7. Onboarding (레벨 선택) 화면
8. Home 대시보드 화면
9. Category 목록 화면
10. Phrase List 화면
11. Phrase Detail 화면 (TTS 연동 포함)
12. 즐겨찾기 기능 + Favorites 화면

### Phase 3 — 연습 기능 (1~2주)
13. Practice 화면 (플래시카드 모드)
14. Quiz 화면 (객관식, 빈칸 채우기)
15. 연속 학습 스트릭 로직
16. Progress 화면 (차트 포함)

### Phase 4 — AI 대화 기능 (1~2주)
17. Claude API 연동 (`useClaudeChat` 훅)
18. AI Chat 화면 (채팅 UI)
19. 문법 피드백 칩 표시
20. 음성 입력 (STT) 연동

### Phase 5 — 마무리 (1주)
21. Splash / 애니메이션 다듬기
22. Settings 화면 (알림, 학습 목표)
23. 로컬 알림 구현
24. 성능 최적화 + 빌드 테스트
25. 앱 아이콘 / 스플래시 이미지 적용

---

## 참고 — 첫 릴리스 포함 표현 목록 (총 80개)

| 카테고리 | 표현 수 |
|----------|---------|
| 인사/소개 | 15개 |
| 식당 | 15개 |
| 쇼핑 | 10개 |
| 여행 | 15개 |
| 직장 | 15개 |
| 긴급상황 | 10개 |
| **합계** | **80개** |
