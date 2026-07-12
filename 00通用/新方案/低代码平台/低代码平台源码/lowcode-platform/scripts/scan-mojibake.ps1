$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$baseArgs = @(
  "-n",
  "--hidden",
  "-F",
  ".",
  "-g", "!.git/**",
  "-g", "!**/node_modules/**",
  "-g", "!**/dist/**",
  "-g", "!**/target/**",
  "-g", "!scripts/scan-mojibake.ps1"
)

function Invoke-FixedStringGate {
  param(
    [string]$RuleId,
    [string]$Description,
    [string]$Needle
  )

  Write-Host ("Check {0}: {1}" -f $RuleId, $Description)
  $args = @($Needle) + $baseArgs

  Push-Location -LiteralPath $repoRoot
  try {
    & rg @args
    if ($LASTEXITCODE -eq 0) {
      throw ("{0} matched: {1}" -f $RuleId, $Description)
    }
    if ($LASTEXITCODE -gt 1) {
      throw ("{0} failed, ripgrep exit code: {1}" -f $RuleId, $LASTEXITCODE)
    }
  } finally {
    Pop-Location
  }
}

Invoke-FixedStringGate -RuleId "ENC-001" -Description "unicode replacement character" -Needle ([string][char]0xFFFD)
Invoke-FixedStringGate -RuleId "ENC-002" -Description "triple question marks" -Needle "???"

Write-Host "Mojibake scan passed."
