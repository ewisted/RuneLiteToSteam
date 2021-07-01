class MigrationTracker
{
    [string]$lastMigrated
    [string]$lastRuneliteClientHash
    [string]$lastMigrationResult
    [string[]]$lastMigrationErrors
}