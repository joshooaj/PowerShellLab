# ============================================================================
# Ch 16: Variables — Storing and Working with Data
# ============================================================================
# Variables are named containers for data. PowerShell variables
# start with $ and can hold any type of object.
# ============================================================================


# --- Creating Variables ---

# Simple assignment
$name = "PowerShell"
$version = 7
$today = Get-Date

# Display the value
$name
$version
$today


# --- Variable Names ---

# Standard names — letters, numbers, underscores
$myVariable = "Hello"
$item_count = 42
$x1 = 1

# Wrap weird names in curly braces
# Not common - avoid unless the goal is unreadable code
${my-variable} = "Hyphenated name"
${my-variable}


# --- Strings: Single vs Double Quotes ---

# Double quotes: variables and subexpressions are expanded
$animal = "cat"
"I have a $animal"                        # I have a cat
"Today is $(Get-Date -Format 'dddd')"     # Today is Monday (or whatever day)

# Single quotes: everything is literal — no expansion
'I have a $animal'                         # I have a $animal
'Today is $(Get-Date)'                     # Today is $(Get-Date)

# Rule of thumb: Use single quotes unless you NEED expansion


# --- Backtick: The Escape Character (Ch 16.3) ---

# The backtick (`) removes or adds special meaning to the character after it.
# On a US keyboard it's in the upper-left, on the same key as ~.

$computer = 'SRV-02'

# Escape the $ sign — makes it literal instead of a variable indicator:
"The variable `$computer contains: $computer"
# Output: The variable $computer contains: SRV-02

# Common escape sequences inside double-quoted strings:
#   `n  — newline (new line)
#   `t  — tab
#   `"  — literal double-quote inside a double-quoted string
#   ``  — literal backtick

"Line one`nLine two`nLine three"       # Line breaks
"Name:`t$computer"                      # Tab between label and value
"She said `"hello`" to me"             # Embedded double-quotes

# See all escape characters:
Get-Help about_Special_Characters


# --- Subexpressions ---

# $() lets you embed commands or complex expressions inside strings
"There are $((Get-Process).Count) processes running"
"The day of the week is $($today.DayOfWeek)"
"2 + 2 = $(2 + 2)"

# Note: The $() is required when using "." to access properties of variables.
#       This won't work:
"The day of the week is $today.DayOfWeek"


# --- Here-Strings (Multi-line) ---

# Double-quoted here-string (expands variables)
# ?? is the "null-coalescing" operator. If the left side is $null, the value from the right side is used.
$computerName = $env:COMPUTERNAME ?? (hostname)
$report = @"
Computer: $computerName
Date: $(Get-Date -Format 'yyyy-MM-dd')
PowerShell: $($PSVersionTable.PSVersion)
"@
$report

# Single-quoted here-string (literal)
$template = @'
Hello $name,
This text is exactly as-is.
No variables are expanded here.
'@
$template


# --- Arrays ---

# Create an array
$fruits = @('apple', 'banana', 'cherry', 'date')
$fruits

# Access elements of the array (0-based index)
$fruits[0]      # apple
$fruits[-1]     # date (last element)
$fruits[0..2]   # apple, banana, cherry (.. is the range operator)

# Count items
$fruits.Count

# Add to an array
$fruits += 'elderberry'
$fruits.Count   # 5

# Quick number ranges
$numbers = 1..10
$numbers

# Careful... creating REALLY large arrays of numbers can be very slow
Measure-Command { 1..10 } | Select-Object TotalSeconds
Measure-Command { 1..100000000 } | Select-Object TotalSeconds

# Iterate
$fruits | ForEach-Object { $_.ToUpper() }


# --- Hashtables ---

# Key-value pairs — like a dictionary
$person = @{
    Name  = 'Josh'
    Role  = 'Nerd'
    Event = 'PowerShell Summit'
}

# Access values
$person['Name']     # Josh
$person.Role        # Nerd

# Add or change entries
$person['Year'] = 2026
$person.Month = 'April'
$person.Role = 'Geek'
$person

# Ordered hashtable (preserves key order)
$orderedPerson = [ordered]@{
    Name  = 'Josh'
    Role  = 'Speaker'
    Event = 'PowerShell Summit'
}
$orderedPerson


# --- Type Declarations ---

# PowerShell is flexible with types, but you can be explicit
[string]$greeting = "Hello"
[int]$count = 42
[datetime]$deadline = '2026-04-14'
[bool]$isReady = $true

# Type constraint prevents assignment of wrong types
$count = "not a number"   # This would error!

# Check types
$greeting.GetType().Name    # String
$count.GetType().Name       # Int32
$deadline.GetType().Name    # DateTime

# Get the full type names, including namespace
$greeting.GetType().FullName    # System.String
$count.GetType().FullName       # System.Int32
$deadline.GetType().FullName    # System.DateTime


# --- Type Conversion ---

# PowerShell will automatically, implicitly convert types if they are not
# constrained. The left-hand side (LHS) of a PowerShell operator usually
# determines how the right-hand side LHS of the operator will be treated:

10 + '5'        # 15 - the '5' is parsed as an integer because the LHS is an integer.
'10' + 5        # 105 - the 5 is converted to a string and added to the string '10'
'10' - '5'      # 5 - "-" is invalid on strings, so both sides are treated as numbers
'10' / '5'      # 2 - "/" is also invalid on strings, so both sides are treated as numbers
' ' -eq $true   # False - the LHS is a string so $true becomes 'True' and 'True' is not ' '
$true -eq ' '   # True - The LHS is boolean and a non-empty string is interpreted as $true
$false -eq ''   # True - The LHS is boolean and an empty string is interpreted as false
'' -eq $false   # False - The LHS is a string so $false becomes the string 'False' and '' -ne 'False'

# These are ALL True on my computer, but they may not be on yours due to OS culture differences:
$date = Get-Date -Year 2026 -Month 4 -Day 16 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
$date -eq '4-16-2026'
$date -eq '04-16-2026'
$date -eq '2026-04-16'


# --- Automatic / Built-in Variables ---

# PowerShell provides many useful automatic variables
$PSVersionTable              # PowerShell version info
$HOME                        # User's home directory
$PWD                         # Current directory
$null                        # Null/nothing - different from an empty string ""
$true                        # Boolean true
$false                       # Boolean false
$_                           # Current pipeline object (in scriptblocks)
$PSItem                      # Same as $_
$PSCulture                   # Current culture
$IsWindows                   # OS detection (PS 7+)
$IsLinux
$IsMacOS
$ErrorActionPreference       # Default error behavior


# --- Environment Variables ---

$env:PATH                            # PATH variable
$env:HOME                            # Home directory
$env:COMPUTERNAME                    # Computer name (Windows-only!)
$env:COMPUTERNAME ?? (hostname)      # Cross-platform: falls back to hostname

# Set a temporary environment variable (current session only)
$env:MY_VAR = "Hello from PS"
$env:MY_VAR

# Remove it
Remove-Item Env:\MY_VAR -ErrorAction SilentlyContinue


# --- Lab Challenges ---
#
# 1. Create variables for your name, favorite color, and birth year.
#    Use a double-quoted string to combine them into a sentence.
#
# 2. Create an array of 5 cities you'd like to visit.
#    Access the first, last, and middle elements.
#
# 3. Create a hashtable describing your computer:
#    Name, OS, PSVersion, CPUCount
#    Hint: $env:COMPUTERNAME, $PSVersionTable, etc.
#
# 4. Experiment with type constraints:
#    [int]$number = 42; $number = "hello"  # what happens?
#    [string]$text = 42                    # what happens?
