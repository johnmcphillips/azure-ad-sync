Write-Host "Starting AAD Sync..."
$AADComputer = "$AADSYNCSERVERNAME"
$session = New-PSSession -ComputerName $AADComputer
Invoke-Command -Session $session -ScriptBlock {Import-Module -Name 'ADSync'}
$sync = Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
Write-Output $sync | Out-Host

Remove-PSSession $session

Read-Host -Prompt "Press Enter to exit"
