# MCP Registry Pattern

## Contents
- Why a registry
- Registry schema
- Update script (PowerShell)

---

## Why a Registry

Maintain a central JSON registry of installed MCP servers so you can:
- see what’s installed on a device
- track install method/version
- coordinate upgrades across Windows/WSL

---

## Registry Schema

```json
{
  "lastUpdated": "YYYY-MM-DDTHH:MM:SSZ",
  "mcpServers": {
    "desktop-commander": {
      "installed": true,
      "installDate": "YYYY-MM-DD",
      "installMethod": "npx",
      "version": "latest",
      "purpose": "File operations and persistent sessions",
      "configPath": null,
      "notes": "Primary tool for local file operations"
    }
  }
}
```

Template: `templates/mcp-registry.json`.

---

## Registry Update Script (PowerShell)

```powershell
function Update-McpRegistry {
    param(
        [string]$ServerName,
        [string]$InstallMethod,
        [string]$Version,
        [string]$Purpose,
        [string]$ConfigPath,
        [string]$Notes
    )

    $registryPath = $env:MCP_REGISTRY
    $registry = Get-Content $registryPath | ConvertFrom-Json

    $entry = @{
        installed = $true
        installDate = (Get-Date -Format "yyyy-MM-dd")
        installMethod = $InstallMethod
        version = $Version
        purpose = $Purpose
        configPath = $ConfigPath
        notes = $Notes
    }

    if ($registry.mcpServers.PSObject.Properties.Name -contains $ServerName) {
        $registry.mcpServers.$ServerName = $entry
    } else {
        $registry.mcpServers | Add-Member -NotePropertyName $ServerName -NotePropertyValue $entry
    }

    $registry.lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    $registry | ConvertTo-Json -Depth 10 | Set-Content $registryPath

    Write-Host "Updated registry: $ServerName" -ForegroundColor Green
}
```

