---
marp: true
theme: summit-2026
paginate: false
---

<!-- _class: title -->
# <span class="gradient-text">PowerShell Hands-on Lab</span><br/>

## Let's GO!!

<p class="name">Josh Hendricks</p>
<p class="handle">@joshooaj.com</p>
<!--
SPEAKER NOTES:
- Welcome everyone, introduce yourself
- Set expectations: it's a firehose, and that's OK
-->

---

<!-- _class: sponsors -->
<!-- _paginate: skip -->

# Thanks!

<!--
Gotta thank the sponsors!
-->

---

<!-- _class: centered -->
# About Me

<div class="columns">
<div>

- <span class="primary">Josh Hendricks</span> (@joshooaj.com)
- Principal engineer @
  Milestone Systems
- PowerShell enthusiast &
  self-hosting nerd
- First-year Microsoft MVP 🎉
- First-time speaking to Onramp!

</div>
<div>

![selfie](./assets/selfie.png)

</div>
</div>

<!--
SPEAKER NOTES:
- Photo is from a short family hike on the Clarno Arch Trail in Central Oregon.
-->
---

# What We're Doing Today

### Speed-running <span class="primary">**Learn PowerShell in a Month of Lunches**</span>

- ⚡ ~8 min per topic: intro, demo, move on
- 🎯 Mental map, not mastery
- 📖 The book is your companion for going deeper

<div class="callout secondary">

### 💬 Questions welcome anytime, raise your hand, shout it out, drop it in chat

</div>

<!--
SPEAKER NOTES:
- Reassure people, this is a LOT of content in a short time
- We're building a mental map, not deep expertise
- The book is the companion material for going deeper
- Emphasize that questions are welcome throughout
-->

---

# How This Workshop Works

<div class="primary-list">

### For Each Topic We'll...

1. **Set the stage:** Why does this matter?
2. **Demo it live:** VS Code, follow along
3. **Highlight pitfalls:** Common gotchas
4. **Move on:** Keep the momentum

</div>

<!--
SPEAKER NOTES:
- Explain the rhythm: slides → VS Code → slides → VS Code
- Encourage people to follow along in their own terminal
- Mention that the GitHub repo has all demo scripts
- Reassure: if a topic doesn't click right away, that's totally fine, note it and revisit after the summit
-->

---

# Our Agenda

| Block | Topics | Chapters |
|-------|--------|----------|
| <span class="primary">**1**</span> | The Shell & Running Commands | 1–4 |
| <span class="primary">**2**</span> | Providers & the Pipeline | 5–6 |
| <span class="primary">**3**</span> | Modules & Objects | 7–9 |
| <span class="secondary">**4**</span> | Pipeline Deep Dive, Formatting & Filtering | 10–12 |
| <span class="secondary">**5**</span> | Remoting, Jobs & ForEach | 13–15 |
| <span class="tertiary">**6**</span> | Variables, I/O & Scripting | 16–22 |
| <span class="quaternary">**7**</span> | Logic, Errors, Debugging & Tips | 23–27 |



<!--
SPEAKER NOTES:
- Walk through each block briefly so people know what's coming
- Mention that blocks get progressively more advanced
- We'll take 5–10 minute breaks between major blocks
-->

---

# Before We Begin

### Make sure you have...

<div class="checklist">

- **PowerShell 7+** installed (`$PSVersionTable`)
- **VS Code** with the PowerShell extension
- A terminal open and ready to go
- The GitHub repo cloned: `devops-collective-inc/OnRamp-2026`

</div>

<!--
SPEAKER NOTES:
- TODO: Update GitHub repo URL
- Quick environment check, ask the room if everyone is set up
- If not, they can follow along on screen and troubleshoot during break
- Point people to the GitHub repo for all materials
-->

---

<!-- _class: big-statement -->
# Block 1

## The Shell & Running Commands

<span class="primary-bg">Chapters 1–4</span>

<span class="accent">~30 minutes</span>

<!--
SPEAKER NOTES:
- Section break, take a breath
- This block covers the absolute fundamentals
- By the end, everyone should be able to find and run commands
-->

---

# Ch 1. Before You Begin

## Why PowerShell?

- <span class="primary">**Cross-platform:**</span> Windows, macOS, Linux
- <span class="secondary">**Object-based:**</span> not just text, real .NET objects
- <span class="tertiary">**Discoverable:**</span> built-in help for everything
- <span class="quaternary">**Extensible:**</span> thousands of community modules

<!--
SPEAKER NOTES:
- "Life without PowerShell" vs "Life with PowerShell", paint the picture
- Emphasize that PowerShell runs everywhere now, not just Windows
- This is the "why should I care" slide
- PowerShell isn't just for sysadmins anymore. Developers, cloud engineers,
  security analysts all benefit
-->

---

# Ch 2. Meet PowerShell

### Your New Best Friend

```powershell
$PSVersionTable      # What version am I running?

Get-Location         # Where am I?

Get-Command          # What can I do?
```

<div class="callout primary">

### 💡 We'll spend most of our time here today

</div>

<!--
SPEAKER NOTES:
- DEMO: Open VS Code, show the terminal, run $PSVersionTable
- Point out the PowerShell extension features: IntelliSense, integrated terminal
- Show that the terminal is a full PowerShell session
- This is where we'll spend most of our time. Make sure everyone has it open
- Transition: "Now let's learn how to find help when we're stuck"
-->

---

# Ch 3. The Help System

### The Most Valuable Skill in PowerShell

```powershell
Update-Help -ErrorAction SilentlyContinue      # Update your help files first

Get-Help Get-Process                           # Get help on any command
Get-Help Get-Process -Examples
Get-Help Get-Process -Online
```

- `Get-Help` is your <span class="primary">**first stop**</span> for learning any command
- `-Examples` shows usage, `-Online` opens help in your browser

<!--
SPEAKER NOTES:
- DEMO: Run Update-Help, then Get-Help Get-Process -Full
- Show parameter sets, mandatory vs optional parameters
- Show -Examples for practical usage
- Emphasize: "If you learn ONE thing today, learn to use Get-Help"
- Mention Get-Help about_* topics
-->

---

# Ch 3. Understanding the Syntax

```
Get-Process [[-Name] <string[]>] [-ComputerName <string[]>]
```

| Syntax            | Meaning                                      |
| ----------------- | -------------------------------------------- |
| `[[-Name]`        | Optional, and positional. You don't have to type `-Name` |
| `<string[]>`      | Parameter type. Accepts one or more strings  |
| `[-ComputerName]` | Optional, named. Not positional, must use the parameter name |
| No brackets       | **Mandatory**                                |

<!--
SPEAKER NOTES:
- Walk through the syntax notation slowly
- Square brackets = optional, angle brackets = value type
- This is where most beginners get confused — normalize that. It looks intimidating at first; after a few commands it's second nature.
-->

---

# Ch 4. Running Commands

### Anatomy of a PowerShell Command

```powershell
# ↓ Verb          ↓ Value   
Get-Process -Name "pwsh" -ErrorAction Stop
#   ↑ Noun   ↑ Parameter  ↑ Common Parameter
```

- <span class="primary">**Verb-Noun**</span> naming convention — `Get-`, `Set-`, `New-`, `Remove-`
- **Parameters** modify behavior — use `Get-Help` to discover them
- **Common parameters** like `-Verbose`, `-ErrorAction` work everywhere

<!--
SPEAKER NOTES:
- DEMO: Run Get-Process, then with -Name, then with -ErrorAction
- Show tab completion for parameter names
- Show truncated parameter names (e.g. -N for -Name)
- Mention aliases exist but should not be used in scripts
-->

---

# Ch 4. Aliases & Shortcuts

```powershell
Get-ChildItem                           # These all do the same thing
dir
ls
gci

Get-Alias ls                            # Find what an alias maps to
Get-Alias -Definition Get-ChildItem     # Find all aliases for a command
```

<div class="callout tertiary">

### 📏 Rule of Thumb

**Use aliases interactively**, not in scripts.

</div>

<!--
SPEAKER NOTES:
- DEMO: Show Get-Alias, explain why ls works in PowerShell
- Emphasize: scripts = full names, terminal = aliases are fine
- Transition: "We've been using the filesystem. Let's dive deeper."
-->

---

<!-- _class: big-statement -->
# Block 2

## Providers & the Pipeline

<span class="primary-bg">Chapters 5–6</span>

<span class="accent">~15 minutes</span>

<!--
SPEAKER NOTES:
- Short section — two foundational concepts
- Providers = how PowerShell sees storage
- Pipeline = how commands talk to each other
-->

---

# Ch 5. Working with Providers

PowerShell providers give you a <span class="primary">**filesystem-like interface**</span> to many data stores:

```powershell
# See all available providers
Get-PSDrive

# Navigate the registry like a filesystem!
Set-Location HKCU:\Software
Get-ChildItem

# Environment variables too
Get-ChildItem Env:
```

<!--
SPEAKER NOTES:
- DEMO: Run Get-PSDrive, navigate to HKCU:\, browse with Get-ChildItem
- Show Env: drive — Get-ChildItem Env:
- Key insight: same commands (Get-ChildItem, Set-Location) work everywhere
- If on Linux/macOS, note that Registry is Windows-only
-->

---

# Ch 6. The Pipeline

```powershell
# Get processes, filter, sort, and display
Get-Process |
    Where-Object CPU -gt 10 |
    Sort-Object CPU -Descending |
    Select-Object -First 5 Name, CPU
```

- Each `|` connects output **objects** to the next command
- This is not text processing — it's <span class="quaternary">**object processing**</span>
- Easier than text-based pipelines in other shells

<!--
SPEAKER NOTES:
- DEMO: Build this pipeline step by step, adding one pipe at a time
- Show what happens at each stage
- Emphasize the object nature — properties, not text columns
- Mention Export-Csv, Out-File, ConvertTo-Html as pipeline endpoints
-->

---

# Ch 6. Pipeline Exports

## Sending Data Somewhere Useful

```powershell
Get-Process | Export-Csv -Path processes.csv -NoTypeInformation

Get-Service | ConvertTo-Json | Out-File services.json

Get-Process | ConvertTo-Html | Out-File processes.html
```

<!--
SPEAKER NOTES:
- DEMO: Export processes to CSV, open the file
- Show ConvertTo-Json output
- Transition: "We've been using built-in commands. What about adding more?"
-->

---

<!-- _class: big-statement -->
# Block 3

## Modules & Objects

<span class="primary-bg">Chapters 7–9</span>

<span class="accent">~20 minutes</span>

<!--
SPEAKER NOTES:
- This block covers how PowerShell becomes extensible
- Modules = packages of commands
- Objects = the heart of PowerShell's power
-->

---

# Ch 7. Installing Modules

```powershell
Find-Module -Name "*Azure*" | Select-Object -First 5 Name, Description

Install-Module -Name Microsoft.PowerShell.SecretManagement -Scope CurrentUser

Get-Command -Module Microsoft.PowerShell.SecretManagement
```

<div class="callout primary">

### 💡 PowerShell Gallery

[powershellgallery.com](https://powershellgallery.com) hosts thousands of community modules. It's like npm or pip for PowerShell.

</div>

<!--
SPEAKER NOTES:
- DEMO: Find-Module, Find-Command, Install-Module, Get-Command -Module
- Mention -Scope CurrentUser to avoid admin requirements on Windows PowerShell
- Show a fun module if time allows
- Key point: you don't have to write everything yourself
-->

---

# Ch 8. Objects

Everything in PowerShell is an <span class="primary">**object**</span> with **properties** and **methods**:

```powershell
Get-Process | Get-Member           # What kind of object is this?
(Get-Process -Name pwsh).Path      # Access a property
(Get-Date).AddDays(30)             # Call a method
```

- <span class="primary">**Properties**</span> = data about the object (Name, Path, CPU)
- <span class="quaternary">**Methods**</span> = actions the object can perform (Kill, AddDays)
- `Get-Member` is how you <span class="secondary">**discover**</span> what's available

<!--
SPEAKER NOTES:
- DEMO: Get-Process | Get-Member — walk through the output
- Show properties vs methods
- Access a property with dot notation
- This is THE concept that separates PowerShell from other shells
-->

---

# Ch 8. Exploring Objects

### Select, Sort, Measure

```powershell
Get-Process | Select-Object Name, CPU, WorkingSet                # Pick specific properties

Get-Service | Sort-Object Status, Name                           # Sort by a property

Get-Process | Measure-Object -Property WorkingSet -Sum -Average  # Count and measure
```

PowerShell cmdlets return rich objects, not text.

That's why `Sort-Object` and `Select-Object` work so well.

<!--
SPEAKER NOTES:
- DEMO: Build up from Get-Process to Select, Sort, Measure
- Show that Select-Object limits which properties pass through
- Transition: "Let's put this into practice with a quick challenge"
-->

---

# Ch 9. A Practical Interlude

### The Problem-Solving Pattern

When you face a new task in PowerShell, follow this pattern:

<div class="quaternary-list">

1. **What am I trying to do?** Define the goal in plain English
2. **What commands might help?** `Get-Command *keyword*`
3. **How do I use that command?** `Get-Help Command-Name -Examples`
4. **Try it:** experiment in the terminal
5. **Refine it:** pipe to `Where-Object`, `Sort-Object`, `Select-Object`

</div>

<!--
SPEAKER NOTES:
- DEMO: Walk through a real example:
  "Find all services that are stopped and could be started"
  1. Get-Command *service*
  2. Get-Help Get-Service -Examples
  3. Get-Service | Where-Object Status -eq Stopped
- Even experienced PowerShell users follow these same steps — you never
  memorize everything, you learn how to discover
- Transition: "Time for a break! Stretch, grab coffee, try some commands."
-->

---

<!-- _class: title -->
# ☕ <span class="gradient-text">Break Time</span>

## Stretch, grab coffee, ask questions!

<p class="name">Back in 10 minutes</p>
<p class="handle">Try some commands on your own!</p>

---

<!-- _class: big-statement -->
# Block 4

## More Pipelines, Formatting & Filtering

<span class="primary-bg">Chapters 10–12</span>

<span class="accent">~20 minutes</span>

<!--
SPEAKER NOTES:
- Now we go deeper on things we've already touched
- Pipeline binding, formatting, and filtering
- These are the skills that make you productive day-to-day
-->

---

# Ch 10. The Pipeline 2: Binding

PowerShell binds pipeline input using two strategies:

<div class="primary-list">

- <span class="primary">**ByValue:**</span> matches the entire object by type
- <span class="secondary">**ByPropertyName:**</span> matches properties to parameter names

</div>

```powershell
# Get-Service outputs ServiceController objects,
# Stop-Service accepts ServiceController object ByValue
Get-Service -Name BITS | Stop-Service -WhatIf

# ByPropertyName: CSV columns match parameter names
Import-Csv servers.csv | Test-Connection
```

<!--
SPEAKER NOTES:
- TODO: Write Trace-Command example
- DEMO: Show Trace-Command to visualize ByValue vs ByPropertyName
- Show what happens when things DON'T match
- Use Select-Object with calculated properties to reshape: @{n='ComputerName'; e={$_.ServerName}}
- This is dense — it's OK to just understand the concept
-->

---

# Ch 11. Formatting is for Humans

```powershell
Get-Process | Format-Table Name, CPU, WorkingSet -AutoSize

Get-Process | Format-List *

Get-Process | Format-Wide -Column 4
```

<div class="callout tertiary">

### 📏 Rule of Thumb

`Format-*` commands should be the **last thing** in your pipeline. Once you format, you can't pipe to anything else useful.

</div>

<!--
SPEAKER NOTES:
- DEMO: Show Format-Table vs Format-List vs Format-Wide
- Show what happens when you pipe Format-Table to Export-Csv (broken!)
- Key rule: Format-* goes at the END, always
-->

---

# Ch 12. Filtering & Comparisons

```powershell
Get-Process -Name "pwsh"                         # Filter at the source when you can
Get-Service | Where-Object Status -eq 'Running'  # Use Where-Object when you can't

5 -gt 3                                          # Greater than → True
"hello" -like "*ell*"                            # Wildcard match → True
"PowerShell" -match "power"                      # Regex match → True
```

<div class="callout primary">

### 💡 Filter Left, Format Right

Filter as early as possible in the pipeline, format at the end if needed

</div>

<!--
SPEAKER NOTES:
- DEMO: Show filtering with both source parameter and Where-Object
- Show common comparison operators: -eq, -ne, -gt, -lt, -like, -match
- Emphasize "filter left" — performance matters
- Transition: "Next up — remoting! Doing things on other machines."
-->

---

<!-- _class: big-statement -->
# Block 5

## Remoting, Jobs & ForEach

<span class="primary-bg">Chapters 13–15</span>

<span class="accent">~20 minutes</span>

<!--
SPEAKER NOTES:
- This is where PowerShell starts to feel like a superpower
- Run commands on remote machines
- Run things in the background
- Process many objects at once
-->

---

# Ch 13. Remote Control

### One-to-One and One-to-Many

```powershell
Enter-PSSession -ComputerName Server01  # Interactive

Invoke-Command -ComputerName Server01, Server02, Server03 -ScriptBlock {
    Get-Service -Name W32Time # Run on multiple machines at once!
}
```

- <span class="primary">**Enter-PSSession**</span> — interactive, one-at-a-time
- <span class="quaternary">**Invoke-Command**</span> — run on many machines simultaneously
- Works over **WinRM** (Windows) or **SSH** (cross-platform)

<!--
SPEAKER NOTES:
- DEMO: If possible, show Enter-PSSession to localhost
- Show Invoke-Command with -ComputerName
- Explain that remoting needs to be enabled and configured
- Mention SSH-based remoting for cross-platform scenarios
-->

---

# Ch 14. Background Jobs

### Multitasking in PowerShell

```powershell
$job = Start-Job -ScriptBlock {
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
}
Get-Job                 # Check on it
$job | Receive-Job      # Get the results
```

- `Start-Job` → run in a separate process
- `Start-ThreadJob` → thread-based (faster, lighter)
- `Invoke-Command -AsJob` → remote commands in background jobs

<!--
SPEAKER NOTES:
- DEMO: Start a job, check status, receive results
- Mention Start-ThreadJob as the modern, faster alternative
- Jobs are great for long-running tasks you don't want to wait for
-->

---

# Ch 15. Working with Many Objects

```powershell
# Stream services one at a time, memory-friendly
Get-Service | ForEach-Object  { "$($_.Name) is $($_.Status)" }

# Load all services at once, then processes them one at a time
foreach ($svc in Get-Service) { "$($svc.Name) is $($svc.Status)" }
```

<div class="callout primary">

### 💡 Which One?

Use `ForEach-Object` in pipelines. Use `foreach` in scripts when you don't need streaming.

</div>

<!--
SPEAKER NOTES:
- DEMO: Show both styles side by side
- Mention ForEach-Object -Parallel for PowerShell 7+
- Key: if a cmdlet accepts arrays natively, use that instead of looping
- Transition: "Break time! Then we start scripting."
-->

---

<!-- _class: title -->
# ☕ <span class="gradient-text">Break Time</span>

## Halfway there! Take a breather.

<p class="name">Back in 10 minutes</p>
<p class="handle">You're doing great! 🚀</p>

---

<!-- _class: big-statement -->
# Block 6

## Variables, I/O & Scripting

<span class="primary-bg">Chapters 16–22</span>

<span class="accent">~40 minutes</span>
<!--
SPEAKER NOTES:
- Biggest block — covers a lot of ground
- We transition from "running commands" to "writing scripts"
- Variables, input/output, reusable code, regex
-->

---

# Ch 16. Variables

### A Place to Store Your Stuff

```powershell
$name = "PowerShell Summit"           # Simple assignment
$count = 42

$processes = Get-Process              # Store command output

[int]$port = 443                      # Typed variables
[string]$greeting = "Hello, Summit!"
```

- PowerShell is <span class="primary">**dynamically typed**</span> — but you *can* enforce types
- Store anything: strings, numbers, objects, arrays, hashtables

<!--
SPEAKER NOTES:
- DEMO: Create variables, show types with .GetType()
- Reference variables with $
- Show storing command output in a variable
- Show array access: $processes[0], $processes.Count
- Keep it simple — don't go deep on types
-->

---

# Ch 16. Strings & Arrays

## Quotes, Expansion, and Collections

```powershell
$who = "World"
"Hello, $who!"    # → Hello, World! (double-quotes allow variable expansion)
'Hello, $who!'    # → Hello, $who!  (no variable expansion in single quotes)

$fruits = @("apple", "banana", "cherry")  # Array of fruit
$fruits[0]                                # → apple
$fruits.Count                             # → 3

$person = @{ Name = "Josh" }
$person.Name      # → Josh (Name is a hashtable key, Josh is the value)
```

<!--
SPEAKER NOTES:
- DEMO: Show string expansion, single vs double quotes
- Show array creation and indexing
- Show hashtable creation and access
- These are the building blocks for scripts
-->

---

# Ch 17. Input and Output

### Read-Host and the 7 Output Streams

```powershell
Read-Host "Type anything"          # Gather input as a string (or SecureString)

Write-Output      "This is data"      # Stream 1 - Success stream, goes down pipeline
Write-Error       "Oops..."           # Stream 2 - Defaults to Continue
Write-Warning     "Heads up!"         # Stream 3 - Defaults to Continue
Write-Verbose     "More detail"       # Stream 4 - Defaults to SilentlyContinue
Write-Debug       "Debugging info"    # Stream 5 - Defaults to SilentlyContinue
Write-Information "Extra info"        # Stream 6 - Defaults to SilentlyContinue
Write-Progress    "Working on it"     # Stream 7 - Defaults to Continue

Write-Host        "Only for display"  # Goes to the host only - cannot be captured
```

<!--
SPEAKER NOTES:
- DEMO: Show the difference between Write-Output and Write-Host
- Pipe Write-Output to a variable vs Write-Host (nothing captured!)
- Mention Read-Host exists but is bad practice in scripts
-->

---

# Ch 18. Sessions

```powershell
$session = New-PSSession -ComputerName Server01                     # Create a reusable session

Invoke-Command -Session $session -ScriptBlock { $env:COMPUTERNAME } # Use it multiple times
Invoke-Command -Session $session -ScriptBlock { Get-Process }

Remove-PSSession -Session $session                                  # Clean up
```

<div class="callout secondary">

### ℹ️ Why Sessions?

Without a session, `Invoke-Command` creates a new connection. Sessions retain
variables, imported modules, and working directory between calls.

</div>

<!--
SPEAKER NOTES:
- DEMO: Create a session, run multiple commands, show state persists
- Mention implicit remoting (Import-PSSession) if time allows
- This is a brief topic — move through it quickly
-->

---

# Ch 19. You Call This Scripting?

### From commands to scripts

```powershell
# Save this as Get-DiskReport.ps1
param(
    # A parameter with a default value
    [string]$ComputerName = $env:COMPUTERNAME
)

Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $ComputerName |
    Where-Object { $_.DriveType -eq 3 } |
    Select-Object @{n='Drive';e={$_.DeviceID}},
                  @{n='SizeGB';e={[math]::Round($_.Size/1GB,2)}},
                  @{n='FreeGB';e={[math]::Round($_.FreeSpace/1GB,2)}}
```

<!--
SPEAKER NOTES:
- DEMO: Create a .ps1 file, run it, pass a parameter
- Show that it's literally the same commands we type interactively
- The param block is the only new concept here
-->

---

# Ch 20. Improving Your Script

```powershell
function Get-DiskReport {
    [CmdletBinding()]                       # Unlocks `-Verbose`, `-ErrorAction`, and more
    param(
        [Parameter(Mandatory)]              # Forces the user to provide a value
        [ValidateNotNullOrEmpty()]          # Catches bad input early
        [string]$ComputerName
    )

    Write-Verbose "Checking disks on $ComputerName"
    # ... your logic here
}
```

<!--
SPEAKER NOTES:
- DEMO: Add CmdletBinding and Mandatory to a simple script
- Show -Verbose output appearing
- Show what happens when you don't provide a mandatory param
- Key: a few attributes make your script behave like a real cmdlet
-->

---

# Ch 21. Regular Expressions

```powershell
"Server-DC01" -match "DC\d+"      # True: Matches DC followed by one or more digits
$Matches[0]                       # DC01

# Find "ERROR" or "FATAL" in *.log files in the current folder
Select-String -Path *.log -Pattern "ERROR|FATAL"

# Replace with regex
"2026-04-16" -replace "(\d{4})-(\d{2})-(\d{2})", '$2/$3/$1'
# → 04/16/2026
```

<div class="callout secondary">

✨ Use tools like [regex101.com](https://regex101.com) to build and test patterns

</div>

<!--
SPEAKER NOTES:
- DEMO: Show a simple -match, access $Matches
- Show Select-String on a log file
- Don't go deep on regex syntax — just show it exists
- Regex is a skill you build over time, not in 5 minutes
-->

---

# Ch 22. Using someone else's script

## You will inherit scripts

When reading unfamiliar PowerShell code, look for:

<div class="primary-list">

- **param block:** what inputs does it expect?
- **process block:** where's the main logic?
- **comments:** what was the author thinking?
- **Get-Help:** does the script have comment-based help?

</div>

<!--
SPEAKER NOTES:
- DEMO: Open a script from the repo, walk through how to read it
- param block first → understand the inputs and how to call the script
- process block → that's where the main logic lives; look for it in longer scripts
- comments → read them first, they tell you what the author was thinking
- Get-Help → well-written scripts have comment-based help; try Get-Help .\script.ps1
- You'll spend more time reading code than writing it — get comfortable with this process
- Transition: "Last couple blocks — logic, errors, and wrapping up!"
-->

---

<!-- _class: big-statement -->
# Block 7

## Logic, Errors, Debugging & Tips

<span class="primary-bg">Chapters 23–27</span>

<span class="accent">~30 minutes</span>

<!--
SPEAKER NOTES:
- Home stretch! We're covering scripting mechanics now
- Loops, error handling, debugging, and tips
- These make the difference between "a script" and "a good script"
-->

---

# Ch 23. Logic and Loops

<div class="columns">
<div>

## if / elseif / else

```powershell
if ($service.Status -eq 'Running') {

    Write-Output 'Service is healthy'

} elseif ($service.Status -eq 'Stopped') {

    Write-Warning 'Service is stopped!'

} else {

    Write-Error "Service is $($service.Status)"

}
```

</div>

<div>

## foreach & while

```powershell
foreach ($server in $servers) {

    Test-Connection $server -Count 1 -Quiet

}

$secretNumber = 42
$tries = 0
while ($guess -ne $secretNumber) {
    $tries++
    $guess = Get-Random -Min 1 -Max 100
}
Write-Host "Guessed in $tries tries!"
```

</div>

</div>

<!--
SPEAKER NOTES:
- DEMO: Show a simple if/else, then a foreach loop
- Mention switch statement exists but don't demo
- Remind people: prefer pipeline over explicit loops when possible
-->

---

# Ch 24. Handling errors

## When Things Go Wrong

<div class="columns">
<div>

```powershell
try {
    Get-Content foo.txt -EA Stop
} catch {
    Write-Warning "Uh oh: $_"
} finally {
    Write-Verbose "Optional:"
    Write-Verbose "Always runs (usually)"
}
```

</div>

<div>

- `-EA Stop` turns non-terminating errors into terminating ones
- `try`/`catch` only catches <span class="quaternary">**terminating**</span> errors
- `$_` in the catch block holds the error details

</div>

</div>

<!--
SPEAKER NOTES:
- DEMO: Show try/catch with and without -ErrorAction Stop
- Explain terminating vs non-terminating errors
- Show $_ and $_.Exception.Message
- This is critical for reliable scripts
-->

---

# Ch 25. Debugging

## Finding and Fixing Problems

<div class="columns">
<div>

```powershell
# Add breakpoints
Set-PSBreakpoint .\MyScript.ps1 -Line 10

# Use Write-Debug for investigation
Write-Debug "Variable value: $myVar"

# Debug in VSCode
# Set breakpoints in editor and press F5
```

</div>
<div>

<div class="callout primary">

### 💡 Easiest in VSCode

Set breakpoints with a click in the gutter.

Step through code with F10/F11.

Inspect variables in the debug pane.

</div>

</div>
</div>

<!--
SPEAKER NOTES:
- DEMO: Set a breakpoint in VS Code, run script, step through
- Show the Variables pane, Watch expressions
- Mention Write-Debug and -Debug switch
- VS Code debugging is the way to go for anything non-trivial
-->

---

# Ch 26. Tips, Tricks & Techniques

### Power User Moves

<div class="columns">
<div>

```powershell
# Custom profile startup script
code $PROFILE

# Splatting — clean up long commands
$params = @{
    Path        = "C:\Logs"
    Filter      = "*.log"
    Recurse     = $true
    ErrorAction = "SilentlyContinue"
}
Get-ChildItem @params
```

</div>
<div>

```powershell
# Ternary operator (PowerShell 7+)
$status = $isRunning ? "Running" : "Stopped"

# Syntactic-sugar for...
$status = if ($isRunning) {
    "Running"
} else {
    "Stopped""
}
```

</div>
</div>

<!--
SPEAKER NOTES:
- DEMO: Show $PROFILE, create a simple profile greeting
- Show splatting with a real command
- Mention other operators: -replace, -split, -join, -contains, -in
- These are quality-of-life improvements that add up
-->

---

# Ch 26. More Useful Tricks

### Operators & String Magic

<div class="columns">

<div>

```powershell
# Type checking and casting
42 -is [int]            # True
"42" -as [int]          # 42

# String manipulation
"Hello World" -split " "
# @("Hello", "World")

@("one","two") -join ", "    # "one, two"

"Error: disk full" -replace "Error:", "Ope,"
```

</div>

<div>

```powershell
# Array filtering

$numbers = 1..10
$numbers -contains 5           # True
5 -in $numbers                 # True
```

</div>

</div>



<!--
SPEAKER NOTES:
- Quick overview — don't dwell on each one
- Point people to Get-Help about_Operators for the full list
- These come up constantly in real scripts
-->

---

# Ch 27. Never the End

## Where to Go From Here

<div class="primary-list">

- 📖 **Read the book:** *Learn PowerShell in a Month of Lunches*
- 🌐 **PowerShell docs:** [learn.microsoft.com/powershell](https://learn.microsoft.com/powershell)
- 💬 **Community:** Discord, Reddit, PowerShell.org, Bluesky
- 🧪 **Practice:** automate something real at work or home
- 📦 **Explore modules:** [PowerShell Gallery](https://powershellgallery.com)

</div>

<!--
SPEAKER NOTES:
- Encourage people to pick ONE thing to automate when they get back
- Mention the PowerShell community is incredibly welcoming
- Point to the GitHub repo for all session materials
- The best way to learn: use it — find a repetitive task, automate it, break it, fix it. That's how every expert started.
-->

---

# Workshop Recap

### What We Covered Today

<div class="columns">
<div>

| Block | What You Learned |
|-------|-----------------|
| <span class="primary">**1**</span> | The shell, help system, running commands |
| <span class="primary">**2**</span> | Providers and the pipeline |
| <span class="primary">**3**</span> | Modules, objects, and discovery |
| <span class="secondary">**4**</span> | Pipeline binding, formatting, filtering |

</div>
<div>

| Block | What You Learned |
|-------|-----------------|
| <span class="secondary">**5**</span> | Remoting, jobs, and ForEach |
| <span class="tertiary">**6**</span> | Variables, I/O, scripting, regex |
| <span class="quaternary">**7**</span> | Logic, errors, debugging, tips & tricks |

</div>
</div>

<!--
SPEAKER NOTES:
- Use this as a victory lap — you just speed-ran an entire book
- Pause and let it sink in: this is genuinely a lot of ground to cover
- Invite any final questions before the wrap-up
- Remind people: you won't remember all of this, and that's OK — you know it exists
  and you know how to find it again
-->

---

<!-- _class: title -->
# <span class="gradient-text">THANK YOU</span>

## <span class="primary">Feedback</span> is a <span class="quaternary">gift</span>

<p class="name">Please review this session via the mobile app</p>
<p class="handle">Questions? Find me @joshooaj.com</p>

<!--
SPEAKER NOTES:
- Thank everyone for spending 4 hours with you
- Point to session review in the app
- Offer to chat in the hallway track
- Share GitHub repo link one more time
-->