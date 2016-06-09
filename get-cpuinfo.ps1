# Get-CPUInfo.ps1 
# Code produced by Juan Manuel Rey (@jreypo) 
# 
 
$strComputer = "." 
$colItems = Get-WmiObject -class "Win32_Processor" -namespace "root/CIMV2" -computername $strComputer 
 
foreach ($objItem in $colItems) { 
    Write-Host 
    Write-Host "CPU ID: " -foregroundcolor yellow -NoNewLine 
    Write-Host $objItem.DeviceID -foregroundcolor white 
    Write-Host "CPU Model: " -foregroundcolor yellow -NoNewLine 
    Write-Host $objItem.Name -foregroundcolor white 
    Write-Host "CPU Cores: " -foregroundcolor yellow -NoNewLine 
    Write-Host $objItem.NumberOfCores -foregroundcolor white 
    Write-Host "CPU Max Speed: " -foregroundcolor yellow -NoNewLine 
    Write-Host $objItem.MaxClockSpeed 
    Write-Host "CPU Status: " -foregroundcolor yellow -NoNewLine 
    Write-Host $objItem.Status 
    Write-Host 
}