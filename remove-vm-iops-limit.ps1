# Remove VM IOPS Limit
$VMNAME = "VM-CUST-0001-192-168-2-12"
# We remove IOPS limits by setting default IOPS Limit value -1
$IOPSLimit = -1
$vm = Get-VM -Name $VMNAME
$harddisk = $vm | Get-Harddisk -Name "Hard disk 1"
Get-VMResourceConfiguration -VM $vm | Set-VMResourceConfiguration -Disk $harddisk -DiskLimitIOPerSecond $IOPSLimit
