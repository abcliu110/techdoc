param(
  [switch]$SelfCheck
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

$requiredFiles = @(
  "docs\runbooks\README.md",
  "docs\runbooks\release.md",
  "docs\runbooks\rollback.md",
  "docs\runbooks\ddl-partial-apply-repair.md",
  "docs\runbooks\release-observability.md",
  "docs\runbooks\dependency-license-compliance.md",
  "docs\runbooks\docker-testcontainers.md",
  "docs\runbooks\import-export.md",
  "docs\runbooks\permission-exception.md",
  "docs\runbooks\plugin-upgrade-failed.md",
  "docs\review\manual-checklist.md",
  "docs\review\release-checklist.md",
  "docs\compliance\README.md",
  "docs\compliance\dependency-admission.md",
  "docs\compliance\formal-toolchain-migration.md",
  "docs\compliance\license-sbom.md",
  "docs\compliance\license-inventory.json",
  "docs\compliance\openapi-http-baseline.txt",
  "docs\compliance\sbom-minimal.json",
  "docs\compliance\release-gap-register.md",
  "docs\compliance\saas-private-boundary.md",
  "scripts\export-release-baselines.ps1",
  ".github\pull_request_template.md",
  ".github\workflows\release-gate.yml"
)

$javaPomFiles = @(
  "pom.xml",
  "lowcode-app\pom.xml",
  "lowcode-common\pom.xml",
  "lowcode-designer\pom.xml",
  "lowcode-expression\pom.xml",
  "lowcode-metamodel\pom.xml",
  "lowcode-plugin\pom.xml",
  "lowcode-runtime\pom.xml",
  "lowcode-workflow\pom.xml"
)

$packageJsonFiles = @(
  "lowcode-web\package.json",
  "lowcode-web\packages\app\package.json",
  "lowcode-web\packages\builder\package.json",
  "lowcode-web\packages\renderer\package.json",
  "lowcode-web\packages\shared\package.json"
)

function Assert-Exists {
  param([string]$RelativePath)

  $fullPath = Join-Path $repoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $fullPath)) {
    throw ("Missing release-gate artifact: {0}" -f $RelativePath)
  }
}

function Read-Text {
  param([string]$RelativePath)

  $fullPath = Join-Path $repoRoot $RelativePath
  return Get-Content -Encoding UTF8 -Raw -LiteralPath $fullPath
}

function Read-JsonFile {
  param([string]$RelativePath)

  return Read-Text -RelativePath $RelativePath | ConvertFrom-Json
}

function Assert-Contains {
  param(
    [string]$RelativePath,
    [string[]]$Tokens
  )

  $content = Read-Text -RelativePath $RelativePath
  foreach ($token in $Tokens) {
    if ($content -notmatch [Regex]::Escape($token)) {
      throw ("Gate token missing: {0} -> {1}" -f $RelativePath, $token)
    }
  }
}

function Add-StringSetValue {
  param(
    [hashtable]$Set,
    [string]$Value
  )

  if (-not [string]::IsNullOrWhiteSpace($Value)) {
    $Set[$Value] = $true
  }
}

function Normalize-StringArray {
  param([object]$Value)

  $items = New-Object System.Collections.Generic.List[string]
  if ($null -eq $Value) {
    return $items
  }

  foreach ($entry in @($Value)) {
    if ($null -ne $entry) {
      $text = [string]$entry
      if (-not [string]::IsNullOrWhiteSpace($text)) {
        $items.Add($text.Trim())
      }
    }
  }

  return $items
}

function Normalize-DependencyKey {
  param(
    [string]$Id,
    [string[]]$Scopes,
    [string[]]$Versions
  )

  $scopePart = ((Normalize-StringArray -Value $Scopes | Sort-Object) -join ",")
  $versionPart = ((Normalize-StringArray -Value $Versions | Sort-Object) -join ",")
  return ("{0}|{1}|{2}" -f $Id.Trim(), $scopePart, $versionPart)
}

function Resolve-MavenPropertyTokens {
  param(
    [string]$Value,
    [hashtable]$Properties
  )

  if ([string]::IsNullOrWhiteSpace($Value)) {
    return $Value
  }

  return ([Regex]::Replace($Value, '\$\{([^}]+)\}', {
        param($match)
        $name = $match.Groups[1].Value
        if ($Properties.ContainsKey($name)) {
          return [string]$Properties[$name]
        }
        return $match.Value
      }))
}

function Get-MavenProperties {
  param(
    [System.Xml.XmlNode]$ProjectNode,
    [hashtable]$BaseProperties = @{}
  )

  $map = @{}
  foreach ($key in $BaseProperties.Keys) {
    $map[$key] = $BaseProperties[$key]
  }
  foreach ($propertyNode in @(Get-XmlChildNodes -Node $ProjectNode -Path "properties/*")) {
    if ($null -eq $propertyNode) {
      continue
    }
    $map[$propertyNode.LocalName] = ([string]$propertyNode.InnerText).Trim()
  }
  return $map
}

function Get-XmlChildNode {
  param(
    [System.Xml.XmlNode]$Node,
    [string]$LocalName
  )

  if ($null -eq $Node) {
    return $null
  }

  return $Node.SelectSingleNode("*[local-name()='" + $LocalName + "']")
}

function Get-XmlChildNodes {
  param(
    [System.Xml.XmlNode]$Node,
    [string]$Path
  )

  if ($null -eq $Node) {
    return @()
  }

  $segments = @($Path -split "/")
  $xpath = "."
  foreach ($segment in $segments) {
    if ($segment -eq "*") {
      $xpath += "/*"
    } else {
      $xpath += "/*[local-name()='" + $segment + "']"
    }
  }

  return @($Node.SelectNodes($xpath))
}

function Get-XmlNodeText {
  param(
    [System.Xml.XmlNode]$Node,
    [string]$LocalName,
    [string]$DefaultValue = ""
  )

  $child = Get-XmlChildNode -Node $Node -LocalName $LocalName
  if ($null -eq $child) {
    return $DefaultValue
  }

  $text = [string]$child.InnerText
  if ([string]::IsNullOrWhiteSpace($text)) {
    return $DefaultValue
  }

  return $text.Trim()
}

function Get-PomDirectDependencies {
  param([string]$RelativePath)

  [xml]$pom = Read-Text -RelativePath $RelativePath
  $results = New-Object System.Collections.Generic.List[object]

  $projectNode = $pom.project
  if ($null -eq $projectNode) {
    return $results
  }

  [xml]$rootPom = Read-Text -RelativePath "pom.xml"
  $rootProperties = @{}
  if ($RelativePath -ne "pom.xml" -and $null -ne $rootPom.project) {
    $rootProperties = Get-MavenProperties -ProjectNode $rootPom.project
  }

  $properties = Get-MavenProperties -ProjectNode $projectNode -BaseProperties $rootProperties

  $dependencyNodes = Get-XmlChildNodes -Node $projectNode -Path "dependencies/dependency"
  foreach ($dependency in @($dependencyNodes)) {
    if ($null -eq $dependency) {
      continue
    }

    $groupId = Get-XmlNodeText -Node $dependency -LocalName "groupId"
    $artifactId = Get-XmlNodeText -Node $dependency -LocalName "artifactId"
    if ([string]::IsNullOrWhiteSpace($groupId) -or [string]::IsNullOrWhiteSpace($artifactId)) {
      continue
    }

    $scope = Resolve-MavenPropertyTokens -Value (Get-XmlNodeText -Node $dependency -LocalName "scope" -DefaultValue "compile") -Properties $properties
    $version = Resolve-MavenPropertyTokens -Value (Get-XmlNodeText -Node $dependency -LocalName "version" -DefaultValue "managed") -Properties $properties

    $results.Add([pscustomobject]@{
        Id = ("{0}:{1}" -f $groupId.Trim(), $artifactId.Trim())
        Scope = $scope
        Version = $version
        DeclaredIn = $RelativePath.Replace("\", "/")
      })
  }

  $dependencyManagementNode = Get-XmlChildNode -Node $projectNode -LocalName "dependencyManagement"
  if ($null -ne $dependencyManagementNode) {
    $managedDependencyNodes = Get-XmlChildNodes -Node $dependencyManagementNode -Path "dependencies/dependency"
    foreach ($dependency in @($managedDependencyNodes)) {
      if ($null -eq $dependency) {
        continue
      }

      $groupId = Get-XmlNodeText -Node $dependency -LocalName "groupId"
      $artifactId = Get-XmlNodeText -Node $dependency -LocalName "artifactId"
      if ([string]::IsNullOrWhiteSpace($groupId) -or [string]::IsNullOrWhiteSpace($artifactId)) {
        continue
      }

      $scope = Resolve-MavenPropertyTokens -Value (Get-XmlNodeText -Node $dependency -LocalName "scope" -DefaultValue "managed") -Properties $properties
      $version = Resolve-MavenPropertyTokens -Value (Get-XmlNodeText -Node $dependency -LocalName "version" -DefaultValue "managed") -Properties $properties
      $results.Add([pscustomobject]@{
          Id = ("{0}:{1}" -f $groupId.Trim(), $artifactId.Trim())
          Scope = $scope
          Version = $version
          DeclaredIn = $RelativePath.Replace("\", "/")
        })
    }
  }

  return $results
}

function Get-PackageDirectDependencies {
  param([string]$RelativePath)

  $package = Read-JsonFile -RelativePath $RelativePath
  $results = New-Object System.Collections.Generic.List[object]
  $relativeUnix = $RelativePath.Replace("\", "/")

  foreach ($propertyName in @("dependencies", "devDependencies")) {
    $property = $package.PSObject.Properties[$propertyName]
    if ($null -eq $property) {
      continue
    }

    foreach ($entry in $property.Value.PSObject.Properties) {
      $results.Add([pscustomobject]@{
          Id = [string]$entry.Name
          Version = [string]$entry.Value
          DependencyType = $propertyName
          DeclaredIn = $relativeUnix
        })
    }
  }

  return $results
}

function Get-AllPackageExternalDirectDependencies {
  param([string[]]$RelativePaths)

  $results = New-Object System.Collections.Generic.List[object]
  foreach ($relativePath in $RelativePaths) {
    foreach ($dependency in Get-PackageDirectDependencies -RelativePath $relativePath) {
      if ($dependency.Version -eq "workspace:*") {
        continue
      }
      $results.Add($dependency)
    }
  }
  return $results
}

function Get-PackageNames {
  param([string[]]$RelativePaths)

  $results = New-Object System.Collections.Generic.List[string]
  foreach ($relativePath in $RelativePaths) {
    $package = Read-JsonFile -RelativePath $relativePath
    $nameProperty = $package.PSObject.Properties["name"]
    if ($null -ne $nameProperty -and -not [string]::IsNullOrWhiteSpace([string]$nameProperty.Value)) {
      $results.Add(([string]$nameProperty.Value).Trim())
    }
  }
  return $results
}

function Get-WorkspaceLinks {
  param([string[]]$RelativePaths)

  $results = New-Object System.Collections.Generic.List[object]
  foreach ($relativePath in $RelativePaths) {
    $package = Read-JsonFile -RelativePath $relativePath
    $nameProperty = $package.PSObject.Properties["name"]
    $name = ""
    if ($null -ne $nameProperty -and -not [string]::IsNullOrWhiteSpace([string]$nameProperty.Value)) {
      $name = ([string]$nameProperty.Value).Trim()
    }
    if ([string]::IsNullOrWhiteSpace($name)) {
      continue
    }

    foreach ($propertyName in @("dependencies", "devDependencies")) {
      $property = $package.PSObject.Properties[$propertyName]
      if ($null -eq $property) {
        continue
      }

      foreach ($entry in $property.Value.PSObject.Properties) {
        if ([string]$entry.Value -eq "workspace:*") {
          $results.Add([pscustomobject]@{
              From = $name.Trim()
              To = ([string]$entry.Name).Trim()
            })
        }
      }
    }
  }
  return $results
}

function Get-DockerImages {
  $composeContent = Read-Text -RelativePath "docker-compose.yml"
  $matches = [Regex]::Matches($composeContent, '(?m)^\s*image:\s*([^\s#]+)\s*$')
  $results = New-Object System.Collections.Generic.List[string]
  foreach ($match in $matches) {
    $results.Add($match.Groups[1].Value.Trim())
  }
  return $results
}

function Convert-ToRepoRelativePath {
  param([string]$FullPath)

  $relativePath = $FullPath.Substring($repoRoot.Length).TrimStart('\')
  return $relativePath
}

function Test-IsControllerFile {
  param([string]$Content)

  return $Content.Contains("@RestController") -or $Content.Contains("@Controller")
}

function Get-ControllerFileRelativePaths {
  param([string]$RelativeRoot)

  $rootPath = Join-Path $repoRoot $RelativeRoot
  if (-not (Test-Path -LiteralPath $rootPath)) {
    throw ("Controller root not found: {0}" -f $RelativeRoot)
  }

  $results = New-Object System.Collections.Generic.List[string]
  foreach ($file in @(Get-ChildItem -LiteralPath $rootPath -Recurse -File -Filter *.java)) {
    $content = Get-Content -Encoding UTF8 -Raw -LiteralPath $file.FullName
    if (Test-IsControllerFile -Content $content) {
      $results.Add((Convert-ToRepoRelativePath -FullPath $file.FullName))
    }
  }

  return $results
}

function Get-ClassLevelRequestPrefix {
  param([string]$Content)

  $classPattern = '@RequestMapping\s*\(\s*(?:value\s*=\s*|path\s*=\s*)?"([^"]+)"\s*\)\s*(?:public\s+)?(?:final\s+)?(?:abstract\s+)?(?:class|record)\s+'
  $match = [Regex]::Match($Content, $classPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  if (-not $match.Success) {
    return ""
  }

  return $match.Groups[1].Value.Trim()
}

function Join-RoutePath {
  param(
    [string]$Prefix,
    [string]$Path
  )

  if ([string]::IsNullOrWhiteSpace($Prefix)) {
    return $Path.Trim()
  }

  if ([string]::IsNullOrWhiteSpace($Path)) {
    return $Prefix.Trim()
  }

  $left = $Prefix.Trim().TrimEnd('/')
  $right = $Path.Trim().TrimStart('/')
  return ("{0}/{1}" -f $left, $right)
}

function Get-HttpRoutesFromControllerContent {
  param([string]$Content)

  $routes = New-Object System.Collections.Generic.List[string]
  $classPrefix = Get-ClassLevelRequestPrefix -Content $Content
  $methodPattern = '@(PostMapping|GetMapping|PutMapping|DeleteMapping|PatchMapping)\s*\(\s*(?:value\s*=\s*|path\s*=\s*)?"([^"]+)"\s*\)'
  $matches = [Regex]::Matches($Content, $methodPattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
  foreach ($match in $matches) {
    $method = $match.Groups[1].Value.Replace("Mapping", "").ToUpperInvariant()
    $route = Join-RoutePath -Prefix $classPrefix -Path $match.Groups[2].Value
    $routes.Add(("{0} {1}" -f $method, $route))
  }

  return $routes
}

function Get-HttpRouteBaseline {
  param([string]$ControllerRoot)

  $results = New-Object System.Collections.Generic.List[string]

  foreach ($relativePath in Get-ControllerFileRelativePaths -RelativeRoot $ControllerRoot) {
    $content = Read-Text -RelativePath $relativePath
    foreach ($route in Get-HttpRoutesFromControllerContent -Content $content) {
      $results.Add($route)
    }
  }

  return $results
}

function Get-BaselineRoutes {
  param([string]$RelativePath)

  $baselineContent = Read-Text -RelativePath $RelativePath
  $baselineRoutes = New-Object System.Collections.Generic.List[string]
  foreach ($line in ($baselineContent -split "`r?`n")) {
    $trimmed = $line.Trim()
    if ([string]::IsNullOrWhiteSpace($trimmed)) {
      continue
    }
    if ($trimmed.StartsWith("#")) {
      continue
    }
    $baselineRoutes.Add($trimmed)
  }

  return $baselineRoutes
}

function Assert-SetEquals {
  param(
    [string]$Name,
    [string[]]$Expected,
    [string[]]$Actual
  )

  $expectedSorted = @($Expected | Sort-Object -Unique)
  $actualSorted = @($Actual | Sort-Object -Unique)
  $missing = @($expectedSorted | Where-Object { $_ -notin $actualSorted })
  $extra = @($actualSorted | Where-Object { $_ -notin $expectedSorted })

  if ($missing.Count -gt 0 -or $extra.Count -gt 0) {
    $parts = New-Object System.Collections.Generic.List[string]
    if ($missing.Count -gt 0) {
      $parts.Add(("missing: {0}" -f (Format-DiffItems -Items $missing)))
    }
    if ($extra.Count -gt 0) {
      $parts.Add(("extra: {0}" -f (Format-DiffItems -Items $extra)))
    }
    throw ("{0} mismatch -> {1}. Remediation: {2}" -f $Name, ($parts -join " | "), (Get-RemediationHint -Name $Name))
  }
}

function Format-DiffItems {
  param([string[]]$Items)

  if ($Items.Count -le 8) {
    return ($Items -join "; ")
  }

  $preview = @($Items | Select-Object -First 8)
  return ("{0}; ... (+{1} more)" -f ($preview -join "; "), ($Items.Count - $preview.Count))
}

function Get-RemediationHint {
  param([string]$Name)

  switch ($Name) {
    "OpenAPI HTTP baseline" {
      return "If route changes are intentional, run `powershell -ExecutionPolicy Bypass -File .\\scripts\\export-release-baselines.ps1`, review `docs/compliance/openapi-http-baseline.txt`, rerun `verify-release.ps1 -Light`, and record any remaining field-level contract risk in `docs/compliance/release-gap-register.md`."
    }
    "OpenAPI HTTP self-check" {
      return "Review the fixture controllers under `lowcode-app/src/test/resources/http-route-selfcheck/controllers`, refresh `docs/compliance/openapi-http-selfcheck-baseline.txt` only if the extraction fixture intentionally changed, and rerun `verify-release.ps1 -SelfCheck`."
    }
    "Maven license inventory" {
      return "Review Maven direct dependencies and dependencyManagement drift, then refresh `docs/compliance/license-inventory.json` with `export-release-baselines.ps1`. If a new dependency still lacks formal legal review, block release and capture the gap in `docs/compliance/release-gap-register.md`."
    }
    "pnpm license inventory" {
      return "Review frontend workspace direct dependency drift, refresh `docs/compliance/license-inventory.json`, and block release until every new external package has an explicit reviewed license entry."
    }
    "Docker license inventory" {
      return "Review `docker-compose.yml` image drift, refresh `docs/compliance/license-inventory.json`, and confirm the image source / license result in `docs/review/release-checklist.md`."
    }
    "SBOM javaModules" {
      return "Review root `pom.xml` module drift, regenerate `docs/compliance/sbom-minimal.json`, and note any release-composition limitation in `docs/compliance/release-gap-register.md`."
    }
    "SBOM webWorkspacePackages" {
      return "Review workspace package drift under `lowcode-web/packages`, regenerate `docs/compliance/sbom-minimal.json`, and rerun the light gate."
    }
    "SBOM workspaceLinks" {
      return "Review `workspace:*` link drift in `lowcode-web/package.json` and workspace packages, regenerate `docs/compliance/sbom-minimal.json`, and rerun the light gate."
    }
    "SBOM Maven external direct deps" {
      return "Review Maven direct dependency drift, regenerate `docs/compliance/sbom-minimal.json`, and ensure release notes describe any new external dependency."
    }
    "SBOM pnpm external direct deps" {
      return "Review frontend direct dependency drift, regenerate `docs/compliance/sbom-minimal.json`, and ensure release notes describe any new external dependency."
    }
    "SBOM dockerImages" {
      return "Review Docker image drift, regenerate `docs/compliance/sbom-minimal.json`, and confirm release packaging impact in `docs/review/release-checklist.md`."
    }
    default {
      return "Review the committed baseline, rerun `powershell -ExecutionPolicy Bypass -File .\\scripts\\export-release-baselines.ps1 -MatchCommitted`, and capture any unresolved process/tooling limitation in `docs/compliance/release-gap-register.md`."
    }
  }
}

function Assert-NoReviewPlaceholders {
  param(
    [string]$Name,
    [object[]]$Items,
    [scriptblock]$IdSelector,
    [scriptblock]$ValueSelector
  )

  $violations = New-Object System.Collections.Generic.List[string]
  foreach ($item in @($Items)) {
    if ($null -eq $item) {
      continue
    }

    $id = [string](& $IdSelector $item)
    $value = [string](& $ValueSelector $item)
    if ([string]::IsNullOrWhiteSpace($value)) {
      $violations.Add(("{0}=<empty>" -f $id))
      continue
    }

    $normalized = $value.Trim().ToUpperInvariant()
    if ($normalized -in @("UNREVIEWED", ("TO" + "DO"), ("TB" + "D"))) {
      $violations.Add(("{0}={1}" -f $id, $value.Trim()))
    }
  }

  if ($violations.Count -gt 0) {
    throw ("{0} contains unresolved review placeholders: {1}. Remediation: replace placeholders with reviewed results before release, then update `docs/review/release-checklist.md` and `docs/compliance/release-gap-register.md` if formal tooling is still missing." -f $Name, (Format-DiffItems -Items @($violations)))
  }
}

function Assert-LicenseInventory {
  $inventory = Read-JsonFile -RelativePath "docs\compliance\license-inventory.json"

  Assert-NoReviewPlaceholders -Name "Maven license inventory" -Items @($inventory.maven) -IdSelector { param($item) $item.id } -ValueSelector { param($item) $item.license }
  Assert-NoReviewPlaceholders -Name "pnpm license inventory" -Items @($inventory.pnpm) -IdSelector { param($item) $item.id } -ValueSelector { param($item) $item.license }
  Assert-NoReviewPlaceholders -Name "Docker license inventory" -Items @($inventory.docker) -IdSelector { param($item) $item.image } -ValueSelector { param($item) $item.license }

  $mavenExpected = @{}
  foreach ($item in @($inventory.maven)) {
    if ($null -eq $item) {
      continue
    }
    if ([string]::IsNullOrWhiteSpace([string]$item.license)) {
      throw ("license-inventory.json has empty Maven license: {0}" -f $item.id)
    }
    $key = Normalize-DependencyKey -Id ([string]$item.id) -Scopes (Normalize-StringArray -Value $item.scopes) -Versions (Normalize-StringArray -Value $item.versions)
    $mavenExpected[$key] = $true
  }

  $mavenActual = @{}
  foreach ($relativePath in $javaPomFiles) {
    foreach ($dependency in Get-PomDirectDependencies -RelativePath $relativePath) {
      if ($dependency.Id -like "com.lowcode:*") {
        continue
      }
      $key = Normalize-DependencyKey -Id $dependency.Id -Scopes @($dependency.Scope) -Versions @($dependency.Version)
      $mavenActual[$key] = $true
    }
  }

  Assert-SetEquals -Name "Maven license inventory" -Expected $mavenExpected.Keys -Actual $mavenActual.Keys

  $pnpmExpected = @{}
  foreach ($item in @($inventory.pnpm)) {
    if ($null -eq $item) {
      continue
    }
    if ([string]::IsNullOrWhiteSpace([string]$item.license)) {
      throw ("license-inventory.json has empty pnpm license: {0}" -f $item.id)
    }
    $pnpmExpected[("{0}|{1}|{2}" -f ([string]$item.id).Trim(), ([string]$item.dependencyType).Trim(), ([string]$item.version).Trim())] = $true
  }

  $pnpmActual = @{}
  foreach ($dependency in Get-AllPackageExternalDirectDependencies -RelativePaths $packageJsonFiles) {
    $pnpmActual[("{0}|{1}|{2}" -f $dependency.Id, $dependency.DependencyType, $dependency.Version)] = $true
  }

  Assert-SetEquals -Name "pnpm license inventory" -Expected $pnpmExpected.Keys -Actual $pnpmActual.Keys

  $dockerExpected = @{}
  foreach ($item in @($inventory.docker)) {
    if ($null -eq $item) {
      continue
    }
    if ([string]::IsNullOrWhiteSpace([string]$item.license)) {
      throw ("license-inventory.json has empty Docker license: {0}" -f $item.image)
    }
    $dockerExpected[([string]$item.image).Trim()] = $true
  }

  $dockerActual = @{}
  foreach ($image in Get-DockerImages) {
    $dockerActual[$image] = $true
  }

  Assert-SetEquals -Name "Docker license inventory" -Expected $dockerExpected.Keys -Actual $dockerActual.Keys
}

function Assert-SbomInventory {
  $sbom = Read-JsonFile -RelativePath "docs\compliance\sbom-minimal.json"

  $javaModules = New-Object System.Collections.Generic.List[string]
  [xml]$rootPom = Read-Text -RelativePath "pom.xml"
  foreach ($module in @(Get-XmlChildNodes -Node $rootPom.project -Path "modules/module")) {
    if ($null -ne $module) {
      $javaModules.Add(([string]$module.InnerText).Trim())
    }
  }
  Assert-SetEquals -Name "SBOM javaModules" -Expected (Normalize-StringArray -Value $sbom.javaModules) -Actual $javaModules

  $workspacePackages = Get-PackageNames -RelativePaths $packageJsonFiles
  Assert-SetEquals -Name "SBOM webWorkspacePackages" -Expected (Normalize-StringArray -Value $sbom.webWorkspacePackages) -Actual $workspacePackages

  $expectedLinks = @()
  foreach ($link in @($sbom.workspaceLinks)) {
    if ($null -ne $link) {
      $expectedLinks += ("{0}->{1}" -f ([string]$link.from).Trim(), ([string]$link.to).Trim())
    }
  }

  $actualLinks = @()
  foreach ($link in Get-WorkspaceLinks -RelativePaths $packageJsonFiles) {
    $actualLinks += ("{0}->{1}" -f $link.From, $link.To)
  }
  Assert-SetEquals -Name "SBOM workspaceLinks" -Expected $expectedLinks -Actual $actualLinks

  $expectedMaven = @()
  foreach ($item in @($sbom.mavenExternalDirectDependencies)) {
    if ($null -ne $item) {
      $expectedMaven += Normalize-DependencyKey -Id ([string]$item.id) -Scopes (Normalize-StringArray -Value $item.scopes) -Versions (Normalize-StringArray -Value $item.versions)
    }
  }

  $actualMaven = @()
  foreach ($relativePath in $javaPomFiles) {
    foreach ($dependency in Get-PomDirectDependencies -RelativePath $relativePath) {
      if ($dependency.Id -like "com.lowcode:*") {
        continue
      }
      $actualMaven += Normalize-DependencyKey -Id $dependency.Id -Scopes @($dependency.Scope) -Versions @($dependency.Version)
    }
  }
  Assert-SetEquals -Name "SBOM Maven external direct deps" -Expected $expectedMaven -Actual $actualMaven

  $expectedPnpm = @()
  foreach ($item in @($sbom.pnpmExternalDirectDependencies)) {
    if ($null -ne $item) {
      $expectedPnpm += ("{0}|{1}|{2}" -f ([string]$item.id).Trim(), ([string]$item.dependencyType).Trim(), ([string]$item.version).Trim())
    }
  }

  $actualPnpm = @()
  foreach ($dependency in Get-AllPackageExternalDirectDependencies -RelativePaths $packageJsonFiles) {
    $actualPnpm += ("{0}|{1}|{2}" -f $dependency.Id, $dependency.DependencyType, $dependency.Version)
  }
  Assert-SetEquals -Name "SBOM pnpm external direct deps" -Expected $expectedPnpm -Actual $actualPnpm

  Assert-SetEquals -Name "SBOM dockerImages" -Expected (Normalize-StringArray -Value $sbom.dockerImages) -Actual (Get-DockerImages)
}

foreach ($file in $requiredFiles) {
  Assert-Exists -RelativePath $file
}

Assert-Contains -RelativePath "docs\review\manual-checklist.md" -Tokens @("H4", "A2", "F12")
Assert-Contains -RelativePath "docs\review\release-checklist.md" -Tokens @("verify-release.ps1 -SelfCheck", "verify-release.ps1 -Light", "Rollback", "Observability", "Dependency / License / SBOM")
Assert-Contains -RelativePath "docs\review\release-checklist.md" -Tokens @("release-gap-register.md", "formal-toolchain-migration.md")
Assert-Contains -RelativePath "docs\compliance\dependency-admission.md" -Tokens @("License", "Maven / npm / Docker / binary", "Node 20")
Assert-Contains -RelativePath "docs\compliance\license-sbom.md" -Tokens @("OpenAPI", "License", "SBOM", "openapi-http-baseline.txt", "license-inventory.json", "sbom-minimal.json")
Assert-Contains -RelativePath "docs\compliance\license-sbom.md" -Tokens @("verify-placeholder-gates.ps1 -SelfCheck", "openapi-http-selfcheck-baseline.txt")
Assert-Contains -RelativePath "docs\compliance\license-sbom.md" -Tokens @("export-release-baselines.ps1", "-MatchCommitted")
Assert-Contains -RelativePath "docs\compliance\license-sbom.md" -Tokens @("release-gap-register.md", "formal-toolchain-migration.md", "Light gate coverage", "UNREVIEWED")
Assert-Contains -RelativePath "docs\compliance\README.md" -Tokens @("openapi-http-selfcheck.md", "verify-placeholder-gates.ps1")
Assert-Contains -RelativePath "docs\compliance\README.md" -Tokens @("export-release-baselines.ps1", "license-inventory.json", "formal-toolchain-migration.md", "release-gap-register.md")
Assert-Contains -RelativePath "docs\compliance\README.md" -Tokens @("importPreview", "importCommit", "/api/packages/install", "field-level / enum-level", "CycloneDX / SPDX", "CSRF")
Assert-Contains -RelativePath "docs\compliance\formal-toolchain-migration.md" -Tokens @("OpenAPI", "License", "SBOM", "shadow", "CycloneDX", "SPDX")
Assert-Contains -RelativePath "docs\compliance\release-gap-register.md" -Tokens @("OPENAPI-FIELD-DIFF", "LICENSE-TRANSITIVE", "SBOM-STANDARD", "Current control", "Exit criteria")
Assert-Contains -RelativePath "docs\compliance\saas-private-boundary.md" -Tokens @("SaaS", "Redis", "License")
Assert-Contains -RelativePath "docs\runbooks\README.md" -Tokens @("release-observability.md", "dependency-license-compliance.md")
Assert-Contains -RelativePath "docs\runbooks\release.md" -Tokens @("verify-release.ps1", "README.md", "docs/compliance")
Assert-Contains -RelativePath "docs\runbooks\rollback.md" -Tokens @("DDL", "README", "verify-release.ps1")
Assert-Contains -RelativePath "docs\runbooks\release-observability.md" -Tokens @("verify-release.ps1 -Light", "traceId", "Rollback", "lowcode_")
Assert-Contains -RelativePath "docs\runbooks\dependency-license-compliance.md" -Tokens @("verify-release.ps1 -Light", "docs/compliance/license-sbom.md", "Rollback", "SBOM")
Assert-Contains -RelativePath "docs\runbooks\dependency-license-compliance.md" -Tokens @("export-release-baselines.ps1", "-MatchCommitted", "release-gap-register.md", "formal-toolchain-migration.md")
Assert-Contains -RelativePath ".github\pull_request_template.md" -Tokens @("Compatibility", "Security", "Verification", "Rollback", "Covered trap IDs", "release-gap-register.md")
Assert-Contains -RelativePath ".github\workflows\release-gate.yml" -Tokens @("verify-release.ps1")
Assert-Contains -RelativePath "README.md" -Tokens @("M0", "M5", "verify-release.ps1", "OpenAPI", "License", "SBOM")
Assert-Contains -RelativePath "README.md" -Tokens @("/api/packages/precheck|install|list|audit|upgrade|rollback|uninstall-dry-run", "export", "importPreview", "importCommit")
Assert-Contains -RelativePath "lowcode-app\README.md" -Tokens @("/api/packages/precheck|install", "/api/packages/{packageCode}/disable|enable|upgrade|rollback|uninstall-dry-run|uninstall", "importPreview", "importCommit", "/api/packages/*", "UI")

$baselineRoutes = Get-BaselineRoutes -RelativePath "docs\compliance\openapi-http-baseline.txt"
Assert-SetEquals -Name "OpenAPI HTTP baseline" -Expected $baselineRoutes -Actual (Get-HttpRouteBaseline -ControllerRoot "lowcode-app\src\main\java")

if ($SelfCheck) {
  $selfCheckRoutes = Get-BaselineRoutes -RelativePath "docs\compliance\openapi-http-selfcheck-baseline.txt"
  Assert-SetEquals -Name "OpenAPI HTTP self-check" -Expected $selfCheckRoutes -Actual (Get-HttpRouteBaseline -ControllerRoot "lowcode-app\src\test\resources\http-route-selfcheck\controllers")
  Write-Host "OpenAPI HTTP self-check passed."
}

Assert-LicenseInventory
Assert-SbomInventory

$exportScript = Join-Path $repoRoot "scripts\export-release-baselines.ps1"
& $exportScript -MatchCommitted

Write-Host "OpenAPI/License/SBOM real gates passed."
