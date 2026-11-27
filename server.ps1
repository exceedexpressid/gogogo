param(
  [int]$Port = 8080
)

$Root = $PSScriptRoot
$LogFile = "C:\Users\ellyas.martadinata\.gemini\antigravity\brain\bf5edbdc-4ebb-4fa6-a2ad-41a1fc7411dc\scratch\server_debug.log"
function Write-Log([string]$msg) {
  try {
    [System.IO.File]::AppendAllText($LogFile, "$(Get-Date -Format 'HH:mm:ss.fff') $msg`r`n")
  } catch {}
}

Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue | ForEach-Object {
  if ($_.OwningProcess -and $_.OwningProcess -ne $PID) {
    Write-Log "Killing old listener PID $($_.OwningProcess) on port $Port"
    Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
  }
}
Start-Sleep -Milliseconds 300

$Endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Loopback, $Port)
$Listener = New-Object System.Net.Sockets.TcpListener($Endpoint)
$Listener.Start()

Write-Log "=== NON-BLOCKING SERVER STARTED ON 127.0.0.1:$Port ==="
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " GoGoGo SuperApp Clone (Database Mandiri)" -ForegroundColor Green
Write-Host " Server aktif di: http://localhost:$Port" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

$MimeTypes = @{
  ".html"        = "text/html; charset=utf-8"
  ".js"          = "application/javascript; charset=utf-8"
  ".mjs"         = "application/javascript; charset=utf-8"
  ".css"         = "text/css; charset=utf-8"
  ".json"        = "application/json; charset=utf-8"
  ".webmanifest" = "application/manifest+json; charset=utf-8"
  ".png"         = "image/png"
  ".jpg"         = "image/jpeg"
  ".jpeg"        = "image/jpeg"
  ".webp"        = "image/webp"
  ".svg"         = "image/svg+xml"
  ".ico"         = "image/x-icon"
  ".woff"        = "font/woff"
  ".woff2"       = "font/woff2"
}

$RecvBuf = New-Object byte[] 65536

try {
  while ($true) {
    $Client = $Listener.AcceptTcpClient()
    try {
      $Waited = 0
      while ($Client.Available -eq 0 -and $Waited -lt 250) {
        Start-Sleep -Milliseconds 5
        $Waited += 5
      }
      if ($Client.Available -eq 0) {
        continue
      }

      $Stream = $Client.GetStream()
      $BytesRead = $Stream.Read($RecvBuf, 0, $RecvBuf.Length)
      if ($BytesRead -le 0) { continue }

      $ReqText = [System.Text.Encoding]::UTF8.GetString($RecvBuf, 0, $BytesRead)
      $Lines = $ReqText -split "`r`n"
      $RequestLine = $Lines[0]
      if ([string]::IsNullOrEmpty($RequestLine)) { continue }

      $Parts = $RequestLine.Split(' ')
      $Method = $Parts[0]
      $RawUrl = if ($Parts.Length -ge 2) { $Parts[1] } else { "/" }
      $UrlPath = ($RawUrl -split '\?')[0]
      $UrlPath = [System.Uri]::UnescapeDataString($UrlPath)

      if ($UrlPath -eq "/__debug_report") {
        $BodyIdx = $ReqText.IndexOf("`r`n`r`n")
        $BodyText = if ($BodyIdx -ge 0) { $ReqText.Substring($BodyIdx + 4) } else { "" }
        Write-Log "[BROWSER-REPORT] $BodyText"
        $OkBytes = [System.Text.Encoding]::UTF8.GetBytes("OK")
        $HeaderStr = "HTTP/1.1 200 OK`r`nContent-Type: text/plain`r`nContent-Length: 2`r`nConnection: close`r`n`r`n"
        $HeaderBytes = [System.Text.Encoding]::ASCII.GetBytes($HeaderStr)
        $Stream.Write($HeaderBytes, 0, $HeaderBytes.Length)
        $Stream.Write($OkBytes, 0, $OkBytes.Length)
        continue
      }

      if ($UrlPath -eq "/" -or [string]::IsNullOrWhiteSpace($UrlPath)) {
        $UrlPath = "/index.html"
      }

      $LocalFile = Join-Path $Root ($UrlPath.TrimStart('/') -replace '/', '\')
      if (-not (Test-Path $LocalFile -PathType Leaf)) {
        $ExtCheck = [System.IO.Path]::GetExtension($LocalFile)
        if ([string]::IsNullOrEmpty($ExtCheck)) {
          $LocalFile = Join-Path $Root "index.html"
        }
      }

      if (Test-Path $LocalFile -PathType Leaf) {
        $Ext = [System.IO.Path]::GetExtension($LocalFile).ToLower()
        $ContentType = if ($MimeTypes.ContainsKey($Ext)) { $MimeTypes[$Ext] } else { "application/octet-stream" }
        $BodyBytes = [System.IO.File]::ReadAllBytes($LocalFile)
        $HeaderStr = "HTTP/1.1 200 OK`r`nContent-Type: $ContentType`r`nContent-Length: $($BodyBytes.Length)`r`nCache-Control: no-cache, no-store, must-revalidate`r`nConnection: close`r`n`r`n"
        $HeaderBytes = [System.Text.Encoding]::ASCII.GetBytes($HeaderStr)
        $Stream.Write($HeaderBytes, 0, $HeaderBytes.Length)
        $Stream.Write($BodyBytes, 0, $BodyBytes.Length)
        if ($Ext -eq ".html") {
          Write-Log "[200-HTML] $Method $RawUrl -> $(Split-Path $LocalFile -Leaf)"
        }
      } else {
        Write-Log "[404-MISSING] $Method $RawUrl"
        $NotFoundBytes = [System.Text.Encoding]::UTF8.GetBytes("Not Found")
        $HeaderStr = "HTTP/1.1 404 Not Found`r`nContent-Type: text/plain`r`nContent-Length: $($NotFoundBytes.Length)`r`nConnection: close`r`n`r`n"
        $HeaderBytes = [System.Text.Encoding]::ASCII.GetBytes($HeaderStr)
        $Stream.Write($HeaderBytes, 0, $HeaderBytes.Length)
        $Stream.Write($NotFoundBytes, 0, $NotFoundBytes.Length)
      }
    } catch {
      Write-Log "[EXC] $($_.Exception.Message)"
    } finally {
      $Client.Close()
    }
  }
} finally {
  $Listener.Stop()
}
