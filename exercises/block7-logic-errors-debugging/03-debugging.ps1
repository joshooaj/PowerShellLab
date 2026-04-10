# ============================================================================
# Ch 25: Debugging — Finding and Fixing Problems
# ============================================================================
# When code doesn't behave as expected, debugging tools help you
# see what's happening step by step.
# ============================================================================


# --- Write-Verbose and Write-Debug ---

# The simplest "debugging" — add commentary to your functions

function Find-LargeFiles {
    [CmdletBinding()]
    param(
        [string]$Path = $HOME,
        [int]$MinSizeMB = 10,
        [int]$Top = 5
    )

    Write-Verbose "Searching in: $Path"
    Write-Verbose "Minimum size: $MinSizeMB MB"
    Write-Debug "Path resolved to: $(Resolve-Path $Path -ErrorAction SilentlyContinue)"

    $files = Get-ChildItem -Path $Path -File -Recurse -ErrorAction SilentlyContinue
    Write-Verbose "Total files found: $($files.Count)"
    Write-Debug "First file: $($files[0].FullName)"

    $large = $files | Where-Object { $_.Length -gt ($MinSizeMB * 1MB) }
    Write-Verbose "Files over $MinSizeMB MB: $($large.Count)"

    $large |
        Sort-Object Length -Descending |
        Select-Object -First $Top Name, @{N='SizeMB'; E={[math]::Round($_.Length / 1MB, 1)}}, DirectoryName
}

# Normal run — just the results
Find-LargeFiles -MinSizeMB 1 -Top 3

# With verbose messages — see the narrative
Find-LargeFiles -MinSizeMB 1 -Top 3 -Verbose

# With debug messages — even more detail
Find-LargeFiles -MinSizeMB 1 -Top 3 -Debug

# The -Debug switch prompts before every Write-Debug message in Windows PowerShell,
# which can be tedious. Instead, set $DebugPreference to show all debug output at once:
$DebugPreference = 'Continue'           # Show Write-Debug output automatically
Find-LargeFiles -MinSizeMB 1 -Top 3     # Debug messages appear without prompting
$DebugPreference = 'SilentlyContinue'   # Back to default (suppress debug output)

# Same pattern works for verbose output:
$VerbosePreference = 'Continue'
Find-LargeFiles -MinSizeMB 1 -Top 3
$VerbosePreference = 'SilentlyContinue'


# --- Set-PSBreakpoint ---

# Breakpoints pause execution so you can inspect state.
# In VS Code, click the gutter to set breakpoints visually.
# From the console, use Set-PSBreakpoint.

# Line breakpoint (pause at a specific line of a script)
# Set-PSBreakpoint -Script .\my-script.ps1 -Line 15

# Variable breakpoint (pause when a variable is read or written)
# Set-PSBreakpoint -Variable 'result' -Mode Write

# Command breakpoint (pause when a command is called)
# Set-PSBreakpoint -Command 'Get-Process'

# List all breakpoints
Get-PSBreakpoint

# Remove all breakpoints
Get-PSBreakpoint | Remove-PSBreakpoint


# --- VS Code Debugging (F5) ---

# 1. Open a .ps1 file in VS Code
# 2. Click in the gutter (left of line numbers) to set a red breakpoint dot
# 3. Press F5 to start debugging
# 4. Execution pauses at breakpoints — you can:
#    - Hover over variables to see their values
#    - Use the Debug Console to run commands
#    - Step Over (F10)  — run current line, go to next
#    - Step Into (F11)  — dive into a function call
#    - Step Out (Shift+F11) — finish current function
#    - Continue (F5)    — run until next breakpoint
# 5. The Variables panel shows all current variables


# --- Using the Debugger Interactively ---

# You can drop into the debugger manually with Wait-Debugger
function Test-DebuggerDemo {
    [CmdletBinding()]
    param([int]$Count = 3)

    $items = @()

    for ($i = 1; $i -le $Count; $i++) {
        $item = [PSCustomObject]@{
            Index = $i
            Value = $i * $i
            Time  = Get-Date
        }

        Wait-Debugger

        $items += $item
    }

    $items
}

Test-DebuggerDemo -Count 5


# --- Inspecting Variables at Debug Time ---

# When paused at a breakpoint (in VS Code or the console), you can:
#
# $variable              — view a variable's value
# $variable | Get-Member — inspect its type and properties
# Get-Variable           — see all variables in scope
# $PSBoundParameters     — see what parameters were passed


# --- Common Debugging Strategies ---

# 1. "Print debugging" — add Write-Verbose/Write-Host to trace execution
# 2. Breakpoints — pause and inspect state
# 3. Isolate the problem — run pieces of code separately (F8 in VS Code)
# 4. Check types — use .GetType() to verify data types match expectations
# 5. Check pipeline — pipe to Get-Member mid-pipeline to see what's there

# Example: Checking types to debug unexpected behavior
# ⚠️ Read-Host pauses execution! Use F8 (Run Selection) to try these lines.
$number = Read-Host "Enter a number"  # This returns a STRING!
$number + 1                           # String concatenation, not math!
[int]$number + 1                      # Cast to int first!

# Typed parameters are the best
function Add-One {
    param([int]$Number)
    $Number + 1
}

Add-One -Number "42"   # PowerShell converts "42" to int automatically


# --- Strict Mode ---

# Catch common mistakes by enabling strict mode
Set-StrictMode -Version Latest

# Now these will ERROR instead of silently returning $null:
$undeclaredVariable               # Error: variable not defined
$obj = [PSCustomObject]@{A=1}
$obj.NonexistentProperty          # Error: property not found

Set-StrictMode -Off


# --- Lab Challenges ---
#
# 1. Add Write-Verbose messages to any function you wrote earlier.
#    Run it with -Verbose to see the narration.
#
# 2. In VS Code, set a breakpoint inside a foreach loop.
#    Press F5 and step through iterations. Watch variables change.
#
# 3. Enable Set-StrictMode -Version Latest, then try accessing a
#    property that doesn't exist on an object. What happens?
#
# 4. Use Set-PSBreakpoint -Variable to pause when a specific variable
#    gets written to. Inspect the call stack when it pauses.
