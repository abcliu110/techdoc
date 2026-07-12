param(
  [string]$MysqlImage = "mysql:8.0.37",
  [string]$RedisImage = "redis:7.4.8"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

function Assert-Command {
  param([string]$Name)

  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw ("Missing command: {0}" -f $Name)
  }
}

function Invoke-Docker {
  param([string[]]$Arguments)

  & docker @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw ("Docker command failed: docker {0}, exit code: {1}" -f ($Arguments -join " "), $LASTEXITCODE)
  }
}

function Test-DockerImage {
  param([string]$Image)

  $previousErrorActionPreference = $ErrorActionPreference
  try {
    $ErrorActionPreference = "Continue"
    & docker image inspect $Image --format "{{.Id}}" 1> $null 2> $null
    return $LASTEXITCODE -eq 0
  } finally {
    $ErrorActionPreference = $previousErrorActionPreference
  }
}

Assert-Command -Name "docker"

Write-Host "Check Docker daemon"
Invoke-Docker -Arguments @("info")

Write-Host "Check Docker context"
Invoke-Docker -Arguments @("context", "inspect")

foreach ($image in @($MysqlImage, $RedisImage)) {
  Write-Host ("Check required Docker image: {0}" -f $image)
  if (Test-DockerImage -Image $image) {
    Write-Host ("Use local image: {0}" -f $image)
  } else {
    Invoke-Docker -Arguments @("pull", $image)
  }
}

Write-Host "Docker/Testcontainers precheck passed."
