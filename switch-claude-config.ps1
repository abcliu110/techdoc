# Claude 配置切换工具
# 使用符号链接方式切换配置

$configDir = "C:\Windows-SSD\claude_config"
$targetPath = "C:\Users\16555\.claude\settings.json"

Write-Host "=== Claude 配置切换工具 ===" -ForegroundColor Cyan
Write-Host ""

# 检查配置目录是否存在
if (-not (Test-Path $configDir)) {
    Write-Host "错误: 配置目录不存在: $configDir" -ForegroundColor Red
    exit 1
}

# 获取所有配置文件
$configs = Get-ChildItem -Path $configDir -Filter "*.json" | Sort-Object Name

if ($configs.Count -eq 0) {
    Write-Host "错误: 未找到任何配置文件" -ForegroundColor Red
    exit 1
}

# 检查当前配置
$currentConfig = "无"
$needBackup = $false
$needCreate = $false

if (Test-Path $targetPath) {
    $item = Get-Item $targetPath
    if ($item.LinkType -eq "SymbolicLink") {
        $currentConfig = Split-Path $item.Target -Leaf
    } else {
        $currentConfig = "settings.json (非符号链接，需要转换)"
        $needBackup = $true
    }
} else {
    $currentConfig = "不存在 (将创建新的符号链接)"
    $needCreate = $true
}

Write-Host "当前配置: $currentConfig" -ForegroundColor Yellow
Write-Host ""

if ($needCreate) {
    Write-Host "提示: 目标配置文件不存在，将创建新的符号链接" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "可用配置列表:" -ForegroundColor Green
Write-Host ""

# 显示配置列表
for ($i = 0; $i -lt $configs.Count; $i++) {
    $config = $configs[$i]
    $num = $i + 1
    $size = [math]::Round($config.Length / 1KB, 2)
    $time = $config.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    
    $marker = ""
    if ($config.Name -eq $currentConfig) {
        $marker = " [当前]"
        Write-Host "  [$num] $($config.Name) ($size KB, $time)$marker" -ForegroundColor Yellow
    } else {
        Write-Host "  [$num] $($config.Name) ($size KB, $time)$marker"
    }
}

Write-Host ""
Write-Host "请选择要切换的配置 (输入序号 1-$($configs.Count), 或按 Q 退出): " -NoNewline -ForegroundColor Cyan
$choice = Read-Host

if ($choice -eq "Q" -or $choice -eq "q") {
    Write-Host "已取消" -ForegroundColor Yellow
    exit 0
}

# 验证输入
$index = 0
if (-not [int]::TryParse($choice, [ref]$index) -or $index -lt 1 -or $index -gt $configs.Count) {
    Write-Host "错误: 无效的选择" -ForegroundColor Red
    exit 1
}

$selectedConfig = $configs[$index - 1]
$sourcePath = $selectedConfig.FullName

Write-Host ""
Write-Host "准备切换到: $($selectedConfig.Name)" -ForegroundColor Green

# 检查是否需要管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "警告: 需要管理员权限来创建符号链接" -ForegroundColor Yellow
    Write-Host "正在尝试以管理员身份重新运行..." -ForegroundColor Yellow
    
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit 0
}

# 备份现有配置（如果是普通文件）
if ($needBackup) {
    $backupPath = Join-Path $configDir "settings_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
    Write-Host "备份现有配置到: $backupPath" -ForegroundColor Yellow
    Copy-Item $targetPath $backupPath -Force
}

# 删除现有配置（如果存在）
if (Test-Path $targetPath) {
    Write-Host "删除现有配置..." -ForegroundColor Yellow
    Remove-Item $targetPath -Force
}

# 确保目标目录存在
$targetDir = Split-Path $targetPath -Parent
if (-not (Test-Path $targetDir)) {
    Write-Host "创建目标目录: $targetDir" -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

# 创建符号链接
try {
    Write-Host "创建符号链接..." -ForegroundColor Yellow
    New-Item -ItemType SymbolicLink -Path $targetPath -Target $sourcePath -Force | Out-Null
    Write-Host ""
    Write-Host "✓ 配置切换成功!" -ForegroundColor Green
    Write-Host "  当前配置: $($selectedConfig.Name)" -ForegroundColor Cyan
    Write-Host "  链接路径: $targetPath" -ForegroundColor Gray
    Write-Host "  目标路径: $sourcePath" -ForegroundColor Gray
} catch {
    Write-Host ""
    Write-Host "✗ 切换失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "按任意键退出..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
