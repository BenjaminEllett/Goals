function DisplayBlankLine()
{
    Write-Host ''
}

function DisplayHorizonalSeparator()
{
    [int] $bufferWidthInChars = $Host.UI.RawUI.BufferSize.Width
    Write-Host "bufferWidthInChars = $bufferWidthInChars" # TODO - Remove this line

    [System.Text.StringBuilder] $horizonalSeparator = [System.Text.StringBuilder]::new($bufferWidthInChars)
    [void]($horizonalSeparator.Append('-', $bufferWidthInChars))

    Write-Host $horizonalSeparator.ToString()
}

function DisplayHeader([string] $headerName)
{
    DisplayHorizonalSeparator
    Write-Host $headerName
    DisplayHorizonalSeparator
    DisplayBlankLine
}
