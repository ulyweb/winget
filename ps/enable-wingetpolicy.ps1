
# Enable-WingetPolicy.ps1
# Purpose: If winget is blocked by Group Policy, enable required AppInstaller policies, then retry search/install.
# Features:
#   - Dynamic target (ID or name)
#   - Admin self-elevation
#   - Group Policy unblock via registry keys
#   - -Install (silent), -Source, -Version
#   - -WhatIf dry-run
#   - -Select interactive prompt for multiple matches
#   - Logging (Text/JSON/Both), JSON lines friendly to monitoring ingestion
# Usage examples:
#   .\Enable-WingetPolicy.ps1
#   .\Enable-WingetPolicy.ps1 Google.Chrome
#   .\Enable-WingetPolicy.ps1 chrome -Install
#   .\Enable-WingetPolicy.ps1 chrome -Install -Source winget
#   .\Enable-WingetPolicy.ps1 chrome -Install -Version 129.0.6668.60
#   .\Enable-WingetPolicy.ps1 chrome -Install -Select
#   .\Enable-WingetPolicy.ps1 chrome -Install -LogFormat Both -JsonLogPath "C:\Logs\WingetPolicy.jsonlog"
#   .\Enable-WingetPolicy.ps1 chrome -Install -Source msstore -WhatIf

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [Parameter(Position=0, Mandatory=$false)]
    [string]$Target = 'Google.Chrome',

    [switch]$Install,

    # Text log path (default: C:\ProgramData\WingetPolicy\Enable-WingetPolicy.log)
    [string]$LogPath,

    # Log format: Text | Json | Both
    [ValidateSet('Text','Json','Both')]
    [string]$LogFormat = 'Text',

    # JSON log path (default: same folder, Enable-WingetPolicy.jsonlog)
    [string]$JsonLogPath,

    # Optional winget source (e.g., 'winget', 'msstore', etc.)
    [string]$Source,

    # Optional version to install
    [string]$Version,

    # Prompt to select when multiple matches are found
    [switch]$Select
)

# ------------------------------
# 0) Setup log paths
# ------------------------------
$LogDir = Join-Path $env:ProgramData 'WingetPolicy'
if (-not (Test-Path $LogDir)) {
    try { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null } catch { }
}
if (-not $LogPath -or [string]::IsNullOrWhiteSpace($LogPath)) {
    $LogPath = Join-Path $LogDir 'Enable-WingetPolicy.log'
}
if (-not $JsonLogPath -or [string]::IsNullOrWhiteSpace($JsonLogPath)) {
    $JsonLogPath = Join-Path $LogDir 'Enable-WingetPolicy.jsonlog'
}

# ------------------------------
# Logging helpers (Text + JSON)
# ------------------------------
function Write-Log {
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR','SUCCESS','DEBUG')][string]$Level = 'INFO',
        [ConsoleColor]$Color = [ConsoleColor]::Gray,
        [hashtable]$Data
    )
    $tsText = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $tsIso  = (Get-Date).ToString("o")  # ISO 8601
    $lineText = "[$tsText] [$Level] $Message"

    # Console
    Write-Host $lineText -ForegroundColor $Color

    # Text log
    if ($LogFormat -in @('Text','Both')) {
        try { Add-Content -LiteralPath $LogPath -Value $lineText -Encoding UTF8 } catch { }
    }

    # JSON log
    if ($LogFormat -in @('Json','Both')) {
        $obj = [ordered]@{
            ts      = $tsIso
            level   = $Level
            message = $Message
            target  = $Target
            source  = $Source
            version = $Version
            install = [bool]$Install
            host    = $env:COMPUTERNAME
            user    = $env:USERNAME
            whatIf  = [bool]$PSBoundParameters['WhatIf']
        }
        if ($Data) {
            foreach ($k in $Data.Keys) { $obj[$k] = $Data[$k] }
        }
        $jsonLine = ($obj | ConvertTo-Json -Depth 6 -Compress)
        try { Add-Content -LiteralPath $JsonLogPath -Value $jsonLine -Encoding UTF8 } catch { }
    }
}

Write-Log "Script started." 'DEBUG' ([ConsoleColor]::DarkGray) @{
    LogPath     = $LogPath
    JsonLogPath = $JsonLogPath
    LogFormat   = $LogFormat
    Params      = $PSBoundParameters
}

# ------------------------------
# 1) Admin elevation
# ------------------------------
$CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal   = New-Object Security.Principal.WindowsPrincipal $CurrentUser
$IsAdmin     = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Log "This script must be run as Administrator. Restarting elevated..." 'WARN' Yellow
    $psArgs = @(
        "-NoProfile",
        "-ExecutionPolicy","Bypass",
        "-File","`"$PSCommandPath`"",
        "`"$Target`""
    )
    if ($Install)  { $psArgs += "-Install" }
    if ($Select)   { $psArgs += "-Select" }
    if ($LogPath)  { $psArgs += @("-LogPath","`"$LogPath`"") }
    if ($JsonLogPath) { $psArgs += @("-JsonLogPath","`"$JsonLogPath`"") }
    if ($LogFormat) { $psArgs += @("-LogFormat","`"$LogFormat`"") }
    if ($Source)   { $psArgs += @("-Source","`"$Source`"") }
    if ($Version)  { $psArgs += @("-Version","`"$Version`"") }
    if ($PSBoundParameters.ContainsKey('WhatIf')) { $psArgs += "-WhatIf" }

    Start-Process -FilePath "powershell.exe" -ArgumentList $psArgs -Verb RunAs | Out-Null
    exit
}

Write-Log "Running elevated." 'DEBUG' ([ConsoleColor]::DarkGray)

# ------------------------------
# 2) Winget helpers
# ------------------------------
function Test-WingetAvailable {
    try { $null = Get-Command winget -ErrorAction Stop; return $true } catch { return $false }
}

function Invoke-Winget {
    param(
        [Parameter(Mandatory)]
        [ValidateSet('search','install','show')]
        [string]$Command,
        [Parameter(Mandatory)]
        [string]$ArgumentString
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName               = "winget"
    $psi.Arguments              = "$Command $ArgumentString"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.UseShellExecute        = $false
    $psi.CreateNoWindow         = $true

    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    $p.Start() | Out-Null
    $stdout = $p.StandardOutput.ReadToEnd()
    $stderr = $p.StandardError.ReadToEnd()
    $p.WaitForExit()

    $output = ($stdout + "`n" + $stderr).Trim()
    Write-Log "winget $Command $ArgumentString" 'DEBUG' ([ConsoleColor]::DarkGray) @{
        ExitCode = $p.ExitCode
        StdOutLen = $stdout.Length
        StdErrLen = $stderr.Length
        OutputSample = ($output.Substring(0, [Math]::Min(500, $output.Length)))
    }

    [PSCustomObject]@{
        ExitCode = $p.ExitCode
        StdOut   = $stdout
        StdErr   = $stderr
        Output   = $output
    }
}

function Add-SourceArg {
    param([string]$Args, [bool]$Exact = $false)
    $final = $Args
    if ($Exact) { $final += " -e" }
    if (-not [string]::IsNullOrWhiteSpace($Source)) { $final += " --source `"$Source`"" }
    return $final
}

function Build-SearchArgs {
    param([ValidateSet('id','name')][string]$Mode, [string]$Text, [bool]$Exact = $true)
    if ($Mode -eq 'id')   { return Add-SourceArg "--id `"$Text`"" $Exact }
    if ($Mode -eq 'name') { return Add-SourceArg "--name `"$Text`"" $Exact }
}

function Invoke-Search {
    param([ValidateSet('id','name')][string]$Mode, [string]$Text, [bool]$Exact = $true)
    $args = Build-SearchArgs -Mode $Mode -Text $Text -Exact $Exact
    return Invoke-Winget -Command 'search' -ArgumentString $args
}

function Invoke-InstallById {
    param([string]$Id)
    $args = "--id `"$Id`" --silent --accept-source-agreements --accept-package-agreements"
    if ($Version) { $args += " --version `"$Version`"" }
    $args = Add-SourceArg $args $true
    if ($PSCmdlet.ShouldProcess("Package Id '$Id'", "Install (silent)")) {
        return Invoke-Winget -Command 'install' -ArgumentString $args
    } else {
        Write-Log "WHATIF: Would run 'winget install $args'" 'INFO' Cyan
        return [PSCustomObject]@{ ExitCode = 0; Output = "WhatIf: install by Id skipped"; StdOut=""; StdErr="" }
    }
}
function Invoke-InstallByName {
    param([string]$Name)
    $args = "--name `"$Name`" --silent --accept-source-agreements --accept-package-agreements"
    if ($Version) { $args += " --version `"$Version`"" }
    $args = Add-SourceArg $args $true
    if ($PSCmdlet.ShouldProcess("Package Name '$Name'", "Install (silent)")) {
        return Invoke-Winget -Command 'install' -ArgumentString $args
    } else {
        Write-Log "WHATIF: Would run 'winget install $args'" 'INFO' Cyan
        return [PSCustomObject]@{ ExitCode = 0; Output = "WhatIf: install by Name skipped"; StdOut=""; StdErr="" }
    }
}

function Is-GroupPolicyDisabledMessage {
    param([string]$Text)
    return ($Text -match 'This operation is disabled by Group Policy:\s*Enable Windows Package Manager')
}

# ------------------------------
# 3) Search output parsing + selection
# ------------------------------
function Parse-SearchRows {
    param([string]$Output)
    $rows = New-Object System.Collections.Generic.List[object]
    $lines = $Output -split "`r?`n"
    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        if ($line -match '^\s*Name\s+Id\s+') { continue }         # header
        if ($line -match '^-{3,}') { continue }                   # separators
        if ($line -match '^\s*Found\s+\d+\s+matches') { continue }# summary lines
        if ($line -match '^\s*No package found') { continue }
        # Split by 2+ spaces into up to 4 columns
        $cols = ($line -split '\s{2,}').Where({ $_ -ne '' })
        if ($cols.Count -ge 2) {
            $name    = $cols[0].Trim()
            $id      = $cols[1].Trim()
            $version = if ($cols.Count -ge 3) { $cols[2].Trim() } else { $null }
            $source  = if ($cols.Count -ge 4) { $cols[3].Trim() } else { $null }
            $rows.Add([PSCustomObject]@{ Name=$name; Id=$id; Version=$version; Source=$source })
        }
    }
    return $rows
}

function Select-PackageInteractively {
    param([object[]]$Rows)
    if (-not $Rows -or $Rows.Count -eq 0) { return $null }

    # Detect non-interactive environments (e.g., scheduled tasks, pipeline runs)
    $isInteractive = $Host -and $Host.UI -and $Host.UI.RawUI
    if (-not $isInteractive) {
        Write-Log "Non-interactive shell detected; selecting the first match automatically." 'WARN' Yellow
        return $Rows[0]
    }

    Write-Log "Multiple matches found. Prompting user to select one..." 'INFO' Cyan
    $i = 1
    foreach ($r in $Rows) {
        Write-Host ("[{0}] Name='{1}'  Id='{2}'  Version='{3}'  Source='{4}'" -f $i, $r.Name, $r.Id, $r.Version, $r.Source)
        $i++
    }
    while ($true) {
        $choice = Read-Host "Select a package [1..$($Rows.Count)] or 0 to cancel"
        if ([int]::TryParse($choice, [ref]$null)) { } # noop to avoid error
        $n = 0
        try { $n = [int]$choice } catch { $n = -1 }
        if ($n -eq 0) {
            Write-Log "Selection canceled by user." 'WARN' Yellow
            return $null
        }
        if ($n -ge 1 -and $n -le $Rows.Count) {
            $sel = $Rows[$n-1]
            Write-Log "Selected: Id='$($sel.Id)' Name='$($sel.Name)' Version='$($sel.Version)' Source='$($sel.Source)'" 'SUCCESS' Green
            return $sel
        }
        Write-Log "Invalid selection '$choice'. Try again." 'WARN' Yellow
    }
}

# Resolve an ID using exact search; if ambiguous and -Select is set, prompt.
# If exact yields none, try non-exact and allow selection if requested.
function Resolve-PackageId {
    param([string]$TargetText)

    Write-Log "Resolving package Id for '$TargetText'." 'INFO' Cyan

    # 1) Exact by Id
    $s1 = Invoke-Search -Mode 'id' -Text $TargetText -Exact $true
    $rows1 = Parse-SearchRows -Output $s1.Output
    if ($rows1.Count -ge 1) {
        if ($rows1.Count -eq 1 -or -not $Select) {
            $chosen = $rows1[0]
        } else {
            $chosen = Select-PackageInteractively -Rows $rows1
        }
        if ($null -ne $chosen) {
            Write-Log "Resolved via exact Id search: '$($chosen.Id)'." 'SUCCESS' Green @{ Method='ExactId'; Matches=$rows1.Count }
            return $chosen.Id
        }
    }

    # 2) Exact by Name
    $s2 = Invoke-Search -Mode 'name' -Text $TargetText -Exact $true
    $rows2 = Parse-SearchRows -Output $s2.Output
    if ($rows2.Count -ge 1) {
        if ($rows2.Count -eq 1 -or -not $Select) {
            $chosen = $rows2[0]
        } else {
            $chosen = Select-PackageInteractively -Rows $rows2
        }
        if ($null -ne $chosen) {
            Write-Log "Resolved via exact Name search: '$($chosen.Id)'." 'SUCCESS' Green @{ Method='ExactName'; Matches=$rows2.Count }
            return $chosen.Id
        }
    }

    # 3) Non-exact by Id (broader)
    $s3 = Invoke-Search -Mode 'id' -Text $TargetText -Exact $false
    $rows3 = Parse-SearchRows -Output $s3.Output
    if ($rows3.Count -ge 1) {
        if ($rows3.Count -eq 1 -or -not $Select) {
            $chosen = $rows3[0]
        } else {
            $chosen = Select-PackageInteractively -Rows $rows3
        }
        if ($null -ne $chosen) {
            Write-Log "Resolved via non-exact Id search: '$($chosen.Id)'." 'SUCCESS' Green @{ Method='LooseId'; Matches=$rows3.Count }
            return $chosen.Id
        }
    }

    # 4) Non-exact by Name (broader)
    $s4 = Invoke-Search -Mode 'name' -Text $TargetText -Exact $false
    $rows4 = Parse-SearchRows -Output $s4.Output
    if ($rows4.Count -ge 1) {
        if ($rows4.Count -eq 1 -or -not $Select) {
            $chosen = $rows4[0]
        } else {
            $chosen = Select-PackageInteractively -Rows $rows4
        }
        if ($null -ne $chosen) {
            Write-Log "Resolved via non-exact Name search: '$($chosen.Id)'." 'SUCCESS' Green @{ Method='LooseName'; Matches=$rows4.Count }
            return $chosen.Id
        }
    }

    Write-Log "Failed to resolve a package Id for '$TargetText'." 'ERROR' Red
    return $null
}

# ------------------------------
# 4) Registry policy enforcement
# ------------------------------
$AppInstallerPolicyKey = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppInstaller'
function Ensure-AppInstallerPolicies {
    try {
        if ($PSCmdlet.ShouldProcess("Registry '$AppInstallerPolicyKey'", "Create/Update AppInstaller policy values")) {
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
            Write-Log "AppInstaller policies applied to enable winget usage." 'SUCCESS' Green @{ Registry=$AppInstallerPolicyKey }
            return $true
        } else {
            Write-Log "WHATIF: Would set AppInstaller policy values under '$AppInstallerPolicyKey'." 'INFO' Cyan
            return $true
        }
    } catch {
        Write-Log "Failed to set AppInstaller policies: $($_.Exception.Message)" 'ERROR' Red
        return $false
    }
}

# ------------------------------
# 5) Main flow
# ------------------------------
if (-not (Test-WingetAvailable)) {
    Write-Log "winget is not available. Install App Installer, then rerun." 'ERROR' Red
    exit 1
}

Write-Log "Initial winget search (exact by Id) for '$Target'." 'INFO' Cyan
$initial = Invoke-Search -Mode 'id' -Text $Target -Exact $true
if ($initial.Output) { Write-Host $initial.Output }

$policyBlocked = Is-GroupPolicyDisabledMessage -Text $initial.Output
if ($policyBlocked) {
    Write-Log "Detected Group Policy blocking winget. Applying registry policy changes..." 'WARN' Yellow
    $ok = Ensure-AppInstallerPolicies
    if (-not $ok) {
        Write-Log "Policy application failed. Verify registry permissions." 'ERROR' Red
        exit 1
    }
    Write-Log "Retrying winget search by exact Id..." 'INFO' Cyan
    Start-Sleep -Seconds 2
    $retry = Invoke-Search -Mode 'id' -Text $Target -Exact $true
    if ($retry.Output) { Write-Host $retry.Output }
    if (Is-GroupPolicyDisabledMessage -Text $retry.Output) {
        Write-Log "Winget still blocked by Group Policy after applying policies. Consider additional enterprise controls or reboot." 'ERROR' Red
        exit 1
    }
    $searchExit = $retry.ExitCode
} else {
    $searchExit = $initial.ExitCode
    # If exact Id returns no rows, try exact name
    $rowsInitial = Parse-SearchRows -Output $initial.Output
    if ($rowsInitial.Count -eq 0) {
        Write-Log "Exact Id search returned no rows; trying exact Name search." 'WARN' Yellow
        $byName = Invoke-Search -Mode 'name' -Text $Target -Exact $true
        if ($byName.Output) { Write-Host $byName.Output }
        $searchExit = $byName.ExitCode
    }
}

# ------------------------------
# 6) Resolve Id and optional install
# ------------------------------
$resolvedId = Resolve-PackageId -TargetText $Target

if ($Install) {
    if ($null -eq $resolvedId) {
        Write-Log "Install skipped: could not resolve a package Id. Use -Select to disambiguate." 'ERROR' Red
        exit 2
    }
    Write-Log "Starting silent install using Id '$resolvedId'." 'INFO' Cyan @{ ResolvedId=$resolvedId }
    $inst = Invoke-InstallById -Id $resolvedId
    if ($inst.Output) { Write-Host $inst.Output }
    if ($inst.ExitCode -eq 0 -and -not ($inst.Output -match 'No package found')) {
        Write-Log "Silent install by Id succeeded." 'SUCCESS' Green @{ ExitCode=$inst.ExitCode }
        exit 0
    } else {
        Write-Log "Install by Id failed (ExitCode=$($inst.ExitCode)). Attempting by Name fallback." 'WARN' Yellow
        $instName = Invoke-InstallByName -Name $Target
        if ($instName.Output) { Write-Host $instName.Output }
        if ($instName.ExitCode -eq 0 -and -not ($instName.Output -match 'No package found')) {
            Write-Log "Silent install by Name succeeded." 'SUCCESS' Green @{ ExitCode=$instName.ExitCode }
            exit 0
        } else {
            Write-Log "Silent install failed. ExitCode=$($instName.ExitCode). Review winget output." 'ERROR' Red @{ ExitCode=$instName.ExitCode }
            exit ($instName.ExitCode)
        }
    }
}

# ------------------------------
# 7) Exit based on search if not installing
# ------------------------------
if ($searchExit -eq 0) {
    Write-Log "Completed without install. Search successful." 'SUCCESS' Green @{ ExitCode=$searchExit }
} else {
    Write-Log "Completed without install. Search returned ExitCode=$searchExit." 'WARN' Yellow @{ ExitCode=$searchExit }
}
exit $searchExit
