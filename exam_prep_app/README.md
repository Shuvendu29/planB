# exam_prep_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Remote Development and CI

### GitHub Codespaces / Dev Container
To develop without using local disk space:
1. Push this repo to GitHub.
2. Open the repo on GitHub and click `Code` → `Codespaces` → `Create codespace on main`.
3. The dev container will automatically install Flutter and run `flutter pub get`.
4. In the terminal, run `flutter test` to test the app.

Alternatively, open in VS Code locally and use `Remote-Containers: Reopen in Container`.

### GitHub Actions CI
The project includes a GitHub Actions workflow that runs on every push and pull request:
- Installs Flutter
- Runs `flutter pub get`
- Runs `flutter test`

Check the Actions tab on GitHub to see test results.

