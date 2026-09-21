@echo off
echo ====================================
echo 启动天然气气田监测系统 - 前端服务
echo ====================================
echo.

cd frontend

echo [1/3] 检查 Node.js 环境...
call node -v
if errorlevel 1 (
    echo 错误: 未检测到 Node.js，请先安装 Node.js
    pause
    exit /b 1
)

echo.
echo [2/3] 安装依赖包...
if not exist "node_modules" (
    call npm install
) else (
    echo 依赖包已存在，跳过安装
)

echo.
echo [3/3] 启动开发服务器...
echo 前端服务将运行在: http://localhost:3000
echo.

call npm run dev

pause
