#PeopleIT 
#
#Run from a machine on the local network.
#
# Given a list of users and domain admin credentials, resets all user passwords to "Welcome2019" and sets their account to "change password at next logon."


# Setting up module
Import-Module -Name ActiveDirectory


#Gathering DC name and Credentials

$adcredentials = Get-Credential
$dc = Read-Host -prompt 'Enter the FQDN of a domain controller on the network.'
$users = Get-Content "users.txt"



#Create a new powershell remote session to the domain controller

$session = New-PSSession -ComputerName $dc -Credential $adcredentials




# Change passwords for each user based on list
Invoke-Command -Session $session -ScriptBlock {
	foreach($username in $args[0]) {
		$resetuser = Get-ADUser $username
		if ($resetuser) {
			Set-AdAccountPassword $resetuser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Welcome2019" -Force)
			Set-ADUser $resetuser -ChangePasswordAtLogon $true
		}
	}
} -ArgumentList $users


