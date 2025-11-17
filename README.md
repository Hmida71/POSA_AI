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

## 📸 Screenshots

<div align="center">

### Initialization
<img width="1036" height="682" alt="Screenshot 2025-11-16 132341" src="https://github.com/user-attachments/assets/63f0ef9d-2266-459d-91a4-37f2992dff49" />
*Please wait while the Posa AI backend downloads all required dependencies.*

### Main Dashboard
<img width="1235" height="793" alt="Screenshot 2025-11-16 132326" src="https://github.com/user-attachments/assets/8c90dc06-70fc-4ddf-bd98-5740d26d2aa3" />
*Clean and intuitive interface for browser automation*

### Agent in Action
<img width="1917" height="984" alt="Screenshot 2025-11-16 132711" src="https://github.com/user-attachments/assets/48d63a6c-5761-457c-bfab-a10adbb4b4a9" />
*Real-time visual feedback as AI navigates the web*


</div>

---

## 📖 Table of Contents

- [About](#about)
- [Screenshots](#screenshots)
- [Features](#features)
- [Demo](#demo)
- [How It Works](#how-it-works)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Gallery](#gallery)
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

## 🎬 Demo

<div align="center">

![Demo GIF](./screenshots/demo.gif)
*Watch POSA AI automate complex web tasks in real-time*

</div>

**Example Commands:**
```
"Go to Amazon and search for Samsung Galaxy S25"
"Find the best laptop under $1000 on eBay"
"Compare prices for iPhone 15 across 3 websites"
"Fill out this form with my information"
```

### Video Demo
[![POSA AI Demo Video](./screenshots/video-thumbnail.png)](https://youtu.be/your-video-link)

---

## 🎯 How It Works

<div align="center">

![How It Works](./screenshots/how-it-works.png)

</div>

1. **Enter Task** - Describe what you want in natural language
2. **AI Planning** - GPT/Claude/Gemini plans the automation steps
3. **Browser Control** - Playwright executes actions in real-time
4. **Visual Feedback** - See every click, scroll, and input
5. **Get Results** - Receive structured output or extracted data

---

## 🖼️ Gallery

<div align="center">

<table>
  <tr>
    <td align="center">
      <img src="./screenshots/feature-1.png" width="400px" alt="Feature 1"/>
      <br />
      <sub><b>Natural Language Commands</b></sub>
    </td>
    <td align="center">
      <img src="./screenshots/feature-2.png" width="400px" alt="Feature 2"/>
      <br />
      <sub><b>Multi-Tab Management</b></sub>
    </td>
  </tr>
  <tr>
    <td align="center">
      <img src="./screenshots/feature-3.png" width="400px" alt="Feature 3"/>
      <br />
      <sub><b>API Key Management</b></sub>
    </td>
    <td align="center">
      <img src="./screenshots/feature-4.png" width="400px" alt="Feature 4"/>
      <br />
      <sub><b>Cross-Platform Support</b></sub>
    </td>
  </tr>
</table>

</div>

---

## 🏗️ Architecture

<div align="center">

![Architecture Diagram](./screenshots/architecture.png)
*System architecture showing Flutter frontend, Python backend, and AI integration*

</div>

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
            │
            │ Socket.IO
            ▼
┌─────────────────────────────────┐
│     Python Backend              │
│  - Socket.IO Server             │
│  - Browser Automation           │
│  - AI Model Integration         │
└─────────────────────────────────┘
```

---

## 🚀 Getting Started

### Installation Steps

<div align="center">

![Installation Process](./screenshots/installation.png)

</div>

### Prerequisites

- Flutter SDK (latest stable)
- Python 3.10 or higher
- Git
- Windows 10/11, macOS 10.15+, or Linux

[Rest of your original content...]

---

## 💻 Usage

### Quick Start Guide

<div align="center">

![Usage Guide](./screenshots/usage-guide.png)

</div>

### Basic Workflow

1. **Launch POSA AI** and sign in with Supabase Auth
2. **Navigate to AI Browser Agent screen**
3. **Enter your task** (e.g., "Search for Python tutorials on YouTube")
4. **Select AI model and version**
5. **Provide API key**
6. **Click Start**

### Interface Overview

<div align="center">

<table>
  <tr>
    <td><img src="./screenshots/ui-task-input.png" alt="Task Input"/></td>
    <td><img src="./screenshots/ui-model-select.png" alt="Model Selection"/></td>
    <td><img src="./screenshots/ui-logs.png" alt="Live Logs"/></td>
  </tr>
  <tr>
    <td align="center"><b>Task Input</b></td>
    <td align="center"><b>Model Selection</b></td>
    <td align="center"><b>Live Logs</b></td>
  </tr>
</table>

</div>

---

## 🎨 Platform Support

<div align="center">

### Windows
![Windows Screenshot](./screenshots/windows.png)

### macOS
![macOS Screenshot](./screenshots/macos.png)

### Linux
![Linux Screenshot](./screenshots/linux.png)

</div>

---

## 🌍 Multilingual Support

<div align="center">

<table>
  <tr>
    <td align="center">
      <img src="./screenshots/english-ui.png" width="400px" alt="English UI"/>
      <br />
      <sub><b>English Interface</b></sub>
    </td>
    <td align="center">
      <img src="./screenshots/arabic-ui.png" width="400px" alt="Arabic UI"/>
      <br />
      <sub><b>Arabic Interface (RTL)</b></sub>
    </td>
  </tr>
</table>

</div>

---

[Rest of your original README content...]

---

## 📊 Performance

<div align="center">

![Performance Metrics](./screenshots/performance.png)

</div>

---

## 🏆 Success Stories

<div align="center">

![Success Story 1](./screenshots/success-1.png)
![Success Story 2](./screenshots/success-2.png)

</div>

---

<div align="center">

**⭐ Star us on GitHub — it motivates us a lot! ⭐**

[![Star History Chart](https://api.star-history.com/svg?repos=Hmida71/POSA_AI&type=Date)](https://star-history.com/#Hmida71/POSA_AI&Date)

Made with ❤️ by the POSA AI community

[Website](https://posa-ai.free.nf/) • [Nexios](https://www.nexios-dz.com/) • [GitHub](https://github.com/Hmida71/POSA_AI)

</div>
