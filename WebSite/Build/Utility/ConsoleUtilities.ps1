function DisplayBlankLine()
{
    Write-Host ''
}

function DisplayHorizontalSeparator()
{
    [int] $bufferWidthInChars = $Host.UI.RawUI.BufferSize.Width
    [System.Text.StringBuilder] $horizontalSeparator = [System.Text.StringBuilder]::new($bufferWidthInChars)
    [void]($horizontalSeparator.Append('-', $bufferWidthInChars))

    Write-Host $horizontalSeparator.ToString()
}

function DisplayHeader([string] $headerName)
{
    DisplayHorizontalSeparator
    Write-Host $headerName
    DisplayHorizontalSeparator
    DisplayBlankLine
}
