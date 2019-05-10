#PeopleIT
#
#Use this script to find the on-premise AD account source anchor for a user when trying to match them to their MS Online user. Once you get the source anchor, you can run the set-msoluser -UserPrincipalName <email address> -ImmutableId <id from this script> to make sure there is a hard match when they are moved to the syncing OU.
Connect-MsolService

# Name of the person you are looking for in AD
$TT_DomainUser = Read-Host -prompt 'Enter AD username' # Active Directory Account to look for.
$TT_UserPrincipalName  = Read-Host -prompt 'Enter Email address' # Cloud account to look for

# Look up the account and get the GUID in Active Directory
$TT_GUID = (Get-ADUser $TT_DomainUser).objectGUID
Write-Host "AD GUID is: " $TT_GUID

# Convert the GUID to Base 64
 if ($TT_GUID) { # If we where able to find the AD Account. Do this.
   $guid = [GUID]$TT_GUID
   $bytearray = $guid.tobytearray()
   $AD_immutableID = [system.convert]::ToBase64String($bytearray)
 }
 
Write-Host $AD_immutableID "<-- This is what the Cloud Immutable ID should look like. Created from the AD GUID."

# Look up the user in the Cloud
$TT_ValidCloudUser = Get-MsolUser -UserPrincipalName $TT_UserPrincipalName 
# Stick the Immutable ID of the Cloud account into another Variable
$Cloud_ImmutableId = $TT_ValidCloudUser.ImmutableId

Write-Host $Cloud_ImmutableId "<-- This is the Cloud Immutable ID "

$update = Read-Host -prompt 'Would you like to update the Cloud Immutable ID for this user? (y/n)'

if ($update -eq "y") {
	Set-Msoluser -UserPrincipalName $TT_UserPrincipalName
