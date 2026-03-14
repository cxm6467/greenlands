# Pre-Push Hook Setup

This repository includes a pre-push hook that runs CI/CD checks locally before pushing to remote. This ensures code quality and catches issues early.

## What the Hook Does

The pre-push hook automatically runs:
1. **Formatting check**: `dart format --set-exit-if-changed .`
2. **Static analysis**: `flutter analyze --fatal-infos`
3. **Tests**: `flutter test --coverage`

If any check fails, the push is aborted and you'll see which check failed.

## Setup Instructions

The pre-push hook is located at `.git/hooks/pre-push` but is **not tracked by git** (hooks are local to each clone).

### Quick Setup

Copy the pre-push hook to your local `.git/hooks` directory:

```bash
# Make the hook executable
chmod +x .git/hooks/pre-push
```

The hook should already exist if you cloned this repo after it was added. If not, create it:

```bash
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash

# Pre-push hook to run CI/CD checks locally
# This ensures code quality before pushing to remote

set -e

# Use full paths to flutter/dart
FLUTTER="$HOME/flutter/bin/flutter"
DART="$HOME/flutter/bin/dart"

echo "🔍 Running pre-push checks..."
echo ""

# 1. Verify formatting
echo "=== Verify formatting ==="
$DART format --set-exit-if-changed .
if [ $? -ne 0 ]; then
  echo "❌ Formatting check failed. Run 'dart format .' to fix."
  exit 1
fi
echo "✅ Formatting OK"
echo ""

# 2. Analyze code
echo "=== Analyze code ==="
$FLUTTER analyze --fatal-infos
if [ $? -ne 0 ]; then
  echo "❌ Code analysis failed. Fix issues above."
  exit 1
fi
echo "✅ Analysis OK"
echo ""

# 3. Run tests
echo "=== Run tests ==="
$FLUTTER test --coverage
if [ $? -ne 0 ]; then
  echo "❌ Tests failed. Fix failing tests."
  exit 1
fi
echo "✅ Tests OK"
echo ""

echo "✨ All pre-push checks passed!"
echo "🚀 Pushing to remote..."
EOF

chmod +x .git/hooks/pre-push
```

### Custom Flutter Path

If your Flutter installation is not at `$HOME/flutter`, update these lines in the hook:

```bash
FLUTTER="/path/to/your/flutter/bin/flutter"
DART="/path/to/your/flutter/bin/dart"
```

## Bypassing the Hook (Not Recommended)

If you need to push without running checks (e.g., for work-in-progress commits), use:

```bash
git push --no-verify
```

**Warning**: This skips all checks and may cause CI/CD failures.

## Benefits

- ✅ Catch issues before they reach CI/CD
- ✅ Faster feedback loop (no waiting for remote CI)
- ✅ Reduce failed CI/CD builds
- ✅ Ensure consistent code quality across the team
- ✅ Save time by not having to fix issues after pushing

## Troubleshooting

### Hook not running
- Check if the hook file exists: `ls -la .git/hooks/pre-push`
- Check if it's executable: `chmod +x .git/hooks/pre-push`

### Flutter/Dart not found
- Update the `FLUTTER` and `DART` paths in the hook
- Ensure Flutter is installed and in your PATH

### Hook takes too long
- Tests run with coverage, which can be slow for large projects
- Consider skipping coverage locally: change `test --coverage` to `test`
- Use `git push --no-verify` for quick pushes (not recommended)
