function Copy-RuneLiteToSteam
{
    [CmdletBinding(DefaultParameterSetName="Copy")]
    param(
        [Parameter(ParameterSetName="Schedule")]
        [ValidateSet("Startup", "Logon")]
        [string]$Schedule,
        [Parameter()]
        [switch]$Revert
    )

    # If any required files are missing, return
    if (!($InstallationPaths.CheckRequiredFilePaths())) 
    {
        Write-Error "Files were missing. Verify that RuneLite and the OSRS Steam client are both installed in the specified paths."
        return
    }

    switch ($PSCmdlet.ParameterSetName)
    {
        "Copy"
        {
            if ($Revert)
            {
                Remove-Item -Path $InstallationPaths.steamClientPath -Force
                Remove-Item -Path $InstallationPaths.steamJrePath -Recurse -Force
                Remove-Item -Path $InstallationPaths.steamJarPath -Force
                Remove-Item -Path $InstallationPaths.steamConfigPath -Force
                Remove-Item -Path $InstallationPaths.MigrationTrackerPath -Force
                Rename-Item -Path $InstallationPaths.steamClientBackupPath -NewName $InstallationPaths.steamClientPath -Force
                Write-Output "Reverted back to OSRS Steam client."
                return
            }

            # Current client hashes
            $currentRuneliteClientHash = (Get-FileHash -Algorithm MD5 -Path $InstallationPaths.runeliteClientPath).Hash
            $currentSteamClientHash = (Get-FileHash -Algorithm MD5 -Path $InstallationPaths.steamClientPath).Hash

            if (Test-Path $MigrationTrackerPath) 
            {
                $migrationTracker = [MigrationTracker](Get-Content -Path $MigrationTrackerPath -Raw | ConvertFrom-Json)

                # Check if client has been updated by Steam or if RuneLite has updated since last run. If neither case is true, take no action.
                if ($currentSteamClientHash -ne $migrationTracker.lastRuneliteClientHash)
                {
                    Write-Output "Steam client update detected. Copying RuneLite files..."
                    if (Test-Path $InstallationPaths.steamClientBackupPath) 
                    {
                        Remove-Item $InstallationPaths.steamClientBackupPath
                    }
                    Rename-Item -Path $InstallationPaths.steamClientPath -NewName $InstallationPaths.steamClientBackupPath -Force
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

                if (Test-Path $InstallationPaths.steamClientBackupPath) 
                {
                    Remove-Item $InstallationPaths.steamClientBackupPath
                }
                Rename-Item -Path $InstallationPaths.steamClientPath -NewName $InstallationPaths.steamClientBackupPath -Force

                Copy-Files
            }

            if ($Error -ne $null -and $Error.Count -gt 0)
            {
                $migrationTracker.lastMigrationResult = "Fail"
                $migrationTracker.lastMigrationErrors = $Error | Select-Object { $_.Exception.Message }
            }
            else {
                $migrationTracker.lastMigrationResult = "Success"
            }

            $migrationTracker.lastMigrated = (Get-Date).ToString()
            $migrationTracker | ConvertTo-Json | Out-File -FilePath $MigrationTrackerPath -Force
            Write-Output "Migration completed successfully."
        }
        "Schedule"
        {
            if ($Revert)
            {
                Unregister-ScheduledTask -TaskName "RuneLite to Steam Migration Job - $Schedule" -Confirm:$false
            }
            else
            {
                $actionArgs = "-NoProfile -ExecutionPolicy Bypass -Command `"& {Copy-RuneLiteToSteam}`""
                $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument $actionArgs
                switch ($Schedule)
                {
                    "Startup" { $trigger = New-ScheduledTaskTrigger -AtStartup }
                    "Logon" { $trigger = New-ScheduledTaskTrigger -AtLogOn }
                }
                $principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
                $settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew
                $task = New-ScheduledTask -Action $action -Principal $principal -Trigger $trigger -Settings $settings
                Register-ScheduledTask "RuneLite to Steam Migration Job - $Schedule" -InputObject $task
            }
        }
    }
}