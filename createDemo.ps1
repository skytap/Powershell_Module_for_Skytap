import-module showui
import-module skytap

$global:userid = ''
write-host 'Getting Skytap details' 
write-host "Loading Users"
$users =  Get-Users
$ulookup = $users | foreach { $_.id + '  ' + $_.last_name + ',' + $_.first_name }
write-host "Loading Templates"
$templates = Get-Templates -v2 True
$tlookup = $templates | foreach { $_.id + '   ' + $_.name }

write-host "Creating window"
New-window -SizeToContent WidthAndHeight {
	New-Grid -Rows 4 -Children {
		Stackpanel -name "linky" { 
			textblock -Fontweight Bold -inlines {new-hyperlink "Skytap" -name "skytap" -NavigateUri "http://cloud.skytap.com" 
	 	 	 -on_requestnavigate {[diagnostics.process]::start($this.navigateuri.tostring())}
	 	 }
	     UniformGrid -ControlName 'Skytap Demo Select' -Column 0 -Row 1 -Columns 2 -Rows 4 {
	     	 	Label "Project Name" 
			New-TextBox -Name "ProjectName" 
			Label "Select User" 
			New-ComboBox  -Name 'SelectedUser'  -IsTextSearchEnabled:$true -Items $ulookup  -On_DropDownClosed {$global:userid = $SelectedUser.text}
			Label "Select demo template" 
			New-ComboBox  -Name 'SelectedTemplate'  -IsTextSearchEnabled:$true -Items $tlookup -On_DropDownClosed {$global:templateID = $SelectedTemplate.text} 	
			Label "Expires On" 
			New-TextBox -Name "expDate"  -On_Loaded { $this.text = (Get-Date).AddDays(30) }
		 } -On_Loaded { $ProjectName.Focus() } # uniform grid
		 
	
		New-TextBox  -Name "userMessages" -Column 0 -Row 2 -margin "0,5,5,0" -Foreground Red -Fontweight Bold		
	
	stackpanel -name 'bottomPanel' -Orientation Horizontal -Column 0 -Row 3 -margin 5 {
		
		New-Button "Select Date"  -On_Click {
				stackpanel {
				Select-Date -name "expiresOn" 
				New-Button "  Select  " -On_Click { 
					$expDate.text = ${expiresOn}.tag
					Close-Control 
					}
			} -show
		}
		
		New-Button "New User" -name 'nuButton'  -On_Click {
			UniformGrid -ControlName "AddUser" -Columns 2 -MinWidth 350 -Margin 5 { 
				New-Label "login"
				New-Textbox -Name loginName
				New-Label "first name"  
				New-Textbox -Name fname  
				New-Label "last name"  
				New-Textbox -name lname  
				New-Label "email"  
				New-Textbox -name email  
				New-Label " "
				New-Button "Submit" -On_Click { 
					$response = Add-User -loginName $loginName.text -firstName $fname.text -lastName $lname.text -email $email.text 
					if ($response.requestResultCode -eq 0) {
						$global:userid = $response.id 
						${userMessages}.text = "Selected user is " + $response.id + " " + $response.last_name + " " + $response.first_name
					}
					Close-Control }
			}-show
		}
		
		New-Button "Add Public IP" -name 'ipButton' -On_Loaded { ${ipButton}.visibility = 'hidden' } -On_Click { 	
			Grid -ControlName "APIP" {
				New-ComboBox -Name 'SelectedInterface' -Width 150 -IsTextSearchEnabled:$true -Items $ilookup  -On_DropDownClosed {$global:pubIP = $SelectedInterface.text}
				New-Button "Assign" -On_Click {
					$nid = $global:pubIP
					$vid = $vms.interfaces | foreach {if ($_.id -match $nid){$_.vm_id}}
					$response = assignPublicIP $vid $nid $nextPIP   
					if ($response.requestResultCode -eq 0) {
						${userMessages}.text = "Attached  $response.id" 
					}
					Close-Control }
				
		}  -On_Load { $ips = Get-PublicIPs $environmentId 
					$nextPIP = $ips | foreach { if ( $_.nics.count -eq 0) {$_.id }}			
		}
		
	}

	New-Button "   Submit   " -name 'subButton'  -On_Click {  
		
		${userMessages}.text = ""
		if (!$ProjectName.text) { $userMessages.text = 'Please enter a project name'
			return }
		if (!$global:userid) { ${userMessages}.text = 'Please select a user'
			return }
		if (!$SelectedTemplate.text) { ${userMessages}.text = 'Please select a demo template'
			return }

		$projectId = createProject $ProjectName.text
		${userMessages}.text = "Project ID $projectId"
		sleep 1
		${userMessages}.text = "Creating Environment - please wait"
		$environmentId = createEnvironment $SelectedTemplate.text
		sleep 30
		${userMessages}.text = "Environment ID $environmentId"
		$success = addEnvironmentToProject $environmentId $projectId
		${userMessages}.text = "Envionment added to project"
		$success = addProjectUser $projectId $global:userid
		${userMessages}.text = "User added to project"
		$pURL = createPubURL $environmentId
		${userMessages}.text = "Published URL is $pURL"
		$endAt =  $expDate.text.tostring("yyyy/MM/dd HH:mm")
		$startAt = (Get-Date.AddDays(1)).tostring("yyyy/MM/dd HH:mm")
		$schDelete = Add-Schedule -stype 'config' -objectId $environmentId -title "$ProjectName.text cleanup" -startAt $startAt -endAt $endAt -deleteAtEnd $True 
		${subButton}.visibility = 'hidden'
		${ipButton}.visibility = 'visible'
		${nuButton}.visibility = 'hidden'
		
			}
			
	New-Label "    " 
	
	New-Button "  Quit  "  -On_Click { 
		Get-ParentControl |
			Set-UIValue -passThru |
			Close-Control 
			}
			
		
	 }  # stackpanel

	 }
} # grid
	
} -On_Loaded {
	function Global:createNewUser ($login, $fname, $lname, $email ){
		$response = Add-User $login $fname $lname $email 
		if ($response.requestResultCode -eq 0) {
			return $response.id
		}
	}
	function Global:createProject ($name, $description) {
		$response = New-Project $name $description	
		if ($response.requestResultCode -eq 0) {
			return $response.id
		}
	}
	function Global:addProjectUser ($projectId, $userid){
		Add-UserToProject $projectId $userid
		if ($response.requestResultCode -eq 0) {
			return $response.id
		}
	}
	function Global:createEnvironment ($templateId){
		$response = New-EnvironmentFromTemplate $templateId
		if ($response.requestResultCode -eq 0) {
			return $response.id
		}
	}
	function Global:addEnvironmentToProject ($environmentId, $projectId){
		$response = Add-ConfigurationToProject $environmentId $projectId
		if ($response.requestResultCode -eq 0) {
			return 0
		}
	}
	function Global:createPubURL ($configId) {
		$response = Publish-URL -configId $configId
		if ($response.requestResultCode -eq 0) {
			return $response.url
		}
	}
	function Global:assignPublicIP ( $vmId, $interfaceId, $ip ){
		$response = Connect-PublicIP $vmId $interfaceId $ip
		if ($response.requestResultCode -eq 0) {
			return $response.id
		}
	}
	
	}  -show
	

#New-TextBox -Column 1 -Row 5 -Name 'UserID' -IsReadOnly:$True # -IsHidden:$True
#New-TextBox -Column 2 -Row 5 -Name 'ProjID' -IsReadOnly:$True -IsHidden:$True
#New-TextBox -Column 3 -Row 5 -Name 'TemplateID' -IsReadOnly:$True -IsHidden:$True
