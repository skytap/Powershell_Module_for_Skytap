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
	
List of Functions ( 11/26/15 )

  Add-ConfigurationToProject
  Add-Schedule
  Add-TemplateToConfiguration
  Add-TemplateToProject
  Add-User
  Add-UserToProject
  Connect-Network
  Connect-PublicIP
  Edit-Configuration
  Get-Configurations
  Get-ProjectEnvironments
  Get-Projects
  Get-PublicIPs
  Get-PublishedServices
  Get-PublishedURLDetails
  Get-PublishedURLs
  Get-Schedules
  Get-Templates
  Get-Users
  Get-VMs
  New-EnvironmentfromTemplate
  New-Project
  Publish-Service
  Publish-URL
  Remove-Configuration
  Save-ConfigurationToTemplate
  Set-Authorization
  Show-RequestFailure
  Show-RequestFailure2
  Update-AutoSuspend
  Update-RunState
  
 alias Add-TemplateToEnvironment
 alias Edit-Environment
 alias Get-Configuration
 alias Get-Environment
 alias Get-Environments
 alias Get-Schedule
 alias Get-Template
 alias Remove-Environment
 alias Save-EnvironmentToTemplate

Questions or comments to mmeasel@skytap.com

