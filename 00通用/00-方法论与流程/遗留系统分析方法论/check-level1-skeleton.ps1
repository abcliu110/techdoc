# check-level1-skeleton.ps1
# Purpose: Validate Level 1 skeleton completeness and content substance
# Exit codes:
#   0 - All domain skeletons are complete with substantive content
#   2 - Level 1 directories exist but skeleton files are missing
#   3 - Level 2 tasks belong to domains not in Level 0 list or without Level 1 skeleton
#   4 - Domain list inconsistent with Level 1 directories
#   5 - Level 1 files exist but contain only template placeholders

[CmdletBinding()]
param(
    [string]$RootPath = "系统分析产出"
)

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Helper function: Check if file contains only placeholder content
function Test-IsPlaceholderOnly {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) { return $false }
    
    $content = Get-Content $FilePath -Encoding UTF8 -Raw
    if ([string]::IsNullOrWhiteSpace($content)) { return $true }
    
    # Remove skeleton marker lines
    $lines = ($content -split "`n") | Where-Object { 
        $_ -notmatch '^\s*<!--\s*skeleton:.*-->\s*$' 
    }
    
    # Count substantive lines (not empty, not just dash, not just markdown headers)
    $substantiveLines = 0
    foreach ($line in $lines) {
        $trimmed = $line.Trim()
        
        if ($trimmed -eq "") { continue }
        if ($trimmed -eq "-") { continue }
        if ($trimmed -match '^#+\s*$') { continue }
        if ($trimmed -match '^\[.*\]$') { continue }
        if ($trimmed -match '^TODO') { continue }
        
        # Check for very short lines that are likely placeholders
        if ($trimmed.Length -lt 3) { continue }
        
        $substantiveLines++
        if ($substantiveLines -ge 3) { break }  # Found enough content
    }
    
    return ($substantiveLines -lt 3)
}

Write-Host "=== Level 1 Skeleton Completeness Check ===" -ForegroundColor Cyan
Write-Host "Root path: $RootPath"
Write-Host ""

# 1. Read Level 0 domain list
$level0Dir = Join-Path $RootPath "Level 0"
$moduleFile = Get-ChildItem -Path $level0Dir -Filter "02-*.md" | 
              Select-Object -First 1 -ExpandProperty FullName

if (-not $moduleFile -or -not (Test-Path $moduleFile)) {
    Write-Host "[ERROR] Domain list file not found in: $level0Dir" -ForegroundColor Red
    Write-Host "  Expected file pattern: 02-*.md" -ForegroundColor Red
    Write-Host "  Found files:" -ForegroundColor Yellow
    Get-ChildItem -Path $level0Dir | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
    exit 4
}

Write-Host "[1/5] Parsing domain list..." -ForegroundColor Yellow

$content = Get-Content $moduleFile -Encoding UTF8 -Raw
# Pattern to match table rows with: | 01 | 业务域01-xxx(domain) | ...
$domains = [System.Collections.ArrayList]@()

$lines = $content -split "`n"
foreach ($line in $lines) {
    # Match table rows: | 01 | XXX01-名称(domain) | ...
    if ($line -match '^\s*\|\s*(\d{2})\s*\|') {
        # Extract the domain directory pattern from line
        if ($line -match '([^\|]+\d{2}-[^(|]+\([^)|]+\))') {
            $fullMatch = $matches[1].Trim()
            
            # Extract number and domain code
            if ($fullMatch -match '(\d{2})-[^(]+\(([^)]+)\)') {
                $num = $matches[1]
                $domain = $matches[2].Trim()
                
                # Extract name (between number and parenthesis)
                if ($fullMatch -match '\d{2}-([^(]+)\(') {
                    $name = $matches[1].Trim()
                } else {
                    $name = "unknown"
                }
                
                # Use the actual matched text as FullName (includes correct prefix from file)
                $fullName = $fullMatch
                
                # Check if already added (avoid duplicates)
                $exists = $domains | Where-Object { $_.Number -eq $num }
                if (-not $exists) {
                    $domainObj = @{
                        Number = $num
                        Name = $name
                        Domain = $domain
                        FullName = $fullName
                    }
                    [void]$domains.Add($domainObj)
                }
            }
        }
    }
}

if ($domains.Count -eq 0) {
    Write-Host "[ERROR] No domain definitions found in $moduleFile" -ForegroundColor Red
    exit 4
}

Write-Host "  Found $($domains.Count) domains" -ForegroundColor Green

# 2. Validate domain numbering
Write-Host ""
Write-Host "[2/5] Validating domain numbering..." -ForegroundColor Yellow

$numbers = $domains | ForEach-Object { [int]$_.Number } | Sort-Object
$duplicates = $numbers | Group-Object | Where-Object { $_.Count -gt 1 }

if ($duplicates) {
    Write-Host "[ERROR] Duplicate domain numbers: $($duplicates.Name -join ', ')" -ForegroundColor Red
    exit 4
}

for ($i = 0; $i -lt $numbers.Count; $i++) {
    $expected = $i + 1
    if ($numbers[$i] -ne $expected) {
        Write-Host "[ERROR] Domain numbers not consecutive, expected $expected, got $($numbers[$i])" -ForegroundColor Red
        exit 4
    }
}

Write-Host "  Numbering is consecutive and unique OK" -ForegroundColor Green

# 3. Validate Level 1 directories and skeleton files
Write-Host ""
Write-Host "[3/5] Validating Level 1 skeletons..." -ForegroundColor Yellow

# Find Level 1 directory (avoid hardcoding Chinese characters)
$level1Dir = Get-ChildItem -Path $RootPath -Directory | 
             Where-Object { $_.Name -like "Level 1*" -or $_.Name -like "*业务域*" } | 
             Select-Object -First 1 -ExpandProperty FullName

if (-not $level1Dir -or -not (Test-Path $level1Dir)) {
    Write-Host "[ERROR] Level 1 directory not found in: $RootPath" -ForegroundColor Red
    Write-Host "  Expected pattern: Level 1-* or *业务域*" -ForegroundColor Red
    exit 4
}

# Find the required file names from actual file system (avoid hardcoding Chinese)
# Look for a complete domain directory to extract the file pattern
$sampleDomainDir = $null
foreach ($testDir in (Get-ChildItem -Path $level1Dir -Directory)) {
    $mdFiles = Get-ChildItem -Path $testDir.FullName -Filter "*.md" | Sort-Object Name
    if ($mdFiles.Count -ge 3) {
        $sampleDomainDir = $testDir
        break
    }
}

$requiredFiles = @()
if ($sampleDomainDir) {
    $existingFiles = Get-ChildItem -Path $sampleDomainDir.FullName -Filter "*.md" | 
                     Where-Object { $_.Name -match '^0[1-3]-.*\.md$' } | 
                     Sort-Object Name
    if ($existingFiles.Count -ge 3) {
        $requiredFiles = $existingFiles[0..2] | ForEach-Object { $_.Name }
    }
}

# Fallback: use pattern matching instead of hardcoded names
if ($requiredFiles.Count -eq 0) {
    # Find files matching 01-*, 02-*, 03-* pattern
    $allFiles = Get-ChildItem -Path $level1Dir -Recurse -Filter "*.md" | 
                Where-Object { $_.Name -match '^0[1-3]-.*\.md$' } |
                Select-Object -ExpandProperty Name -Unique |
                Sort-Object
    
    if ($allFiles.Count -ge 3) {
        $requiredFiles = $allFiles | Select-Object -First 3
    } else {
        # Last resort: use generic patterns
        $requiredFiles = @("01-*.md", "02-*.md", "03-*.md")
    }
}

$skeletonMarker = "<!-- skeleton: do not delete -->"

$missingDirs = @()
$missingFiles = @()
$missingMarkers = @()
$placeholderOnly = @()

foreach ($domain in $domains) {
    $domainDir = Join-Path $level1Dir $domain.FullName
    
    if (-not (Test-Path $domainDir)) {
        $missingDirs += $domain.FullName
        continue
    }
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $domainDir $file
        
        if (-not (Test-Path $filePath)) {
            $missingFiles += "$($domain.FullName)/$file"
            continue
        }
        
        $fileContent = Get-Content $filePath -Encoding UTF8 -Raw
        
        if ($fileContent -notmatch [regex]::Escape($skeletonMarker)) {
            $missingMarkers += "$($domain.FullName)/$file"
        }
        
        if (Test-IsPlaceholderOnly -FilePath $filePath) {
            $placeholderOnly += "$($domain.FullName)/$file"
        }
    }
}

if ($missingDirs) {
    Write-Host "[ERROR] Missing Level 1 directories:" -ForegroundColor Red
    $missingDirs | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 4
}

if ($missingFiles) {
    Write-Host "[ERROR] Missing skeleton files:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 2
}

if ($missingMarkers) {
    Write-Host "[WARNING] Missing skeleton markers:" -ForegroundColor Yellow
    $missingMarkers | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}

if ($placeholderOnly) {
    Write-Host "[ERROR] Files contain only template placeholders (G1 incomplete):" -ForegroundColor Red
    $placeholderOnly | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 5
}

Write-Host "  All domain skeletons complete with substantive content OK" -ForegroundColor Green

# 4. Validate Level 2 task ownership
Write-Host ""
Write-Host "[4/5] Validating Level 2 task ownership..." -ForegroundColor Yellow

$level2Dir = Join-Path $RootPath "Level 2"
$orphanedLevel2 = @()

if (Test-Path $level2Dir) {
    $level2Contexts = Get-ChildItem $level2Dir -Directory
    
    foreach ($context in $level2Contexts) {
        $contextName = $context.Name
        $belongsToDomain = $false
        
        foreach ($domain in $domains) {
            $domainDir = Join-Path $level1Dir $domain.FullName
            $contextListFile = Join-Path $domainDir "02-上下文清单.md"
            
            if ((Test-Path $contextListFile)) {
                $contextList = Get-Content $contextListFile -Encoding UTF8 -Raw
                if ($contextList -match [regex]::Escape($contextName)) {
                    $belongsToDomain = $true
                    break
                }
            }
        }
        
        if (-not $belongsToDomain) {
            $orphanedLevel2 += $contextName
        }
    }
}

if ($orphanedLevel2) {
    Write-Host "[ERROR] Level 2 tasks not listed in any domain:" -ForegroundColor Red
    $orphanedLevel2 | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 3
}

Write-Host "  All Level 2 tasks have clear ownership OK" -ForegroundColor Green

# 5. Final summary
Write-Host ""
Write-Host "[5/5] Final summary" -ForegroundColor Yellow
Write-Host "  Domain count: $($domains.Count)" -ForegroundColor Cyan
Write-Host "  Level 1 directories: $($domains.Count)/$($domains.Count) OK" -ForegroundColor Green
Write-Host "  Level 1 files: $(($domains.Count * 3))/$(($domains.Count * 3)) OK" -ForegroundColor Green
Write-Host "  Substantive content: All passed OK" -ForegroundColor Green

Write-Host ""
Write-Host "=== Check PASSED ===" -ForegroundColor Green
exit 0
