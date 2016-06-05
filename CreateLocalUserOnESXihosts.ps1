# The script will add local user to all ESXi hosts in vCenter
#————————————————
# Start of script parameters section
#
$account_action = "c"   # actions can be - c=create, r=remove
$account_name = "secaudit"
$account_password = "VMware1!..QASDF123"
$account_description = "New temporary user for security audit"

$role_name = "ReadOnly"

$vcenter_hostname = "vc01.home.uw.cz"
#
# End of script par

$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

Clear-Host

# Ask if it will be create or remove action
do {
  write-host "What action do you want to perform? Available options: c=create, r=remove, q=quit" -BackgroundColor Yellow -ForegroundColor black
  $choice = Read-Host -Prompt "Enter your choice: [c,r,q]"
  write-host "Your choice is $choice"
  if ($choice -eq "q") {
    write-host "Quit script"
    exit
  }
} until ( ($choice -eq "c") -or ($choice -eq "r") )

$account_action = $choice;

# Connect to vCenter
Write-Host "Connecting to vCenter ..."
$CRED_VC = Get-Credential -Message "Enter vCenter credentials ..."
$CRED_ESX = Get-Credential -Message "Enter ESXi host credentials ..."

$VIServer_VC = Connect-VIServer -Server $vcenter_hostname -Credential $CRED_VC -ErrorAction Stop

# Perform action for each ESXi managed by vCenter
foreach ($esx in (Get-VMHost | Sort-Object Name)) {
  # Connect to particular ESXi host
  $VIServer_ESX = Connect-VIServer -Server $esx.Name -Credential $CRED_ESX

  if ($account_action -eq "c") {
    # Create new local user
    Write-host "Creating new local user on ESX host:" $esx.Name;
    New-VMHostAccount -Server $VIServer_ESX -Id $account_name -Password $account_password -Description $account_description

    # Add permission
    $role = Get-VIRole -Server $VIServer_ESX -Name $role_name
    $x = New-VIPermission -Server $VIServer_ESX -Entity $esx.name -Principal $account_name -Role $role -Propagate:$true
  }

  if ($account_action -eq "r") {
    # Remove new local user
    Write-host "Removing local user from ESX host:" $esx.Name;
    $host_account = Get-VMHostAccount -Server $VIServer_ESX -Id $account_name
    Remove-VMHostAccount -Server $VIServer_ESX -HostAccount $host_account -Confirm:$false
  }

  # Disconnect from particular ESXi host
  Disconnect-VIserver -Server $VIServer_ESX -Force -Confirm:$false
}


Disconnect-VIserver -Server $VIServer_VC -Force -Confirm:$false