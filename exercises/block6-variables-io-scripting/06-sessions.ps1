# ============================================================================
# Ch 18: Sessions — Remote Control with Less Work
# ============================================================================
# Chapter 13 (Block 5) introduced remoting with -ComputerName or -HostName.
# Every call reconnected, ran your command, and disconnected.
#
# Chapter 18 is about REUSABLE SESSIONS — persistent connections you create
# once and reuse many times, avoiding repeated authentication overhead.
# ============================================================================

# NOTE: Most examples below require remoting to be enabled.
#   Windows:  Run 'Enable-PSRemoting' as Administrator first.
#   SSH:      Configure the PowerShell SSH subsystem (see link below).
#   Reference: https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/ssh-remoting-in-powershell
#
# In this workshop we may not have remote targets, so many examples are
# commented out. Use F8 to run individual lines when you have a target.
# Un-commented examples run locally or require no remote machine.


# --- Recap: The Problem with One-Off Connections ---

# Every time you use -ComputerName (WinRM) or -HostName (SSH), PowerShell:
#   1. Authenticates to the remote machine
#   2. Starts a new runspace (PowerShell process)
#   3. Runs your command
#   4. Tears down the connection
#
# For occasional use that's fine. For scripts that talk to the same machine
# many times in a row, it's wasteful and slow.


# --- New-PSSession: Create a Reusable Session ---

# A session is a persistent, named connection to a remote PowerShell instance.
# You create it once and reuse it as many times as you like.

# WinRM (Windows-to-Windows):
# $session = New-PSSession -ComputerName Server01

# SSH (cross-platform):
# $session = New-PSSession -HostName linuxserver -UserName linuxuser

# Multiple machines at once — all sessions in one variable:
# $webSessions = New-PSSession -ComputerName web01, web02, web03

# Multiple machines via SSH:
# $linuxSessions = New-PSSession -HostName web04, web05 -UserName linuxuser

# Store each in its own variable (order not guaranteed — verify!):
# $s1, $s2 = New-PSSession -ComputerName Server01, Server02
# $s1.ComputerName    # Confirm which is which
# $s2.ComputerName


# --- Get-PSSession: See All Open Sessions ---

# PowerShell maintains a list of all open sessions independently of variables.
Get-PSSession    # Returns nothing if no sessions are open

# After creating sessions you'll see them here even if the variable is gone.
# Useful if you lose a reference to a session object.


# --- Remove-PSSession: Always Clean Up ---

# Close specific sessions stored in a variable:
# $session | Remove-PSSession
# $webSessions | Remove-PSSession

# Close ALL open sessions at once (good for cleanup at end of a script):
Get-PSSession | Remove-PSSession

# ⚠️  Sessions hold resources on BOTH machines.
#     Close them when you no longer need them.


# --- Enter-PSSession with a Session Object ---

# Chapter 13 approach — creates and destroys a connection each time:
#   Enter-PSSession -ComputerName Server01

# Chapter 18 approach — reuse an existing session:
#   $session = New-PSSession -ComputerName Server01
#   Enter-PSSession -Session $session
#   [Server01]: PS C:\> Get-Process | Select-Object -First 5
#   [Server01]: PS C:\> Exit-PSSession    ← session stays OPEN after this!

# Re-entering the same session (connection is already established):
#   Enter-PSSession -Session $session

# You can also retrieve a session by computer name from the master list:
#   Get-PSSession -ComputerName Server01 | Enter-PSSession

# Or by the session's numeric ID:
#   Enter-PSSession -Id 3


# --- Invoke-Command with Session Objects ---

# One-off approach (reconnects each time):
#   Invoke-Command -ComputerName web01, web02 -ScriptBlock { Get-Service W3SVC }

# Reusable session approach:
#   $webSessions = New-PSSession -ComputerName web01, web02, web03
#   Invoke-Command -Session $webSessions -ScriptBlock { Get-Service W3SVC }

# Run the SAME block on all sessions — useful for batch admin tasks:
#   Invoke-Command -Session $webSessions -ScriptBlock {
#       Get-EventLog -LogName Application -Newest 5
#   }

# Target sessions from the master list (no variable required):
#   Invoke-Command -Session (Get-PSSession -ComputerName web01, web02) -ScriptBlock {
#       Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 3
#   }

# Real-world pattern — create once, use many times, clean up at the end:
#
#   $servers = New-PSSession -ComputerName web01, web02, db01
#
#   # Task 1
#   Invoke-Command -Session $servers -ScriptBlock { Get-Service }
#
#   # Task 2
#   Invoke-Command -Session $servers -ScriptBlock { Get-EventLog System -Newest 10 }
#
#   # Task 3 — variable in your local session is NOT available inside the block!
#   $threshold = 80
#   Invoke-Command -Session $servers -ScriptBlock {
#       # Use $using: to inject a local variable into the remote scope
#       Get-PSDrive C | Where-Object { ($_.Used / ($_.Used + $_.Free) * 100) -gt $using:threshold }
#   }
#
#   # Clean up
#   $servers | Remove-PSSession


# --- $using: Scope Modifier (Same Rule as Jobs) ---

# Variables from your session do NOT automatically travel into remote sessions.
# Use $using:variableName to send a local value into a remote script block.

# Quick local demonstration of the same scoping rule using Start-Job instead:
$threshold = 80
$job = Start-Job -ScriptBlock {
    # $threshold is NOT available here — different process/scope
    "threshold is: $threshold"
}
Receive-Job $job -Wait -AutoRemoveJob     # Expected: "threshold is: "

$job = Start-Job -ScriptBlock {
    # $using:threshold reaches into the calling scope
    "threshold is: $using:threshold"
}
Receive-Job $job -Wait -AutoRemoveJob     # Expected: "threshold is: 80"

# The $using: modifier works exactly the same way with Invoke-Command -Session.


# --- Implicit Remoting: Import-PSSession ---

# Implicit remoting lets you run commands FROM a remote machine AS IF they
# were installed locally. No local module installation required.
#
# Classic use case: the ActiveDirectory module only exists on Domain Controllers
# or machines with RSAT. With implicit remoting, you can use it anyway.

# Step 1: Create a session with the machine that has the module
# $dcSession = New-PSSession -ComputerName DomainController01

# Step 2: Load the module on the REMOTE machine
# Invoke-Command -Session $dcSession -ScriptBlock { Import-Module ActiveDirectory }

# Step 3: Import remote commands into YOUR session, with an optional prefix
#         The prefix helps you identify which commands are remote.
# Import-PSSession -Session $dcSession -Module ActiveDirectory -Prefix rem

# Step 4: Use the remote commands as if they were local!
# Get-remADUser -Identity jsmith        # Executes on the DC, results come here
# New-remADUser -Name "Jane" ...        # Same!
# Get-Help Get-remADUser                # Help works too

# The imported commands disappear when you close the session or the shell:
# $dcSession | Remove-PSSession

# ⚠️  Objects returned through implicit remoting are DESERIALIZED.
#     Properties are preserved; most methods are stripped.
#     (Same behavior you saw in Block 5 with Export-Clixml / Import-Clixml.)


# --- Deserialization Reminder (from Block 5) ---

# Demonstrating deserialization locally using the same XML format remoting uses:
$local = Get-Process -Id $PID

# Serialize (what remoting does to transport objects across the wire):
$local | Export-Clixml -Path "$env:TEMP\remote-sim.xml"

# Deserialize (what you get back):
$deserialized = Import-Clixml -Path "$env:TEMP\remote-sim.xml"

# Compare method counts
"Local methods:         $(($local | Get-Member -MemberType Method).Count)"
"Deserialized methods:  $(($deserialized | Get-Member -MemberType Method).Count)"

# Properties still work — only methods are stripped:
"Local Name:        $($local.Name)"
"Deserialized Name: $($deserialized.Name)"

Remove-Item "$env:TEMP\remote-sim.xml" -ErrorAction SilentlyContinue


# --- Lab Challenges ---
#
# (If you have remoting available, try these live. Otherwise, review the syntax.)
#
# 1. Create a persistent session and enter it interactively:
#    $s = New-PSSession -ComputerName localhost
#    Enter-PSSession -Session $s
#    ... explore, then Exit-PSSession
#    Verify the session is still open:
#    Get-PSSession
#
# 2. Reuse the session with Invoke-Command:
#    Invoke-Command -Session $s -ScriptBlock { $env:COMPUTERNAME }
#    Invoke-Command -Session $s -ScriptBlock { Get-Process | Measure-Object }
#    Notice: no reconnection overhead on the second call.
#
# 3. Pass a local variable into the session with $using::
#    $filter = 'p*'
#    Invoke-Command -Session $s -ScriptBlock { Get-Process $using:filter }
#
# 4. Clean up:
#    $s | Remove-PSSession
#    Get-PSSession    # Confirm it's gone
#
# 5. Bonus — Implicit remoting (if you have a module on a remote machine):
#    $rem = New-PSSession -ComputerName SomeServer
#    Invoke-Command -Session $rem -ScriptBlock { Import-Module SomeModule }
#    Import-PSSession -Session $rem -Module SomeModule -Prefix rem
#    # Now use the remote commands with the 'rem' prefix
#    $rem | Remove-PSSession
