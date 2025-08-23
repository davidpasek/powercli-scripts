# This script counts the number of Virtual Machines (VMs) and
# the total number of vCPUs within a specified vSphere Cluster,
# differentiating between powered-on and powered-off states.
# It assumes you are already connected to a vCenter Server.

# Function to get VM and vCPU counts for a given cluster, including power state breakdown
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

            # Filter VMs by power state
            $poweredOnVms = $vmsInCluster | Where-Object {$_.PowerState -eq "PoweredOn"}
            $poweredOffVms = $vmsInCluster | Where-Object {$_.PowerState -eq "PoweredOff"}

            # Count VMs for each state
            $poweredOnVmCount = $poweredOnVms.Count
            $poweredOffVmCount = $poweredOffVms.Count

            # Calculate total vCPUs for each state
            $poweredOnVcpuCount = ($poweredOnVms | Measure-Object -Property NumCPU -Sum).Sum
            $poweredOffVcpuCount = ($poweredOffVms | Measure-Object -Property NumCPU -Sum).Sum

            # Output the results
            Write-Host "----------------------------------------------------"
            Write-Host "Results for Cluster: $($cluster.Name)"
            Write-Host "----------------------------------------------------"
            Write-Host "Total Virtual Machines (VMs): $($vmsInCluster.Count)"
            Write-Host ""
            Write-Host "  ✅ Powered-On VMs: $poweredOnVmCount"
            Write-Host "     Total vCPUs: $poweredOnVcpuCount"
            Write-Host ""
            Write-Host "  🚫 Powered-Off VMs: $poweredOffVmCount"
            Write-Host "     Total vCPUs: $poweredOffVcpuCount"
            Write-Host "----------------------------------------------------"

            # Return a detailed object for programmatic use
            return [PSCustomObject]@{
                ClusterName             = $cluster.Name
                TotalVmCount            = $vmsInCluster.Count
                PoweredOnVmCount        = $poweredOnVmCount
                PoweredOffVmCount       = $poweredOffVmCount
                PoweredOnVcpuCount      = $poweredOnVcpuCount
                PoweredOffVcpuCount     = $poweredOffVcpuCount
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
