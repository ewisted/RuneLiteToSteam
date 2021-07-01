function Set-InstallationPaths
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$RuneLiteInstallationPath,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$SteamClientInstallationPath
    )

    $installPaths = New-Object InstallationPaths($RuneLiteInstallationPath, $SteamClientInstallationPath)
    if ($installPaths.CheckRequiredFilePaths())
    {
        Set-Variable -Name InstallationPaths -Value $installPaths
        $updatedConfig = New-Object RuneLiteToSteamConfig($RuneLiteInstallationPath, $SteamClientInstallationPath)
        $updatedConfig | ConvertTo-Json | Out-File -FilePath $RuneLiteToSteamConfigPath -Force
    }
    else
    {
        Write-Error "Required files were missing. Check the file paths specified and try running Set-InstallationPaths again."    
    }
}