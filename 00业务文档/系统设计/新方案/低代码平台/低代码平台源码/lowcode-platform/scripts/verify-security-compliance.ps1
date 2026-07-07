param()

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Read-Text {
  param([string]$RelativePath)

  $fullPath = Join-Path $repoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    throw ("Missing security compliance artifact: {0}" -f $RelativePath)
  }

  return Get-Content -Encoding UTF8 -Raw -LiteralPath $fullPath
}

function Assert-Contains {
  param(
    [string]$RelativePath,
    [string[]]$Tokens
  )

  $content = Read-Text -RelativePath $RelativePath
  foreach ($token in $Tokens) {
    if ($content -notmatch [Regex]::Escape($token)) {
      throw ("Security compliance token missing: {0} -> {1}" -f $RelativePath, $token)
    }
  }
}

function Assert-ReleaseGapRegister {
  $relativePath = "docs\compliance\release-gap-register.md"
  $content = Read-Text -RelativePath $relativePath
  $lines = @($content -split "`r?`n")
  $header = $null
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i].Trim()
    if ($line -eq "| Gap ID | Current limitation | Evidence signal | Current control | Release-time action | Exit criteria |") {
      $header = $i
      break
    }
  }

  if ($null -eq $header) {
    throw ("Release gap register table header missing: {0}" -f $relativePath)
  }

  $rows = New-Object System.Collections.Generic.List[string]
  for ($i = $header + 2; $i -lt $lines.Count; $i++) {
    $line = $lines[$i].Trim()
    if ([string]::IsNullOrWhiteSpace($line)) {
      break
    }
    if (-not $line.StartsWith("|")) {
      break
    }
    $rows.Add($line)
  }

  if ($rows.Count -eq 0) {
    throw ("Release gap register has no gap rows: {0}" -f $relativePath)
  }

  $violations = New-Object System.Collections.Generic.List[string]
  foreach ($row in $rows) {
    $cells = @($row.Trim("|").Split("|") | ForEach-Object { $_.Trim() })
    if ($cells.Count -ne 6) {
      $violations.Add(("malformed row: {0}" -f $row))
      continue
    }

    $gapId = $cells[0]
    if ([string]::IsNullOrWhiteSpace($gapId)) {
      $gapId = "<empty-id>"
    }

    if ([string]::IsNullOrWhiteSpace($cells[3])) {
      $violations.Add(("{0}: Current control is empty" -f $gapId))
    }
    if ([string]::IsNullOrWhiteSpace($cells[5])) {
      $violations.Add(("{0}: Exit criteria is empty" -f $gapId))
    }
  }

  if ($violations.Count -gt 0) {
    throw ("Release gap register validation failed: {0}" -f ($violations -join "; "))
  }
}

function Assert-NoMainJavaPattern {
  param(
    [string]$RuleId,
    [string]$Description,
    [string]$Pattern
  )

  Write-Host ("Check {0}: {1}" -f $RuleId, $Description)
  $args = @(
    "-n",
    "--hidden",
    "--pcre2",
    "-e", $Pattern,
    "lowcode-app/src/main/java",
    "lowcode-common/src/main/java",
    "-g", "*.java"
  )

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

Assert-Contains -RelativePath "docs\compliance\browser-session-csrf.md" -Tokens @(
  "F9",
  "Browser session",
  "CSRF",
  "X-Gateway-Signature",
  "no cookie-backed browser session",
  "Exit criteria",
  "verify-security-compliance.ps1"
)

Assert-Contains -RelativePath "docs\compliance\README.md" -Tokens @(
  "browser-session-csrf.md",
  "verify-security-compliance.ps1"
)

Assert-Contains -RelativePath "docs\compliance\release-gap-register.md" -Tokens @(
  "BROWSER-SESSION-CSRF",
  "F9",
  "Current control",
  "Exit criteria"
)

Assert-ReleaseGapRegister

Assert-NoMainJavaPattern -RuleId "SEC-F9-001" -Description "servlet HttpSession usage in main code" -Pattern "\bHttpSession\b"
Assert-NoMainJavaPattern -RuleId "SEC-F9-002" -Description "servlet Cookie usage in main code" -Pattern "\bCookie\b"
Assert-NoMainJavaPattern -RuleId "SEC-F9-003" -Description "session attributes in main code" -Pattern "@SessionAttributes\b"
Assert-NoMainJavaPattern -RuleId "SEC-F9-004" -Description "hard-coded JSESSIONID reference" -Pattern "JSESSIONID"
Assert-NoMainJavaPattern -RuleId "SEC-F9-005" -Description "explicit CSRF disable call" -Pattern "csrf\s*\([^)]*\)\s*\.disable\s*\(|csrf\s*\([^)]*disable"

Write-Host "Security compliance gates passed."
