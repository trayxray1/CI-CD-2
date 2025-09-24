param(
  [int64]$runId,
  [string]$owner = 'trayxray1',
  [string]$repo = 'CI-CD-2',
  [string]$token
)

if (-not $runId) { Write-Error "Usage: .\fetch_run_logs.ps1 -runId <id> [-token <PAT>]"; exit 1 }

if (-not $token) { $token = $env:GITHUB_TOKEN }
if (-not $token) { Write-Error "GITHUB_TOKEN not provided. Set env var or pass -token parameter."; exit 2 }

$headers = @{ 'User-Agent' = 'CI-Logs-Fetcher' ; 'Authorization' = "token $token" }

$uri = "https://api.github.com/repos/$owner/$repo/actions/runs/$runId/logs"
Write-Output "Fetching logs zip for run $runId from $uri"

 $outZip = Join-Path -Path $PSScriptRoot -ChildPath "run-$runId-logs.zip"
 # Create logs directory relative to repository root (../logs/run-<id>) without Resolve-Path
 $outDir = Join-Path -Path $PSScriptRoot -ChildPath "..\logs\run-$runId"
 if (-not (Test-Path -Path $outDir)) {
   New-Item -ItemType Directory -Path $outDir -Force | Out-Null
 }

try {
  Invoke-WebRequest -Uri $uri -Headers $headers -OutFile $outZip -UseBasicParsing -ErrorAction Stop
} catch {
  $msg = $_.Exception.Message
  Write-Error "Failed to download logs zip: $msg"
  Write-Output "Common causes: missing/invalid GITHUB_TOKEN, token lacks Actions/Repo read permissions, or run logs are not available."
  Write-Output "Ensure you set: `$env:GITHUB_TOKEN = 'ghp_...'` (or pass -token) and the token has permissions: Actions -> Read for the repository."
  exit 3
}

Write-Output "Downloaded to $outZip"

try {
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory($outZip, $outDir)
} catch {
  Write-Error "Failed to extract zip: $($_.Exception.Message)"
  exit 4
}

Write-Output "Extracted logs to: $outDir"

# List top-level files
Get-ChildItem -Path $outDir -Recurse | Sort-Object FullName | ForEach-Object {
  $relative = $_.FullName.Substring($outDir.Length).TrimStart('\\')
  Write-Output $relative
}

# Search for error-containing files and print snippets
Write-Output "\n=== Files that contain keywords (error|failed|traceback) - showing first matching lines ===\n"
$patterns = 'error','failed','traceback'
$matching = Get-ChildItem -Path $outDir -Recurse -File | Where-Object {
  try {
    Select-String -Path $_.FullName -Pattern $patterns -Quiet -ErrorAction SilentlyContinue
  } catch { $false }
}

if (-not $matching) { Write-Output 'No matches for keywords in logs. You can inspect the files under ./logs/run-<id> manually.'; exit 0 }

foreach ($f in $matching) {
  Write-Output "---- $($f.FullName.Substring($outDir.Length).TrimStart('\\')) ----"
  try {
    Select-String -Path $f.FullName -Pattern $patterns -AllMatches | Select-Object -First 20 | ForEach-Object {
      Write-Output $_.Line
    }
  } catch {
    Write-Output "(Could not read $($f.FullName))"
  }
}

Write-Output "\nLogs extracted under: $outDir"
Write-Output "You can open those files and paste relevant error sections here for analysis."
