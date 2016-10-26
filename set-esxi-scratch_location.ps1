######################################################################################################################################
# Author: David Pasek
# E-mail: david.pasek@gmail.com
# Twitter: david_pasek
# Creation Date: 2016-10-26
#
# Use case:
#   Key use case of this script is to create directories in pre-defined datastore and redirect all ESXi scratch partitions to this particular
#   shared datastore. It is done just for ESXi hosts in pre-defined clusters.
#
# Description:
#   This script does three following actions.
#   Action 1/ creates directory "scratch/[ESXi_FQDN]" on datastore defined by name in variable $DATASTORE_NAME_FOR_SCRATCH_LOCATION
#   Action 2/ Set ESXi advanced parameter ScratchConfig.ConfiguredScratchLocation to point into particular subdirectory
#   Action 3/ Set ESXi advanced parameter Syslog.global.logDir to the default scratch location "[] /scratch/log" because
#             scratch location is already redirected to shared datastore
#   
#   All actions above are done for each ESXi host in clusters defined in variable $CLUSTER_NAMES
#
# Disclaimer:
#   Use it on your own risk. Author is not responsible for any impacts caused by this script. 
######################################################################################################################################
# 
# CHANGE FOLLOWING VARIABLES BASED ON YOUR SPECIFIC REQUIREMENTS  
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
#
# Array of vSphere Cluster names 
  $CLUSTER_NAMES =  "DEV", "PROD","TEST"
# Datastore name for scratch directories
  $DATASTORE_NAME_FOR_SCRATCH_LOCATION = "NFS-SYNOLOGY-SSD"
######################################################################################################################################

Clear-Host

# Keep old path. At the end of the script we will return working path to the old path. It is necessary before unmounting datastore.
$old_path = Get-Location

# We need VMware PowerCLI snapins
$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false

# Connect to vCenter
Write-Host "Connecting to vCenter ..."
$VC = Read-Host "Enter one vCentre Server or multiple vCenter servers delimted by comma."
Write-Host "Enter vCenter credentials ..."
$CRED = Get-Credential
Connect-VIServer -Server $VC -Credential $CRED -ErrorAction Stop | Out-Null

# Validate existence of datastore where scratch directories should be created
try {
  $DATASTORE_FOR_SCRATCH_LOCATION = get-datastore -name $DATASTORE_NAME_FOR_SCRATCH_LOCATION -ErrorAction Stop
} catch {
  Write-Warning -Message "Datastore $DATASTORE_NAME_FOR_SCRATCH_LOCATION doesn't exist and script cannot continue";
  exit
}

# Mount a datastore read/write as a PSDrive
try {
  Write-Host "Mounting datastore" $DATASTORE_FOR_SCRATCH_LOCATION.Name
  New-PSDrive -Name "mounteddatastore" -Root \ -PSProvider VimDatastore -Datastore $DATASTORE_FOR_SCRATCH_LOCATION -ErrorAction Stop  | Out-Null
} catch [VMware.VimAutomation.ViCore.Cmdlets.Provider.Exceptions.DriveException] {
  Write-Warning -Message "The specified mount name is already in use.";
} catch {
  Write-Error "Exception full name: " + $_.Exception.GetType().fullname
  exit
}

foreach ($cluster_name in $cluster_names) {
  Write-Host
  Write-Host "*****************************" -ForegroundColor Yellow -BackgroundColor Black
  Write-Host "Cluster name: [$cluster_name]" -ForegroundColor Yellow -BackgroundColor Black
  Write-Host "*****************************" -ForegroundColor Yellow -BackgroundColor Black

  try {
    $cluster = get-cluster -name $cluster_name -ErrorAction Stop
    foreach ($esx in ($cluster | Get-VMHost)) {
      Write-Host "ESXi host name: [$esx.name]" -ForegroundColor:Green -BackgroundColor:Black
      # Access the new PSDrive 
      Set-Location mounteddatastore:\
      # Create a uniquely-named directory for this particular ESXi host
      $directory_name =  "scratch/"+$esx.name
      Write-Host "Creating new directory $directory_name on datastore $DATASTORE_NAME_FOR_SCRATCH_LOCATION"
      try {
        New-Item $directory_name -ItemType directory -ErrorAction Stop | Out-Null
      } catch [Microsoft.PowerShell.Commands.WriteErrorException] {
        Write-Warning -Message "The directory already exists.";
      } catch {
        Write-Warning $_.Exception
      }
      # Check the current value of the ScratchConfig.ConfiguredScratchLocation configuration option
      $current_scratch_location = $esx | Get-AdvancedSetting -Name "ScratchConfig.ConfiguredScratchLocation"
      Write-Host "Current scratch location:" $current_scratch_location.Value
      # Set the ScratchConfig.ConfiguredScratchLocation configuration option, specifying the full path to the uniquely-named directory
      $new_scratch_location = "/vmfs/volumes/$DATASTORE_NAME_FOR_SCRATCH_LOCATION/$directory_name"
      Write-Host "New scratch location: $new_scratch_location"
      $esx | Get-AdvancedSetting -Name "ScratchConfig.ConfiguredScratchLocation" | Set-AdvancedSetting -Value $new_scratch_location -Confirm:$false

      # Check the current value of the Syslog.global.logDir configuration option
      $current_syslog_dir_location = $esx | Get-AdvancedSetting -Name "Syslog.global.logDir"
      Write-Host "Current syslog directory location:" $current_syslog_dir_location.Value
      # Set the Syslog.global.logDir configuration option, specifying the default scratch location "[] /scratch/log"
      $new_syslog_dir_location = "[] /scratch/log"
      Write-Host "New syslog directory location: $new_syslog_dir_location"
      $esx | Get-AdvancedSetting -Name "Syslog.global.logDir" | Set-AdvancedSetting -Value $new_syslog_dir_location -Confirm:$false
    }
  } catch {
    Write-Warning -Message "Cluster $cluster_name doesn't exist";
  }

}

# Unount a datastore used as a PSDrive
try {
  Write-Host "Unmounting datastore" $DATASTORE_FOR_SCRATCH_LOCATION.Name
  Set-Location -Path $old_path
  Remove-PSDrive -Name "mounteddatastore" -PSProvider VimDatastore -ErrorAction Stop
} catch {
  Write-Error "Exception full name: $_.Exception.GetType().fullname"
}

Disconnect-VIserver -Server $VC -Force -Confirm:$false
