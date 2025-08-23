# This script counts the number of Virtual Machines (VMs) and
# the total number of vCPUs within a specified vSphere Cluster.
# It assumes you are already connected to a vCenter Server.

# Function to get VM and vCPU counts for a given cluster
function Get-ClusterDensity {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ClusterName
    )

    try {
        # Get the cluster object
        $cluster = Get-Cluster -Name $ClusterName -ErrorAction Stop

        if ($cluster) {
            Write-Host "Gathering information for cluster: $($cluster.Name)..."

            # Get all VMs within the specified cluster
            $vmsInCluster = Get-VM -Location $cluster

            # Count the total number of VMs
            $vmCount = $vmsInCluster.Count

            # Calculate the total vCPU count by summing the NumCPU property of each VM
            $vcpuCount = ($vmsInCluster | Measure-Object -Property NumCPU -Sum).Sum

            # Output the results
            Write-Host "----------------------------------------------------"
            Write-Host "Results for Cluster: $($cluster.Name)"
            Write-Host "----------------------------------------------------"
            Write-Host "Total Virtual Machines (VMs): $vmCount"
            Write-Host "Total Virtual CPUs (vCPUs): $vcpuCount"
            Write-Host "----------------------------------------------------"

            # You can also return these as an object if you want to use them programmatically
            return [PSCustomObject]@{
                ClusterName = $cluster.Name
                VmCount     = $vmCount
                vCpuCount   = $vcpuCount
            }
        } else {
            Write-Warning "Cluster '$ClusterName' not found."
            return $null
        }
    }
    catch {
        Write-Error "An error occurred: $($_.Exception.Message)"
        return $null
    }
}

# --- How to Use ---
# 1. Connect to your vCenter Server using Connect-VIServer.
#    Example: Connect-VIServer -Server "your_vcenter_ip_or_hostname" -User "your_username" -Password "your_password"
# 2. Call the function with your desired cluster name.
#    Example: Get-ClusterDensity -ClusterName "MyProductionCluster"

# Example usage (uncomment and replace with your cluster name after connecting to vCenter):
# Get-ClusterDensity -ClusterName "YourClusterNameHere"
