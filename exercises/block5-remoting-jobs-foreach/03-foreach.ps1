# ============================================================================
# Ch 15: Working with many objects, one at a time
# ============================================================================
# When you need to do something with every item in a collection,
# PowerShell gives you several approaches — each with trade-offs.
# ============================================================================


# --- ForEach-Object (Pipeline) ---

# The pipeline-friendly way to process each item
Get-Process | ForEach-Object {
    $_.Name.ToUpper()
} | Select-Object -First 10

# ForEach-Object alias "%":
Get-Process | Select-Object -First 5 | % { $_.Name.ToUpper() }

# Select and expand property values and even run methods:
Get-Process | Select-Object -First 5 | % Name | % ToUpper

# Access properties — you're inside $_ (the current object)
1..5 | ForEach-Object {
    [PSCustomObject]@{
        Number  = $_
        Doubled = $_ * 2
        # $PSItem is an alternative to $_ and does the same thing
        Squared = $_ * $PSItem
    }
}


# --- foreach Statement (Scripting) ---

# The foreach STATEMENT is different from the ForEach-Object CMDLET.
# It loads the whole collection into memory first — faster for local data.

$processes = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 20
foreach ($proc in $processes) {
    if ($proc.WorkingSet -gt 50MB) {
        # Just showing the name and memory usage
        "$($proc.Name) — $([math]::Round($proc.WorkingSet / 1MB))MB"
    }
}


# --- Key Difference: Pipeline vs Statement ---

# ForEach-Object: streams objects one-at-a-time through the pipeline
# - Lower memory usage for large datasets
# - Supports pipeline input
# - Slightly slower per-item

# foreach statement: loads everything into memory first, then loops
# - Uses more memory
# - Faster for local processing
# - Cannot be used mid-pipeline except inside a scriptblock


# --- Batch Cmdlets vs ForEach-Object ---

# PREFER batch cmdlets when available — they're usually more efficient.

# Good — one call handles everything:
Get-Process | Where-Object WorkingSet -gt 50MB | Stop-Process -WhatIf

# Unnecessary — wrapping in ForEach-Object when you don't need to:
# Get-Process | Where-Object WorkingSet -gt 50MB | ForEach-Object {
#     Stop-Process -Id $_.Id -WhatIf
# }

# Use ForEach-Object when you need to do something a cmdlet can't do natively.
# or when the next command does not accept pipeline input from the previous


# --- -PassThru: See What Batch Cmdlets Did ---

# Action cmdlets (Set-*, Copy-*, Move-*, etc.) usually produce NO output.
# -PassThru tells them to output the objects they acted on, so you can
# confirm the change, pipe to another command, or log the results.

# Without -PassThru — completely silent:
Copy-Item -Path $PROFILE -Destination "$HOME\profile.bak" -ErrorAction SilentlyContinue

# With -PassThru — see what happened:
Copy-Item -Path $PROFILE -Destination "$HOME\profile.bak2" -PassThru -ErrorAction SilentlyContinue

# Clean up:
Remove-Item "$HOME\profile.bak", "$HOME\profile.bak2" -ErrorAction SilentlyContinue

# Other cmdlets that support -PassThru:
# Get-Service Spooler | Set-Service -StartupType Manual -PassThru
# Get-ChildItem .\ | Copy-Item -Destination ~\Archive -PassThru


# --- ForEach-Object -Parallel (PowerShell 7+) ---

# Run iterations in parallel — great for independent, slow operations
# NOTE: Uses separate runspaces, so variables aren't shared by default!

1..10 | ForEach-Object -Parallel {
    Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 500)
    [pscustomobject]@{
        Id        = $_
        ProcessId = $PID
        ThreadId  = [System.Threading.Thread]::CurrentThread.ManagedThreadId
    }
} -ThrottleLimit 5

# Compare speed: Sequential vs Parallel

# Sequential
$sequential = Measure-Command {
    1..10 | ForEach-Object {
        Start-Sleep -Milliseconds 200
    }
}

# Parallel
$parallel = Measure-Command {
    1..10 | ForEach-Object -Parallel {
        Start-Sleep -Milliseconds 200
    } -ThrottleLimit 5
}

[pscustomobject]@{
    Sequential      = $sequential.TotalSeconds
    ParallelSeconds = $parallel.TotalSeconds
}

# --- Using $using: in -Parallel ---

# Variables from the outer scope need $using:
# Note: Run multiple times and the order in which they finish will be different
$greeting = "Hello"
1..3 | ForEach-Object -Parallel {
    $delay = Get-Random -Minimum 50 -Maximum 500
    Start-Sleep -Milliseconds $delay
    "$($using:greeting) from item $_"
}


# --- ForEach-Object with -Begin, -Process, -End ---

# Advanced: setup, per-item, and teardown blocks
1..5 | ForEach-Object -Begin {
    $sum = 0
    Write-Host "Starting the count..."
} -Process {
    $sum += $_
    Write-Host "  Added $_ — running total: $sum"
} -End {
    Write-Host "Final total: $sum"
}


# --- Method Syntax Shortcut (v4+) ---

# Call a method on every object using the .ForEach() method
$names = (Get-Process | Select-Object -First 5).ForEach({ $_.Name })
$names

# Or use the member enumeration shortcut
$names2 = (Get-Process | Select-Object -First 5).Name
$names2


# --- Discovering Methods with Get-Member ---

# Before calling a method, discover what's available.
# -MemberType Method filters down to just the callable actions on each object.

Get-Process | Get-Member -MemberType Method

# Key process methods you'll see:
#   Kill()         — terminate the process (also see: Stop-Process)
#   WaitForExit()  — block until the process ends
#   Refresh()      — update live properties (CPU, memory, etc.)

Get-ChildItem | Get-Member -MemberType Method

# Key file/directory methods:
#   Delete()       — delete the file or empty directory
#   MoveTo('path') — move the file to a new location

# For full documentation, search the TypeName shown by Get-Member.
# e.g., search "System.Diagnostics.Process" to find .NET docs for process methods.


# --- Calling Methods via ForEach-Object ---

# The book (Ch 15) shows three equivalent ways to take action on objects.
# Use batch cmdlets when available; fall back to method calls when they don't exist.

# Approach 1 — Batch cmdlet (PREFERRED when one exists):
# Get-Process -Name notepad | Stop-Process

# Approach 2 — ForEach-Object calling the method directly:
# Get-Process -Name notepad | ForEach-Object { $_.Kill() }

# Approach 3 - ForEach-Object can invoke a method by name:
# Get-Process -Name notepad | ForEach-Object Kill

# Approach 4 — ForEach-Object calling a cmdlet:
# Get-Process -Name notepad | ForEach-Object { Stop-Process -Id $_.Id }

# All four do the same thing. Method calling matters for CIM objects and
# any case where no cmdlet exists for the action you need.

# Safe demo — calling .ToUpper() on strings via ForEach-Object:
$serverNames = @('server01', 'server02', 'workstation01')
$serverNames | % ToUpper

# Same thing using the .ForEach() method shortcut:
$serverNames.ForEach({ $_.ToUpper() })

# Or member enumeration (works for parameterless methods in PS 5+):
$serverNames.ToUpper()


# --- Invoke-CimMethod (Windows Only) ---

# CIM classes (the modern WMI replacement) often expose methods that have
# NO corresponding PowerShell cmdlet. Invoke-CimMethod fills that gap.
#
# Key advantage over calling a method directly on the object:
#   Invoke-CimMethod supports -WhatIf and -Confirm!
#   Calling $obj.SomeMethod() does NOT.

# NOTE: CIM cmdlets are Windows-only. This block is skipped on macOS/Linux.

if ($IsWindows) {
    # Discover what methods a CIM class exposes:
    (Get-CimClass -ClassName Win32_Process).CimClassMethods | Select-Object Name

    # Get some CIM process objects (same concept as Get-Process but through CIM):
    Get-CimInstance -ClassName Win32_Process | Select-Object -First 5 Name, ProcessId

    # To terminate a process via Invoke-CimMethod (safe: commented out):
    # Get-CimInstance -ClassName Win32_Process -Filter "Name='notepad.exe'" |
    #     Invoke-CimMethod -MethodName Terminate

    # -WhatIf works — unlike calling the method directly on the object:
    # Get-CimInstance -ClassName Win32_Process -Filter "Name='notepad.exe'" |
    #     Invoke-CimMethod -MethodName Terminate -WhatIf

    # IMPORTANT: You cannot pipe objects to a method. Methods are not cmdlets!
    # Get-CimInstance Win32_Process | Terminate   # ERROR — 'Terminate' is not a cmdlet
}


# --- Lab Challenges ---
#
# 1. Use ForEach-Object to create a formatted string for each process:
#    Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 |
#        ForEach-Object { "$($_.Name) — $([math]::Round($_.WorkingSet / 1MB))MB" }
#
# 2. Use the foreach statement to loop through numbers 1-10 and
#    output only the even numbers. Hint: use the modulo operator (%)
#    foreach ($n in 1..10) { if ($n % 2 -eq 0) { $n } }
#
# 3. Compare sequential vs parallel performance:
#    Time how long it takes to test 5 different paths with Test-Path
#    using ForEach-Object vs ForEach-Object -Parallel.
#    Is "ForEach-Object -Parallel" faster for this purpose? Why or why not?
