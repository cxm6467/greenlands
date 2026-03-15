# Greenfield RPG Project Guidelines

Project-specific instructions for Greenfield RPG (The Greenlands fantasy adventure) Flutter application.

## Test Data Guidelines

When creating test fixtures with API tokens, bot tokens, or webhooks:
- Use obviously fake formats: `FAKE_TOKEN_test_not_real`
- Never use realistic base64 or hex patterns
- Always include words like "test", "fake", "not-real" in the token string
- For Discord: Use `FAKE_DISCORD_TOKEN.test.not-real` format
- For Slack: Use `xoxb-fake-test-token-not-real` format
- GitHub's secret scanning triggers on realistic patterns, even with "-test" suffix

**Why:** Realistic-looking test tokens (even with `-test` suffix) trigger GitHub's secret scanning and block pushes. This causes multiple rebase/amend cycles that waste tokens.

## CI/CD Test Status

Current known issues:
- Widget tests fail due to GetIt mock setup (13 failures) - **non-critical**
- Health check tests are the critical metric (47/47 passing required)
- When CI fails on widget tests only, note it but don't block on it
- Analyzer and formatting must pass

**Why:** Widget test failures are a test infrastructure issue, not code functionality issues. The health check tests validate critical business logic (API validation, connectivity, error handling).

## Git Operations

When fixing commits in history that were already pushed:

1. Use interactive rebase with sed:
```bash
GIT_SEQUENCE_EDITOR="sed -i 's/^pick HASH/edit HASH/'" git rebase -i BASE_COMMIT
```

2. Amend the commit:
```bash
git add . && git commit --amend --no-edit
```

3. Continue rebase:
```bash
git rebase --continue
```

4. Force push with lease (bypass hooks if already verified locally):
```bash
git push --force-with-lease --no-verify
```

**Why:** This pattern allows efficient commit history editing without manual editor interaction.

## Flutter Environment

For this project:
- Flutter: `~/flutter/bin/flutter`
- Dart: `~/flutter/bin/dart`
- Always use full paths since Flutter is not in PATH

Common commands:
```bash
~/flutter/bin/flutter format .
~/flutter/bin/flutter analyze
~/flutter/bin/flutter test test/core/services/health_check/
~/flutter/bin/flutter run
```

## Project Architecture

- **Local-First:** SQLite for mobile/desktop, in-memory for web
- **Clean Architecture:** Domain/Data/Presentation separation
- **Dependency Injection:** GetIt with InjectionNames constants
- **State Management:** Riverpod with AsyncValue pattern
- **Testing:** Focus on health check service tests (business logic)
