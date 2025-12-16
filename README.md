# SnapKill ⚡️

SnapKill is a lightweight, blisteringly fast macOS Menu Bar utility for killing processes instantly. No more opening Activity Monitor or typing frantic `kill -9` commands.

![SnapKill Demo](https://via.placeholder.com/800x400?text=SnapKill+Screenshot) 
*Note: Replace with standard screenshot after capture.*

## Features

- **⚡️ Instant Search**: Search by Process Name (e.g. `slack`) or Port Number (e.g. `8080`).
- **🎯 Precise Control**: Kill individual processes or "Kill All" matching results at once.
- **🛡 Safe & Secure**: Handles system permissions gracefully; filters benign kernel errors.
- **📂 Deep Insight**: Right-click to Copy PID, Path, or Port. Handles deep app paths (e.g. Chrome Helpers).
- **🚀 Native SwiftUI**: Built purely in SwiftUI for macOS 13+. Lightweight (< 5MB).

## Installation

### Build from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/SnapKill.git
   ```
2. Open `SnapKill.xcodeproj` in Xcode.
3. Build and Run (Cmd+R).
4. (Optional) Archive and Export as `SnapKill.app` for your Applications folder.

## Usage

1. Click the **lightning bolt icon** in your Menu Bar.
2. Type a name (e.g., `node`) or a port number (e.g., `3000`).
3. View results instantly.
4. Click the **Trash Icon** to kill a specific process.
5. Click **Kill All** to terminate everything in the list.
6. **Right-Click** any row to copy its PID, Path, or Port.

## Requirements

- macOS 13.0 (Ventura) or later.
- Xcode 14+ (to build).

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)
