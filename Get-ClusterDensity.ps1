# This script counts the number of Virtual Machines (VMs) and
# the total number of vCPUs and vRAM within a specified vSphere Cluster,
# differentiating between powered-on and powered-off states.
# It assumes you are already connected to a vCenter Server.

# Function to get VM, vCPU, and vRAM counts and averages for a cluster
function Get-ClusterDensity {
    param (
        [Parameter(Mandatory = $true)]
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
            $poweredOnVms = $vmsInCluster | Where-Object { $_.PowerState -eq "PoweredOn" }
            $poweredOffVms = $vmsInCluster | Where-Object { $_.PowerState -eq "PoweredOff" }

            # --- VM and vCPU Calculations ---
            $totalVmCount = $vmsInCluster.Count
            $poweredOnVmCount = $poweredOnVms.Count
            $poweredOffVmCount = $poweredOffVms.Count

            $totalVcpuCount = ($vmsInCluster   | Measure-Object -Property NumCPU   -Sum).Sum
            $poweredOnVcpuCount = ($poweredOnVms | Measure-Object -Property NumCPU   -Sum).Sum
            $poweredOffVcpuCount = ($poweredOffVms | Measure-Object -Property NumCPU   -Sum).Sum

            # --- vRAM Calculations ---
            $totalVramGB = ($vmsInCluster | Measure-Object -Property MemoryGB -Sum).Sum

            # Calculate averages
            $avgVcpuPerVm   = if ($totalVmCount -gt 0)   { [math]::Round($totalVcpuCount / $totalVmCount, 2) } else { 0 }
            $avgVramPerVm   = if ($totalVmCount -gt 0)   { [math]::Round($totalVramGB / $totalVmCount, 2) } else { 0 }
            $avgVramPerVcpu = if ($totalVcpuCount -gt 0) { [math]::Round($totalVramGB / $totalVcpuCount, 2) } else { 0 }

            # --- Output the results ---
            Write-Host "----------------------------------------------------"
            Write-Host "Results for Cluster: $($cluster.Name)"
            Write-Host "----------------------------------------------------"
            Write-Host "Total Virtual Machines (VMs): $totalVmCount"
            Write-Host "Total Virtual CPUs (vCPUs): $totalVcpuCount"
            Write-Host "Total Virtual RAM (vRAM): $totalVramGB GB"
            Write-Host ""
            Write-Host "  Powered-On VMs: $poweredOnVmCount"
            Write-Host "     Total vCPUs: $poweredOnVcpuCount"
            Write-Host "     Total vRAM: $(($poweredOnVms | Measure-Object -Property MemoryGB -Sum).Sum) GB"
            Write-Host ""
            Write-Host "  Powered-Off VMs: $poweredOffVmCount"
            Write-Host "     Total vCPUs: $poweredOffVcpuCount"
            Write-Host "     Total vRAM: $(($poweredOffVms | Measure-Object -Property MemoryGB -Sum).Sum) GB"
            Write-Host ""
            Write-Host "  Average Density Metrics (based on all VMs)"
            Write-Host "  --------------------------------------------------"
            Write-Host "  Average vCPU per VM: $avgVcpuPerVm"
            Write-Host "  Average vRAM per VM: $avgVramPerVm GB"
            Write-Host "  Average vRAM per vCPU: $avgVramPerVcpu GB"
            Write-Host "----------------------------------------------------"

            # Return a detailed object for programmatic use
            return [PSCustomObject]@{
                ClusterName         = $cluster.Name
                TotalVmCount        = $totalVmCount
                TotalVcpuCount      = $totalVcpuCount
                TotalVramGB         = $totalVramGB
                PoweredOnVmCount    = $poweredOnVmCount
                PoweredOffVmCount   = $poweredOffVmCount
                PoweredOnVcpuCount  = $poweredOnVcpuCount
                PoweredOffVcpuCount = $poweredOffVcpuCount
                AvgVcpuPerVM        = $avgVcpuPerVm
                AvgVramPerVmGB      = $avgVramPerVm
                AvgVramPerVcpuGB    = $avgVramPerVcpu
            }
        }
        else {
            Write-Warning 'Cluster $ClusterName not found.'
            return $null
        }
    }
    catch {
        # safer string formatting, no nested quotes
        Write-Error ('An error occurred: {0}' -f $_.Exception.Message)
        return $null
    }
}

# Example of function usage (uncomment to run directly):
Get-ClusterDensity -ClusterName 'CUST-1001-CL01'
