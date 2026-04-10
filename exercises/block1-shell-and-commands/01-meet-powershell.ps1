# ============================================================================
# Block 1: The Shell & Running Commands (Chapters 1-4)
# ============================================================================
# This script covers:
#   Ch 1 - Before You Begin (environment check)
#   Ch 2 - Meet PowerShell (first commands)
#
# Run each section one at a time using F8 (Run Selection) in VS Code.
# ============================================================================


# ----------------------------------------------------------------------------
# Ch 1: Before You Begin — Why PowerShell?
# ----------------------------------------------------------------------------

# PowerShell is cross-platform! Let's prove it.
# This same script runs on Windows, macOS, AND Linux.

# What version of PowerShell are you running?
$PSVersionTable

# Just the version number
$PSVersionTable.PSVersion

# What OS are we on? (PowerShell 7+ automatic variables)
$IsWindows
$IsMacOS
$IsLinux

# A quick summary of your environment
[PSCustomObject]@{
    PSVersion = $PSVersionTable.PSVersion.ToString()
    OS        = $IsWindows ? 'Windows' : ($IsLinux ? 'Linux' : 'macOS')
    Edition   = $PSVersionTable.PSEdition
    User      = [System.Environment]::UserName
    Home      = $HOME
}


# --- Life WITHOUT PowerShell (imagine doing this manually) ---

# "How many files are in my home directory?"
#   Without PowerShell: open Explorer, browse, count... ugh.
#   With PowerShell:
(Get-ChildItem ~ -File).Count

# "What's the largest file in my home directory?"
#   Without PowerShell: sort by size in Explorer, scroll...
#   With PowerShell:
Get-ChildItem ~ -File |
    Sort-Object Length -Descending |
    Select-Object -First 1 Name, @{N='SizeMB'; E={[math]::Round($_.Length / 1MB, 2)}}


# ----------------------------------------------------------------------------
# Ch 2: Meet PowerShell — Your New Best Friend
# ----------------------------------------------------------------------------

# Where are we right now?
Get-Location

# What's in our current directory?
Get-ChildItem

# PowerShell commands follow Verb-Noun naming. Try these:
Get-Date                             # What time is it?
Get-Process | Select-Object -First 5 # What's running?
Get-Host                             # Info about this PowerShell session

# Navigate around (these work on every OS)
Set-Location ~                      # Go to your home directory
Get-ChildItem                       # See what's there
Set-Location -                      # Go back to where you were


# --- The Integrated Terminal in VS Code ---

# If you're in VS Code right now, here are some tips:
#   - Ctrl+` (backtick or grave) toggles the terminal panel
#   - F8 runs the current line or selected text (your most-used shortcut today!)
#   - F5 runs the entire file
#   - Ctrl+Space triggers IntelliSense (autocomplete)

# Try it — type "Get-" below and press Ctrl+Space to see suggestions:
# Get-


# --- Quick Experiments ---

# PowerShell can do math
2 + 2
10 / 3
[math]::Pow(2, 10)    # 2 to the power of 10 = 1024

# PowerShell knows about file sizes
1KB         # 1024
1MB         # 1048576
1GB         # 1073741824

# Strings are objects too — you can call methods on them!
"hello world".ToUpper()
"HELLO WORLD".ToLower()
"PowerShell Summit 2026".Length


# --- Lab Challenge ---
# Try these on your own:
#
# 1. Run $PSVersionTable and find your PSVersion
#
# 2. Use Get-Location to see where you are, then use
#    Set-Location to navigate to your home directory (~)
#
# 3. Run Get-ChildItem in your home directory.
#    How many items are listed?
#
# 4. Try some math: what's 2 to the power of 16?
#    Hint: [math]::Pow(2, 16)
#
# 5. Create a string and call .ToUpper() on it
