#!/bin/bash

# Database initialization script for Ship Management System
# This script runs all SQL files in the correct order

echo "Initializing Ship Management Database..."

# Configuration
SA_PASSWORD="YourStrong@Passw0rd"
SERVER="localhost"
DATABASE="ShipManagementDB"

# Wait for SQL Server to be ready
echo "Waiting for SQL Server to start..."
sleep 30

# Create database
echo "Creating database..."
/opt/mssql-tools18/bin/sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -C -Q "
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$DATABASE')
BEGIN
    CREATE DATABASE $DATABASE;
    PRINT 'Database $DATABASE created successfully';
END
ELSE
BEGIN
    PRINT 'Database $DATABASE already exists';
END
"

# Run SQL scripts in order
echo "Running table creation script..."
/opt/mssql-tools18/bin/sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $DATABASE -C -i /docker-entrypoint-initdb.d/01_CreateTables.sql

echo "Inserting sample data..."
/opt/mssql-tools18/bin/sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $DATABASE -C -i /docker-entrypoint-initdb.d/02_InsertSampleData.sql

echo "Inserting budget and transaction data..."
/opt/mssql-tools18/bin/sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $DATABASE -C -i /docker-entrypoint-initdb.d/03_InsertBudgetAndTransactions.sql

echo "Creating stored procedures..."
/opt/mssql-tools18/bin/sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $DATABASE -C -i /docker-entrypoint-initdb.d/04_CreateStoredProcedures.sql

echo "Database initialization completed!"
