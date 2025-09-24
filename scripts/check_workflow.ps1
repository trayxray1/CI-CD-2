param(
  [string]$owner = 'trayxray1',
  [string]$repo = 'CI-CD-2'
)

try {
  $runs = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/actions/runs" -UseBasicParsing
} catch {
  Write-Output 'ERROR: Cannot fetch runs (repo private or rate-limited or network issue)'
  exit 2
}

if (-not $runs.workflow_runs) {
  Write-Output 'No workflow runs found'
  exit 0
}

$run = $runs.workflow_runs[0]
Write-Output "RunId: $($run.id)  workflow: $($run.name)  event: $($run.event)  status: $($run.status)  conclusion: $($run.conclusion)  created_at: $($run.created_at)"

$jobs = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/actions/runs/$($run.id)/jobs" -UseBasicParsing
foreach ($job in $jobs.jobs) {
  Write-Output "--- Job: $($job.name)  status:$($job.status)  conclusion:$($job.conclusion)"
  foreach ($step in $job.steps) {
    $name = $step.name
    $ss = $step.status
    $sc = $step.conclusion
    Write-Output "    Step: $name  status:$ss  conclusion:$sc"
  }
}
