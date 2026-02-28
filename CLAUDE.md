# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OutSpoken - an English conversation practice app for Korean speakers, built with Flutter/Dart. Users learn phrases by category, practice with TTS pronunciation, and take quizzes.

## Build & Development Commands

```bash
# Run the app (debug mode)
flutter run

# Run on specific platform
flutter run -d chrome          # Web
flutter run -d macos           # macOS
flutter run -d ios             # iOS simulator

# Build
flutter build apk              # Android
flutter build ios              # iOS
flutter build web              # Web

# Analyze code (lint)
flutter analyze

# Run tests
flutter test                   # All tests
flutter test test/widget_test.dart  # Single test file

# Get dependencies
flutter pub get
```

## Architecture

### Entry Point & Providers

`lib/main.dart` wraps the app in `MultiProvider` with three ChangeNotifier providers that each call `load()` on startup to restore state from SharedPreferences:

- **PhraseProvider** — phrase data, category filtering, search
- **ProgressProvider** — learned phrases, favorites, streaks, quiz results (persists to `user_progress` and `daily_records` keys)
- **SettingsProvider** — user level, daily goal, speech rate, theme mode

> **AI Chat (비활성화)**: ChatProvider, AiChatScreen, ChatBubble 및 관련 모델(ChatMessage, ChatSession)은 현재 주석 처리됨. 백엔드 구현 후 복원 예정. 주석에 `[AI Chat 기능 비활성화]` 태그로 검색 가능.

### Navigation

`lib/routes/app_router.dart` uses GoRouter with a `ShellRoute` for the 4 bottom-nav tabs (`/home`, `/categories`, `/progress`, `/settings`) rendered inside `MainShell`. Standalone routes (phrase detail, practice, quiz, etc.) live outside the shell.

Initial route is `/splash` → onboarding (if first launch) → `/home`.

### Design Tokens

All visual constants are centralized in `lib/constants/`:
- `colors.dart` — light/dark palettes + per-category colors
- `typography.dart` — text styles (display, headline, body, label, phrase-specific)
- `layout.dart` — padding, radius, gaps, icon sizes, elevation
- `app_theme.dart` — Material 3 ThemeData for light and dark modes

Use these constants instead of hardcoding values. Reference via `AppColors`, `AppTypography`, `AppLayout`, `AppTheme`.

### Data Layer

Static phrase/category data lives in `lib/data/` (80+ phrases across 6 categories). Models in `lib/models/` define `Phrase`, `Category`, `UserProgress`, `DailyRecord`. Persistence uses SharedPreferences with JSON serialization.

### Screens

14 screens in `lib/screens/`. Key ones: `home_screen.dart` (dashboard), `phrase_detail_screen.dart` (TTS playback, learn/favorite), `quiz_screen.dart` (10-question MCQ with scoring), `practice_screen.dart` (flashcard mode).

## Key Patterns

- **State access**: Use `context.read<XProvider>()` for one-time reads, `context.watch<XProvider>()` or `Consumer<X>` for reactive rebuilds
- **TTS**: Initialized per-screen with `FlutterTts()`, language `en-US`, rate from `SettingsProvider.speechRate`
- **Route params**: Category and phrase IDs passed via GoRouter path params (e.g., `/phrase-list/:categoryId`)
- **Widget reuse**: Custom components in `lib/widgets/` — `CustomButton` (primary/secondary/outline/ghost variants), `ProgressBarWidget`, `PhraseListItem`

## UI Redesign Rules

When redesigning screens based on external UI references (e.g., Stitch-generated designs), **never remove or replace existing features/functionality without explicit user approval**. The reference design is for visual styling only — all existing app features (filters, buttons, navigation, data bindings) must be preserved. If the reference design lacks a feature that already exists in the app, ask the user before removing it.

**Text and background colors must always have sufficient contrast.** Never use the same or similar color for text/icons and their background (e.g., white text on white background). Always ensure foreground elements are clearly visible against their container.

## Language

The app UI is in Korean (ko). Code comments and variable names are in English.
