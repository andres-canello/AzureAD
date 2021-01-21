<#
.SYNOPSIS
    Reports MFA status for O365 users.
.DESCRIPTION
    Reports MFA status for Office 365 users. Thist report doesn't take into account Conditional Access scenarios.
	Andres Canello https://twitter.com/andrescanello
	Version 0.1 - 10 August 2020
.NOTES
    THIS CODE-SAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED 
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR 
    FITNESS FOR A PARTICULAR PURPOSE.
    This sample is not supported under any Microsoft standard support program or service. 
    The script is provided AS IS without warranty of any kind. Microsoft further disclaims all
    implied warranties including, without limitation, any implied warranties of merchantability
    or of fitness for a particular purpose. The entire risk arising out of the use or performance
    of the sample and documentation remains with you. In no event shall Microsoft, its authors,
    or anyone else involved in the creation, production, or delivery of the script be liable for 
    any damages whatsoever (including, without limitation, damages for loss of business profits, 
    business interruption, loss of business information, or other pecuniary loss) arising out of 
    the use of or inability to use the sample or documentation, even if Microsoft has been advised 
    of the possibility of such damages, rising out of the use of or inability to use the sample script, 
    even if Microsoft has been advised of the possibility of such damages.
#>

$Results=@()

$ExportCSVReport=".\MFAReport_$((Get-Date -format yyyy-MMM-dd-ddd` hh-mm` tt).ToString()).csv" 
 
 
$allUsers = Get-MsolUser -All

$allUsers | ForEach-Object {

    switch ($_) {

        {$_.StrongAuthenticationRequirements.State -eq $Null}
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Disabled"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "N/A"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "N/A"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "MFANotRequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "Allowed"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue "AdminEnforceAndRegister"
            $Results += $obj
            Break
        } 
        
        # User has registered, admin set to Enabled
        {($_.StrongAuthenticationRequirements.State -eq "Enabled") -and ($_.StrongAuthenticationMethods.count -gt 0) -and (($_.StrongAuthenticationUserDetails -ne $Null) -or ($_.StrongAuthenticationPhoneAppDetails.count -gt 0))}
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Enabled"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "MethodsSet"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "DetailsSet"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "MFARequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "Allowed"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue "AdminEnforce"
            $Results += $obj
            Break
        } 
        
        # User has registered, admin set to Enabled, Methods cleared by admin (require re-registration)
        {($_.StrongAuthenticationRequirements.State -eq "Enabled") -and ($_.StrongAuthenticationMethods.count -eq 0) -and (($_.StrongAuthenticationUserDetails -ne $Null) -or ($_.StrongAuthenticationPhoneAppDetails.count -gt 0))}
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Enabled"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "MethodsNotSet"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "DetailsSet"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "RegistrationRequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "Allowed"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue "AdminEnforceAndRegister"
            $Results += $obj
            Break
        } 
    
        # Admin set to Enabled, Methods set by admin, no details. If Office or Mobile phone are set we fall back and user is required to MFA
        {($_.StrongAuthenticationRequirements.State -eq "Enabled") -and ($_.StrongAuthenticationMethods.count -gt 0) -and ($_.StrongAuthenticationUserDetails -eq $Null) -and ($_.StrongAuthenticationPhoneAppDetails.count -eq 0)}
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Enabled"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "MethodsSet"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "DetailsNotSet"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "MFARequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "Allowed"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue "AdminEnforce"
            $Results += $obj
            Break
        } 


        # Admin set to Enabled, user has not registered
        {($_.StrongAuthenticationRequirements.State -eq "Enabled") -and ($_.StrongAuthenticationMethods.count -eq 0) -and ($_.StrongAuthenticationUserDetails -eq $Null) -and ($_.StrongAuthenticationPhoneAppDetails.count -eq 0)}
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Enabled"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "MethodsNotSet"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "DetailsNotSet"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "RegistrationRequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "Allowed"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue "AdminEnforceAndRegister"
            $Results += $obj
            Break
        } 
    
        # User has registered
        {($_.StrongAuthenticationRequirements.State -eq "Enforced") -and ($_.StrongAuthenticationMethods.count -gt 0) -and (($_.StrongAuthenticationUserDetails -ne $Null) -or ($_.StrongAuthenticationPhoneAppDetails.count -gt 0))}
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Enforced"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "MethodsSet"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "DetailsSet"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "MFARequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "AllowedOnlyWithAppPassword"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue ""
            $Results += $obj
            Break
        } 

        # User has registered, Methods cleared by admin (require re-registration)
        {($_.StrongAuthenticationRequirements.State -eq "Enforced") -and ($_.StrongAuthenticationMethods.count -eq 0) -and (($_.StrongAuthenticationUserDetails -ne $Null) -or ($_.StrongAuthenticationPhoneAppDetails.count -gt 0))}
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Enforced"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "MethodsNotSet"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "DetailsSet"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "RegistrationRequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "AllowedOnlyWithAppPassword"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue "Register"
            $Results += $obj
            Break
        } 

        # Admin set to Enforced, Methods and contact phone set by admin
        {($_.StrongAuthenticationRequirements.State -eq "Enforced") -and ($_.StrongAuthenticationMethods.count -gt 0) -and ($_.StrongAuthenticationUserDetails -eq $Null) -and ($_.StrongAuthenticationPhoneAppDetails.count -eq 0)} 
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Enforced"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "MethodsSet"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "DetailsNotSet"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "MFARequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "AllowedOnlyWithAppPassword"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue ""
            $Results += $obj
            Break
        }


        # Admin set to Enforced, user has not registered
        {($_.StrongAuthenticationRequirements.State -eq "Enforced") -and ($_.StrongAuthenticationMethods.count -eq 0) -and ($_.StrongAuthenticationUserDetails -eq $Null) -and ($_.StrongAuthenticationPhoneAppDetails.count -eq 0)}
        { 
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Enforced"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "MethodsNotSet"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "DetailsNotSet"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "RegistrationRequired"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "AllowedOnlyWithAppPassword"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue "Register"
            $Results += $obj
            Break
        } 

        {$_}
        {
            $obj = New-Object -TypeName PSObject
            $obj | Add-Member -NotePropertyName "UserPrincipalName" -NotePropertyValue $_.UserPrincipalName
            $obj | Add-Member -NotePropertyName "UserDisplayName" -NotePropertyValue $_.DisplayName
            $obj | Add-Member -NotePropertyName "StrongAuthState" -NotePropertyValue "Unknown"
            $obj | Add-Member -NotePropertyName "StrongAuthMethods" -NotePropertyValue "Unknown"
            $obj | Add-Member -NotePropertyName "StrongAuthDetails" -NotePropertyValue "Unknown"
            $obj | Add-Member -NotePropertyName "ExpectedUserExperience" -NotePropertyValue "Unknown"
            $obj | Add-Member -NotePropertyName "LegacyAuthStatus" -NotePropertyValue "Unknown"
            $obj | Add-Member -NotePropertyName "RecommendedAction" -NotePropertyValue "Unknown"
            $Results += $obj
            Break
        }
    }

}
#$Results | Export-Csv -Path $ExportCSVReport -Notype
return $Results
