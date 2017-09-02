#
# Script inspiration
#   http://www.punchingclouds.com/2016/03/24/vmware-virtual-san-automated-deployments-powercli/
#
# Script assumptions
#   A1: ESXi host has single vmkernel interface (vmk0) for management.
#       vmk0 is not configured.
#       vmk0 real configuration will be validated against expected configuration in the future version
#   A2: 
 

Clear-Host

$o = Add-PSSnapin VMware.VimAutomation.Core
$o = Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
 
# Connect to vCenter
Write-Host "Connecting to vCenter ..."
$VC = Read-Host "Enter one vCentre Server or multiple vCenter servers delimted by comma."
Write-Host "Enter vCenter credentials ..."
$CRED = Get-Credential
Connect-VIServer -Server $VC -Credential $CRED -ErrorAction Stop | Out-Null


# CONFIGURATION - JSON created and validated at https://jsonformatter.curiousconcept.com/ 
$conf_json = '
{"ESXs":
  [
    {
     "hostname": "esx11.home.uw.cz",
     "configure": 1,
     "configure_vmks": 0,
     "vmks": [
       {
         "name": "vmk0",
         "descr": "MGMT",
         "portgroup": "MGMT",
         "ip": "192.168.4.111",
         "subnet": "255.255.255.0",
         "management": 1,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk1",
         "descr": "VMOTION",
         "portgroup": "VMOTION",
         "ip": "192.168.22.111",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 1,
         "vsan": 0
       },
       {
         "name": "vmk2",
         "descr": "NFS",
         "portgroup": "NFS",
         "ip": "192.168.25.111",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk3",
         "descr": "ISCSI",
         "portgroup": "ISCSI",
         "ip": "192.168.24.111",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk4",
         "descr": "VSAN",
         "portgroup": "VSAN",
         "ip": "192.168.26.111",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 1
       }
     ]
    },
    {
     "hostname": "esx12.home.uw.cz",
     "configure" : 1,
     "configure_vmks": 0,
     "vmks": [
       {
         "name": "vmk0",
         "descr": "MGMT",
         "portgroup": "MGMT",
         "ip": "192.168.4.112",
         "subnet": "255.255.255.0",
         "management": 1,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk1",
         "descr": "VMOTION",
         "portgroup": "VMOTION",
         "ip": "192.168.22.112",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 1,
         "vsan": 0
       },
       {
         "name": "vmk2",
         "descr": "NFS",
         "portgroup": "NFS",
         "ip": "192.168.25.112",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk3",
         "descr": "ISCSI",
         "portgroup": "ISCSI",
         "ip": "192.168.24.112",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk4",
         "descr": "VSAN",
         "portgroup": "VSAN",
         "ip": "192.168.26.112",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 1
       }
     ]
    },
    {
     "hostname": "esx13.home.uw.cz",
     "configure" : 1,
     "configure_vmks": 0,
     "vmks": [
       {
         "name": "vmk0",
         "descr": "MGMT",
         "portgroup": "MGMT",
         "ip": "192.168.4.113",
         "subnet": "255.255.255.0",
         "management": 1,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk1",
         "descr": "VMOTION",
         "portgroup": "VMOTION",
         "ip": "192.168.22.113",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 1,
         "vsan": 0
       },
       {
         "name": "vmk2",
         "descr": "NFS",
         "portgroup": "NFS",
         "ip": "192.168.25.113",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk3",
         "descr": "ISCSI",
         "portgroup": "ISCSI",
         "ip": "192.168.24.113",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk4",
         "descr": "VSAN",
         "portgroup": "VSAN",
         "ip": "192.168.26.113",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 1
       }
     ]
    },
    {
     "hostname": "esx14.home.uw.cz",
     "configure" : 1,
     "configure_vmks": 1,
     "vmks": [
       {
         "name": "vmk0",
         "descr": "MGMT",
         "portgroup": "MGMT",
         "ip": "192.168.4.114",
         "subnet": "255.255.255.0",
         "management": 1,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk1",
         "descr": "VMOTION",
         "portgroup": "VMOTION",
         "ip": "192.168.22.114",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 1,
         "vsan": 0
       },
       {
         "name": "vmk2",
         "descr": "NFS",
         "portgroup": "NFS",
         "ip": "192.168.25.114",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk3",
         "descr": "ISCSI",
         "portgroup": "ISCSI",
         "ip": "192.168.24.114",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 0
       },
       {
         "name": "vmk4",
         "descr": "VSAN",
         "portgroup": "VSAN",
         "ip": "192.168.26.114",
         "subnet": "255.255.255.0",
         "management": 0,
         "vmotion": 0,
         "vsan": 1
       }
     ]
    }

  ]
}
'

# Validate JSON configuration in PowerShell
if (1) { # always do - this is just a block which can be collapsed in PowerShell ISE
  try {
    $conf = ConvertFrom-Json -InputObject $conf_json -ErrorAction Stop;
    $validJson = $true;
  } catch {
    $validJson = $false;
  }

  if ($validJson) {
    Write-Host "Provided configuration has been correctly parsed to JSON";
  } else {
    Write-Host "Provided configuration is not a valid JSON string";
    exit
  }
}
 
# Get virtual switch
$VDS = Get-VirtualSwitch -Name PAYLOAD

# Configure ESXi hosts
foreach ($esx in $conf.ESXs) {
  $hostname  = $esx.hostname
  $configure = $esx.configure
  Write-Host -BackgroundColor Gray -ForegroundColor Black "=========================================="
  Write-Host -BackgroundColor Gray -ForegroundColor Black "ESX: $hostname"
  if (-Not $configure) {
    Write-Host -ForegroundColor Yellow "Configuration of $hostname is not required. Skip to next host."
    Continue
  }
  Write-Host -ForegroundColor Green "ESXi configuration ..."

  # start of vmKernel configuration section
  $configure_vmks = $esx.configure_vmks;
  if (-Not $configure_vmks) {
    Write-Host -ForegroundColor Yellow "Configuration of vmKernel interface is not required. Skip to next type of configuration."
  } else {
    Write-Host -ForegroundColor Green "  vmKernel interfaces configuration ..."
    foreach ($vmk in $esx.vmks) {
      $vmk_name       = [String]($vmk.name).ToLower();
      $vmk_ip         = $vmk.ip;
      $vmk_subnet     = $vmk.subnet;
      $vmk_portgroup  = $vmk.portgroup
      $vmk_management = [Boolean]($vmk.management)
      $vmk_vmotion    = [Boolean]($vmk.vmotion) 
      $vmk_vsan       = [Boolean]($vmk.vsan)
      $vmk_mtu        = [Int]($vmk.mtu)
      if ($vmk_mtu -lt 1500) {$vmk_mtu = 1500}
       
      Write-host "  vmk_name       = $vmk_name"
      Write-host "  vmk_ip         = $vmk_ip"
      Write-host "  vmk_subnet     = $vmk_subnet"
      Write-host "  vmk_portgroup  = $vmk_portgroup"
      Write-host "  vmk_management = $vmk_management"
      Write-host "  vmk_vmotion    = $vmk_vmotion"
      Write-host "  vmk_vsan       = $vmk_vsan"
      Write-host "  vmk_mtu        = $vmk_mtu"
      if ($vmk_name -eq "vmk0") {
        Write-host -ForegroundColor Yellow "  We do not configure vmk0 interface. vmk0 validation will be implemented in the future."
      } else {
        # Creates a VMkernel port VMotion on vSwitch0
        Write-Host -ForegroundColor Green "$vmk_name configuration ..."
        New-VMHostNetworkAdapter -VMhost $hostname -PortGroup $vmk_portgroup -VirtualSwitch $VDS -IP $vmk_ip -SubnetMask $vmk_subnet -ManagementTrafficEnabled $vmk_management -VMotionEnabled $vmk_vmotion -VsanTrafficEnabled $vmk_vsan -mtu $vmk_mtu
      }
      Write-host "  --------------------------"
    }
  } # end of vmKernel configuration section

} # enf of ESXi hosts foreach loop

Disconnect-VIserver -Server $VC -Force -Confirm:$false
