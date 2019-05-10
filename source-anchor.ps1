#PeopleIT
#
#Use this script to find the on-premise AD account source anchor for a user when trying to match them to their MS Online user. Once you get the source anchor you can run the set-msoluser -UserPrincipalName <email address> -ImmutableId <id from this script> to make sure there is a hard match when they are moved to the syncing OU.



# Instructions and introduction


Read-Host -prompt 'Welcome. You can use this script to retrieve and update the Source Anchor for a user who exists in On-premise AD and MS Online/Office 365. This script is particularly useful when you need to update the source anchor of a users 365 online directory account to match with a local source anchor, so that when you add them to a synching OU, a hard match occurs in Office365. Please make sure you update the users UPN and proxy addresses to match whatever is in Office365 Exchange Online Today. You will be prompted for Office365 tenant credentials next. Please make sure you are running this on the domain controller with Azure AD Sync installed.'



#Connect to the Microsoft online service (with tenant credentials).

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
# Put the Immutable ID of the Cloud account into another Variable
$Cloud_ImmutableId = $TT_ValidCloudUser.ImmutableId
Write-Host $Cloud_ImmutableId "<-- This is the Cloud Immutable ID "


# Asking if the admin would like to update the CloudAnchor to match the local SourceAnchor to achieve hard match upon sync.

$update = Read-Host -prompt 'Would you like to update the Cloud Immutable ID for this user? (y/n)'
if ($update -eq "y") {
	Set-Msoluser -UserPrincipalName $TT_UserPrincipalName -ImmutableId $AD_immutableID
	Write-Host "User Source Anchor has been updated."
}	Else {
	Read-Host "Press any key to exit..."
	exit
}


#Continuing with additional user accounts if admin says so.

$continue = Read-Host -prompt 'Would you like to work on another user account? (y/n)'

if ($continue -eq "y") {
    #clearing variables
	$TT_DomainUser = ""
    $TT_UserPrincipalName = ""
    $TT_GUID = ""
    $guid = ""
    $bytearray = ""
    $AD_immutableID = ""
    $TT_ValidCloudUser = ""
    $Cloud_ImmutableId = ""
    
    # Repeat steps from above
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
    # Put the Immutable ID of the Cloud account into another Variable
    $Cloud_ImmutableId = $TT_ValidCloudUser.ImmutableId
    Write-Host $Cloud_ImmutableId "<-- This is the Cloud Immutable ID "


    # Asking if the admin would like to update the CloudAnchor to match the local SourceAnchor to achieve hard match upon sync.

    $update = Read-Host -prompt 'Would you like to update the Cloud Immutable ID for this user? (y/n)'
    if ($update -eq "y") {
	   Set-Msoluser -UserPrincipalName $TT_UserPrincipalName -ImmutableId $AD_immutableID
	   Write-Host "User Source Anchor has been updated."
    }
    
    