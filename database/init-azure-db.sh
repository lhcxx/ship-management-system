#!/bin/bash

# Azure SQL Database Initialization Script
# This script initializes the Azure SQL Database with tables, data, and stored procedures

echo "=========================================="
echo "Azure SQL Database Initialization"
echo "=========================================="
echo ""

# Azure SQL Server connection details
SERVER="sqlshipmasys.database.windows.net"
DATABASE="ship"
USERNAME="ship"
PASSWORD="sys2026!"

# Function to execute SQL file
execute_sql_file() {
    local file=$1
    local description=$2
    
    echo "Executing: $description"
    echo "File: $file"
    
    if [ ! -f "$file" ]; then
        echo "ERROR: File not found - $file"
        return 1
    fi
    
    sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" -i "$file" -I
    
    if [ $? -eq 0 ]; then
        echo "✓ Success: $description"
        echo ""
        return 0
    else
        echo "✗ Failed: $description"
        echo ""
        return 1
    fi
}

# Check if sqlcmd is installed
if ! command -v sqlcmd &> /dev/null; then
    echo "ERROR: sqlcmd is not installed."
    echo ""
    echo "To install sqlcmd on macOS:"
    echo "  brew install microsoft/mssql-release/mssql-tools18"
    echo ""
    echo "For other platforms, visit:"
    echo "  https://learn.microsoft.com/en-us/sql/tools/sqlcmd-utility"
    exit 1
fi

echo "Testing connection to Azure SQL Server..."
sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" -Q "SELECT 1 AS TestConnection" -I

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Cannot connect to Azure SQL Server"
    echo "Please check:"
    echo "  1. Server name: $SERVER"
    echo "  2. Database name: $DATABASE"
    echo "  3. Username: $USERNAME"
    echo "  4. Password is correct"
    echo "  5. Your IP address is allowed in Azure SQL firewall rules"
    exit 1
fi

echo ""
echo "✓ Connection successful!"
echo ""

# Execute SQL scripts in order
echo "Step 1/4: Creating database schema (tables)..."
execute_sql_file "01_CreateTables.sql" "Database schema creation"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create database schema"
    exit 1
fi

echo "Step 2/4: Inserting sample data (ships, users, crew)..."
execute_sql_file "02_InsertSampleData.sql" "Sample data insertion"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to insert sample data"
    exit 1
fi

echo "Step 3/4: Inserting financial data (budget and transactions)..."
execute_sql_file "03_InsertBudgetAndTransactions.sql" "Financial data insertion"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to insert financial data"
    exit 1
fi

echo "Step 4/4: Creating stored procedures..."
execute_sql_file "04_CreateStoredProcedures.sql" "Stored procedures creation"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create stored procedures"
    exit 1
fi

echo "=========================================="
echo "✓ Azure SQL Database Initialization Complete!"
echo "=========================================="
echo ""
echo "Database Summary:"
sqlcmd -S "$SERVER" -d "$DATABASE" -U "$USERNAME" -P "$PASSWORD" -Q "
SELECT 'Ships' AS TableName, COUNT(*) AS RecordCount FROM Ships
UNION ALL
SELECT 'Users', COUNT(*) FROM Users
UNION ALL
SELECT 'CrewMembers', COUNT(*) FROM CrewMembers
UNION ALL
SELECT 'CrewRanks', COUNT(*) FROM CrewRanks
UNION ALL
SELECT 'ChartOfAccounts', COUNT(*) FROM ChartOfAccounts
UNION ALL
SELECT 'BudgetData', COUNT(*) FROM BudgetData
UNION ALL
SELECT 'AccountTransactions', COUNT(*) FROM AccountTransactions
ORDER BY TableName;
" -I

echo ""
echo "You can now run the API with: dotnet run"
echo "The API will connect to: $SERVER"
echo ""
