# --- Configuration Parameters ---
$DVSName = "dvSwitch-PRG03T0-VPC" # Replace with the name of your Distributed Virtual Switch
$DVPortGroupName = "DP-438" # Replace with the name of the Distributed Port Group

# MAC Learning settings
$MacLearningEnabled = $false
$MacLearningLimit = 4096 # Maximum number of MAC addresses to learn. Default is usually sufficient.
$MacLearningLimitPolicy = "DROP" # Action to take when the limit is reached (DROP or ACCEPT)

# Other recommended security policies for nested virtualization (adjust as needed)
$ForgedTransmitsEnabled = $true
$MacChangesEnabled = $false # Typically set to false for security
$PromiscuousModeEnabled = $false # MAC Learning removes the need for promiscuous mode

# --- Script Logic ---

Write-Host "Retrieving Distributed Virtual Switch '$DVSName'..."
$vds = Get-VDSwitch -Name $DVSName
if (-not $vds) {
    Write-Error "Distributed Virtual Switch '$DVSName' not found. Exiting."
    Exit
}

Write-Host "Retrieving Distributed Port Group '$DVPortGroupName'..."
$dvPortGroup = Get-VDPortgroup -VDSwitch $vds -Name $DVPortGroupName
if (-not $dvPortGroup) {
    Write-Error "Distributed Port Group '$DVPortGroupName' not found on DVS '$DVSName'. Exiting."
    Exit
}

Write-Host "`nConfiguring MAC Address Learning and security policies for port group '$DVPortGroupName'..."

# Create a DVS config spec
$dvpgConfigSpec = New-Object VMware.Vim.DVPortgroupConfigSpec
$dvpgConfigSpec.ConfigVersion = $dvPortGroup.ExtensionData.Config.ConfigVersion

# Create a DVS port setting
$dvPortSetting = New-Object VMware.Vim.VMwareDVSPortSetting

# Create MAC Management Policy
$macManagementPolicy = New-Object VMware.Vim.DVSMacManagementPolicy
$macManagementPolicy.AllowPromiscuous = $PromiscuousModeEnabled
$macManagementPolicy.ForgedTransmits = $ForgedTransmitsEnabled
$macManagementPolicy.MacChanges = $MacChangesEnabled

# Create MAC Learning Policy
$macLearningPolicy = New-Object VMware.Vim.DVSMacLearningPolicy
$macLearningPolicy.Enabled = $MacLearningEnabled
$macLearningPolicy.Limit = $MacLearningLimit
$macLearningPolicy.LimitPolicy = $MacLearningLimitPolicy

# Assign MAC Learning Policy to MAC Management Policy
$macManagementPolicy.MacLearningPolicy = $macLearningPolicy

# Assign MAC Management Policy to the Port Setting
$dvPortSetting.MacManagementPolicy = $macManagementPolicy

# Assign the Port Setting to the DVS Port Group Config Spec
$dvpgConfigSpec.DefaultPortConfig = $dvPortSetting

# Reconfigure the Distributed Port Group
try {
    $dvPortGroup.ExtensionData.ReconfigureDVPortgroup_Task($dvpgConfigSpec)
    Write-Host "Successfully configured MAC Address Learning and security policies for '$DVPortGroupName'."
}
catch {
    Write-Error "Failed to configure MAC Address Learning for '$DVPortGroupName': $($_.Exception.Message)"
}