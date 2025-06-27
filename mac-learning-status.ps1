# --- Configuration Parameters ---
$DVSName = "dvSwitch-PRG03T0-VPC" # Replace with the name of your Distributed Virtual Switch
$DVPortGroupName = "DP-438" # Replace with the name of the Distributed Port Group

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

Write-Host "Current MAC Learning and Security Policies for '$DVPortGroupName':"
$currentDVPortgroupConfig = $dvPortGroup.ExtensionData.Config
$defaultPortConfig = $currentDVPortgroupConfig.DefaultPortConfig
$currentMacManagementPolicy = $currentDVPortgroupConfig.DefaultPortConfig.MacManagementPolicy

# --- Show Promiscuous Mode Policy ---
if ($defaultPortConfig -ne $null -and $defaultPortConfig.AllowPromiscuous -ne $null) {
    Write-Host "  Promiscuous Mode: $($defaultPortConfig.AllowPromiscuous.Value)"
} elseif ($defaultPortConfig -ne $null) {
    # This case handles when DefaultPortConfig exists, but AllowPromiscuous is not explicitly set
    # It means it's inheriting its setting, likely from the DVS default.
    # To get the inherited value, you'd typically need to look at the DVS's default policies
    # or the effective policy if available, but for a simple status check, this is sufficient.
    Write-Host "  Promiscuous Mode: Not explicitly set for this port group (inheriting from DVS/parent)."
} else {
    Write-Host "  No DefaultPortConfig found for this port group."
}

# --- Show MAC Management Policy ---
if ($currentMacManagementPolicy) {
    Write-Host "  MAC Learning Enabled: $($currentMacManagementPolicy.MacLearningPolicy.Enabled)"
    Write-Host "  MAC Learning Limit: $($currentMacManagementPolicy.MacLearningPolicy.Limit)"
    Write-Host "  MAC Learning Limit Policy: $($currentMacManagementPolicy.MacLearningPolicy.LimitPolicy)"
    Write-Host "  Forged Transmits: $($currentMacManagementPolicy.ForgedTransmits)"
    Write-Host "  MAC Address Changes: $($currentMacManagementPolicy.MacChanges)"
} else {
    Write-Host "  No specific MAC Management Policy configured for this port group (inheriting from DVS default)."
}

