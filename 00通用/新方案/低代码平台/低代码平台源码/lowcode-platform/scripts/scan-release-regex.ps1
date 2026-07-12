param(
  [ValidateSet("All", "P0", "P1")]
  [string]$Level = "All"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$baseArgs = @(
  "-n",
  "--hidden",
  "--pcre2",
  ".",
  "-g", "!.git/**",
  "-g", "!docs/**",
  "-g", "!scripts/scan-release-regex.ps1",
  "-g", "!**/node_modules/**",
  "-g", "!**/dist/**",
  "-g", "!**/target/**"
)

function Invoke-RegexGate {
  param(
    [string]$RuleId,
    [string]$Description,
    [string]$Pattern
  )

  Write-Host ("Check {0}: {1}" -f $RuleId, $Description)
  $args = @("-e", $Pattern) + $baseArgs

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

if ($Level -in @("All", "P0")) {
  Invoke-RegexGate -RuleId "P0-001" -Description "merge conflict markers" -Pattern "^(<<<<<<<|=======|>>>>>>>)"
  Invoke-RegexGate -RuleId "P0-002" -Description "private key material" -Pattern "BEGIN [A-Z0-9 ]*PRIVATE KEY"
  Invoke-RegexGate -RuleId "P0-003" -Description "cloud credential pattern" -Pattern "AKIA[0-9A-Z]{16}"
}

if ($Level -in @("All", "P1")) {
  Invoke-RegexGate -RuleId "P1-001" -Description "console.log debug output" -Pattern 'console\.log\s*\('
  Invoke-RegexGate -RuleId "P1-002" -Description "System.out.println debug output" -Pattern 'System\.out\.println\s*\('
  Invoke-RegexGate -RuleId "P1-003" -Description "printStackTrace debug output" -Pattern 'printStackTrace\s*\('
  Invoke-RegexGate -RuleId "P1-004" -Description "debugger statement" -Pattern '\bdebugger\s*;'
  Invoke-RegexGate -RuleId "P1-005" -Description "@ts-ignore marker" -Pattern "@ts-ignore"
  Invoke-RegexGate -RuleId "P1-006" -Description "FIXME/HACK/XXX marker" -Pattern '\b(FIXME|HACK|XXX)\b'
}

Write-Host "P0/P1 regex gates passed."
