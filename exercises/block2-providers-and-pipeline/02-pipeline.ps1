# ============================================================================
# Ch 6: The Pipeline — Connecting Commands Together
# ============================================================================
# The pipeline (|) passes OBJECTS from one command to the next.
# This is PowerShell's superpower — it's not piping text like bash.
# ============================================================================


# --- Basic Pipeline ---

# Get all processes and sort by CPU usage
Get-Process | Sort-Object CPU -Descending

# Chain more commands: sort, then pick the top 5
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5

# Filter + sort + select — build it up step by step
Get-Process |
    Where-Object { $_.CPU -gt 0 } |
    Sort-Object CPU -Descending |
    Select-Object -First 10 Name, CPU


# --- Out-File and the > Shorthand ---

# PowerShell's default output destination is the screen (Out-Host).
# You can redirect it to a file with Out-File:
Get-ChildItem ~ | Out-File ~/dirlist.txt
Get-Content ~/dirlist.txt | Select-Object -First 5

# The > character is shorthand for Out-File (Bash compatibility):
Get-ChildItem ~ > ~/dirlist2.txt

# Out-File also supports -Width (default is 80 cols, which can truncate tables):
Get-Process | Out-File ~/procs.txt -Width 200

# What other Out- cmdlets exist? Discover them:
Get-Command -Verb Out

# Key ones: Out-File, Out-Host, Out-Null, Out-String, Out-Default
# Out-Null is handy for silencing noisy output:
New-Item ~/suppress-me.txt -ItemType File -Force | Out-Null

# Clean up temp files
Remove-Item ~/dirlist.txt, ~/dirlist2.txt, ~/procs.txt, ~/suppress-me.txt -ErrorAction SilentlyContinue


# --- Exporting Data ---

# Export to CSV — great for spreadsheets
Get-Process | Select-Object Name, Id, CPU |
    Export-Csv -Path ~/processes.csv -NoTypeInformation

# Look at the raw file — it's plain text, just formatted as CSV
Get-Content ~/processes.csv | Select-Object -First 5

# Import it back as objects — use Import-Csv, NOT Get-Content!
Import-Csv ~/processes.csv | Select-Object -First 5

# Useful Export-Csv parameters worth knowing:
#   -NoTypeInformation / -IncludeTypeInformation
#     Include the #TYPE header line at the top (off by default in PS 6+)
Get-Process | Select-Object -First 3 | Export-Csv ~/typed.csv -IncludeTypeInformation
Get-Content ~/typed.csv | Select-Object -First 2   # notice the #TYPE line

#   -NoClobber — refuse to overwrite an existing file
# Get-Process | Export-Csv ~/typed.csv -NoClobber   # would error — file exists

#   -Delimiter — use a different separator (pipe-delimited is common in some regions)
Get-Process | Select-Object -First 3 Name, Id |
    Export-Csv ~/processes-pipe.csv -Delimiter '|' -NoTypeInformation
Get-Content ~/processes-pipe.csv | Select-Object -First 3

#   -UseCulture — uses the system's default list separator (locale-aware)
# Get-Process | Export-Csv ~/processes-culture.csv -UseCulture

Remove-Item ~/typed.csv, ~/processes-pipe.csv -ErrorAction SilentlyContinue

# Export to JSON
Get-Process | Select-Object -First 5 Name, Id, CPU |
    ConvertTo-Json |
    Set-Content ~/processes.json

# ConvertTo vs Export: ConvertTo- only converts (outputs a string on the pipeline).
# Export- does both the conversion AND saves to a file.
# That's why we need | Set-Content when using ConvertTo-Json.

# Round-trip: read the file back and convert from JSON
Get-Content ~/processes.json | ConvertFrom-Json | Select-Object -First 3 Name, Id

# Note: ConvertFrom-Json returns different object types than the original Get-Process,
# so the display formatting may look different. For round-tripping PowerShell objects
# faithfully, use Export-Clixml / Import-Clixml instead.

# Export to HTML — open this in a browser!
Get-Process | Select-Object Name, Id, CPU |
    ConvertTo-Html -Title "Process Report" |
    Out-File ~/processes.html

Start-Process ~/processes.html

# Export to XML (preserves object types for re-import)
Get-Process | Select-Object -First 10 | Export-Clixml ~/processes.xml
$restored = Import-Clixml ~/processes.xml
$restored | Select-Object -First 3 Name, Id


# --- Comparing Snapshots with Compare-Object ---

# Take a baseline snapshot of running processes
# Note: This might take some time!
Get-Process | Export-Clixml ~/baseline.xml

# Now start something new (like another pwsh instance) and compare:
Compare-Object -ReferenceObject (Import-Clixml ~/baseline.xml) -DifferenceObject (Get-Process) -Property Name

# Clean up
Remove-Item ~/processes.xml, ~/processes.json, ~/processes.html, ~/baseline.xml -ErrorAction SilentlyContinue -Verbose

# Here's a simpler example you can try right now:
$before = Get-ChildItem ~
New-Item ~/compare-test.txt -ItemType File -Force | Out-Null
$after = Get-ChildItem ~

Compare-Object -ReferenceObject $before -DifferenceObject $after -Property Name

# Clean up
Remove-Item ~/compare-test.txt -ErrorAction SilentlyContinue


# --- The -WhatIf Safety Net and $ConfirmPreference ---

# Cmdlets that modify the system each have an internal "impact level".
# The shell's $ConfirmPreference setting determines when you're auto-prompted.
$ConfirmPreference   # default is "High"

# -WhatIf tells you what WOULD happen without doing it
Get-Process -Name pwsh | Stop-Process -WhatIf

# -Confirm asks you before each action (uncomment to try):
# Get-ChildItem ~/processes.* | Remove-Item -Confirm

# It looks strange, but use "-Confirm:$false" to suppress confirmation:
# Get-ChildItem ~/processes.* | Remove-Item -Confirm:$false

# Actually, -Confirm lowers $ConfirmPreference to "low". Commands declaring
# a "ConfirmImpact" level of "low" or higher will then prompt for confirmation.

# Both -WhatIf and -Confirm are supported by any cmdlet that implements ShouldProcess
# (you can check: Get-PSProvider shows "ShouldProcess" in the Capabilities column)


# --- Same-Noun Piping: Cmdlets That Work Together ---

# Cmdlets sharing the same noun can often pass objects between each other.
# Get-Process feeds right into Stop-Process:
Get-Process -Name pwsh | Stop-Process -WhatIf   # preview — don't actually stop it!

# Same pattern applies to jobs, services, etc.:
#   Get-Job    | Stop-Job / Remove-Job / Receive-Job
#   Get-Service | Stop-Service / Start-Service

# Warning: Get-Process | Stop-Process (no filter, no -WhatIf) would
# attempt to stop EVERY process — including critical system ones. Always filter or use -WhatIf first!


# --- Common Confusion: Get-Content vs Import-Csv / Import-Clixml ---

# Get-Content reads raw text — it does NOT parse CSV or XML structure.
# This produces a wall of comma-separated text - one string per line:
Get-Content ~/processes.csv | Select-Object -First 3

# Import-Csv reads and PARSES the CSV, returning one PSCustomObject per line:
Import-Csv ~/processes.csv | Select-Object -First 3

# The rule: use Import-* to read back whatever Export-* / ConvertTo-* produced.
#   Wrote with Export-Csv?    => Read with Import-Csv
#   Wrote with Export-Clixml? => Read with Import-Clixml
#   Wrote with ConvertTo-Json | Out-File? => Read with Get-Content | ConvertFrom-Json
#
# Use Get-Content when you want the raw text and don't need PowerShell to parse it for you.


# --- Clean Up Demo Files ---

Remove-Item ~/processes.csv, ~/processes.json, ~/processes.html, ~/processes.xml, ~/baseline.xml -ErrorAction SilentlyContinue


# --- Lab Challenge ---
#
# 1. Get all processes, sort by WorkingSet (memory), export the top 10 to a CSV
#    Get-Process | Sort-Object WorkingSet -Descending |
#        Select-Object -First 10 Name, Id, WorkingSet |
#        Export-Csv ~/top-memory.csv -NoTypeInformation
#
# 2. Import that CSV and display it. Then try Get-Content on the same file — what's different?
#    Import-Csv ~/top-memory.csv
#    Get-Content ~/top-memory.csv
#
# 3. Create two text files with different fruit lists and compare them with Compare-Object
#    "apple", "banana", "cherry" | Out-File ~/fruits1.txt
#    "apple", "date", "cherry"   | Out-File ~/fruits2.txt
#    Compare-Object (Get-Content ~/fruits1.txt) (Get-Content ~/fruits2.txt)
#
# 4. Export your running processes to a pipe-delimited file using -Delimiter
#    Get-Process | Select-Object Name, Id | Export-Csv ~/procs-pipe.csv -Delimiter '|' -NoTypeInformation
#    Get-Content ~/procs-pipe.csv | Select-Object -First 5
#    Import-Csv ~/procs-pipe.csv -Delimiter '|' | Select-Object -First 5
#
# 5. Check your $ConfirmPreference and use -WhatIf to preview a potentially destructive command
#    $ConfirmPreference
#    Get-Process -Name pwsh | Stop-Process -WhatIf
#
# 6. Clean up all the files you created
#    Remove-Item ~/top-memory.csv, ~/fruits1.txt, ~/fruits2.txt, ~/procs-pipe.csv -ErrorAction SilentlyContinue
