# Count VMs with custom attribute "Last Backup"
Get-VM | Select-Object Name, @{N='LastBackup';E={($_.CustomFields | Where-Object {$_.Key -match "Last Backup"}).Value}} | Where-Object {$_.LastBackup -ne $null -and $_.LastBackup -ne ""} | Measure-Object | Select-Object Count
