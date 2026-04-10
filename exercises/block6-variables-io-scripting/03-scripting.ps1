# ============================================================================
# Ch 19-20: Scripts & CmdletBinding — From Commands to Scripts
# ============================================================================
# Scripts let you save and reuse sequences of commands.
# Parameters make them flexible. CmdletBinding makes them professional.
# ============================================================================


# --- Your First Script ---

# A script is just a .ps1 file with commands in it.
# Save this block to a file and run it, or select and press F8.

# Simple example — this IS a script:
$top = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5
$top | Format-Table Name, Id, @{N='Memory (MB)'; E={[math]::Round($_.WorkingSet / 1MB, 1)}}


# --- Adding Parameters ---

# Parameters make scripts flexible and reusable.
# Here's a parameterized script you could save as Get-TopProcess.ps1:

# ---- BEGIN: conceptual script ----
# param(
#     [int]$Count = 5,
#     [string]$SortBy = 'WorkingSet'
# )
#
# Get-Process |
#     Sort-Object $SortBy -Descending |
#     Select-Object -First $Count
# ---- END: conceptual script ----

# For demo purposes, we'll use functions (same param syntax as scripts):

function Get-TopProcess {
    param(
        [int]$Count = 5,
        [string]$SortBy = 'WorkingSet'
    )

    Get-Process |
        Sort-Object $SortBy -Descending |
        Select-Object -First $Count Name, Id, @{
            N='Memory (MB)'; E={[math]::Round($_.WorkingSet / 1MB, 1)}
        }
}

# Use it
Get-TopProcess
Get-TopProcess -Count 3
Get-TopProcess -Count 10 -SortBy CPU


# --- Mandatory Parameters ---

function Get-Greeting {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [string]$TimeOfDay = 'day'
    )

    "Good $TimeOfDay, $Name!"
}

$name = Read-Host -Prompt "Whom do I have the pleasure of greeting?"
Get-Greeting -Name $name
Get-Greeting -Name $name -TimeOfDay "morning"
Get-Greeting       # Prompts you for -Name!


# --- ValidateSet — Restricting Input ---

function Get-Greeting2 {
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [ValidateSet('morning', 'afternoon', 'evening')]
        [string]$TimeOfDay = 'morning'
    )

    "Good $TimeOfDay, $Name!"
}

Get-Greeting2 -Name "Summit" -TimeOfDay "afternoon"
Get-Greeting2 -Name "Summit" -TimeOfDay "midnight"   # Error! Not in the set


# --- CmdletBinding — The Pro Upgrade ---

# Adding [CmdletBinding()] gives your function/script superpowers:
# - Automatic -Verbose, -Debug, -ErrorAction, -WarningAction parameters
# - Access to Write-Verbose, Write-Debug
# - Consistent behavior with built-in cmdlets

function Get-DirectoryReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [switch]$IncludeHidden
    )

    Write-Verbose "Scanning directory: $Path"

    if (-not (Test-Path $Path)) {
        Write-Error "Path not found: $Path"
        return
    }

    $params = @{
        Path        = $Path
        File        = $true
        ErrorAction = 'SilentlyContinue'
    }

    if ($IncludeHidden) {
        $params['Force'] = $true
        Write-Verbose "Including hidden files"
    }

    $files = Get-ChildItem @params
    Write-Verbose "Found $($files.Count) files"

    $files | Measure-Object -Property Length -Sum -Average | ForEach-Object {
        [PSCustomObject]@{
            Path         = $Path
            FileCount    = $_.Count
            TotalSizeMB  = [math]::Round($_.Sum / 1MB, 2)
            AvgSizeKB    = [math]::Round($_.Average / 1KB, 2)
        }
    }
}

Get-DirectoryReport -Path $PWD
Get-DirectoryReport -Path $PWD -Verbose
Get-DirectoryReport -Path $PWD -IncludeHidden -Verbose


# --- Switch Parameters ---

# Switch params are practically booleans: present = $true, absent = $false
function Get-ProcessReport {
    [CmdletBinding()]
    param(
        [switch]$MemoryOnly,
        [int]$Top = 10
    )

    $processes = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First $Top

    $memory = @{N='Memory (MB)'; E={[math]::Round($_.WorkingSet / 1MB, 1)}}
    if ($MemoryOnly) {
        $processes | Select-Object Name, $memory
    } else {
        $processes | Select-Object Name, Id, CPU, $memory
    }
}

Get-ProcessReport -Top 5
Get-ProcessReport -Top 5 -MemoryOnly


# --- Splatting — Clean Parameter Passing ---

# Instead of very long one-liners, consider putting parameters in a hashtable
# and "splatting" them with @ instead of $

$params = @{
    Path        = $PWD
    Filter      = '*.ps1'
    Recurse     = $true
    ErrorAction = 'SilentlyContinue'
}
Get-ChildItem @params

# Compare to the one-liner:
Get-ChildItem -Path $PWD -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue


# --- Pipeline Input in Functions ---

function Get-FileAge {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [System.IO.FileInfo]$File
    )

    process {
        [PSCustomObject]@{
            Name    = $File.Name
            AgeDays = [math]::Round(((Get-Date) - $File.LastWriteTime).TotalDays, 1)
            SizeKB  = [math]::Round($File.Length / 1KB, 1)
        }
    }
}

# Pipe files into it
Get-ChildItem $PWD -File -ErrorAction SilentlyContinue |
    Select-Object -First 5 |
    Get-FileAge |
    Sort-Object AgeDays -Descending


# --- Comment-Based Help ---

# PowerShell reads specially formatted comment blocks and exposes them as help.
# Use <# ... #> immediately before [CmdletBinding()] or param().
# Supported keywords: .SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE, .INPUTS
# .OUTPUTS, .NOTES, .LINK,
# Also supported, less common: .COMPONENT, .ROLE, .FUNCTIONALITY, .FORWARDHELPTARGETNAME,
# .FORWARDHELPCATEGORY, .REMOTEHELPRUNSPACE, .EXTERNALHELP

function Get-LargestFiles {
    <#
    .SYNOPSIS
        Lists the largest files in a directory.

    .DESCRIPTION
        Get-LargestFiles scans the specified directory and returns the top N
        files by size, including the file name, size in MB, and age in days.
        Use -Recurse to include subdirectories.

    .PARAMETER Path
        The directory to scan. Defaults to the current directory.

    .PARAMETER Count
        The number of files to return. Defaults to 10.

    .PARAMETER Recurse
        If specified, includes files from all subdirectories.

    .EXAMPLE
        Get-LargestFiles -Path C:\Users -Count 5

        Returns the 5 largest files directly in C:\Users.

    .EXAMPLE
        Get-LargestFiles -Path C:\Logs -Recurse

        Returns the 10 largest files in C:\Logs and all subdirectories.

    .NOTES
        Author: PowerShell Summit Onramp Workshop
    #>
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage = "Directory path to scan")]
        [string]$Path = $PWD,

        [Parameter(HelpMessage = "Number of files to return")]
        [int]$Count = 10,

        [switch]$Recurse
    )

    Write-Verbose "Scanning '$Path' (Recurse: $($Recurse.IsPresent), Top: $Count)"

    $params = @{
        Path        = $Path
        File        = $true
        Recurse     = $Recurse.IsPresent
        ErrorAction = 'SilentlyContinue'
    }

    Get-ChildItem @params |
        Sort-Object Length -Descending |
        Select-Object -First $Count |
        ForEach-Object {
            [PSCustomObject]@{
                Name    = $_.Name
                SizeMB  = [math]::Round($_.Length / 1MB, 2)
                AgeDays = [math]::Round(((Get-Date) - $_.LastWriteTime).TotalDays, 1)
                Path    = $_.FullName
            }
        }
}

# PowerShell generates help automatically from the comment block:
Get-Help Get-LargestFiles
Get-Help Get-LargestFiles -Examples
Get-Help Get-LargestFiles -Parameter Path

# Use it:
Get-LargestFiles -Path $HOME -Count 5 -Verbose
Get-LargestFiles -Path $HOME -Recurse -Count 3


# --- Parameter Aliases (Ch 20) ---

# [Alias()] lets a parameter accept alternate names.
# Useful for consistency with other PowerShell commands or common abbreviations.

function Get-DiskUsage {
    <#
    .SYNOPSIS
        Summarizes disk usage for local drives, with a low-space warning threshold.

    .PARAMETER ComputerName
        The computer to query. Accepts aliases: -CN and -MachineName.

    .PARAMETER WarningThreshold
        Warn when free space falls below this percentage. Must be 1–100.

    .EXAMPLE
        Get-DiskUsage
        Get-DiskUsage -CN localhost -WarningThreshold 15
    #>
    [CmdletBinding()]
    param(
        [Parameter(HelpMessage = "Computer name to query")]
        [Alias('CN', 'MachineName')]    # -CN and -MachineName are accepted alternatives
        [string]$ComputerName = 'localhost',

        [ValidateRange(1, 100)]         # Chapter 20: restrict input to a valid range
        [int]$WarningThreshold = 20
    )

    Write-Verbose "Querying $ComputerName (warn threshold: $WarningThreshold%)"

    Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue |
        Where-Object { $_.Used -gt 0 } |
        ForEach-Object {
            $total  = $_.Used + $_.Free
            $pctFree = [math]::Round($_.Free / $total * 100, 1)
            [PSCustomObject]@{
                Drive          = "$($_.Name):"
                UsedGB         = [math]::Round($_.Used / 1GB, 2)
                FreeGB         = [math]::Round($_.Free / 1GB, 2)
                PctFree        = $pctFree
                NeedsAttention = $pctFree -lt $WarningThreshold
            }
        }
}

# All three parameter names are equivalent thanks to [Alias()]:
Get-DiskUsage -ComputerName localhost
Get-DiskUsage -CN localhost
Get-DiskUsage -MachineName localhost

# ValidateRange prevents invalid input:
Get-DiskUsage -WarningThreshold 10
Get-DiskUsage -WarningThreshold 0     # Error! 0 is outside the 1–100 range


# --- Lab Challenges ---
#
# 1. Write a function with [CmdletBinding()] that accepts a -Path
#    parameter and lists files sorted by size. Include Write-Verbose
#    messages explaining what the function is doing.
#
# 2. Add [ValidateSet()] to a parameter so only certain values
#    are accepted (e.g., SortBy = 'Size', 'Name', 'Date').
#
# 3. Write a function that accepts pipeline input (ValueFromPipeline)
#    and processes each item in a process {} block.
#
# 4. Practice splatting: take a long Get-ChildItem or Get-Process
#    command and convert the parameters to a hashtable.
