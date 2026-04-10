# ============================================================================
# Ch 14: Multitasking with background jobs
# ============================================================================
# Jobs let you run tasks in the background while you keep working.
# Great for long-running operations you don't want to wait for.
# ============================================================================


# --- Thread Jobs (Fast and Lightweight) ---

# Start a background thread job
# Note: Not available in Windows PowerShell unless you
#       install the Microsoft.PowerShell.ThreadJob module first:
#       Install-PSResource -Name Microsoft.PowerShell.ThreadJob
$job = Start-ThreadJob -ScriptBlock {
    # Simulate some work
    Start-Sleep -Seconds 3
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, Id, WorkingSet
}

# Check on it
Get-Job
$job

# Wait for it to finish and get results
$results = Receive-Job -Job $job -Wait
$results

# Clean up completed jobs
Remove-Job -Job $job


# --- Process Jobs ---

# Start-Job runs in a separate PROCESS (heavier, but fully isolated)
$job = Start-Job -ScriptBlock {
    Get-ChildItem ~ -Recurse -ErrorAction SilentlyContinue | Measure-Object
}

# Monitor progress
Get-Job

# Wait and receive
$result = Receive-Job -Job $job -Wait
$result

Remove-Job -Job $job


# --- Multiple Jobs at Once ---

# Start several jobs
$job1 = Start-ThreadJob -Name "Processes" -ScriptBlock {
    Start-Sleep 2
    (Get-Process).Count
}

$job2 = Start-ThreadJob -Name "Files" -ScriptBlock {
    Start-Sleep 2
    (Get-ChildItem ~ -ErrorAction SilentlyContinue).Count
}

$job3 = Start-ThreadJob -Name "Modules" -ScriptBlock {
    Start-Sleep 2
    (Get-Module -ListAvailable).Count
}

# Watch them run
Get-Job | Format-Table Id, Name, State

# Wait for all to finish
Get-Job | Wait-Job | Out-Null

# Collect all results
Get-Job | ForEach-Object {
    [PSCustomObject]@{
        Task   = $_.Name
        Result = (Receive-Job -Job $_)
    }
}

# Clean up all jobs
Get-Job | Remove-Job


# --- Child Jobs ---

# Every background job has a parent job and at least one child job.
# The child job is where the ACTUAL work happens.
# This matters for Invoke-Command -AsJob, where each target machine
# gets its own child job — so you can see per-machine failures.

$job = Start-Job -ScriptBlock { Get-Process | Select-Object -First 5 Name, Id }
Wait-Job $job | Out-Null

# The parent job summarizes child job state:
$job | Format-List Id, Name, State, ChildJobs

# Expand child jobs into a proper table:
Get-Job -Id $job.Id | Select-Object -ExpandProperty ChildJobs

# Receive from a specific child job:
$childJob = Get-Job -Id $job.Id | Select-Object -ExpandProperty ChildJobs | Select-Object -First 1
Receive-Job -Job $childJob

Remove-Job $job


# --- Invoke-Command -AsJob ---

# Invoke-Command has an -AsJob switch that turns a remote command into a background job.
# With multiple computers, each gets its OWN child job — great for parallel work!
#
# With real remoting you'd write:
#   Invoke-Command -ComputerName Server01, Server02 -ScriptBlock { ... } -AsJob
#
# We can try to demo the structure locally:
$remoteJob = Invoke-Command -ComputerName localhost -ScriptBlock {
    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 3 Name, Id
} -AsJob -JobName 'RemoteDemo'

Get-Job
Wait-Job $remoteJob | Out-Null

# Results include ComputerName — which machine produced each object:
# Note: You might get an error like "Connecting to remote server localhost failed with the following error message"
$results = Receive-Job $remoteJob
$results | Select-Object Name, Id, ComputerName

Remove-Job $remoteJob


# --- Stop-Job ---

# If a job is stuck or running longer than expected, Stop-Job terminates it.
# You can still retrieve any output that was generated before it stopped.

$slowJob = Start-ThreadJob -ScriptBlock {
    "Starting work..."
    Start-Sleep -Seconds 60   # Simulates a long operation
    "Done!"
}

# It's running:
Get-Job $slowJob.Id

# Stop it early:
Stop-Job $slowJob
Get-Job $slowJob.Id   # State is now 'Stopped'

# Collect whatever output was produced before it stopped:
Receive-Job $slowJob   # May be empty or partial
Remove-Job $slowJob


# --- Cleaning Up: HasMoreData ---

# HasMoreData = True means the job still has output waiting to be retrieved.
# After Receive-Job consumes the output, HasMoreData flips to False.
# This pattern safely removes only jobs you've already collected from:

$j1 = Start-ThreadJob { "Result A" }
$j2 = Start-ThreadJob { "Result B" }
Get-Job | Wait-Job | Out-Null
Get-Job | Receive-Job | Out-Null   # Consume all output

# Check the flag:
Get-Job | Select-Object Id, Name, State, HasMoreData

# Remove only the ones with nothing left to collect:
Get-Job | Where-Object { -not $_.HasMoreData } | Remove-Job
Get-Job   # All gone!


# --- Receive-Job with -Keep ---

# By default, Receive-Job consumes the results (one-time read).
# Use -Keep to preserve them for later.

$job = Start-ThreadJob -ScriptBlock { "Hello from a job!" }
Wait-Job $job | Out-Null

Receive-Job $job -Keep   # First read — results preserved
Receive-Job $job -Keep   # Second read — still there!
Receive-Job $job         # Final read — results consumed
Receive-Job $job         # Returns nothing now because no new data has been produced by the job

Remove-Job $job


# --- Lab Challenge ---
#
# 1. Start a thread job that counts files in your home directory
#    $job = Start-ThreadJob { (Get-ChildItem ~ -Recurse -EA SilentlyContinue).Count }
#
# 2. While it runs, check its status with Get-Job
#
# 3. When it finishes, retrieve the result
#    Receive-Job $job -Wait
#
# 4. Start 3 jobs that each sleep for different amounts of time.
#    See which finishes first. Think about why?
#    $j1 = Start-ThreadJob { Start-Sleep 10; "Job 1 done" }
#    $j2 = Start-ThreadJob { Start-Sleep 5; "Job 2 done" }
#    $j3 = Start-ThreadJob { Start-Sleep 1; "Job 3 done" }
#    Get-Job | Wait-Job | Receive-Job
#
# 5. Don't forget to clean up: Get-Job | Remove-Job
