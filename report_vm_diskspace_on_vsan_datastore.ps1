# Specify the vSAN Datastore Name
$vSAN_DatastoreName = "CUST-1001-VSAN"

# Initialize total provisioned space
$totalProvisionedGB = 0

try {
    # Get the vSAN datastore object
    $vSANDatastore = Get-Datastore -Name $vSAN_DatastoreName -ErrorAction Stop

    Write-Host "Searching for VMs on vSAN datastore: $($vSANDatastore.Name)..."

    # Get all VMs on the specified vSAN datastore
    $vmsOnvSAN = Get-VM | Where-Object { $_.DatastoreIdList -contains $vSANDatastore.Id }

    if ($vmsOnvSAN.Count -eq 0) {
        Write-Warning "No VMs found on datastore '$vSAN_DatastoreName'."
    } else {
        # Loop through each VM and sum their provisioned space
        foreach ($vm in $vmsOnvSAN) {
            $provisionedGB = [math]::Round(($vm.ProvisionedSpaceGB), 2)
            $totalProvisionedGB += $provisionedGB
            Write-Host "VM: $($vm.Name) - Provisioned Space: $($provisionedGB) GB"
        }

        Write-Host "----------------------------------------------------"
        Write-Host "Total Provisioned Space on '$($vSANDatastore.Name)': $([math]::Round($totalProvisionedGB, 2)) GB"
        Write-Host "----------------------------------------------------"
    }

}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Error "Datastore '$vSAN_DatastoreName' not found. Please check the name and try again."
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
