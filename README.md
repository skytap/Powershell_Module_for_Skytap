# Powershell_Module
A powershell module to simplify API usage

Installation - copy these files to powershell module directory: 

	skytap.psd1
	Skytap.psm1
	user_token

	(substitute your \User directory )

	$home\Documents\WindowsPowerShell\Modules\<Module Folder>\<Module Files>

example:    Directory: C:\Users\Skytap\Documents\WindowsPowerShell\Modules\Skytap


Use:  Import-Module Skytap [-verbose]

	When loaded the module will look for the user_token file  You can have multiple user_token files for different environments or access
	To change user_token location user Set-Authorization <path to user_token file>   -  ex:   Set-Authorization c:\temp\user_token_alt
	
Syntax help:
   Get-Help <Function Name>
	
List of Functions ( 04/27/16 )

	 Add-ConfigurationToProject
	 Add-Department
	 Add-Group
	 Add-Schedule
	 Add-TemplateToConfiguration
	 Add-TemplateToProject
	 Add-User
	 Add-UserToGroup
	 Add-UserToProject
	 Connect-Network
	 Connect-PublicIP
	 Edit-Configuration
	 Edit-VMUserdata
	 Get-Configurations
	 Get-DepartmentQuotas
	 Get-Departments
	 Get-ProjectEnvironments
	 Get-Projects
	 Get-PublicIPs
	 Get-PublishedServices
	 Get-PublishedURLDetails
	 Get-PublishedURLs
	 Get-Schedules
	 Get-Templates
	 Get-Usage
	 Get-Users
	 Get-VMs
	 Get-VMUserData
	 New-EnvironmentfromTemplate
	 New-Project
	 Publish-Service
	 Publish-URL
	 Remove-Configuration
	 Remove-Project
	 Rename-Environment
	 Save-ConfigurationToTemplate
	 Set-Authorization
	 Show-RequestFailure
	 Show-WebRequestFailure
	 Update-AutoSuspend
	 Update-RunState
	 Update-AutoSuspend
	Alias: 
		Add-TemplateToEnvironment
		Edit-Environment
		Get-Configuration
		Get-Environment
		Get-Environments
		Get-Schedule
		Get-Template
		Remove-Environment
		Save-EnvironmentToTemplate

Questions or comments to mmeasel@skytap.com

