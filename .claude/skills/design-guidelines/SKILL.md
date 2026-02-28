---
name: design-guidelines
description: OutSpoken 앱의 디자인 가이드라인. UI 코드를 작성하거나 수정할 때 자동으로 참조하여 일관된 디자인을 유지한다.
user-invocable: false
---

# OutSpoken 디자인 가이드라인

이 앱의 UI 코드를 작성할 때 반드시 아래 규칙을 따른다. 하드코딩 금지 — 항상 `lib/constants/`의 디자인 토큰을 사용한다.

---

## 1. 색상 체계 (Color System)

### 핵심 3색

| 역할 | 이름 | Hex | 용도 |
|------|------|-----|------|
| **메인** | Primary Blue | `#3B82F6` | CTA 버튼, 링크, 활성 탭, 진행률 바, 강조 텍스트 |
| **보조 1** | Emerald Green | `#10B981` | 성공 상태, 학습 완료, 스트릭 달성, 긍정 피드백 |
| **보조 2** | Warm Amber | `#F59E0B` | 배지, 알림, 퀴즈 점수, 주의 상태, 하이라이트 |

### 코드에서의 사용법

```dart
// 직접 색상값 사용 금지. 반드시 AppColors 클래스 참조
import '../constants/colors.dart';

// 라이트/다크 모드 자동 대응 — context 기반 메서드 사용
AppColors.primaryColor(context)     // 메인 블루
AppColors.secondaryColor(context)   // 보조 에메랄드
AppColors.accentColor(context)      // 보조 앰버

// 배경/표면
AppColors.bg(context)               // 화면 배경
AppColors.surfaceColor(context)     // 카드/시트 배경
AppColors.surfaceAltColor(context)  // 입력필드/칩 배경

// 텍스트
AppColors.textPrimaryColor(context) // 본문 텍스트
AppColors.textSecondaryColor(context) // 보조 텍스트, 힌트
AppColors.textDisabledColor(context)  // 비활성 텍스트

// 기타
AppColors.borderColor(context)      // 테두리
AppColors.errorColor(context)       // 에러 상태
```

### 투명도 규칙

```dart
// 배경 틴트로 사용할 때
color.withValues(alpha: 0.08)   // 매우 연한 배경 (배너, 상태바)
color.withValues(alpha: 0.1)    // 연한 배경 (카드, 버튼 배경)
color.withValues(alpha: 0.15)   // 선택된 칩/탭 배경
color.withValues(alpha: 0.2)    // 뱃지, 오버레이
color.withValues(alpha: 0.25)   // 테두리
color.withValues(alpha: 0.3)    // 버튼 테두리
color.withValues(alpha: 0.4)    // 스위치 트랙
```

### 카테고리 색상

```dart
AppColors.catGreetings   // #6366F1 Indigo  — 인사/소개
AppColors.catRestaurant  // #F97316 Orange  — 식당
AppColors.catShopping    // #EC4899 Pink    — 쇼핑
AppColors.catTravel      // #06B6D4 Cyan    — 여행
AppColors.catWorkplace   // #8B5CF6 Purple  — 직장
AppColors.catEmergency   // #EF4444 Red     — 긴급상황
```

---

## 2. 간격 체계 (Spacing System)

4px 기반 간격 체계를 사용한다. `AppLayout` 클래스의 상수를 참조한다.

### 여백 (Padding) — 컨테이너 내부 간격

| 토큰 | 값 | 용도 |
|------|-----|------|
| `AppLayout.paddingXS` | 4px | 최소 내부 여백 (태그, 뱃지 내부) |
| `AppLayout.paddingSM` | 8px | 좁은 내부 여백 (칩, 작은 배너) |
| `AppLayout.paddingMD` | 16px | 기본 내부 여백 (카드, 리스트 아이템) |
| `AppLayout.paddingLG` | 24px | 넓은 내부 여백 (주요 카드, 히어로 섹션) |
| `AppLayout.paddingXL` | 32px | 최대 내부 여백 (섹션 사이 간격) |
| `AppLayout.paddingXXL` | 48px | 특대 여백 (페이지 상단/하단) |
| `AppLayout.screenPadding` | 20px | 화면 좌우 기본 패딩 (모든 화면에 적용) |

### 간격 (Gap) — 요소 사이 간격

| 토큰 | 값 | 용도 |
|------|-----|------|
| `AppLayout.gapXS` | 4px | 아이콘-텍스트, 인라인 요소 사이 |
| `AppLayout.gapSM` | 8px | 텍스트-텍스트, 작은 요소 사이 |
| `AppLayout.gapMD` | 12px | 카드 사이, 리스트 아이템 사이 |
| `AppLayout.gapLG` | 16px | 섹션 내 그룹 사이 |
| `AppLayout.gapXL` | 24px | 섹션 사이 |

### 선택 가이드

```
인라인 요소 사이 → gapXS (4) 또는 gapSM (8)
리스트 아이템 사이 → gapMD (12)
섹션 제목 - 내용 사이 → gapMD (12)
섹션 - 섹션 사이 → paddingXL (32)
화면 좌우 패딩 → screenPadding (20)
카드 내부 패딩 → paddingMD (16) 또는 paddingLG (24)
```

---

## 3. 사이즈 체계 (Size System)

### 타이포그래피 — `AppTextStyles` 클래스

| 토큰 | 크기 | 굵기 | 용도 |
|------|------|------|------|
| `displayLarge` | 32px | bold | 스플래시, 히어로 타이틀 |
| `displayMedium` | 28px | bold | 온보딩 타이틀 |
| `headlineLarge` | 24px | w700 | 페이지 타이틀 |
| `headlineMedium` | 20px | w600 | 섹션 대제목 |
| `headlineSmall` | 18px | w600 | 섹션 소제목, 카드 타이틀 |
| `titleLarge` | 16px | w600 | 리스트 아이템 제목, 버튼 텍스트 |
| `titleMedium` | 15px | w500 | 보조 제목 |
| `bodyLarge` | 16px | normal | 본문 (강조) |
| `bodyMedium` | 14px | normal | 기본 본문 |
| `bodySmall` | 12px | normal | 보조 텍스트, 캡션 |
| `labelLarge` | 14px | w600 | 버튼 라벨, 탭 라벨 |
| `labelMedium` | 12px | w500 | 태그, 뱃지 라벨 |
| `caption` | 11px | normal | 최소 텍스트, 타임스탬프 |
| `phraseDisplay` | 26px | w700 | 영어 표현 메인 텍스트 |
| `pronunciation` | 16px | italic | IPA 발음 기호 |

### 아이콘 크기

| 토큰 | 값 | 용도 |
|------|-----|------|
| `AppLayout.iconSM` | 18px | 인라인 아이콘, 태그 내 아이콘 |
| `AppLayout.iconMD` | 24px | 기본 아이콘 (버튼, 네비게이션) |
| `AppLayout.iconLG` | 32px | 강조 아이콘 (카드 헤더) |
| `AppLayout.iconXL` | 48px | 히어로 아이콘 (빈 상태, 온보딩) |

### 모서리 반지름 (Border Radius)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `AppLayout.radiusSM` | 8px | 칩, 태그, 작은 카드 |
| `AppLayout.radiusMD` | 12px | 기본 카드, 입력 필드, 버튼 |
| `AppLayout.radiusLG` | 16px | 큰 카드, 바텀시트 |
| `AppLayout.radiusXL` | 24px | 다이얼로그, 모달, 히어로 카드 |
| `AppLayout.radiusCircle` | 999px | 원형 (아바타, 뱃지, 플로팅 버튼) |

### 버튼 높이

| 토큰 | 값 | 용도 |
|------|-----|------|
| `AppLayout.buttonHeight` | 52px | 기본 버튼 (CTA, 로그인, 제출) |
| `AppLayout.buttonHeightSM` | 40px | 보조 버튼 (필터, 정렬) |

### 그림자 (Elevation)

| 토큰 | 값 | 용도 |
|------|-----|------|
| `AppLayout.elevationSM` | 2px | 카드, 칩 (미묘한 부유감) |
| `AppLayout.elevationMD` | 4px | 떠 있는 카드, 드롭다운 |
| `AppLayout.elevationLG` | 8px | 모달, 바텀시트 |

---

## 4. 코드 작성 규칙

### 필수

- 색상, 간격, 크기에 **숫자 리터럴 직접 사용 금지**. 반드시 토큰 참조.
- 다크모드 대응이 필요한 색상은 **context 기반 메서드** 사용 (`AppColors.bg(context)` 등).
- `const` 색상이 필요한 곳(decoration 등)에서만 `AppColors.primary` 같은 static const 사용.
- `SizedBox`로 간격 넣을 때 토큰 사용: `SizedBox(height: AppLayout.gapMD)`.
- 텍스트 스타일은 `AppTextStyles.bodyMedium` 등을 사용하고, 색상 변경 시 `.copyWith(color: ...)`.

### 금지

- `Color(0xFF...)` 직접 사용 금지 (카테고리 색상 등 이미 정의된 경우 제외)
- `TextStyle(fontSize: 16)` 직접 정의 금지 — `AppTextStyles`에서 선택
- `EdgeInsets.all(16)` 대신 `EdgeInsets.all(AppLayout.paddingMD)` 사용
- `BorderRadius.circular(12)` 대신 `BorderRadius.circular(AppLayout.radiusMD)` 사용
- `withOpacity()` 사용 금지 — `withValues(alpha: 0.1)` 사용 (Flutter 최신 권장)

### 패턴

```dart
// 화면 기본 구조
Scaffold(
  backgroundColor: AppColors.bg(context),
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(AppLayout.screenPadding),
      child: ...
    ),
  ),
)

// 카드 기본 구조
Container(
  padding: const EdgeInsets.all(AppLayout.paddingMD),
  decoration: BoxDecoration(
    color: AppColors.surfaceColor(context),
    borderRadius: BorderRadius.circular(AppLayout.radiusMD),
    border: Border.all(color: AppColors.borderColor(context)),
  ),
  child: ...
)

// 카테고리 색상 배경 카드
Container(
  decoration: BoxDecoration(
    color: cat.color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppLayout.radiusMD),
    border: Border.all(color: cat.color.withValues(alpha: 0.25)),
  ),
)

// 그림자 있는 카드
BoxShadow(
  color: Colors.black.withValues(alpha: 0.06),
  blurRadius: AppLayout.elevationMD,
  offset: const Offset(0, 2),
)
```
