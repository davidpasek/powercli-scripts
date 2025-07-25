# Specify the Datastore Name
$DatastoreName = "CUST-1001-VSAN"

# Initialize total provisioned and used space
$totalProvisionedGB = 0
$totalUsedGB = 0

try {
    # Get the datastore object
    $Datastore = Get-Datastore -Name $DatastoreName -ErrorAction Stop

    Write-Host "Searching for VMs on datastore: $($Datastore.Name)..."

    # Get all VMs on the specified datastore
    $vmsOnvSAN = Get-VM | Where-Object { $_.DatastoreIdList -contains $Datastore.Id }

    if ($vmsOnvSAN.Count -eq 0) {
        Write-Warning "No VMs found on datastore '$DatastoreName'."
    } else {
        # Loop through each VM and sum their provisioned and used space
        foreach ($vm in $vmsOnvSAN) {
            $provisionedGB = [math]::Round(($vm.ProvisionedSpaceGB), 2)
            $usedGB = [math]::Round(($vm.UsedSpaceGB), 2) # Get the used space

            $totalProvisionedGB += $provisionedGB
            $totalUsedGB += $usedGB # Add to total used space

            Write-Host "VM: $($vm.Name) - Provisioned Space: $($provisionedGB) GB, Used Space: $($usedGB) GB"
        }

        Write-Host "----------------------------------------------------"
        Write-Host "Total Provisioned Space on '$($Datastore.Name)': $([math]::Round($totalProvisionedGB, 2)) GB"
        Write-Host "Total Used Space on '$($Datastore.Name)': $([math]::Round($totalUsedGB, 2)) GB"
        Write-Host "----------------------------------------------------"
    }

}
catch [System.Management.Automation.ItemNotFoundException] {
    Write-Error "Datastore '$DatastoreName' not found. Please check the name and try again."
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}
