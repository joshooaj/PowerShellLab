# ============================================================================
# Ch 22: Using Someone Else's Script
# ============================================================================
# You WILL inherit, borrow, or google someone else's script.
# Being able to READ and UNDERSTAND unfamiliar code is a core skill.
#
# Methodology:
#   1. Identify the high-level purpose (read comments, help, function name)
#   2. Map out variables and what they hold
#   3. Look up any commands you don't recognize with Get-Help
#   4. Trace the flow — especially Begin / Process / End blocks, and logic / loops
#   5. Understand try / catch: what's attempted, what happens on error
#   6. Run small pieces in isolation to verify your understanding
#   7. Run the whole thing when you're confident
# ============================================================================


# =============================================================================
# EXAMPLE SCRIPT TO DISSECT: Get-SystemSnapshot
#
# Imagine you found this on GitHub. Read through it first.
# Then we'll walk through it step-by-step.
# =============================================================================

function Get-SystemSnapshot {
    <#
    .SYNOPSIS
        Collects a system health snapshot for one or more computers.

    .DESCRIPTION
        Get-SystemSnapshot returns OS information, memory usage, and CPU load.
        Accepts computer names from the pipeline. Computers that cannot be
        reached are flagged in the output rather than crashing the script.

    .PARAMETER ComputerName
        One or more computer names to query. Defaults to localhost.

    .PARAMETER IncludeDisk
        If specified, includes disk usage for each fixed drive.

    .EXAMPLE
        Get-SystemSnapshot

    .EXAMPLE
        'web01', 'web02' | Get-SystemSnapshot -IncludeDisk -Verbose
    #>
    [CmdletBinding()]
    param(
        [switch]$IncludeDisk
    )

    begin {
        Write-Verbose "Starting snapshot collection. IncludeDisk: $IncludeDisk"
        $commandStartTime = Get-Date
    }

    process {
        $computerName = [environment]::MachineName
        Write-Verbose "Processing: $computerName"
        try {
            $os  = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
            
            # Inaccurate method of measuring CPU usage but cross-platform and good enough
            Write-Verbose "Measuring CPU usage over a period of 2 seconds"
            $zero = New-TimeSpan -Seconds 0
            $startTime = Get-Date
            $p1 = $zero
            Get-Process | % { $p1 += $_.TotalProcessorTime ?? $zero }
            Start-Sleep -Seconds 2
            $p2 = $zero
            $processes = Get-Process | % { $p2 += $_.TotalProcessorTime ?? $zero; $_ }
            $cpuUsage = ($p2 - $p1) / ((Get-Date) - $startTime) / [environment]::ProcessorCount * 100
            $memUsage = (Get-Process | Measure-Object -Property WorkingSet64 -Sum).Sum

            $snapshot = [PSCustomObject]@{
                ComputerName   = $computerName
                Status         = 'OK'
                OS             = $os
                TotalMemoryGB  = [math]::Round([GC]::GetGCMemoryInfo().TotalAvailableMemoryBytes / 1GB, 2)
                FreeMemoryGB   = [math]::Round($memUsage / 1GB, 2)
                CPULoadPercent = $cpuUsage
                Disks          = $null
            }

            if ($IncludeDisk) {
                Write-Verbose "Retrieving FileSystem PSProvider info"
                $fsProvider = Get-PSProvider -PSProvider FileSystem
                $snapshot.Disks = Get-PSDrive | Where-Object Provider -eq $fsProvider | Select-Object Name,
                    @{ n = 'SizeGB';  e = { ($_.Used + $_.Free) / 1GB } },
                    @{ n = 'FreeGB';  e = { $_.Free / 1GB } },
                    @{ n = 'PctFree'; e = { [math]::Round($_.Free / ($_.Used + $_.Free) * 100, 1 ) } }
            }

            $snapshot
        } catch {
            Write-Warning "Could not build system snapshot: $($_.Exception.Message)"
            [PSCustomObject]@{
                ComputerName   = $computerName
                Status         = 'Error'
                OS             = $null
                TotalMemoryGB  = $null
                FreeMemoryGB   = $null
                CPULoadPercent = $null
                Disks          = $null
            }
        }
    }

    end {
        $elapsedTime = (Get-Date) - $commandStartTime
        Write-Verbose "Collection completed in $($elapsedTime.TotalSeconds.ToString('n2')) seconds."
    }
}



# =============================================================================
# WALKTHROUGH: Dissecting Get-SystemSnapshot line by line
# =============================================================================

# --- STEP 1: High-level purpose ---
#
# function Get-SystemSnapshot { ... }
#
# The name follows Verb-Noun convention.
# "Get" = reads data (no changes made)
# "SystemSnapshot" = moment-in-time picture of a computer's state
#
# Run this to see approved verbs:
Get-Verb | Sort-Object Verb


# --- STEP 2: Read the comment-based help ---
#
# The <# ... #> block uses special keywords PowerShell understands:
#   .SYNOPSIS     — one-line summary
#   .DESCRIPTION  — detailed explanation
#   .PARAMETER    — what each param does
#   .EXAMPLE      — how to call the function
#
# PowerShell exposes this through Get-Help:
Get-Help Get-SystemSnapshot
Get-Help Get-SystemSnapshot -Full
Get-Help Get-SystemSnapshot -Examples


# --- STEP 3: Understand the parameters ---
#
# [CmdletBinding()]
#   → Advanced function. Adds -Verbose, -Debug, -ErrorAction automatically.
#
# [switch]$IncludeDisk
#   → Present = $true, absent = $false (you used these in Block 5!)


# --- STEP 4: Understand Begin / Process / End ---
#
# When a function accepts pipeline input, it often uses three special blocks:
#
#   begin   { }  — Runs ONCE before any pipeline input arrives
#                  Use it for one-time setup (create lists, open connections)
#
#   process { }  — Runs ONCE PER pipeline item
#                  This is where the main logic lives
#
#   end     { }  — Runs ONCE after all pipeline input is processed
#                  Use it for cleanup or final output
#
# In our script:
#   begin   → saves the time the command started
#   process → gathers and returns system information
#   end     → writes a verbose message including the command's elapsed time

# See Begin / Process / End in action with a simple demo:
function Show-PipelineBlocks {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$Item
    )
    begin   { Write-Host "BEGIN   — runs once at the start" -ForegroundColor Cyan }
    process { Write-Host "PROCESS — item: $Item" -ForegroundColor Yellow }
    end     { Write-Host "END     — runs once at the finish" -ForegroundColor Green }
}

'apple', 'banana', 'cherry' | Show-PipelineBlocks


# --- STEP 5: Understand Try / Catch ---
#
#   try   { ... }  — Attempt this. If a terminating error occurs, jump to catch.
#   catch { ... }  — Handle the error instead of crashing.
#
# The automatic variable $_ inside catch is the ErrorRecord.
# $_.Exception.Message is the plain-text error description.
#
# Key detail: -ErrorAction Stop turns non-terminating errors into terminating
# ones, which means try/catch can intercept them.

# Demo without an error — catch never runs:
try {
    $result = Get-Date
    "Got a result: $result"
}
catch {
    Write-Warning "This won't run because Get-Date always succeeds"
}

# Demo with an intentional error:
try {
    Get-Item "C:\PathThatDefinitelyDoesNotExist" -ErrorAction Stop
    "Script does not reach here"
}
catch {
    Write-Warning "Caught: $($_.Exception.Message)"
}

# Without -ErrorAction Stop, the error goes to the error stream and catch is skipped:
try {
    Get-Item "C:\PathThatDefinitelyDoesNotExist"   # No -ErrorAction Stop
    "Script continues here"
}
catch {
    Write-Warning "You WON'T see this — error was non-terminating"
}


# --- STEP 6: Look up unfamiliar commands ---

# Anything you don't recognize — stop and look it up.
# Q: What is [System.Runtime.InteropServices.RuntimeInformation]?
# A: It's a .NET class providing information about the environment we're running in
#    See https://learn.microsoft.com/en-us/dotnet/api/System.Runtime.InteropServices.RuntimeInformation?view=net-10.0


# --- STEP 7: Run pieces in isolation ---

# Verify your understanding of sub-expressions before trusting the whole script.

# What does this produce?
[System.Runtime.InteropServices.RuntimeInformation]::OSDescription

# How does the memory math work?
$memUsage = (Get-Process | Measure-Object -Property WorkingSet64 -Sum).Sum
$totalMem = [GC]::GetGCMemoryInfo().TotalAvailableMemoryBytes
"Free  memory (GB): $([math]::Round($memUsage / 1GB, 2))"
"Total memory (GB): $([math]::Round($totalMem / 1GB, 2))"


# --- STEP 8: Run the full function ---

Get-SystemSnapshot
Get-SystemSnapshot -Verbose
Get-SystemSnapshot -IncludeDisk
Get-SystemSnapshot -IncludeDisk -Verbose


# =============================================================================
# LAB: Dissect this function yourself using the same process.
#
# Before running it, read through it and answer:
#   Q1. What does this function do?
#   Q2. What is stored in $inventory? When is it populated?
#   Q3. What happens if $Path is a file instead of a folder?
#   Q4. Why does ValueFromPipelineByPropertyName work when piping Get-ChildItem?
#       (Hint: does Get-ChildItem output have a FullName property?)
#   Q5. What would happen if you removed the 'begin' block entirely?
# =============================================================================

function Get-FolderInventory {
    <#
    .SYNOPSIS
        Returns a file inventory for one or more directories.

    .PARAMETER Path
        One or more directory paths to scan. Accepts pipeline input.
        Also accepts the FullName property from Get-ChildItem output.

    .PARAMETER MinSizeKB
        Only return files at least this large, in kilobytes. Default is 0 (all files).

    .EXAMPLE
        Get-FolderInventory -Path C:\Logs

    .EXAMPLE
        Get-ChildItem $HOME -Directory | Get-FolderInventory -MinSizeKB 100
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('FullName')]
        [string]$Path,

        [int]$MinSizeKB = 0
    )

    begin {
        $inventory = [System.Collections.Generic.List[PSObject]]::new()
        $skipped   = 0
    }

    process {
        Write-Verbose "Scanning: $Path"

        if (-not (Test-Path -Path $Path -PathType Container)) {
            Write-Warning "Not a folder or does not exist: $Path"
            $skipped++
            return
        }

        try {
            $files = Get-ChildItem -Path $Path -File -ErrorAction Stop
            foreach ($file in $files) {
                $sizeKB = [math]::Round($file.Length / 1KB, 1)
                if ($sizeKB -ge $MinSizeKB) {
                    $inventory.Add([PSCustomObject]@{
                        Folder    = $Path
                        FileName  = $file.Name
                        SizeKB    = $sizeKB
                        AgeDays   = [math]::Round(((Get-Date) - $file.LastWriteTime).TotalDays)
                        Extension = $file.Extension
                    })
                }
            }
        }
        catch {
            Write-Warning "Error reading '$Path': $($_.Exception.Message)"
            $skipped++
        }
    }

    end {
        Write-Verbose "Done. $($inventory.Count) file(s) found. $skipped path(s) skipped."
        $inventory | Sort-Object SizeKB -Descending
    }
}

# Once you've analyzed it, try running it:
Get-FolderInventory -Path $HOME
Get-FolderInventory -Path $HOME -MinSizeKB 100 -Verbose

# Pipeline from Get-ChildItem — works because of the FullName alias on $Path:
Get-ChildItem $HOME -Directory |
    Get-FolderInventory -MinSizeKB 10 |
    Select-Object -First 10 |
    Format-Table
