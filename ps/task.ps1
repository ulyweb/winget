$taskName = "MyDailyTask"
$taskPath = "c:\IT_folder\dailytask.bat"
$fileContent = @"
@echo off
REM Add dontdisplaylastusername key
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v dontdisplaylastusername /t REG_DWORD /d 0 /f

REM Remove legalnoticecaption key if it exists
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticecaption /f

REM Remove legalnoticetext key if it exists
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v legalnoticetext /f
"@

# Check if the file exists
if (-Not (Test-Path $taskPath)) {
    # Create the file and write the content
    New-Item -Path $taskPath -ItemType File -Force
    Set-Content -Path $taskPath -Value $fileContent
    Write-Output "The file '$taskPath' has been created."
} else {
    Write-Output "The file '$taskPath' already exists."
}

# Check if the task already exists
$task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($task) {
    Write-Output "The task '$taskName' already exists. Please choose a different name or delete the existing task."
} else {
    $action = New-ScheduledTaskAction -Execute $taskPath
    $trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 1)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings

    Write-Output "The task '$taskName' has been created successfully."
}
