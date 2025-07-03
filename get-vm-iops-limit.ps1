# Get VM IOPS Limit
$VMNAME = "VM-CUST-0001-192-168-2-12"
$vm = Get-VM -Name $VMNAME
$vm | Get-VMResourceConfiguration -PipelineVariable vm | Select -ExpandProperty DiskResourceConfiguration | Select @{N='VM';E={$vm.VM.Name}},Key,DiskLimitIOPerSecond
