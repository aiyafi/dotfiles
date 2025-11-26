# MEDIA FUNCTIONS (yt-dlp)
# Requires yt-dlp to be installed and added to PATH

function yt {
    yt-dlp -o "C:\Users\{username}\ytdlp\%(title)s.%(ext)s" @args
}

function yt1080 {
    yt-dlp -f "bestvideo[height=1080]+bestaudio/best[height=1080]" `
           -o "C:\Users\{username}\ytdlp\%(title)s.%(ext)s" @args
}

function yt720 {
    yt-dlp -f "bestvideo[height=720]+bestaudio/best[height=720]" `
           -o "C:\Users\{username}\ytdlp\%(title)s.%(ext)s" @args
}

function yt480 {
    yt-dlp -f "bestvideo[height=480]+bestaudio/best[height=480]" `
           -o "C:\Users\{username}\ytdlp\%(title)s.%(ext)s" @args
}

function youtube {
    param(
        [string]$query
    )

    if (!$query) {
        Start-Process "https://www.youtube.com/"
    }
    else {
        $searchUrl = "https://www.youtube.com/results?search_query=$([System.Uri]::EscapeDataString($query))"
        Start-Process $searchUrl
    }
}
