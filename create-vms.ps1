# PowerCLI script to create 5 VMs
#
#————————————————
# Start of script parameters section
#
# vCenter Server configuration
$vcenter = “vc01.home.uw.cz“
$vcenteruser = “readwrite“
$vcenterpw = “readwrite“
#
# Specify number of VMs you want to create
$vm_count = “50“
#
# Specify number of VM CPUs
$numcpu = “1“
#
# Specify number of VM MB RAM
$MBram = “512“
#
# Specify VM disk size (in MB)
$MBguestdisk = “1000“
#
# Specify VM disk type, available options are Thin, Thick, EagerZeroedThick
$Typeguestdisk =”Thick“
#
# Specify VM guest OS
$guestOS = “winNetStandardGuest“
#
# Specify vCenter Server datastore
$ds = “TEST“
#
# Specify vCenter Server Virtual Machine & Templates folder
$Folder = “TEST”
#
# Specify the vSphere Cluster
$Cluster = “TEST“
#
# Specify the VM name to the left of the – sign
$VM_prefix = “TEST-“
#
# Specify the VM provisioning type (sync/async) - true = async (parallel), false = sync (sequentional)
$VM_create_async = $true
#
# Specify if VM should be Power On 
$VM_power_on = $false
#
# End of script parameter section
#—————————————— #

clear-host

$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
#
# Connect to vCenter Server
write-host “Connecting to vCenter Server $vcenter” -foreground green
$vc = connect-viserver $vcenter -User $vcenteruser -Password $vcenterpw
#

1..$vm_count | foreach {
  $VM_postfix=”{0:D2}” -f $_
  $VM_name= $VM_prefix + $VM_postfix
  $ESXi=Get-Cluster $Cluster | Get-VMHost -state connected | Get-Random

  write-host “Creation of VM $VM_name initiated”  -foreground green
  New-VM -RunAsync:$VM_create_async -Name $VM_Name -VMHost $ESXi -numcpu $numcpu -MemoryMB $MBram -DiskMB $MBguestdisk -DiskStorageFormat $Typeguestdisk -Datastore $ds -GuestId $guestOS -Location $Folder

  if ($VM_power_on) {
    write-host “Power On of the  VM $VM_name initiated" -foreground green
    Start-VM -VM $VM_name -confirm:$false -RunAsync
  }
}