$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

Push-Location -LiteralPath $repoRoot
try {
  $ddlArgs = @(
    "-n",
    "--pcre2",
    "-e",
    "DROP\\s+TABLE|DROP\\s+COLUMN|ALTER\\s+TABLE|DELETE\\s+FROM",
    ".",
    "-g", "*.java",
    "-g", "!**/target/**",
    "-g", "!**/node_modules/**",
    "-g", "!**/src/test/**"
  )
  & rg @ddlArgs
  if ($LASTEXITCODE -eq 0) {
    throw "Found risky SQL pattern. Dynamic DDL must come from Schema Sync."
  }
  if ($LASTEXITCODE -gt 1) {
    throw ("ripgrep failed while scanning DDL risk, exit code: {0}" -f $LASTEXITCODE)
  }

  $runtimeSqlArgs = @(
    "-n",
    "--pcre2",
    "-e",
    '"(select|insert|update|delete)\s+',
    "lowcode-runtime/src/main/java/com/lowcode/runtime/data",
    "-g", "*.java",
    "-g", "!DynamicSqlAssembler.java"
  )
  & rg @runtimeSqlArgs
  if ($LASTEXITCODE -eq 0) {
    throw "Found runtime SQL text outside DynamicSqlAssembler."
  }
  if ($LASTEXITCODE -gt 1) {
    throw ("ripgrep failed while scanning runtime SQL boundary, exit code: {0}" -f $LASTEXITCODE)
  }
} finally {
  Pop-Location
}
