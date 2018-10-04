# This script will set the parameter Perennially Reservations to True on RDM Luns in a cluster
#$vcenter = #"vCenter Name "
#$dCenter = #"Datacenter Name"
#$cluster = #"Cluster Name"
 
$vcenter = "vc01.home.uw.cz"
$dCenter = "LAB"
$cluster = "Cluster01"
 
#-------------------------------------------------------------------------
 
# Do not modify bellow script
#-------------------------------------------------------------------------
 
#Add-PSSnapIn VMware* -ErrorAction SilentlyContinue
 
$connected = Connect-VIServer -Server $vcenter | Out-Null
 
$clusterInfo = Get-Datacenter -Name $dCenter | get-cluster $cluster
$vmHosts = $clusterInfo | get-vmhost | select -ExpandProperty Name
$RDMNAAs = $clusterInfo | Get-VM | Get-HardDisk -DiskType "RawPhysical","RawVirtual" | Select -ExpandProperty ScsiCanonicalName -Unique
 
foreach ($vmhost in $vmHosts) {
  $myesxcli = Get-EsxCli -VMHost $vmhost
   
  foreach ($naa in $RDMNAAs) {
    $diskinfo = $myesxcli.storage.core.device.list("$naa") | Select -ExpandProperty IsPerenniallyReserved
    $vmhost + " " + $naa + " " + "IsPerenniallyReserved= " + $diskinfo
    if($diskinfo -eq "false") {
      write-host "Configuring Perennial Reservation for LUN $naa......."
      $myesxcli.storage.core.device.setconfig($false,$naa,$true)
      $diskinfo = $myesxcli.storage.core.device.list("$naa") | Select -ExpandProperty IsPerenniallyReserved
      $vmhost + " " + $naa + " " + "IsPerenniallyReserved= " + $diskinfo
    }
    write-host "----------------------------------------------------------------------------------------------"
  }
}
 
Disconnect-VIServer $vcenter -confirm:$false | Out-Null

