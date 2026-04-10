# ============================================================================
# Ch 26-27: Tips, Tricks & Next Steps — PowerShell Power-Ups
# ============================================================================
# Useful operators, profile customization, and patterns you'll
# reach for every day.
# ============================================================================


# --- Ternary Operator (PowerShell 7+) ---
# Shorthand for if ($something) { "true" } else { "false" }
$isAdmin = $false
$status = $isAdmin ? "Administrator" : "Standard User"
$status

# Equivalent to:
# if ($isAdmin) { "Administrator" } else { "Standard User" }

# Practical use
$os = ($IsWindows -or ($null -eq $IsWindows)) ? "Windows" : ($IsLinux ? "Linux" : "macOS")
$os


# --- Null-Coalescing & Null-Conditional (PowerShell 7+) ---

# ?? — use a default if the value is $null
$name = $null
$displayName = $name ?? "Unknown"
$displayName    # Unknown

$name = "Josh"
$displayName = $name ?? "Unknown"
$displayName    # Josh

# ??= — assign only if currently $null
$config = $null
$config ??= @{ Theme = 'dark'; FontSize = 14 }
$config


# --- Pipeline Chain Operators ---

# && — run second command only if first SUCCEEDS
# || — run second command only if first FAILS

Get-Process -Id $PID && Write-Host "Process found!" -ForegroundColor Green
Get-Process -Name 'zzzNotReal' -ErrorAction SilentlyContinue || Write-Warning "Process not found"


# --- Useful Operators ---

# -join: combine array elements
$words = 'PowerShell', 'Summit', 'Rocks'
$words -join ' '                    # Power Shell Summit
$words -join '-'                    # Power-Shell-Summit

# -split: break strings apart
"one,two,three" -split ','          # Array of 3 items
"Hello   World" -split '\s+'       # Split on whitespace

# -replace: regex replacement
"File_Name_Here" -replace '_', ' '

# -as / -is: type testing and conversion
42 -is [int]          # True
"42" -is [int]        # False
"42" -as [int]        # 42 (converted)
"hello" -as [int]     # $null (can't convert, but no error)

# -contains / -in: collection membership
$fruits = 'apple', 'banana', 'cherry'
$fruits -contains 'banana'    # True
'cherry' -in $fruits          # True


# --- String Methods ---

$text = "  Hello, PowerShell World!  "

$text.Trim()                     # Remove whitespace from edges
$text.ToUpper()                  # HELLO, POWERSHELL WORLD!
$text.ToLower()                  # hello, powershell world!
$text.Replace('World', 'Summit') # Hello, PowerShell Summit!
$text.Split(',')                 # Split on comma
$text.Contains('PowerShell')     # True
$text.StartsWith('  Hello')      # True
$text.Substring(9, 10)           # PowerShell

# String formatting
"Process count: {0:N0}" -f (Get-Process).Count        # Formatted number
"Disk: {0:P1}" -f 0.847                                # 84.7%
"Today: {0:yyyy-MM-dd}" -f (Get-Date)                  # 2026-04-14


# --- Date Methods ---

$now = Get-Date

$now.AddDays(7)                # A week from now
$now.AddHours(-3)              # 3 hours ago
$now.ToString('yyyy-MM-dd')    # Custom format
$now.DayOfWeek                 # Day name
$now.DayOfYear                 # Day number
$now.ToUniversalTime()         # Convert to UTC

# Date math
$summit = [datetime]'2026-04-16'
$daysUntil = ($summit - (Get-Date)).Days
"$daysUntil days left of Summit!"


# --- Calculated Properties Recap ---

Get-Process | Select-Object -First 5 Name,
    @{ Name = 'Memory (MB)'; Expression = { [math]::Round($_.WorkingSet / 1MB, 1) }},
    @{ Name = 'CPU (s)';     Expression = { [math]::Round($_.CPU, 2) }}


# --- $PSDefaultParameterValues ---

# Set default parameter values for any command — great in your profile!
# Format the key as 'CmdletName:ParameterName' (wildcards supported).

# Always use UTF-8 encoding when writing files:
$PSDefaultParameterValues['Out-File:Encoding']    = 'utf8'
$PSDefaultParameterValues['Add-Content:Encoding'] = 'utf8'

# Silently skip errors from Get-ChildItem by default:
$PSDefaultParameterValues['Get-ChildItem:ErrorAction'] = 'SilentlyContinue'

# Wildcard: apply -ErrorAction SilentlyContinue to ALL commands
# (useful to set temporarily — not recommended permanently):
# $PSDefaultParameterValues['*:ErrorAction'] = 'SilentlyContinue'

# View current defaults:
$PSDefaultParameterValues

# Use a ScriptBlock value to run code fresh each time the parameter is used:
$PSDefaultParameterValues['Invoke-RestMethod:Headers'] = {
    @{ Authorization = "Bearer $env:MY_API_TOKEN" }
}

# Remove a specific default:
$PSDefaultParameterValues.Remove('Get-ChildItem:ErrorAction')

# Clear all defaults:
$PSDefaultParameterValues.Clear()

# Read more: Get-Help about_Parameters_Default_Values


# --- Script Blocks ---

# A script block is a portable chunk of code
$greet = { param($name) "Hello, $name!" }
& $greet "PowerShell"

# Used everywhere: Where-Object, ForEach-Object, jobs, etc.
$filter = { $_.WorkingSet -gt 50MB }
Get-Process | Where-Object $filter | Select-Object -First 5 Name, WorkingSet


# --- Your PowerShell Profile ---

# The profile is a script that runs every time PowerShell starts.
# Great for aliases, functions, and customizing your prompt.

# Where is your profile?
$PROFILE

# Does it exist?
Test-Path $PROFILE

# Example profile content (DON'T run this — it's for your profile file):
# function prompt {
#     $path = (Get-Location).Path.Replace($HOME, '~')
#     "PS $path> "
# }
#
# Set-Alias -Name g -Value git
# Set-Alias -Name c -Value code
#
# function mkcd { param($Path) New-Item $Path -ItemType Directory -Force; Set-Location $Path }

# Create a profile if you don't have one:
# if (-not (Test-Path $PROFILE)) {
#     New-Item -Path $PROFILE -ItemType File -Force
# }
# Then: code $PROFILE


# --- Useful One-Liners to Remember ---

# Find commands for a topic
Get-Command *json*

# Explore objects
Get-Process | Get-Member -MemberType Property

# Quick file search
Get-ChildItem ~ -Recurse -Filter '*.ps1' -ErrorAction SilentlyContinue | Select-Object FullName

# System info
[PSCustomObject]@{
    Computer   = $env:COMPUTERNAME ?? (hostname)
    OS         = $IsWindows ? 'Windows' : ($IsLinux ? 'Linux' : 'macOS')
    PSVersion  = $PSVersionTable.PSVersion.ToString()
    Uptime     = (Get-Uptime).ToString()
    Processes  = (Get-Process).Count
}


# --- Where to Go from Here ---

# 1. PowerShell documentation: https://learn.microsoft.com/powershell/
# 2. PowerShell GitHub: https://github.com/PowerShell/PowerShell
# 3. PowerShell Gallery: https://www.powershellgallery.com
# 4. PowerShell Discord / communities
# 5. "Learn PowerShell in a Month of Lunches" available from Manning Publications
# 6. Practice! Build tools that solve YOUR problems.


# --- Final Lab Challenge: Build Something! ---
#
# Combine everything you've learned into a mini-tool like this function:
#
# function Get-SystemReport {
#     [CmdletBinding()]
#     param(
#         [ValidateSet('Brief', 'Full')]
#         [string]$Detail = 'Brief'
#     )
#
#     Write-Verbose "Gathering system info..."
#     $report = [ordered]@{
#         Computer  = $env:COMPUTERNAME ?? (hostname)
#         OS        = $IsWindows ? 'Windows' : ($IsLinux ? 'Linux' : 'macOS')
#         PSVersion = $PSVersionTable.PSVersion.ToString()
#         Uptime    = (Get-Uptime).ToString()
#     }
#
#     if ($Detail -eq 'Full') {
#         Write-Verbose "Adding detailed information..."
#         $report['Processes']    = (Get-Process).Count
#         $report['Modules']     = (Get-Module -ListAvailable).Count
#         $report['ProfilePath'] = $PROFILE
#     }
#
#     [PSCustomObject]$report
# }
#
# Try it:
#   Get-SystemReport
#   Get-SystemReport -Detail Full -Verbose
