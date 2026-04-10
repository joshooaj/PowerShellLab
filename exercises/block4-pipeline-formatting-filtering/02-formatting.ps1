# ============================================================================
# Ch 11: Formatting — Making Output Look Right
# ============================================================================
# PowerShell has a formatting system that controls how objects display.
# Format commands should ALWAYS be the LAST thing in your pipeline.
# ============================================================================


# --- IMPORTANT GOTCHA: Column headers ≠ property names ---

# The formatted output can lie! Run Get-Process and look at the column "CPU(s)".
# Now run this — CPU(s) is the "display name" for the ScriptProperty "CPU".
# Since CPU is a ScriptProperty, it ONLY exists in PowerShell - it's not a real
# property of the .NET Process object.
Get-Process | Get-Member | Where-Object Name -like '*CPU*'

# --- Format-Table (ft) ---

# Default table output (PowerShell picks the columns)
Get-Process | Format-Table

# Pick specific columns
Get-Process | Format-Table Name, Id, CPU

# Auto-size columns to fit the data
Get-Process | Format-Table Name, Id, CPU -AutoSize

# Wrap long text instead of truncating
Get-Process | Format-Table Name, Id, Path -Wrap

# Show ALL properties (or as many as will fit) (wide output!)
Get-Process -Id $PID | Format-Table *

# -GroupBy: groups rows by a property value, printing a new header each time
# the value changes. IMPORTANT: sort on the same property first!
gci ~ -File | Sort-Object Extension, Length | Format-Table Name, Length -GroupBy Extension


# --- Format-List (fl) ---

# List view shows one property per line — great for discovering properties
Get-Process -Id $PID | Format-List *

# Pick specific properties
Get-Process -Id $PID | Format-List Name, Id, Path, StartTime


# --- Format-Wide (fw) ---

# Display a single property in columns
Get-Process | Format-Wide Name -Column 4

# Great for a quick overview of names
Get-ChildItem ~ | Format-Wide Name -Column 3


# --- Custom Columns with Hash Tables ---

# Format-Table supports the same calculated properties as Select-Object
$columns = @(
    'Name',
    @{
        Name       = 'VM (MB)'
        Expression = {
            $_.VirtualMemorySize64 / 1MB
        }
        Align      = 'Right'
    },
    @{
        Name       = 'Mem (MB)'
        Expression = {
            $_.WorkingSet / 1MB
        }
        Align      = 'Right'
    },
    'Id'
)
Get-Process |
    Sort-Object WorkingSet -Descending |
    Select-Object -First 10 |
    Format-Table $columns -AutoSize

# The KB, MB, GB, TB shortcuts are built into PowerShell!
1KB   # 1024
1MB   # 1048576
1GB   # 1073741824


# --- THE GOLDEN RULE: Format Right ---

# Format commands produce FORMAT objects, not the original object type.
# They should be the LAST thing in your pipeline, and only for VIEWING data.

# CORRECT: Select → Export, or Select → Format
Get-Process | Select-Object Name, Id, CPU | Export-Csv ~/procs.demo.csv -NoTypeInformation
Get-Process | Select-Object Name, Id, CPU | Format-Table -AutoSize

# WRONG: Format → Export (you're exporting formatting instructions, not data!)
# Get-Process | Format-Table Name, Id, CPU | Export-Csv ~/broken.csv
# ^^^ This would give you garbage in the CSV!

# See for yourself:
Get-Process | Format-Table Name, Id | Export-Csv ~/procs.demo.wrong.csv -NoTypeInformation
Import-Csv -Path ~/procs.demo.wrong.csv
Get-Process | Format-Table Name, Id | Get-Member
# TypeName: Microsoft.PowerShell.Commands.Internal.Format.* ← NOT process objects!

Remove-Item ~/procs.demo.csv, ~/procs.demo.wrong.csv -ErrorAction SilentlyContinue


# --- Lab Challenge ---
#
# 1. Get processes, format as a table with Name, Id, and a custom "VM (MB)" column
#    Get-Process | Format-Table Name, Id,
#        @{n='VM (MB)'; e={$_.VirtualMemorySize64 / 1MB}} -AutoSize
#
# 2. List files in your home dir, format-wide with 4 columns
#    Get-ChildItem ~ | Format-Wide Name -Column 4
#
# 3. Get modules and format as a list showing Name and Version
#    Get-Module -ListAvailable | Format-List Name, Version
#
# 4. What happens if you pipe Format-Table into Get-Member?
#    Get-Process | Format-Table | Get-Member
#    (Answer: you see formatting objects, not process objects!)
