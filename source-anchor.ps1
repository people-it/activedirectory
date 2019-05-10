# Connect to the Cloud. Un-Remark if needed.
#Connect-MsolService

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
