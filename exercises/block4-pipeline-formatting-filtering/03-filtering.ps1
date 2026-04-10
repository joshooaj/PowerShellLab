# ============================================================================
# Ch 12: Filtering & Comparisons
# ============================================================================
# Filter LEFT, Format RIGHT. Always filter as early as possible
# in the pipeline to reduce the amount of data you're processing.
# ============================================================================


# --- Comparison Operators ---

# Equality
5 -eq 5          # True
5 -eq 10         # False
5 -ne 10         # True
"hello" -eq "HELLO"  # True! (case-insensitive by default)
"hello" -ceq "HELLO" # False (case-sensitive with -ceq)

# Greater/less than
10 -gt 5         # True
10 -ge 10        # True
5 -lt 10         # True
5 -le 5          # True

# Wildcard matching with -like and -notlike
"PowerShell" -like "Power*"     # True
"PowerShell" -like "*Shell"     # True
"PowerShell" -like "*wer*"      # True
"PowerShell" -like "Bash*"      # False
"PowerShell" -notlike "Bash*"   # True — the logical opposite of -like

# Regex matching with -match
# Note: This pattern matches any text starting with "DC" followed by 1 or more numbers
"Server-DC01" -match "DC\d+"    # True
$Matches[0]                     # DC01

"2026-04-16" -match "(\d{4})-(\d{2})-(\d{2})"
$Matches[1]   # 2026 (year)
$Matches[2]   # 04 (month)
$Matches[3]   # 16 (day)

# Containment
$fruits = @("apple", "banana", "cherry")
$fruits -contains "grape"        # False
$fruits -contains "banana"       # True
"banana" -in $fruits             # True (same check, reversed syntax)

# Boolean values — PowerShell defines $true and $false
$true
$false

5 -eq 5     # evaluates to $true
5 -eq 10    # evaluates to $false

# -not $_.Responding reads like: "the process isn't responding"
# Both forms are equivalent:
$p = Get-Process -Id $PID
$p.Responding -eq $false
-not $p.Responding

# Logical operators AND, OR, NOT
(5 -gt 3) -and (10 -gt 5)       # True
(5 -gt 3) -and (10 -gt 100)     # False
(5 -gt 9) -or (10 -gt 5)        # True
-not $false                     # True
!$false                         # True (shorthand for -not)


# --- Where-Object: Filtering the Pipeline ---

# Full syntax with script block
Get-Process | Where-Object { $_.CPU -gt 0 }

# Simplified syntax (single comparison only)
Get-Process | Where-Object CPU -gt 0

# Multiple conditions require the script block syntax
Get-Process | Where-Object { $_.CPU -gt 0 -and $_.WorkingSet -gt 50MB }

# Filter by name with wildcards
Get-Process | Where-Object Name -like p*

# Filter by property existence
# Objects with missing, null, or empty Length properties are ignored
Get-ChildItem ~ | Where-Object Length


# --- Filter Left: Let the Source Do the Work ---

# GOOD: Filter at the source (fast!)
Get-Process -Name "pwsh"
New-Item ~/filter.demo.txt
Get-ChildItem ~ -Filter "*.txt"
Remove-Item ~/filter.demo.txt

# OK: If you must, filter with Where-Object (processes all objects first)
Get-Process | Where-Object Name -eq "pwsh"
Get-ChildItem ~ | Where-Object { $_.Extension -eq ".txt" }

# The source-level filter is always faster because PowerShell
# doesn't have to create and inspect every single object.


# --- Building Pipelines Iteratively ---

# Start simple, add filters one step at a time:

# Step 1: Get all processes
Get-Process

# Step 2: Filter for interesting property values
Get-Process | Where-Object CPU -gt 0

# Step 3: Exclude PowerShell itself
Get-Process | Where-Object { $_.CPU -gt 0 -and $_.Name -ne 'pwsh' }

# Step 4: Sort by memory usage
Get-Process | Where-Object { $_.CPU -gt 0 -and $_.Name -ne 'pwsh' } |
    Sort-Object WorkingSet -Descending

# Step 5: Take the top 10
Get-Process | Where-Object { $_.CPU -gt 0 -and $_.Name -ne 'pwsh' } |
    Sort-Object WorkingSet -Descending |
    Select-Object -First 10 Name, Id, @{n = 'MemMB'; e = { [math]::Round($_.WorkingSet / 1MB) } }

# Step 6: Measure-Object — aggregate numeric properties across all pipeline objects
# Use -Sum, -Average, -Minimum, or -Maximum
Get-Process | Where-Object { $_.Name -notlike 'pwsh*' } |
    Sort-Object VirtualMemorySize64 -Descending |
    Select-Object -First 10 |
    Measure-Object -Property VirtualMemorySize64 -Sum

# Read the total:
(Get-Process | Measure-Object WorkingSet -Sum).Sum / 1GB   # Total RAM used by all processes in GB


# --- Lab Challenge ---
#
# 1. Get modules loaded in your session that are from Microsoft
#    Get-Module | Where-Object CompanyName -like "*Microsoft*"
#
# 2. Find files in your home directory modified in the last 7 days
#    Get-ChildItem ~ | Where-Object LastWriteTime -ge (Get-Date).AddDays(-7)
#
# 3. Use -match to check if a string looks like an email address
#    P.S. This is a BAD way to validate email addresses
#    "user@example.com" -match "\w+@\w+\.\w+"
#
# 4. Build a pipeline iteratively:
#    - Start with Get-ChildItem ~
#    - Filter to files only (not directories)
#    - Filter to files larger than 1KB
#    - Sort by descending size
#    - Show top 5 with Name and size in KB
#
# 5. Iterative challenge:
#    Measure the total virtual memory used by the 10 most VM-hungry processes,
#    excluding PowerShell itself. Build it one step at a time:
#
#    Get-Process
#    Get-Process | Where-Object { $_.Name -notlike 'pwsh*' }
#    Get-Process | Where-Object { $_.Name -notlike 'pwsh*' } | Sort-Object VirtualMemorySize64 -Descending
#    Get-Process | Where-Object { $_.Name -notlike 'pwsh*' } | Sort-Object VirtualMemorySize64 -Descending # | Select the first 10
#    Get-Process | Where-Object { $_.Name -notlike 'pwsh*' } | Sort-Object VirtualMemorySize64 -Descending # | Select the first 10 and measure the sum of VirtualMemorySize64
