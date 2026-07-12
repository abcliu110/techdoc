param(
  [string]$OutputDir = "",
  [switch]$MatchCommitted
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

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

function Read-Text {
  param([string]$RelativePath)

  $fullPath = Join-Path $repoRoot $RelativePath
  return Get-Content -Encoding UTF8 -Raw -LiteralPath $fullPath
}

function Read-JsonFile {
  param([string]$RelativePath)

  return Read-Text -RelativePath $RelativePath | ConvertFrom-Json
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

function Convert-DependencyObjectToKey {
  param([object]$Dependency)

  return Normalize-DependencyKey -Id ([string]$Dependency.id) -Scopes (Normalize-StringArray -Value $Dependency.scopes) -Versions (Normalize-StringArray -Value $Dependency.versions)
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
    if ($null -ne $propertyNode) {
      $map[$propertyNode.LocalName] = ([string]$propertyNode.InnerText).Trim()
    }
  }

  return $map
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

  foreach ($dependency in @(Get-XmlChildNodes -Node $projectNode -Path "dependencies/dependency")) {
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
      })
  }

  $dependencyManagementNode = Get-XmlChildNode -Node $projectNode -LocalName "dependencyManagement"
  if ($null -ne $dependencyManagementNode) {
    foreach ($dependency in @(Get-XmlChildNodes -Node $dependencyManagementNode -Path "dependencies/dependency")) {
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
              from = $name.Trim()
              to = ([string]$entry.Name).Trim()
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

  return $FullPath.Substring($repoRoot.Length).TrimStart('\')
}

function Test-IsControllerFile {
  param([string]$Content)

  return $Content.Contains("@RestController") -or $Content.Contains("@Controller")
}

function Get-ControllerFileRelativePaths {
  param([string]$RelativeRoot)

  $rootPath = Join-Path $repoRoot $RelativeRoot
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
  return @($results | Sort-Object -Unique)
}

function Get-ExistingLicenseMaps {
  $inventory = Read-JsonFile -RelativePath "docs\compliance\license-inventory.json"

  $maps = [ordered]@{
    MavenExact = @{}
    MavenById = @{}
    PnpmExact = @{}
    PnpmById = @{}
    DockerByImage = @{}
  }

  foreach ($item in @($inventory.maven)) {
    if ($null -eq $item) {
      continue
    }
    $key = Normalize-DependencyKey -Id ([string]$item.id) -Scopes (Normalize-StringArray -Value $item.scopes) -Versions (Normalize-StringArray -Value $item.versions)
    $maps.MavenExact[$key] = [string]$item.license
    if (-not $maps.MavenById.ContainsKey([string]$item.id)) {
      $maps.MavenById[[string]$item.id] = [string]$item.license
    }
  }

  foreach ($item in @($inventory.pnpm)) {
    if ($null -eq $item) {
      continue
    }
    $key = ("{0}|{1}|{2}" -f ([string]$item.id).Trim(), ([string]$item.dependencyType).Trim(), ([string]$item.version).Trim())
    $maps.PnpmExact[$key] = [string]$item.license
    if (-not $maps.PnpmById.ContainsKey([string]$item.id)) {
      $maps.PnpmById[[string]$item.id] = [string]$item.license
    }
  }

  foreach ($item in @($inventory.docker)) {
    if ($null -ne $item) {
      $maps.DockerByImage[[string]$item.image] = [string]$item.license
    }
  }

  return $maps
}

function Resolve-LicenseValue {
  param(
    [hashtable]$ExactMap,
    [hashtable]$FallbackMap,
    [string]$ExactKey,
    [string]$FallbackKey
  )

  if ($ExactMap.ContainsKey($ExactKey)) {
    return [string]$ExactMap[$ExactKey]
  }
  if ($FallbackMap.ContainsKey($FallbackKey)) {
    return [string]$FallbackMap[$FallbackKey]
  }
  return "UNREVIEWED"
}

function New-LicenseInventoryObject {
  $licenseMaps = Get-ExistingLicenseMaps

  $mavenItems = New-Object System.Collections.Generic.List[object]
  $seenMavenKeys = @{}
  foreach ($relativePath in $javaPomFiles) {
    foreach ($dependency in Get-PomDirectDependencies -RelativePath $relativePath) {
      if ($dependency.Id -like "com.lowcode:*") {
        continue
      }

      $key = Normalize-DependencyKey -Id $dependency.Id -Scopes @($dependency.Scope) -Versions @($dependency.Version)
      if ($seenMavenKeys.ContainsKey($key)) {
        continue
      }
      $seenMavenKeys[$key] = $true
      $mavenItems.Add([pscustomobject]@{
          id = $dependency.Id
          license = Resolve-LicenseValue -ExactMap $licenseMaps.MavenExact -FallbackMap $licenseMaps.MavenById -ExactKey $key -FallbackKey $dependency.Id
          versions = @($dependency.Version)
          scopes = @($dependency.Scope)
        })
    }
  }

  $mavenSorted = @(
    $mavenItems |
      Sort-Object id, @{Expression = { ($_.scopes -join ",") }}, @{Expression = { ($_.versions -join ",") }}
  )

  $pnpmItems = New-Object System.Collections.Generic.List[object]
  foreach ($dependency in Get-AllPackageExternalDirectDependencies -RelativePaths $packageJsonFiles) {
    $key = ("{0}|{1}|{2}" -f $dependency.Id, $dependency.DependencyType, $dependency.Version)
    $pnpmItems.Add([pscustomobject]@{
        id = $dependency.Id
        license = Resolve-LicenseValue -ExactMap $licenseMaps.PnpmExact -FallbackMap $licenseMaps.PnpmById -ExactKey $key -FallbackKey $dependency.Id
        version = $dependency.Version
        declaredIn = $dependency.DeclaredIn
        dependencyType = $dependency.DependencyType
      })
  }

  $pnpmSorted = @(
    $pnpmItems |
      Sort-Object id, dependencyType, version
  )

  $dockerItems = New-Object System.Collections.Generic.List[object]
  foreach ($image in (Get-DockerImages | Sort-Object -Unique)) {
    $serviceName = ""
    if ($image -like "mysql:*") {
      $serviceName = "mysql"
    } elseif ($image -like "redis:*") {
      $serviceName = "redis"
    } else {
      $serviceName = "image"
    }

    $dockerItems.Add([pscustomobject]@{
        image = $image
        license = (Resolve-LicenseValue -ExactMap $licenseMaps.DockerByImage -FallbackMap $licenseMaps.DockerByImage -ExactKey $image -FallbackKey $image)
        declaredIn = ("docker-compose.yml:{0}" -f $serviceName)
      })
  }

  $inventoryObject = @{}
  $inventoryObject["schemaVersion"] = 1
  $inventoryObject["reviewMode"] = "manual-committed-baseline"
  $inventoryObject["updatedBy"] = "release-gate"
  $inventoryObject["maven"] = $mavenSorted
  $inventoryObject["pnpm"] = $pnpmSorted
  $inventoryObject["docker"] = @($dockerItems.ToArray())
  return $inventoryObject
}

function New-SbomObject {
  [xml]$rootPom = Read-Text -RelativePath "pom.xml"
  $javaModules = New-Object System.Collections.Generic.List[string]
  foreach ($module in @(Get-XmlChildNodes -Node $rootPom.project -Path "modules/module")) {
    if ($null -ne $module) {
      $javaModules.Add(([string]$module.InnerText).Trim())
    }
  }

  $workspacePackages = @(
    Get-PackageNames -RelativePaths $packageJsonFiles |
      Sort-Object -Unique
  )

  $workspaceLinks = @(
    Get-WorkspaceLinks -RelativePaths $packageJsonFiles |
      Sort-Object from, to
  )

  $mavenDependencies = New-Object System.Collections.Generic.List[object]
  $seenMavenKeys = @{}
  foreach ($relativePath in $javaPomFiles) {
    foreach ($dependency in Get-PomDirectDependencies -RelativePath $relativePath) {
      if ($dependency.Id -like "com.lowcode:*") {
        continue
      }
      $key = Normalize-DependencyKey -Id $dependency.Id -Scopes @($dependency.Scope) -Versions @($dependency.Version)
      if ($seenMavenKeys.ContainsKey($key)) {
        continue
      }
      $seenMavenKeys[$key] = $true
      $mavenDependencies.Add([pscustomobject]@{
          id = $dependency.Id
          versions = @($dependency.Version)
          scopes = @($dependency.Scope)
        })
    }
  }

  $pnpmDependencies = New-Object System.Collections.Generic.List[object]
  foreach ($dependency in Get-AllPackageExternalDirectDependencies -RelativePaths $packageJsonFiles) {
    $pnpmDependencies.Add([pscustomobject]@{
        id = $dependency.Id
        version = $dependency.Version
        dependencyType = $dependency.DependencyType
      })
  }

  $sbomObject = @{}
  $sbomObject["schemaVersion"] = 1
  $sbomObject["bomFormat"] = "lowcode-minimal-release-sbom"
  $sbomObject["serialNumber"] = "urn:lowcode-platform:release-sbom:minimal:1"
  $sbomObject["javaModules"] = @($javaModules)
  $sbomObject["webWorkspacePackages"] = $workspacePackages
  $sbomObject["workspaceLinks"] = $workspaceLinks
  $sbomObject["mavenExternalDirectDependencies"] = @(
    $mavenDependencies |
      Sort-Object id, @{Expression = { ($_.scopes -join ",") }}, @{Expression = { ($_.versions -join ",") }}
  )
  $sbomObject["pnpmExternalDirectDependencies"] = @(
    $pnpmDependencies |
      Sort-Object id, dependencyType, version
  )
  $sbomObject["dockerImages"] = @(
    Get-DockerImages |
      Sort-Object -Unique
  )
  return $sbomObject
}

function Convert-ObjectToPrettyJson {
  param([object]$Value)

  return (($Value | ConvertTo-Json -Depth 8) -replace "`n", "`r`n")
}

function New-OpenApiBaselineText {
  $lines = New-Object System.Collections.Generic.List[string]
  $lines.Add("# OpenAPI transition baseline")
  $lines.Add("# Generated from lowcode-app controller routes.")
  $lines.Add("# Update with scripts/export-release-baselines.ps1 when routes change.")
  foreach ($route in Get-HttpRouteBaseline -ControllerRoot "lowcode-app\src\main\java") {
    $lines.Add($route)
  }
  return (($lines -join "`r`n") + "`r`n")
}

function Write-Utf8NoBom {
  param(
    [string]$Path,
    [string]$Content
  )

  $directory = Split-Path -Parent $Path
  if (-not [string]::IsNullOrWhiteSpace($directory) -and -not (Test-Path -LiteralPath $directory)) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
  }

  $encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Get-GeneratedArtifacts {
  $artifacts = New-Object System.Collections.Generic.List[object]
  $artifacts.Add([pscustomobject]@{
      RelativePath = "docs\compliance\openapi-http-baseline.txt"
      Content = New-OpenApiBaselineText
    })
  $artifacts.Add([pscustomobject]@{
      RelativePath = "docs\compliance\license-inventory.json"
      Content = Convert-ObjectToPrettyJson -Value (New-LicenseInventoryObject)
    })
  $artifacts.Add([pscustomobject]@{
      RelativePath = "docs\compliance\sbom-minimal.json"
      Content = Convert-ObjectToPrettyJson -Value (New-SbomObject)
    })
  return $artifacts
}

function Assert-CommittedMatches {
  $mismatches = New-Object System.Collections.Generic.List[string]

  $committedRouteText = Read-Text -RelativePath "docs\compliance\openapi-http-baseline.txt"
  $committedRoutes = @(
    $committedRouteText -split "`r?`n" |
      ForEach-Object { $_.Trim() } |
      Where-Object { $_ -and -not $_.StartsWith("#") } |
      Sort-Object -Unique
  )
  $generatedRoutes = Get-HttpRouteBaseline -ControllerRoot "lowcode-app\src\main\java"
  if (($committedRoutes -join "`n") -ne ($generatedRoutes -join "`n")) {
    $mismatches.Add("docs\compliance\openapi-http-baseline.txt")
  }

  $committedInventory = Read-JsonFile -RelativePath "docs\compliance\license-inventory.json"
  $generatedInventory = New-LicenseInventoryObject
  $committedMaven = @($committedInventory.maven | ForEach-Object { "{0}|{1}|{2}|{3}" -f $_.id, ($_.scopes -join ","), ($_.versions -join ","), $_.license } | Sort-Object)
  $generatedMaven = @($generatedInventory.maven | ForEach-Object { "{0}|{1}|{2}|{3}" -f $_.id, ($_.scopes -join ","), ($_.versions -join ","), $_.license } | Sort-Object)
  $committedPnpm = @($committedInventory.pnpm | ForEach-Object { "{0}|{1}|{2}|{3}" -f $_.id, $_.dependencyType, $_.version, $_.license } | Sort-Object)
  $generatedPnpm = @($generatedInventory.pnpm | ForEach-Object { "{0}|{1}|{2}|{3}" -f $_.id, $_.dependencyType, $_.version, $_.license } | Sort-Object)
  $committedDocker = @($committedInventory.docker | ForEach-Object { "{0}|{1}" -f $_.image, $_.license } | Sort-Object)
  $generatedDocker = @($generatedInventory.docker | ForEach-Object { "{0}|{1}" -f $_.image, $_.license } | Sort-Object)
  if (($committedMaven -join "`n") -ne ($generatedMaven -join "`n") -or ($committedPnpm -join "`n") -ne ($generatedPnpm -join "`n") -or ($committedDocker -join "`n") -ne ($generatedDocker -join "`n")) {
    $mismatches.Add("docs\compliance\license-inventory.json")
  }

  $committedSbom = Read-JsonFile -RelativePath "docs\compliance\sbom-minimal.json"
  $generatedSbom = New-SbomObject
  $committedSbomParts = @(
    "javaModules:" + (($committedSbom.javaModules | Sort-Object) -join ","),
    "webWorkspacePackages:" + (($committedSbom.webWorkspacePackages | Sort-Object) -join ","),
    "workspaceLinks:" + ((@($committedSbom.workspaceLinks | ForEach-Object { "{0}->{1}" -f $_.from, $_.to } | Sort-Object)) -join ","),
    "maven:" + ((@($committedSbom.mavenExternalDirectDependencies | ForEach-Object { "{0}|{1}|{2}" -f $_.id, ($_.scopes -join ","), ($_.versions -join ",") } | Sort-Object)) -join ","),
    "pnpm:" + ((@($committedSbom.pnpmExternalDirectDependencies | ForEach-Object { "{0}|{1}|{2}" -f $_.id, $_.dependencyType, $_.version } | Sort-Object)) -join ","),
    "docker:" + ((@($committedSbom.dockerImages | Sort-Object)) -join ",")
  )
  $generatedSbomParts = @(
    "javaModules:" + (($generatedSbom.javaModules | Sort-Object) -join ","),
    "webWorkspacePackages:" + (($generatedSbom.webWorkspacePackages | Sort-Object) -join ","),
    "workspaceLinks:" + ((@($generatedSbom.workspaceLinks | ForEach-Object { "{0}->{1}" -f $_.from, $_.to } | Sort-Object)) -join ","),
    "maven:" + ((@($generatedSbom.mavenExternalDirectDependencies | ForEach-Object { "{0}|{1}|{2}" -f $_.id, ($_.scopes -join ","), ($_.versions -join ",") } | Sort-Object)) -join ","),
    "pnpm:" + ((@($generatedSbom.pnpmExternalDirectDependencies | ForEach-Object { "{0}|{1}|{2}" -f $_.id, $_.dependencyType, $_.version } | Sort-Object)) -join ","),
    "docker:" + ((@($generatedSbom.dockerImages | Sort-Object)) -join ",")
  )
  if (($committedSbomParts -join "`n") -ne ($generatedSbomParts -join "`n")) {
    $mismatches.Add("docs\compliance\sbom-minimal.json")
  }

  if ($mismatches.Count -gt 0) {
    throw ("Generated release baselines differ from committed files: {0}" -f ($mismatches -join ", "))
  }
}

function Export-Artifacts {
  param([string]$TargetDir)

  foreach ($artifact in Get-GeneratedArtifacts) {
    $targetPath = Join-Path $TargetDir $artifact.RelativePath
    Write-Utf8NoBom -Path $targetPath -Content $artifact.Content
    Write-Host ("Wrote {0}" -f $targetPath)
  }
}

if ($MatchCommitted) {
  Assert-CommittedMatches
  Write-Host "Committed release baselines match generated output."
  exit 0
}

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $OutputDir = Join-Path $repoRoot ".tmp\release-baselines"
}

Export-Artifacts -TargetDir $OutputDir
Write-Host ("Release baselines exported to {0}" -f $OutputDir)
