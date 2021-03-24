#Enter your vCenter Host below
$vcenter = "vc01.home.uw.cz"
#Enter the CSV file to be created
$csvfile = "c:\tmp\VM_creation_date.CSV"
################################
 
#Load the VMware Powershell snapin if the script is being executed in PowerShell
Add-PSSnapin VMware.VimAutomation.Core -ErrorAction 'SilentlyContinue'
 
#Connect to the vCenter server defined above. Ignore certificate errors
Write-Host "Connecting to vCenter"
Connect-VIServer $vcenter -wa 0
Write-Host "Connected"
Write-Host ""
 
#Check to see if the file exists, if it does then overwrite it.
if (Test-Path $csvfile) {
Write-Host "Overwriting $csvfile"
del $csvfile
}
 
#Create the CSV title header
Add-Content $csvfile "VM,Born on,Creator,Creation Type,Event Message"
 
#Gather all VM's from vCenter
$vms = Get-VM | sort Name
 
foreach ($VM in $vms) {
Write-Host "Gathering info for $VM"
 
#Search for events where the VM was deployed from a template
$vmevents = Get-VIEvent $VM -Start (Get-Date).AddHours(-1) -MaxSamples([int]::MaxValue) | Where-Object {$_.FullFormattedMessage -like "Deploying*"} |Select CreatedTime, UserName, FullFormattedMessage
if ($vmevents)
{
$type = "From Template"
}
 
#If no events were found, search for events where the VM was created from scratch
if (!$vmevents) {
$vmevents = Get-VIEvent $VM -Start (Get-Date).AddHours(-1) -MaxSamples([int]::MaxValue) | Where-Object {$_.FullFormattedMessage -like "Created*"} |Select CreatedTime, UserName, FullFormattedMessage
Write-Host "Searching by Created"
$type = "From Scratch"
}
 
#If no events were found, search for events where the VM was cloned
if (!$vmevents) {
$vmevents = Get-VIEvent $VM -Start (Get-Date).AddHours(-1) -MaxSamples([int]::MaxValue) | Where-Object {$_.FullFormattedMessage -like "Clone*"} |Select CreatedTime, UserName, FullFormattedMessage
Write-Host "Searching by Cloned"
$type = "Cloned"
}
 
#If no events were found, search for events where the VM was discovered
if (!$vmevents) {
$vmevents = Get-VIEvent $VM -Start (Get-Date).AddHours(-1) -MaxSamples([int]::MaxValue) | Where-Object {$_.FullFormattedMessage -like "Discovered*"} |Select CreatedTime, UserName, FullFormattedMessage
Write-Host "Searching by Discovered"
$type = "Discovered"
}
 
#If no events were found, search for events where the VM was connected (typically from Backup Restores)
if (!$vmevents) {
$vmevents = Get-VIEvent $VM -Start (Get-Date).AddHours(-1) -MaxSamples([int]::MaxValue) | Where-Object {$_.FullFormattedMessage -like "* connected"} |Select CreatedTime, UserName, FullFormattedMessage
Write-Host "Searching by Connected"
$type = "Connected"
}
 
#I have no idea how this VM came to be.
if (!$vmevents) {
Write-Host "No clue how this VM got here!"
$type = "Immaculate Conception"
}
 
#In some cases there may be more than one event found (typically from VM restores). This will include each event in the CSV for the user to interpret.
foreach ($event in $vmevents) {
 
#Prepare the entries
$birthday = $event.CreatedTime.ToString("MM/dd/yy")
$parent = $event.Username
$message = $event.FullFormattedMessage
 
#Add the entries to the CSV
$write = "$VM, $birthday, $parent, $type, $message"
Add-Content $csvfile $write
}
}
