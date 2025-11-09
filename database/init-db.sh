#!/bin/bash

# Ship Management System - Database Initialization Script
# This script works with both Azure SQL and Local SQL Server
# Supports macOS, Linux, and Windows (Git Bash)

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to parse connection string from appsettings.json
parse_appsettings() {
    local appsettings_file="$SCRIPT_DIR/DatabaseInitializer/appsettings.json"
    
    if [ -f "$appsettings_file" ]; then
        echo -e "${BLUE}Reading configuration from appsettings.json...${NC}"
        
        # Extract connection string using grep and sed
        local conn_str=$(grep -o '"DefaultConnection"[[:space:]]*:[[:space:]]*"[^"]*"' "$appsettings_file" | sed 's/.*"DefaultConnection"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
        
        if [ -n "$conn_str" ]; then
            # Parse Server
            DB_SERVER=$(echo "$conn_str" | grep -o 'Server=[^;]*' | cut -d'=' -f2 | sed 's/tcp://;s/,1433//')
            # Parse Database/Initial Catalog
            DB_NAME=$(echo "$conn_str" | grep -o -E '(Database|Initial Catalog)=[^;]*' | cut -d'=' -f2)
            # Parse User ID
            DB_USER=$(echo "$conn_str" | grep -o 'User ID=[^;]*' | cut -d'=' -f2)
            # Parse Password
            DB_PASSWORD=$(echo "$conn_str" | grep -o 'Password=[^;]*' | cut -d'=' -f2)
            
            return 0
        fi
    fi
    return 1
}

# Try to read from appsettings.json first
if parse_appsettings; then
    echo -e "${GREEN}✅ Configuration loaded from appsettings.json${NC}"
else
    # Fallback to environment variables or defaults
    echo -e "${YELLOW}⚠ appsettings.json not found, using environment variables or defaults${NC}"
    DB_SERVER="${DB_SERVER:-sqlshipmasys.database.windows.net}"
    DB_NAME="${DB_NAME:-ship}"
    DB_USER="${DB_USER:-ship}"
    DB_PASSWORD="${DB_PASSWORD}"
fi

# Print banner
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Ship Management System - Database Initialization    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if password is available
if [ -z "$DB_PASSWORD" ]; then
    echo -e "${RED}❌ Error: Database password not found${NC}"
    echo ""
    echo "Please either:"
    echo "  1. Update password in: database/DatabaseInitializer/appsettings.json"
    echo "  2. Set environment variable: export DB_PASSWORD=yourpassword"
    echo ""
    exit 1
fi

# Check if sqlcmd is installed
if ! command -v sqlcmd &> /dev/null; then
    echo -e "${RED}❌ Error: sqlcmd is not installed${NC}"
    echo ""
    echo "Please install SQL Server command-line tools:"
    echo ""
    echo "  macOS:   brew install sqlcmd"
    echo "  Linux:   https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools"
    echo "  Windows: https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility"
    echo ""
    exit 1
fi

# Detect server type
if [[ "$DB_SERVER" == *"database.windows.net"* ]]; then
    SERVER_TYPE="Azure SQL"
    SQLCMD_OPTS="-N -C"
else
    SERVER_TYPE="Local SQL Server"
    SQLCMD_OPTS="-C"
fi

echo -e "${BLUE}Server Type: ${SERVER_TYPE}${NC}"
echo -e "${BLUE}Server: ${DB_SERVER}${NC}"
echo -e "${BLUE}Database: ${DB_NAME}${NC}"
echo -e "${BLUE}User: ${DB_USER}${NC}"
echo ""

# Function to execute SQL file
execute_sql_file() {
    local file=$1
    local description=$2
    
    echo -e "${BLUE}▶ ${description}...${NC}"
    
    if [ ! -f "$file" ]; then
        echo -e "${RED}❌ Error: File not found: $file${NC}"
        exit 1
    fi
    
    if sqlcmd -S "$DB_SERVER" -d "$DB_NAME" -U "$DB_USER" -P "$DB_PASSWORD" $SQLCMD_OPTS -i "$file" -b > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Success: ${description}${NC}"
    else
        echo -e "${RED}❌ Failed: ${description}${NC}"
        echo -e "${RED}   Please check the error above and try again${NC}"
        exit 1
    fi
}

# Test connection first
echo -e "${BLUE}▶ Testing database connection...${NC}"
if sqlcmd -S "$DB_SERVER" -d "$DB_NAME" -U "$DB_USER" -P "$DB_PASSWORD" $SQLCMD_OPTS -Q "SELECT 1" -b > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Connected to database successfully${NC}"
    echo ""
else
    echo -e "${RED}❌ Failed to connect to database${NC}"
    echo -e "${RED}   Server: $DB_SERVER${NC}"
    echo -e "${RED}   Database: $DB_NAME${NC}"
    echo -e "${RED}   User: $DB_USER${NC}"
    echo ""
    echo "Please check:"
    echo "  1. Database credentials are correct"
    echo "  2. Server firewall allows your IP address"
    echo "  3. Database exists and is accessible"
    echo ""
    if [[ "$SERVER_TYPE" == "Azure SQL" ]]; then
        echo "For Azure SQL:"
        echo "  - Add your IP to firewall rules in Azure Portal"
        echo "  - Check Azure SQL server status"
    fi
    exit 1
fi

# Start initialization
echo -e "${YELLOW}Starting database initialization...${NC}"
echo -e "${YELLOW}⚠ This will delete all existing data and reinitialize the database${NC}"
echo ""

# Step 1: Cleanup existing data (always execute)
if [ -f "$SCRIPT_DIR/00_CleanupData.sql" ]; then
    execute_sql_file "$SCRIPT_DIR/00_CleanupData.sql" "Cleaning up existing data"
fi

# Step 2: Create tables
execute_sql_file "$SCRIPT_DIR/01_CreateTables.sql" "Creating database tables"

# Step 3: Insert sample data
execute_sql_file "$SCRIPT_DIR/02_InsertSampleData.sql" "Inserting sample data (ships, crew, users)"

# Step 4: Insert budget and transaction data
execute_sql_file "$SCRIPT_DIR/03_InsertBudgetAndTransactions.sql" "Inserting budget and transaction data"

# Step 5: Create stored procedures
execute_sql_file "$SCRIPT_DIR/04_CreateStoredProcedures.sql" "Creating stored procedures and functions"

# Completion
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║       Database Initialization Completed Successfully!  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Show summary
echo -e "${BLUE}📊 Database Summary:${NC}"
echo ""

# Query record counts
echo -e "${YELLOW}Querying record counts...${NC}"
QUERY="
SELECT 
    'Ships' AS TableName, COUNT(*) AS RecordCount FROM Ships
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
"

sqlcmd -S "$DB_SERVER" -d "$DB_NAME" -U "$DB_USER" -P "$DB_PASSWORD" $SQLCMD_OPTS -Q "$QUERY" -Y 20

echo ""
echo -e "${GREEN}✨ Your database is ready to use!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Start the API: cd ../src/ShipManagement.API && dotnet run"
echo "  2. Open Swagger UI: http://localhost:5050"
echo "  3. Test endpoints with sample data"
echo ""
