@echo off
cd /d "%~dp0"
echo ========================================
echo  单词深度分析原型服务器
echo  浏览器打开: http://localhost:8888
echo  按 Ctrl+C 停止
echo ========================================
python -m http.server 8888
