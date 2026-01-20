 function Get-ClusterDensity {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ClusterName
    )

    try {
        $cluster = Get-Cluster -Name $ClusterName -ErrorAction Stop

        Write-Host "Gathering information for cluster: $($cluster.Name)..."

        $vmsInCluster = Get-VM -Location $cluster

        $poweredOnVms  = $vmsInCluster | Where-Object PowerState -eq "PoweredOn"
        $poweredOffVms = $vmsInCluster | Where-Object PowerState -eq "PoweredOff"

        # --- VM & CPU ---
        $totalVmCount        = $vmsInCluster.Count
        $poweredOnVmCount    = $poweredOnVms.Count
        $poweredOffVmCount   = $poweredOffVms.Count

        $totalVcpuCount      = ($vmsInCluster   | Measure-Object NumCPU -Sum).Sum
        $poweredOnVcpuCount  = ($poweredOnVms   | Measure-Object NumCPU -Sum).Sum
        $poweredOffVcpuCount = ($poweredOffVms  | Measure-Object NumCPU -Sum).Sum

        # --- vRAM ---
        $totalVramGB = ($vmsInCluster | Measure-Object MemoryGB -Sum).Sum

        # --- vDISK ---
        $totalVdiskGB = (
            $vmsInCluster |
            Get-HardDisk |
            Measure-Object CapacityGB -Sum
        ).Sum

        # --- Averages ---
        $avgVcpuPerVm       = if ($totalVmCount   -gt 0) { [math]::Round($totalVcpuCount / $totalVmCount, 2) } else { 0 }
        $avgVramPerVm       = if ($totalVmCount   -gt 0) { [math]::Round($totalVramGB   / $totalVmCount, 2) } else { 0 }
        $avgVramPerVcpu     = if ($totalVcpuCount -gt 0) { [math]::Round($totalVramGB   / $totalVcpuCount, 2) } else { 0 }

        $avgVdiskPerVmGB    = if ($totalVmCount   -gt 0) { [math]::Round($totalVdiskGB  / $totalVmCount, 2) } else { 0 }
        $avgVdiskPerVcpuGB  = if ($totalVcpuCount -gt 0) { [math]::Round($totalVdiskGB  / $totalVcpuCount, 2) } else { 0 }

        # --- Output ---
        Write-Host "----------------------------------------------------"
        Write-Host "Results for Cluster: $($cluster.Name)"
        Write-Host "----------------------------------------------------"
        Write-Host "Total VMs: $totalVmCount"
        Write-Host "Total vCPUs: $totalVcpuCount"
        Write-Host "Total vRAM: $totalVramGB GB"
        Write-Host "Total vDISK: $totalVdiskGB GB"
        Write-Host ""
        Write-Host "Average Density Metrics"
        Write-Host "----------------------------------------------------"
        Write-Host "Average vCPU per VM: $avgVcpuPerVm"
        Write-Host "Average vRAM per VM: $avgVramPerVm GB"
        Write-Host "Average vRAM per vCPU: $avgVramPerVcpu GB"
        Write-Host "Average vDISK per VM: $avgVdiskPerVmGB GB"
        Write-Host "Average vDISK per vCPU: $avgVdiskPerVcpuGB GB"
        Write-Host "----------------------------------------------------"

        return [PSCustomObject]@{
            ClusterName        = $cluster.Name
            TotalVmCount       = $totalVmCount
            TotalVcpuCount     = $totalVcpuCount
            TotalVramGB        = $totalVramGB
            TotalVdiskGB       = $totalVdiskGB
            AvgVcpuPerVM       = $avgVcpuPerVm
            AvgVramPerVmGB     = $avgVramPerVm
            AvgVramPerVcpuGB   = $avgVramPerVcpu
            AvgVdiskPerVmGB    = $avgVdiskPerVmGB
            AvgVdiskPerVcpuGB  = $avgVdiskPerVcpuGB
        }
    }
    catch {
        Write-Error ('An error occurred: {0}' -f $_.Exception.Message)
        return $null
    }
}


# Example of function usage (uncomment to run directly):
# Get-ClusterDensity("CLUSTER01") 
