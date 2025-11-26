# Clock-rs inspired for pwsh By K9Fox

# ASCII Art 
$script:asciiDigits = @{
    '0' = @(
        "███████"
        "██   ██"
        "██   ██"
        "██   ██"
        "██   ██"
        "██   ██"
        "███████"
    )
    '1' = @(
        "    ██"
        "    ██"
        "    ██"
        "    ██"
        "    ██"
        "    ██"
        "    ██"
    )
    '2' = @(
        "███████"
        "     ██"
        "     ██"
        "███████"
        "██     "
        "██     "
        "███████"
    )
    '3' = @(
        "███████"
        "     ██"
        "     ██"
        "███████"
        "     ██"
        "     ██"
        "███████"
    )
    '4' = @(
        "██   ██"
        "██   ██"
        "██   ██"
        "███████"
        "     ██"
        "     ██"
        "     ██"
    )
    '5' = @(
        "███████"
        "██     "
        "██     "
        "███████"
        "     ██"
        "     ██"
        "███████"
    )
    '6' = @(
        "███████"
        "██     "
        "██     "
        "███████"
        "██   ██"
        "██   ██"
        "███████"
    )
    '7' = @(
        "███████"
        "     ██"
        "     ██"
        "     ██"
        "     ██"
        "     ██"
        "     ██"
    )
    '8' = @(
        "███████"
        "██   ██"
        "██   ██"
        "███████"
        "██   ██"
        "██   ██"
        "███████"
    )
    '9' = @(
        "███████"
        "██   ██"
        "██   ██"
        "███████"
        "     ██"
        "     ██"
        "███████"
    )
    ':' = @(
        "  "
        "██"
        "  "
        "  "
        "██"
        "  "
        "  "
    )
}

function Get-AsciiTime {
    param([string]$time)

    $lines = @("", "", "", "", "", "", "")

    foreach ($char in $time.ToCharArray()) {
        $digit = $script:asciiDigits[$char.ToString()]
        for ($i = 0; $i -lt 7; $i++) {
            # Add single space for colon, double space for digits
            $spacing = if ($char -eq ':') { " " } else { "  " }
            $lines[$i] += $digit[$i] + $spacing
        }
    }

    return $lines
}

function Get-CenteredPadding {
    param([string]$text)

    try {
        $terminalWidth = $Host.UI.RawUI.WindowSize.Width
        $textLength = $text.Length
        $padding = [math]::Max(0, [math]::Floor(($terminalWidth - $textLength) / 2))
        return " " * $padding
    }
    catch {
        return " " * 5
    }
}

function clock {
    param(
        [string]$action,
        [int]$minutes,
        [int]$seconds,
        [string]$message
    )

    switch ($action) {
        "timer" {
            if (!$minutes -and !$seconds) {
                Write-Host "Usage: clock timer <minutes> [seconds] ['message']" -ForegroundColor Yellow
                Write-Host "Example: clock timer 5" -ForegroundColor Gray
                Write-Host "Example: clock timer 0 30 'Tea is ready!'" -ForegroundColor Gray
                return
            }
            Start-Timer -Minutes $minutes -Seconds $seconds -Message $message
        }

        "stopwatch" {
            Start-Stopwatch
        }

        "world" {
            Show-WorldClock
        }

        "alarm" {
            if (!$minutes -and !$seconds) {
                Write-Host "Usage: clock alarm <hour> <minute> ['message']" -ForegroundColor Yellow
                Write-Host "Example: clock alarm 14 30" -ForegroundColor Gray
                Write-Host "Example: clock alarm 7 0 'Wake up!'" -ForegroundColor Gray
                return
            }
            Start-Alarm -Hour $minutes -Minute $seconds -Message $message
        }

        {$_ -eq "help" -or $_ -eq "?"} {
            Write-Host "`n⏰ CLOCK Commands:`n" -ForegroundColor Cyan
            Write-Host "  clock                          - Live clock (realtime)" -ForegroundColor White
            Write-Host "  clock timer <min> [sec] [msg]  - Start countdown timer" -ForegroundColor White
            Write-Host "  clock stopwatch                - Start stopwatch" -ForegroundColor White
            Write-Host "  clock alarm <hour> <min> [msg] - Set alarm for specific time" -ForegroundColor White
            Write-Host "  clock world                    - World clock (multiple timezones)" -ForegroundColor White
            Write-Host "  clock help / clock ?           - Show this help`n" -ForegroundColor White
        }

        default {
            try {
                [Console]::CursorVisible = $false

                while ($true) {
                    $now = Get-Date
                    $date = $now.ToString("dddd, MMMM dd, yyyy")
                    $time = $now.ToString("HH:mm:ss")

                    Clear-Host

                    Write-Host "`n`n" -NoNewline

                    $asciiLines = Get-AsciiTime -time $time

                    foreach ($line in $asciiLines) {
                        $padding = Get-CenteredPadding -text $line
                        Write-Host "$padding$line" -ForegroundColor Magenta
                    }

                    $datePadding = Get-CenteredPadding -text $date
                    Write-Host "`n$datePadding$date`n" -ForegroundColor White

                    Start-Sleep -Milliseconds 100
                }
            }
            catch {
                Write-Host "`n✓ Clock stopped" -ForegroundColor Yellow
            }
            finally {
                # Always restore cursor visibility
                [Console]::CursorVisible = $true
            }
        }
    }
}

function Start-Timer {
    param(
        [int]$Minutes = 0,
        [int]$Seconds = 0,
        [string]$Message = "Time's up!"
    )

    $totalSeconds = ($Minutes * 60) + $Seconds

    if ($totalSeconds -eq 0) {
        Write-Host "Invalid time!" -ForegroundColor Red
        return
    }

    Write-Host "`n⏱️  Timer started for " -NoNewline -ForegroundColor Cyan
    if ($Minutes -gt 0) {
        Write-Host "$Minutes min " -NoNewline -ForegroundColor Yellow
    }
    if ($Seconds -gt 0) {
        Write-Host "$Seconds sec" -NoNewline -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Press Ctrl+C to cancel`n" -ForegroundColor Gray

    $endTime = (Get-Date).AddSeconds($totalSeconds)

    try {
        while ((Get-Date) -lt $endTime) {
            $remaining = ($endTime - (Get-Date)).TotalSeconds
            $min = [math]::Floor($remaining / 60)
            $sec = [math]::Floor($remaining % 60)

            Write-Host "`r⏱️  $($min.ToString('00')):$($sec.ToString('00')) " -NoNewline -ForegroundColor Green
            Start-Sleep -Milliseconds 100
        }

        Write-Host "`n`n🔔 $Message" -ForegroundColor Yellow

        # Beep beep beep!
        for ($i = 0; $i -lt 3; $i++) {
            [Console]::Beep(800, 300)
            Start-Sleep -Milliseconds 200
        }
    }
    catch {
        Write-Host "`n`n❌ Timer cancelled" -ForegroundColor Red
    }
}

function Start-Stopwatch {
    Write-Host "`n⏱️  Stopwatch started" -ForegroundColor Cyan
    Write-Host "Press [Space] to pause/resume | Ctrl+C to stop`n" -ForegroundColor Gray

    $startTime = Get-Date
    $pausedTime = [TimeSpan]::Zero
    $isPaused = $false
    $pauseStartTime = $null

    try {
        while ($true) {
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)

                if ($key.Key -eq 'Spacebar') {
                    if ($isPaused) {
                        # Resume
                        $pausedTime += (Get-Date) - $pauseStartTime
                        $isPaused = $false
                        Write-Host "`r⏱️  Resumed" -NoNewline -ForegroundColor Yellow
                        Start-Sleep -Milliseconds 500
                    }
                    else {
                        $pauseStartTime = Get-Date
                        $isPaused = $true
                    }
                }
            }

            if ($isPaused) {
                $elapsed = $pauseStartTime - $startTime - $pausedTime
                $hours = [math]::Floor($elapsed.TotalHours)
                $minutes = $elapsed.Minutes
                $seconds = $elapsed.Seconds
                $milliseconds = [math]::Floor($elapsed.Milliseconds / 10)

                Write-Host "`r⏸️  $($hours.ToString('00')):$($minutes.ToString('00')):$($seconds.ToString('00')).$($milliseconds.ToString('00')) [PAUSED]" -NoNewline -ForegroundColor Yellow
            }
            else {
                $elapsed = (Get-Date) - $startTime - $pausedTime
                $hours = [math]::Floor($elapsed.TotalHours)
                $minutes = $elapsed.Minutes
                $seconds = $elapsed.Seconds
                $milliseconds = [math]::Floor($elapsed.Milliseconds / 10)

                Write-Host "`r⏱️  $($hours.ToString('00')):$($minutes.ToString('00')):$($seconds.ToString('00')).$($milliseconds.ToString('00'))          " -NoNewline -ForegroundColor Green
            }

            Start-Sleep -Milliseconds 10
        }
    }
    catch {
        if ($isPaused) {
            $finalElapsed = $pauseStartTime - $startTime - $pausedTime
        }
        else {
            $finalElapsed = (Get-Date) - $startTime - $pausedTime
        }
        Write-Host "`n`n⏹️  Stopped at: $($finalElapsed.ToString('hh\:mm\:ss\.ff'))" -ForegroundColor Yellow
    }
}

function Start-Alarm {
    param(
        [int]$Hour = 0,
        [int]$Minute = 0,
        [string]$Message = "Alarm!"
    )

    if ($Hour -lt 0 -or $Hour -gt 23 -or $Minute -lt 0 -or $Minute -gt 59) {
        Write-Host "Invalid time! Hour must be 0-23, Minute must be 0-59" -ForegroundColor Red
        return
    }

    $now = Get-Date
    $alarmTime = Get-Date -Hour $Hour -Minute $Minute -Second 0 -Millisecond 0

    if ($alarmTime -le $now) {
        $alarmTime = $alarmTime.AddDays(1)
    }

    $timeUntil = $alarmTime - $now

    Write-Host "`n⏰ Alarm set for " -NoNewline -ForegroundColor Cyan
    Write-Host "$($alarmTime.ToString('HH:mm'))" -NoNewline -ForegroundColor Yellow
    Write-Host " ($($alarmTime.ToString('dddd, MMMM dd')))" -ForegroundColor Gray
    Write-Host "Time until alarm: " -NoNewline -ForegroundColor Gray

    if ($timeUntil.Days -gt 0) {
        Write-Host "$($timeUntil.Days) day(s) " -NoNewline -ForegroundColor White
    }
    if ($timeUntil.Hours -gt 0) {
        Write-Host "$($timeUntil.Hours) hour(s) " -NoNewline -ForegroundColor White
    }
    Write-Host "$($timeUntil.Minutes) minute(s)" -ForegroundColor White
    Write-Host "Press Ctrl+C to cancel`n" -ForegroundColor Gray

    try {
        while ((Get-Date) -lt $alarmTime) {
            $remaining = $alarmTime - (Get-Date)
            $hours = [math]::Floor($remaining.TotalHours)
            $minutes = $remaining.Minutes
            $seconds = $remaining.Seconds

            Write-Host "`r⏰ Time until alarm: $($hours.ToString('00')):$($minutes.ToString('00')):$($seconds.ToString('00')) " -NoNewline -ForegroundColor Green
            Start-Sleep -Milliseconds 500
        }

        Write-Host "`n`n🔔🔔🔔 $Message 🔔🔔🔔" -ForegroundColor Yellow
        Write-Host "Press [Q] to stop or [S] to snooze (5 min)`n" -ForegroundColor Cyan

        $alarmActive = $true
        while ($alarmActive) {
            # Ring pattern
            [Console]::Beep(1000, 400)
            Start-Sleep -Milliseconds 100
            [Console]::Beep(800, 400)
            Start-Sleep -Milliseconds 100

            # Key press
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)

                if ($key.Key -eq 'Q') {
                    Write-Host "✓ Alarm dismissed" -ForegroundColor Green
                    $alarmActive = $false
                }
                elseif ($key.Key -eq 'S') {
                    Write-Host "😴 Snoozing for 5 minutes..." -ForegroundColor Yellow
                    $alarmActive = $false

                    # Snooze for 5 minutes
                    $snoozeTime = (Get-Date).AddMinutes(5)
                    Write-Host "Alarm will ring again at $($snoozeTime.ToString('HH:mm'))" -ForegroundColor Gray
                    Write-Host "Press Ctrl+C to cancel`n" -ForegroundColor Gray

                    while ((Get-Date) -lt $snoozeTime) {
                        $remaining = $snoozeTime - (Get-Date)
                        $minutes = $remaining.Minutes
                        $seconds = $remaining.Seconds

                        Write-Host "`r😴 Snooze time remaining: $($minutes.ToString('00')):$($seconds.ToString('00')) " -NoNewline -ForegroundColor Magenta
                        Start-Sleep -Milliseconds 500
                    }

                    # Recursive call to ring again after snooze
                    Write-Host "`n`n🔔🔔🔔 $Message 🔔🔔🔔" -ForegroundColor Yellow
                    Write-Host "Press [Q] to stop or [S] to snooze (5 min)`n" -ForegroundColor Cyan
                    $alarmActive = $true
                }
            }

            Start-Sleep -Milliseconds 500
        }
    }
    catch {
        Write-Host "`n`n❌ Alarm cancelled" -ForegroundColor Red
    }
}

function Show-WorldClock {
    Write-Host "`n🌍 World Clock`n" -ForegroundColor Cyan

    $timezones = @(
        @{Name="Jakarta/Bandung"; Zone="SE Asia Standard Time"},
        @{Name="Tokyo"; Zone="Tokyo Standard Time"},
        @{Name="London"; Zone="GMT Standard Time"},
        @{Name="New York"; Zone="Eastern Standard Time"},
        @{Name="Los Angeles"; Zone="Pacific Standard Time"},
        @{Name="Sydney"; Zone="AUS Eastern Standard Time"}
    )

    foreach ($tz in $timezones) {
        try {
            $time = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), $tz.Zone)
            $formatted = $time.ToString("HH:mm:ss")
            Write-Host "$($tz.Name.PadRight(20)) : $formatted" -ForegroundColor White
        }
        catch {
            Write-Host "$($tz.Name.PadRight(20)) : N/A" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Aliases
Set-Alias -Name timer -Value clock
Set-Alias -Name stopwatch -Value clock
