# DAHAM

figma : https://www.figma.com/design/I44yicEbLb5kjVA8EsW8rZ/DAHAM?node-id=0-1&p=f&t=gg0TXU63HbmB0gK3-0

---

## 목차
- [폴더 구조](#폴더-구조-202506-최신화)
- [주요 기능 요약](#주요-기능-요약)
- [팀원 참고/주의사항](#팀원-참고주의사항)
- [개발 팁](#개발-팁)
- [앱 실행 흐름](#앱-실행-흐름)
- [페이지 별 기능](docs/pages.md)

## 📁 폴더 구조 (2025.06 최신화)

```
lib/
├── main.dart
├── firebase_options.dart
├── Provider/
│   ├── appstate.dart
│   ├── group_provider.dart
│   ├── todo_provider.dart
│   ├── user_provider.dart
│   ├── gemini_provider.dart
│   └── export.dart
├── Data/
│   ├── group.dart
│   ├── user.dart
│   ├── task.dart
│   └── todo.dart
├── Pages/
│   ├── HomePage/
│   │   ├── mainFrame.dart
│   │   ├── main_page.dart
│   │   └── userMain_Todo.dart
│   ├── Login/
│   │   └── login.dart
│   ├── User/
│   │   ├── profile_setup.dart
│   │   └── my_page.dart
│   ├── Group/
│   │   ├── all_group_page.dart
│   │   ├── group_create.dart
│   │   ├── group_detail.dart
│   │   ├── group_join.dart
│   │   ├── group_list_page.dart
│   │   ├── my_group_page.dart
│   │   └── task_create.dart
│   └── test/
│       └── test_main.dart
├── Func/
│   └── todo_assiant.dart
```
---

---

## 🧩 주요 기능 요약

- **그룹 기반 할 일 관리**: 그룹 생성/가입/상세/과제(Task) 관리
- **개인 할 일 관리**: 할 일 추가, 체크, AI 기반 자동 생성
- **AI 할 일 생성**: Gemini API를 활용한 자연어 → JSON 변환
- **사용자 관리**: 로그인, 프로필 설정, 내 정보 페이지
- **진행률/캘린더/진행상황 시각화**: 퍼센트 인디케이터, 캘린더 등

---

## ⚠️ 팀원 참고/주의사항

### 1. Gemini API 호출 방법
- `.env` 파일에 `GEMINI_API_KEY`를 반드시 등록해야 함 (루트에 위치, pubspec.yaml의 assets에 등록)
- `GeminiProvider` 및 `GeminiTodoAssistant` 참고
- 프롬프트/스키마/예시 수정 시 반드시 팀원과 상의

### 2. 코드 리팩토링/구조 변경 시
- Provider, Model, 주요 페이지 구조 변경 시 **슬랙/노션/회의로 공유 필수**
- 함수/클래스/파일명 변경 시 주석 또는 커밋 메시지에 변경 내역 명확히 남길 것

### 3. 기타 주의사항
- pubspec.yaml, .env, firebase_options.dart 등 환경설정 파일은 항상 최신 상태로 유지
- .env 파일은 git에 올리지 않도록 주의 (`.gitignore`에 등록)
- 외부 패키지 추가/업데이트 시 반드시 `flutter pub get` 후 정상 동작 확인

---

## 💡 개발 팁

- **AI 할 일 생성 테스트**: `userMain_Todo.dart`의 AI 버튼에서 하드코딩된 입력으로 Gemini 호출 결과 확인 가능
- **기능별 분리**: Provider(상태), Data(모델), Pages(UI), Func(비즈니스 로직)로 역할 분리
- **테스트용 페이지**: `Pages/test/test_main.dart`에서 임시 UI/기능 실험 가능

---

## 🚀 앱 실행 흐름

1. `main.dart`에서 Firebase 및 Provider 초기화
2. 로그인 상태에 따라 `login.dart` 또는 `mainFrame.dart` 진입
3. 각 Provider에서 상태 관리 및 데이터 연동
4. 주요 기능은 `Pages/` 하위 폴더에서 모듈화

---

## 문의/공유

- 구조/기능/코드 관련 문의, 리팩토링/대규모 변경 전 반드시 팀원과 상의 바랍니다.
- Gemini 프롬프트/스키마/예시 등 AI 관련 변경은 꼭 공유 후 적용!

---
