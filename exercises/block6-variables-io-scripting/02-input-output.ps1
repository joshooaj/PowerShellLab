# ============================================================================
# Ch 17: Input and Output — Communicating with the User
# ============================================================================
# PowerShell has multiple output streams. Understanding them is
# key to writing clear, professional scripts.
# ============================================================================


# --- Write-Output (The Default) ---

# Write-Output sends objects to the pipeline — it's the default behavior.
# These two are equivalent:
Write-Output "Hello, World!"
"Hello, World!"

# Objects from Write-Output can be piped further
Write-Output "first", "second", "third" | ForEach-Object { $_.ToUpper() }

# Data from Write-Output can be captured in variables
$result = Write-Output "captured"
$result


# --- Write-Host (Display Only) ---

# Write-Host writes directly to the console — bypasses the pipeline.
# Use it for user-facing messages, NOT for data.

Write-Host "This is a console message" -ForegroundColor Cyan
Write-Host "Warning style" -ForegroundColor Yellow -BackgroundColor DarkRed
Write-Host "No newline... " -NoNewline
Write-Host "continues here!"

# ⚠️ Write-Host data CANNOT be captured or piped
$nope = Write-Host "try to capture"
$nope

# Rule: Use Write-Host for display. Use Write-Output for data.


# --- Write-Verbose ---

# Verbose messages appear only when the user opts in with -Verbose.
# Perfect for "what is the script doing?" messages.

function Get-DemoData {
    [CmdletBinding()]
    param()

    Write-Verbose "Starting data collection..."
    $processes = Get-Process
    Write-Verbose "Found $($processes.Count) processes"

    $top5 = $processes | Sort-Object WorkingSet -Descending | Select-Object -First 5
    Write-Verbose "Returning top 5 by memory usage"

    $top5
}

# Without -Verbose: only the data
Get-DemoData

# With -Verbose: data + behind-the-scenes commentary
Get-DemoData -Verbose


# --- Write-Warning ---

# Yellow warning messages — for non-critical issues
Write-Warning "The configuration file was not found. Using defaults."
Write-Warning "This operation may take several minutes."


# --- Write-Error ---

# Red error messages — for problems
Write-Error "Something went wrong!" # Uncomment to see

# Non-terminating by default. — the script continues after Write-Error
# To stop execution, use throw or $ErrorActionPreference
$ErrorActionPreference = 'Stop'
Write-Error "Whoomp! There it is!"
Write-Output "You won't see this thanks to the ErrorActionPreference"

# --- Write-Debug ---

# Debug messages appear only with -Debug or $DebugPreference = 'Continue'
function Test-DebugDemo {
    [CmdletBinding()]
    param($Value)

    Write-Debug "Input value: $Value"
    Write-Debug "Type: $($Value.GetType().Name)"

    $Value * 2
}

Test-DebugDemo -Value 21
Test-DebugDemo -Value 21 -Debug


# --- Write-Information & Write-Progress ---

# Write-Information: general informational messages (stream 6)
Write-Information "Starting process..." -InformationAction Continue

# Write-Progress: progress bars for long operations
1..10 | ForEach-Object {
    Write-Progress -Activity "Processing items" -Status "Item $_" -PercentComplete ($_ * 10)
    Start-Sleep -Milliseconds 200
}
Write-Progress -Activity "Processing items" -Completed


# --- Read-Host (Getting Input) ---

# ⚠️ NOTE: Read-Host pauses execution waiting for input!
# If you're running this whole file with F5, comment these lines out.
# Use F8 (Run Selection) to try them interactively.

# Simple text input
$yourName = Read-Host -Prompt "What is your name"
"Hello, $yourName!"

# Try it yourself with F8 — select the two lines above and press F8!

# Secure input (for passwords — masks the text)
$secret = Read-Host -Prompt "Enter password" -AsSecureString
$secret
# Note: We can't display a SecureString — that's the point!


# Well... you can, it's just not obvious...
# There's this way...
[Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
)

# Or my favorite...
(New-Object pscredential -ArgumentList username, $secret).GetNetworkCredential().Password
[pscredential]::new('a', $secret).GetNetworkCredential().Password


# --- Output Streams Summary ---

# Stream 1: Success     (Write-Output)      — pipeline data, variable assignment
# Stream 2: Error       (Write-Error)       — error messages
# Stream 3: Warning     (Write-Warning)     — warnings
# Stream 4: Verbose     (Write-Verbose)     — opt-in details
# Stream 5: Debug       (Write-Debug)       — developer debug info
# Stream 6: Information (Write-Information) — general info
# <no num>: Progress    (Write-Progress)    - Progress stream does not support redirection


# --- Lab Challenges ---
#
# 1. Write a function that uses Write-Verbose to narrate its steps:
#    function Get-LargestFiles {
#        [CmdletBinding()] param([int]$Count = 5)
#        Write-Verbose "Scanning $HOME..."
#        ...
#    }
#
# 2. Use Write-Progress to show a status bar while processing files:
#    $files = Get-ChildItem ~ -File -ErrorAction SilentlyContinue
#    for ($i = 0; $i -lt $files.Count; $i++) { ... }
#
# 3. Explain the difference: why does this capture nothing?
#    $x = Write-Host "Hello"
#    But this captures "Hello"?
#    $y = Write-Output "Hello"
