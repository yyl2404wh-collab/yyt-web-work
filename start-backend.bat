@echo off
echo ====================================
echo 启动天然气气田监测系统 - 后端服务
echo ====================================
echo.

cd backend

echo [1/2] 检查 Maven 环境...
call mvn -version
if errorlevel 1 (
    echo 错误: 未检测到 Maven，请先安装 Maven
    pause
    exit /b 1
)

echo.
echo [2/2] 启动 Spring Boot 应用...
echo 后端服务将运行在: http://localhost:8080
echo.

call mvn spring-boot:run

pause
