param {
    [Parameter(
        HelpMessage="The environment the tenant and identities are created for.  It can be either 'Development' or 'Production'.",
        Mandatory=$true)]
    [Alias("env")]
    [ValidateSet("Development", "Production")]
    [string]$Environment
}
  
function InitializeMicrosoftGraph()
{
    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Import-Module Microsoft.Graph.Applications -ErrorAction Stop    

    Import-Module Microsoft.Graph.Users -ErrorAction Stop
    Import-Module Microsoft.Graph.Users.Actions -ErrorAction Stop
    Import-Module Microsoft.Graph.Users.Functions -ErrorAction Stop

    Import-Module Microsoft.Graph.Groups -ErrorAction Stop
}  

function CreateTruelyRandomPassword()
{
    # This function always creates passwords with 24
    [uint] $passwordLengthInCharacters = 24
    
    [char[]] $alphaNumericCharacters = 
        (
            '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',

            'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
            'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',

            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
            'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
        )

    [string] $newPassword = $alphaNumericCharacters | Get-SecureRandom
}

function IsThereAnEqualChanceEachCharacterCouldBeSelected([byte] $passwordCharacterIndex, [int] $numberOfPossibleCharacters)
{
    [int] $TotalNumberOfDistinctByteValues = 256;

    [int] $totalNumberOfWholeRangesInAByte = $TotalNumberOfDistinctByteValues / $numberOfPossibleCharacters
    [int] $indexOfLastNumberInLastWholeRange = ($totalNumberOfWholeRangesInAByte * $numberOfPossibleCharacters) - 1

    return ($passwordCharacterIndex -le $indexOfLastNumberInLastWholeRange)
}

function CreateAzureADUser([string] $userDisplayName, [string] $userPrincipalName)
{
    $passwordProfile = New-Object -TypeName 'Microsoft.Azure.PowerShell.Cmdlets.Resources.MSGraph.Models.ApiV10.MicrosoftGraphPasswordProfile'
    $passwordProfile.Password = CreateTruelyRandomPassword
    $passwordProfile.ForceChangePasswordNextSignIn = $false

    [void](New-MgUser -DisplayName $userDisplayName -UserPrincipalName $userPrincipalName -AccountEnabled $true -PasswordProfile $passwordProfile -ErrorAction Stop)

    return $passwordProfile.Password
}

Connect-MsGraph -Scopes 'Application.ReadWrite.All'

try
{
    [string] $goalsAdminAccountPassword = CreateAzureADUser 'Goals Administrator (Development Environment)' 'goals.admin@goals.dev.benellett.net'
    [string] $benEllettsAccountPassword = CreateAzureADUser 'Ben Ellett (Development Environment)' 'ben.ellett@goals.dev.benellett.net'
    


}
finally
{
    Disconnect-AzureAD
}