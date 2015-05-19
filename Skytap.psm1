if ($PSBoundParameters['Debug']) {
	$DebugPreference = 'Continue'
}

$username = "john.doe@skytap.com"
$password = "_put_your_token_here_"
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

function Add-ConfigurationToProject ($configId, $projectId ){

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

function Update-RunState ( $configId, $newstate ){

	try {
		$uri = "$url/configurations/$configId?runstate=$newstate"
		$result = Invoke-RestMethod -Uri $uri -Method PUT -ContentType "application/json" -Headers $headers 
		$result | Add-member -MemberType NoteProperty -name requestResultCode -value 0
			} catch { 
				$errorResponse = $_.Exception.Response
				$result = Show-APIFailure($errorResponse)		
		}
	return $result
	}

function Connect-Network ($sourceNetwork, $destinationNetwork){

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


function New-EnvironmentfromTemplate ( $templateId ){

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



function Publish-URL ($configId, $ptype, $pname) { 
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

function Save-ConfigurationToTemplate ($configId, $tname) {
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

function Remove-Configuration ($configId) {
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

function Add-TemplateToProject ($projectId, $templateId) {
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

function Add-TemplateToConfiguration ($configId, $templateId) {
		
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

function Publish-Service ($configId, $vmId, $interfaceId, $serviceId, $port) {
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

function Get-PublishedURLs ($configId) {
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

function Get-PublishedServices ($configId, $vmId, $interfaceId){
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

function Get-VMs ($configId, $vm) {
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

function Get-Projects ($projectId){
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

function Get-Users ($userId) {	
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

function Get-Configurations ($configId) {
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

