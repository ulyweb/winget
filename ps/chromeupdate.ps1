# This script requires Run as Administrator
# Save this script as chromeupdate.ps1

# Function to check for Administrator privileges
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check for Administrator privileges
if (-not (Test-Administrator)) {
    Write-Host "This script requires running as Administrator."
    exit
}

# Update registry keys
try {
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name "AutoUpdateCheckPeriodMinutes" -PropertyType DWord -Value 1 -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name "Install{8A69D345-D564-463C-AFF1-A69D9E530F96}" -PropertyType DWord -Value 1 -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Update" -Name "Update{8A69D345-D564-463C-AFF1-A69D9E530F96}" -PropertyType DWord -Value 1 -Force
    New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "SyncDisabled" -PropertyType DWord -Value 0 -Force
    Write-Host "Registry keys updated successfully."
} catch {
    Write-Host "Failed to update registry keys: $_"
}
