# ============================================================================
# Ch 8: Objects — Data by another name
# ============================================================================
# Everything in PowerShell is an OBJECT with properties and methods.
# This is the single most important concept in PowerShell.
#
# Think of a command's output as a spreadsheet in memory:
#   Collection = the whole spreadsheet
#   Object     = one row
#   Property   = one column  (data about the object)
#   Method     = an action the object can perform
# ============================================================================


# --- Everything is an Object ---

# A string is an object
"Hello Summit!" | Get-Member

# A number is an object
42 | Get-Member

# A date is an object
Get-Date | Get-Member

# A process is an object
Get-Process -Id $PID | Get-Member


# --- Get-Member (alias: gm) ---

# gm is the command for exploring objects — use it constantly.
# The FIRST line of output tells you the TypeName — pay attention to it!
Get-Process | gm

# gm works after any command that produces output
Get-Date | gm
Get-ChildItem | gm

# You can filter by member type
Get-Date | gm -MemberType Property
Get-Date | gm -MemberType Method

# --- Select-Object *: See ALL Properties

# PowerShell often shows only a subset of the available properties by default.
# Use commands like Select-Object * or Format-List to view everything available:

Get-Process | Get-Random | Select-Object *

Get-Process | Get-Random | Format-List *

# Compare: default view vs. all properties
Get-Process -Id $PID                     # filtered display
Get-Process -Id $PID | Select-Object *   # all properties on screen


# --- Accessing Properties ---

# Dot notation to access a single property
(Get-Date).DayOfWeek
(Get-Date).Year
(Get-Date).Hour

# Access process properties
(Get-Process -Id $PID).ProcessName
(Get-Process -Id $PID).Id
(Get-Process -Id $PID).Path


# --- Calling Methods ---

# Methods are functions, but they're not "PowerShell functions".
# They are invoked using parentheses, and may or may not accept arguments.

# String methods
"Hello Summit".ToUpper()
"Hello Summit".ToLower()
"Hello Summit".Replace("Summit", "World")
"Hello Summit".Contains("Summit")
"       lots of spaces       ".Trim()

# Date methods
(Get-Date).AddDays(30)
(Get-Date).AddHours(-6)
(Get-Date).ToString("yyyy-MM-dd")


# --- Sort-Object: Sorting by Properties ---

# Sort processes by CPU usage
Get-Process | Select-Object -First 10 | Sort-Object CPU -Descending

# Sort by multiple properties (comma-separated)
Get-Process | Sort-Object Name, CPU | Select-Object -First 10 Name, CPU, Id

# Sort files by size
Get-ChildItem ~ -File -Recurse | Select-Object -First 5 Name, Length | Sort-Object Length -Descending


# --- Select-Object: Picking Properties ---

# Select specific properties
Get-Process | Select-Object -First 5 Name, Id, CPU

# Select all properties (discover what's available)
Get-Process -Id $PID | Select-Object *

# -First and -Last
Get-Process | Select-Object -First 3
Get-Process | Select-Object -Last 3

# -Skip
Get-Process | Select-Object -Skip 3 -First 3

# --- Measure-Object: Counting and Summing ---

# How many processes are running?
Get-Process | Measure-Object
(Get-Process).Count

# Sum up the working set memory
Get-Process | Measure-Object -Property WorkingSet -Sum -Average -Minimum -Maximum

# Count and add up size of files in a directory
Get-ChildItem ~ -File -Recurse | select -First 10 | measure Length -Sum


# --- The Pipeline Preserves Object Types ---

# TypeName stays the same through Sort-Object, but changes with Select-Object!
Get-Process | gm | Select-Object -First 1 TypeName                          # System.Diagnostics.Process
Get-Process | Sort-Object CPU | gm | Select-Object -First 1 TypeName        # still Process
Get-Process | Sort-Object CPU | Select-Object Name, CPU | gm | Select-Object -First 1 TypeName
# ^^^ Now it's Selected.System.Diagnostics.Process (a PSCustomObject)!

# You can even pipe gm to gm — it produces its own objects
Get-Process | gm | gm


# --- Lab Challenge ---
#
# 1. What type of object does Get-Date return?
#    Get-Date | gm  (look at the TypeName line)
#
# 2. Display only the DayOfWeek from Get-Date
#    Get-Date | Select-Object DayOfWeek
#
# 2b. Get JUST the DayOfWeek value without the header
#     Get-Date | Select-Object -ExpandProperty DayOfWeek
#
# 3. Get files in your home directory, sort by LastWriteTime,
#    show Name and LastWriteTime, export to CSV
#    Get-ChildItem ~ | Sort-Object LastWriteTime -Descending |
#        Select-Object Name, LastWriteTime |
#        Export-Csv ~/files.csv
#
# 3b. Import the CSV file and select the first 5 files
#
# 4. Get a random number, then explore it with gm. What's the object type?
#    Get-Random | gm
#
# 5. How many items are in your home directory?
#    Get-ChildItem ~ | Measure-Object
