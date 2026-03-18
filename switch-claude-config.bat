@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Claude 配置切换工具 (批处理版本)
set "CONFIG_DIR=C:\Windows-SSD\claude_config"
set "TARGET_PATH=C:\Users\16555\.claude\settings.json"

echo ========================================
echo    Claude 配置切换工具
echo ========================================
echo.

:: 检查配置目录是否存在
if not exist "%CONFIG_DIR%" (
    echo [错误] 配置目录不存在: %CONFIG_DIR%
    pause
    exit /b 1
)

:: 检查当前配置
set "CURRENT_CONFIG=无"
if exist "%TARGET_PATH%" (
    fsutil reparsepoint query "%TARGET_PATH%" >nul 2>&1
    if !errorlevel! equ 0 (
        for /f "tokens=3" %%a in ('fsutil reparsepoint query "%TARGET_PATH%" ^| findstr /C:"Print Name:"') do (
            set "LINK_TARGET=%%a"
            for %%b in ("!LINK_TARGET!") do set "CURRENT_CONFIG=%%~nxb"
        )
    ) else (
        set "CURRENT_CONFIG=settings.json (非符号链接)"
    )
) else (
    set "CURRENT_CONFIG=不存在 (将创建新的符号链接)"
)

echo 当前配置: %CURRENT_CONFIG%
echo.
echo 可用配置列表:
echo.

:: 列出所有配置文件
set COUNT=0
for %%f in ("%CONFIG_DIR%\*.json") do (
    set /a COUNT+=1
    set "CONFIG_!COUNT!=%%~nxf"
    set "CONFIG_PATH_!COUNT!=%%f"
    
    :: 获取文件大小和修改时间
    set "SIZE=%%~zf"
    set "TIME=%%~tf"
    
    :: 标记当前配置
    if "%%~nxf"=="%CURRENT_CONFIG%" (
        echo   [!COUNT!] %%~nxf ^(!SIZE! bytes, !TIME!^) [当前]
    ) else (
        echo   [!COUNT!] %%~nxf ^(!SIZE! bytes, !TIME!^)
    )
)

if %COUNT% equ 0 (
    echo [错误] 未找到任何配置文件
    pause
    exit /b 1
)

echo.
set /p "CHOICE=请选择要切换的配置 (输入序号 1-%COUNT%, 或按 Q 退出): "

:: 检查是否退出
if /i "%CHOICE%"=="Q" (
    echo 已取消
    pause
    exit /b 0
)

:: 验证输入
if %CHOICE% lss 1 (
    echo [错误] 无效的选择
    pause
    exit /b 1
)
if %CHOICE% gtr %COUNT% (
    echo [错误] 无效的选择
    pause
    exit /b 1
)

:: 获取选中的配置
set "SELECTED_CONFIG=!CONFIG_%CHOICE%!"
set "SOURCE_PATH=!CONFIG_PATH_%CHOICE%!"

echo.
echo 准备切换到: %SELECTED_CONFIG%
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 需要管理员权限来创建符号链接
    echo 正在尝试以管理员身份重新运行...
    echo.
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b 0
)

:: 备份现有配置（如果是普通文件）
if exist "%TARGET_PATH%" (
    fsutil reparsepoint query "%TARGET_PATH%" >nul 2>&1
    if !errorlevel! neq 0 (
        set "BACKUP_NAME=settings_backup_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%.json"
        set "BACKUP_NAME=!BACKUP_NAME: =0!"
        echo 备份现有配置到: !BACKUP_NAME!
        copy "%TARGET_PATH%" "%CONFIG_DIR%\!BACKUP_NAME!" >nul
    )
    
    echo 删除现有配置...
    del /f /q "%TARGET_PATH%"
)

:: 确保目标目录存在
set "TARGET_DIR=%TARGET_PATH%\.."
if not exist "%TARGET_DIR%" (
    echo 创建目标目录: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
)

:: 创建符号链接
echo 创建符号链接...
mklink "%TARGET_PATH%" "%SOURCE_PATH%" >nul

if %errorlevel% equ 0 (
    echo.
    echo ✓ 配置切换成功!
    echo   当前配置: %SELECTED_CONFIG%
    echo   链接路径: %TARGET_PATH%
    echo   目标路径: %SOURCE_PATH%
) else (
    echo.
    echo ✗ 切换失败
)

echo.
pause
