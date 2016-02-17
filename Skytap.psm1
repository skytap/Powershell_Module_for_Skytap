if ($PSBoundParameters['Debug']) {
	$DebugPreference = 'Continue'
}

if ($PSVersionTable.PSVersion.major -lt 4) {
	write-host "This module requires Powershell Version 4" -foregroundcolor "magenta"
	return
}

function Set-Authorization ([string]$tokenfile='user_token', [string]$user, [string]$pwd) {
<#
    .SYNOPSIS
      Creates authorization headers from file or parameters
    .SYNTAX
       Add-ConfigurationToProject EnvironmentId ProjectId
    .EXAMPLE
      Add-ConfigurationToProject 12345 54321
#>
	  if ($user) {    #use params instead of file 
		  $username = $user
		  $password = $pwd
	  } else {
		  if (Test-Path $tokenfile) {
			Get-Content $tokenfile | Foreach-Object{
			   $var = $_.Split('=')
			   Set-Variable -Name $var[0] -Value $var[1]
				}
		  } else {
				Write-host "The user_token file $tokenfile was not found" -foregroundcolor "magenta"
		  		return -1 }
		
		
	  }
	Write-host "Skytap user is $username"
	$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
	$global:headers = @{"Accept" = "application/json"; Authorization=("Basic {0}" -f $auth)}
	return 0
}

Set-Authorization
$global:url = "https://cloud.skytap.com"
$global:tOffset = 0
$global:errorResponse = ''

function Show-RequestFailure  {
	$ex = $global:errorResponse
	if ($ex.gettype().fullname -eq 'System.Net.WebException') {
		$nob = New-Object -TypeName psobject -Property @{
		requestResultCode = [int]$ex.HResult
		eDescription = $ex.gettype()
		eMessage = $ex.Message
		method = $ex.Source
		}
		
       }else{
		$eresp = $ex.response 
		$errorResponse = $eresp.GetResponseStream()
		$reader = New-Object System.IO.StreamReader($errorResponse)
		$reader.BaseStream.Position = 0
		$reader.DiscardBufferedData()
		$responseBody = $reader.ReadToEnd();
		$nob = New-Object -TypeName psobject -Property @{
			requestResultCode = [int]$eresp.StatusCode
			eDescription = $eresp.StatusDescription
			eMessage = $responseBody
			method = $eresp.Method
		}
	}
	$global:errorResponse = ''
	return $nob
}
	
function Show-RequestFailure2 ($eresp) {
       
       return {$eresp | Get-member}
	$nob = New-Object -TypeName psobject -Property @{
		requestResultCode = [int]$eresp.StatusCode
		eDescription = $eresp.StatusDescription
		eMessage = $responseBody
		#method = $eresp.Method
	}
	return $nob
}	


function Add-ConfigurationToProject ([string]$configId, [string]$projectId ){
 <#
    .SYNOPSIS
      Adds an environment to a project
    .SYNTAX
       Add-ConfigurationToProject EnvironmentId ProjectId
    .EXAMPLE
      Add-ConfigurationToProject 12345 54321
  #>
	try {
		$uri = "$url/projects/$projectId/configurations/$configId"
		$result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure		
		}
		return $result
	}

function Edit-Configuration ( [string]$configId, $configAttributes ){
<#
    .SYNOPSIS
      Change environment attributes
    .SYNTAX
       Edit-Configuration  ConfigId Attribute-Hash
    .EXAMPLE
      Edit-Configuration 12345 @{name='config 1234'; description='windows v10'}
      
      Or
      
      $Attrib = @{name='config 1234'; description='windows v10'}
      Edit-Configuration 12345 $Attrib
  #>
	try {
		$uri = "$url/configurations/$configId"
		
		$body = $configAttributes
		$result = Invoke-RestMethod -Uri $uri -Method PUT -Body (ConvertTo-Json $body)  -ContentType "application/json" -Headers $headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure		
		}
	return $result
	}
	
Set-Alias Edit-Environment Edit-Configuration 

function Edit-VMUserdata ( [string]$configId, $vmid, $userdata ){
<#
    .SYNOPSIS
      Change userdata 
    .SYNTAX
       Edit-VMUserdata ConfigId VMid Contents
       {
	"contents": "Text you want saved in the user data field"
	}
    .EXAMPLE
      Edit-VMUserdata 12345  54321 @{contents="text for userdata field"}
      Or
      $userdata = @{"contents"="This machine does not conform"}
      Edit-VMUserdata 12345 54321 $userdata
      
  #>
	try {
		$uri = "$url/configurations/$configId/vms/$vmid/user_data"
		
		$body = $userdata
		$result = Invoke-RestMethod -Uri $uri -Method PUT -Body (ConvertTo-Json $body)  -ContentType "application/json" -Headers $headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure		
		}
	return $result
	}
	
		
	
function Update-RunState ( [string]$configId, [string]$newstate ){
<#
    .SYNOPSIS
      Change and environments runstate
    .SYNTAX
       Update-RunState ConfigId State
    .EXAMPLE
      Update-RunState 12345 running
  #>
	try {
		$uri = "$url/configurations/$configId"
		
		$body = @{
			runstate = $newstate
		}
		$result = Invoke-RestMethod -Uri $uri -Method PUT -Body (ConvertTo-Json $body)  -ContentType "application/json" -Headers $headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure		
		}
	return $result
	}

function Connect-Network ([string]$sourceNetwork, [string]$destinationNetwork){
<#
    .SYNOPSIS
      Connect two networks
    .SYNTAX
       Connect-Network Source-Network Destination-Network
    .EXAMPLE
      Connect-Network 78901 10987
  #>
	try {
		$uri = "$url/tunnels"
		$body = @{
				source_network_id = $sourceNetwork
				target_network_id = $destinationNetwork
			}
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
			} catch {
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure		
		}
	return $result
	}


function New-EnvironmentfromTemplate ( [string]$templateId ){
<#
    .SYNOPSIS
      Create a new environment from a template
    .SYNTAX
       New-EnvironmentfromTemplate templateId
       Returns new environment ID
    .EXAMPLE
      New-EnvironmentfromTemplate 12345
  #>
	try {
		$uri = "$global:url/configurations"
		$body = @{
				template_id = $templateId 
				}
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}

function New-Project( [string]$projectName, [string]$projectDescription ){
<#
    .SYNOPSIS
      Create a new project
    .SYNTAX
       New-Project Name [Description]
       Returns new project ID
    .EXAMPLE
      New-Project "Global Training"  "This is a training project"
      ---
      New-Project -projectName "Global Training" -projectDescription "A project for global training"
  #>
	try {
		$uri = "$global:url/projects"
		$body = @{
				name = $projectName
				summary = $projectDescription
				}
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}

function Publish-URL ([string]$configId, [string]$ptype, [string]$pname) { 
<#
    .SYNOPSIS
      Create a published url for an environment 
    .SYNTAX
       Publish-URL configId [type] [name]
       Returns new URL ID
    .EXAMPLE
      Publish-URL 12345 multiple_url "Class 123"
  #>
		try {
			$uri = "$global:url/configurations/$configId/publish_sets"
			if ($ptype) {
				$type = $ptype
			} else {
				$type = "single_url"
					}
			if ($pname) {
				$name = $pname 
			} else {
				$name = "Published set - $type" 
					}
			
			$body = @{
					name = $name
					publish_set_type = $type
					}
			$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
			$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
				} catch { 
					$global:errorResponse = $_.Exception
					$result = Show-RequestFailure			
				}
			return $result
			}

function Save-ConfigurationToTemplate ([string]$configId, [string]$tname) {
<#
    .SYNOPSIS
      Save an environment as a template
    .SYNTAX
       Save-ConfigurationToTemplate
       Returns template ID
    .EXAMPLE
      Save-ConfigurationToTemplate 12345 
  #>
	try {
			$uri = "$url/templates"
			if ($tname) {
				$name = $tname 
				$body = @{
					configuration_id = $configId
					name = $name
				}
			} else {
				$body = @{
					configuration_id = $configId
				}
			}
			$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $headers 
			$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
				} catch { 
					$global:errorResponse = $_.Exception
					$result = Show-RequestFailure		
			}
			return $result
		}
Set-Alias  Save-EnvironmentToTemplate Save-ConfigurationToTemplate
		
function Remove-Configuration ([string]$configId) {
<#
    .SYNOPSIS
      Remove (DELETE) an environment
    .SYNTAX
       Remove-Configuration
    .EXAMPLE
      Remove-Configuration 12345 
  #>
	try {
			$uri = "$url/configurations/$configId"
			
			$result = Invoke-RestMethod -Uri $uri -Method DELETE -ContentType "application/json" -Headers $headers 
			$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
				} catch { 
					$global:errorResponse = $_.Exception
					$result = Show-RequestFailure		
			}
			return $result
		}
Set-Alias  Remove-Environment Remove-Configuration

function Add-TemplateToProject ([string]$projectId, [string]$templateId) {
<#
    .SYNOPSIS
      Adds an template to a project
    .SYNTAX
       Add-TemplateToProject TemplateId ProjectId
    .EXAMPLE
      Add-TemplateToProject  12345 54321
  #>
		try {
		$uri = "$url/projects/$projectId/templates/$templateId"
		$result = Invoke-RestMethod -Uri $uri -Method POST -ContentType "application/json" -Headers $headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure		
		}
		return $result
	}

function Add-TemplateToConfiguration ([string]$configId, [string]$templateId) {
<#
    .SYNOPSIS
      Adds an template to an environment
    .SYNTAX
       Add-TemplateToConfiguration EnvironmentId TemplateId 
    .EXAMPLE
      Add-TemplateToConfiguration  12345 54321
  #>
	try {
		$uri = "$global:url/configurations/$configId"
		$body = @{
				template_id = $templateId 
				}
		$result = Invoke-RestMethod -Uri $uri -Method PUT -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}
Set-Alias  Add-TemplateToEnvironment Add-TemplateToConfiguration
	
function Add-User ([string]$loginName,[string]$firstName, [string]$lastName,[string]$email,[string]$accountRole="restricted_user") {
<#
    .SYNOPSIS
      Adds a new user
    .SYNTAX
       Add-User Login-name First-name Last-Name Email-Address Account-Role
    .EXAMPLE
      Add-User mmeasel mike measel mmeasel@skytap.com admin
  #>
	try {
		$uri = "$global:url/users"
		$body = @{
				login_name = $loginName
				email = $email
				first_name = $firstName
				last_name = $lastName
				account_role = $accountRole
				}
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}
	
function Add-Group ([string]$groupName,[string]$description) {
<#
    .SYNOPSIS
      Adds a new group
    .SYNTAX
       Add-Group Name Description
    .EXAMPLE
      Add-Group EastUsers "Users in east region"
  #>
	try {
		$uri = "$global:url/groups"
		$body = @{
				name = $groupName
				description = $description
				}
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}
function Add-Department ([string]$deptName,[string]$description) {
<#
    .SYNOPSIS
      Adds a new department
    .SYNTAX
       Add-Department Name Description
    .EXAMPLE
      Add-Department Accounting "Users in east region"
  #>
	try {
		$uri = "$global:url/departments"
		$body = @{
				name = $deptName
				description = $description
				}
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}
		
function Publish-Service ([string]$configId, [string]$vmId, [string]$interfaceId, [string]$serviceId, [string]$port) {
<#
    .SYNOPSIS
      Create a published service for an environment 
    .SYNTAX
       Publish-Service configId vmId interfaceId serviceId port_Number
       Returns new service url
    .EXAMPLE
      Publish-Service 12345 54321 11111 22222 8080
  #>
			try {
			$uri = "$global:url/configurations/$configId/vms/$vmId/interfaces/$interfaceId/services/$serviceId"
			
			$body = @{
					port = $port
					}
			$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
			$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
				} catch { 
					$global:errorResponse = $_.Exception
					$result = Show-RequestFailure			
				}
			return $result
			}

function Get-PublishedURLs ([string]$configId) {
<#
    .SYNOPSIS
      Get published URLs for an environment 
    .SYNTAX
       Get-PublishedURLs configId 
       Returns list of URLs
    .EXAMPLE
      Get-PublishedURLs 12345 
  #>
		try {
			$uri = "$global:url/configurations/$configId/publish_sets"
			$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
			$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
				} catch { 
					$global:errorResponse = $_.Exception
					$result = Show-RequestFailure			
				}
			return $result
			}
			
function Get-PublishedURLDetails ([string]$url) {
<#
    .SYNOPSIS
      Get published URL details
    .SYNTAX
       Get-PublishedURLDetails url
       Returns published url objects
    .EXAMPLE
      Get-PublishedURLDetails https://cloud.skytap.com/configurations/3125360/publish_sets/878322 
  #>
		try {
			$uri = $url
			$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
			$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
				} catch { 
					$global:errorResponse = $_.Exception
					$result = Show-RequestFailure			
				}
			return $result
			}

function Get-PublishedServices ([string]$configId, [string]$vmId, [string]$interfaceId){
<#
    .SYNOPSIS
      Get published services for an environment 
    .SYNTAX
       Get-PublishedServices configId vmId interfaceId
       Returns service(s) list object
    .EXAMPLE
      Get-PublishedURLs 12345 
  #>
			try {
			$uri = "$global:url/configurations/$configId/vms/$vmId/interfaces/$interfaceId/services"
			$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
			$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
				} catch { 
					$global:errorResponse = $_.Exception
					$result = Show-RequestFailure			
				}
			return $result
			}

function Get-VMs ([string]$configId, [string]$vm) {
<#
    .SYNOPSIS
      Get VMs for an environment 
    .SYNTAX
       Get-VMs configId [vmId]
       Returns vm(s) list object
    .EXAMPLE
    	  All VMs in an environment
      Get-VMs 12345 
        Only specific VM details
      Get-VMs 12345 54321 
  #>
			try {
				if ($vm){
					$uri = "$global:url/configurations/$configId/vms/$vm"
				}else{
					$uri = "$global:url/configurations/$configId/vms"
				}
				$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
				$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					} catch { 
						$global:errorResponse = $_.Exception
						$result = Show-RequestFailure			
					}
				return $result
				}
				
function Get-VMUserData ([string]$configId, [string]$vm) {
<#
    .SYNOPSIS
      Get VM userdata ( part of metadata )
    .SYNTAX
       Get-VM configId vmId
       Returns vm userdata
    .EXAMPLE
      Get-VMUserdata 12345 54321 
  #>
			try {				
				$uri = "$global:url/configurations/$configId/vms/$vm/user_data"
				$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
				$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					} catch { 
						$global:errorResponse = $_.Exception
						$result = Show-RequestFailure			
					}
				return $result
				}

function Get-Projects ([string]$projectId,[string]$attributes,[string]$v2="T",[int]$startCount="100",[string]$qscope="company") {
<#
    .SYNOPSIS
      Get projects
    .SYNTAX
        Get-Projects
       Returns service(s) list object
    .EXAMPLE
       Get-Projects
  #>
   $more_records = $True
  		if ($v2 -eq 'T') {
				While ($more_records) {
  					try {
						if ($attributes){
							$uri = $global:url + '/v2/projects?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset + '&query=' + $attributes
						}else{
							if ($projectId){	
								$uri = $global:url + '/v2/projects/' + $projectId
							}else{
								$uri = $global:url + '/v2/projects?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset
								}
							}
						write-host $uri
						$result = Invoke-WebRequest -Uri $uri -Method GET -ContentType 'application/json' -Headers $global:headers 
										
							} catch { 
								$global:errorResponse = $_.Exception
								$result = Show-RequestFailure		
							}
						if ($result.StatusCode -ne 200) {
							write-host $result.StatusCode
							write-host $result.StatusDescription
									return
									}
						
						$hold_result = $hold_result + (ConvertFrom-Json $result.Content)
						$hdr = $result.headers['Content-Range']
						#write-host "header" $hdr
						if ($hdr.length -gt 0) {
							$hcounters = $hdr.Split('-')[1]
							[Int]$lastItem,[int]$itemTotal = $hcounters.Split('/')
							write-host "counts " $lastItem $itemTotal
							if (($lastItem + 1)  -lt ($itemTotal)){                                         
								$global:tOffset = $lastItem + 1
							}
							else 
							{
								$more_records = $False
							}
						}
						else 
						{
							$more_records = $False
						}
					}
					$result =  $hold_result
					$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					$global:tOffset = 0
					return $result
				} else {
					try {
					if ($projectId){
						$uri = "$global:url/projects/$projectId"
					}else{
						$uri = "$global:url/projects"
					}
					$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
					$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
						} catch { 
							$global:errorResponse = $_.Exception
							$result = Show-RequestFailure			
						}
				return $result
				}
}

function Get-ProjectEnvironments ([string]$projectId){
<#
    .SYNOPSIS
      Get all environments for a project
    .SYNTAX
        Get-ProjectEnvironments projectId
       Returns Environment(s) list object
    .EXAMPLE
       Get-ProjectConfiguration 654321
  #>
 			try { 
				$uri = "$global:url/projects/$projectId/configurations"
	
				$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
				$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					} catch { 
						$global:errorResponse = $_.Exception
						$result = Show-RequestFailure			
					}
				return $result
				}
		
				
function Get-Users ([string]$userId,[string]$attributes,[string]$v2="T",[int]$startCount="100",[string]$qscope="company")  {
<#
    .SYNOPSIS
      Get all users
    .SYNTAX
        Get-Users
       Returns users list object
    .EXAMPLE
       Get-Users
  #>
   $more_records = $True
  		if ($v2 -eq 'T') {
				While ($more_records) {
  					try {
						if ($attributes){
							$uri = $global:url + '/v2/users?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset + '&query=' + $attributes
						}else{
							if ($userId){	
								$uri = $global:url + '/v2/users/' + $userId
							}else{
								$uri = $global:url + '/v2/users?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset
								}
							}
						write-host $uri
						$result = Invoke-WebRequest -Uri $uri -Method GET -ContentType 'application/json' -Headers $global:headers 
										
							} catch { 
								$global:errorResponse = $_.Exception
								$result = Show-RequestFailure		
							}
						if ($result.StatusCode -ne 200) {
							write-host $result.StatusCode
							write-host $result.StatusDescription
									return
									}
						
						$hold_result = $hold_result + (ConvertFrom-Json $result.Content)
						$hdr = $result.headers['Content-Range']
						#write-host "header" $hdr
						if ($hdr.length -gt 0) {
							$hcounters = $hdr.Split('-')[1]
							[Int]$lastItem,[int]$itemTotal = $hcounters.Split('/')
							write-host "counts " $lastItem $itemTotal
							if (($lastItem + 1)  -lt ($itemTotal)){                                         
								$global:tOffset = $lastItem + 1
							}
							else 
							{
								$more_records = $False
							}
						}
						else 
						{
							$more_records = $False
						}
					}
					$result =  $hold_result
					$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					$global:tOffset = 0
					return $result
		}else{
			try {
				if ($userId){
					$uri = "$global:url/users/$userId"
				}else{
					$uri = "$global:url/users"
				}
				$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
				$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					} catch { 
						$global:errorResponse = $_.Exception
						$result = Show-RequestFailure			
					}
				return $result
				}
		}
		
Set-Alias Get-User Get-Users
				
function Get-Configurations ([string]$configId, [string]$attributes,[string]$v2="T",[int]$startCount="100",[string]$qscope="company") {
<#
    .SYNOPSIS
      Get environment(s)
    .SYNTAX
       Get-Configurations [configId]
       Returns environment(s) list object
    .EXAMPLE
    	  All environments
      Get-Configurations
        Only specific environment details
      Get-Configurations 12345
  #>
  $more_records = $True
  		if ($v2 -eq 'T') {
				While ($more_records) {
  					try {
						if ($attributes){
							$uri = $global:url + '/v2/configurations?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset + '&query=' + $attributes
						}else{
							if ($configId){	
								$uri = $global:url + '/v2/configurations/' + $configId
							}else{
								$uri = $global:url + '/v2/configurations?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset
								}
							}
						write-host $uri
						$result = Invoke-WebRequest -Uri $uri -Method GET -ContentType 'application/json' -Headers $global:headers 
										
							} catch { 
								$global:errorResponse = $_.Exception
								$result = Show-RequestFailure2($errorResponse)			
							}
						if ($result.StatusCode -ne 200) {
							write-host $result.StatusCode
							write-host $result.StatusDescription
									return
									}
						
						$hold_result = $hold_result + (ConvertFrom-Json $result.Content)
						$hdr = $result.headers['Content-Range']
						#write-host "header" $hdr
						if ($hdr.length -gt 0) {
							$hcounters = $hdr.Split('-')[1]
							[Int]$lastItem,[int]$itemTotal = $hcounters.Split('/')
							write-host "counts " $lastItem $itemTotal
							if (($lastItem + 1)  -lt ($itemTotal)){                                         
								$global:tOffset = $lastItem + 1
							}
							else 
							{
								$more_records = $False
							}
						}
						else 
						{
							$more_records = $False
						}
					}
					$result =  $hold_result
					$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					$global:tOffset = 0
					return $result
				} else {
					
					try {
					if ($configId){
						$uri = "$global:url/configurations/$configId"
					}else{
						$uri = "$global:url/configurations"
					}
					$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
					$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
						} catch { 
							$global:errorResponse = $_.Exception
							$result = Show-RequestFailure			
						}
					return $result
				}
			}
Set-Alias Get-Environments Get-Configurations
Set-Alias Get-Environment Get-Configurations
Set-Alias Get-Configuration Get-Configurations
				
function Get-Templates ([string]$templateId, [string]$attributes,[string]$v2='T',[int]$startCount="100",[string]$qscope='company') {
<#
    .SYNOPSIS
      Get template(s) optionally filter by attributes
    .SYNTAX
      Get-Templates [templateId] [attribute value pairs]
       Returns template(s) list object
    .EXAMPLE
    	  All templates
    	  	Get-Templates
    	  	
         Only templates that are non-public in US-West
         	Get-Templates -attributes "public=False,region=USWest"
         	
        Only specific template details
        	Get-Templates 12345
  #>
  		$more_records = $True
  		if ($v2 -eq 'T') {
				While ($more_records) {
  					try {
						if ($attributes){
							$uri = $global:url + '/v2/templates?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset + '&query=' + $attributes
						}else{
							if ($templateId){	
								$uri = $global:url + '/v2/templates/' + $templateId
							}else{
								$uri = $global:url + '/v2/templates?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset
								}
							}
						write-host $uri
						$result = Invoke-WebRequest -Uri $uri -Method GET -ContentType 'application/json' -Headers $global:headers 
										
							} catch { 
								$global:errorResponse = $_.Exception
								$result = Show-RequestFailure		
							}
						if ($result.StatusCode -ne 200) {
							write-host $result.StatusCode
							write-host $result.StatusDescription
									return
									}
						$hold_result = $hold_result + (ConvertFrom-Json $result.Content)
	
						$hdr = $result.headers['Content-Range']
						
						if ($hdr.length -gt 0) {
							$hcounters = $hdr.Split('-')[1]
							[Int]$lastItem,[int]$itemTotal = $hcounters.Split('/')
							
							if (($lastItem + 1)  -lt ($itemTotal)){                                         
								$global:tOffset = $lastItem + 1
							}
							else 
							{
								$more_records = $False
							}
						}
						else 
						{
							$more_records = $False
						}
					}
					write-host $hold_result.count
					$result =  $hold_result
					$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					$global:tOffset = 0
					return $result
					
				} else {
					try {
						if ($templateId){	
							$uri = "$global:url/templates/$templateId"
						}else{
							$uri = "$global:url/templates"
							}
					$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
					$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
						} catch { 
							$global:errorResponse = $_.Exception
							$result = Show-RequestFailure			
						}
					return $result
					}
			}
Set-Alias Get-Template Get-Templates

function Add-Schedule ([string]$stype="config",[string]$objectId, [string]$title, $scheduleActions,[string]$startAt,$recurringDays,[string]$endAt,[string]$timezone="Pacific Time (US & Canada)",[string]$deleteAtEnd,[string]$newConfigName) {
<#
    .SYNOPSIS
      Create a schedule
    .SYNTAX
      Add-Schedule $stype $objectId $title $scheduleActions $startAt $recurringDays $endAt $timezone $deleteAtEnd $newConfigName
       Returns schedule object
    .EXAMPLE
    	   Add-Schedule -objectId <template or environment Id> -title "Eight to Five" -scheduleActions [action hash] -startAt "2013/09/09 09:00" -endAt "2013/10/09 0900" -timezone "Central Time (US & Canada)" -deleteAtEnd $True
#>    
   	
		$uri = "$global:url/schedules"
			
			$body = @{
					title = $title					
					start_at = $startAt
					time_zone = $timezone
					actions = @( $scheduleActions )
					}
							
			if ($stype -eq 'config') { 
				$body.add("configuration_id",$objectId)
			}else{
				$body.add("template_id",$objectId)
			}
			if ($endAt) { $body.add("end_at",$endAt) }
			if ($recurringDays) { $body.add("recurring_days",$recurringDays) }
			if ($deleteAtEnd) { $body.add("delete_at_end",$True) }
		#write-host (ConvertTo-Json $body)
		try {
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}
	
function Get-PublicIPs ([string]$configId) {
<#
    .SYNOPSIS
      Get Public IP table
    .SYNTAX
       Get-PublicIPs
       Returns list of IPs
    .EXAMPLE
      Get-PublicIPs
  #>
		try {
			$uri = "$global:url/ips"
			$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
			$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
				} catch { 
					$global:errorResponse = $_.Exception
					$result = Show-RequestFailure			
				}
			return $result
	}
	
function Get-Schedules ([string]$scheduleId, [string]$attributes,[string]$v2='T',[int]$startCount="100",[string]$qscope='admin') {
<#
    .SYNOPSIS
      Get Schedules
    .SYNTAX
       Get-Schedules
       Returns list of Schedules
    .EXAMPLE
      Get-Schedules
      Get-Schedule 1234
  #>
   $more_records = $True
  		if ($v2 -eq 'T') {
				While ($more_records) {
  					try {
						if ($attributes){
							$uri = $global:url + '/v2/schedules?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset + '&query=' + $attributes
						}else{
							if ($configId){	
								$uri = $global:url + '/v2/schedules/' + $scheduleId
							}else{
								$uri = $global:url + '/v2/schedules?scope=' + $qscope + '&count=' + $startCount + '&offset=' + $global:tOffset
								}
							}
						write-host $uri
						$result = Invoke-WebRequest -Uri $uri -Method GET -ContentType 'application/json' -Headers $global:headers 
										
							} catch { 
								$global:errorResponse = $_.Exception
								$result = Show-RequestFailure2($errorResponse)			
							}
						if ($result.StatusCode -ne 200) {
							write-host $result.StatusCode
							write-host $result.StatusDescription
									return
									}
						
						$hold_result = $hold_result + (ConvertFrom-Json $result.Content)
						$hdr = $result.headers['Content-Range']
						#write-host "header" $hdr
						if ($hdr.length -gt 0) {
							$hcounters = $hdr.Split('-')[1]
							[Int]$lastItem,[int]$itemTotal = $hcounters.Split('/')
							write-host "counts " $lastItem $itemTotal
							if (($lastItem + 1)  -lt ($itemTotal)){                                         
								$global:tOffset = $lastItem + 1
							}
							else 
							{
								$more_records = $False
							}
						}
						else 
						{
							$more_records = $False
						}
					}
					$result =  $hold_result
					$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					$global:tOffset = 0
					return $result
				} else {
					try {
						if ($scheduleId) {
							$uri = "$global:url/schedules/" + $scheduleId 
						} else {
						$uri = "$global:url/schedules" }
						$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
						$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
							} catch { 
								$global:errorResponse = $_.Exception
								$result = Show-RequestFailure			
							}
						return $result
	}
}
Set-Alias Get-Schedule Get-Schedules
	
function Connect-PublicIP ([string]$vmId, [string]$interfaceId,[string]$publicIP){
<#
    .SYNOPSIS
      Connect Public IP to network
    .SYNTAX
       Connect-Network Source-Network Destination-Network
    .EXAMPLE
      Connect-Network 78901 10987
  #>
  write-host $publicIP
	try {
		$uri = "$global:url/vms/$vmId/interfaces/$interfaceId/ips"
		write-host $uri
		$body = @{
				ip = $publicIP
			}
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
			} catch {
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure		
		}
	return $result
	}
	
function Update-AutoSuspend ( [string]$configId, [string]$suspendOnIdle ){
<#
   .SYNOPSIS
     Change an environment's auto-suspend setting, null = off, 300-86400 is valid range.
   .SYNTAX
      Update-AutoSuspend ConfigId NumberOfSeconds
   .EXAMPLE
     Update-RunState 12345 300
 #>
    try {
        $uri = "$url/configurations/$configId"
        
        $body = @{
            suspend_on_idle = $suspendOnIdle
        }
        $result = Invoke-RestMethod -Uri $uri -Method PUT -Body (ConvertTo-Json $body)  -ContentType "application/json" -Headers $headers 
        $result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
            } catch { 
                $global:errorResponse = $_.Exception
                $result = Show-RequestFailure        
        }
    return $result
    }

function Add-UserToProject( [string]$projectId, [string]$userId,[string]$projectRole="participant" ){
<#
    .SYNOPSIS
      Add a user to a project
    .SYNTAX
        Add-UserToProject projectID userID [project-role]
       Return
    .EXAMPLE
      Add-UserToProject 123344 3828 viewer
      ---
      New-Project -projectName "Global Training" -projectDescription "A project for global training"
  #>
	try {
		$uri = "$global:url/projects/$projectId/users/$userId"
		$body = @{
				role = $projectRole
				}
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}
function Add-UserToGroup( [string]$groupId, [string]$userId ){
<#
    .SYNOPSIS
      Add a user to a group
    .SYNTAX
        Add-UserToProject groupID userID 
       Return
    .EXAMPLE
      Add-UserToGroup 123344 3828 
  #>
	try {
		$uri = "$global:url/groups/$groupId/users/$userId"
		$result = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json $body) -ContentType "application/json" -Headers $global:headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0

			} catch { 
				$global:errorResponse = $_.Exception
				$result = Show-RequestFailure			
			}
		return $result
	
	}

Export-ModuleMember -function * -alias *

			


