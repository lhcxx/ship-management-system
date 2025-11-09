@echo off
REM Azure SQL Database Initialization Script
REM This script initializes the Azure SQL Database with tables, data, and stored procedures

echo ==========================================
echo Azure SQL Database Initialization
echo ==========================================
echo.

REM Azure SQL Server connection details
set SERVER=sqlshipmasys.database.windows.net
set DATABASE=ship
set USERNAME=ship
set PASSWORD=sys2026!

echo Testing connection to Azure SQL Server...
sqlcmd -S %SERVER% -d %DATABASE% -U %USERNAME% -P %PASSWORD% -Q "SELECT 1 AS TestConnection" -I

if errorlevel 1 (
    echo.
    echo ERROR: Cannot connect to Azure SQL Server
    echo Please check:
    echo   1. Server name: %SERVER%
    echo   2. Database name: %DATABASE%
    echo   3. Username: %USERNAME%
    echo   4. Password is correct
    echo   5. Your IP address is allowed in Azure SQL firewall rules
    pause
    exit /b 1
)

echo.
echo Connection successful!
echo.

echo Step 1/4: Creating database schema (tables)...
sqlcmd -S %SERVER% -d %DATABASE% -U %USERNAME% -P %PASSWORD% -i 01_CreateTables.sql -I
if errorlevel 1 (
    echo ERROR: Failed to create database schema
    pause
    exit /b 1
)
echo Success: Database schema created
echo.

echo Step 2/4: Inserting sample data (ships, users, crew)...
sqlcmd -S %SERVER% -d %DATABASE% -U %USERNAME% -P %PASSWORD% -i 02_InsertSampleData.sql -I
if errorlevel 1 (
    echo ERROR: Failed to insert sample data
    pause
    exit /b 1
)
echo Success: Sample data inserted
echo.

echo Step 3/4: Inserting financial data (budget and transactions)...
sqlcmd -S %SERVER% -d %DATABASE% -U %USERNAME% -P %PASSWORD% -i 03_InsertBudgetAndTransactions.sql -I
if errorlevel 1 (
    echo ERROR: Failed to insert financial data
    pause
    exit /b 1
)
echo Success: Financial data inserted
echo.

echo Step 4/4: Creating stored procedures...
sqlcmd -S %SERVER% -d %DATABASE% -U %USERNAME% -P %PASSWORD% -i 04_CreateStoredProcedures.sql -I
if errorlevel 1 (
    echo ERROR: Failed to create stored procedures
    pause
    exit /b 1
)
echo Success: Stored procedures created
echo.

echo ==========================================
echo Azure SQL Database Initialization Complete!
echo ==========================================
echo.

echo Database Summary:
sqlcmd -S %SERVER% -d %DATABASE% -U %USERNAME% -P %PASSWORD% -Q "SELECT 'Ships' AS TableName, COUNT(*) AS RecordCount FROM Ships UNION ALL SELECT 'Users', COUNT(*) FROM Users UNION ALL SELECT 'CrewMembers', COUNT(*) FROM CrewMembers UNION ALL SELECT 'CrewRanks', COUNT(*) FROM CrewRanks UNION ALL SELECT 'ChartOfAccounts', COUNT(*) FROM ChartOfAccounts UNION ALL SELECT 'BudgetData', COUNT(*) FROM BudgetData UNION ALL SELECT 'AccountTransactions', COUNT(*) FROM AccountTransactions ORDER BY TableName;" -I

echo.
echo You can now run the API with: dotnet run
echo The API will connect to: %SERVER%
echo.

pause
