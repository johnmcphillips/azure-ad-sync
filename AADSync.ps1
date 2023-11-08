# Define AD Sync Server
$AADComputer = "$AADSYNCSERVER"

$runsToKeep = 7
$logDirectory = "\\$AADComputer\scripts\Logs"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFileName = "$timestamp.log"
$logFilePath = Join-Path -Path $logDirectory -ChildPath $logFileName

# Redirect standard output and error to a temporary log file
$tempLogFilePath = Join-Path -Path "\\$AADComputer\scripts\Logs\" -ChildPath "temp_log.txt"
Start-Transcript -Path $tempLogFilePath -Append

Write-Host "Starting AAD Sync..."

$session = New-PSSession -ComputerName $AADComputer
Invoke-Command -Session $session -ScriptBlock {Import-Module -Name 'ADSync'}
$sync = Invoke-Command -Session $session -ScriptBlock {
    try {
        $result = Start-ADSyncSyncCycle -PolicyType Delta
        Write-Output $result
    } catch {
        Write-Error $_.Exception.Message
    }
}

Remove-PSSession $session
Write-Output $sync | Out-Host
Stop-Transcript
Get-Content -Path $tempLogFilePath | Add-Content -Path $logFilePath
Remove-Item -Path $tempLogFilePath

# Display a message in the console

Write-Host "Script execution completed. Output has been logged to $logFilePath"
Read-Host -Prompt "Press Enter to exit"

# Clean up logs
$logFiles = Get-ChildItem -Path $logDirectory -Filter "*.log"
$logFiles = $logFiles | Sort-Object LastWriteTime
$filesToDelete = $logFiles.Count - $runsToKeep

if ($filesToDelete -gt 0) {
    $logFilesToDelete = $logFiles[0..($filesToDelete - 1)]
    $logFilesToDelete | ForEach-Object {
        Remove-Item -Path $_.FullName -Force
        Write-Host "Deleted log file: $($_.FullName)"
    }
}
