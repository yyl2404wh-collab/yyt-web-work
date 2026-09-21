@echo off
REM Keep window open when double-clicked
if /i not "%~1"=="RUN" (
    start "Database Init" cmd /k "%~f0" RUN
    exit /b 0
)

setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
cd /d "%~dp0"

echo ====================================
echo Database Init
echo ====================================
echo.

set "MYSQL_USER=root"
set "MYSQL_PWD="
set "MYSQL_CMD="

REM Read database.local.ini
if exist "database.local.ini" (
    for /f "usebackq eol=# tokens=1,* delims==" %%a in ("database.local.ini") do (
        set "KEY=%%a"
        set "VAL=%%b"
        if /i "!KEY!"=="mysql_user" set "MYSQL_USER=!VAL!"
        if /i "!KEY!"=="mysql_password" set "MYSQL_PWD=!VAL!"
    )
)

REM Trim spaces
for /f "tokens=* delims= " %%a in ("!MYSQL_USER!") do set "MYSQL_USER=%%a"
for /f "tokens=* delims= " %%a in ("!MYSQL_PWD!") do set "MYSQL_PWD=%%a"

if "!MYSQL_PWD!"=="" (
    echo [ERROR] mysql_password not set in database.local.ini
    echo Edit database.local.ini and set mysql_password=your_mysql_root_password
    goto end
)

REM Find mysql.exe
where mysql >nul 2>&1
if not errorlevel 1 (
    set "MYSQL_CMD=mysql"
    goto mysql_found
)
if exist "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" (
    set "MYSQL_CMD=C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
    goto mysql_found
)
if exist "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe" (
    set "MYSQL_CMD=C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe"
    goto mysql_found
)
if exist "C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe" (
    set "MYSQL_CMD=C:\Program Files (x86)\MySQL\MySQL Server 8.0\bin\mysql.exe"
    goto mysql_found
)

echo [ERROR] mysql.exe not found. Install MySQL or add it to PATH.
goto end

:mysql_found
echo [OK] mysql: !MYSQL_CMD!
echo [OK] user: !MYSQL_USER!
echo.

echo [1/3] Import init.sql ...
"!MYSQL_CMD!" -u "!MYSQL_USER!" -p"!MYSQL_PWD!" --default-character-set=utf8mb4 < "%~dp0sql\init.sql"
if errorlevel 1 goto fail

echo [2/3] Import business-tables.sql ...
"!MYSQL_CMD!" -u "!MYSQL_USER!" -p"!MYSQL_PWD!" --default-character-set=utf8mb4 gas_field_rbac < "%~dp0sql\business-tables.sql"
if errorlevel 1 goto fail

echo [3/3] Import sample-data.sql ...
"!MYSQL_CMD!" -u "!MYSQL_USER!" -p"!MYSQL_PWD!" --default-character-set=utf8mb4 gas_field_rbac < "%~dp0sql\sample-data.sql"
if errorlevel 1 goto fail

echo.
echo ====================================
echo [SUCCESS] Database initialized.
echo ====================================
echo DB: gas_field_rbac
echo Login accounts (password 123456):
echo   admin, client_01, algo_dev, field_eng
echo.
"!MYSQL_CMD!" -u "!MYSQL_USER!" -p"!MYSQL_PWD!" -e "SELECT COUNT(*) AS point_count FROM gas_field_rbac.point_info;"
echo.
goto end

:fail
echo.
echo [FAILED] Import error.
echo Check: 1) MySQL service running  2) password in database.local.ini
echo.

:end
echo Press any key to close...
pause >nul
endlocal
exit /b 0
