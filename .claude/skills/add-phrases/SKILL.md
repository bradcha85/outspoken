---
name: add-phrases
description: OutSpoken 앱의 특정 카테고리에 영어회화 표현을 추가한다. 카테고리 ID와 개수를 인자로 받는다.
argument-hint: <categoryId> <count>
---

# Add Phrases

`lib/data/phrases_data.dart`에 새 표현을 추가하고 `lib/data/categories_data.dart`의 phraseCount를 업데이트한다.

## 인자

- `$0` — 카테고리 ID (greetings | restaurant | shopping | travel | workplace | emergency)
- `$1` — 추가할 표현 개수 (기본값: 5)

## 실행 절차

1. `lib/data/phrases_data.dart`를 읽어 해당 카테고리의 기존 표현과 마지막 ID 번호를 파악한다.
2. 기존 표현과 **중복되지 않는** 실용적인 영어회화 표현을 생성한다.
3. 각 표현은 아래 Phrase 구조를 **정확히** 따른다:
   - `id`: 카테고리 접두사 + 3자리 번호 (예: g016, r016, s011, t016, w016, e011)
   - `english`: 실제 원어민이 쓰는 자연스러운 표현
   - `korean`: 한국어 번역
   - `pronunciation`: IPA 발음 기호 (슬래시로 감싼다)
   - `categoryId`: 해당 카테고리 ID
   - `difficulty`: beginner / intermediate / advanced 중 적절한 난이도
   - `examples`: 2개의 Example (각각 english + korean), 실제 대화에서 쓸 수 있는 예문
   - `tags`: 한국어 태그 1~3개
4. `lib/data/categories_data.dart`의 해당 카테고리 phraseCount를 새 총 개수로 업데이트한다.
5. `flutter analyze`로 문법 오류가 없는지 확인한다.

## ID 접두사 매핑

| categoryId  | 접두사 |
|-------------|--------|
| greetings   | g      |
| restaurant  | r      |
| shopping    | s      |
| travel      | t      |
| workplace   | w      |
| emergency   | e      |

## 표현 데이터 형식 예시

```dart
const Phrase(
  id: 'r016',
  english: 'Could I get a refill, please?',
  korean: '리필 좀 받을 수 있을까요?',
  pronunciation: '/kʊd aɪ ɡɛt ə ˈriːfɪl pliːz/',
  categoryId: 'restaurant',
  difficulty: Difficulty.beginner,
  examples: [
    Example(english: 'Excuse me, could I get a refill on my coffee?', korean: '실례합니다, 커피 리필 좀 받을 수 있을까요?'),
    Example(english: 'Sure! I\'ll bring that right over.', korean: '물론이죠! 바로 가져다 드릴게요.'),
  ],
  tags: ['주문', '음료'],
),
```

## 주의사항

- 기존 표현 목록의 해당 카테고리 섹션 끝에 이어서 추가한다.
- 발음 기호는 정확한 IPA를 사용한다.
- 난이도는 카테고리 내 기존 분포를 참고해 적절히 배분한다.
- 예문은 실제 대화 맥락에서 자연스럽게 쓸 수 있어야 한다.
