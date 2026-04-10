# ============================================================================
# Ch 4: Running Commands
# ============================================================================
# PowerShell commands follow a Verb-Noun naming convention and have a
# consistent structure. Let's explore how commands work.
# ============================================================================


# --- Security: Execution Policy ---

# PowerShell has a machine-wide setting that controls what scripts can run.
# It does NOT affect typing interactive commands — only running script files.
Get-ExecutionPolicy

# Common values:
#   Restricted   → No scripts. Interactive commands only. (Windows 10 default)
#   RemoteSigned → Local scripts run freely; downloaded scripts need a signature.
#   AllSigned    → Every script must be signed.
#   Unrestricted → Everything runs.

# Microsoft recommends RemoteSigned for machines where you run scripts:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# IMPORTANT: This is NOT a security boundary — an informed user can always
# bypass it. Its purpose is to prevent users from accidentally running a
# malicious script they downloaded. Don't rely on it as your only defense.


# --- The Verb-Noun Convention ---

# See all approved PowerShell verbs
Get-Verb

# Common verbs you'll see everywhere:
#   Get-    → Retrieve something
#   Set-    → Change something
#   New-    → Create something
#   Remove- → Delete something
#   Start-  → Begin something
#   Stop-   → End something

# Knowing the convention lets you GUESS command names:
# "How do I test a network connection?" → probably Test-Something
Test-Connection -TargetName google.com -Count 2   # PowerShell-native ping!
Test-Connection -TargetName google.com -Quiet      # Returns $true/$false


# --- Running Commands with Parameters ---

# Get all processes
Get-Process

# Get a specific process by name
Get-Process -Name pwsh

# Get only cmdlets (not aliases, functions, or external tools)
Get-Command -CommandType Cmdlet

# Tab completion works for parameter names!
# Try typing: Get-Process -N<Tab>

# You can truncate parameter names as long as they're unambiguous
Get-Process -N pwsh    # -N is enough because only -Name starts with N here


# --- Aliases: Convenient but Dangerous ---

# These all do the same thing:
Get-ChildItem ~
dir ~
gci ~
ls ~   # This alias may not be present in pwsh on non-Windows

# Find what an alias maps to
Get-Alias ls
Get-Alias dir
Get-Alias gci

# Find all aliases for a command
Get-Alias -Definition Get-ChildItem

# See ALL aliases
Get-Alias

# You can create your own aliases (they last only for the current session)
New-Alias -Name ntst -Value netstat
ntst -an   # now works!

# HOT TAKE: Use aliases interactively, never in scripts!
# In scripts, always use the full command name for readability.
# Some disagree when it comes to common aliases like ? and % and that's OK!


# --- External Commands ---

# PowerShell runs your old command-line tools just fine — you don't have to
# abandon everything you already know.
ping google.com
ipconfig      # Windows
# ip addr     # Linux/macOS

# PowerShell-native alternatives are usually better (structured output):
Test-Connection -TargetName google.com -Count 2   # vs. ping


# --- Common Parameters ---

# Every command supports common parameters like -Verbose and -ErrorAction.
# These come from [CmdletBinding()] which we'll cover later.

# -WhatIf: "What would happen if I ran this?" (no changes made)
Get-Process -Name pwsh | Stop-Process -WhatIf

# -Verbose: Show extra detail about what's happening
New-Item tempfile.txt -Verbose
Remove-Item tempfile.txt -Verbose


# --- Dealing with Errors ---

# Red text is normal — don't panic. Read it carefully.
# PowerShell tries to tell you exactly what went wrong.

# Common mistake 1: Missing the dash in the command name
# Get Content          # Wrong — "Get" isn't a command
# Get-Content          # Right

# Common mistake 2: Missing space between parameter and value
# Get-Process -Namepwsh    # Wrong
# Get-Process -Name pwsh   # Right

# Common mistake 3: Wrong alias expectation — always verify with Get-Alias
Get-Alias -Definition Get-ChildItem

# When you see an error you don't understand, read the help:
# Get-Help <CommandName> -Examples
# Get-Help <CommandName> -Online


# --- Lab Challenge ---
# Try these on your own:
#
# 1. Display all running processes
#    Get-Process
#
# 2. Test a connection to a website WITHOUT using the native ping command
#    Test-Connection -TargetName <domain or ip> -Count <count>
# 2b. See how short you can make this command
#
# 3. Find all commands of type Cmdlet
#    Get-Command -CommandType Cmdlet
#
# 4. Display all aliases
#    Get-Alias
#
# 5. Create an alias 'ntst' for netstat, then use it
#    New-Alias -Name ntst -Value netstat
#
# 6. Find all processes starting with 'p'
#    Get-Process -Name p*
#
# 7. Create two folders in your home directory, then remove both at once
#    New-Item -Path ~ -Name SummitTestFolder1 -ItemType Directory
#    New-Item -Path ~ -Name SummitTestFolder2 -ItemType Directory
#    Remove-Item ~/SummitTestFolder*
#
# 8. What alias maps to Get-Process?
#    Get-Alias -Definition Get-Process
