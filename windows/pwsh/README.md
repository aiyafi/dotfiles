# Windows PowerShell Configuration

Custom PowerShell profile with productivity utilities and terminal enhancements.

## Features

### 📅 cal - Interactive Calendar

Display calendars with Japanese era support and interactive navigation.

**Usage:**
```powershell
cal                    # Show current month
cal 12 2025           # Show specific month/year
cal all               # Interactive mode (arrow key navigation)
cal help              # Show help
```

**Interactive Mode:**
- `←` / `→` - Navigate months
- `h` - Jump to today
- `q` - Quit

**Features:**
- Highlights current day
- Japanese era display (Reiwa, Heisei, etc.)
- Centered terminal display
- Clean, minimal interface

---

### ⏰ clock - Multi-Mode Clock

ASCII art clock with timer, stopwatch, alarm, and world clock features.

**Usage:**
```powershell
clock                              # Live ASCII clock
clock timer 25                     # 25-minute timer
clock timer 0 30 "Tea ready!"      # 30-second timer with message
clock stopwatch                    # Start stopwatch
clock alarm 14 30 "Meeting time"   # Set alarm for 2:30 PM
clock world                        # World clock display
clock help                         # Show help
```

**Timer Features:**
- Visual countdown with progress
- Custom messages
- Audio notification (beep)
- Ctrl+C to cancel

**Stopwatch Features:**
- Precise timing with milliseconds
- Space to pause/resume
- Ctrl+C to stop

**Alarm Features:**
- Set specific time (24-hour format)
- Snooze function (5 minutes)
- Repeating notification sound
- Press Q to dismiss, S to snooze

**World Clock:**
- Jakarta/Bandung
- Tokyo
- London
- New York
- Los Angeles
- Sydney

---

### 🍅 pomo - Pomodoro Timer

Full-featured Pomodoro technique timer with statistics tracking.

**Usage:**
```powershell
pomo                               # Start default session (25/5/15)
pomo start "Write documentation"   # Start with task name
pomo -work 50 -break 10           # Custom durations
pomo -auto                        # Auto-start breaks
pomo -silent                      # No sound notifications
pomo stats                        # View statistics
pomo today                        # Today's sessions
pomo config                       # View/edit configuration
pomo help                         # Show help
```

**Default Configuration:**
- Work: 25 minutes
- Short break: 5 minutes
- Long break: 15 minutes
- Cycles: 4 (long break after 4th cycle)

**Features:**
- Progress bar visualization
- Session tracking and statistics
- Daily/weekly/total pomodoro counts
- Streak tracking
- Persistent data storage
- Configurable durations
- Auto-start mode
- Silent mode

**Statistics:**
- Today's pomodoros
- Weekly count
- Total lifetime count
- Current streak

**Data Storage:**
- Config: `~/.App/pomo_config.json`
- Data: `~/.App/pomo_data.json`

---

### ✅ todo - Todo List Manager

Simple command-line todo list with persistent storage.

**Usage:**
```powershell
todo                              # Show all todos
todo add "Buy groceries"          # Add new todo
todo done 1                       # Mark todo #1 as done
todo edit 2 "Updated task"        # Edit todo #2
todo remove 3                     # Delete todo #3
todo clear                        # Clear all todos
todo help                         # Show help
```

**Features:**
- Checkbox-style display
- Visual completion markers (✓)
- Color-coded (green for completed)
- Persistent storage
- Simple numbered interface

**Data Storage:**
- File: `~/.App/todo.txt`

---

### 🌤️ weather - Terminal Weather

Display weather information using wttr.in service.

**Usage:**
```powershell
weather                # Show weather for default city
weather Tokyo          # Show weather for specific location
weather "New York"     # Use quotes for multi-word locations
```

**Features:**
- Current conditions
- 3-day forecast
- Moon phase
- Wind, humidity, visibility
- Sunrise/sunset times
- Powered by [wttr.in](https://github.com/chubin/wttr.in)

**Configuration:**
Edit `weather.ps1` to set your default city:
```powershell
$defaultCity = "YourCity"
```

---

### 🎥 camtro - ASCII Webcam

Real-time ASCII art from your webcam with optional RGB color support.

**Usage:**
```powershell
camtro                 # Start grayscale ASCII webcam
camtro -color          # Start with RGB colors
camtro -width 80       # Custom width (default: 120)
camtro -color -w 100   # Color mode with custom width
camtro -help           # Show help
```

**Features:**
- Real-time ASCII conversion
- RGB color mode (true color)
- Adjustable resolution
- Auto-installs OpenCV if needed
- Mirror-corrected display
- Frame counter

**Requirements:**
- Python 3.x
- OpenCV (auto-installed on first run)

**Controls:**
- Ctrl+C to stop

**Performance Tips:**
- Smaller width = faster performance
- Color mode uses more resources
- Works best in dark mode terminal

---

### 📺 media - YouTube Utilities

Wrapper functions for yt-dlp to download videos easily.

**Usage:**
```powershell
yt <url>               # Download best quality
yt1080 <url>           # Download 1080p
yt720 <url>            # Download 720p
yt480 <url>            # Download 480p
youtube                # Open YouTube homepage
youtube "search term"  # Search YouTube
```

**Requirements:**
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) installed and in PATH

**Download Location:**
- Default: `C:\Users\{username}\ytdlp\`

**Configuration:**
Edit `media.ps1` to change download location:
```powershell
-o "C:\Your\Custom\Path\%(title)s.%(ext)s"
```

---

## Installation

### Quick Setup

1. Clone this repository
2. Copy scripts to your PowerShell profile directory:
```powershell
Copy-Item -Path "windows/pwsh/*.ps1" -Destination "$env:USERPROFILE\.App\pwsh\"
```

3. Add to your PowerShell profile (`$PROFILE`):
```powershell
# Load custom functions
Get-ChildItem "$env:USERPROFILE\.App\pwsh\*.ps1" | ForEach-Object { . $_.FullName }
```

4. Reload profile:
```powershell
. $PROFILE
```

### Manual Setup

1. Create directory structure:
```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.App\pwsh" -Force
New-Item -ItemType Directory -Path "$env:USERPROFILE\.App\pwsh\scripts" -Force
```

2. Copy individual scripts:
```powershell
Copy-Item cal.ps1 "$env:USERPROFILE\.App\pwsh\"
Copy-Item clock.ps1 "$env:USERPROFILE\.App\pwsh\"
Copy-Item pomo.ps1 "$env:USERPROFILE\.App\pwsh\"
Copy-Item todo.ps1 "$env:USERPROFILE\.App\pwsh\"
Copy-Item weather.ps1 "$env:USERPROFILE\.App\pwsh\"
Copy-Item camtro.ps1 "$env:USERPROFILE\.App\pwsh\"
Copy-Item media.ps1 "$env:USERPROFILE\.App\pwsh\"
Copy-Item ascii_cam.py "$env:USERPROFILE\.App\pwsh\scripts\"
```

3. Source in profile as shown above

---

## Requirements

### Core Requirements
- PowerShell 5.1+ (PowerShell 7+ recommended)
- Windows 10/11

### Optional Requirements
- **Python 3.x** - For camtro
- **OpenCV** - Auto-installed by camtro
- **yt-dlp** - For media functions
- **curl** - For weather (usually pre-installed)

### Installing Optional Tools

**Python:**
```powershell
winget install Python.Python.3.12
```

**yt-dlp:**
```powershell
winget install yt-dlp.yt-dlp
```

---

## Configuration

### Weather Default City

Edit `weather.ps1`:
```powershell
$defaultCity = "YourCity"
```

### Media Download Path

Edit `media.ps1`:
```powershell
-o "C:\Your\Path\%(title)s.%(ext)s"
```

### Pomodoro Defaults

Use the config command:
```powershell
pomo config -work 50 -break 10 -long 20 -cycles 6
```

Or edit directly: `~/.App/pomo_config.json`

---

## Data Storage

All utilities store data in `~/.App/`:

```
~/.App/
├── pomo_config.json    # Pomodoro configuration
├── pomo_data.json      # Pomodoro statistics
└── todo.txt            # Todo list items
```

---

## Troubleshooting

### Scripts not loading

Check execution policy:
```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Camtro camera not working

1. Close other apps using the camera
2. Check Windows camera permissions
3. Try running PowerShell as administrator
4. Verify Python installation: `python --version`

### Weather not displaying

1. Check internet connection
2. Verify curl is available: `curl --version`
3. Try different location name

### Pomodoro/Todo data not saving

1. Ensure `~/.App/` directory exists
2. Check write permissions
3. Manually create directory:
```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.App" -Force
```

---

## Tips & Tricks

### Aliases

Add custom aliases to your profile:
```powershell
Set-Alias -Name t -Value todo
Set-Alias -Name p -Value pomo
Set-Alias -Name w -Value weather
```

### Startup Commands

Add to profile for automatic execution:
```powershell
# Show calendar on startup
cal

# Show today's todos
todo
```

### Keyboard Shortcuts

Create custom keybindings in your profile:
```powershell
Set-PSReadLineKeyHandler -Chord 'Ctrl+t' -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('todo')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
```

---

## Credits

- **cal** - Inspired by Unix `cal` command
- **clock** - Inspired by clock-rs
- **weather** - Powered by [wttr.in](https://github.com/chubin/wttr.in)
- **media** - Uses [yt-dlp](https://github.com/yt-dlp/yt-dlp)

---

## License

MIT License - See root LICENSE file for details.
