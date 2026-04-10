# ============================================================================
# Block 2: Providers & the Pipeline (Chapters 5-6)
# ============================================================================
# Ch 5 - Working with Providers
#
# PowerShell providers give you a filesystem-like interface to many
# different data stores. The same commands (Get-ChildItem, Set-Location)
# work across all of them!
# ============================================================================


# --- What Providers Are Available? ---

Get-PSProvider

# Each provider exposes one or more "drives"
Get-PSDrive


# --- The Item Cmdlet Family ---

# The cmdlets you use with any PSDrive all have "Item" in their noun.
# This is a great discovery pattern:
Get-Command -Noun *item*

# Key cmdlets you'll use constantly:
#   Get-ChildItem  — list contents of a container (like ls / dir)
#   Get-Item       — get a specific item
#   New-Item       — create an item
#   Remove-Item    — delete an item
#   Set-Item       — change an item's value (not all providers support this)
#   Get-ItemProperty / Set-ItemProperty — read/write item attributes


# --- The FileSystem Provider (you already know this one) ---

# Navigate around
Set-Location ~
Get-ChildItem

# Create a test directory and file
New-Item -Path ~/ProviderDemo -ItemType Directory -Force
New-Item -Path ~/ProviderDemo/hello.txt -ItemType File -Value "Hello from PowerShell!"

# Read the file
Get-Content ~/ProviderDemo/hello.txt

# Use wildcards
Get-ChildItem ~/ProviderDemo/*.txt

# Push and Pop
Push-Location ~/ProviderDemo    # You are in the folder now
Pop-Location                    # You are wherever you were before the last push

# Clean up
Remove-Item ~/ProviderDemo -Recurse -Force


# --- The Environment Provider ---

# Browse environment variables like a filesystem!
Get-ChildItem Env:

# Get a specific variable (case-sensitive except on Windows!)
Get-Item Env:PATH

# Set a temporary environment variable (only lasts this session)
Set-Item -Path Env:WORKSHOP_DEMO -Value "PowerShell Summit 2026"
Get-Item Env:WORKSHOP_DEMO

# Clean up
Remove-Item Env:WORKSHOP_DEMO


# --- The Variable Provider ---

# All your PowerShell variables are accessible as a drive
$myName = "Summit Attendee"
Get-ChildItem Variable:myName

# See ALL variables in your session
Get-ChildItem Variable:

# See just the first 10 variables in your session
Get-ChildItem Variable: | Select-Object -First 10


# --- The Function Provider ---

# Even functions are browsable!
Get-ChildItem Function: | Select-Object -First 10


# --- Wildcards vs. Literal Paths ---

# By default, -Path accepts wildcards (* and ?)
Get-ChildItem Env:PATH        # exact name — works fine
Get-ChildItem Env:P*          # wildcard — matches PATH, PROCESSOR_ARCHITECTURE, etc.

# Problem: some items have * or ? in their actual names (common on Linux/macOS).
# If you have a file literally named "report?.txt", wildcards will mis-match it.
# Solution: use -LiteralPath — it is never treated as a wildcard.
Get-Item -LiteralPath Env:PATH    # treated as the exact string "PATH"

# Important: -LiteralPath is a named-only parameter (not positional), so you
# must type the parameter name explicitly — you can't rely on tab-completing position 1.
Get-Item -LiteralPath ~

# Create a... difficult file
New-Item -Path '~/Special [Characters].txt'
"Hello there!" | Set-Content -LiteralPath '~/Special [Characters].txt'

# You won't find the file using -Path
Get-Content -Path '~/Special [Characters].txt'

# You MUST use -LiteralPath to find the file
Get-Content -LiteralPath '~/Special [Characters].txt'

# Clean up
Remove-Item -LiteralPath '~/Special [Characters].txt'

# --- Using the Same Commands Everywhere ---

# This is the key insight: Get-ChildItem, Set-Location, Get-Item,
# New-Item, Remove-Item — they all work across every provider.
# The interface is consistent, even when the underlying data store is different.

# Quick comparison:
Write-Output "--- Files ---"
Get-ChildItem ~ | Select-Object -First 3 Name

Write-Output "`n--- Environment Variables ---"
Get-ChildItem Env: | Select-Object -First 3 Name, Value

Write-Output "`n--- Variables ---"
Get-ChildItem Variable: | Select-Object -First 3 Name, Value


# --- Windows: The Registry Provider ---
# (Windows-only — skip on macOS/Linux)

if ($IsWindows) {
    # Two registry drives are available: HKLM: and HKCU:
    Get-PSDrive | Where-Object Provider -match Registry

    # Navigate and browse just like the filesystem
    Set-Location HKCU:\Software\Microsoft\Windows
    Get-ChildItem

    # Read a registry value (item property)
    Get-ItemProperty -Path HKCU:\Software\Microsoft\Windows\DWM -Name EnableAeroPeek

    # Change a registry value — use Set-ItemProperty
    # Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\DWM -Name EnableAeroPeek -Value 0

    # Go back home
    Set-Location ~
}


# --- Lab Challenge ---
#
# 1. List all PSDrives and identify which provider each uses
#    Get-PSDrive | Select-Object Name, Provider
#
# 2. Display your PATH environment variable using both -Path (wildcard) and -LiteralPath
#    Get-ChildItem Env:PATH
#    Get-Item -LiteralPath Env:PATH
#
# 3. Discover cmdlets that work with providers
#    Get-Command -Noun *item*
#
# 4. Create a temp folder, put a file in it, then remove both
#    New-Item ~/TempLab -ItemType Directory
#    "test content" | Out-File ~/TempLab/test.txt
#    Remove-Item ~/TempLab -Recurse
#
# 5. (Windows only) Navigate to HKCU:\Software and list the contents
#    Set-Location HKCU:\Software
#    Get-ChildItem
#
# 6. PowerShell also supports navigation using "+" and "-" to
#    to browser forward and backward through your location history.
#    Try it out!
#    cd -
#    cd +