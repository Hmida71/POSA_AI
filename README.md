# 🚀 POSA AI - Open Source Browser Agent

<div align="center">

![POSA AI](https://img.shields.io/badge/POSA%20AI-Browser%20Agent-blue?style=for-the-badge&logo=robot&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Stars](https://img.shields.io/github/stars/Hmida71/POSA_AI?style=for-the-badge)
![Contributors](https://img.shields.io/github/contributors/Hmida71/POSA_AI?style=for-the-badge)

**Control browsers with natural language - Built with Flutter, Python, and AI**

[🌐 Website](https://posa-ai.free.nf/) • [📚 Documentation](#documentation) • [🤝 Contributing](#contributing) • [🏢 Nexios](https://www.nexios-dz.com/)

</div>

---

## 📖 Table of Contents

- [About](#about)
- [Features](#features)
- [Demo](#demo)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [API Keys](#api-keys)
- [Building](#building)
- [Contributing](#contributing)
- [Community](#community)
- [Roadmap](#roadmap)
- [Troubleshooting](#troubleshooting)
- [License](#license)

---

## 🎯 About

POSA AI is an **open-source browser automation agent** that lets you control web browsers using natural language. Built with Flutter for cross-platform desktop support and Python's browser-use framework for intelligent web automation.

### Why POSA AI?

- 🤖 **AI-Powered** - Uses GPT-4, Claude 3, Gemini, and DeepSeek
- 🌐 **Cross-Platform** - Windows, macOS, Linux support via Flutter
- 🔓 **Open Source** - Fully transparent, community-driven development
- 🎯 **Real-Time** - Watch AI navigate with visual indicators
- 🛠️ **Extensible** - Built on open standards (Socket.IO, Playwright)

---

## ✨ Features

### Core Capabilities

- 🗣️ **Natural Language Commands** - Just describe what you want
- 👁️ **Visual Feedback** - See every click and action in real-time
- 🧠 **Multi-Model Support** - Choose between GPT-4, Claude 3, Gemini, DeepSeek
- 📑 **Multi-Tab Management** - Handle complex workflows
- 🔄 **Real-Time Logs** - Stream execution logs live
- 💾 **Local Storage** - Secure API key storage per model
- 🌍 **Multilingual** - Arabic and English support

### Technical Features

- ✅ Automatic Python backend setup
- ✅ Playwright Chromium auto-installation
- ✅ Socket.IO real-time communication
- ✅ Supabase authentication & user management
- ✅ Cross-platform desktop builds (Windows/macOS/Linux)

---

## 🎬 Demo

**Example Commands:**
```
"Go to Amazon and search for Samsung Galaxy S25"
"Find the best laptop under $1000 on eBay"
"Compare prices for iPhone 15 across 3 websites"
"Fill out this form with my information"
```

---

## 🏗️ Architecture

### System Overview

```
┌─────────────────────────────────┐
│     Flutter Desktop App         │
│  ┌───────────────────────────┐  │
│  │  UI Layer                 │  │
│  │  - browser_agent_screen   │  │
│  │  - Model selection UI     │  │
│  │  - Real-time logs display │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │  State Management         │  │
│  │  - Provider pattern       │  │
│  │  - backend_manage.dart    │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │  Services                 │  │
│  │  - Socket.IO Client       │  │
│  │  - SharedPreferences      │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
            │
            │ Socket.IO (localhost:5000)
            ▼
┌─────────────────────────────────┐
│     Python Backend              │
│  ┌───────────────────────────┐  │
│  │  Socket.IO Server         │  │
│  │  - app.py / app_secure.py │  │
│  │  - Task orchestration     │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │  Browser Automation       │  │
│  │  - browser-use framework  │  │
│  │  - Playwright             │  │
│  │  - Chromium control       │  │
│  └───────────────────────────┘  │
│  ┌───────────────────────────┐  │
│  │  AI Model Integration     │  │
│  │  - OpenAI API (GPT)       │  │
│  │  - Anthropic API (Claude) │  │
│  │  - Google API (Gemini)    │  │
│  │  - DeepSeek API           │  │
│  └───────────────────────────┘  │
└─────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────┐
│     Supabase Backend            │
│  - Authentication               │
│  - User management              │
│  - Plans & quotas               │
│  - Task tracking                │
└─────────────────────────────────┘
```

### Component Breakdown

**Frontend (`lib/` directory):**
- `lib/providers/backend_manage.dart` - Manages Python backend lifecycle (startup, pip install, Playwright setup)
- `lib/screens/agent_screens/browser_agent_screen.dart` - Main Agent UI (task input, model selection, logs, results)
- `lib/services/` - Business logic and API communication
- `lib/utils/constants.dart` - Configuration (Supabase credentials, default models)

**Backend (`backend/` directory):**
- `backend/app.py` - Main Socket.IO server for agent tasks
- `backend/app_secure.py` - Secure version with additional validation
- `backend/requirements.txt` - Python dependencies (Playwright, crypto, AI SDKs)
- `backend/setup_backend.py` - Script for bundling Python in release builds

**Key Communication Flow:**
1. User enters task in Flutter UI
2. Flutter sends task via Socket.IO to Python backend (localhost:5000)
3. Python backend uses browser-use + Playwright to control Chromium
4. AI model (GPT/Claude/Gemini/DeepSeek) provides intelligent navigation
5. Real-time logs stream back to Flutter UI
6. Final results displayed to user

### Technology Stack

**Frontend:**
- Flutter 3.x (Desktop support)
- Provider (State management)
- SharedPreferences (Local storage)
- Socket.IO Client

**Backend:**
- Python 3.10+
- Socket.IO Server
- Playwright (Browser automation)
- browser-use framework
- AI Model APIs (OpenAI, Anthropic, Google)

**Database:**
- Supabase (Auth, User management, Plans & Quotas)

### Supabase Database Schema

The app uses Supabase for user authentication and management. Here's the users table schema:

```sql
CREATE TABLE public.users (
  id bigint NOT NULL DEFAULT nextval('users_id_seq'::regclass),
  created_at timestamp with time zone DEFAULT now(),
  uid text NOT NULL UNIQUE,
  email text NOT NULL UNIQUE,
  role text NOT NULL,
  profileimage text DEFAULT ''::text,
  plan text DEFAULT 'Free'::text,
  taskcount integer DEFAULT 0,
  tasklimit integer DEFAULT 10,
  locale text DEFAULT 'en'::text,
  provider text DEFAULT 'email'::text,
  isverified boolean DEFAULT false,
  isbanned boolean DEFAULT false,
  referrerid text,
  orgid text,
  metadata json,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);
```

**Schema Fields:**
- `uid` - Unique user identifier (from Supabase Auth)
- `email` - User's email address
- `role` - User role (admin, user, etc.)
- `plan` - Subscription plan (Free, Pro, Enterprise)
- `taskcount` - Number of tasks executed
- `tasklimit` - Maximum tasks allowed per plan
- `locale` - User's language preference (en, ar)
- `provider` - Auth provider (email, google, etc.)

**Suggested Row-Level Security Policies:**
- Users can read and update their own row (match by `uid`)
- Admin role can read/write all rows

### Backend Auto-Bootstrap Process

When the Agent screen starts a task, the backend manager automatically:

1. **Detects Python** - Locates Python executable in system PATH
2. **Resolves Backend Path** - Finds `backend/` folder in Debug and Release layouts
3. **Installs Dependencies** - Runs `pip install -r requirements.txt` with live log streaming
4. **Sets up Playwright** - Downloads Chromium browser if missing (`python -m playwright install chromium`)
5. **Starts Socket.IO Server** - Launches on `http://localhost:5000`
6. **Port Management** - Automatically kills conflicting processes on port 5000 (Windows)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Python 3.10 or higher
- Git
- Windows 10/11, macOS 10.15+, or Linux

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/Hmida71/POSA_AI.git
cd POSA_AI
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Install Python dependencies**
```bash
cd backend
pip install -r requirements.txt
python -m playwright install chromium
cd ..
```

4. **Configure Supabase**

Update `lib/utils/constants.dart` with your Supabase credentials:

```dart
// Supabase Configuration
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

// Google Sign-In (if used)
static const String webClientId = 'YOUR_WEB_CLIENT_ID';
static const String iosClientId = 'YOUR_IOS_CLIENT_ID';

// Default AI Model
static const String defaultModel = 'gemini';
static const String defaultVersion = 'gemini-2.0-flash';
```

**Note:** The backend automatically normalizes `gemini-1.5-*` requests to `gemini-2.0-flash` to avoid runtime issues.

5. **Run the app**
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

---

## 💻 Usage

### Basic Workflow

1. **Launch POSA AI** and sign in with Supabase Auth
2. **Navigate to AI Browser Agent screen**
3. **Enter your task** (e.g., "Search for Python tutorials on YouTube")
4. **Select AI model and version:**
   - **Gemini** - `gemini-2.0-flash` (default), `gemini-1.5-pro`
   - **GPT** - `gpt-4`, `gpt-3.5-turbo`
   - **Claude** - `claude-3-opus`, `claude-3-sonnet`
   - **DeepSeek** - Various versions
5. **Provide API key** (stored locally per model via SharedPreferences)
6. **Toggle "Keep browser open"** if you want to inspect after completion
7. **Click Start** - Real-time logs stream, status updates appear, final result shown
8. **Control execution** with "Stop Task" or "Close Browser" buttons

### Advanced Features

**Auto Backend Setup:**
- First run automatically installs all Python dependencies
- Live log streaming shows installation progress
- Playwright Chromium downloads automatically
- No manual setup required!

**Model-Specific API Keys:**
- Each AI model has separate API key storage
- Keys persist across sessions
- Stored securely using SharedPreferences
- Never sent to external servers

**Multi-Language Support:**
- English (en) and Arabic (ar)
- User preference stored in Supabase
- UI adapts to selected language

### Configuration

```dart
// Default model settings (lib/utils/constants.dart)
static const String defaultModel = 'gemini';
static const String defaultVersion = 'gemini-2.0-flash';
```

### API Key Setup

API keys are stored locally using SharedPreferences:
- Each model has its own key storage
- Keys persist across sessions
- No keys are sent to external servers

---

## 🔑 API Keys

You'll need API keys from one or more providers:

| Provider | Model | Get API Key |
|----------|-------|-------------|
| OpenAI | GPT-4, GPT-3.5 | [platform.openai.com](https://platform.openai.com) |
| Anthropic | Claude 3 | [console.anthropic.com](https://console.anthropic.com) |
| Google | Gemini | [makersuite.google.com](https://makersuite.google.com) |
| DeepSeek | DeepSeek | [platform.deepseek.com](https://platform.deepseek.com) |

---

## 🛠️ Building

### Windows
```bash
flutter build windows --release
```
Output: `build/windows/runner/Release/`

### macOS
```bash
flutter build macos --release
```
Output: `build/macos/Build/Products/Release/`

### Linux
```bash
flutter build linux --release
```
Output: `build/linux/x64/release/bundle/`

### Android (APK)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS (requires macOS)
```bash
flutter build ios --release
```
Output: `build/ios/iphoneos/`

### Create Windows Installer

POSA AI includes Inno Setup configuration for professional Windows installers:

1. Build the Windows release (see above)
2. Copy `backend/` folder to `installer_source/app_files/backend/`
3. (Optional) Include embedded Python in `installer_source/app_files/python/`
4. Open `installer_source/setup_script.iss` in Inno Setup
5. Compile to create `POSA-AI-Setup.exe`

**Installer Features:**
- Self-contained with embedded Python (optional)
- Includes all backend files and dependencies
- Desktop shortcut creation
- Start menu integration
- Uninstaller included
- File size: ~150MB with all dependencies

---

## 🤝 Contributing

We ❤️ contributions! POSA AI is built by the community, for the community.

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit your changes** (`git commit -m 'Add amazing feature'`)
4. **Push to the branch** (`git push origin feature/amazing-feature`)
5. **Open a Pull Request**

### Contribution Guidelines

- 📝 Follow the existing code style
- ✅ Write tests for new features
- 📚 Update documentation
- 💬 Be respectful and constructive

### Areas We Need Help

- 🌍 **Translations** - Add more languages
- 🎨 **UI/UX** - Improve the interface
- 🐛 **Bug Fixes** - Find and fix issues
- 📚 **Documentation** - Improve guides
- 🧪 **Testing** - Write more tests
- 🚀 **Features** - Implement roadmap items

---

## 👥 Community

Join our growing community of developers!

- 💬 **Discord**: [Join our server](https://discord.gg/your-discord-link)
- 🐛 **Issues**: [Report bugs](https://github.com/Hmida71/POSA_AI/issues)
- 💡 **Discussions**: [Share ideas](https://github.com/Hmida71/POSA_AI/discussions)
- 🌟 **Star us**: If you like the project!
- 🏢 **Nexios**: [Our Company](https://www.nexios-dz.com/)

---

## 🗺️ Roadmap

### ✅ Completed
- [x] Multi-model AI support (GPT, Claude, Gemini, DeepSeek)
- [x] Real-time browser control
- [x] Cross-platform desktop support
- [x] Visual feedback system
- [x] Supabase authentication

### 🚧 In Progress
- [ ] Mobile support (Android/iOS)
- [ ] Chrome extension
- [ ] Cloud deployment option
- [ ] Plugin system

### 🔮 Future
- [ ] Voice command support
- [ ] Workflow recording & replay
- [ ] Team collaboration features
- [ ] Marketplace for automation scripts
- [ ] Docker containerization
- [ ] REST API endpoint

[Vote on features →](https://github.com/Hmida71/POSA_AI/discussions)

---

## 📂 Project Structure

```
POSA_AI/
├── lib/                              # Flutter application
│   ├── providers/                    # State management (Provider pattern)
│   │   └── backend_manage.dart       # Backend lifecycle management
│   │       - Python detection & path resolution
│   │       - Pip install with live log streaming
│   │       - Playwright setup automation
│   │       - Socket.IO server management
│   ├── screens/                      # UI screens
│   │   ├── agent_screens/
│   │   │   └── browser_agent_screen.dart  # Main Agent UI
│   │   │       - Task input & submission
│   │   │       - Model & version selection
│   │   │       - API key management
│   │   │       - Real-time log display
│   │   │       - Status & result views
│   │   ├── auth/                     # Authentication screens
│   │   └── settings/                 # Settings & preferences
│   ├── services/                     # Business logic
│   │   ├── socket_service.dart       # Socket.IO client
│   │   ├── supabase_service.dart     # Supabase integration
│   │   └── storage_service.dart      # Local storage (SharedPreferences)
│   ├── utils/                        # Utilities
│   │   ├── constants.dart            # Configuration constants
│   │   │   - Supabase credentials
│   │   │   - Default model settings
│   │   │   - API endpoints
│   │   └── helpers.dart              # Helper functions
│   └── l10n/                         # Localization files
│       ├── app_en.arb                # English translations
│       └── app_ar.arb                # Arabic translations
│
├── backend/                          # Python backend
│   ├── app.py                        # Main Socket.IO server
│   │   - Task orchestration
│   │   - Browser automation control
│   │   - AI model integration
│   ├── app_secure.py                 # Enhanced security version
│   ├── requirements.txt              # Python dependencies
│   │   - socketio, playwright
│   │   - browser-use framework
│   │   - AI SDK packages (openai, anthropic, google-generativeai)
│   │   - Crypto libraries
│   └── setup_backend.py              # Release build bundling script
│
├── windows/                          # Windows desktop runner
├── macos/                            # macOS desktop runner
├── linux/                            # Linux desktop runner
├── android/                          # Android mobile target
├── ios/                              # iOS mobile target
│
├── installer_source/                 # Windows installer assets (Inno Setup)
│   ├── app_files/                    # Embedded Python & backend
│   └── setup_script.iss              # Inno Setup configuration
│
├── test/                             # Test files
│   ├── widget_test.dart              # Flutter widget tests
│   └── unit_test.dart                # Unit tests
│
├── pubspec.yaml                      # Flutter dependencies
├── README.md                         # This file
├── LICENSE                           # MIT License
└── CONTRIBUTING.md                   # Contribution guidelines
```

### Key Files Explained

**`lib/providers/backend_manage.dart`**
- Manages entire Python backend lifecycle
- Detects Python installation and resolves paths
- Streams pip installation logs to UI in real-time
- Automatically sets up Playwright Chromium
- Handles Socket.IO server startup/shutdown
- Manages port conflicts (kills processes on port 5000)

**`lib/screens/agent_screens/browser_agent_screen.dart`**
- Complete Agent user interface
- Task input with validation
- Model dropdown (Gemini, GPT, Claude, DeepSeek)
- Version selection per model
- API key input with per-model storage
- Real-time log streaming display
- Status indicators (idle, running, complete, error)
- Final results visualization
- Browser control options (keep open, close)

**`backend/app.py`**
- Socket.IO server on localhost:5000
- Receives tasks from Flutter frontend
- Integrates with browser-use framework
- Controls Playwright for browser automation
- Communicates with AI models (OpenAI, Anthropic, Google, DeepSeek)
- Streams logs and status back to frontend
- Handles task execution, stopping, and cleanup

**`backend/requirements.txt`**
- All Python dependencies with versions
- Includes: playwright, socketio, browser-use
- AI SDKs: openai, anthropic, google-generativeai
- Crypto libraries: pycryptodome
- Auto-installed on first run

---

## 🐛 Troubleshooting

### Common Issues

**Python not found**
```bash
# Windows - Add Python to PATH
setx PATH "%PATH%;C:\Python310"

# Linux/macOS
export PATH="/usr/local/bin/python3:$PATH"

# Verify installation
python --version
```

**Playwright Chromium missing**
```bash
# Auto-installed on first run, but if needed:
python -m playwright install chromium

# If blocked by network policy, download manually
python -m playwright install --with-deps chromium
```

**Port 5000 already in use**
```bash
# Windows - Find and kill process
netstat -ano | findstr :5000
taskkill /PID <PID> /F

# Linux/macOS
lsof -ti:5000 | xargs kill -9

# Or use a different port (edit backend/app.py)
```

**Module 'Crypto' not found**
```bash
# Install pycryptodome
pip install pycryptodome

# Or reinstall all requirements
cd backend
pip install -r requirements.txt --force-reinstall
```

**Backend startup fails**
- Check Python is in PATH: `python --version`
- Ensure pip is installed: `python -m pip --version`
- Verify backend folder location (Debug vs Release layout)
- Check firewall isn't blocking port 5000
- Look for error logs in the app's log display

**Socket.IO connection failed**
- Verify backend is running (check for "Server running on port 5000" message)
- Ensure localhost:5000 is accessible
- Check firewall/antivirus isn't blocking local connections
- Try restarting the app

**API Key errors**
- Verify API key is correct for selected model
- Check API key has sufficient credits/quota
- Ensure correct model version is selected
- Keys are stored per model - don't mix them up

**Task execution fails**
- Check internet connection for AI API calls
- Verify the task description is clear and specific
- Some websites may block automation - try different sites
- Check backend logs for detailed error messages

**Supabase authentication issues**
- Verify Supabase URL and anon key in `lib/utils/constants.dart`
- Check Supabase project is active
- Ensure email confirmation if required
- Review Supabase Auth settings and policies

**Build errors**
```bash
# Clean build artifacts
flutter clean
flutter pub get

# Clear pub cache if needed
flutter pub cache repair

# Rebuild
flutter build windows --release
```

[More solutions →](https://github.com/Hmida71/POSA_AI/wiki/Troubleshooting)

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Hmida71, abenkoula71, Nexios & POSA AI Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 🙏 Acknowledgments

- **Created by**: [Hmida71](https://github.com/Hmida71) & [abenkoula71](https://github.com/abenkoula71)
- **Company**: [Nexios](https://www.nexios-dz.com/)
- Built on [browser-use](https://github.com/browser-use/browser-use) framework
- Powered by [Flutter](https://flutter.dev)
- Browser automation via [Playwright](https://playwright.dev)
- UI components inspired by the community

---

## 👨‍💻 Maintainers

- **Hmida71** - *Creator & Lead Developer* - [GitHub](https://github.com/Hmida71)
- **abenkoula71** - *Co-Creator & Nexios Founder* - [GitHub](https://github.com/abenkoula71)
- **Nexios** - *Development Company* - [Website](https://www.nexios-dz.com/)

See also the list of [contributors](https://github.com/Hmida71/POSA_AI/contributors) who participated in this project.

---

## 📊 Stats

![Alt](https://repobeats.axiom.co/api/embed/your-repo-id.svg "Repobeats analytics image")

---

<div align="center">

**⭐ Star us on GitHub — it motivates us a lot! ⭐**

[![Star History Chart](https://api.star-history.com/svg?repos=Hmida71/POSA_AI&type=Date)](https://star-history.com/#Hmida71/POSA_AI&Date)

Made with ❤️ by the POSA AI community

[Website](https://posa-ai.free.nf/) • [Nexios](https://www.nexios-dz.com/) • [GitHub](https://github.com/Hmida71/POSA_AI)

</div>