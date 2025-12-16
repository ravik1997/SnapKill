# Release Notes

## v1.0.0 - Initial Release 🎉

**SnapKill** is a lightweight, blisteringly fast macOS Menu Bar utility for killing processes instantly.

### ✨ Features

- **⚡️ Instant Search**: Search by process name (e.g., `slack`) or port number (e.g., `8080`)
- **🎯 Precise Control**: Kill individual processes or "Kill All" matching results at once
- **📂 Deep Insight**: Click any process to reveal its full path; right-click to copy PID, Path, or Port
- **🚀 Launch at Login**: Toggle automatic startup from the settings menu
- **🌓 Theme Support**: Automatically adapts to Dark Mode and Light Mode
- **⌨️ Keyboard Shortcuts**: Press `Cmd+Q` to quit instantly

### 🖥️ System Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon or Intel Mac

### 📦 Installation

1. Download `SnapKill.zip` from the Assets below
2. Unzip and drag `SnapKill.app` to your Applications folder
3. On first launch, you may need to right-click → Open (or run `xattr -cr /path/to/SnapKill.app` in Terminal)

### 🔐 Permissions Note

SnapKill uses standard macOS commands (`lsof`, `pgrep`, `ps`, `kill`) to find and manage processes. No special permissions are required, but some system-protected processes may not be visible.

---

**Full Changelog**: https://github.com/ravik1997/SnapKill/commits/main
