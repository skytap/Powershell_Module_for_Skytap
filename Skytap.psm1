if ($PSBoundParameters['Debug']) {
	$DebugPreference = 'Continue'
}

$username = "mike.measel@gmail.com"
$password = "b035e25ae13ee5fa0f2e53d2fe13991a328f90fc"
$auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$global:url = "https://cloud.skytap.com"
$global:headers = @{"Accept" = "application/json"; Authorization=("Basic {0}" -f $auth)}


function Show-APIFailure ($eresp) {

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
	return $nob
	

}	

function Set-runstateColor {
	switch ($global:vm_state)
	{
		"running" { $global:mcolor = "green" }
		"suspended" { $global:mcolor = "yellow" }
		"stopped" { $global:mcolor = "red" }
		"busy" { $global:mcolor = "purple" }
	}
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
				$errorResponse = $_.Exception.Response
				$result = Show-APIFailure($errorResponse)		
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
				$errorResponse = $_.Exception.Response
				$result = Show-APIFailure($errorResponse)		
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
				$errorResponse = $_.Exception.Response
				$result = Show-APIFailure($errorResponse)		
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
				$errorResponse = $_.Exception.Response
				$result = Show-APIFailure($errorResponse)			
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
					$errorResponse = $_.Exception.Response
					$result = Show-APIFailure($errorResponse)			
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
					$errorResponse = $_.Exception.Response
					$result = Show-APIFailure($errorResponse)		
			}
			return $result
		}

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
					$errorResponse = $_.Exception.Response
					$result = Show-APIFailure($errorResponse)		
			}
			return $result
		}

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
				$errorResponse = $_.Exception.Response
				$result = Show-APIFailure($errorResponse)		
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
				$errorResponse = $_.Exception.Response
				$result = Show-APIFailure($errorResponse)			
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
					$errorResponse = $_.Exception.Response
					$result = Show-APIFailure($errorResponse)			
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
					$errorResponse = $_.Exception.Response
					$result = Show-APIFailure($errorResponse)			
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
					$errorResponse = $_.Exception.Response
					$result = Show-APIFailure($errorResponse)			
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
						$errorResponse = $_.Exception.Response
						$result = Show-APIFailure($errorResponse)			
					}
				return $result
				}

function Get-Projects ([string]$projectId){
<#
    .SYNOPSIS
      Get projects
    .SYNTAX
        Get-Projects
       Returns service(s) list object
    .EXAMPLE
       Get-Projects
  #>
				try {
				if ($projectId){
					$uri = "$global:url/projects/$projectId"
				}else{
					$uri = "$global:url/projects"
				}
				$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
				$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					} catch { 
						$errorResponse = $_.Exception.Response
						$result = Show-APIFailure($errorResponse)			
					}
				return $result
				}

function Get-Users ([string]$userId) {
<#
    .SYNOPSIS
      Get all users
    .SYNTAX
        Get-Users
       Returns users list object
    .EXAMPLE
       Get-Users
  #>
			try {
				if ($userId){
					$uri = "$global:url/users/$userId"
				}else{
					$uri = "$global:url/users"
				}
				$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
				$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					} catch { 
						$errorResponse = $_.Exception.Response
						$result = Show-APIFailure($errorResponse)			
					}
				return $result
				}

function Get-Configurations ([string]$configId) {
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
				try {
				if ($configId){
					$uri = "$global:url/configurations/$configId"
				}else{
					$uri = "$global:url/configurations"
				}
				$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
				$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					} catch { 
						$errorResponse = $_.Exception.Response
						$result = Show-APIFailure($errorResponse)			
					}
				return $result
				}
				
function Get-Templates ([string]$templateId, [string]$attributes) {
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
			try {
				if ($attributes){
					$uri = "$global:url/templates?$attributes"
				}else{
					if ($templateId){	
						$uri = "$global:url/templates/$templateId"
					}else{
						$uri = "$global:url/templates"
						}
					}
				$result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers $global:headers 
				$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
					} catch { 
						$errorResponse = $_.Exception.Response
						$result = Show-APIFailure($errorResponse)			
					}
				return $result
				}	


