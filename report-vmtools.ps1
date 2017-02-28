######################################################################################################################################
# Author: David Pasek
# E-mail: david.pasek@gmail.com
# Twitter: david_pasek
# Creation Date: 2016-11-25
#
# Use case:
#   Key use case of this script is to report VMtools from all VMs in vCenter
#
# Disclaimer:
#   Use it on your own risk. Author is not responsible for any impacts caused by this script. 
######################################################################################################################################
# 
# CHANGE FOLLOWING VARIABLES BASED ON YOUR SPECIFIC REQUIREMENTS  
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
# Report type - table, grid, file, csv-file
  $REPORT_TYPE =  "grid"
# Report file name without file extension. Extension is automatically added. File is created in current working directory. 
  $REPORT_FILE_NAME = "report-vmtools"
######################################################################################################################################


Clear-Host

# We need VMware PowerCLI snapin
$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Connect to vCenter
Write-Host "Connecting to vCenter ..."
$VC = Read-Host "Enter one vCentre Server or multiple vCenter servers delimted by comma."
Write-Host "Enter vCenter credentials ..."
$CRED = Get-Credential
Connect-VIServer -Server $VC -Credential $CRED -ErrorAction Stop | Out-Null

# Add new property (ToolsVersion) to VM
New-VIProperty -Name ToolsVersion -ObjectType VirtualMachine -ValueFromExtensionProperty 'Config.tools.ToolsVersion' -Force | Out-Null

# Initalize report
$Report = @()
foreach ($vm in Get-VM) {
  # Numbers mapping is from https://packages.vmware.com/tools/versions
  Switch ($vm.ToolsVersion) {
	7302  {$GuestToolsVersion = "7.4.6"}
	7303  {$GuestToolsVersion = "7.4.7"}
    7304  {$GuestToolsVersion = "7.4.8"}
    8192  {$GuestToolsVersion = "8.0.0"}
    8194  {$GuestToolsVersion = "8.0.2"}
    8195  {$GuestToolsVersion = "8.0.3"}
    8196  {$GuestToolsVersion = "8.0.4"}
    8197  {$GuestToolsVersion = "8.0.5"}
    8198  {$GuestToolsVersion = "8.0.6"}
    8199  {$GuestToolsVersion = "8.0.7"}
    8290  {$GuestToolsVersion = "8.3.2"}
    8295  {$GuestToolsVersion = "8.3.7"}
    8300  {$GuestToolsVersion = "8.3.12"}
    8305  {$GuestToolsVersion = "8.3.17"}
    8306  {$GuestToolsVersion = "8.3.18"}
    8307  {$GuestToolsVersion = "8.3.19"}
    8384  {$GuestToolsVersion = "8.6.0"}
    8389  {$GuestToolsVersion = "8.6.5"}
    8394  {$GuestToolsVersion = "8.6.10"}
    8395  {$GuestToolsVersion = "8.6.11"}
    8396  {$GuestToolsVersion = "8.6.12"}
    8397  {$GuestToolsVersion = "8.6.13"}
    8398  {$GuestToolsVersion = "8.6.14"}
    8399  {$GuestToolsVersion = "8.6.15"}
    8400  {$GuestToolsVersion = "8.6.16"}
    8401  {$GuestToolsVersion = "8.6.17"}
    9216  {$GuestToolsVersion = "9.0.0"}
    9217  {$GuestToolsVersion = "9.0.1"}
    9221  {$GuestToolsVersion = "9.0.5"}
    9226  {$GuestToolsVersion = "9.0.10"}
    9227  {$GuestToolsVersion = "9.0.11"}
    9228  {$GuestToolsVersion = "9.0.12"}
    9229  {$GuestToolsVersion = "9.0.13"}
    9231  {$GuestToolsVersion = "9.0.15"}
    9232  {$GuestToolsVersion = "9.0.16"}
    9233  {$GuestToolsVersion = "9.0.17"}
    9344  {$GuestToolsVersion = "9.4.0"}
    9349  {$GuestToolsVersion = "9.4.5"}
    9350  {$GuestToolsVersion = "9.4.6"}
    9354  {$GuestToolsVersion = "9.4.10"}
    9355  {$GuestToolsVersion = "9.4.11"}
    9356  {$GuestToolsVersion = "9.4.12"}
    9359  {$GuestToolsVersion = "9.4.15"}
    9536  {$GuestToolsVersion = "9.10.0"}
    9537  {$GuestToolsVersion = "9.10.1"}
    9541  {$GuestToolsVersion = "9.10.5"}
    10240 {$GuestToolsVersion = "10.0.0"}
    10245 {$GuestToolsVersion = "10.0.5"}
    10246 {$GuestToolsVersion = "10.0.6"}
    10247 {$GuestToolsVersion = "10.0.8"}
    10249 {$GuestToolsVersion = "10.0.9"}
    10252 {$GuestToolsVersion = "10.0.12"}
    10272 {$GuestToolsVersion = "10.1.0"}
    0     {$GuestToolsVersion = "Not installed"}
    2147483647 {$GuestToolsVersion = "3rd party - guest managed"}
	default {$GuestToolsVersion = "Unknown"}
	}

  $vminfo = New-Object -Type PSObject -Property @{
   		Name = $vm.Name
        VMhardwareVersion = $vm.Version
		ToolsVersion = $vm.ToolsVersion
		GuestToolsVersion = $GuestToolsVersion
	}

  $Report += $vminfo
}

# Show report
Switch ($REPORT_TYPE) {
	"grid"     { $Report | select Name,VMhardwareVersion,ToolsVersion,GuestToolsVersion | Out-GridView }
    "file"     { $Report | select Name,VMhardwareVersion,ToolsVersion,GuestToolsVersion | Out-File -FilePath "$REPORT_FILE_NAME.txt" }
    "csv-file" { $Report | select Name,VMhardwareVersion,ToolsVersion,GuestToolsVersion | export-csv "$REPORT_FILE_NAME.csv" }
    default    { $Report | select Name,VMhardwareVersion,ToolsVersion,GuestToolsVersion | Format-Table }
}

Disconnect-VIserver -Server $VC -Force -Confirm:$false
