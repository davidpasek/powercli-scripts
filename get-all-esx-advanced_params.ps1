# Array of advanced params
$adv_params = "VMkernel.Boot.hyperthreadingMitigation", "VMkernel.Boot.hyperthreadingMitigationIntraVM"

# Initialize an empty array to store results
$results = @()

foreach ($esx in Get-VMHost) {
    Write-Host "Gathering info for $($esx.Name)" -ForegroundColor Green

    # Create a custom object for the current ESXi host's settings
    # Initialize it with the host's name
    $hostSettings = [PSCustomObject]@{
        VMHost = $esx.Name
    }

    foreach ($adv_param in $adv_params) {
        # Get the advanced setting value, suppressing errors if not found
        $adv_param_value = $esx | Get-AdvancedSetting -Name $adv_param -ErrorAction SilentlyContinue

        # Determine the property name (using the full parameter name)
        $propertyName = $adv_param

        # Get the value, or null if the setting wasn't found
        $propertyValue = $null
        if ($adv_param_value) {
            $propertyValue = $adv_param_value.Value
        }

        # Add the property to the custom object
        $hostSettings | Add-Member -MemberType NoteProperty -Name $propertyName -Value $propertyValue
    }

    # Add the completed hostSettings object to the results array
    $results += $hostSettings
}

# $results is array of objects (PSCustomObject)

# Output the results in a tabular format directly to the console
# Use -AutoSize to make columns fit their content
$results | Format-Table -AutoSize
