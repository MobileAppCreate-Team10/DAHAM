# DAHAM

figma : https://www.figma.com/design/I44yicEbLb5kjVA8EsW8rZ/DAHAM?node-id=0-1&p=f&t=gg0TXU63HbmB0gK3-0
---

# 📱 모바일 앱 구조 및 기능 정리

본 프로젝트는 그룹 기반의 할 일(Task) 관리 및 커뮤니케이션을 위한 Flutter 앱입니다. 아래는 `lib/` 폴더 기준 전체 구조 및 기능별 역할 정리입니다.

---

## 📁 폴더 구조

```
lib/
├── main.dart
├── firebase_options.dart
├── Provider/
│   ├── appstate.dart
│   ├── group_provider.dart
│   └── user_provider.dart
├── Data/
│   ├── group.dart
│   ├── user.dart
│   ├── task.dart
│   └── todo.dart
├── Pages/
│   ├── HomePage/
│   │   ├── mainFrame.dart
│   │   └── main_page.dart
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
```

---

## 🧩 기능별 역할

### 🔧 상태 관리 (Provider)

| 파일명 | 설명 |
|--------|------|
| `appstate.dart` | 로그인 상태 등 앱 전역 상태 관리 |
| `group_provider.dart` | 그룹 생성, 검색, 가입 등의 로직 |
| `user_provider.dart` | 사용자 정보 관련 상태 관리 |

---

### 🧾 데이터 모델 (Model)

| 파일명 | 설명 |
|--------|------|
| `group.dart` | 그룹 정보 모델 (이름, 설명, 인원 등) |
| `user.dart` | 사용자 모델 |
| `task.dart` | 작업(Task) 모델 |
| `todo.dart` | 세부 할 일(To-do) 모델 |

---

### 🖥️ UI 페이지 (Pages)

#### 🔹 홈

| 파일명 | 설명 |
|--------|------|
| `mainFrame.dart` | 메인 프레임: 탭 구조 혹은 하단 네비게이션 |
| `main_page.dart` | 메인 콘텐츠 영역 |

#### 🔹 로그인 및 사용자

| 파일명 | 설명 |
|--------|------|
| `login.dart` | 로그인 화면 |
| `profile_setup.dart` | 최초 로그인 시 프로필 설정 |
| `my_page.dart` | 사용자 정보 및 설정 화면 |

#### 🔹 그룹 기능

| 파일명 | 설명 |
|--------|------|
| `group_create.dart` | 그룹 생성 |
| `group_list_page.dart` | 전체 그룹 목록 보기 |
| `group_join.dart` | 그룹 검색 및 가입 |
| `group_detail.dart` | 그룹 상세 정보 |
| `my_group_page.dart` | 내가 속한 그룹 목록 |
| `all_group_page.dart` | 전체 그룹 탐색 페이지 |
| `task_create.dart` | 그룹 내 작업(Task) 생성 |

#### 🔹 테스트

| 파일명 | 설명 |
|--------|------|
| `test_main.dart` | 테스트용 임시 화면 |

---

## 🚀 앱 실행 흐름 요약

1. `main.dart`에서 Firebase 초기화 및 Provider 설정
2. 로그인 상태 확인 → 미로그인 시 `login.dart`, 로그인 시 `mainFrame.dart` 진입
3. `AppState`와 `Provider`를 통해 앱 전반의 상태 관리
4. 기능별 UI는 `Pages/` 하위 폴더에서 모듈화하여 구성

---
