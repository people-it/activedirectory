#PeopleIT 
#
#Run from a machine on the local network.
#
# Given an OU of users and domain admin credentials, resets all user passwords to "Welcome2019" and sets their account to "change password at next logon."


# Setting up module
Import-Module -Name ActiveDirectory


#Gathering DC name and Credentials

$adcredentials = Get-Credential
$dc = Read-Host -prompt 'Enter the FQDN of a domain controller on the network.'


#Create a new powershell remote session to the domain controller

$session = New-PSSession -ComputerName $dc -Credential $adcredentials


#Grab OUs that exist on the domain and print them out

$presentous = Invoke-Command -Session $session -ScriptBlock {
	Get-ADOrganizationalUnit -Filter * -Properties CanonicalName | Select-Object -Property CanonicalName
}

Write-Host $presentous

$selectedous = @()
do {
 $input = (Read-Host "Enter OU names, one at a time. (Type the name, press enter. Press enter with a blank line when complete).")
 if ($input -ne '') {$selectedous += $input}
}
until ($input -eq '')



 

