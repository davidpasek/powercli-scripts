cls

#import vmware modules
Import-module VMware.VimAutomation.Core
Import-module VMware.VimAutomation.Vds
Import-module VMware.VimAutomation.Cloud
Import-module VMware.VimAutomation.PCloud
Import-module VMware.VimAutomation.Cis.Core
Import-module VMware.VimAutomation.Storage
Import-module VMware.VimAutomation.HorizonView
Import-module VMware.VimAutomation.HA
Import-module VMware.VimAutomation.vROps
Import-module VMware.VumAutomation
Import-module VMware.DeployAutomation
Import-module VMware.ImageBuilder
Import-module VMware.VimAutomation.License

# define new property to be used in the reports
New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.ToolsVersion' -Force
New-VIProperty -Name ToolsVersionStatus -ObjectType VirtualMachine -ValueFromExtensionProperty 'Guest.ToolsVersionStatus'-Force

cls
$vCenter = Read-Host "Please enter name or IP address of the source vCenter Server"
connect-viserver $vCenter

Write-Host "please select file from wich you want to read list of VMs to be upgraded" -ForegroundColor Yellow -BackgroundColor Black

Function Get-OpenFile($initialDirectory)
{ 
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
Out-Null

$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.filter = "Text files (*.txt)|*.txt"
$OpenFileDialog.ShowDialog() | Out-Null
$OpenFileDialog.filename
$OpenFileDialog.ShowHelp = $true
}

$InputFile = Get-OpenFile
$MyVMs = Get-Content $InputFile

# nebo mozno zadat cestu k souboru
# $MyVMs = get-content C:\PS\MK\A2_NHQ.txt

# Attach baselines
Get-Baseline -server $vCenter -Name "VMware Tools Upgrade to Match Host (Predefined)" | Attach-Baseline -Entity $MyVMs
Get-Baseline -server $vCenter -Name "VM Hardware Upgrade to Match Host (Predefined)" | Attach-Baseline -Entity $MyVMs

# Scan
Scan-Inventory -Entity $MyVMs

cls
# Report before upgrade
Write-Host "VMware Tools and VM HW report before upgrade" -ForegroundColor Yellow -BackgroundColor Black
Get-VM  $MyVMs | select Name, Version, ToolsVersion, ToolsVersionStatus |ft -AutoSize

Write-host "VMware Tools and VM Hardware will be upgraded on following VMs "$MyVMs -ForegroundColor yellow -BackgroundColor Black -Separator ","

# upgrade VM Tools
$VMTools = Get-Baseline -server $vCenter -Name "VMware Tools Upgrade to Match Host (Predefined)"
foreach ($VM in $MyVMs){Update-Entity -server $vCenter -Baseline $VMTools -Entity $VM}

# upgrade VM HW
$VMHW = Get-Baseline -server $vCenter -Name "VM Hardware Upgrade to Match Host (Predefined)"
#se snapshotem
foreach ($VM in $MyVMs){Update-Entity -server $vCenter -Baseline $VMHW -Entity $VM -GuestCreateSnapshot:$true -GuestKeepSnapshotHours 24 -GuestSnapshotName BeforeHWUpgrade}
#bez snapshotu
#foreach ($VM in $MyVMs){Update-Entity -server $vCenter -Baseline $VMHW -Entity $VM}

# Report after upgrade
Write-Host "VMware Tools and VM HW report after upgrade" -ForegroundColor Green -BackgroundColor Black
Get-VM  $MyVMs | select Name, Version, ToolsVersion, ToolsVersionStatus |ft -AutoSize