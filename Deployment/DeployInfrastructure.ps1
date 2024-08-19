param(
    [ValidateSet('Development', 'Production')]
    [string] $Environment
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Main([string] $environmentInternal)
{
    DeployBicepFiles $environmentInternal 
}

#
# Deploy Bicep Files functions
#

function DeployBicepFiles([string] $environmentInternal)
{
    DisplayHeader 'Reviewing and Deploying Bicep files'

    [string] $bicepFileDirectory = Join-Path -Path $PSScriptRoot -ChildPath 'Bicep'

    Push-Location -Path $bicepFileDirectory

    try 
    {
        $deploymentParameters = @{
            TemplateFile = 'Main.bicep'
            Location = 'West US 2'
            Environment = $environmentInternal
        }
    
        [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.Deployments.PSWhatIfOperationResult] $whatIfResults = $null
        $whatIfResults = Get-AzDeploymentWhatIfResult -TemplateFile .\Main.bicep -Location 'West US 2' -Environment Development 
        if ($whatIfResults.Status -ne 'Succeeded') 
        {
            [string] $errorMessage = $null -eq  $whatIfResults.Error ? '' : $whatIfResults.Error.Message
            throw "Error: Unable to get What-If results. Status: $($whatIfResults.Status)   Error message: $errorMessage"
        }

        RemoveFalseChanges $whatIfResults

        # Display the What-If results   
        DisplayBlankLine 5

        # This will display the results in the console
        $whatIfResults

        DisplayBlankLine 5

        [string] $confirmationMessage =
            "Please review the changes above.  If these are good changes, type 'I want to deploy these changes' to deploy the changes.  " +
            "Press CTRL+C to abort deployment"

        do
        {
            $confirmation = Read-Host $confirmationMessage
        } 
        while ($confirmation -ne 'I want to deploy these changes')
    
        New-AzDeployment @deploymentParameters
    }
    finally
    {
        Pop-Location
    }
}

function RemoveFalseChanges(
    [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.Deployments.PSWhatIfOperationResult] $whatIfResults
    )
{
    $Delete = [Microsoft.Azure.Management.ResourceManager.Models.PropertyChangeType]::Delete

    [string] $webSiteResourceId = '/subscriptions/c47fab2e-7725-4c7e-a8a2-7e4a2ec97880/resourceGroups/goals-dev-usw2-rg-web-site/providers/Microsoft.Web/staticSites/goals-dev-usw2-swa-web-site' 

    # A false change is a change which Bicep/Azure Resource Manager claims will occur if a deployment is performed but will not occur 
    # when a deployment occurs.  They typically occur for the following reasons:
    #
    # 1. There is a bug in a particular resource's Azure Resource Manger code.  For example, the properties.stableInboundIP property
    #    on an Azure Static Web Site resource has this bug.  Each time the WhatIf command is run, WhatIf claims the
    #    properties.stableInboundIP property will change.  However, when the deployment is actually performed, 
    #    properties.stableInboundIP's value does not change.
    #  
    # 2. "The what-if operation can't resolve the reference function. Every time you set a property to a template expression that 
    #    includes the reference function, what-if reports the property will change. This behavior happens because what-if compares
    #    the current value of the property (such as true or false for a boolean value) with the unresolved template expression. 
    #    Obviously, these values will not match. When you deploy the Bicep file, the property will only change when the template
    #    expression resolves to a different value."
    #    (https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-what-if?tabs=azure-powershell%2CCLI#see-results)
    #
    RemoveSinlgeFalseChange $whatIfResults $webSiteResourceId 'properties.areStaticSitesDistributedBackendsEnabled' $Delete
    RemoveSinlgeFalseChange $whatIfResults $webSiteResourceId 'properties.deploymentAuthPolicy' $Delete
    RemoveSinlgeFalseChange $whatIfResults $webSiteResourceId 'properties.stableInboundIP' $Delete
    RemoveSinlgeFalseChange $whatIfResults $webSiteResourceId 'properties.trafficSplitting' $Delete
}

function RemoveSinlgeFalseChange(
    [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.Deployments.PSWhatIfOperationResult] $whatIfResults,
    [string] $changeResourceId,
    [string] $properyPath,
    [Microsoft.Azure.Management.ResourceManager.Models.PropertyChangeType] $changeType
    )
{
    # Get the resource with the appropriate change
    [int] $changedResourceIndex = GetChangedResourceIndex $whatIfResults $changeResourceId

    $changedResource = $whatIfResults.Changes[$changedResourceIndex] 
    
    # Get the change
    $deltaToRemove = $changedResource.Delta | Where-Object { $_.Path -eq $properyPath -and $_.PropertyChangeType -eq $changeType }
    if ($null -eq $deltaToRemove)
    {
        [string] $warningMessage = 
            "WARNING: Unable to find the change for resource ID: $changeResourceId and property path: $properyPath .  This usually occurs " +
            "because the property name is misspelled or has a space at the end."

        Write-Warning $warningMessage
        return
    }

    [void]($changedResource.Delta.Remove($deltaToRemove))

    # Replace the Modify change type with the NoChange change type if there are no changes.
    if (($changedResource.ChangeType -eq 'Modify') -and 
        ($changedResource.Delta.Count -eq 0))
    {
        [Microsoft.Azure.Management.Resources.Models.WhatIfChange] $updatedChangedResource = $null
        [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.Deployments.PSWhatIfChange] $updatedPowerShellChangedResource = $null

        # https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.management.resources.models.whatifchange.-ctor?view=az-ps-latest#microsoft-azure-management-resources-models-whatifchange-ctor(system-string-microsoft-azure-management-resources-models-changetype-system-string-system-object-system-object-system-collections-generic-ilist((microsoft-azure-management-resources-models-whatifpropertychange)))
        [object[]] $updatedChangeConstructorParameters = @(
            $changedResource.FullyQualifiedResourceId,
            ([Microsoft.Azure.Management.Resources.Models.ChangeType]::NoChange)
        )

        $updatedChangedResource = New-Object -TypeName 'Microsoft.Azure.Management.Resources.Models.WhatIfChange' -ArgumentList $updatedChangeConstructorParameters
        
        # https://learn.microsoft.com/en-us/dotnet/api/microsoft.azure.commands.resourcemanager.cmdlets.sdkmodels.deployments.pswhatifchange.-ctor?view=az-ps-latest
        $updatedPowerShellChangedResource = New-Object -TypeName 'Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.Deployments.PSWhatIfChange' -ArgumentList $updatedChangedResource

        $whatIfResults.Changes[$changedResourceIndex] = $updatedPowerShellChangedResource
    }
}

function GetChangedResourceIndex(
    [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.Deployments.PSWhatIfOperationResult] $whatIfResults,
    [string] $changeResourceId
    )
{
    for ($changedResourceIndex = 0; $changedResourceIndex -lt $whatIfResults.Changes.Count; $changedResourceIndex++)
    {
        [Microsoft.Azure.Commands.ResourceManager.Cmdlets.SdkModels.Deployments.PSWhatIfChange] $changedResource = $null 
        $changedResource = $whatIfResults.Changes[$changedResourceIndex]
        if ($changedResource.FullyQualifiedResourceId -eq $changeResourceId)
        {
            return $changedResourceIndex
        }
    }

    throw "Error: Unable to find the change for resource ID: $changeResourceId"    
}

#
# Console Utility Functions
#

function DisplayHeader([string] $headerText)
{
    DisplayBlankLine
    DisplaySeparatorLine
    Write-Host $headerText
    DisplaySeparatorLine
    DisplayBlankLine
}

function DisplaySubHeader([string] $subHeaderText)
{
    DisplayBlankLine
    Write-Host $subHeaderText
    DisplaySeparatorLine
    DisplayBlankLine
}


function DisplaySeparatorLine()
{
    [int] $consoleWidthInCharacters = [System.Console]::WindowWidth
 
    [System.Text.StringBuilder] $separatorLine = New-Object -TypeName System.Text.StringBuilder -ArgumentList $consoleWidthInCharacters

    for ($charIndex = 0; $charIndex -lt $consoleWidthInCharacters; $charIndex++)
    {
        [void]($separatorLine.Append('-'))
    }

    [string] $separatorLine = $separatorLine.ToString()

    Write-Host $separatorLine
}

function DisplayBlankLine([int] $count = 1)
{
    for ($numBlankLinesDisplayed = 0; $numBlankLinesDisplayed -lt $count; $numBlankLinesDisplayed++)
    {
        Write-Host ''
    }
}

#
# Call Main
#

Main $Environment