$puppet_master=$args[0]
$puppet_role=$args[1]
# This script lays down a yaml fact to designate a machine's role and then 
# installs the windows puppet agent on the windows seteam vagrant vms
# from the master's pe_repo by downloading it to C:\tmp first and then running
# msiexec on it from there.

New-Item C:\ProgramData\PuppetLabs\facter\facts.d -type directory -force
New-Item C:\ProgramData\PuppetLabs\facter\facts.d\role.yaml -type file -value "puppet_role: ${puppet_role}" -force

$msi_source = "https://${puppet_master}:8140/packages/current/windows-x86_64/puppet-agent-x64.msi"
$msi_dest = "C:\puppet-agent-x64.msi"

# Start the agent installation process and wait for it to end before continuing.
Write-Host "Installing puppet agent from ${msi_source}"

# Determine system hostname and primary DNS suffix
# Join strings and apply lowercase filter to determine certname
$objIPProperties = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties()
$name_components = @($objIPProperties.HostName.ToLower(), $objIPProperties.DomainName.ToLower()) | ? {$_}
$certname = $name_components -Join "."

Function Get-WebPage { Param( $url, $file, [switch]$force)
  if($force) { 
    [Net.ServicePointManager]::ServerCertificateValidationCallback = {$true} 
  }
  $webclient = New-Object system.net.webclient
  $webclient.DownloadFile($url,$file)
}

Get-WebPage -url $msi_source -file $msi_dest -force
$msiexec_path = "C:\Windows\System32\msiexec.exe"
$msiexec_args = "/qn /log c:\log.txt /i $msi_dest PUPPET_MASTER_SERVER=$puppet_master PUPPET_AGENT_CERTNAME=$certname"
$msiexec_proc = [System.Diagnostics.Process]::Start($msiexec_path, $msiexec_args)
$msiexec_proc.WaitForExit()

