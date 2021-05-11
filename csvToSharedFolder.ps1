#NetBIOS domain name. 
$domain = "domain name" 

#Path to list of users. 
$importFile = "C:\myfile.csv"

#Retrive users from csv file and loop through creating shares 
Import-Csv $importFile | ForEach-Object { 
	#Create User folder and set permissions if it does not exist 
	$userFolder = "\\$($_.Fileserver)\$($_.username)" 

	If(!(Test-Path -Path $userFolder)) 
	{ 
		new-item $userFolder -itemtype Directory 
		# Configure Remote Desktop Users Full Control access 
		$identity = "$domain\$($_.username)"
		$accessControlType = "Allow" 
		$fileSystemRights = [System.Security.AccessControl.FileSystemRights]"Modify" 
		$inheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
 		$propagationFlags = [System.Security.AccessControl.PropagationFlags]::None 

		# Configure the Access Control object 
		$ace = New-Object System.Security.AccessControl.FileSystemAccessRule($identity,$fileSystemRights,$inheritanceFlags,$propagationFlags,$accessControlType)
 
		# Retrieve the directory ACL and add a new ACL 
		$acl = Get-Acl $userFolder 
		$acl.AddAccessRule($ace) 
		$acl.SetAccessRuleProtection($false,$false) 

		# Add the ACL to the directory object 
		Set-Acl $userFolder $acl 
	} 
	else 
	{ 
		Write "Directory for $($_.username) already exist" 
	} 
	Get-Acl $userFolder | Fl
}
