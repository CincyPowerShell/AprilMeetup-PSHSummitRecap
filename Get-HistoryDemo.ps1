# Automatic PowerShell variables
# Variable drive
cd variable: # Set-Location variable:

# list all Automatic PowerShell variables
dir variable:\ # Get-ChildItem -Path variable:

# PWD - PowerShell's Current Location
# $ - current variable name
# ? - previous command resulted in error
# ^ - previous command
# $MaximumHistoryCount



# Look at the description and other settings of the variable
Get-Variable -Name MaximumHistoryCount | Select-Object *

# Validate Range Attribute, lets see what the min and max are
Get-Variable -Name MaximumHistoryCount | Select-Object -ExpandProperty Attributes

# Change the variable
$MaximumHistoryCount = 1000

# Reset the variable
$MaximumHistoryCount = 4096

# Since we have a start and end time, we can calculate the execution time
# Boe Prox has written a function called Get-History2 which displays in this same format
# https://gallery.technet.microsoft.com/scriptcenter/Get-History2-to-view-f90613a8
Get-History | Select-Object -Property  Id, CommandLine,  @{L='ExecutionTime';E={($_.EndExecutionTime-$_.StartExecutionTime)}} 

# Persisting History - MANUAL
# First we create our history directory, then we export all of our history as an XML file
# We use XML so we can keep the properties of the object, so we can use it later on.
#$HistoryPath = "$env:USERPROFILE\Documents\WindowsPowerShell\History"
$HistoryPath = "$env:HOMEDRIVE\WindowsPowerShell\History"

If (-NOT  (Test-Path $HistoryPath))  {
    $null = New-Item -Path $HistoryPath -ItemType Directory
}

Get-History | Export-Clixml -Path "$HistoryPath\History.xml"

# Persisting History - Automated
# Import our history from a previous PowerShell session. 
# Use Register-EventEngine to export our history every time that we close PowerShell
#$HistoryPath = "$env:USERPROFILE\Documents\WindowsPowerShell\History"
$HistoryPath = "$env:HOMEDRIVE\WindowsPowerShell\History"

If (Test-Path  "$HistoryPath\History.xml") {
    Add-History -InputObject (Import-Clixml  "$HistoryPath\History.xml")
} ElseIf (-NOT (Test-Path $HistoryPath)) {
    $null = New-Item -Path $HistoryPath  -ItemType Directory
}

Register-EngineEvent -SourceIdentifier powershell.exiting  -SupportEvent -Action  {  
    Get-History | Select-Object -Last 100 | Export-Clixml -Path "$HistoryPath\History.xml"
} 



# Plan out your modules cmdlets and parameter sets before you write a single line of PowerShell code
# writing the help first makes sure that you are coding to your help. 
# This ensures that your help is in sync with your code and is no longer an afterthought.
# Your help is your contract with your user

# Test Driven Development
# Anything mission critical for your business deserves tests to validate the correct configuration
# This brings you one step closer to continuous deployment/integration
# You can make safely make changes to your environment as long as the tests pass
# Examples
# Validate files/folders that need to be present
# Validate that services are installed/running and configured correctly
# Scheduled tasks are created, enabled and configured correctly