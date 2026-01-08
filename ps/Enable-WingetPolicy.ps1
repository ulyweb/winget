
# Enable-WingetPolicy.ps1
# Purpose: If winget is blocked by Group Policy, enable required AppInstaller policies, then retry.
# Usage examples:
#   .\Enable-WingetPolicy.ps1              # defaults to Google.Chrome (ID)
#   .\Enable-WingetPolicy.ps1 Google.Chrome
#   .\Enable-WingetPolicy.ps1 chrome       # will try --id chrome, then fallback to --name chrome

[CmdletBinding()]
param(
    # Accept a positional parameter for the package target. Default is Google.Chrome.
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Target = 'Google.Chrome'
)

# ------------------------------
# 1) Check if running as Administrator and elevate if needed
# ------------------------------
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal    = New-Object Security.Principal.WindowsPrincipal $CurrentUser
$IsAdmin      = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "This script must be run as an Administrator. Restarting with elevated privileges..."
    $psArgs = @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`"",
        "`"$Target`""
    )
    Start-Process -FilePath "powershell.exe" -ArgumentList $psArgs -Verb RunAs
    exit
}

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
    # Capture stdout + stderr
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

    return [PSCustomObject]@{
        ExitCode = $p.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
        Output   = ($stdout + "`n" + $stderr).Trim()
    }
}

function Invoke-WingetSearchById {
    param([string]$Id)
    return Invoke-Winget -Command 'search' -ArgumentString "--id `"$Id`""
}

function Invoke-WingetSearchByName {
    param([string]$Name)
    return Invoke-Winget -Command 'search' -ArgumentString "--name `"$Name`""
}

function Is-GroupPolicyDisabledMessage {
    param([string]$Text)
    # Canonical example:
    # "This operation is disabled by Group Policy: Enable Windows Package Manager"
    return ($Text -match 'This operation is disabled by Group Policy:\s*Enable Windows Package Manager')
}

# ------------------------------
# 3) Registry policy enforcement (PowerShell-native equivalent of your REG ADD commands)
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

        Write-Host "AppInstaller policies set to enable winget usage." -ForegroundColor Green
        return $true
    } catch {
        Write-Host "Failed to set AppInstaller policies: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ------------------------------
# 4) Main flow
# ------------------------------

if (-not (Test-WingetAvailable)) {
    Write-Host "winget is not available on this system. Please install App Installer from Microsoft Store or enterprise distribution, then rerun this script." -ForegroundColor Yellow
    exit 1
}

Write-Host "Attempting winget search by ID: `"$Target`"" -ForegroundColor Cyan
$initial = Invoke-WingetSearchById -Id $Target

if ($initial.Output) { Write-Host $initial.Output }

$policyBlocked = Is-GroupPolicyDisabledMessage -Text $initial.Output

if ($policyBlocked) {
    Write-Host "Detected Group Policy blocking winget. Applying registry policy changes..." -ForegroundColor Yellow

    $ok = Ensure-AppInstallerPolicies
    if (-not $ok) {
        Write-Host "Policy application failed. Please verify registry permissions and try again." -ForegroundColor Red
        exit 1
    }

    Write-Host "Retrying winget search by ID..." -ForegroundColor Cyan
    Start-Sleep -Seconds 2
    $retry = Invoke-WingetSearchById -Id $Target

    if ($retry.Output) { Write-Host $retry.Output }

    if (Is-GroupPolicyDisabledMessage -Text $retry.Output) {
        Write-Host "Winget still appears blocked by Group Policy after applying policies. Consider checking additional policies or rebooting." -ForegroundColor Red
        exit 1
    } else {
        Write-Host "Success: winget appears to be working after policy change." -ForegroundColor Green
        exit 0
    }
}
else {
    # If not blocked by policy but the ID search didn't yield results, try name search as a convenience.
    $noResultsById =
        ($initial.ExitCode -ne 0 -and -not $initial.Output) -or
        ($initial.Output -match 'No package found') -or
        ($initial.Output -match 'No installed package found') -or
        ($initial.Output -match '0 packages found')

    if ($noResultsById) {
        Write-Host "ID search did not return results. Falling back to name search: `"$Target`"" -ForegroundColor Yellow
        $byName = Invoke-WingetSearchByName -Name $Target
        if ($byName.Output) { Write-Host $byName.Output }
        if ($byName.ExitCode -eq 0) {
            Write-Host "Name search completed." -ForegroundColor Green
            exit 0
        } else {
            Write-Host "winget search (name) returned ExitCode $($byName.ExitCode). Review output above." -ForegroundColor Yellow
            exit $byName.ExitCode
        }
    } else {
        Write-Host "ID search completed." -ForegroundColor Green
        exit $initial.ExitCode
    }
}
