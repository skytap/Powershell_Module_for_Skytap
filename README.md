# Skytap Powershell Module

#### A powershell module to simplify Skytap API usage

## Installation - 

####   Copy these files to powershell module directory: 

	skytap.psd1
	Skytap.psm1
	

	(substitute your \User directory for $home)

	$home\Documents\WindowsPowerShell\Modules\<Module Folder>\<Module Files>
	
	example directory: C:\Users\Skytap\Documents\WindowsPowerShell\Modules\Skytap

####    Copy this file to your current directory and edit:

	user_token

	*Replace the values in that file with the ones you can find in the Skytap GUI under My Profile*
	
	
powershell download from Git:

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	Invoke-WebRequest -Uri https://github.com/skytap/Powershell_Module_for_Skytap/archive/master.zip -Outfile C:\Users\Administrator\skytap
	$destination = ‘Documents/WindowsPowershell/Modules’
	Mkdir $destination
	Add-Type -assembly "system.io.compression.filesystem"
	[io.compression.zipfile]::ExtractToDirectory(‘skytap’,$destination)
	mv $destination/Powershell_Module_for_Skytap-master $destination/skytap


## Use:  Import-Module Skytap [-verbose]

	When loaded the module will look for the user_token file  You can have multiple user_token files for different environments or access
	To change user_token location user Set-Authorization <path to user_token file>   -  ex:   Set-Authorization c:\temp\user_token_alt
	
## Syntax help:

   Get-Help <Function Name>
 
### List of Functions ( 11/08/2022 )

- Add-ConfigurationToProject   
- Add-Department   
- Add-EnvironmentTag   
  - Tag-Configuration
  - Tag-Environment    
- Add-Group   
- Add-NetworkAdapter  
  - Add-Adapter
- Add-Schedule   
- Add-TemplateTag   
  - Tag-Template   
- Add-TemplateToConfiguration   
  - Add-TemplateToEnvironment   
- Add-TemplateToProject   
- Add-User   
- Add-UserToGroup   
- Add-UserToProject   
- Attach-WAN   
- Connect-Network   
- Connect-PublicIP   
- Connect-WAN   
- Copy-Configuration
- Copy-EnvironmentToRegion
- Copy-TemplateToRegion   
- Edit-Configuration      
  - Edit-Environment   
- Edit-NetworkAdapter
  - Edit-Adapter     
- Edit-VM   
- Edit-Userdata
  - Update-EnvironmentUserdata
  - Update-VMUserdata   
- Get-AuditReport   
- Get-Configurations   
  - Get-Configuration   
  - Get-Environment   
  - Get-Environments   
- Get-DepartmentQuotas   
- Get-Departments   
- Get-Metadata  ( only works from within a vm )
- Get-Network   
- Get-ProjectEnvironments   
- Get-Projects   
- Get-PublicIPs   
- Get-PublishedServices   
- Get-PublishedURLDetails   
- Get-PublishedURLs   
- Get-Schedules
  - Get-Schedule   
- Get-Tags   
- Get-Templates
  - Get-Template   
- Get-Usage   
- Get-Users
  - Get-User   
- Get-VMCredentials   
- Get-VMs    
- Get-VMUserData   
- Get-WAN
  - Get-WANs   
  - Get-VPN   
  - Get-VPNs   
- LogWrite   
- New-EnvironmentfromTemplate   
- New-Project   
- Publish-Service   
- Publish-URL   
- Remove-Configuration
  - Remove-Environment    
- Remove-Network   
- Remove-Project   
- Remove-Tag   
- Remove-Template   
- Rename-Environment 
  - Rename-Configuration   
- Save-ConfigurationToTemplate
  - Save-EnvironmentToTemplate   
- Send-SharedDrive  - simple ftp to skytap shared drive
- Set-Authorization   
- Show-RequestFailure   
- Show-WebRequestFailure   
- Update-AutoSuspend   
- Update-EnvironmentUserdata   
- Update-RunState   
 

**Questions or comments to mmeasel@skytap . com**

