# ============================================================================
# Ch 3: The Help System — The Most Important Skill in PowerShell
# ============================================================================
# The help system is your best friend. If you learn one thing today,
# learn how to use Get-Help to discover commands and understand them.
# ============================================================================


# --- Update Help First ---

# Help files aren't fully installed by default. Run this once.
Update-Help

# Offline? Save help on an internet-connected machine and copy it over:
#   Save-Help -DestinationPath C:\HelpFiles
# Then on the offline machine:
#   Update-Help -SourcePath \\server\HelpFiles


# --- help vs. Get-Help ---

# Get-Help is the cmdlet. "help" is a wrapper function that pages the output
# (so it doesn't scroll past — press Space to advance, Q to quit).
# They return the same information; "help" is just more readable at the console.

Get-Help Get-Process      # output scrolls past all at once
help Get-Process          # paged output — press Q to quit


# --- Finding Commands by Keyword ---

# "I need to do something with processes... what commands exist?"
Get-Help *process*

# "What about working with files?"
Get-Help *file*

# Get-Command is a direct way to search — by noun or verb
Get-Command -Noun Process
Get-Command -Verb Get -Noun *item*

# Use -CommandType to narrow results to only real cmdlets (no external tools)
Get-Command *event* -CommandType Cmdlet


# --- Getting Help on a Specific Command ---

# Basic summary view
Get-Help Get-Process

# Show me examples — the most useful switch!
Get-Help Get-Process -Examples

# Full help with every parameter detail
Get-Help Get-Process -Full

# Open the online docs in your browser (most up-to-date)
Get-Help Get-Process -Online


# --- Reading the Full Help: What to Look For ---

# Get the full help for Get-ChildItem and read these fields for each parameter:
Get-Help Get-ChildItem -Full

# For each parameter, notice:
#   Required?        → is it mandatory or optional?
#   Position?        → a number = positional; "named" = must type the name
#   Accept wildcard? → can you use * and ?
#   Pipeline input?  → can you pipe values to it?

# Key things to notice in the SYNTAX line:
#   [-Path]          → name in square brackets = POSITIONAL (you can skip -Path)
#   <string[]>       → [] after the type = accepts multiple values (array)
#   [-Recurse]       → entire entry in brackets = OPTIONAL switch, no value
#   [-Filter <string>] → optional named parameter with a value

# These two commands are equivalent because -Path is positional (position 0):
Get-ChildItem -Path ~
Get-ChildItem ~


# --- "About" Topics ---

# PowerShell has conceptual help topics beyond individual commands
Get-Help about_*

# Some useful ones to explore later:
Get-Help about_Operators
Get-Help about_Comparison_Operators
Get-Help about_Pipelines
Get-Help about_CommonParameters    # Learn about -Verbose, -ErrorAction, -WhatIf, etc.


# --- Lab Challenge ---
# Try these on your own:
#
# 1. Find a command that converts output to HTML
#    Hint: Get-Command -Noun *html*
#
# 2. Find commands that work with aliases
#    Hint: Get-Command -Noun Alias
#
# 3. How do you get help on the "about_arrays" topic?
#    Hint: Get-Help about_arrays
#
# 4. You forgot the name of a command but you know it had
#    a parameter named "Append"
#    Hint: Get-Command -ParameterName *append*
#
# 5. Find commands related to transcripts (saving a record of your session)
#    Hint: Get-Command -Noun *transcript*
