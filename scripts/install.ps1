<#
.SYNOPSIS
  Installs the ticket-memo skill into the skill folders of one or more AI agents (Windows).

.DESCRIPTION
  By default creates a directory junction from each agent's skills folder to
  <repo>\skills\ticket-memo, so `git pull` in the repo updates every agent at once.
  Junctions need no admin rights. Use -Copy for a standalone copy instead.

  Targets:
    claude       %USERPROFILE%\.claude\skills          (Claude Code)
    agents       %USERPROFILE%\.agents\skills          (cross-agent folder: Codex, Gemini CLI and others)
    antigravity  %USERPROFILE%\.gemini\config\skills   (Google Antigravity)

.EXAMPLE
  .\scripts\install.ps1                          # Claude Code only
  .\scripts\install.ps1 -Target claude,antigravity
  .\scripts\install.ps1 -Target all -WhatIf      # show what would happen
  .\scripts\install.ps1 -Target all -Uninstall
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('claude', 'agents', 'antigravity', 'all')]
    [string[]]$Target = @('claude'),
    [switch]$Copy,
    [switch]$Force,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'
$skillName = 'ticket-memo'
$source = (Resolve-Path (Join-Path $PSScriptRoot "..\skills\$skillName")).Path

if (-not (Test-Path (Join-Path $source 'SKILL.md'))) {
    throw "SKILL.md not found in $source - run the script from a clone of the repository."
}

$dirs = [ordered]@{
    claude      = Join-Path $env:USERPROFILE '.claude\skills'
    agents      = Join-Path $env:USERPROFILE '.agents\skills'
    antigravity = Join-Path $env:USERPROFILE '.gemini\config\skills'
}
if ($Target -contains 'all') { $Target = @($dirs.Keys) }

function Test-IsLink([string]$Path) {
    $item = Get-Item -LiteralPath $Path -Force
    return [bool]($item.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function Remove-Link([string]$Path) {
    # rmdir removes only the junction itself, never the files it points to.
    cmd /c rmdir "$Path" | Out-Null
}

foreach ($t in $Target) {
    $dest = Join-Path $dirs[$t] $skillName
    Write-Host "[$t] $dest"

    if ($Uninstall) {
        if (-not (Test-Path -LiteralPath $dest)) { Write-Host '  not installed'; continue }
        if (Test-IsLink $dest) {
            if ($PSCmdlet.ShouldProcess($dest, 'Remove junction')) { Remove-Link $dest; Write-Host '  junction removed' }
        }
        elseif ((Test-Path (Join-Path $dest 'SKILL.md')) -and ((Get-Content (Join-Path $dest 'SKILL.md') -TotalCount 3) -match "name:\s*$skillName")) {
            if ($PSCmdlet.ShouldProcess($dest, 'Remove copied skill folder')) { Remove-Item -LiteralPath $dest -Recurse -Force; Write-Host '  folder removed' }
        }
        else { Write-Warning "  $dest is not a ticket-memo install - left untouched" }
        continue
    }

    if (Test-Path -LiteralPath $dest) {
        if ((Test-IsLink $dest) -and ((Get-Item -LiteralPath $dest -Force).Target -contains $source)) {
            Write-Host '  already linked'; continue
        }
        if (-not $Force) {
            Write-Warning "  $dest already exists - skipped. Re-run with -Force to move it to a .bak folder."
            continue
        }
        $backup = "$dest.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        if ($PSCmdlet.ShouldProcess($dest, "Move existing install to $backup")) {
            if (Test-IsLink $dest) { Remove-Link $dest } else { Move-Item -LiteralPath $dest -Destination $backup }
            Write-Host "  existing install moved aside"
        }
    }

    if ($PSCmdlet.ShouldProcess($dest, $(if ($Copy) { "Copy from $source" } else { "Create junction to $source" }))) {
        New-Item -ItemType Directory -Force -Path $dirs[$t] | Out-Null
        if ($Copy) { Copy-Item -LiteralPath $source -Destination $dest -Recurse }
        else { New-Item -ItemType Junction -Path $dest -Target $source | Out-Null }
        Write-Host '  installed'
    }
}

if (-not $Uninstall) { Write-Host "`nRestart the agent (or start a new session) so it picks up the skill." }
