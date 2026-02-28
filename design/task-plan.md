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
