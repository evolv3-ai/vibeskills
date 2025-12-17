#Requires -Version 5.1
<#
.SYNOPSIS
    Admin Suite Profile Loader - Loads device profile and deployment configs
.DESCRIPTION
    Reads profile.json and associated .env.local files, making context available
    for scripts and AI assistants.
.PARAMETER ProfilePath
    Path to profile.json (defaults to $HOME/.admin/profiles/$env:COMPUTERNAME.json)
.PARAMETER Deployment
    Optional: Load specific deployment's .env.local
.PARAMETER Export
    Export variables to current session
.EXAMPLE
    . .\Load-Profile.ps1
    Load-AdminProfile -Export
.EXAMPLE
    Load-AdminProfile -Deployment "vibeskills-oci" -Export
#>

[CmdletBinding()]
param(
    [string]$ProfilePath,
    [string]$Deployment,
    [switch]$Export,
    [switch]$Quiet
)

# Default profile location
$DefaultProfileDir = Join-Path $HOME ".admin\profiles"
$DefaultProfilePath = Join-Path $DefaultProfileDir "$env:COMPUTERNAME.json"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    if (-not $Quiet) {
        $color = switch ($Level) {
            "ERROR" { "Red" }
            "WARN"  { "Yellow" }
            "OK"    { "Green" }
            default { "Cyan" }
        }
        Write-Host "[$Level] $Message" -ForegroundColor $color
    }
}

function Load-AdminProfile {
    [CmdletBinding()]
    param(
        [string]$Path = $DefaultProfilePath,
        [string]$DeploymentName,
        [switch]$ExportVars
    )

    if (-not $Path) { $Path = $DefaultProfilePath }
    
    if (-not (Test-Path $Path)) {
        Write-Log "Profile not found: $Path" "ERROR"
        Write-Log "Run Initialize-AdminProfile to create one" "WARN"
        return $null
    }

    Write-Log "Loading profile: $Path"
    
    try {
        $profile = Get-Content $Path -Raw | ConvertFrom-Json
    }
    catch {
        Write-Log "Failed to parse profile: $_" "ERROR"
        return $null
    }

    if ($profile.schemaVersion -ne "3.0") {
        Write-Log "Profile schema version $($profile.schemaVersion) - expected 3.0" "WARN"
    }

    Write-Log "Device: $($profile.device.name) ($($profile.device.platform))" "OK"
    Write-Log "Tools: $($profile.tools.PSObject.Properties.Count) registered"
    Write-Log "Servers: $($profile.servers.Count) managed"

    if ($ExportVars) {
        $global:AdminProfile = $profile
        Write-Log "Exported `$AdminProfile to session" "OK"
    }

    if ($DeploymentName) {
        $deployment = $profile.deployments.$DeploymentName
        if (-not $deployment) {
            Write-Log "Deployment '$DeploymentName' not found in profile" "ERROR"
            Write-Log "Available: $($profile.deployments.PSObject.Properties.Name -join ', ')" "WARN"
        }
        elseif ($deployment.envFile -and (Test-Path $deployment.envFile)) {
            Write-Log "Loading deployment: $DeploymentName"
            $envVars = Load-EnvFile -Path $deployment.envFile
            if ($ExportVars -and $envVars) {
                $global:DeploymentEnv = $envVars
                Write-Log "Exported `$DeploymentEnv to session ($($envVars.Count) vars)" "OK"
            }
        }
        else {
            Write-Log "Deployment '$DeploymentName' has no envFile or file not found" "WARN"
        }
    }

    return $profile
}

function Load-EnvFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [switch]$ExportToEnvironment
    )

    if (-not (Test-Path $Path)) {
        Write-Log "Env file not found: $Path" "ERROR"
        return $null
    }

    Write-Log "Parsing: $Path"
    
    $vars = @{}
    $lines = Get-Content $Path

    foreach ($line in $lines) {
        if ($line -match '^\s*#' -or $line -match '^\s*$') { continue }
        
        if ($line -match '^([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$') {
            $key = $matches[1]
            $value = $matches[2].Trim()
            
            if ($value -match '^"(.*)"$' -or $value -match "^'(.*)'$") {
                $value = $matches[1]
            }
            
            $vars[$key] = $value
            
            if ($ExportToEnvironment) {
                [Environment]::SetEnvironmentVariable($key, $value, "Process")
            }
        }
    }

    Write-Log "Loaded $($vars.Count) variables" "OK"
    return $vars
}

function Get-AdminTool {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Name)

    if (-not $global:AdminProfile) {
        Write-Log "Profile not loaded. Run Load-AdminProfile -Export first" "ERROR"
        return $null
    }

    $tool = $global:AdminProfile.tools.$Name
    if (-not $tool) { Write-Log "Tool '$Name' not in profile" "WARN"; return $null }
    return $tool
}

function Get-AdminServer {
    [CmdletBinding()]
    param([string]$Id, [string]$Role, [string]$Provider)

    if (-not $global:AdminProfile) {
        Write-Log "Profile not loaded" "ERROR"; return $null
    }

    $servers = $global:AdminProfile.servers
    if ($Id) { return $servers | Where-Object { $_.id -eq $Id } }
    if ($Role) { return $servers | Where-Object { $_.role -eq $Role } }
    if ($Provider) { return $servers | Where-Object { $_.provider -eq $Provider } }
    return $servers
}

function Get-AdminPreference {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateSet("python", "node", "packages", "shell", "editor", "terminal")][string]$Category)

    if (-not $global:AdminProfile) { Write-Log "Profile not loaded" "ERROR"; return $null }
    return $global:AdminProfile.preferences.$Category
}

function Test-AdminCapability {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Capability)

    if (-not $global:AdminProfile) { return $false }
    return $global:AdminProfile.capabilities.$Capability -eq $true
}

function Show-AdminSummary {
    if (-not $global:AdminProfile) { Write-Log "Profile not loaded" "ERROR"; return }

    $p = $global:AdminProfile
    
    Write-Host "`n=== Admin Profile Summary ===" -ForegroundColor Cyan
    Write-Host "Device:     $($p.device.name) ($($p.device.platform))"
    Write-Host "User:       $($p.device.user)"
    Write-Host "Shell:      $($p.preferences.shell.preferred)"
    Write-Host ""
    
    Write-Host "Preferences:" -ForegroundColor Yellow
    Write-Host "  Python:   $($p.preferences.python.manager)"
    Write-Host "  Node:     $($p.preferences.node.manager)"
    Write-Host "  Packages: $($p.preferences.packages.manager)"
    Write-Host ""
    
    Write-Host "Capabilities:" -ForegroundColor Yellow
    $caps = @()
    if ($p.capabilities.hasWsl) { $caps += "WSL" }
    if ($p.capabilities.hasDocker) { $caps += "Docker" }
    if ($p.capabilities.mcpEnabled) { $caps += "MCP" }
    if ($p.capabilities.canAccessDropbox) { $caps += "Dropbox" }
    Write-Host "  $($caps -join ', ')"
    Write-Host ""
    
    Write-Host "Servers ($($p.servers.Count)):" -ForegroundColor Yellow
    foreach ($s in $p.servers) {
        $status = if ($s.status -eq "active") { "[+]" } else { "[ ]" }
        Write-Host "  $status $($s.name) ($($s.role)) - $($s.host)"
    }
    Write-Host ""
    
    Write-Host "Deployments:" -ForegroundColor Yellow
    foreach ($d in $p.deployments.PSObject.Properties) {
        $dep = $d.Value
        $hasEnv = if ($dep.envFile) { "[+]" } else { "[ ]" }
        Write-Host "  $hasEnv $($d.Name) ($($dep.type)/$($dep.provider)) - $($dep.status)"
    }
    Write-Host ""
}

if ($Export) {
    $loadedProfile = Load-AdminProfile -Path $ProfilePath -DeploymentName $Deployment -ExportVars
    if ($loadedProfile) { Show-AdminSummary }
}

# Note: Functions are available after dot-sourcing this script
# Usage: . .\Load-Profile.ps1; Load-AdminProfile -Export
