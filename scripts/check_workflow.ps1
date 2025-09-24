param(
  [string]$owner = 'trayxray1',
  [string]$repo = 'CI-CD-2',
  [int64]$runId,
  [string]$token
)

$headers = @{ 'User-Agent' = 'CI-Checker' }
if (-not $token) { $token = $env:GITHUB_TOKEN }
if ($token) { $headers['Authorization'] = "token $token" }
try {
  $runs = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/actions/runs" -UseBasicParsing -Headers $headers
} catch {
  Write-Output 'ERROR: Cannot fetch runs (repo private or rate-limited or network issue)'
  exit 2
}

if (-not $runs.workflow_runs) {
  Write-Output 'No workflow runs found'
  exit 0
}

if (-not $runId) {
  $run = $runs.workflow_runs[0]
} else {
  $run = $runs.workflow_runs | Where-Object { $_.id -eq $runId }
  if (-not $run) { Write-Output "Run $runId not found"; exit 1 }
}
Write-Output "RunId: $($run.id)  workflow: $($run.name)  event: $($run.event)  status: $($run.status)  conclusion: $($run.conclusion)  created_at: $($run.created_at)"

try {
  $jobs = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/actions/runs/$($run.id)/jobs" -UseBasicParsing -Headers $headers
} catch {
  Write-Output "ERROR fetching jobs: $($_.Exception.Message)"
  exit 3
}

foreach ($job in $jobs.jobs) {
  Write-Output "--- Job: $($job.name)  status:$($job.status)  conclusion:$($job.conclusion)  id:$($job.id)"
  foreach ($step in $job.steps) {
    Write-Output "    Step: $($step.number) $($step.name)  status:$($step.status)  conclusion:$($step.conclusion)"
  }
}
