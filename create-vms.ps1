# PowerCLI script to create Virtual Machines
# ===========================================
# It can create new VM or deploy VM from template if template name is specified.
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
$vm_count = “5“
#
# Specify vCenter Server datastore
$Datastore = “TEST“
#
# Specify vCenter Server Virtual Machine & Templates folder
$Folder = “TEST”
#
# Specify the vSphere Cluster
$Cluster = “TEST“
#
# Specify the VM name to the left of the – sign
$VM_prefix = “XTEST-“
#
# Specify the VM provisioning type (sync/async) - true = async (parallel), false = sync (sequentional)
$VM_create_async = $false
#
# Specify if VM should be created from template
$VM_from_template="TEST_template"
#
# Specify if VM should be Power On 
$VM_power_on = $false
#
# Parameters below are used only for new VM. 
# VM created from template has these parameters included in the template.
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

#$O_cluster=Get-Cluster $Cluster

1..$vm_count | foreach {
  $VM_postfix=”{0:D2}” -f $_
  $VM_name= $VM_prefix + $VM_postfix
  #$O_ESXi=Get-Cluster $Cluster_name | Get-VMHost -state connected | Get-Random

  if ($VM_from_template -eq "") {
    write-host “Creation of VM $VM_name initiated”  -foreground green
    New-VM -RunAsync:$VM_create_async -Name $VM_Name -ResourcePool $Cluster -numcpu $numcpu -MemoryMB $MBram -DiskMB $MBguestdisk -DiskStorageFormat $Typeguestdisk -Datastore $Datastore -GuestId $guestOS -Location $Folder
  } else {
    write-host “Deployment of VM $VM_name from template $VM_from_template initiated”  -foreground green
    New-VM -RunAsync:$VM_create_async -Name $VM_Name -Template $VM_from_template -ResourcePool $Cluster -Datastore $Datastore -Location $Folder
  }

  if ($VM_power_on) {
    write-host “Power On of the  VM $VM_name initiated" -foreground green
    Start-VM -VM $VM_name -confirm:$false -RunAsync
  }
}