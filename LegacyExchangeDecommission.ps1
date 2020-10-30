 #create directories referenced in this script:
#-force will create the entire path if it doesn't exist already...
New-Item -ItemType Directory -Force -Path C:\Utils\PerUserFiles

#start a log file so we can see console output later on and see what's f'd up...
Start-Transcript C:\Utils\PowershellUpdateLog.txt

#activate force powers so we an do cool stuff
import-module ActiveDirectory
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010

#create some junk so we know what we broke later on
Get-Aduser -Filter * -SearchBase ("OU=Employees,OU=Domain Users,DC=ad,DC=peopleit,DC=com") -Properties * | select samaccountname, mail, mailNickname, @{L = "ProxyAddresses"; E = { $_.ProxyAddresses -join ","}} | Export-Csv -Path c:\utils\proxyAddressexport.csv -NoTypeInformation

#create a txt backup file for user attributes in case we want to look at any later on...
$peruserfiles = Get-Aduser -Filter * -SearchBase ("OU=Employees,OU=Domain Users,DC=ad,DC=peopleit,DC=com") -Properties * | select -ExpandProperty samaccountname
foreach($peruserfile in $peruserfiles){
get-aduser $peruserfile -Properties * | fl | Out-File "c:\utils\PerUserFiles\$peruserfile.txt"
}

#import one of the files to work with
$users = Import-Csv C:\utils\proxyAddressexport.csv

#find users that were hidden before so we can make sure we put that back later on...
$hiddenusers = get-aduser -filter {msExchhidefromAddressLists -eq '$True'} -searchbase ("OU=Employees,OU=Domain Users,DC=ad,DC=peopleit,DC=com") -properties * | select -ExpandProperty samaccountname

#use our witchcraft / force powers to do some cool stuff
foreach($user in $users){
Write-host "Found User " $user.samaccountname "in working file, now attempting to disable their mailbox and update their info..."
Write-Host "Found Mailbox for:"
get-mailbox $user.mailNickname
Write-Host "Now disabling..."
disable-mailbox $user.mailNickname
Write-Host "Found AD User for:"
get-aduser $user.samaccountname
Write-Host "Attempting to put back stuff that was removed..."
Set-ADUser $user.samaccountname -mail $user.mail -mailNickname $user.mailNickname -Add @{Proxyaddresses=$user.Proxyaddresses -split ","}
}

#take the list of hidden users we captured before, and make sure they are hidden now
foreach($hiddenuser in $hiddenusers){
set-aduser $hiddenuser -msExchHidefromAddressLists $True
}


Stop-Transcript 
