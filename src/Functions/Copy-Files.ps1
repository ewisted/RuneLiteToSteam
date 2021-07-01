function Copy-Files
{
    if ($InstallationPaths)
    {
        Copy-Item -Path $InstallationPaths.runeliteClientPath -Destination $InstallationPaths.steamClientPath -Force
        Copy-Item -Path $InstallationPaths.runeliteJrePath -Destination $InstallationPaths.steamJrePath -Recurse -Force
        Copy-Item -Path $InstallationPaths.runeliteJarPath -Destination $InstallationPaths.steamJarPath -Force
        Copy-Item -Path $InstallationPaths.runeliteConfigPath -Destination $InstallationPaths.steamConfigPath -Force
    }
    else
    {
        throw "Installation paths are not set. Try running the Set-InstallationPath cmdlet."
    }
}