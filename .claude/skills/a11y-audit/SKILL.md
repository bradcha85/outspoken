---
name: a11y-audit
description: OutSpoken 앱 화면의 접근성(Accessibility)을 감사하고 개선한다. 화면 파일명을 인자로 받는다.
argument-hint: <screen_file.dart>
---

# Accessibility Audit

`lib/screens/$ARGUMENTS` (또는 인자가 없으면 전체 screens 디렉토리)의 접근성을 감사하고 개선한다.

## 실행 절차

### 1단계: 대상 파일 읽기

- 인자가 있으면 `lib/screens/$0`을 읽는다.
- 인자가 없으면 `lib/screens/` 전체를 대상으로 한다.
- 해당 화면이 사용하는 위젯 파일(`lib/widgets/`)도 함께 읽는다.

### 2단계: 접근성 항목 체크리스트

아래 항목을 점검하고, 누락된 것을 보고한다:

#### Semantics & Screen Reader
- [ ] 아이콘에 `Semantics` 또는 `semanticLabel` 제공
- [ ] 이미지에 `semanticLabel` 제공
- [ ] 장식용 요소에 `ExcludeSemantics` 적용
- [ ] 의미 있는 위젯 그룹에 `MergeSemantics` 적용
- [ ] 커스텀 버튼/탭 영역에 `Semantics(button: true)` 적용

#### Touch Target
- [ ] 터치 영역 최소 48x48dp 확보
- [ ] `GestureDetector` 대신 `InkWell` 또는 `IconButton` 사용 (리플 피드백)

#### Color & Contrast
- [ ] 텍스트-배경 명암비 4.5:1 이상 (WCAG AA 기준)
- [ ] 색상만으로 정보를 전달하지 않음 (아이콘/텍스트 병행)

#### Text & Readability
- [ ] 하드코딩된 텍스트 크기 대신 디자인 토큰(`AppTextStyles`) 사용
- [ ] `maxLines` + `overflow` 설정으로 텍스트 잘림 방지

#### Navigation
- [ ] `Scaffold`에 적절한 `AppBar` 타이틀 제공
- [ ] 포커스 순서가 논리적

### 3단계: 수정 적용

발견된 문제를 **직접 코드에 수정 적용**한다. 수정 원칙:

- `Icon` → `Icon(Icons.xxx, semanticLabel: '설명')` 추가
- `GestureDetector` → 적절한 `Semantics` 래핑 추가
- 작은 터치 영역 → `SizedBox`나 padding으로 48dp 이상 확보
- 기존 코드 스타일과 디자인 토큰(`AppColors`, `AppTextStyles`, `AppLayout`)을 따른다.
- 과도한 수정은 피하고, 접근성에 직접 관련된 변경만 한다.

### 4단계: 결과 보고

수정 완료 후 아래 형식으로 요약한다:

```
## 접근성 감사 결과: <파일명>

### 수정됨
- (수정 항목과 간략 설명)

### 수동 확인 필요
- (자동으로 판단하기 어려운 항목)
```

## 주의사항

- `lib/constants/` 디자인 토큰을 반드시 참조한다.
- 기존 UI 동작을 변경하지 않는다. 접근성 속성만 추가한다.
- `flutter analyze`로 수정 후 에러 없는지 확인한다.
