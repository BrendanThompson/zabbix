## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## Name:      zabbix-installer
## Author:    Brendan Thompson <brendan@btsystems.com.au>
## Key:       5E871BD7
## Version:   0.0.1 
## ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[CmdletBinding()]

Param(
	[switch] $install,
	[switch] $uninstall,
	#[string] $conf,
	[string] $hostname = $env:COMPUTERNAME
)


### ---------------------------------------------------------------------------
### Global Variables
### ---------------------------------------------------------------------------

$Global:dirZabbixAgent = "C:\Program Files\Zabbix Agent\"
$Global:dirZabbixAgentInstaller = "Microsoft.PowerShell.Core\FileSystem::\\mydomain.local\netlogon\zabbix\"

### ---------------------------------------------------------------------------
### Functions
### ---------------------------------------------------------------------------

function updateConfiguration() {
	Param(
		[string]$configurationFilePath,
		[string]$configKey,
		[string]$configValue
	)
		
	((Get-Content -Path $configurationFilePath) | Foreach-Object {
		$line = $_
		if ($line -like "*=*") {
			$lineArray = $line -split "=", 2

			if ($lineArray[0].Trim() -eq $configKey) {
				$lineArray[1] = $configValue
				$line = $lineArray -join "="
			}
		}
		$line
	}) | Set-Content ($configurationFilePath)
}

function checkZabbixAgentDirectories() {
	$Local:dirZabbixAgent = $Global:dirZabbixAgent

	if ((Test-Path -Path $Local:dirZabbixAgent) -eq 1) {
		Write-Warning "Zabbix Agent Directory Already Exists"
	} elseif ((Test-Path -Path $Local:dirZabbixAgent) -eq 0) {
		copyZabbixAgent
		copyZabbixAgentDefaultConfiguration
	}
}

function removeZabbixAgentDirectory() {
	$Local:dirZabbixAgent = $Global:dirZabbixAgent

	if ((Test-Path -Path $Local:dirZabbixAgent) -eq 1) {
		Remove-Item -Recurse -Path $Local:dirZabbixAgent
	} elseif ((Test-Path -Path $Local:dirZabbixAgent) -eq 0) {
		Write-Warning "Zabbix Agent Directory Doesn't Exist"
	}
}

function copyZabbixAgent() {
	$Local:arch = [IntPtr]::Size
	
	if ($Local:arch -eq 4) {
		Copy-Item -Recurse -Path "$Global:dirZabbixAgentInstaller\bin\win32\" -Destination $Global:dirZabbixAgent
	} elseif ($Local:arch -eq 8) {
		Copy-Item -Recurse -Path "$Global:dirZabbixAgentInstaller\bin\win64\" -Destination $Global:dirZabbixAgent
	}
}

function copyZabbixAgentDefaultConfiguration() {
	$Local:agentConf = Join-Path -Path $Global:dirZabbixAgentInstaller -ChildPath "\conf\zabbix_agentd.conf"
	Copy-Item -Path "Microsoft.PowerShell.Core\FileSystem::\\mydomain.local\netlogon\zabbix\conf\zabbix_agentd.conf" -Destination $Global:dirZabbixAgent
}

function installZabbixAgent() {
	$Local:configFile = "$Global:dirZabbixAgent\zabbix_agentd.conf"
	$Local:zabbix_agentd = "$Global:dirZabbixAgent\zabbix_agentd.exe"
	updateConfiguration -configurationFilePath $Local:configFile -configKey "Hostname" -configValue $hostname
	
	$cmd = "$Local:zabbix_agentd"
	$prm = '-c', "$Local:configFile", '-i'

	& $cmd $prm
}

function uninstallZabbixAgent() {
	$Local:configFile = "$Global:dirZabbixAgent\zabbix_agentd.conf"
	$Local:zabbix_agentd = "$Global:dirZabbixAgent\zabbix_agentd.exe"
	
	$cmd = "$Local:zabbix_agentd"
	$prm = '-c', "$Local:configFile", '-d'

	& $cmd $prm
}

function startZabbixAgent() {
	$Local:configFile = "$Global:dirZabbixAgent\zabbix_agentd.conf"
	$Local:zabbix_agentd = "$Global:dirZabbixAgent\zabbix_agentd.exe"
	
	$cmd = "$Local:zabbix_agentd"
	$prm = '-c', "$Local:configFile", '-s'

	& $cmd $prm
}

function Main() {
	if ($install) {
		checkZabbixAgentDirectories
		installZabbixAgent
		startZabbixAgent

	} elseif ($uninstall) {
		uninstallZabbixAgent
		removeZabbixAgentDirectory
	}
}

Main
