@echo off
REM Ship Management System - Database Initialization Script (Windows)
REM This script works with both Azure SQL and Local SQL Server
REM Supports Windows Command Prompt and PowerShell

setlocal enabledelayedexpansion

REM Configuration - Can be overridden with environment variables
if "%DB_SERVER%"=="" set DB_SERVER=sqlshipmasys.database.windows.net
if "%DB_NAME%"=="" set DB_NAME=ship
if "%DB_USER%"=="" set DB_USER=ship

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

REM Print banner
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║   Ship Management System - Database Initialization    ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Check if password is provided
if "%DB_PASSWORD%"=="" (
    set /p DB_PASSWORD="Please enter database password for user '%DB_USER%': "
)

REM Check if sqlcmd is installed
where sqlcmd >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] sqlcmd is not installed
    echo.
    echo Please install SQL Server command-line tools:
    echo   Download from: https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility
    exit /b 1
)

REM Detect server type
echo %DB_SERVER% | findstr "database.windows.net" >nul
if %ERRORLEVEL% EQU 0 (
    set SERVER_TYPE=Azure SQL
    set SQLCMD_OPTS=-N -C
) else (
    set SERVER_TYPE=Local SQL Server
    set SQLCMD_OPTS=-C
)

echo Server Type: %SERVER_TYPE%
echo Server: %DB_SERVER%
echo Database: %DB_NAME%
echo User: %DB_USER%
echo.

REM Test connection
echo [*] Testing database connection...
sqlcmd -S "%DB_SERVER%" -d "%DB_NAME%" -U "%DB_USER%" -P "%DB_PASSWORD%" %SQLCMD_OPTS% -Q "SELECT 1" -b >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to connect to database
    echo   Server: %DB_SERVER%
    echo   Database: %DB_NAME%
    echo   User: %DB_USER%
    echo.
    echo Please check:
    echo   1. Database credentials are correct
    echo   2. Server firewall allows your IP address
    echo   3. Database exists and is accessible
    echo.
    if "%SERVER_TYPE%"=="Azure SQL" (
        echo For Azure SQL:
        echo   - Add your IP to firewall rules in Azure Portal
        echo   - Check Azure SQL server status
    )
    exit /b 1
)
echo [OK] Connected to database successfully
echo.

REM Start initialization
echo Starting database initialization...
echo.

REM Step 1: Cleanup (optional)
if exist "%SCRIPT_DIR%\00_CleanupData.sql" (
    set /p CLEANUP="Do you want to cleanup existing data? (y/N): "
    if /i "!CLEANUP!"=="y" (
        echo [*] Cleaning up existing data...
        sqlcmd -S "%DB_SERVER%" -d "%DB_NAME%" -U "%DB_USER%" -P "%DB_PASSWORD%" %SQLCMD_OPTS% -i "%SCRIPT_DIR%\00_CleanupData.sql" -b >nul 2>&1
        if !ERRORLEVEL! NEQ 0 (
            echo [ERROR] Failed to cleanup existing data
            exit /b 1
        )
        echo [OK] Cleanup completed
    )
)

REM Step 2: Create tables
echo [*] Creating database tables...
sqlcmd -S "%DB_SERVER%" -d "%DB_NAME%" -U "%DB_USER%" -P "%DB_PASSWORD%" %SQLCMD_OPTS% -i "%SCRIPT_DIR%\01_CreateTables.sql" -b >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to create tables
    exit /b 1
)
echo [OK] Tables created successfully

REM Step 3: Insert sample data
echo [*] Inserting sample data (ships, crew, users)...
sqlcmd -S "%DB_SERVER%" -d "%DB_NAME%" -U "%DB_USER%" -P "%DB_PASSWORD%" %SQLCMD_OPTS% -i "%SCRIPT_DIR%\02_InsertSampleData.sql" -b >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to insert sample data
    exit /b 1
)
echo [OK] Sample data inserted successfully

REM Step 4: Insert budget and transaction data
echo [*] Inserting budget and transaction data...
sqlcmd -S "%DB_SERVER%" -d "%DB_NAME%" -U "%DB_USER%" -P "%DB_PASSWORD%" %SQLCMD_OPTS% -i "%SCRIPT_DIR%\03_InsertBudgetAndTransactions.sql" -b >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to insert budget and transaction data
    exit /b 1
)
echo [OK] Budget and transaction data inserted successfully

REM Step 5: Create stored procedures
echo [*] Creating stored procedures and functions...
sqlcmd -S "%DB_SERVER%" -d "%DB_NAME%" -U "%DB_USER%" -P "%DB_PASSWORD%" %SQLCMD_OPTS% -i "%SCRIPT_DIR%\04_CreateStoredProcedures.sql" -b >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to create stored procedures
    exit /b 1
)
echo [OK] Stored procedures created successfully

REM Completion
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║       Database Initialization Completed Successfully!  ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Show summary
echo 📊 Database Summary:
echo.
echo Querying record counts...

set "QUERY=SELECT 'Ships' AS TableName, COUNT(*) AS RecordCount FROM Ships UNION ALL SELECT 'Users', COUNT(*) FROM Users UNION ALL SELECT 'CrewMembers', COUNT(*) FROM CrewMembers UNION ALL SELECT 'CrewRanks', COUNT(*) FROM CrewRanks UNION ALL SELECT 'ChartOfAccounts', COUNT(*) FROM ChartOfAccounts UNION ALL SELECT 'BudgetData', COUNT(*) FROM BudgetData UNION ALL SELECT 'AccountTransactions', COUNT(*) FROM AccountTransactions ORDER BY TableName;"

sqlcmd -S "%DB_SERVER%" -d "%DB_NAME%" -U "%DB_USER%" -P "%DB_PASSWORD%" %SQLCMD_OPTS% -Q "%QUERY%" -Y 20

echo.
echo ✨ Your database is ready to use!
echo.
echo Next steps:
echo   1. Start the API: cd ..\src\ShipManagement.API ^&^& dotnet run
echo   2. Open Swagger UI: http://localhost:5050
echo   3. Test endpoints with sample data
echo.
echo Configuration:
echo   - Database tools use appsettings.json
echo   - Set environment variables to override:
echo     set DB_SERVER=yourserver.database.windows.net
echo     set DB_USER=yourusername
echo     set DB_PASSWORD=yourpassword
echo.

endlocal
