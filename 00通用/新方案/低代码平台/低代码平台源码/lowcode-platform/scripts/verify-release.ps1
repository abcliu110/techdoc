param(
  [switch]$Light,
  [switch]$SelfCheck,
  [switch]$SkipBackendVerify,
  [switch]$SkipFrontendVerify
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$script:ExitCode = 0
$script:Results = @()

function Add-Result {
  param(
    [string]$Step,
    [string]$Status,
    [double]$Seconds,
    [string]$Detail
  )

  $script:Results += [pscustomobject]@{
    Step = $Step
    Status = $Status
    Seconds = [Math]::Round($Seconds, 2)
    Detail = $Detail
  }
}

function Assert-Command {
  param(
    [string]$Name,
    [string]$Hint = ""
  )

  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    if ([string]::IsNullOrWhiteSpace($Hint)) {
      throw ("Missing command: {0}" -f $Name)
    }
    throw ("Missing command: {0}. {1}" -f $Name, $Hint)
  }
}

function Invoke-Native {
  param(
    [string]$Command,
    [string[]]$Arguments = @(),
    [string]$WorkingDirectory = ""
  )

  if ([string]::IsNullOrWhiteSpace($WorkingDirectory)) {
    $WorkingDirectory = $repoRoot
  }

  Push-Location -LiteralPath $WorkingDirectory
  try {
    Write-Host ("   Command: {0} {1}" -f $Command, ($Arguments -join " "))
    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
      throw ("Command failed: {0}, exit code: {1}" -f $Command, $LASTEXITCODE)
    }
  } finally {
    Pop-Location
  }
}

function Invoke-ChildScript {
  param(
    [string]$RelativePath,
    [string[]]$Arguments = @()
  )

  $scriptPath = Join-Path $repoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw ("Missing script: {0}" -f $RelativePath)
  }

  Write-Host ("   Script: {0}" -f $RelativePath)
  & $scriptPath @Arguments
}

function Ensure-Pnpm {
  if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    return
  }

  Assert-Command -Name "corepack" -Hint "Install Node 20+ or enable pnpm via corepack."
  Invoke-Native -Command "corepack" -Arguments @("enable")

  if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
    throw "pnpm is still unavailable after corepack enable."
  }
}

function Run-Step {
  param(
    [string]$Name,
    [scriptblock]$Action
  )

  Write-Host ""
  Write-Host ("==> {0}" -f $Name)
  $watch = [System.Diagnostics.Stopwatch]::StartNew()

  try {
    & $Action
    Add-Result -Step $Name -Status "PASS" -Seconds $watch.Elapsed.TotalSeconds -Detail ""
  } catch {
    Add-Result -Step $Name -Status "FAIL" -Seconds $watch.Elapsed.TotalSeconds -Detail $_.Exception.Message
    throw
  }
}

function Show-Summary {
  Write-Host ""
  Write-Host "==> Summary"
  $script:Results | Format-Table -AutoSize
}

try {
  Run-Step -Name "Environment check" -Action {
    Assert-Command -Name "rg" -Hint "ripgrep is required."
    if (-not $SelfCheck -and -not $Light -and -not $SkipBackendVerify) {
      Assert-Command -Name "mvn" -Hint "Maven 3.9+ and Java 21 are required."
    }
    if (-not $SelfCheck -and -not $Light -and -not $SkipFrontendVerify) {
      if (-not (Get-Command pnpm -ErrorAction SilentlyContinue) -and -not (Get-Command corepack -ErrorAction SilentlyContinue)) {
        throw "Frontend verification requires pnpm or corepack."
      }
    }
  }

  Run-Step -Name "Placeholder gates" -Action {
    $placeholderArgs = @()
    if ($SelfCheck) {
      $placeholderArgs += "-SelfCheck"
    }
    Invoke-ChildScript -RelativePath "scripts\verify-placeholder-gates.ps1" -Arguments $placeholderArgs
  }

  Run-Step -Name "Existing scan: scan-todo.ps1" -Action {
    Invoke-ChildScript -RelativePath "scripts\scan-todo.ps1"
  }

  Run-Step -Name "Existing scan: scan-sql-risk.ps1" -Action {
    Invoke-ChildScript -RelativePath "scripts\scan-sql-risk.ps1"
  }

  Run-Step -Name "Existing scan: scan-sensitive-log.ps1" -Action {
    Invoke-ChildScript -RelativePath "scripts\scan-sensitive-log.ps1"
  }

  Run-Step -Name "P0/P1 regex gates" -Action {
    Invoke-ChildScript -RelativePath "scripts\scan-release-regex.ps1"
  }

  Run-Step -Name "Security compliance gates" -Action {
    Invoke-ChildScript -RelativePath "scripts\verify-security-compliance.ps1"
  }

  Run-Step -Name "Mojibake scan" -Action {
    Invoke-ChildScript -RelativePath "scripts\scan-mojibake.ps1"
  }

  if (-not $SelfCheck -and -not $Light -and -not $SkipBackendVerify) {
    Run-Step -Name "Docker/Testcontainers precheck" -Action {
      Invoke-ChildScript -RelativePath "scripts\verify-docker-testcontainers.ps1"
    }

    Run-Step -Name "Backend verify" -Action {
      Invoke-Native -Command "mvn" -Arguments @("-B", "clean", "verify", "-Dlowcode.it=true")
    }
  }

  if (-not $SelfCheck -and -not $Light -and -not $SkipFrontendVerify) {
    Run-Step -Name "Frontend lint/typecheck/test/build" -Action {
      Ensure-Pnpm
      $webRoot = Join-Path $repoRoot "lowcode-web"
      Invoke-Native -Command "pnpm" -Arguments @("install", "--frozen-lockfile") -WorkingDirectory $webRoot
      Invoke-Native -Command "pnpm" -Arguments @("lint") -WorkingDirectory $webRoot
      Invoke-Native -Command "pnpm" -Arguments @("typecheck") -WorkingDirectory $webRoot
      Invoke-Native -Command "pnpm" -Arguments @("test") -WorkingDirectory $webRoot
      Invoke-Native -Command "pnpm" -Arguments @("build") -WorkingDirectory $webRoot
    }
  }
} catch {
  $script:ExitCode = 1
  Write-Error $_
} finally {
  Show-Summary
}

if ($Light) {
  Write-Host "Light verification completed."
}

if ($SelfCheck) {
  Write-Host "Self-check completed."
}

exit $script:ExitCode
