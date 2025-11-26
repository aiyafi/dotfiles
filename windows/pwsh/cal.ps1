# CALENDAR FUNCTION (Pure PowerShell, Interactive) By K9Fox

# Outer 
function Get-K9CalPadding {
    $consoleWidth = $Host.UI.RawUI.WindowSize.Width
    $calWidth     = 28
    $outerPaddingWidth = [Math]::Max(0, [Math]::Floor(($consoleWidth - $calWidth) / 2))
    return (" " * $outerPaddingWidth)
}

# Calendar Renderer
function Invoke-K9CalMonth {
    param(
        [int]$Month,
        [int]$Year
    )

    $today = Get-Date
        Write-Host "Error: Invalid date." -ForegroundColor Red
    try {
        $targetDate = Get-Date -Year $Year -Month $Month -Day 1
    } catch {
        return
    }

    $firstDayOffset = [int]$targetDate.DayOfWeek
    $totalDays = [DateTime]::DaysInMonth($Year, $Month)
    $isCurrentMonthAndYear = ($targetDate.Month -eq $today.Month) -and ($targetDate.Year -eq $today.Year)
    $outerPadding = Get-K9CalPadding

    # Title
    [string]$title = "{0:MMMM yyyy}" -f $targetDate
    [int]$paddingWidth = [math]::Floor((28 - $title.Length) / 2)
    $padding = " " * $paddingWidth
    Write-Host ""
    Write-Host "$outerPadding$padding$title" -ForegroundColor Cyan

    # Japanese Era 
    try {
        $jpCalendar = [System.Globalization.JapaneseCalendar]::new()

        $eraRomajiLookup = @{
            5 = "Reiwa"
            4 = "Heisei"
            3 = "Shōwa"
            2 = "Taishō"
            1 = "Meiji"
        }

        $eraIndex = $jpCalendar.GetEra($targetDate)
        $eraYear  = $jpCalendar.GetYear($targetDate)
        $eraName  = $eraRomajiLookup[$eraIndex]

        if ($eraName) {
            $jpTitle = "$eraName $eraYear"

            [int]$jpPaddingWidth = [math]::Floor((28 - $jpTitle.Length) / 2)
            $jpPadding = " " * $jpPaddingWidth
            Write-Host "$outerPadding$jpPadding$jpTitle" -ForegroundColor Magenta
        }
    } catch {
    }

    Write-Host ""

    # Day Header
    Write-Host "$outerPadding Su  Mo  Tu  We  Th  Fr  Sa" -ForegroundColor Yellow

    # Starting weekday & padding
    $weekday = $firstDayOffset

    Write-Host "$outerPadding" -NoNewline
    $startPadding = " " * (4 * $weekday)
    Write-Host $startPadding -NoNewline

    # Loop and draw dates
    for ($day = 1; $day -le $totalDays; $day++) {

        $isToday = $isCurrentMonthAndYear -and ($day -eq $today.Day)

        $dayNum = ("{0}" -f $day)
        $prePadding = " " * (3 - $dayNum.Length)
        $postPadding = " "

        Write-Host $prePadding -NoNewline

        if ($isToday) {
            Write-Host $dayNum -NoNewline -BackgroundColor DarkCyan -ForegroundColor White
        } else {
            Write-Host $dayNum -NoNewline
        }

        Write-Host $postPadding -NoNewline

        $weekday = ($weekday + 1) % 7

        if ($weekday -eq 0 -and $day -lt $totalDays) {
            Write-Host ""
            Write-Host "$outerPadding" -NoNewline
        }
    }

    Write-Host ""
    Write-Host ""
}

# Interactive Mode
function Invoke-K9CalInteractive {
    $currentDate = Get-Date
    $running = $true

    # Hide cursor
    $oldCursorVisible = [System.Console]::CursorVisible
    [System.Console]::CursorVisible = $false

    try {
        while ($running) {
            Clear-Host

            $windowHeight = $Host.UI.RawUI.WindowSize.Height

            $month = $currentDate.Month
            $year  = $currentDate.Year

            $targetDate    = Get-Date -Year $year -Month $month -Day 1
            $firstDayOffset = [int]$targetDate.DayOfWeek
            $totalDays      = [DateTime]::DaysInMonth($year, $month)
            $weeks          = [math]::Ceiling( ($firstDayOffset + $totalDays) / 7 )


            $calendarLines = 7 + $weeks
            $blockHeight   = $calendarLines + 1   # + nav

            $topPadding = [Math]::Max(0, [Math]::Floor( ($windowHeight - $blockHeight) / 2 ))

            for ($i = 0; $i -lt $topPadding; $i++) {
                Write-Host ""
            }
            
            Invoke-K9CalMonth -Month $currentDate.Month -Year $currentDate.Year

            $outerPadding = Get-K9CalPadding
            Write-Host "$outerPadding Navigation: [<-] Left | [->] Right | [h] Today | [q] Quit" -ForegroundColor Gray

            # Keyboard 
            $key = [System.Console]::ReadKey($true)

            switch ($key.Key) {
                "LeftArrow"  { $currentDate = $currentDate.AddMonths(-1) }
                "RightArrow" { $currentDate = $currentDate.AddMonths(1) }
                { $_ -eq "H" -or $_ -eq "h" } { $currentDate = Get-Date }
                { $_ -eq "Q" -or $_ -eq "q" } {
                    $running = $false
                    Clear-Host
                }
            }
        }
    }
    finally {
        [System.Console]::CursorVisible = $oldCursorVisible
    }
}

# Help Display
function Get-K9CalHelp {
    Write-Host @"

  usage: cal [command]

  Commands:
    (none)          Display this month's calendar.
    [month] [year]  Display a specific month's calendar.
                    Example: cal 12 2026

    all             Enter interactive mode (arrow navigation).

    ? / help        Display this help message.

"@ -ForegroundColor Gray
}

# Main
function cal {
    param(
        [string[]]$Arguments
    )

    $Mode = "default"
    $Month = (Get-Date).Month
    $Year = (Get-Date).Year

    if ($Arguments.Length -gt 0) {
        switch ($Arguments[0].ToLower()) {
            "all"   { $Mode = "interactive"; break }
            "?"     { $Mode = "help"; break }
            "help"  { $Mode = "help"; break }
            default {
                if ($Arguments.Length -eq 2 -and $Arguments[0] -match '^\d+$' -and $Arguments[1] -match '^\d+$') {
                    $Mode = "specific"
                    $Month = [int]$Arguments[0]
                    $Year  = [int]$Arguments[1]
                } else {
                    Write-Host "Error: Command not recognized." -ForegroundColor Red
                    $Mode = "help"
                }
            }
        }
    }

    # Run selected mode
    switch ($Mode) {
        "default"     { Invoke-K9CalMonth -Month $Month -Year $Year }
        "specific"    { Invoke-K9CalMonth -Month $Month -Year $Year }
        "interactive" { Invoke-K9CalInteractive }
        "help"        { Get-K9CalHelp }
    }
}
