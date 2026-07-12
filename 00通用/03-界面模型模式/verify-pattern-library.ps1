param(
    [string]$Root = $PSScriptRoot
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

$caseRoot = Join-Path $Root 'cases'
$caseFiles = @(Get-ChildItem -Path $caseRoot -Recurse -Filter '*.html' -File)
Assert-True ($caseFiles.Count -eq 39) "Expected 39 case files, found $($caseFiles.Count)."

$markdownFiles = @(Get-ChildItem -Path $Root -Filter '*.md' -File)
$markdownText = ($markdownFiles | ForEach-Object {
    [IO.File]::ReadAllText($_.FullName, [Text.Encoding]::UTF8)
}) -join "`n"

$placeholderMarkers = @(
    'KPI Cards (for dashboard/report cases)',
    'Filter Form (for list cases)',
    'Order Table',
    'Order Timeline'
)

$statefulCases = @{
    '01-5-wizard.html' = 'data-action="next-step"'
    '02-5-import-flow.html' = 'data-action="run-import"'
    '08-2-draft-handling.html' = 'data-action="save-draft"'
    '08-3-import-task-center.html' = 'data-action="retry-import"'
    '09-2-rule-builder.html' = 'data-action="test-rule"'
    '11-1-order-exception-ai.html' = 'data-action="approve-ai"'
    '12-1-promotion-rule-simulator.html' = 'data-action="run-simulation"'
    '12-3-retry-queue.html' = 'data-action="retry-job"'
}

foreach ($caseFile in $caseFiles) {
    $text = [IO.File]::ReadAllText($caseFile.FullName, [Text.Encoding]::UTF8)
    Assert-True ($text.Contains('lang="zh-CN"')) "$($caseFile.Name): missing zh-CN language."
    Assert-True ($text.Contains('name="viewport"')) "$($caseFile.Name): missing viewport metadata."
    Assert-True ($text.Contains('../shared/case.css')) "$($caseFile.Name): missing shared responsive CSS."
    Assert-True ($text.Contains('../shared/case.js')) "$($caseFile.Name): missing shared behavior runtime."
    Assert-True ($text.Contains('<main')) "$($caseFile.Name): missing main landmark."
    Assert-True ($text.Contains('data-demo=')) "$($caseFile.Name): missing static/interactive declaration."
    Assert-True ($text.Contains('class="demo-mode"')) "$($caseFile.Name): missing visible demo mode label."
    Assert-True (-not ($text -match 'https?://')) "$($caseFile.Name): external dependency is not allowed."
    Assert-True ($markdownText.Contains($caseFile.Name)) "$($caseFile.Name): not discoverable from Markdown."

    $buttonsWithoutType = [regex]::Matches($text, '<button(?![^>]*\stype=)[^>]*>', 'IgnoreCase')
    Assert-True ($buttonsWithoutType.Count -eq 0) "$($caseFile.Name): button without explicit type."

    $inputsWithId = [regex]::Matches($text, '<(?:input|select|textarea)[^>]*\sid="([^"]+)"', 'IgnoreCase')
    foreach ($inputMatch in $inputsWithId) {
        $id = $inputMatch.Groups[1].Value
        $escapedId = [regex]::Escape($id)
        $hasLabel = [regex]::IsMatch($text, '<label[^>]*\sfor="' + $escapedId + '"', 'IgnoreCase')
        Assert-True $hasLabel "$($caseFile.Name): form control $id has no explicit label."
    }

    foreach ($marker in $placeholderMarkers) {
        Assert-True (-not $text.Contains($marker)) "$($caseFile.Name): copied placeholder marker remains."
    }

    if ($statefulCases.ContainsKey($caseFile.Name)) {
        $token = $statefulCases[$caseFile.Name]
        Assert-True ($text.Contains($token)) "$($caseFile.Name): required state transition is missing."
    }
}

$sharedCssPath = Join-Path $caseRoot 'shared\case.css'
$sharedJsPath = Join-Path $caseRoot 'shared\case.js'
Assert-True (Test-Path -LiteralPath $sharedCssPath) 'Missing shared case CSS.'
Assert-True (Test-Path -LiteralPath $sharedJsPath) 'Missing shared case runtime.'

$sharedCss = [IO.File]::ReadAllText($sharedCssPath, [Text.Encoding]::UTF8)
Assert-True ($sharedCss.Contains('@media (max-width:')) 'Shared CSS has no responsive breakpoint.'
Assert-True ($sharedCss.Contains(':focus-visible')) 'Shared CSS has no visible keyboard focus.'

$detailHtmlPath = Join-Path $Root '13-UI-detail.html'
if (-not (Test-Path -LiteralPath $detailHtmlPath)) {
    $detailHtmlPath = @(Get-ChildItem -Path $Root -Filter '13-*.html' -File)[0].FullName
}
$detailHtml = [IO.File]::ReadAllText($detailHtmlPath, [Text.Encoding]::UTF8)
foreach ($number in 1..25) {
    $id = 'p{0:d2}' -f $number
    Assert-True ($detailHtml.Contains("id=`"$id`"")) "Detail HTML is missing anchor $id."
    Assert-True ($detailHtml.Contains("href=`"#$id`"")) "Detail HTML TOC is missing link $id."
}

Write-Output "PASS: $($caseFiles.Count) cases satisfy the pattern-library structural contract."
