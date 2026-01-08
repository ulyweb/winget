# **`Enable-WingetPolicy.ps1`** that adds:

*   `-Install` switch to install the target package (after unblocking winget), using `--silent` and auto-accepting agreements.
*   **Logging** to a file (default: `C:\ProgramData\WingetPolicy\Enable-WingetPolicy.log`), with timestamps and both console + file output.
*   Keeps your admin elevation behavior and carries parameters across elevation.
*   Tries **search by ID first**, falls back to **search by name**, and mirrors that strategy for **install**.

> Save as `Enable-WingetPolicy.ps1`

```powershell
# Enable-WingetPolicy.ps1
# Purpose: If winget is blocked by Group Policy, enable required AppInstaller policies, then retry.
# Adds: -Install switch for silent install, logging to file.
# Usage examples:
#   .\Enable-WingetPolicy.ps1                        # defaults to Google.Chrome (ID)
#   .\Enable-WingetPolicy.ps1 Google.Chrome          # search by ID
#   .\Enable-WingetPolicy.ps1 chrome                 # tries ID, then falls back to name search
#   .\Enable-WingetPolicy.ps1 chrome -Install        # search + silent install (ID then name)
#   .\Enable-WingetPolicy.ps1 chrome -Install -LogPath "C:\Logs\WingetPolicy.log"

[CmdletBinding()]
param(
    # Accept a positional parameter for the package target. Default is Google.Chrome.
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Target = 'Google.Chrome',

    # If present, will attempt to install the target package after unblocking winget.
    [switch]$Install,

    # Optional log file path. Defaults to C:\ProgramData\WingetPolicy\Enable-WingetPolicy.log
    [string]$LogPath
)

# ------------------------------
# 0) Logging helpers
# ------------------------------
if (-not $LogPath -or [string]::IsNullOrWhiteSpace($LogPath)) {
    $LogDir = Join-Path $env:ProgramData 'WingetPolicy'
    if (-not (Test-Path $LogDir)) {
        try { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null } catch { }
    }
    $LogPath = Join-Path $LogDir 'Enable-WingetPolicy.log'
}

function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR','SUCCESS','DEBUG')][string]$Level = 'INFO',
        [ConsoleColor]$Color = [ConsoleColor]::Gray
    )
    $ts = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $line = "[$ts] [$Level] $Message"
    Write-Host $line -ForegroundColor $Color
    try {
        Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
    } catch {
        # If logging fails, at least continue without stopping script
        Write-Host "[$ts] [WARN] Failed to write log: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Log "Script started. Target='$Target', Install=$($Install.IsPresent), LogPath='$LogPath'" 'DEBUG'

# ------------------------------
# 1) Check if running as Administrator and elevate if needed
# ------------------------------
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal    = New-Object Security.Principal.WindowsPrincipal $CurrentUser
$IsAdmin      = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Log "This script must be run as an Administrator. Restarting with elevated privileges..." 'WARN' Yellow
    $psArgs = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`"",
        "`"$Target`""
    )
    if ($Install) { $psArgs += "-Install" }
    if ($LogPath) { $psArgs += @("-LogPath", "`"$LogPath`"") }

    Start-Process -FilePath "powershell.exe" -ArgumentList $psArgs -Verb RunAs | Out-Null
    exit
}

Write-Log "Running elevated." 'DEBUG'

# ------------------------------
# 2) Helpers
# ------------------------------

function Test-WingetAvailable {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Invoke-Winget {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('search','show','install')]
        [string]$Command,
        [Parameter(Mandatory)]
        [string]$ArgumentString
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "winget"
    $psi.Arguments = "$Command $ArgumentString"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    $p.Start() | Out-Null
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()

    $output = ($stdout + "`n" + $stderr).Trim()
    Write-Log "winget $Command $ArgumentString`n$output" 'DEBUG'

    return [PSCustomObject]@{
        ExitCode = $p.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
        Output   = $output
    }
}

function Invoke-WingetSearchById { param([string]$Id)   ; Invoke-Winget -Command 'search'  -ArgumentString "--id `"$Id`"" }
function Invoke-WingetSearchByName { param([string]$Name); Invoke-Winget -Command 'search'  -ArgumentString "--name `"$Name`"" }

function Invoke-WingetInstallById {
    param([string]$Id)
    Invoke-Winget -Command 'install' -ArgumentString "--id `"$Id`" --silent --accept-source-agreements --accept-package-agreements"
}
function Invoke-WingetInstallByName {
    param([string]$Name)
    Invoke-Winget -Command 'install' -ArgumentString "--name `"$Name`" --silent --accept-source-agreements --accept-package-agreements"
}

function Is-GroupPolicyDisabledMessage {
    param([string]$Text)
    # "This operation is disabled by Group Policy: Enable Windows Package Manager"
    return ($Text -match 'This operation is disabled by Group Policy:\s*Enable Windows Package Manager')
}

# ------------------------------
# 3) Registry policy enforcement (PowerShell-native equivalent of REG ADD)
# ------------------------------
$AppInstallerPolicyKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'

function Ensure-AppInstallerPolicies {
    try {
        if (-not (Test-Path $AppInstallerPolicyKey)) {
            New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows' -ErrorAction SilentlyContinue | Out-Null
            New-Item -Path $AppInstallerPolicyKey -Force | Out-Null
        }

        $values = @(
            @{Name='EnableExperimentalFeatures';     Type='DWord'; Value=1},
            @{Name='EnableAppInstaller';             Type='DWord'; Value=1},
            @{Name='EnableHashOverride';             Type='DWord'; Value=1},
            @{Name='EnableMSAppInstallerProtocol';   Type='DWord'; Value=1}
        )

        foreach ($v in $values) {
            New-ItemProperty -Path $AppInstallerPolicyKey -Name $v.Name -PropertyType $v.Type -Value $v.Value -Force | Out-Null
        }

        Write-Log "AppInstaller policies applied to enable winget usage." 'SUCCESS' Green
        return $true
    } catch {
        Write-Log "Failed to set AppInstaller policies: $($_.Exception.Message)" 'ERROR' Red
        return $false
    }
}

# ------------------------------
# 4) Main flow
# ------------------------------

if (-not (Test-WingetAvailable)) {
    Write-Log "winget is not available on this system. Install App Installer from Microsoft Store or enterprise distribution, then rerun." 'ERROR' Red
    exit 1
}

Write-Log "Attempting winget search by ID: '$Target'" 'INFO' Cyan
$initial = Invoke-WingetSearchById -Id $Target

if ($initial.Output) { Write-Host $initial.Output }

$policyBlocked = Is-GroupPolicyDisabledMessage -Text $initial.Output

if ($policyBlocked) {
    Write-Log "Detected Group Policy blocking winget. Applying registry policy changes..." 'WARN' Yellow

    $ok = Ensure-AppInstallerPolicies
    if (-not $ok) {
        Write-Log "Policy application failed. Verify registry permissions and try again." 'ERROR' Red
        exit 1
    }

    Write-Log "Retrying winget search by ID..." 'INFO' Cyan
    Start-Sleep -Seconds 2
    $retry = Invoke-WingetSearchById -Id $Target

    if ($retry.Output) { Write-Host $retry.Output }

    if (Is-GroupPolicyDisabledMessage -Text $retry.Output) {
        Write-Log "Winget still blocked by Group Policy after applying policies. Consider checking additional enterprise policies or rebooting." 'ERROR' Red
        exit 1
    } else {
        Write-Log "Winget search works after policy change." 'SUCCESS' Green
        $searchExit = $retry.ExitCode
    }
} else {
    # Not blocked by policy
    $searchExit = $initial.ExitCode

    # If ID search didn't yield results, try name search as a convenience.
    $noResultsById =
        ($initial.ExitCode -ne 0 -and -not $initial.Output) -or
        ($initial.Output -match 'No package found') -or
        ($initial.Output -match 'No installed package found') -or
        ($initial.Output -match '0 packages found')

    if ($noResultsById) {
        Write-Log "ID search returned no results. Falling back to name search: '$Target'" 'WARN' Yellow
        $byName = Invoke-WingetSearchByName -Name $Target
        if ($byName.Output) { Write-Host $byName.Output }
        $searchExit = $byName.ExitCode
        if ($byName.ExitCode -eq 0) {
            Write-Log "Name search completed." 'SUCCESS' Green
        } else {
            Write-Log "winget search (name) returned ExitCode $($byName.ExitCode). Review output above." 'WARN' Yellow
        }
    } else {
        Write-Log "ID search completed." 'SUCCESS' Green
    }
}

# ------------------------------
# 5) Optional silent install
# ------------------------------
if ($Install) {
    Write-Log "Starting silent install for target '$Target'." 'INFO' Cyan

    # Try install by ID first
    $instId = Invoke-WingetInstallById -Id $Target
    if ($instId.Output) { Write-Host $instId.Output }

    $installSucceeded = ($instId.ExitCode -eq 0) -and (-not ($instId.Output -match 'No package found'))

    if (-not $installSucceeded) {
        Write-Log "Install by ID failed or returned no package. Falling back to install by name." 'WARN' Yellow
        $instName = Invoke-WingetInstallByName -Name $Target
        if ($instName.Output) { Write-Host $instName.Output }
        $installSucceeded = ($instName.ExitCode -eq 0) -and (-not ($instName.Output -match 'No package found'))

        if ($installSucceeded) {
            Write-Log "Silent install by name succeeded." 'SUCCESS' Green
            exit 0
        } else {
            Write-Log "Silent install failed. ExitCode=$($instName.ExitCode). Review winget output above." 'ERROR' Red
            exit ($instName.ExitCode)
        }
    } else {
        Write-Log "Silent install by ID succeeded." 'SUCCESS' Green
        exit 0
    }
}

# ------------------------------
# 6) Exit based on search result if not installing
# ------------------------------
if ($searchExit -eq 0) {
    Write-Log "Completed without install. Search successful." 'SUCCESS' Green
} else {
    Write-Log "Completed without install. Search returned ExitCode=$searchExit." 'WARN' Yellow
}
exit $searchExit
```

***

## How to Use

### Search only

```powershell
.\Enable-WingetPolicy.ps1
.\Enable-WingetPolicy.ps1 Google.Chrome
.\Enable-WingetPolicy.ps1 chrome
```

### Search + Silent Install

```powershell
.\Enable-WingetPolicy.ps1 chrome -Install
.\Enable-WingetPolicy.ps1 Google.Chrome -Install
.\Enable-WingetPolicy.ps1 Microsoft.Edge -Install -LogPath "C:\Logs\WingetPolicy.log"
```

### What it does

*   Elevates to Administrator automatically and **preserves your arguments**.
*   Searches by **ID** first, then by **name** if needed.
*   If it sees the Group Policy error (the one you mentioned), it sets:
    *   `HKLM\SOFTWARE\Policies\Microsoft\Windows\AppInstaller`
        *   `EnableExperimentalFeatures` (DWORD) = 1
        *   `EnableAppInstaller` (DWORD) = 1
        *   `EnableHashOverride` (DWORD) = 1
        *   `EnableMSAppInstallerProtocol` (DWORD) = 1
*   Retries the search.
*   If `-Install` is set, it runs:
    *   `winget install --id "<Target>" --silent --accept-source-agreements --accept-package-agreements`
    *   Falls back to `--name "<Target>"` if the ID path fails.
*   Logs everything to the file with timestamps.


