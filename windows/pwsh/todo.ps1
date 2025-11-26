# TODO TUI by K9Fox

function todo {
    param(
        [string]$action,
        [string]$item,
        [int]$index
    )

    $todoFile = "$env:USERPROFILE\.App\todo.txt"

    # Create file
    if (!(Test-Path $todoFile)) {
        New-Item $todoFile -ItemType File | Out-Null
    }

    switch ($action) {
    "add" {
        if (!$item) { Write-Host "Usage: todo add 'task name'"; return }
        Add-Content $todoFile "[ ] $item"
        Write-Host "✓ Added: $item" -ForegroundColor Green
    }

    "remove" {
        if (!$index) { Write-Host "Usage: todo remove <number>"; return }
        $items = @(Get-Content $todoFile)
        if ($index -lt 1 -or $index -gt $items.Count) {
            Write-Host "Invalid index" -ForegroundColor Red
            return
        }
        $items = $items | Where-Object {$_ -ne $items[$index-1]}
        if ($items) {
            Set-Content $todoFile $items
        } else {
            Clear-Content $todoFile
        }
        Write-Host "✓ Removed item $index" -ForegroundColor Green
    }

    "done" {
        if (!$index) { Write-Host "Usage: todo done <number>"; return }
        $items = @(Get-Content $todoFile)
        if ($index -lt 1 -or $index -gt $items.Count) {
            Write-Host "Invalid index" -ForegroundColor Red
            return
        }
        $items[$index-1] = $items[$index-1] -replace '\[ \]', '[x]'
        Set-Content $todoFile $items
        Write-Host "✓ Marked as done: $($items[$index-1])" -ForegroundColor Green
    }

    "edit" {
        if (!$index -or !$item) { Write-Host "Usage: todo edit <number> 'new task'"; return }
        $items = @(Get-Content $todoFile)
        if ($index -lt 1 -or $index -gt $items.Count) {
            Write-Host "Invalid index" -ForegroundColor Red
            return
        }
        $items[$index-1] = $items[$index-1] -replace '(?<=\] ).*', $item
        Set-Content $todoFile $items
        Write-Host "✓ Updated item $index" -ForegroundColor Green
    }

    "clear" {
        Clear-Content $todoFile
        Write-Host "✓ All todos cleared" -ForegroundColor Green
    }

    {$_ -eq "help" -or $_ -eq "?"} {
        Write-Host "`nTODO Commands:`n" -ForegroundColor Cyan
        Write-Host "  todo                        - Show all todos" -ForegroundColor White
        Write-Host "  todo add 'task name'        - Add new todo" -ForegroundColor White
        Write-Host "  todo done <number>          - Mark todo as done" -ForegroundColor White
        Write-Host "  todo edit <number> 'text'   - Edit todo" -ForegroundColor White
        Write-Host "  todo remove <number>        - Delete todo" -ForegroundColor White
        Write-Host "  todo clear                  - Delete all todos" -ForegroundColor White
        Write-Host "  todo help / todo ?          - Show this help`n" -ForegroundColor White
    }

    default {
        # Tampilkan list
        $todos = @(Get-Content $todoFile -ErrorAction SilentlyContinue)
        if (!$todos -or $todos.Count -eq 0) {
            Write-Host "No todos yet!" -ForegroundColor Yellow
            return
        }

        Write-Host "`nYour TODOs:`n" -ForegroundColor Cyan
        for ($i = 0; $i -lt $todos.Count; $i++) {
            $prefix = if ($todos[$i] -match '\[x\]') { "✓" } else { " " }
            Write-Host "$($i+1). $($todos[$i])" -ForegroundColor $(if ($todos[$i] -match '\[x\]') { 'Green' } else { 'White' })
        }
        Write-Host ""
    }
    }
}
