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
 
List of Functions ( 11/08/2022 )

1. Add-ConfigurationToProject   
2. Add-Department   
3. Add-EnvironmentTag   
..1. Tag-Configuration
..2. Tag-Environment    
4. Add-Group   
5. Add-NetworkAdapter  
..1. Add-Adapter
6. Add-Schedule   
7. Add-TemplateTag   
..1. Tag-Template   
8. Add-TemplateToConfiguration   
..1. Add-TemplateToEnvironment   
9. Add-TemplateToProject   
10. Add-User   
11. Add-UserToGroup   
12. Add-UserToProject   
13. Attach-WAN   
14. Connect-Network   
15. Connect-PublicIP   
16. Connect-WAN   
17. Copy-Configuration
18. Copy-EnvironmentToRegion
19. Copy-TemplateToRegion   
20. Edit-Configuration      
..1. Edit-Environment   
21. Edit-NetworkAdapter
..1. Edit-Adapter     
22. Edit-VM   
23. Edit-Userdata
..1. Update-EnvironmentUserdata
..1. Update-VMUserdata   
24. Get-AuditReport   
25. Get-Configurations   
..1. Get-Configuration   
..2. Get-Environment   
..3. Get-Environments   
26. Get-DepartmentQuotas   
27. Get-Departments   
28. Get-Metadata  ( only works from within a vm )
29. Get-Network   
30. Get-ProjectEnvironments   
31. Get-Projects   
32. Get-PublicIPs   
33. Get-PublishedServices   
34. Get-PublishedURLDetails   
35. Get-PublishedURLs   
36. Get-Schedules
..1. Get-Schedule   
37. Get-Tags   
38. Get-Templates
..1. Get-Template   
39. Get-Usage   
40. Get-Users
..1. Get-User   
41. Get-VMCredentials   
42. Get-VMs    
43. Get-VMUserData   
44. Get-WAN
..1. Get-WANs   
..2. Get-VPN   
..3. Get-VPNs   
45. LogWrite   
46. New-EnvironmentfromTemplate   
47. New-Project   
48. Publish-Service   
49. Publish-URL   
50. Remove-Configuration
..1. Remove-Environment    
51. Remove-Network   
52. Remove-Project   
53. Remove-Tag   
54. Remove-Template   
55. Rename-Environment 
..1. Rename-Configuration   
56. Save-ConfigurationToTemplate
..1. Save-EnvironmentToTemplate   
57. Send-SharedDrive  - simple ftp to skytap shared drive
58. Set-Authorization   
59. Show-RequestFailure   
60. Show-WebRequestFailure   
61. Update-AutoSuspend   
62. Update-EnvironmentUserdata   
63. Update-RunState   
 

**Questions or comments to mmeasel@skytap . com**

