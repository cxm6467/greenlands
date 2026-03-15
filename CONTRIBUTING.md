# Contributing to Greenfield

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/shire.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test thoroughly
6. Commit with clear messages
7. Push to your fork: `git push origin feature/your-feature-name`
8. Open a Pull Request

## Development Setup

### Prerequisites
- Flutter SDK 3.41.4+
- Dart 3.11.1+
- Git

### Setup Steps
```bash
# Install dependencies
flutter pub get

# Run the app
flutter run -d linux

# Run tests
flutter test

# Format code
dart format .

# Analyze code
flutter analyze
```

## Branch Protection Rules

The `main` branch is protected with the following rules:

### Required for Merging
- **Pull Request Required**: All changes must go through a pull request
- **Status Checks**: All CI checks must pass
  - Test & Lint job must succeed
  - Build job must succeed
- **Up-to-date Branch**: Branch must be up to date with main before merging
- **Conversation Resolution**: All PR conversations must be resolved

### To Set Up Branch Protection (Repository Owner)

1. Go to **Settings** → **Branches**
2. Click **Add rule** or edit the `main` branch rule
3. Configure the following:
   - ✅ Require a pull request before merging
     - ✅ Require approvals: 1 (optional, recommended for teams)
     - ✅ Dismiss stale pull request approvals when new commits are pushed
   - ✅ Require status checks to pass before merging
     - ✅ Require branches to be up to date before merging
     - Add required status checks:
       - `Test & Lint`
       - `Build Web App`
   - ✅ Require conversation resolution before merging
   - ❌ Do not allow bypassing the above settings (recommended)
4. Click **Create** or **Save changes**

## Commit Message Guidelines

Use clear, descriptive commit messages:

```
Add character creation wizard

- Implement race selection screen
- Add class selection with stat bonuses
- Create stat allocation interface
- Add character preview
```

### Format
- First line: Brief summary (50 chars or less)
- Blank line
- Detailed description with bullet points if needed

## Code Style

- Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `dart format .` before committing
- Ensure `flutter analyze` shows no issues
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions focused and concise

## Testing

- Write tests for new features
- Update tests when modifying existing features
- Ensure all tests pass: `flutter test`
- Aim for good test coverage

## Pull Request Process

1. **Update Documentation**: If you add features, update README.md
2. **Run Tests**: Ensure all tests pass locally
3. **Format Code**: Run `dart format .`
4. **Analyze Code**: Run `flutter analyze` and fix issues
5. **Fill PR Template**: Provide clear description and context
6. **Address Feedback**: Respond to review comments promptly
7. **Keep Updated**: Rebase on main if conflicts arise

## CI/CD Pipeline

The project uses GitHub Actions for CI/CD:

### On Pull Requests
- Runs tests with coverage
- Checks code formatting
- Runs static analysis
- Builds the web app

### On Merge to Main
- Runs all PR checks
- Deploys to Firebase Hosting (production)

## Firebase Secrets Setup (Repository Owner)

To enable Firebase deployment, add these secrets in **Settings** → **Secrets and variables** → **Actions**:

1. **FIREBASE_PROJECT_ID**: Your Firebase project ID (from `.firebaserc`)
2. **FIREBASE_SERVICE_ACCOUNT**: Firebase service account JSON
   ```bash
   # Generate service account key
   firebase projects:list
   # In Firebase Console: Project Settings → Service Accounts → Generate New Private Key
   # Copy the entire JSON and add as secret
   ```

## Architecture Guidelines

Follow Clean Architecture principles:

```
lib/
├── domain/        # Business logic (entities, use cases)
├── data/          # Data sources, repositories
├── presentation/  # UI, state management
└── core/          # Configuration, utilities
```

### Layer Dependencies
- **Domain**: No dependencies on other layers
- **Data**: Depends on Domain
- **Presentation**: Depends on Domain (use cases)
- **Core**: Can be used by all layers

## Questions?

- Check existing issues
- Review closed PRs for examples
- Open a discussion for questions

Thank you for contributing! 🏰✨
