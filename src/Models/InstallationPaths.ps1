class InstallationPaths
{
    # Steam Paths
    [string]$steamClientPath
    [string]$steamClientBackupPath
    [string]$steamJrePath
    [string]$steamJarPath
    [string]$steamConfigPath

    # Runelite Paths
    [string]$runeliteClientPath
    [string]$runeliteJrePath
    [string]$runeliteJarPath
    [string]$runeliteConfigPath

    hidden InstallationPaths([string]$runeLiteInstallationPath, [string]$steamClientInstallationPath)
    {
        if (!($steamClientInstallationPath.EndsWith("\bin\win64")))
        {
            $steamClientInstallationPath = $steamClientInstallationPath + "\bin\win64"
        }
        
        $this.steamClientPath = "$steamClientInstallationPath\osclient.exe"
        $this.steamClientBackupPath = "$steamClientInstallationPath\osclient.exe.original"
        $this.steamJrePath = "$steamClientInstallationPath\jre"
        $this.steamJarPath = "$steamClientInstallationPath\RuneLite.jar"
        $this.steamConfigPath = "$steamClientInstallationPath\config.json"
        $this.runeliteClientPath = "$runeLiteInstallationPath\RuneLite.exe"
        $this.runeliteJrePath = "$runeLiteInstallationPath\jre"
        $this.runeliteJarPath = "$runeLiteInstallationPath\RuneLite.jar"
        $this.runeliteConfigPath = "$runeLiteInstallationPath\config.json"
    }

    [bool] CheckRequiredFilePaths()
    {
        if ((Test-Path $this.runeliteClientPath) -and 
            (Test-Path $this.runeliteJrePath) -and 
            (Test-Path $this.runeliteJarPath) -and 
            (Test-Path $this.runeliteConfigPath) -and 
            (Test-Path $this.steamClientPath)) 
        {
            return $true
        }
        else
        {
            return $false
        }
    }
}