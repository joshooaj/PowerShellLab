# ============================================================================
# Ch 21: Regular Expressions — Pattern Matching
# ============================================================================
# Regex lets you match patterns in text. PowerShell makes it
# easy with -match, -replace, and Select-String.
# ============================================================================


# --- The -match Operator ---

# Returns $true/$false and populates $Matches
"PowerShell Summit 2026" -match '\d+'
$Matches        # Shows the list of matches
$Matches[0]     # The value of the first match: 2026

# Case-insensitive by default
"Hello World" -match 'hello'    # True
"Hello World" -cmatch 'hello'   # False (case-sensitive variant)

# Not match
"Hello World" -notmatch '\d'    # True (no digits)


# --- Common Regex Patterns ---

$text = "Call me at 867-5309 or email j@madeye.dev"

# \d  = any digit
# \w  = any word character (letter, digit, underscore)
# \s  = any whitespace
# .   = any character
# +   = one or more
# *   = zero or more
# ?   = zero or one
# ^   = start of string
# $   = end of string

$text -match '\d{3}-\d{4}'     # Match phone number pattern
$Matches[0]                     # 555-1234

$text -match '[\w.]+@[\w.]+'   # Match email pattern
$Matches[0]                     # josh@example.com


# --- Named Captures ---

# Use (?<name>) to assign a name to a capture group
$logLine = "2026-04-14 10:30:45 ERROR: Disk space low"

$logLine -match '(?<date>\d{4}-\d{2}-\d{2})\s(?<time>\d{2}:\d{2}:\d{2})\s(?<level>\w+):\s(?<message>.+)'

$Matches.date       # 2026-04-14
$Matches.time       # 10:30:45
$Matches.level      # ERROR
$Matches.message    # Disk space low


# --- Character Classes ---

# [abc]      = a, b, or c
# [a-z]      = any lowercase letter
# [A-Za-z]   = any letter
# [0-9]      = any digit (same as \d)
# [^abc]     = NOT a, b, or c
#
# Note: Regular Expressions use "^" to anchor a match at the beginning of
#       a string, and "$" to anchor a match at the end of a string.
#       In this example, we match only if the last character is a digit.

"PowerShell7" -match '[0-9]$'     # True — ends with a digit
"PowerShell" -match '[0-9]$'      # False — does not end with a digit


# --- Quantifiers ---

# {n}   = exactly n times
# {n,}  = n or more times
# {n,m} = between n and m times

"abc" -match '\w{3}'          # True — exactly 3 word chars
"ab " -match '\w{3}'           # False

"12345" -match '^\d{5}$'      # True — exactly 5 digits
"123456" -match '^\d{5}$'     # False — 6 digits between begin and end of string


# --- The -replace Operator ---

# Replace text using regex patterns
"Hello World" -replace 'World', 'PowerShell'

# Regex replacement
"Report_2026-04-14.txt" -replace '\d{4}-\d{2}-\d{2}', 'YYYY-MM-DD'

# Replace multiple spaces with a single space
"  extra   spaces  " -replace '\s+', ' '

# Back-references with $1, $2
"Doe, John" -replace '(\w+), (\w+)', '$2 $1'    # John Doe

# Remove non-alphanumeric characters (replace with nothing)
"He!!o, W@rld #123" -replace '[^a-zA-Z0-9\s]'


# --- Select-String (grep for PowerShell) ---

# Search for patterns in file content or strings

# Search in strings
$data = @(
    "Server: web01 Status: Running"
    "Server: db01 Status: Stopped"
    "Server: app01 Status: Running"
    "Server: cache01 Status: Running"
)

$data | Select-String -Pattern 'Stopped'
$data | Select-String -Pattern 'web|app'
$data | Select-String -Pattern 'Status: Running'

# Search in files (searches your PS1 files!)
Get-ChildItem $PWD -Recurse -Filter '*.ps1' |
    Select-String -Pattern 'ForEach-Object' |
    Select-Object -First 5 Filename, LineNumber, Line


# --- Practical Examples ---

# Validate an email address (simple pattern)
function Test-EmailAddress {
    param([string]$Email)
    $Email -match '^[\w.+-]+@[\w.-]+\.\w{2,}$'
}

Test-EmailAddress "user@example.com"     # True
Test-EmailAddress "not-an-email"         # False
Test-EmailAddress "user@test.co.uk"      # True

# Validate an email (more reliable, but not regex)
$addresses = @(
'user@example.com'
'not-an-email'
'user@test.co.uk'
)
$email = $null
foreach ($address in $addresses) {
    $result = [pscustomobject]@{
        Address = $address
        IsValid = $false
    }
    
    if ([System.Net.Mail.MailAddress]::TryCreate($address, [ref]$email)) {
        $result.IsValid = 'Probably'
    }
    $result
}

# Extract version numbers from text
$text = "PowerShell 7.4.1 is the latest stable version"
if ($text -match '(\d+\.\d+\.\d+)') {
    "Found version: $($Matches[1])"
}

# Parse structured log entries
$logs = @(
    "[INFO] 2026-04-14 Started processing"
    "[WARN] 2026-04-14 Disk usage at 85%"
    "[ERROR] 2026-04-14 Connection timeout"
    "[INFO] 2026-04-14 Processing complete"
)

$logs | ForEach-Object {
    if ($_ -match '\[(?<level>\w+)\]\s(?<date>[\d-]+)\s(?<msg>.+)') {
        [PSCustomObject]@{
            Level   = $Matches.level
            Date    = $Matches.date
            Message = $Matches.msg
        }
    }
} | Format-Table


# --- Lab Challenges ---
#
# 1. Write a regex that matches a US zip code: 5 digits, optionally
#    followed by a hyphen and 4 more digits (e.g., 98004 or 98004-1234)
#    "98004-1234" -match '^\d{5}(-\d{4})?$'
#
# 2. Use -replace to transform dates from "04/14/2026" to "2026-04-14"
#    "04/14/2026" -replace '(\d{2})/(\d{2})/(\d{4})', '$3-$1-$2'
#
# 3. Use Select-String to find all single-line comments in a .PS1 file
#    Get-ChildItem *.ps1 -Recurse | Select-Object -First 1 | Select-String '^\s*#'
#
# 4. Parse this string and extract each field using named captures:
#    "Name=Josh;Role=Nerd;Event=Summit"
#
#
#
#
#
#
#    $fields = [ordered]@{}
#    $text = 'Name=Josh;Role=Nerd;Event=Summit'
#    $pattern = '(?<name>[^=;]+)=(?<value>[^;]+)'
#    [regex]::Matches($text, $pattern) | % {
#       $key = $_.Groups['name'].Value
#       $val = $_.Groups['value'].Value
#       $fields[$key] = $val
#    }
#    $fields
