class RuneLiteToSteamConfig
{
    [string]$runeLiteInstallationPath
    [string]$steamClientInstallationPath

    hidden RuneLiteToSteamConfig([string]$runeLiteInstallationPath, [string]$steamClientInstallationPath)
    {
        $this.runeLiteInstallationPath = $runeLiteInstallationPath
        $this.steamClientInstallationPath = $steamClientInstallationPath
    }
}