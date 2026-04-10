# ============================================================================
# Ch 10 - The Pipeline, Deeper
# ============================================================================
# How does PowerShell decide which parameter gets pipeline input?
# Two strategies: ByValue and ByPropertyName
# ============================================================================


# --- ByValue: Matching by Object Type ---

# Get-Process outputs Process objects.
# Stop-Process accepts Process objects ByValue on its -InputObject parameter.
# So this "just works":
Get-Process -Name pwsh | Stop-Process -WhatIf

# PowerShell matches the TYPE of the output to the TYPE the next command accepts.


# --- ByPropertyName: Matching by Property Names ---

# When ByValue doesn't match, PowerShell tries matching
# property NAMES to parameter NAMES.

# Example: Create a CSV with columns that match parameter names
$csvContent = @"
Path
$HOME
"@
$csvContent | Out-File ~/paths.csv

# Import the CSV — each row becomes an object with a "Path" property
$items = Import-Csv ~/paths.csv
$items

# Test-Path has a -Path parameter. The CSV's "Path" column matches by name!
$items | Test-Path

# Clean up
Remove-Item ~/paths.csv

# A classic ByPropertyName example from the book:
# Create a CSV whose column headers EXACTLY match New-Alias parameter names
$aliasContent = @"
Name,Value
d,Get-ChildItem
sel,Select-Object
go,Invoke-Command
"@
$aliasContent | Out-File ~/aliases.csv

# Import-Csv produces objects with Name and Value properties.
# New-Alias has -Name and -Value parameters that accept pipeline input ByPropertyName.
# The names match — so this just works!
Import-Csv ~/aliases.csv | New-Alias

# Verify the aliases were created
Get-Alias d, sel, go

# HOW TO VERIFY binding yourself:
# 1. Pipe Command A's output to Get-Member to see the TypeName and property names
Import-Csv ~/aliases.csv | Get-Member
#    TypeName: System.Management.Automation.PSCustomObject
#    Properties: Name, Value
#
# 2. Run Get-Help <CommandB> -Full and look for:
#    "Accept pipeline input?   True (ByValue)"  — or —
#    "Accept pipeline input?   True (ByPropertyName)"
Get-Help New-Alias -Parameter Name | Out-String | Select-String -Pattern 'pipeline'

# Get-Help may not The online help may be more detailed
Get-Help New-Alias -Online


# Clean up
Remove-Item ~/aliases.csv
Remove-Item Alias:\d, Alias:\sel, Alias:\go


# --- Select-Object: Property vs ExpandProperty ---

# -Property wraps the value in a new "Selected.*" object type
Get-Date | Select-Object -Property DayOfWeek

# -ExpandProperty extracts the raw value of the matching property
Get-Date | Select-Object -ExpandProperty DayOfWeek

# This matters when piping to the next command!
# Compare:
Get-Module -ListAvailable -Name Microsoft.* |
    Select-Object -Property Name |
    Get-Member  # New object type with only a Name property

Get-Module -ListAvailable -Name Microsoft.* |
    Select-Object -ExpandProperty Name |
    Get-Member  # String!


# --- When Property Names Don't Line Up: Custom (Calculated) Properties ---

# What if the CSV has columns like "dept" but the command needs "-Department"?
# Use Select-Object -Property * to keep ALL original properties,
# then ADD new calculated properties that use the right parameter names.

$hrContent = @"
login,dept,city,title
TylerL,IT,Seattle,IT Engineer
JamesP,IT,Chattanooga,CTO
"@
$hrContent | Out-File ~/newusers.csv

# The "dept" column won't match -Department. Bridge it with a hash table:
Import-Csv ~/newusers.csv | Select-Object -Property *,
    @{Name = 'samAccountName'; Expression = { $_.login } },
    @{Name = 'Name';           Expression = { $_.login } },
    @{Name = 'Department';     Expression = { $_.dept  } }

# Result: objects now have BOTH the original properties AND the new ones.
# These new property names match New-ADUser parameters — ready to pipe!

Remove-Item ~/newusers.csv

# Create new properties on the fly with hash tables
Get-Process | Select-Object -First 5 Name,
    @{Name = 'MemoryMB';   Expression = { [math]::Round($_.WorkingSet / 1MB, 1) } },
    @{Name = 'CPUSeconds'; Expression = { [math]::Round($_.CPU, 2) } }

# The most important hash table keys for calculated properties:
#   Name (or Label, n, l) = The column header
#   Expression (or e)     = A script block that calculates the value

# This works the same
Get-Process | Select-Object -First 5 Name,
    @{n = 'MemoryMB';   e = { [math]::Round($_.WorkingSet / 1MB, 1) } },
    @{n = 'CPUSeconds'; e = { [math]::Round($_.CPU, 2) } }

# They're just hashtables, you can reuse them if you need to:
$mem = @{n = 'MemoryMB';   e = { [math]::Round($_.WorkingSet / 1MB, 1) } }
$cpu = @{n = 'CPUSeconds'; e = { [math]::Round($_.CPU, 2) } }
Get-Process | Select-Object -First 5 Name, $mem, $cpu

# You can pass all the properties to Select-Object with an array:
$props = @(
    'Name'
    @{n = 'MemoryMB';   e = { [math]::Round($_.WorkingSet / 1MB, 1) } }
    @{n = 'CPUSeconds'; e = { [math]::Round($_.CPU, 2) } }
)
Get-Process | Select-Object -First 5 $props


# --- Parenthetical Commands ---

# Use parentheses to evaluate a "subexpression" and feed the output
# as a PARAMETER value (not pipeline input — a parameter value)
Get-Help -Name (Get-Command | Get-Random)

# --- Lab Challenge ---
#
# 1. What's the difference between these two?
#    Get-Date | Select-Object -Property DayOfWeek
#    Get-Date | Select-Object -ExpandProperty DayOfWeek
#    Hint: Pipe each to Get-Member and compare the TypeName
#
# 2. Get processes with a calculated "MemoryGB" property
#    $calculated = @{n='MemoryGB'; e={ [math]::Round($_.WorkingSet / 1GB, 3) }}
#    Get-Process | Select-Object Name, $calculated | Sort-Object MemoryGB
#        
#
# 3. Use a parenthetical command to get commands from the first 2 modules
#    Get-Command -Module (Get-Module -ListAvailable |
#        Select-Object -First 2 -ExpandProperty Name)
