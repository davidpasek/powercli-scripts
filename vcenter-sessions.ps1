Function Get-ViSession {
<#
.SYNOPSIS
Lists vCenter Sessions.

.DESCRIPTION
Lists all connected vCenter Sessions.

.EXAMPLE
PS C:\> Get-VISession

.EXAMPLE
PS C:\> Get-VISession | Where { $_.IdleMinutes -gt 5 }
#>
$SessionMgr = Get-View $DefaultViserver.ExtensionData.Client.ServiceContent.SessionManager
$AllSessions = @()
$SessionMgr.SessionList | Foreach {
$Session = New-Object -TypeName PSObject -Property @{
Key = $_.Key
UserName = $_.UserName
FullName = $_.FullName
LoginTime = ($_.LoginTime).ToLocalTime()
LastActiveTime = ($_.LastActiveTime).ToLocalTime()

}
If ($_.Key -eq $SessionMgr.CurrentSession.Key) {
$Session | Add-Member -MemberType NoteProperty -Name Status -Value “Current Session”
} Else {
$Session | Add-Member -MemberType NoteProperty -Name Status -Value “Idle”
}
$Session | Add-Member -MemberType NoteProperty -Name IdleMinutes -Value ([Math]::Round(((Get-Date) – ($_.LastActiveTime).ToLocalTime()).TotalMinutes))
$AllSessions += $Session
}
$AllSessions
}

Function Disconnect-ViSession {
<#
.SYNOPSIS
Disconnects a connected vCenter Session.

.DESCRIPTION
Disconnects a open connected vCenter Session.

.PARAMETER  SessionList
A session or a list of sessions to disconnect.

.EXAMPLE
PS C:\> Get-VISession | Where { $_.IdleMinutes -gt 5 } | Disconnect-ViSession

.EXAMPLE
PS C:\> Get-VISession | Where { $_.Username -eq “User19” } | Disconnect-ViSession
#>
[CmdletBinding()]
Param (
[Parameter(ValueFromPipeline=$true)]
$SessionList
)
Process {
$SessionMgr = Get-View $DefaultViserver.ExtensionData.Client.ServiceContent.SessionManager
$SessionList | Foreach {
Write “Disconnecting Session for $($_.Username) which has been active since $($_.LoginTime)”
$SessionMgr.TerminateSession($_.Key)
}
}
}

Clear-Host

# We need VMware PowerCLI snapin
$o = Add-PSSnapin VMware.VimAutomation.Core

# Enter vCenter server and credetials
Write-Host "vCenter information ..."
$VC = Read-Host "Enter one vCentre Server or multiple vCenter servers delimted by comma."
Write-Host "Enter vCenter credentials ..."
$CRED = Get-Credential


for($i=1; $i -le 500; $i++) {
Write-Host "Connecting to vCenter ... $i"
Connect-VIServer -Server $VC -Credential $CRED -ErrorAction Stop | Out-Null
# Disconnect-VIserver -Server $VC -Force -Confirm:$false
}

Write-Host "Get Sessions ..."
Get-ViSession | measure

# Disconnect sessions onliner
# get-VISession | Where { $_.IdleMinutes -gt 30 } | disconnect-VISession