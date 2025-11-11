# Ship Management System - Database Initialization Script (PowerShell)
# This script works with both Azure SQL and Local SQL Server

param(
    [string]$ConfigFile = "$PSScriptRoot\DatabaseInitializer\appsettings.json"
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Load configuration from appsettings.json
Write-Host "Reading configuration from appsettings.json..." -ForegroundColor Cyan

if (-not (Test-Path $ConfigFile)) {
    Write-Host "ERROR: Configuration file not found: $ConfigFile" -ForegroundColor Red
    exit 1
}

try {
    $config = Get-Content $ConfigFile | ConvertFrom-Json
    $connectionString = $config.ConnectionStrings.DefaultConnection
    
    if ([string]::IsNullOrEmpty($connectionString)) {
        Write-Host "ERROR: Connection string 'DefaultConnection' not found in appsettings.json" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "OK: Configuration loaded from appsettings.json" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to read configuration: $_" -ForegroundColor Red
    exit 1
}

# Parse connection string
if ($connectionString -match 'Server=([^;]+)') {
    $DB_SERVER = $matches[1] -replace 'tcp:', '' -replace ',1433', ''
} else {
    Write-Host "ERROR: Server not found in connection string" -ForegroundColor Red
    exit 1
}

if ($connectionString -match 'Initial Catalog=([^;]+)') {
    $DB_NAME = $matches[1]
} elseif ($connectionString -match 'Database=([^;]+)') {
    $DB_NAME = $matches[1]
} else {
    Write-Host "ERROR: Database name not found in connection string" -ForegroundColor Red
    exit 1
}

if ($connectionString -match 'User ID=([^;]+)') {
    $DB_USER = $matches[1]
} else {
    Write-Host "ERROR: User ID not found in connection string" -ForegroundColor Red
    exit 1
}

if ($connectionString -match 'Password=([^;]+)') {
    $DB_PASSWORD = $matches[1]
} else {
    Write-Host "ERROR: Password not found in connection string" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please update password in: database\DatabaseInitializer\appsettings.json" -ForegroundColor Yellow
    exit 1
}

# Print banner
Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "  Ship Management System - Database Initialization " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Detect server type
if ($DB_SERVER -match 'database\.windows\.net') {
    $SERVER_TYPE = "Azure SQL"
    $SQLCMD_OPTS = @("-N", "-C")
} else {
    $SERVER_TYPE = "Local SQL Server"
    $SQLCMD_OPTS = @("-C")
}

Write-Host "Server Type: $SERVER_TYPE" -ForegroundColor White
Write-Host "Server: $DB_SERVER" -ForegroundColor White
Write-Host "Database: $DB_NAME" -ForegroundColor White
Write-Host "User: $DB_USER" -ForegroundColor White
Write-Host ""

# Check if sqlcmd is installed
$sqlcmdPath = Get-Command sqlcmd -ErrorAction SilentlyContinue
if (-not $sqlcmdPath) {
    Write-Host "ERROR: sqlcmd is not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install SQL Server command-line tools:" -ForegroundColor Yellow
    Write-Host "  Download from: https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility" -ForegroundColor Yellow
    exit 1
}

# Test connection
Write-Host "Testing database connection..." -ForegroundColor Yellow
$testArgs = @(
    "-S", $DB_SERVER,
    "-d", $DB_NAME,
    "-U", $DB_USER,
    "-P", $DB_PASSWORD,
    "-Q", "SELECT 1",
    "-b"
) + $SQLCMD_OPTS

$result = & sqlcmd @testArgs 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to connect to database" -ForegroundColor Red
    Write-Host "  Server: $DB_SERVER" -ForegroundColor Red
    Write-Host "  Database: $DB_NAME" -ForegroundColor Red
    Write-Host "  User: $DB_USER" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check:" -ForegroundColor Yellow
    Write-Host "  1. Database credentials are correct" -ForegroundColor Yellow
    Write-Host "  2. Server firewall allows your IP address" -ForegroundColor Yellow
    Write-Host "  3. Database exists and is accessible" -ForegroundColor Yellow
    Write-Host ""
    if ($SERVER_TYPE -eq "Azure SQL") {
        Write-Host "For Azure SQL:" -ForegroundColor Yellow
        Write-Host "  - Add your IP to firewall rules in Azure Portal" -ForegroundColor Yellow
        Write-Host "  - Check Azure SQL server status" -ForegroundColor Yellow
    }
    exit 1
}
Write-Host "OK: Connected to database successfully" -ForegroundColor Green

Write-Host ""

# Start initialization
Write-Host "Starting database initialization..." -ForegroundColor Cyan
Write-Host "WARNING: This will delete all existing data and reinitialize the database" -ForegroundColor Yellow
Write-Host ""

# Define SQL scripts in order
$sqlScripts = @(
    @{File = "00_CleanupData.sql"; Description = "Cleaning up existing data"; Optional = $true},
    @{File = "01_CreateTables.sql"; Description = "Creating database tables"; Optional = $false},
    @{File = "02_InsertSampleData.sql"; Description = "Inserting sample data"; Optional = $false},
    @{File = "03_InsertBudgetAndTransactions.sql"; Description = "Inserting budget and transaction data"; Optional = $false},
    @{File = "04_CreateStoredProcedures.sql"; Description = "Creating stored procedures"; Optional = $false}
)

# Execute each SQL script
foreach ($script in $sqlScripts) {
    $scriptPath = Join-Path $PSScriptRoot $script.File
    
    if (-not (Test-Path $scriptPath)) {
        if ($script.Optional) {
            Write-Host "SKIP: $($script.Description) (file not found)" -ForegroundColor Gray
            continue
        } else {
            Write-Host "ERROR: Required file not found: $scriptPath" -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host "Running: $($script.Description)..." -ForegroundColor Yellow
    
    $sqlArgs = @(
        "-S", $DB_SERVER,
        "-d", $DB_NAME,
        "-U", $DB_USER,
        "-P", $DB_PASSWORD,
        "-i", $scriptPath,
        "-b"
    ) + $SQLCMD_OPTS
    
    $output = & sqlcmd @sqlArgs 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed - $($script.Description)" -ForegroundColor Red
        Write-Host $output -ForegroundColor Red
        exit 1
    }
    Write-Host "OK: $($script.Description) completed" -ForegroundColor Green
}

# Completion
Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host "  Database Initialization Completed Successfully!  " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

# Show summary
Write-Host "Database Summary:" -ForegroundColor Cyan
Write-Host ""
Write-Host "Querying record counts..." -ForegroundColor Gray

$summaryQuery = "SELECT 'Ships' AS TableName, COUNT(*) AS RecordCount FROM Ships UNION ALL SELECT 'Users', COUNT(*) FROM Users UNION ALL SELECT 'CrewMembers', COUNT(*) FROM CrewMembers UNION ALL SELECT 'CrewRanks', COUNT(*) FROM CrewRanks UNION ALL SELECT 'ChartOfAccounts', COUNT(*) FROM ChartOfAccounts UNION ALL SELECT 'BudgetData', COUNT(*) FROM BudgetData UNION ALL SELECT 'AccountTransactions', COUNT(*) FROM AccountTransactions ORDER BY TableName;"

$summaryArgs = @(
    "-S", $DB_SERVER,
    "-d", $DB_NAME,
    "-U", $DB_USER,
    "-P", $DB_PASSWORD,
    "-Q", $summaryQuery,
    "-Y", "20"
) + $SQLCMD_OPTS

try {
    $summaryOutput = & sqlcmd @summaryArgs 2>&1
    Write-Host $summaryOutput
} catch {
    Write-Host "WARNING: Could not retrieve database summary" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Your database is ready to use!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Start the API: cd ..\src\ShipManagement.API && dotnet run" -ForegroundColor White
Write-Host "  2. Open Swagger UI: http://localhost:5050" -ForegroundColor White
Write-Host "  3. Test endpoints with sample data" -ForegroundColor White
Write-Host ""
