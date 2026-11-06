# AGENTS.md

## Project

- Vanilla Flutter app (`maestro`, `publish_to: 'none'`) — still the default counter template, no backend, codegen, or custom tooling.
- Entry point: `lib/main.dart` (`MyApp` -> `MyHomePage`). Only other Dart file is `test/widget_test.dart`.
- All platform folders (`android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`) are generated; don't edit them unless asked. `lib/main.dart` is listed in `.metadata` `unmanaged_files`, so `flutter migrate` won't overwrite it.

## Commands

- Setup: `flutter pub get`
- Lint/typecheck: `flutter analyze` (config: `analysis_options.yaml` -> `package:flutter_lints/flutter.yaml`, analyzer excludes platform + `build/`)
- Test: `flutter test` / single file: `flutter test test/widget_test.dart`
- Run: `flutter run` (hot reload by default)

## Notes

- Dart SDK `^3.13.7` (see `pubspec.yaml`); deps are only `cupertino_icons` + `flutter_lints` dev dep.
- Widget test imports the app as `package:maestro/main.dart` and pumps `MyApp` directly — update it if you rename/move `MyApp`.
- No CI, env files, or `opencode.json` in the repo; don't invent scripts or prerequisites.
