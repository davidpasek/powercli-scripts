# Set IOPS Limit
$VMNAME = "VM-CUST-0001-192-168-2-12"
$IOPSLimit = 500
$vm = Get-VM -Name $VMNAME
$harddisk = $vm | Get-Harddisk -Name "Hard disk 1"
Get-VMResourceConfiguration -VM $vm | Set-VMResourceConfiguration -Disk $harddisk -DiskLimitIOPerSecond $IOPSLimit
