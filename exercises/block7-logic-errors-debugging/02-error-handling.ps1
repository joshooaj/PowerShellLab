# ============================================================================
# Ch 24: Error Handling — Try/Catch/Finally
# ============================================================================
# Errors happen. Good scripts anticipate and handle them gracefully.
# ============================================================================


# --- Terminating vs Non-Terminating Errors ---

# Non-terminating: the command reports an error but keeps going
$ErrorActionPreference = 'Continue'       # Default value
Get-ChildItem -Path '/nonexistent/path'   # Error, but script usually continues
"This line still runs"

# Terminating: the command stops execution
throw "This stops everything!"


# --- ErrorAction Parameter ---

# Control how individual commands handle errors:
#   -ErrorAction SilentlyContinue   — suppress the error
#   -ErrorAction Stop               — make it terminating
#   -ErrorAction Continue           — show error, keep going (default)
#   -ErrorAction Ignore             — suppress completely (no $Error)

# Silently skip errors
Get-ChildItem '/no/such/path' -ErrorAction SilentlyContinue
"No error displayed above"

# Force a terminating error (required for try/catch to work!)
Get-ChildItem '/no/such/path' -ErrorAction Stop


# --- $ErrorActionPreference ---

# Set the default error behavior for your session/script
$ErrorActionPreference    # Usually 'Continue'

# You can change it temporarily:
$ErrorActionPreference = 'SilentlyContinue'

# --- Try / Catch / Finally ---

# The core error-handling pattern
try {
    # Code that might fail (use -ErrorAction Stop to treat non-terminating errors like terminating errors)
    $content = Get-Content -Path '/this/file/does/not/exist' -ErrorAction Stop
    "Got content: $content"    # This line won't run if the above fails
} catch {
    # Handle the error
    Write-Warning "Something went wrong: $($_.Exception.Message)"
} finally {
    # Always runs — error or not. Good for cleanup.
    Write-Host "Cleanup complete" -ForegroundColor DarkGray
}


# --- Accessing Error Details ---

try {
    1 / 0    # Division by zero — a terminating error
}
catch {
    # $_ is the error record inside catch
    Write-Warning "Error message: $($_.Exception.Message)"
    Write-Warning "Error type:    $($_.Exception.GetType().Name)"
    Write-Warning "Script line:   $($_.InvocationInfo.ScriptLineNumber)"
}


# --- Catching Specific Error Types ---

try {
    # This generates a specific exception type
    [int]::Parse("not-a-number")
} catch [System.FormatException] {
    Write-Warning "Format error: couldn't parse that as a number"
} catch [System.Exception] {
    Write-Warning "Some other error: $($_.Exception.Message)"
}


# --- The $Error Variable ---

# PowerShell keeps a history of errors in $Error (newest first)
$Error.Count                          # How many errors so far
# $Error[0]                           # Most recent error
# $Error[0].Exception.Message         # Its message
# $Error.Clear()                      # Clear the error history


# --- -ErrorVariable Common Parameter ---

# Every PowerShell command has -ErrorVariable — it stores errors in a
# named variable you choose. Note: no $ prefix when ASSIGNING it!
$splat = @{
    Path          = 'nofilehere.txt', 'orhere.zip'
    ErrorAction   = 'SilentlyContinue'
    ErrorVariable = 'myErrors'
}
Get-ChildItem @splat

$myErrors.Count                       # How many errors this command raised
$myErrors[0].Exception.Message        # The first error's message

# Use the + prefix to APPEND to an existing variable (otherwise it resets):
Get-ChildItem -Path 'Nonexistent1' -ErrorVariable +myErrors -ErrorAction SilentlyContinue
Get-ChildItem -Path 'Nonexistent2' -ErrorVariable +myErrors -ErrorAction SilentlyContinue
$myErrors.Count   # Now has 3 errors total

# This is useful when you expect there may be errors, but the script should
# continue and you'll deal with the errors later.


# --- "Bad Handling" — What NOT to Do ---

# Setting $ErrorActionPreference to 'SilentlyContinue' at the top of a script is
# a common mistake — it suppresses ALL errors, hiding real problems:
#
#   $ErrorActionPreference = 'SilentlyContinue'   # ⚠️ Don't do this globally!
#
# Instead, apply -ErrorAction SilentlyContinue only to the SPECIFIC
# command where you truly don't care about errors:
#
#   Remove-Item $path -ErrorAction SilentlyContinue   # ✅ Targeted suppression


# --- Practical Example: Safe File Processing ---

function Get-SafeFileInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Path
    )

    process {
        Write-Verbose "Processing: $Path"

        try {
            $item = Get-Item -Path $Path -ErrorAction Stop
            [PSCustomObject]@{
                Path     = $item.FullName
                SizeKB   = if ($item.PSIsContainer) { 'Directory' } else { [math]::Round($item.Length / 1KB, 1) }
                Modified = $item.LastWriteTime
                Status   = 'OK'
            }
        } catch {
            [PSCustomObject]@{
                Path     = $Path
                SizeKB   = $null
                Modified = $null
                Status   = "Error: $($_.Exception.Message)"
            }
        }
    }
}

# Mix of valid and invalid paths
@($HOME, '/nonexistent/path', $PROFILE) | Get-SafeFileInfo -Verbose | Format-Table


# --- Practical Example: Retry Logic ---

function Invoke-WithRetry {
    [CmdletBinding()]
    param(
        [scriptblock]$ScriptBlock,
        [int]$MaxRetries = 3,
        [int]$DelayMs = 500
    )

    $attempt = 0
    while ($attempt -lt $MaxRetries) {
        $attempt++
        try {
            Write-Verbose "Attempt $attempt of $MaxRetries"
            $result = & $ScriptBlock
            return $result    # Success — return immediately
        } catch {
            Write-Warning "Attempt $attempt failed: $($_.Exception.Message)"
            if ($attempt -eq $MaxRetries) {
                throw   # Re-throw the last error
            }
            Start-Sleep -Milliseconds $DelayMs
        }
    }
}

# Demo: succeeds after some "failures" (simulated)
$callCount = 0
try {
    Invoke-WithRetry -Verbose -MaxRetries 3 -ScriptBlock {
        $script:callCount++
        if ($script:callCount -lt 3) {
            throw "Simulated failure #$($script:callCount)"
        }
        "Success on attempt $($script:callCount)!"
    }
} catch {
    Write-Warning "All retries exhausted: $($_.Exception.Message)"
}


# --- Lab Challenges ---
#
# 1. Write a try/catch that attempts to read a nonexistent file
#    and displays a friendly error message.
#
# 2. Write a function that takes a [string]$Number parameter,
#    tries to convert it to [int], and returns the result or
#    a warning if conversion fails.
#
# 3. Use -ErrorAction Stop with Get-Process -Name 'nonexistent'
#    inside a try/catch block to handle the missing process gracefully.
#
# 4. Examine $Error after running some commands that produce errors.
#    What properties are available on $Error[0]?
