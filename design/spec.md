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
