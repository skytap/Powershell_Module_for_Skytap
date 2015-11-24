# generate excel workbook reports from skytap data

function reportUsers {
$eUsers = @()

$sUsers = get-users
$sUsers | Foreach-object {
			$sUser = get-users $_.id
			Foreach ($q in $sUser.quotas) { 
				Add-Member -inputObject $sUser -MemberType NoteProperty -Name ($q.id + '_limit')  -Value $q.limit
				Add-Member -inputObject $sUser -MemberType NoteProperty -Name ($q.id + '_usage' ) -Value $q.usage
				
			}			
			$sUser.PSObject.Properties.Remove('quotas')
			# clean out junk
			$sUser.PSObject.Properties.Remove('requestResultCode')
			$sUser.PSObject.Properties.Remove('lockversion')
			# change arrays to counts
			$sUser.configurations = $sUser.configurations.count
			$sUser.templates = $sUser.templates.count
			$sUser.assets = $sUser.assets.count
			
			$eUsers += $sUser
} 

$data = $eUsers | 
	select-object @{
	Name="First Name";Expression={$_.first_name}},	
	@{
	Name="Last Name";Expression={$_.last_name}},
	title,
	email,
	created_at,
	deleted,
	activated,
	account_role,
	configurations,
	templates,
	assets,
	can_export,
	can_import,
	has_public_library,
	concurrent_vms_limit,
	concurrent_vms_usage,
	concurrent_svms_limit,
	concurrent_svms_usage,
	cumulative_svms_limit,
	cumulative_svms_usage,
	concurrent_storage_size_limit,
	concurrent_storage_size_usage 
	
$data | .\Export-XLSX -path "c:\temp\skyExcelReport.xlsx" -worksheet "Users"
}
#################
function reportTemplates {
$eTemplates = @()
$sTemplates = get-templates

$sTemplates | Foreach-Object {
	$sTemplate = $_
	$sVms = $_.vms
	Foreach ($vm in $sVms) {
		#$sVm = get-vms $vm.id
		$hardware = $vm.hardware
		$tCPU = $tCPU + $hardware.cpus
		$tRAM = $tRAM + $hardware.ram
		$tSVMS = $tSVMS + $hardware.svms
		$tStorage = $tStorage + $hardware.storage
	} 
	Add-Member -inputObject $sTemplate -MemberType NoteProperty -Name CPU  -Value $tCPU -force
	Add-Member -inputObject $sTemplate -MemberType NoteProperty -Name RAM -Value $tRAM -force
	Add-Member -inputObject $sTemplate -MemberType NoteProperty -Name SVMS -Value $SVMS -force
	Add-Member -inputObject $sTemplate -MemberType NoteProperty -Name Storage  -Value $tStorage -force
	Add-Member -inputObject $sTemplate -MemberType NoteProperty -Name vm_count  -Value $sVms.count -force
	$tCPU, $tRAM, $tSVMS, $tStorage = 0
		
$eTemplates += $sTemplate
}



$data = $eTemplates | 
	select-object id,
	name,
	region_backend,
	busy,
	public,
	description,
	owner_name,
	tag_list,
	vm_count,
	CPU,
	RAM,
	SVMS,
	Storage
	
$data | .\Export-XLSX -path "c:\temp\skyExcelReport.xlsx" -worksheet "Templates" -Append
}
function reportEnvironments {
$eEnvironments = @()
$sEnvironments = get-environments

$sEnvironments | Foreach-Object {
	$sEnvironment = get-environment $_.id
	$sVms = $_.vms
	Foreach ($vm in $sVms) {
		#$sVm = get-vms $vm.id
		$hardware = $vm.hardware
		$tCPU = $tCPU + $hardware.cpus
		$tRAM = $tRAM + $hardware.ram
		$tSVMS = $tSVMS + $hardware.svms
		$tStorage = $tStorage + $hardware.storage
	} 
	$networks = $sEnvironment.networks.count
	Add-Member -inputObject $sEnvironment -MemberType NoteProperty -Name CPU  -Value $tCPU -force
	Add-Member -inputObject $sEnvironment -MemberType NoteProperty -Name RAM -Value $tRAM -force
	Add-Member -inputObject $sEnvironment -MemberType NoteProperty -Name SVMS -Value $SVMS -force
	Add-Member -inputObject $sEnvironment -MemberType NoteProperty -Name Storage  -Value $tStorage -force
	Add-Member -inputObject $sEnvironment -MemberType NoteProperty -Name vm_count  -Value $sVms.count -force
	Add-Member -inputObject $sEnvironment -MemberType NoteProperty -Name network_count  -Value $networks -force
	
	$tCPU, $tRAM, $tSVMS, $tStorage = 0
		
$eEnvironments += $sEnvironment
}

$data = $eEnvironments | 
	select-object id,
	name,
	description,
       runstate,
	last_run,
	owner_url,
	owner_name,
	owner_id,
	auto_suspend_description,
	vm_count,
	CPU,
	RAM,
	SVMS,
	Storage,
	network_count,
	created_at,
	region,
	published_service_count,
	public_ip_count,
	project_count
	
$data | .\Export-XLSX -path "c:\temp\skyExcelReport.xlsx" -worksheet "Environments" -Append
}
reportUsers
reportTemplates
reportEnvironments
Invoke-item "c:\temp\skyExcelReport.xlsx"
	