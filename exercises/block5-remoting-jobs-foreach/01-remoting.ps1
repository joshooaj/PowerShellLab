# ============================================================================
# Block 5: Remoting, Jobs & ForEach (Chapters 13-15)
# ============================================================================
# Ch 13 - Remote Control
#
# PowerShell remoting lets you run commands on other machines.
# In this workshop we likely don't have remote targets, so we'll focus on
# understanding the CONCEPTS, demonstrating what we can locally, and
# simulating the rest.
# ============================================================================


# --- How Remoting Works (Conceptual) ---

# PowerShell remoting uses two transports:
#   WinRM  — Windows-native (default on Windows, needs elevation to enable)
#   SSH    — Cross-platform (PowerShell 7+, recommended for mixed environments)

# Two main commands:
#   Enter-PSSession   — interactive, one-at-a-time (like SSH)
#   Invoke-Command    — run a script block on one or MANY machines at once

# To enable remoting (not needed today, just for reference):
#   Windows:    Enable-PSRemoting (elevated)
#   macOS/Linux: configure SSH subsystem for PowerShell
#   See: https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/ssh-remoting-in-powershell?view=powershell-7.5


# --- Start-Job Locally (safe to run everywhere!) ---

# Start-Job can run script blocks locally, in a new process, without remoting.
# This lets us learn the syntax and behavior without a remote machine. We'll
# substitute it for Invoke-Command for demo purposes.

# Run a script block in a NEW local scope (no remoting required!)
Start-Job -ScriptBlock { $PSVersionTable } | Receive-Job -Wait -AutoRemoveJob

# Script blocks run in a SEPARATE scope.
# Variables from your current session are NOT available inside:
$greeting = 'Hello Summit!'
Start-Job -ScriptBlock { $greeting } | Receive-Job -Wait -AutoRemoveJob

# ^^^ Returns nothing! $greeting doesn't exist in the "remote" process


# To pass data in, use the $using: scope modifier
Start-Job -ScriptBlock { $using:greeting } | Receive-Job -Wait -AutoRemoveJob

# ^^^ Returns "Hello Summit!"

# The $using: trick works the same way with remote machines.
# This is one of the most common gotchas with Invoke-Command.


# --- What Remoting Commands Look Like (for reference) ---

# These examples show the SYNTAX you'd use with a real remote machine.
# Don't run these unless you have remoting configured!

# One-to-one interactive session (like SSH):
# Enter-PSSession -ComputerName Server01
# Get-Process | Select-Object -First 5
# Exit-PSSession

# One-to-many — run on multiple machines simultaneously:
# Invoke-Command -ComputerName Server01, Server02, Server03 -ScriptBlock {
#     Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5
# }

# SSH-based remoting (cross-platform):
# Enter-PSSession -HostName user@linuxserver -SSHTransport
# Invoke-Command -HostName user@linuxserver -ScriptBlock { uname -a }


# --- Deserialized Objects ---

# Objects returned from remoting lose their methods.
# They become "deserialized" — you get property data but can't call methods.
# We can demonstrate this with Export/Import-Clixml (same serialization concept)

# Local process object — has methods
$local = Get-Process -Id $PID
$methodCount = ($local | Get-Member -MemberType Method).Count
"Local object has $methodCount methods"
$local | Get-Member -MemberType Method | Select-Object -First 5 Name

# Simulate a "remote" object by serializing and deserializing
$local | Export-Clixml -Path ~/remote-demo.xml
$deserialized = Import-Clixml -Path ~/remote-demo.xml
$deserializedMethodCount = ($deserialized | Get-Member -MemberType Method).Count
"Deserialized object has $deserializedMethodCount methods"
$deserialized | Get-Member -MemberType Method | Select-Object -First 5 Name

# Notice: the deserialized object has far fewer methods!
# This is EXACTLY what happens when objects travel over remoting.
# Properties survive. Methods (mostly) don't.

# The properties still work fine:
$deserialized.ProcessName
$deserialized.Id

# Clean up
Remove-Item ~/remote-demo.xml -ErrorAction SilentlyContinue


# --- Filter Left: Remote vs Local Processing ---

# When using remoting, put your filtering INSIDE the script block.
# This reduces the data that travels over the network.

# GOOD: Filtering happens on the remote machine — less data transmitted
# Invoke-Command -ComputerName Server01 -ScriptBlock {
#     Get-Process | Where-Object { $_.WorkingSet -gt 100MB } |
#         Select-Object Name, Id
# }

# BAD: ALL properties for all processes transmitted, THEN filtered locally
# Invoke-Command -ComputerName Server01 -ScriptBlock {
#     Get-Process
# } | Where-Object { $_.WorkingSet -gt 100MB } | Select-Object Name, Id

# Same result, but the GOOD version sends much less data over the network.
# This "filter left" principle applies to everything in PowerShell,
# but it's CRITICAL for remoting where network bandwidth matters.

# We can see the difference locally:
$allProcesses = Invoke-Command -ScriptBlock { Get-Process }
$filteredRemote = Invoke-Command -ScriptBlock {
    Get-Process | Where-Object { $_.WorkingSet -gt 100MB } | Select-Object Name, Id
}

"All processes returned: $($allProcesses.Count) objects"
"Filtered remotely: $($filteredRemote.Count) objects"
"That's $($allProcesses.Count - $filteredRemote.Count) fewer objects to transmit!"


# --- PSComputerName: Tracking Results from Multiple Machines ---

# When Invoke-Command runs against multiple computers, each returned object
# automatically gets a ComputerName property added — telling you exactly
# which machine produced it. This is how you sort or group remote results.

# Demo locally (Invoke-Command without -ComputerName adds 'localhost'):
$results = Invoke-Command -ScriptBlock {
    [PSCustomObject]@{
        PSVersion    = $PSVersionTable.PSVersion.ToString()
        ComputerName = $env:COMPUTERNAME
    }
}
$results
$results.ComputerName      # Returns your machine name

# With real remoting (multiple machines), you'd filter or group by PSComputerName:
# $results | Sort-Object PSComputerName | Format-Table -GroupBy PSComputerName


# --- Loading Computer Names from a File ---

# You'll rarely type a comma-separated list of server names inline.
# The common pattern is storing them in a text file (one name per line)
# and feeding that list to Invoke-Command with Get-Content.

# Create a sample file to demo the concept:
$tempFile = [System.IO.Path]::GetTempFileName()
'server01', 'server02' | Set-Content -Path $tempFile

# Use it just like a hard-coded list:
# Invoke-Command -ComputerName (Get-Content $tempFile) -ScriptBlock { $env:COMPUTERNAME }
"Computer list from file:`n$(Get-Content $tempFile -Raw)"

Remove-Item $tempFile -ErrorAction SilentlyContinue


# --- Lab Challenge ---
#
# 1. Use Start-Job with a script block to get $PSVersionTable
#    $job = Start-Job -ScriptBlock { $PSVersionTable }
#    $job | Receive-Job -Wait -AutoRemoveJob
#
# 2. Prove that variables don't cross the boundary:
#    $secret = "hidden"
#    Start-Job { $secret } | Receive-Job -Wait -AutoRemoveJob   # nothing!
#    Invoke-Command -ScriptBlock { $using:secret }              # "hidden"
#
# 3. Serialize a Get-Date object to XML, import it back, and compare
#    Get-Member on the original vs deserialized version.
#    What methods are missing?
#
# 4. When would you use Enter-PSSession vs Invoke-Command?
