# POMODORO TIMER by K9Fox

$script:pomoDataFile = "$env:USERPROFILE\.App\pomo_data.json"
$script:pomoConfigFile = "$env:USERPROFILE\.App\pomo_config.json"
$script:pomoSessionFile = "$env:USERPROFILE\.App\pomo_session.json"

# Default config
$script:defaultConfig = @{
    work = 25
    shortBreak = 5
    longBreak = 15
    cycles = 4
    autoStart = $false
    silent = $false
}

function Initialize-PomoFiles {
    # Create data 
    if (!(Test-Path $script:pomoDataFile)) {
        @{
            sessions = @()
            totalPomodoros = 0
        } | ConvertTo-Json | Set-Content $script:pomoDataFile
    }

    # Create config file
    if (!(Test-Path $script:pomoConfigFile)) {
        $script:defaultConfig | ConvertTo-Json | Set-Content $script:pomoConfigFile
    }
}

function Get-PomoConfig {
    Initialize-PomoFiles
    return Get-Content $script:pomoConfigFile | ConvertFrom-Json
}

function Save-PomoConfig {
    param($config)
    $config | ConvertTo-Json | Set-Content $script:pomoConfigFile
}

function Get-PomoData {
    Initialize-PomoFiles
    return Get-Content $script:pomoDataFile | ConvertFrom-Json
}

function Save-PomoData {
    param($data)
    $data | ConvertTo-Json -Depth 10 | Set-Content $script:pomoDataFile
}

function Save-PomoSession {
    param(
        [string]$type,
        [int]$duration,
        [string]$task,
        [int]$cycleCount
    )

    $data = Get-PomoData

    $session = @{
        date = (Get-Date).ToString("yyyy-MM-dd")
        time = (Get-Date).ToString("HH:mm:ss")
        type = $type
        duration = $duration
        task = $task
        cycleCount = $cycleCount
        completed = $true
    }

    $data.sessions += $session
    if ($type -eq "work") {
        $data.totalPomodoros++
    }

    Save-PomoData $data
}

function Start-PomoTimer {
    param(
        [int]$minutes,
        [string]$type,
        [string]$message,
        [string]$task = "",
        [int]$cycleCount = 1,
        [switch]$silent
    )

    $totalSeconds = $minutes * 60
    $endTime = (Get-Date).AddSeconds($totalSeconds)

    $emoji = switch ($type) {
        "work" { "🍅" }
        "short" { "☕" }
        "long" { "🎉" }
    }

    $title = switch ($type) {
        "work" { "WORK SESSION" }
        "short" { "SHORT BREAK" }
        "long" { "LONG BREAK" }
    }

    try {
        while ((Get-Date) -lt $endTime) {
            $remaining = ($endTime - (Get-Date)).TotalSeconds
            $min = [math]::Floor($remaining / 60)
            $sec = [math]::Floor($remaining % 60)

            # Progress
            $elapsed = $totalSeconds - $remaining
            $progress = [math]::Floor(($elapsed / $totalSeconds) * 100)

            # Progress bar
            $barLength = 40
            $filledLength = [math]::Floor($barLength * $progress / 100)
            $bar = "█" * $filledLength + "░" * ($barLength - $filledLength)

            Clear-Host
            Write-Host "`n$emoji POMODORO #$cycleCount - $title`n" -ForegroundColor Cyan

            if ($task) {
                Write-Host "Task: $task`n" -ForegroundColor Yellow
            }

            Write-Host "$bar  $($min.ToString('00')):$($sec.ToString('00')) / $($minutes):00" -ForegroundColor Green
            Write-Host "$progress% Complete`n" -ForegroundColor Gray

            $nextSession = if ($type -eq "work") {
                if ($cycleCount % 4 -eq 0) { "Long Break" } else { "Short Break" }
            } else {
                "Work Session"
            }

            Write-Host "Next: $nextSession" -ForegroundColor Magenta
            Write-Host "Press Ctrl+C to pause" -ForegroundColor DarkGray

            Start-Sleep -Milliseconds 500
        }

        # Session completed
        Clear-Host
        Write-Host "`n$emoji $title COMPLETED! $emoji`n" -ForegroundColor Green
        Write-Host "$message`n" -ForegroundColor Yellow

        # Save session
        Save-PomoSession -type $type -duration $minutes -task $task -cycleCount $cycleCount

        # Beep
        if (!$silent) {
            for ($i = 0; $i -lt 5; $i++) {
                [Console]::Beep(800, 200)
                Start-Sleep -Milliseconds 100
            }
        }

        return $true
    }
    catch {
        Write-Host "`n`n⏸️  Session paused" -ForegroundColor Yellow
        return $false
    }
}

function pomo {
    param(
        [Parameter(Position=0)]
        [string]$action,

        [Parameter(Position=1)]
        [string]$task = "",

        [int]$work,
        [int]$break,
        [int]$long,
        [int]$cycles,
        [switch]$auto,
        [switch]$silent,
        [switch]$visual
    )

    Initialize-PomoFiles
    $config = Get-PomoConfig

    switch ($action) {
        {$_ -eq "" -or $_ -eq "start"} {
            $workMin = if ($work) { $work } else { $config.work }
            $shortBreakMin = if ($break) { $break } else { $config.shortBreak }
            $longBreakMin = if ($long) { $long } else { $config.longBreak }
            $maxCycles = if ($cycles) { $cycles } else { $config.cycles }
            $autoStart = if ($auto) { $true } else { $config.autoStart }
            $silentMode = if ($silent) { $true } else { $config.silent }

            Write-Host "`n🍅 Starting Pomodoro Session" -ForegroundColor Cyan
            if ($task) {
                Write-Host "Task: $task`n" -ForegroundColor Yellow
            }
            Write-Host "Config: ${workMin}min work, ${shortBreakMin}min short break, ${longBreakMin}min long break" -ForegroundColor Gray
            Write-Host "Cycles: $maxCycles`n" -ForegroundColor Gray
            Start-Sleep -Seconds 2

            $cycleCount = 1
            $completedPomodoros = 0

            while ($cycleCount -le $maxCycles) {
                # Work session
                $completed = Start-PomoTimer -minutes $workMin -type "work" -message "Time for a break!" -task $task -cycleCount $cycleCount -silent:$silentMode

                if (!$completed) { break }

                $completedPomodoros++

                if ($cycleCount -ge $maxCycles) { break }

                # Break session
                if ($cycleCount % 4 -eq 0) {
                    # Long break after 4 cycles
                    if (!$autoStart) {
                        Write-Host "Press Enter to start long break..." -ForegroundColor Yellow
                        Read-Host
                    } else {
                        Start-Sleep -Seconds 3
                    }

                    $completed = Start-PomoTimer -minutes $longBreakMin -type "long" -message "Great work! Ready for more?" -task $task -cycleCount $cycleCount -silent:$silentMode
                } else {
                    # Short break
                    if (!$autoStart) {
                        Write-Host "Press Enter to start short break..." -ForegroundColor Yellow
                        Read-Host
                    } else {
                        Start-Sleep -Seconds 3
                    }

                    $completed = Start-PomoTimer -minutes $shortBreakMin -type "short" -message "Back to work!" -task $task -cycleCount $cycleCount -silent:$silentMode
                }

                if (!$completed) { break }

                $cycleCount++

                if (!$autoStart -and $cycleCount -le $maxCycles) {
                    Write-Host "Press Enter to continue to next pomodoro..." -ForegroundColor Yellow
                    Read-Host
                } else {
                    Start-Sleep -Seconds 3
                }
            }

            # Session summary
            Write-Host "`n✅ SESSION COMPLETE!" -ForegroundColor Green
            Write-Host "Completed Pomodoros: $completedPomodoros" -ForegroundColor Cyan
            Write-Host ""
        }

        "stats" {
            $data = Get-PomoData

            Write-Host "`n📊 POMODORO STATISTICS`n" -ForegroundColor Cyan

            # Today
            $today = (Get-Date).ToString("yyyy-MM-dd")
            $todayPomodoros = ($data.sessions | Where-Object { $_.date -eq $today -and $_.type -eq "work" }).Count

            # This week
            $weekStart = (Get-Date).AddDays(-((Get-Date).DayOfWeek.value__))
            $weekPomodoros = ($data.sessions | Where-Object {
                [DateTime]::Parse($_.date) -ge $weekStart -and $_.type -eq "work"
            }).Count

            Write-Host "Today:        $todayPomodoros pomodoros ✓" -ForegroundColor White
            Write-Host "This Week:    $weekPomodoros pomodoros" -ForegroundColor White
            Write-Host "Total:        $($data.totalPomodoros) pomodoros" -ForegroundColor White
            Write-Host ""

            # Streak
            $dates = $data.sessions | Where-Object { $_.type -eq "work" } |
                     Select-Object -ExpandProperty date | Sort-Object -Unique |
                     ForEach-Object { [DateTime]::Parse($_) }

            $streak = 0
            $currentDate = Get-Date
            foreach ($date in ($dates | Sort-Object -Descending)) {
                if (($currentDate - $date).Days -le 1) {
                    $streak++
                    $currentDate = $date
                } else {
                    break
                }
            }

            if ($streak -gt 0) {
                Write-Host "Streak:       $streak days 🔥" -ForegroundColor Yellow
            }

            Write-Host ""
        }

        "today" {
            $data = Get-PomoData
            $today = (Get-Date).ToString("yyyy-MM-dd")
            $todaySessions = $data.sessions | Where-Object { $_.date -eq $today }

            Write-Host "`n📅 TODAY'S SESSIONS`n" -ForegroundColor Cyan

            if ($todaySessions.Count -eq 0) {
                Write-Host "No sessions today yet!" -ForegroundColor Yellow
            } else {
                foreach ($session in $todaySessions) {
                    $emoji = switch ($session.type) {
                        "work" { "🍅" }
                        "short" { "☕" }
                        "long" { "🎉" }
                    }

                    $typeText = switch ($session.type) {
                        "work" { "Work" }
                        "short" { "Short Break" }
                        "long" { "Long Break" }
                    }

                    Write-Host "$emoji $($session.time) - $typeText ($($session.duration) min)" -ForegroundColor White
                    if ($session.task) {
                        Write-Host "   Task: $($session.task)" -ForegroundColor Gray
                    }
                }

                $workCount = ($todaySessions | Where-Object { $_.type -eq "work" }).Count
                Write-Host "`nTotal Pomodoros: $workCount" -ForegroundColor Cyan
            }
            Write-Host ""
        }

        "config" {
            if ($work -or $break -or $long -or $cycles) {
                # Update config
                $config = Get-PomoConfig
                if ($work) { $config.work = $work }
                if ($break) { $config.shortBreak = $break }
                if ($long) { $config.longBreak = $long }
                if ($cycles) { $config.cycles = $cycles }
                if ($auto) { $config.autoStart = $true }
                if ($silent) { $config.silent = $true }

                Save-PomoConfig $config
                Write-Host "`n✓ Configuration updated!" -ForegroundColor Green
            }

            # Display config
            $config = Get-PomoConfig
            Write-Host "`n⚙️  POMODORO CONFIGURATION`n" -ForegroundColor Cyan
            Write-Host "Work Duration:       $($config.work) minutes" -ForegroundColor White
            Write-Host "Short Break:         $($config.shortBreak) minutes" -ForegroundColor White
            Write-Host "Long Break:          $($config.longBreak) minutes" -ForegroundColor White
            Write-Host "Cycles per session:  $($config.cycles)" -ForegroundColor White
            Write-Host "Auto-start:          $($config.autoStart)" -ForegroundColor White
            Write-Host "Silent mode:         $($config.silent)" -ForegroundColor White
            Write-Host ""
        }

        "reset" {
            Write-Host "`n⚠️  This will reset all statistics. Continue? (y/n): " -ForegroundColor Yellow -NoNewline
            $confirm = Read-Host

            if ($confirm -eq "y") {
                @{
                    sessions = @()
                    totalPomodoros = 0
                } | ConvertTo-Json | Set-Content $script:pomoDataFile

                Write-Host "✓ Statistics reset!" -ForegroundColor Green
            } else {
                Write-Host "Cancelled" -ForegroundColor Gray
            }
            Write-Host ""
        }

        {$_ -eq "help" -or $_ -eq "?"} {
            Write-Host "`n🍅 POMODORO TIMER - HELP`n" -ForegroundColor Cyan

            Write-Host "Main Commands:" -ForegroundColor Yellow
            Write-Host "  pomo                           - Start default pomodoro" -ForegroundColor White
            Write-Host "  pomo start                     - Same as pomo" -ForegroundColor White
            Write-Host "  pomo start 'task name'         - Start with task description" -ForegroundColor White
            Write-Host ""

            Write-Host "Custom Duration:" -ForegroundColor Yellow
            Write-Host "  pomo -work 50 -break 10        - Custom work/break duration" -ForegroundColor White
            Write-Host "  pomo -long 20 -cycles 6        - Custom long break and cycles" -ForegroundColor White
            Write-Host ""

            Write-Host "Options:" -ForegroundColor Yellow
            Write-Host "  pomo -auto                     - Auto-start next session" -ForegroundColor White
            Write-Host "  pomo -silent                   - No beep sounds" -ForegroundColor White
            Write-Host ""

            Write-Host "Statistics:" -ForegroundColor Yellow
            Write-Host "  pomo stats                     - View statistics" -ForegroundColor White
            Write-Host "  pomo today                     - Today's sessions" -ForegroundColor White
            Write-Host ""

            Write-Host "Configuration:" -ForegroundColor Yellow
            Write-Host "  pomo config                    - View current config" -ForegroundColor White
            Write-Host "  pomo config -work 25           - Update default config" -ForegroundColor White
            Write-Host "  pomo reset                     - Reset all statistics" -ForegroundColor White
            Write-Host ""

            Write-Host "During Session:" -ForegroundColor Yellow
            Write-Host "  Ctrl+C                         - Pause/Stop session" -ForegroundColor White
            Write-Host ""
        }

        default {
            Write-Host "Unknown command. Use 'pomo help' for help." -ForegroundColor Red
        }
    }
}
