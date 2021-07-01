New-Variable -Option Constant -Name ModelsRoot -Scope Script -Value "$PSScriptRoot\Models" -Force
New-Variable -Option Constant -Name FunctionsRoot -Scope Script -Value "$PSScriptRoot\Functions" -Force

# Load module models
$models = Get-ChildItem -Path $ModelsRoot -Filter '*.ps1'
foreach ($model in $models) {
    . $model.FullName
}

# Load module functions
$functions = Get-ChildItem -Path $FunctionsRoot -Filter '*.ps1'
foreach ($function in $functions) {
    . $function.FullName
}

# Set config paths
if (!(Test-Path "$($env:ProgramData)\RuneLiteToSteam"))
{
    New-Item -ItemType Directory -Path "$($env:ProgramData)\RuneLiteToSteam"
}
New-Variable -Option Constant -Name RuneLiteToSteamConfigPath -Scope Script -Value "$($env:ProgramData)\RuneLiteToSteam\config.json" -Force
New-Variable -Option Constant -Name MigrationTrackerPath -Scope Script -Value "$($env:ProgramData)\RuneLiteToSteam\migration-tracker.json" -Force

# Pull config if it exists
if (Test-Path $RuneLiteToSteamConfigPath)
{
    $rlToSteamConfig = [RuneLiteToSteamConfig](Get-Content -Path $RuneLiteToSteamConfigPath -Raw | ConvertFrom-Json)
}

# Get Steam client install path
$osrsSteamId = "1343370"
if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App $osrsSteamId")
{
    $steamClientInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Steam App $osrsSteamId" -Name InstallLocation | Select-Object -ExpandProperty InstallLocation).TrimEnd('/','\')
    Write-Host "Found OSRS Steam client install path: `t$steamClientInstallPath" -ForegroundColor Green
}
elseif ($rlToSteamConfig -and $rlToSteamConfig.steamClientInstallationPath)
{
    $steamClientInstallPath = $rlToSteamConfig.steamClientInstallationPath
    Write-Host "Pulled OSRS Steam client install path from config: `t$steamClientInstallPath" -ForegroundColor Green
}
else
{
    Write-Warning "Unable to locate OSRS Steam client install path. You will need to set it manually with the Set-InstallationPath cmdlet."
}

# Get RuneLite install path
if (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RuneLite Launcher_is1")
{
    $runeLiteInstallPath = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RuneLite Launcher_is1" -Name InstallLocation | Select-Object -ExpandProperty InstallLocation).TrimEnd('/','\')
    Write-Host "Found RuneLite install path: `t`t$runeLiteInstallPath" -ForegroundColor Green
}
elseif (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RuneLite Launcher_is1")
{
    $runeLiteInstallPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\RuneLite Launcher_is1" -Name InstallLocation | Select-Object -ExpandProperty InstallLocation).TrimEnd('/','\')
    Write-Host "Found RuneLite install path: `t`t$runeLiteInstallPath" -ForegroundColor Green
}
elseif ($rlToSteamConfig -and $rlToSteamConfig.runeLiteInstallationPath)
{
    $runeLiteInstallPath = $rlToSteamConfig.runeLiteInstallationPath
    Write-Host "Pulled RuneLite install path from config: `t`t$runeLiteInstallPath" -ForegroundColor Green
}
else
{
    Write-Warning "Unable to locate RuneLite install path. You will need to set it manually with the Set-InstallationPath cmdlet."
}

# If paths were set, create the InstallationPaths object for use in module functions
if ($runeLiteInstallPath -and $steamClientInstallPath)
{
    $Script:InstallationPaths = New-Object InstallationPaths($runeLiteInstallPath, $steamClientInstallPath)
}