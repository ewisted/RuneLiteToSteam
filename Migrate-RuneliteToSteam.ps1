param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$RuneLiteInstallPath,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$SteamClientInstallPath,
    [Parameter()]
    [switch]$Revert
)

class MigrationTracker {
    [string]$lastMigrated
    [string]$lastRuneliteClientHash
}

function Copy-Files {
    Copy-Item -Path $runeliteClientPath -Destination $steamClientPath -Force
    Copy-Item -Path $runeliteJrePath -Destination $steamJrePath -Recurse -Force
    Copy-Item -Path $runeliteJarPath -Destination $steamJarPath -Force
    Copy-Item -Path $runeliteConfigPath -Destination $steamConfigPath -Force
}

# Migration Paths
$migrationTrackerPath = "$SteamClientInstallPath\migration-tracker.json"

# Steam Paths
$steamClientPath = "$SteamClientInstallPath\osclient.exe"
$steamClientBackupPath = "$SteamClientInstallPath\osclient.exe.original"
$steamJrePath = "$SteamClientInstallPath\jre"
$steamJarPath = "$SteamClientInstallPath\RuneLite.jar"
$steamConfigPath = "$SteamClientInstallPath\config.json"

# Runelite Paths
$runeliteClientPath = "$RuneLiteInstallPath\RuneLite.exe"
$runeliteJrePath = "$RuneLiteInstallPath\jre"
$runeliteJarPath = "$RuneLiteInstallPath\RuneLite.jar"
$runeliteConfigPath = "$RuneLiteInstallPath\config.json"

# If any required files are missing, return
if (!(Test-Path $runeliteClientPath) -or 
    !(Test-Path $runeliteJrePath) -or 
    !(Test-Path $runeliteJarPath) -or 
    !(Test-Path $runeliteConfigPath) -or 
    !(Test-Path $steamClientPath)) 
{
    Write-Error "Files were missing. Verify that RuneLite and the OSRS Steam client are both installed in the specified paths."
    return
}

if ($Revert) {
    Remove-Item -Path  $steamClientPath -Force
    Remove-Item -Path $steamJrePath -Recurse -Force
    Remove-Item -Path $steamJarPath -Force
    Remove-Item -Path $steamConfigPath -Force
    Remove-Item -Path $migrationTrackerPath -Force
    Rename-Item -Path $steamClientBackupPath -NewName $steamClientPath -Force
    Write-Output "Reverted back to OSRS Steam client."
    return
}

# Current client hashes
$currentRuneliteClientHash = (Get-FileHash -Algorithm MD5 -Path $runeliteClientPath).Hash
$currentSteamClientHash = (Get-FileHash -Algorithm MD5 -Path $steamClientPath).Hash

if (Test-Path $migrationTrackerPath) 
{
    $migrationTracker = Get-Content -Path $migrationTrackerPath -Raw | ConvertFrom-Json

    # Check if client has been updated by Steam or if RuneLite has updated since last run. If neither case is true, take no action.
    if ($currentSteamClientHash -ne $migrationTracker.lastRuneliteClientHash)
    {
        Write-Output "Steam client update detected. Copying RuneLite files..."
        if (Test-Path $steamClientBackupPath) 
        {
            Remove-Item $steamClientBackupPath
        }
        Rename-Item -Path $steamClientPath -NewName $steamClientBackupPath -Force
        Copy-Files
    }
    elseif ($currentRuneliteClientHash -ne $migrationTracker.lastRuneliteClientHash) {
        Write-Output "RuneLite update detected. Copying new RuneLite files..."
        $migrationTracker.lastRuneliteClientHash = $currentRuneliteClientHash
        Copy-Files
    }
    else
    {
        Write-Output "Neither RuneLite or the Steam client have been updated since last run. Cancelling migraion."
        return
    }
}
else 
{
    $migrationTracker = New-Object -TypeName MigrationTracker
    $migrationTracker.lastRuneliteClientHash = $currentRuneliteClientHash
    Rename-Item -Path $steamClientPath -NewName $steamClientBackupPath -Force
    Copy-Files
}

$migrationTracker.lastMigrated = (Get-Date).ToString()
$migrationTracker | ConvertTo-Json | Out-File -FilePath $migrationTrackerPath
Write-Output "Migration completed successfully."