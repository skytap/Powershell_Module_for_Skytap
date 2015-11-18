# example script using skytap posh module
#
# set all environments to suspend after two hours 

import-module skytap

$Attrib = @{suspend_on_idle=7200}
$envs = Get-Environments

$envs | ForEach-Object {
	$envid = $_.id
      $env = Get-environment $_.id
	write-host $env.id  $env.runstate $env.auto_suspend_description
	if ($env.auto_suspend_description -ne 'After 2 hours of idle time') {
		$newcfg = Edit-Configuration $env.id $Attrib
		write-host 'changed' $newcfg.id $newcfg.suspend_on_idle
	}
}
