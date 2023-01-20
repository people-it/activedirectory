#create directories referenced in this script:
#-force will create the entire path if it doesn't exist already...
New-Item -ItemType Directory -Force -Path C:\Utils\

#start a log file so we can see console output later on and see what's f'd up...
Start-Transcript C:\Utils\PowershellUpdateLog.txt

#activate force powers so we an do cool stuff
import-module ActiveDirectory

#create some backup records and junk so we know what we broke later on...update the SearchBase with the correct OU and add other attributes you want to export after the select statement if you want them too...
Get-Aduser -Filter * -SearchBase ("OU=Employees,OU=Domain Users,DC=ad,DC=peopleit,DC=com") -Properties * | select samaccountname, displayname, givenName, Surname, mail, company, office, telephonenumber, Fax, l, state, StreetAddress, postalCode, @{L = "ProxyAddresses"; E = { $_.ProxyAddresses -join ","}} | Export-Csv -Path c:\utils\ADuserExport.csv -NoTypeInformation

#import one of the files to work with
$users = Import-Csv C:\utils\ADuserExport.csv

#use our witchcraft / force powers to do some cool stuff, you need to make sure you have a password field in the csv file otherwise it won't set one and the script will fail, the export that creates the file won't have that field.
foreach($user in $users){
Write-host "Found User " $user.samaccountname "in working file, now attempting to create their account and update their info..." -ForegroundColor Yellow
Write-Host "Creating User Account for: $user.samaccountname" -ForegroundColor Yellow

foreach($user in $users){

    $name = $user.displayname
    $givenName = $user.givenName
    $Surname = $user.Surname
    $samaccountname = $user.samaccountname
    $userPrincipalName = $user.mail
    $emailaddress = $user.mail
    $AccountPassword = $user.password
    $company = $user.company
    $office = $user.office
    $officephone = $user.telephoneNumber
    $fax = $user.Fax
    $city = $user.l
    $state = $user.state
    $streetaddress = $user.Streetaddress
    $displayname = $user.displayname
    $postalcode = $user.postalCode

    $password = ConvertTo-SecureString -String $AccountPassword -AsPlainText –Force
   
    New-ADUser `
    -Name $name `
    -GivenName $givenName `
    -Surname $Surname `
    -SamAccountName $samaccountname `
    -UserPrincipalName $userPrincipalName `
    -EmailAddress $emailaddress `
    -AccountPassword $password `
    -ChangePasswordAtLogon $False `
    -PasswordNeverExpires $True `
    -Company $company `
    -OfficePhone $officephone `
    -Fax $fax `
    -Office $office `
    -State $state `
    -City $city `
    -StreetAddress $streetaddress `
    -DisplayName $displayname `
    -PostalCode $postalcode `
    -Enabled $True

    #add back proxy addresses from file
    Set-ADUser $user.samaccountname -Add @{Proxyaddresses=$user.Proxyaddresses -split ","}

    #confirm user exists by doing a lookup and displaying the results
    Write-Host "AD user: $samaccountname has been created..." -ForegroundColor Yellow
    Get-AdUser $samaccountname
    
    #wait for a few seconds in case someone needs to press stop
    Write-Host "Sleeping for 5 secondds...press ctrl+c to abort..." -ForegroundColor Cyan
    start-sleep -Seconds 5
    
    }

