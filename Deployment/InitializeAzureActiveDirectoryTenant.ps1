param {
    [Parameter(
        HelpMessage="The environment the tenant and identities are created for.  It can be either 'Development' or 'Production'.",
        Mandatory=$true)]
    [Alias("env")]
    [ValidateSet("Development", "Production")]
    [string]$Environment
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

[hashtable] $mapEnvironmentToSettings = @{
    'Development' = @{
        ShortName = 'dev',
        
    }
}

[string[]] $msGraphModules = @(
    "Microsoft.Graph.Applications",
    "Microsoft.Graph.Authentication",
    "Microsoft.Graph.Users",
    "Microsoft.Graph.Security"
)

Import-Module -Name $msGraphModules

Connect-MsGraph -Scopes 'Application.ReadWrite', 'Directory.ReadWrite', 'User.ReadWrite.All'

$deploymentApplication =  New-MgApplication -DisplayName "Goals Deployment Application ({$Environment})"
New-MgApplicationFederatedIdentityCredential -ApplicationId $deploymentApplication.Id -Audiences "https://graph.microsoft.com" -Issuer "https://sts.windows.net/{TenantId}/"
New-MgServicePrincipal -DisplayName "Goals Deployment Service Principal ({$Environment})" -AppId $application.AppId
