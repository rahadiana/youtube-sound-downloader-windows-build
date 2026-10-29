[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Video,
    [Parameter(Mandatory=$true)]
    [string]$BaseUrl,
    [string]$OutputDirectory = ".\downloads"
)

$ErrorActionPreference = "Stop"

function Get-VideoId([string]$InputValue) {
    $v = $InputValue.Trim()
    if ($v -match '^[A-Za-z0-9_-]{11}$') { return $v }
    try {
        $u = [Uri]$v
        if ($u.Host -match '(^|\.)youtu\.be$') {
            $id = $u.AbsolutePath.Trim('/')
        } elseif ($u.Query) {
            $q = [System.Web.HttpUtility]::ParseQueryString($u.Query)
            $id = $q.Get('v')
            if (-not $id -and $u.AbsolutePath -match '/(shorts|embed|live)/([^/?]+)') { $id = $Matches[2] }
        } else {
            $id = $null
        }
        if ($id -match '^[A-Za-z0-9_-]{11}$') { return $id }
    } catch {}
    throw "Input bukan video ID YouTube 11 karakter atau URL YouTube yang dikenali."
}

$videoId = Get-VideoId $Video
$base = $BaseUrl.TrimEnd('/')
$detailUri = "$base/youtube/video-detail?vid_id=$([Uri]::EscapeDataString($videoId))"

Write-Host "Meminta detail video $videoId ..."
try {
    $detail = Invoke-RestMethod -Uri $detailUri -Method Get -TimeoutSec 30
} catch {
    throw "Gagal memanggil video-detail ($detailUri). Periksa BaseUrl, koneksi, dan status API. Detail: $($_.Exception.Message)"
}

# API dapat membungkus data dalam beberapa tingkat; cari adaptiveFormats tanpa mengasumsikan wrapper tunggal.
$formatLists = @()
if ($detail.streamingData.adaptiveFormats) { $formatLists += ,$detail.streamingData.adaptiveFormats }
if ($detail.data.streamingData.adaptiveFormats) { $formatLists += ,$detail.data.streamingData.adaptiveFormats }
if ($detail.data.data.streamingData.adaptiveFormats) { $formatLists += ,$detail.data.data.streamingData.adaptiveFormats }

$formats = @($formatLists | ForEach-Object { $_ } | Where-Object { $_ -and $_.mimeType -match '^audio/' -and $_.url })
if (-not $formats -and $detail -is [System.Collections.IDictionary]) {
    throw "API berhasil dipanggil, tetapi respons /youtube/video-detail hanya berisi metadata format audio dan tidak menyertakan URL stream langsung. Downloader belum bisa mengunduh sampai API menyediakan endpoint/URL unduhan yang didukung."
}
if (-not $formats) { throw "Tidak ditemukan format audio dengan URL langsung. API mungkin tidak mengekspos URL stream untuk format ini." }

# Utamakan audio/mp4; selain itu gunakan format audio pertama yang tersedia.
$chosen = $formats | Where-Object { $_.mimeType -match '^audio/mp4' } | Select-Object -First 1
if (-not $chosen) { $chosen = $formats | Select-Object -First 1 }

$extension = switch -Regex ($chosen.mimeType) {
    '^audio/mp4'  { '.m4a'; break }
    '^audio/webm' { '.webm'; break }
    '^audio/mpeg' { '.mp3'; break }
    '^audio/ogg'  { '.ogg'; break }
    default       { '.audio' }
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$outFile = Join-Path (Resolve-Path $OutputDirectory).Path "$videoId$extension"
Write-Host "Format: $($chosen.mimeType)"
Write-Host "Menyimpan ke: $outFile"

try {
    Invoke-WebRequest -Uri $chosen.url -OutFile $outFile -TimeoutSec 120
} catch {
    if (Test-Path $outFile) { Remove-Item -Force $outFile -ErrorAction SilentlyContinue }
    throw "Unduhan gagal. URL stream bisa kedaluwarsa; jalankan ulang agar video-detail menghasilkan URL baru. Detail: $($_.Exception.Message)"
}

if ((Get-Item $outFile).Length -lt 1024) {
    Write-Warning "File hasil sangat kecil (<1 KB); kemungkinan respons error, bukan audio valid. Periksa file dan API."
}
Write-Host "Selesai: $outFile"
