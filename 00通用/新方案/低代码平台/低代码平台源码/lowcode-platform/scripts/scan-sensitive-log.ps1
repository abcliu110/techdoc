$ErrorActionPreference = "Stop"

# CI helper: flag log leaks and obvious hardcoded credentials in non-test sources.
$logMatches = rg -n "(log|logger|console\\.(log|error|warn)|System\\.out\\.println|Write-(Host|Error)).*(password|secret|token|accessKey|privateKey)" . -g "*.java" -g "*.ts" -g "*.tsx" -g "!**/src/test/**" -g "!**/*.test.ts" -g "!**/*.test.tsx" -g "!**/dist/**"
if ($LASTEXITCODE -eq 0) {
  Write-Error "Found sensitive keyword in logging context."
}

$secretMatches = rg -n '(password|secret|token|accessKey|privateKey)[A-Za-z_]*[[:space:]]*[:=][[:space:]]*"' . -g "*.java" -g "*.ts" -g "*.tsx" -g "!**/src/test/**" -g "!**/*.test.ts" -g "!**/*.test.tsx" -g "!**/dist/**"
if ($LASTEXITCODE -eq 0) {
  Write-Error "Found possible hardcoded secret in non-test source."
}
