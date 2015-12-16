import-module showui      # get showui here:  https://gallery.technet.microsoft.com/ShowUI-ca29b08f
import-module skytap

$global:userid = ''
$global:environmentID = ''
$global:region = ''
$global:selectedIface = ''
write-host 'Getting Skytap details' 
write-host "Loading Users"
$users =  Get-Users
$ulookup = $users | foreach { $_.id + '  ' + $_.last_name + ',' + $_.first_name }
write-host "Loading Templates"
$templates = Get-Templates 
$tlookup = $templates | foreach { $_.id + '   ' + $_.name }

write-host "Creating window"
New-window -SizeToContent WidthAndHeight -show {
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
			New-TextBox -Name "expDate"  -On_Loaded { $this.text = (Get-Date).AddDays(30).tostring("yyyy/MM/dd HH:mm") }
		 } -On_Loaded { $ProjectName.Focus() } # uniform grid
		 
	
		New-TextBox  -Name "userMessages" -Column 0 -Row 2 -margin "0,5,5,0" -Foreground Red -Fontweight Bold		
	
	stackpanel -name 'bottomPanel' -Orientation Horizontal -Column 0 -Row 3 -margin 5 {
		
		New-Button "Change Date"  -On_Click {
			$pd = New-DatePicker -show
			$expDate.text = get-date -date $pd -format "yyyy/MM/dd HH:mm"
			}
				#stackpanel {
				#Select-Date -name "expiresOn" 
				#New-Button "  Select  " -On_Click { 
					#$expDate.text = ${expiresOn}.tag
					#Close-Control 
					#}
			#} -show
		#}
		
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
		
		New-Button "Add Public IP" -name 'ipButton' -On_Loaded { 
				${ipButton}.visibility = 'hidden'
			}-On_Click { 
			$userMessages.text = 'Getting available public IPs'
			$vms = Get-VMs $global:environmentID
			$ilookup = $vms.interfaces | foreach { $_.id + ' ' + $_.ip + ' ' + $_.vm_name}
			$ips = Get-PublicIPs $global:environmentID
			$nextPIP = $ips | foreach { if ( $_.nics.count -eq 0 -and $_.region -eq $global:region -and $_.vpn_id.length -eq 0) {$_.id}} | Select-Object -first 1
			$userMessages.text = "Next available Public IP is $nextPIP"
			
			Grid -name "Select_Interface" -controlName 'SI' -Columns 1 -Rows 2 -Width 200 -show {
				
				New-ComboBox -Name 'SelectedInterface' -Column 0 -IsTextSearchEnabled:$true -Items $ilookup  -On_DropDownClosed {
					$ifSelected = $SelectedInterface.text
					$ifsplit = $ifSelected.split(" ")
					$global:selectedIface = $ifsplit[0]
					 }
				New-Button "Assign" -Column 0 -Row 1 -On_Click {
					$nid = $global:selectedIface
					$nid = $nid.trim()
					$ifaces = $vms | foreach { $_.interfaces }
					$vid = $ifaces | foreach {if ($_.id -match $nid){$_.vm_id}}
					$response = assignPublicIP -vmId $vid -interfaceId $nid -ip $nextPIP  
					${userMessages}.text = "Attached $nextPIP " 				
					Close-Control 
				}
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
		$global:environmentID = submitRequest -projectName $ProjectName.text -templateID $SelectedTemplate.text -endDate ${expDate}.text
		${subButton}.visibility = 'hidden'
		${ipButton}.visibility = 'visible'
		${nuButton}.visibility = 'hidden'
		${userMessages}.text = "Demo setup complete.  You can now add a Public IP"
			}
			
	New-Label "    " 
	
	New-Button "  Quit  "  -On_Click { 
		write-host ${ProjectName}.text
		write-host $global:environmentID
		write-host $global:userid
		write-host $global:pURL
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
			$global:region = $response.region
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
		write-host "assign" $vmId, $interfaceId, $ip 
		$response = Connect-PublicIP -vmId $vmId -interfaceId $interfaceId -publicIP $ip
		if ($response.requestResultCode -eq 0) {
			return $response.id
		}
	}
	function Global:submitRequest ($projectName, $templateID, $endDate) {
             	 	write-host "Creating Project"
			$projectId = createProject $projectName
			write-host "Project ID $projectId"
			write-host "Creating Environment - please wait"
			$environmentId = createEnvironment $templateID
			sleep 30
			write-host "Environment ID $environmentId"
			$success = addEnvironmentToProject $environmentId $projectId
			write-host "Envionment added to project"
			$success = addProjectUser $projectId $global:userid
			write-host "User added to project"
			$global:pURL = createPubURL $environmentId
			write-host "Published URL is $global:pURL"
			$endAt =  $endDate
			$startAt = (Get-Date).AddDays(1).tostring("yyyy/MM/dd HH:mm")
			write-host "Creating schedule to delete on $endAt"
			$schDelete = Add-Schedule -stype 'config' -objectId $environmentId -title "$ProjectName.text cleanup" -startAt $startAt -endAt $endAt -deleteAtEnd $True
			write-host "Schedule Created"
			return $environmentId
		}
	}  
	

#new-datepicker -show