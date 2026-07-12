$ErrorActionPreference = "Stop"

# CI helper: block TODO markers that are not linked to a task id.
$matches = rg --pcre2 -n 'TODO(?!\(T-)' . -g '!scripts/scan-todo.ps1'
if ($LASTEXITCODE -eq 0) {
  Write-Error "Found TODO without task id. Use TODO(T-xxx): ..."
}
