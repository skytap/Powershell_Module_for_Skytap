# Powershell_Module
A powershell module to simplify Skytap API usage

Installation - copy these files to powershell module directory: 

	skytap.psd1
	Skytap.psm1
	user_token

	(substitute your \User directory )

	$home\Documents\WindowsPowerShell\Modules\<Module Folder>\<Module Files>
	
	example directory: C:\Users\Skytap\Documents\WindowsPowerShell\Modules\Skytap
	
	
powershell download from Git:

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-WebRequest -Uri https://github.com/skytap/Powershell_Module_for_Skytap/archive/master.zip -Outfile C:\Users\Administrator\skytap
	$destination = ‘Documents/WindowsPowershell/Modules’
	Mkdir $destination
	Add-Type -assembly "system.io.compression.filesystem"
	[io.compression.zipfile]::ExtractToDirectory(‘skytap’,$destination)
	mv $destination/Powershell_Module_for_Skytap-master $destination/skytap


Use:  Import-Module Skytap [-verbose]

	When loaded the module will look for the user_token file  You can have multiple user_token files for different environments or access
	To change user_token location user Set-Authorization <path to user_token file>   -  ex:   Set-Authorization c:\temp\user_token_alt
	
Syntax help:

   Get-Help <Function Name>
 
List of Functions ( 03/08/2022 )

 Add-ConfigurationToProject   
 Add-Department   
 Add-EnvironmentTag   
       alias   Tag-Configuration
       alias   Tag-Environment    
 Add-Group   
 Add-NetworkAdapter  alias   Add-Adapter      
 Add-Schedule   
 Add-TemplateTag   alias   Tag-Template   
 Add-TemplateToConfiguration   alias   Add-TemplateToEnvironment   
 Add-TemplateToProject   
 Add-User   
 Add-UserToGroup   
 Add-UserToProject   
 Attach-WAN   
 Connect-Network   
 Connect-PublicIP   
 Connect-WAN   
 Copy-Configuration   
 Edit-Configuration      alias   Edit-Environment   
 Edit-NetworkAdapter   alias   Edit-Adapter     
 Edit-VM   
 Edit-VMUserdata   
 Get-AuditReport   
 Get-Configurations   
     alias   Get-Configuration   
     alias   Get-Environment   
     alias   Get-Environments   
 Get-DepartmentQuotas   
 Get-Departments   
 Get-Metadata  ( only works from within a vm )
 Get-Network   
 Get-ProjectEnvironments   
 Get-Projects   
 Get-PublicIPs   
 Get-PublishedServices   
 Get-PublishedURLDetails   
 Get-PublishedURLs   
 Get-Schedules    alias   Get-Schedule   
 Get-Tags   
 Get-Templates   alias   Get-Template   
 Get-Usage   
 Get-Users         alias   Get-User   
 Get-VMCredentials   
 Get-VMs   
 Get-VMUserData   
 Get-WAN
      alias   Get-WANs   
      alias   Get-VPN   
      alias   Get-VPNs   
 LogWrite   
 New-EnvironmentfromTemplate   
 New-Project   
 Publish-Service   
 Publish-URL   
 Remove-Configuration   alias   Remove-Environment    
 Remove-Network   
 Remove-Project   
 Remove-Tag   
 Remove-Template   
 Rename-Environment   alias   Rename-Configuration   
 Save-ConfigurationToTemplate    alias   Save-EnvironmentToTemplate   
 Send-SharedDrive  - simple ftp to skytap shared drive
	requires additional entries in user_token
		ftpuser = '321_measel'
		ftppwd = '7tBAAHfhC8A'
		ftpregion = 'from your account page'
 Set-Authorization   
 Show-RequestFailure   
 Show-WebRequestFailure   
 Update-AutoSuspend   
 Update-EnvironmentUserdata   
 Update-RunState   
 

Questions or comments to mmeasel@skytap.com

