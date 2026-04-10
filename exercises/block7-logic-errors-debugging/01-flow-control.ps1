# ============================================================================
# Ch 23: Flow Control — If/Else, Loops, and Decisions
# ============================================================================
# Control structures let your code make decisions and repeat work.
# ============================================================================


# --- If / ElseIf / Else ---

$hour = (Get-Date).Hour

if ($hour -lt 12) {
    "Good morning!"
} elseif ($hour -lt 17) {
    "Good afternoon!"
} else {
    "Good evening!"
}

# Comparison operators refresher:
#   -eq  -ne  -gt  -ge  -lt  -le
#   -like  -notlike  (wildcard)
#   -match  -notmatch  (regex)
#   -contains  -notcontains  (collection contains value)
#   -in  -notin  (value in collection)

$os = if ($IsWindows) { "Windows" } elseif ($IsLinux) { "Linux" } elseif ($IsMacOS) { "macOS" } else { "Unknown" }
"Running on: $os"


# --- Switch Statement ---

# Switch is cleaner than many if/elseif blocks
$day = (Get-Date).DayOfWeek

switch ($day) {
    'Monday'    { "Start of the work week" }
    'Friday'    { "Almost the weekend!" }
    'Saturday'  { "Weekend!" }
    'Sunday'    { "Weekend!" }
    default     { "Midweek — keep going!" }
}

# Switch with -Wildcard
$file = "report.csv"
switch -Wildcard ($file) {
    '*.csv'  { "Comma-separated file" }
    '*.json' { "JSON file" }
    '*.xml'  { "XML file" }
    '*.txt'  { "Text file" }
    default  { "Unknown file type" }
}

# Switch with -Regex
# NOTE: Don't use $input as a variable name — it's a reserved automatic variable!
$testValue = "192.168.1.1"
switch -Regex ($testValue) {
    '^\d{1,3}(\.\d{1,3}){3}$' { "Looks like an IP address" }
    '^\w+@\w+\.\w+$'          { "Looks like an email" }
    '^\d+$'                   { "Looks like a number" }
    default                   { "Unknown format" }
}


# --- ForEach Loop ---

# The foreach STATEMENT (not the cmdlet)
$processes = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10

foreach ($proc in $processes) {
    if ($proc.WorkingSet -gt 500MB) {
        "✓ $($proc.Name) — $([math]::Round($proc.WorkingSet / 1MB))MB"
    } else {
        "✗ $($proc.Name) — $([math]::Round($proc.WorkingSet / 1MB))MB"
    }
}


# --- ForEach-Object (Pipeline Cmdlet) ---

# ForEach-Object is the CMDLET version — designed for the pipeline.
# $_ (or $PSItem) represents the current object in each iteration.
Get-ChildItem $HOME -File -ErrorAction SilentlyContinue |
    Select-Object -First 5 |
    ForEach-Object { "$($_.Name) — $([math]::Round($_.Length / 1KB, 1)) KB" }

# % is a built-in alias for ForEach-Object
Get-Process | Select-Object -First 5 | % { $_.Name }

# Shorter member-access syntax — supply a property or method name directly
Get-Process | Select-Object -First 5 | ForEach-Object Name

# Key distinction:
#   foreach (statement) — needs the whole collection in memory first
#   ForEach-Object       — processes objects ONE AT A TIME as they arrive
#                          in the pipeline, using much less memory


# --- ForEach-Object -Parallel (PowerShell 7+) ---

# -Parallel runs each script block in its own runspace simultaneously.
# Compare sequential vs parallel with Measure-Command:
$sequential = Measure-Command {
    1..5 | ForEach-Object { Start-Sleep -Milliseconds 500; $_ }
}
"Sequential: $([math]::Round($sequential.TotalSeconds, 1))s"

$parallel = Measure-Command {
    1..5 | ForEach-Object -Parallel { Start-Sleep -Milliseconds 500; $_ }
}
"Parallel:   $([math]::Round($parallel.TotalSeconds, 1))s"

# Default throttle limit is 5 (max concurrent runspaces).
# Raise it with -ThrottleLimit when you have more items than the default:
1..10 | ForEach-Object -Parallel {
    "Processing $_"
    Start-Sleep -Milliseconds 200
} -ThrottleLimit 10

# ⚠️ Order of results is NOT guaranteed with -Parallel.
# ⚠️ Variables from the outer scope are NOT automatically available.
#    Use the $using: scope modifier to bring them in:
$prefix = "Server"
1..5 | ForEach-Object -Parallel { "$using:prefix-$_" }


# --- For Loop ---

# Traditional counting loop.
# Better than the range operator for very large ranges
for ($i = 1; $i -le 5; $i++) {
    "Iteration $i"
}

# Practical: process items with an index
$colors = @('Red', 'Green', 'Blue', 'Yellow', 'Purple')
for ($i = 0; $i -lt $colors.Count; $i++) {
    "$($i + 1). $($colors[$i])"
}


# --- While Loop ---

# Repeat while a condition is true
$countdown = 5
while ($countdown -gt 0) {
    "T-minus $countdown..."
    $countdown--
    Start-Sleep -Milliseconds 300
}
"Liftoff!"


# --- Do-While and Do-Until ---

# Do-While: execute at least once, repeat while condition is true
$tries = 0
do {
    $tries++
    $roll = Get-Random -Minimum 1 -Maximum 7
    "Rolled a $roll"
} while ($roll -ne 6)
"You rolled a 6! Took $tries tries."

# Do-Until: execute at least once, repeat until condition is true
$guess = 0
$tries = 0
$target = Get-Random -Minimum 1 -Maximum 4
do {
    $tries++
    $guess = Get-Random -Minimum 1 -Maximum 4  # Simulating guesses
} until ($guess -eq $target)
"Got it in $tries tries! The number was $target"


# --- Break and Continue ---

# Break: exit the loop entirely
foreach ($num in 1..20) {
    if ($num -gt 5) { break }
    "Number: $num"
}
# Only prints 1-5

# Continue: skip to the next iteration
foreach ($num in 1..10) {
    if ($num % 2 -eq 0) { continue }   # Skip even numbers
    "Odd: $num"
}

# If you need to break out of an OUTER loop from an INNER loop, you can use
# labels. Let's put it all together: break, continue, and "break <label>"
:outside foreach ($x in 0..10) {
    foreach ($y in 0..10) {
        if ($y % 2) {
            # Skip odd "y" values
            continue
        }

        if ($y % 3 -eq 0) {
            # Break out of the inner loop if "y" divisible by 3
        }
        
        if ($y -ge 5) {
            # Break out of the outer loop if "y" >= 5
            break outside
        }

        "X: $x, Y: $y"
    }
}


# --- Practical Example: File Categorizer ---

$files = Get-ChildItem ~ -File -ErrorAction SilentlyContinue | Select-Object -First 20

$categories = [ordered]@{
    Documents = 0
    Images    = 0
    Code      = 0
    Other     = 0
}

foreach ($file in $files) {
    switch -Wildcard ($file.Extension) {
        { $_ -in '.txt', '.pdf', '.doc', '.docx', '.md' } { $categories.Documents++; break }
        { $_ -in '.jpg', '.png', '.gif', '.svg', '.bmp' } { $categories.Images++; break }
        { $_ -in '.ps1', '.py', '.js', '.cs', '.sh' }     { $categories.Code++; break }
        default { $categories.Other++ }
    }
}

[PSCustomObject]$categories | Format-List


# --- Lab Challenges ---
#
# 1. Write an if/elseif/else block that categorizes a file's size:
#    < 1KB = "Tiny", < 1MB = "Small", < 100MB = "Medium", else "Large"
#
# 2. Use a switch statement on (Get-Date).DayOfWeek to print a
#    different motivational message for each day.
#
# 3. Write a while loop that generates random numbers (1-100) and
#    stops when it gets a number greater than 95. Count the attempts.
#
# 4. Use foreach with break/continue:
#    Loop through Get-Process, skip any with WorkingSet < 10MB,
#    and stop after printing 5 large processes.
