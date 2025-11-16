# Contributing to POSA AI 🚀

First off, thank you for considering contributing to POSA AI! It's people like you that make POSA AI such a great tool. We welcome contributions from everyone, whether you're fixing a typo, adding a feature, or reporting a bug.

## 🎯 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Style Guidelines](#style-guidelines)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Community](#community)

---

## 📜 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please be respectful, inclusive, and constructive in all interactions.

### Our Standards

✅ **Do:**
- Be welcoming and inclusive
- Respect differing viewpoints
- Accept constructive criticism gracefully
- Focus on what's best for the community
- Show empathy towards others

❌ **Don't:**
- Use sexualized language or imagery
- Troll, insult, or make derogatory comments
- Engage in personal or political attacks
- Publish others' private information
- Conduct yourself unprofessionally

---

## 🤝 How Can I Contribute?

### 🐛 Reporting Bugs

Found a bug? Help us fix it!

**Before submitting:**
1. Check the [Issues](https://github.com/Hmida71/POSA_AI/issues) page - it may already be reported
2. Try the latest version - it might be fixed already
3. Gather information about the bug

**When reporting:**
- Use a clear, descriptive title
- Describe the exact steps to reproduce
- Provide specific examples
- Describe the behavior you observed and what you expected
- Include screenshots/GIFs if possible
- Include your environment details:
  - OS (Windows 10/11, macOS, Linux)
  - Flutter version (`flutter --version`)
  - Python version (`python --version`)
  - POSA AI version

**Template:**
```markdown
**Bug Description:**
A clear description of the bug.

**Steps to Reproduce:**
1. Go to '...'
2. Click on '...'
3. Enter '...'
4. See error

**Expected Behavior:**
What you expected to happen.

**Actual Behavior:**
What actually happened.

**Screenshots:**
If applicable, add screenshots.

**Environment:**
- OS: [e.g., Windows 11]
- Flutter: [e.g., 3.16.0]
- Python: [e.g., 3.11.5]
- POSA AI: [e.g., v1.0.0]

**Additional Context:**
Any other relevant information.
```

### 💡 Suggesting Features

Have an idea? We'd love to hear it!

**Before suggesting:**
1. Check [Discussions](https://github.com/Hmida71/POSA_AI/discussions) - it might be planned
2. Search existing [Issues](https://github.com/Hmida71/POSA_AI/issues) - it might be suggested

**When suggesting:**
- Use a clear, descriptive title
- Provide a detailed description of the feature
- Explain why this would be useful
- Provide examples of how it would work
- Consider implementation complexity

**Template:**
```markdown
**Feature Description:**
A clear description of what you want to happen.

**Use Case:**
Why is this feature useful? Who benefits?

**Proposed Solution:**
How should it work?

**Alternatives Considered:**
What other approaches did you think about?

**Additional Context:**
Screenshots, mockups, examples from other apps.
```

### 🌍 Translating

Help make POSA AI accessible to more people!

**Languages we need:**
- French
- Spanish
- German
- Chinese
- Japanese
- And more!

**How to translate:**
1. Copy `lib/l10n/app_en.arb`
2. Rename to your language code (e.g., `app_fr.arb` for French)
3. Translate all strings
4. Test with your language
5. Submit a PR

### 📚 Improving Documentation

Documentation is crucial! Help us make it better:
- Fix typos and grammatical errors
- Add missing information
- Improve explanations
- Add examples and tutorials
- Update outdated information

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (latest stable) - [Install](https://docs.flutter.dev/get-started/install)
- **Python 3.10+** - [Install](https://www.python.org/downloads/)
- **Git** - [Install](https://git-scm.com/downloads)
- **Code editor** - VS Code, Android Studio, or IntelliJ IDEA

### Fork and Clone

1. **Fork** the repository on GitHub
2. **Clone** your fork locally:
```bash
git clone https://github.com/YOUR_USERNAME/POSA_AI.git
cd POSA_AI
```

3. **Add upstream** remote:
```bash
git remote add upstream https://github.com/Hmida71/POSA_AI.git
```

### Setup Development Environment

1. **Install Flutter dependencies:**
```bash
flutter pub get
```

2. **Install Python dependencies:**
```bash
cd backend
pip install -r requirements.txt
python -m playwright install chromium
cd ..
```

3. **Configure Supabase** (optional for testing):
   - Copy `lib/utils/constants.dart.example` to `lib/utils/constants.dart` (if exists)
   - Add your Supabase credentials, or use test mode

4. **Run the app:**
```bash
flutter run -d windows  # or macos, linux
```

---

## 🔧 Development Workflow

### 1. Create a Branch

Always create a new branch for your work:

```bash
# Update your main branch
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/amazing-feature

# Or for bug fixes
git checkout -b fix/bug-description
```

**Branch naming:**
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation changes
- `refactor/` - Code refactoring
- `test/` - Adding tests
- `chore/` - Maintenance tasks

### 2. Make Your Changes

- Write clean, readable code
- Follow the [Style Guidelines](#style-guidelines)
- Add tests for new features
- Update documentation as needed
- Test thoroughly on your target platform

### 3. Test Your Changes

```bash
# Run Flutter tests
flutter test

# Run the app and test manually
flutter run -d windows

# Test backend separately
cd backend
python app.py
```

### 4. Commit Your Changes

Follow our [Commit Guidelines](#commit-guidelines):

```bash
git add .
git commit -m "feat: add amazing new feature"
```

### 5. Push to Your Fork

```bash
git push origin feature/amazing-feature
```

### 6. Open a Pull Request

1. Go to your fork on GitHub
2. Click "Pull Request"
3. Fill out the PR template
4. Wait for review

---

## 🎨 Style Guidelines

### Dart/Flutter Code Style

Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```dart
// ✅ Good
class BrowserAgent {
  final String taskDescription;
  
  BrowserAgent({required this.taskDescription});
  
  Future<void> executeTask() async {
    // Implementation
  }
}

// ❌ Bad
class browser_agent {
  String task_description;
  
  void execute_task() {
    // Implementation
  }
}
```

**Key points:**
- Use `camelCase` for variables and functions
- Use `PascalCase` for classes
- Use `snake_case` for file names
- Add meaningful comments
- Keep functions small and focused
- Use `const` constructors when possible

### Python Code Style

Follow [PEP 8](https://peps.python.org/pep-0008/):

```python
# ✅ Good
class BrowserController:
    def __init__(self, api_key: str):
        self.api_key = api_key
    
    async def execute_task(self, task: str) -> dict:
        """Execute a browser automation task."""
        # Implementation
        pass

# ❌ Bad
class browserController:
    def __init__(self,apiKey):
        self.apiKey=apiKey
    
    def executeTask(self,task):
        pass
```

**Key points:**
- Use `snake_case` for functions and variables
- Use `PascalCase` for classes
- Add type hints
- Write docstrings
- Use 4 spaces for indentation
- Keep lines under 100 characters

### File Organization

```
lib/
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic
├── utils/           # Utilities and helpers
├── widgets/         # Reusable widgets
└── models/          # Data models

backend/
├── app.py           # Main server
├── controllers/     # Request handlers
├── models/          # Data models
└── utils/           # Helper functions
```

---

## 📝 Commit Guidelines

We follow [Conventional Commits](https://www.conventionalcommits.org/):

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `perf:` - Performance improvements

### Examples

```bash
# Feature
git commit -m "feat(agent): add voice command support"

# Bug fix
git commit -m "fix(backend): resolve socket connection timeout"

# Documentation
git commit -m "docs(readme): update installation instructions"

# Breaking change
git commit -m "feat(api)!: change API endpoint structure

BREAKING CHANGE: API endpoints now use /v2/ prefix"
```

### Best Practices

- Use present tense ("add feature" not "added feature")
- Use imperative mood ("move cursor to..." not "moves cursor to...")
- First line should be 50 characters or less
- Reference issues and PRs in the body
- Use the body to explain what and why, not how

---

## 🔄 Pull Request Process

### Before Submitting

- [ ] Code follows style guidelines
- [ ] Self-review of code completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings or errors
- [ ] Tests pass locally
- [ ] Tested on target platform(s)

### PR Template

```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?
Describe how you tested your changes.

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where needed
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally
```

### Review Process

1. **Automated checks** run (if configured)
2. **Maintainers review** your code
3. **Feedback** may be provided
4. **Make requested changes** if needed
5. **Approval** from maintainers
6. **Merge** into main branch

### After Merge

- Your contribution will be included in the next release
- You'll be added to the contributors list
- We'll celebrate your contribution! 🎉

---

## 🌟 Recognition

We value all contributions! Contributors are recognized in:

- **README.md** - Contributors section
- **Release notes** - Feature credits
- **Contributors page** - GitHub automatically tracks

### Significant Contributors

Exceptional contributors may be invited to:
- Join the core team
- Get write access to the repository
- Help guide the project's direction

---

## 💬 Community

### Get Help

- 📖 **Documentation**: [README.md](README.md)
- 💬 **Discord**: [Join our server](https://discord.gg/your-link)
- 🐛 **Issues**: [GitHub Issues](https://github.com/Hmida71/POSA_AI/issues)
- 💡 **Discussions**: [GitHub Discussions](https://github.com/Hmida71/POSA_AI/discussions)

### Stay Updated

- ⭐ **Star** the repository
- 👀 **Watch** for updates
- 🔔 **Subscribe** to release notifications

### Contact Maintainers

- **Hmida71**: [@Hmida71](https://github.com/Hmida71)
- **abenkoula71**: [@abenkoula71](https://github.com/abenkoula71)
- **Nexios**: [www.nexios-dz.com](https://www.nexios-dz.com/)

---

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Python Documentation](https://docs.python.org)
- [Playwright Documentation](https://playwright.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Git Workflow Guide](https://guides.github.com/introduction/flow/)

---

## 🎯 Good First Issues

New to open source? Look for issues labeled `good first issue`:

- Simple bug fixes
- Documentation improvements
- Adding tests
- UI/UX enhancements

[View Good First Issues →](https://github.com/Hmida71/POSA_AI/labels/good%20first%20issue)

---

## ❤️ Thank You!

Every contribution, no matter how small, makes a difference. Thank you for being part of the POSA AI community!

**Questions?** Don't hesitate to ask in [Discussions](https://github.com/Hmida71/POSA_AI/discussions)!

---

<div align="center">

**Made with ❤️ by the POSA AI community**

[Website](https://posa-ai.free.nf/) • [GitHub](https://github.com/Hmida71/POSA_AI) • [Nexios](https://www.nexios-dz.com/)

</div>