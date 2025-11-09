@echo off
REM Database initialization script for Ship Management System (Windows)
REM This script runs all SQL files in the correct order

echo Initializing Ship Management Database...

REM Configuration
set SA_PASSWORD=YourStrong@Passw0rd
set SERVER=localhost
set DATABASE=ShipManagementDB

echo Creating database...
sqlcmd -S %SERVER% -U sa -P %SA_PASSWORD% -C -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '%DATABASE%') BEGIN CREATE DATABASE %DATABASE%; PRINT 'Database %DATABASE% created successfully'; END ELSE BEGIN PRINT 'Database %DATABASE% already exists'; END"

echo Running table creation script...
sqlcmd -S %SERVER% -U sa -P %SA_PASSWORD% -d %DATABASE% -C -i 01_CreateTables.sql

echo Inserting sample data...
sqlcmd -S %SERVER% -U sa -P %SA_PASSWORD% -d %DATABASE% -C -i 02_InsertSampleData.sql

echo Inserting budget and transaction data...
sqlcmd -S %SERVER% -U sa -P %SA_PASSWORD% -d %DATABASE% -C -i 03_InsertBudgetAndTransactions.sql

echo Creating stored procedures...
sqlcmd -S %SERVER% -U sa -P %SA_PASSWORD% -d %DATABASE% -C -i 04_CreateStoredProcedures.sql

echo Database initialization completed!
pause
