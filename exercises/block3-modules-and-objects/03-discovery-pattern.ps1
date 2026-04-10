# ============================================================================
# Ch 9: A practical interlude — The Discovery Pattern
# ============================================================================
# This chapter teaches the most important workflow in PowerShell:
# how to figure things out on your own.
# ============================================================================


# --- The 5-Step Discovery Pattern ---

# 1. Define the goal in plain English
# 2. Search for commands: Get-Command *keyword*
# 3. Read the help: Get-Help Command-Name -Examples
# 4. Try it in the terminal (using -WhatIf for safety)
# 5. Refine with Where-Object, Sort-Object, Select-Object

# Let's walk through a real example:
# GOAL: "Find all processes using more than 100MB of memory"


# Step 1: Define the goal
# "I want to see processes that use a lot of memory."

# Step 2: Search for commands
Get-Command *process*

# Step 3: Read the help
Get-Help Get-Process -Examples

# Step 4: Try it
Get-Process

# Step 4.5: Show ALL the available properties and values on one process
Get-Process | Select-Object * -First 1

# Step 5: Refine — filter, sort, and select
Get-Process |
    Where-Object WorkingSet -gt 100MB |
    Sort-Object WorkingSet -Descending |
    Select-Object Name, Id, @{Name = 'MemoryMB'; Expression = { [math]::Round($_.WorkingSet / 1MB) } }


# --- Example: Working with YAML ---

# This is the exact approach the book walks through in Chapter 9.
# GOAL: "Convert a YAML file into JSON"

# Step 1: Define the goal — we want to work with YAML files.

# Step 2: Search locally first — nothing here?
Get-Help *yaml*
Get-Command -Noun *yaml*

# Step 3: Search the PowerShell Gallery for community modules
Find-PSResource -Name '*yaml*' | Format-Table -AutoSize Name, Version, Description

# Step 4: Install a promising module (review the code/author first!)
# ⚠️  Always check who published a module and review its source before installing.
# Install-Module -Name powershell-yaml

# Step 5: Explore what commands the module added
# Get-Command -Module powershell-yaml

# Step 6: Read the help (even when authors skip it, PowerShell still shows syntax)
# Get-Help ConvertFrom-Yaml
# Get-Help ConvertTo-Yaml

# Step 7: Try it — convert a YAML string to a PowerShell object
$yaml = @'
name: PowerShell Summit
year: 2026
topics:
  - modules
  - objects
  - pipelines
'@

$yaml | ConvertFrom-Yaml                        # hashtable
$yaml | ConvertFrom-Yaml | gm                   # TypeName: System.Collections.Hashtable
$yaml | ConvertFrom-Yaml | ConvertTo-Json       # easy format conversion!

# Step 8: Go the other direction — object → YAML
Get-Process -Id $PID |
    Select-Object Name, Id, CPU |
    ConvertTo-Yaml


# --- Another Example: Working with Files ---

# GOAL: "Find the 10 largest files in my home directory (recursively)"

# Step 1: I need to list files
# Step 2: What commands work with files?
Get-Command | Where-Object OutputType -match 'file'

# Step 3: What does "-Recurse" do on Get-ChildItem?
Get-Help Get-ChildItem -Parameter Recurse

# Step 4: Try it!
# Note: This might take a while so you might swap the order of "Select-Object"
#       and "Sort-Object" to save time. Press CTRL+C to stop a command.
Get-ChildItem ~ -Recurse -File -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending |
    Select-Object -First 10 FullName, Length


# --- Another Example: Dates ---

# GOAL: "What day of the week was January 1, 2000?"

# Step 1: I need to work with dates
# Step 2: What commands work with dates?
Get-Command *date*

# Step 2.5: That was a lot of unrelated commands - let's filter out "update"
Get-Command *date* | ? Name -notlike '*update*'

# Step 3: How does Get-Date work?
Get-Help Get-Date -Examples

# Step 4: Try it
(Get-Date -Year 2000 -Month 1 -Day 1).DayOfWeek

# Step 5: What about your birthday?
# (Get-Date -Year 1990 -Month 6 -Day 15).DayOfWeek


# --- Another Example: Hashing Files ---

# GOAL: "Generate a checksum for a file to verify its integrity"

# Step 2: Search for hash commands
Get-Command *hash*

# Step 3: Read the help
Get-Help Get-FileHash -Examples

# Step 4: Create a test file and hash it
"PowerShell Summit 2026!" | Out-File ~/hashtest.txt -NoNewline
Get-FileHash ~/hashtest.txt
Get-FileHash ~/hashtest.txt -Algorithm SHA256
Get-FileHash ~/hashtest.txt -Algorithm MD5

# Step 4.5: Check with your neighbor - these hashes should be identical everywhere
# Note that without "-NoNewLine", you will see different hashes between Windows
# and Linux / MacOS due to different newlines: CR-LF (Windows), vs LF (non-Windows)

# Clean up
Remove-Item ~/hashtest.txt


# --- The Pattern Works for EVERYTHING ---

# Need to work with JSON?
Get-Command *json*

# Need to work with CSV?
Get-Command *csv*

# Need to measure things?
Get-Command *measure*

# Need to compare things?
Get-Command *compare*

# You don't have to memorize everything
# if you can remember how to FIND it.


# --- Lab Challenge ---
#
# Use the discovery pattern to solve these on your own:
#
# 1. Find a command that generates random numbers
#    Hint: Get-Command *random*
#
# 2. Generate a random number between 1 and 100
#    Hint: Get-Help Get-Random -Examples
#
# 2b. Will Get-Random EVER return 100 if the max is set to 100?
#
# 3. Find a command that creates file checksums (hashes)
#    Hint: Get-Command *hash*
#
# 4. Hash every .ps1 file in this code folder and sort by hash value
#    Hint: Get-ChildItem *.ps1 | Get-FileHash | Sort-Object Hash
#
# 5. (Bonus) Use Find-Module to find a module for something you care about.
#    Read its commands without installing it:
#    Find-Module -Name 'psake' | Select-Object -ExpandProperty AdditionalMetadata
