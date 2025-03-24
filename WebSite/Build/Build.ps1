param(
    [switch] $DebugBuild = $false,
    [switch] $ReleaseBuild = $false,

    [switch] $Build = $false,
    [switch] $BuildAndServeWebSite = $false,
    
    [switch] $CleanBuild = $false
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest



#
# Load libraries
#
. "$PSScriptRoot/Utility/ConsoleUtilities.ps1"



#
# Constants
#
[string] $BuildOutputDirectoryRelativePath = './BuildOutput'
[string] $ThisCaseShouldNeverOccurErrorMessage = "ERROR: This case should never occur.  Please let the development team know about this error."



#
# Functions to build the website 
# 
# These functions do the following
#   - Reset the build's state by deleting the build output directory and the node_modules directory (NPM stores node packages in this
#     directory)
#   - Transform TypeScript into bundled minified JavaScript
#   - Transform SASS into CSS
#   - Copy files HTML files to to build output directory
#
function BuildWebSite()
{
    if ($DebugBuild -and $ReleaseBuild)
    {
        throw 'ERROR: You cannot specify both the -DebugBuild and -ReleaseBuild parameters.  Please only use one of these parameters.'
    }

    if ($Build -and $BuildAndServeWebSite)
    {
        throw 'ERROR: You cannot specify both the -Build and -BuildAndServeWebSite parameters.  Please only use one of these parameters.'
    }

    [System.IO.DirectoryInfo] $scriptFileInfo = Get-Item $PSScriptRoot
    [string] $webSiteRootDirectory = $scriptFileInfo.Parent.FullName

    Push-Location $webSiteRootDirectory

    try 
    {
        DisplayHeader 'Removing directories'

        if ($CleanBuild)
        {
            RemoveDirectoryIfNecessary $BuildOutputDirectoryRelativePath
            RemoveDirectoryIfNecessary './node_modules'
        }

        if (!(Test-Path -Path $BuildOutputDirectoryRelativePath))
        {
            [void](New-Item -ItemType Directory -Path $BuildOutputDirectoryRelativePath)
        }



        DisplayBlankLine
        DisplayHeader 'Install Node Packages'
        npm install
        VerifyNativeFunctionSucceeded "ERROR: npm install failed with error code $LASTEXITCODE"



        DisplayBlankLine
        DisplayHeader 'Check for TypeScript errors'
        ./node_modules/.bin/tsc --noEmit
        VerifyNativeFunctionSucceeded "ERROR: The type script compiler failed with error code $LASTEXITCODE"



        DisplayBlankLine
        DisplayHeader 'Copy HTML files'
        [System.IO.FileInfo[]] $htmlFiles = GetSourceCodeFiles 'html'

        foreach ($currentHtmlFile in $htmlFiles)
        {
            Copy-Item $currentHtmlFile.FullName -Destination $BuildOutputDirectoryRelativePath
        }



        DisplayBlankLine
        DisplayHeader 'Transform SASS (.scss) files to CSS (.css) files'
        [System.IO.FileInfo]  $mainSassFile = Get-Item -Path './src/main.scss'

        BuildSassFile $mainSassFile
       


        DisplayBlankLine
        DisplayHeader 'Transform TypeScript files to JavaScript files.  May create a development web server.'

        [System.Collections.Generic.List[string]] $buildParameters = [System.Collections.Generic.List[string]]::new()

        if (DidUserOnlyRequestABuild)
        {
            $buildParameters.Add('--build')
        } 
        elseif (DidUserRequestABuildAndToServeTheWebSite)
        {
            $buildParameters.Add('--build-and-serve-web-site')
        }
        else 
        {
            throw $ThisCaseShouldNeverOccurErrorMessage
        }

        if (IsReleaseBuild)
        {
            $buildParameters.Add('--release')
        }
        elseif (IsDebugBuild)
        {
            $buildParameters.Add('--debug')
        }
        else 
        {
            throw $ThisCaseShouldNeverOccurErrorMessage
        }
        
        if ($BuildAndServeWebSite)
        {
            [System.Collections.Generic.List[string]] $nodeParameters = [System.Collections.Generic.List[string]]::new()
            $nodeParameters.Add('./Build/Build.mjs')
            $nodeParameters.AddRange($buildParameters)

            RunCommandInNewWindowsTerminalTab "Build and serve web site" node @nodeParameters
        }
        else 
        {
            node './Build/Build.mjs' @buildParameters
            VerifyNativeFunctionSucceeded "ERROR: The build script failed with error code $LASTEXITCODE"
        }
    }
    finally 
    {
        Pop-Location
    }
}

function BuildSassFile([System.IO.FileInfo] $sassFile)
{
    Write-Verbose "Building SASS file: $($sassFile.FullName)"

    if ($sassFile.Extension -ne '.scss')
    {
        throw "ERROR: $($sassFile.FullName) is not a sass file"
    }

    [string] $inputFilePath = $sassFile.FullName

    # Remove the .scss extension and replace it with .css
    [int] $LengthOfScssExtension = 5 # The length includes the . character

    # Start at the first character
    [int] $startCharIndex = 0

    # Include all of the file name characters except the .scss extension
    [int] $numberOfCharactersToInclude = $sassFile.Name.Length - $LengthOfScssExtension
    [string] $outputFileName = $sassFile.Name.Substring($startCharIndex, $numberOfCharactersToInclude)

    [string] $relativeOutputFilePath = Join-Path -Path $BuildOutputDirectoryRelativePath -ChildPath "$outputFileName.css"

    # Get the current SASS version
    #
    # The SASS version comes in the following format:
    # 
    # [SASS version] compiled with dart2js [Dart to JavaScript version]
    # 
    # Here is an example
    # 1.77.8 compiled with dart2js 3.4.4
    #
    [string] $sassOutput = RunSassProgram @('--version')

    # PowerShell Regular Expression Documentation: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_regular_expressions?view=powershell-7.4
    # .NET Regular Expression Documentation: https://learn.microsoft.com/en-us/dotnet/standard/base-types/regular-expressions
    #
    # Regular Expression Character | Meaning
    # ---------------------------- | -------
    # ^                            | Matches the start of a string 
    # $                            | Matches the end of a string 
    # \d                           | Matches any decimal digit (https://learn.microsoft.com/en-us/dotnet/standard/base-types/character-classes-in-regular-expressions#DigitCharacter)
    # +                            | Matches one or more of the preceding character
    # \.                           | Matches the . character
    if ($sassOutput -notmatch '^(?<SassVersionNumber>\d+\.\d+.\d+) compiled with dart2js \d+\.\d+.\d+$')
    {
        throw 'ERROR: Unable to determine the SASS version number from the output of the sass --version command.  Here is the output: ' +
              "$sassOutput"
    }

    [string] $sassVersionNumber = $Matches.SassVersionNumber

    # Determine the SASS command line options
    #
    # The SASS command line options are documented at https://sass-lang.com/documentation/cli/dart-sass/
    [System.Collections.Generic.List[string]] $sassParameters = [System.Collections.Generic.List[string]]::new()
    
    [string[]] $initialSassParameters = @(
        "$($inputFilePath):$relativeOutputFilePath"
        '--verbose'
        '--color' 
        "--fatal-deprecation=$sassVersionNumber"
        '--source-map'
    )

    $sassParameters.AddRange($initialSassParameters)

    if ($BuildAndServeWebSite)
    {
        $sassParameters.Add('--watch')
    }
    else
    {
        $sassParameters.Add('--stop-on-error')
    }

    if (IsReleaseBuild)
    {
        $sassParameters.Add('--embed-sources')
        $sassParameters.Add('--style=compressed')
    }

    [bool] $runInSeparateWindowsTerminalTab = $BuildAndServeWebSite ? $true : $false

    RunSassProgram $sassParameters.ToArray() $runInSeparateWindowsTerminalTab
}

function RunSassProgram([string[]] $commandLineOptions, [bool] $runInSeparateWindowsTerminalTab = $false)
{
    Write-Verbose "Running ./node_modules/.bin/sass $commandLineOptions"

    if ($runInSeparateWindowsTerminalTab)
    {
        RunCommandInNewWindowsTerminalTab "Build Sass" "./node_modules/.bin/sass" $commandLineOptions
    }
    else 
    {
        [string] $sassOutput = ./node_modules/.bin/sass @commandLineOptions
        VerifyNativeFunctionSucceeded "ERROR: SASS (node .\node_modules\sass\sass.js) failed with error code $LASTEXITCODE"
        return $sassOutput
    }
}

#
# Utility functions
#
function IsReleaseBuild()
{
    return $ReleaseBuild ? $true : $false
}

function IsDebugBuild()
{
    if ($DebugBuild)
    {
        return $true
    }

    if (!$ReleaseBuild && !$DebugBuild)
    {
        # If the user does specify a build type, default to debug because it is the most commonly used build type.
        return $true
    }

    return $false
}

function DidUserOnlyRequestABuild()
{
    return $Build ? $true : $false
}

function DidUserRequestABuildAndToServeTheWebSite()
{
    if ($BuildAndServeWebSite)
    {
        return $true
    }

    if (!$Build && !$BuildAndServeWebSite)
    {
        # If the user does request a specific action, default to building the web site and then creating a local web server so the user can
        # test and debug the web site.
        return $true
    }

    return $false
}

function RunCommandInNewWindowsTerminalTab([string] $tabTitle, [string] $command, [string[]] $commandParameters)
{
    [System.Management.Automation.PathInfo] $workingDirectoryPathInfo = Get-Location
    [string] $workingDirectory = $workingDirectoryPathInfo.Path

    wt new-tab --title $tabTitle pwsh -NoProfile -WorkingDirectory $workingDirectory -Command $command @commandParameters
}
function VerifyNativeFunctionSucceeded([string] $errorMessage)
{
    if ($LASTEXITCODE -ne 0) 
    {
        throw $errorMessage
    }
}

function GetSourceCodeFiles([string] $fileExtension)
{
    return Get-ChildItem -Path './src' -Filter "*.$fileExtension" -Recurse
}

function RemoveDirectoryIfNecessary([string] $directoryPath)
{
    if (Test-Path -Path $directoryPath)
    {
        Remove-Item -Path $directoryPath -Recurse -Force
    }

    if (Test-Path -Path $directoryPath)
    {
        throw "ERROR: Unable to remove the directory $directoryPath"
    }
}

#
# Call main function
#

BuildWebSite