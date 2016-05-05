# The script will calculate the ESXi host CPU core to VM vCPU oversubscription and create a HTML report
#
# Version 1.0 Magnus Andersson RTS
#————————————————
# Start of script parameters section
#
# vCenter Server configuration
$vcenter = “vc01.home.uw.cz“
$vcenteruser = “readonly“
$vcenterpw = “readonly“
$loginsight = "192.168.4.51"
#
# End of script parameter section
#—————————————— #

$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
#
# Connect to vCenter Server
$vc = connect-viserver $vcenter -User $vcenteruser -Password $vcenterpw
#

#cls

# Send Message to LogInsight
function Send-LogInsightMessage ([string]$ip, [string]$message)
{
  $uri = "http://" + $ip + ":9000/api/v1/messages/ingest/1"
  $content_type = "application/json"
  $body = '{"messages":[{"text":"'+ $message +' "}]}'
  $r = Invoke-RestMethod -Uri $uri -ContentType $content_type -Method Post -Body $body
}

foreach ($esx in (Get-VMHost | Sort-Object Name)) {
  $pCPUs = $esx.NumCpu
  $vCPUs = ($esx | get-vm | Measure-Object -Sum NumCPU).Sum
  $CPU_ratio = $vCPUs / $pCPUs
  $date = (Get-Date).ToUniversalTime()
  $cluster_name = get-cluster -VMHost $esx

  $message = "UTC date time: $date Cluster: $cluster_name ESX name: $esx.Name pCPUs: $pCPUs vCPUs: $vCPUs vCPU/pCPU ratio: $CPU_ratio"
  Write-Output $message
  Send-LogInsightMessage $loginsight $message
}

disconnect-viserver -Server $vc -Force -Confirm:$false
