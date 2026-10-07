@echo off
echo 正在删除 math-explorer 目录...
timeout /t 2 /nobreak >nul
rmdir /s /q "D:\mywork\techdoc\数学学习软件\math-explorer"
if exist "D:\mywork\techdoc\数学学习软件\math-explorer" (
    echo 删除失败，目录可能仍被占用
    pause
) else (
    echo 删除成功！
    pause
)
