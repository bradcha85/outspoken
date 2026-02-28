---
name: ui-polish
description: OutSpoken 앱 화면의 UI 완성도를 점검하고 개선한다. 빈 상태, 에러 처리, 로딩, 애니메이션 등을 다룬다.
argument-hint: <screen_file.dart>
---

# UI Polish

`lib/screens/$ARGUMENTS`의 UI 완성도를 점검하고 개선한다.

## 실행 절차

### 1단계: 대상 파일 읽기

- `lib/screens/$0`을 읽는다.
- 해당 화면이 사용하는 Provider, 위젯 파일도 함께 읽는다.
- `lib/constants/` 디자인 토큰을 확인한다.

### 2단계: UI 완성도 체크리스트

아래 항목을 점검한다:

#### Empty State (빈 상태)
- [ ] 리스트가 비었을 때 안내 메시지 + 아이콘 표시
- [ ] 빈 상태에서 사용자가 할 수 있는 액션(CTA) 제공
- [ ] 검색 결과가 없을 때 적절한 피드백

#### Loading State (로딩 상태)
- [ ] 데이터 로딩 중 로딩 인디케이터 표시
- [ ] 스켈레톤 UI 또는 shimmer 효과 (필요시)

#### Error State (에러 상태)
- [ ] try-catch로 예외 처리
- [ ] 사용자 친화적 에러 메시지 (한국어)
- [ ] 재시도 버튼 제공

#### Interaction Feedback (인터랙션 피드백)
- [ ] 버튼 탭 시 리플 효과 또는 시각적 피드백
- [ ] 성공/실패 시 SnackBar 또는 토스트 메시지
- [ ] 상태 변경 시 부드러운 전환 (AnimatedSwitcher 등)

#### Layout & Responsiveness
- [ ] SafeArea 적용
- [ ] 키보드 올라올 때 레이아웃 깨지지 않음
- [ ] 긴 텍스트 overflow 처리
- [ ] 스크롤 가능한 콘텐츠에 적절한 스크롤 위젯 사용

#### Visual Detail
- [ ] 일관된 spacing (AppLayout 토큰 사용)
- [ ] 일관된 border radius (AppLayout 토큰 사용)
- [ ] 다크모드에서 올바르게 표시 (AppColors context-aware 메서드 사용)

### 3단계: 수정 적용

발견된 문제를 **우선순위 순으로** 수정한다:

1. **필수**: 에러 상태, 빈 상태 처리 (앱 사용성에 직접 영향)
2. **권장**: 인터랙션 피드백, 로딩 상태
3. **선택**: 애니메이션, 시각적 디테일

수정 원칙:
- 디자인 토큰(`AppColors`, `AppTextStyles`, `AppLayout`)을 반드시 사용한다.
- context-aware 색상 메서드 사용: `AppColors.bg(context)`, `AppColors.surfaceColor(context)`, `AppColors.textPrimaryColor(context)` 등
- 기존 위젯 패턴을 따른다 (`CustomButton`, `ProgressBarWidget` 등)
- 최소한의 변경으로 최대 효과를 노린다. 과도한 리팩토링은 하지 않는다.
- 새 패키지 추가 없이 Flutter 기본 위젯으로 구현한다.

### 4단계: 결과 보고

```
## UI 개선 결과: <파일명>

### 수정됨
- (수정 항목과 간략 설명)

### 미적용 (향후 고려)
- (시간/복잡도 상 적용하지 않은 항목)
```

## 주의사항

- 화면의 **핵심 기능이나 레이아웃 구조를 변경하지 않는다**.
- 새로운 외부 패키지를 추가하지 않는다.
- `flutter analyze`로 수정 후 에러 없는지 확인한다.
