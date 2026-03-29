# Contributing to Farmy

Thanks for your interest in contributing to **Farmy** 🌱  
This document defines the standards and workflow for contributing code, documentation, and improvements.

---

## 1) Development Principles

- Keep changes **small, focused, and reviewable**
- Prioritize **readability and maintainability**
- Follow existing project architecture:
  - `models/` for domain entities
  - `providers/` for state management
  - `services/` for external/API integrations
  - `screens/` and `widgets/` for UI
- Avoid mixing unrelated fixes in one PR

---

## 2) Prerequisites

- Flutter SDK installed
- Dart SDK (bundled with Flutter)
- Android Studio and/or Xcode (as needed)
- Git configured locally

---

## 3) Local Setup

```bash
git clone https://github.com/fekikarim/farmyapp.git
cd farmyapp
flutter pub get
cp .env.example .env
```

Update `.env` with required values before running.

---

## 4) Branching Strategy

- Base branch: `main`
- Branch naming conventions:
  - `feature/<short-description>`
  - `fix/<short-description>`
  - `refactor/<short-description>`
  - `docs/<short-description>`
  - `chore/<short-description>`

Example:
```bash
git checkout -b feature/add-land-filter
```

---

## 5) Code Standards

- Follow Dart/Flutter style and lints (`analysis_options.yaml`)
- Keep widgets/components reusable where practical
- Prefer explicit naming over abbreviations
- Add inline comments only when logic is non-obvious
- Avoid hardcoded secrets or environment-specific credentials

---

## 6) Testing & Validation

Before opening a PR, run:

```bash
flutter analyze
flutter test
```

If your change affects UI flows:
- Include screenshots or short recordings in PR description
- Verify both light and dark themes when relevant

---

## 7) Commit Message Guidelines

Use clear, action-oriented commit messages.

Format:
- `feat: add land boundary validation`
- `fix: resolve basket quantity overflow`
- `refactor: simplify auth provider initialization`
- `docs: update README architecture section`
- `chore: upgrade flutter_stripe dependency`

---

## 8) Pull Request Guidelines

Each PR should include:

1. **Summary** — What changed?
2. **Motivation** — Why was this needed?
3. **Scope** — What is included/excluded?
4. **Testing** — How was it validated?
5. **Screenshots** — If UI changed

### PR Checklist
- [ ] Branch is up to date with `main`
- [ ] Code follows project conventions
- [ ] `flutter analyze` passes
- [ ] `flutter test` passes
- [ ] No secrets committed
- [ ] Documentation updated if behavior changed

---

## 9) Issue Reporting Guidelines

When opening a bug report, include:
- Platform (Android/iOS/Web/Desktop)
- Flutter and Dart versions
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/logs/stack traces if available

For feature requests:
- Describe user problem first
- Proposed solution
- Expected impact and acceptance criteria

---

## 10) Security-Related Contributions

Do **not** open public issues for sensitive vulnerabilities.  
Please follow the process in `SECURITY.md`.

---

## 11) Code of Collaboration

- Be respectful and constructive
- Focus on technical quality, not personal style differences
- Assume good intent
- Welcome feedback and iteration

Thanks for helping improve Farmy 🚀
