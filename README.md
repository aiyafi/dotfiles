# dotfiles

Personal configuration files for Windows PowerShell and Linux Hyprland environments.

## Overview

This repository contains my customized development environment configurations:

- **Windows PowerShell**: Custom profile with productivity utilities and terminal enhancements
- **Linux Hyprland**: Wayland compositor configuration with Waybar and theming (coming soon)

## Why This Exists

I created this PowerShell configuration after debloating my Windows installation. When I remove the default Windows apps (Calendar, Clock, Camera, Timer, etc.), I lose access to basic productivity tools. Rather than reinstalling bloated apps, I built lightweight PowerShell alternatives that run entirely in the terminal.

This repository started as a personal checkpoint to backup my configurations, but I decided to make it public in case others find it useful. The Linux Hyprland configuration is still a work in progress. I haven't finished my final rice yet, so it's not ready for public release.

## Features

### Windows PowerShell Utilities

- **cal** - Interactive calendar with Japanese era support
- **clock** - Multi-mode clock with timer, stopwatch, alarm, and world clock
- **pomo** - Full-featured Pomodoro timer with statistics tracking
- **todo** - Simple command-line todo list manager
- **weather** - Terminal weather display using wttr.in
- **camtro** - ASCII webcam viewer with color support
- **media** - YouTube download utilities (yt-dlp wrapper)

## Installation

### Windows PowerShell

1. Clone this repository:
```powershell
cd dotfiles
```

2. Copy or link the PowerShell profile:
```powershell
# Option 1: Copy files
Copy-Item -Path "windows/pwsh/*" -Destination $PROFILE\..\

# Option 2: Create symbolic link
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$PWD\windows\pwsh\profile.ps1"
```

3. Reload your PowerShell profile:
```powershell
. $PROFILE
```

### Linux Hyprland

Coming soon.

## Usage

See individual README files for detailed usage:

- [Windows PowerShell README](windows/pwsh/README.md)
- [Linux Hyprland README](linux/hyprland/README.md)

## Requirements

### Windows PowerShell

- PowerShell 5.1 or later (PowerShell 7+ recommended)
- Python 3.x (for camtro)
- OpenCV (auto-installed by camtro)
- yt-dlp (optional, for media functions)
- curl (for weather)

### Linux Hyprland

Coming soon.

## Structure

```
dotfiles/
├── README.md
├── LICENSE
├── windows/
│   └── pwsh/
│       ├── profile.ps1
│       ├── cal.ps1
│       ├── clock.ps1
│       ├── pomo.ps1
│       ├── todo.ps1
│       ├── weather.ps1
│       ├── media.ps1
│       ├── camtro.ps1
│       └── README.md
└── linux/
    └── hyprland/
        ├── hyprland.conf
        ├── hyprpaper.conf
        ├── waybar/
        │   ├── config
        │   └── style.css
        └── README.md
```

## Contributing

Feel free to fork this repository and adapt it to your needs. Pull requests for improvements are welcome.

## License

MIT License - See [LICENSE](LICENSE) file for details.

## Acknowledgments

- Calendar inspired by traditional Unix `cal` command
- Clock inspired by clock-rs
- Weather powered by [wttr.in](https://github.com/chubin/wttr.in)
- Media utilities use [yt-dlp](https://github.com/yt-dlp/yt-dlp)
