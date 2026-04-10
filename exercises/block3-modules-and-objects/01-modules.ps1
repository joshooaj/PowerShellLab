# ============================================================================
# Block 3: Modules & Objects (Chapters 7-9)
# ============================================================================
# Ch 7 - Adding Commands (Modules)
#
# Modules are how PowerShell becomes extensible. They're packages of
# commands — like npm packages or Python libraries.
# ============================================================================


# --- Discovering Modules ---

# See what modules are already installed
Get-Module -ListAvailable | Select-Object -First 20 Name, Version

# See what's currently loaded in your session
Get-Module

# What commands does a specific module provide?
Get-Command -Module Microsoft.PowerShell.Archive

# The module path tells PowerShell where to look for modules
# On Windows, the path separator is ";", and it's ":" elsewhere.
# The PathSeparator value can be used to write cross-platform code.
$env:PSModulePath -split [io.path]::PathSeparator

# Modules in PSModulePath are auto-discovered and auto-loaded on demand.
# You can ask for help on a command — and even run it — without ever
# explicitly calling Import-Module.
Get-Help Compress-Archive          # module auto-discovered before loading
Get-Command -Module Microsoft.PowerShell.Archive  # lists commands without loading


# --- Finding Modules on PowerShell Gallery ---

# The PowerShell Gallery (https://powershellgallery.com) is a public repository
# of community-contributed modules. ALWAYS review code before running it.

# Search the gallery (Find-Module works to. Found in older PowerShellGet module)
Find-PSResource -Name '*yaml*'
Find-PSResource -Tag 'DevOps' | Select-Object -First 10 Name, Description

# Install a module from the gallery (-Version is optional)
Install-PSResource -Name powershell-yaml -Version 0.4.11

# Update an installed module to the latest version
# Note: This actually just installs the newest version and leaves the old version in place
Update-PSResource -Name powershell-yaml

# What versions of powershell-yaml do we have installed now?
Get-Module -Name powershell-yaml -ListAvailable

# What commands did our installed module add?
Get-Command -Module powershell-yaml

# Which module version will this import?
Import-Module -Name powershell-yaml
Get-Module -Name powershell-yaml

# Remove a module from the current session (does NOT uninstall it)
Remove-Module -Name powershell-yaml

# IMPORTANT: Modules which load DLLs may never be truly removed from the current
# session. You may find you have to close the session to update or import a
# different version.         


# --- Command Conflicts and Noun Prefixes ---

# Most modules (sadly, not all) add a prefix to their nouns to avoid conflicts.
#   Get-ADUser        (ActiveDirectory module from RSAT)
#   Get-AzureADUser   (Az.Resources module)
#
# If two modules have the same command name, the last one loaded wins.
# To call the other one explicitly, prefix with the module name:
Microsoft.PowerShell.Management\Get-ChildItem

# You can also add your own prefix on import:
# → ConvertFrom-Yaml becomes ConvertFrom-MyYaml
Import-Module powershell-yaml -Prefix My
Get-Command -Module powershell-yaml

# --- Using a Built-In Module: Microsoft.PowerShell.Archive ---

# Let's use Compress-Archive and Expand-Archive — no install needed!

# Create some test files to work with
$demoPath = Join-Path ~ "ModuleDemo"
New-Item -Path $demoPath -ItemType Directory -Force | Out-Null

1..5 | ForEach-Object {
    "This is file number $_" | Out-File (Join-Path $demoPath "file$_.txt")
}

# See what we created
Get-ChildItem $demoPath

# Compress them into a zip
$zipPath = Join-Path ~ "ModuleDemo.zip"
Compress-Archive -Path "$demoPath/*" -DestinationPath $zipPath -Force
Get-Item $zipPath

# Expand to a new location
$extractPath = Join-Path ~ "ModuleDemo-Expanded"
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
Get-ChildItem $extractPath

# Compare the original and expanded versions
$original = Get-ChildItem $demoPath | Select-Object -ExpandProperty Name
$expanded = Get-ChildItem $extractPath | Select-Object -ExpandProperty Name
Compare-Object -ReferenceObject $original -DifferenceObject $expanded

# Clean up
Remove-Item $demoPath, $zipPath, $extractPath -Recurse -Force


# --- Exploring Module Commands ---

# Get help on commands from a module
Get-Help Compress-Archive -Examples

# What parameters does it accept?
Get-Help Compress-Archive -Parameter *


# --- Lab Challenge ---
#
# 1. List all modules available on your system
#    Get-Module -ListAvailable | Select-Object Name, Version
#
#    Try getting a list with the module names, version, and file location
#
# 2. Find what module provides the Get-FileHash command
#    Get-Command Get-FileHash | Select-Object Module
#
# 3. Search the PowerShell Gallery for a module that sounds interesting
#    and look at its commands (but don't install it yet!)
#    Find-PSResource -Name '*<topic>*'
#
# 4. Create a folder with 10 files, zip it, expand it, verify the contents match
#    (Hint: use the pattern from the demo above)
