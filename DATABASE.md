# Database Design and Setup

## 📊 Database Architecture

### Overview

The Ship Management System uses SQL Server with a normalized relational database design. All data access is performed through stored procedures for security and performance.

### Database Schema

#### Entity Relationship Diagram

See [ERD.md](ERD.md) for the complete entity relationship diagram.

#### Main Tables

**1. Ships**
- `ShipCode` (PK) - Unique ship identifier
- `ShipName` - Ship name
- `FiscalYearCode` - MMDD format (e.g., '0112' = Jan-Dec, '0403' = Apr-Mar)
- `Status` - Active/Inactive
- `CreatedAt`, `UpdatedAt` - Audit timestamps

**2. Users**
- `UserId` (PK) - Auto-increment ID
- `UserName` - Unique username
- `Email` - Unique email address
- `Role` - User role (Administrator, FleetManager, etc.)

**3. UserShipAssignments**
- Many-to-many relationship between Users and Ships
- Tracks which users can access which ships

**4. CrewMembers**
- `CrewId` (PK) - Unique crew identifier
- `FirstName`, `LastName`
- `DateOfBirth` - For age calculation
- `Nationality`

**5. CrewRanks**
- `RankId` (PK) - Auto-increment ID
- `RankName` - Rank designation (Master, Chief Officer, etc.)
- `RankOrder` - For hierarchical sorting
- `Department` - Deck, Engine, or Catering

**6. CrewServiceHistory**
- Tracks crew assignments to ships
- `SignOnDate`, `SignOffDate`, `EndOfContractDate`
- Foreign keys to CrewMembers, Ships, and CrewRanks

**7. ChartOfAccounts**
- Hierarchical account structure
- `AccountNumber` (PK) - Account code
- `AccountDescription` - Account name
- `ParentAccountNumber` - For hierarchy
- `AccountType` - 'Parent' or 'Child'

**8. BudgetData**
- Budget information by ship, account, and period
- `ShipCode`, `AccountNumber`, `AccountingPeriod`
- `BudgetAmount`

**9. AccountTransactions**
- Actual transactions
- `ShipCode`, `AccountNumber`, `AccountingPeriod`
- `TransactionAmount`, `TransactionDate`, `TransactionDescription`

### Stored Procedures

#### 1. usp_GetCrewList
Retrieves crew members with advanced filtering and pagination.

**Parameters:**
- `@ShipCode` - Filter by ship
- `@PageNumber` - Page number (default: 1)
- `@PageSize` - Records per page (default: 20)
- `@SortColumn` - Column to sort by (default: 'RankOrder')
- `@SortDirection` - ASC or DESC (default: 'ASC')
- `@SearchTerm` - Search across all text fields
- `@AsOfDate` - Date for status calculation (default: current date)

**Returns:**
- Paginated crew list with status, age, and formatted dates
- Total records, total pages, current page, page size

**Status Logic:**
- **Onboard**: Signed on, not signed off, within contract period
- **Relief Due**: More than 30 days past EndOfContractDate
- **Planned**: SignOnDate is in the future
- **Signed Off**: Has SignOffDate

#### 2. usp_GetFinancialReportDetail
Generates detailed financial report with budget vs actual comparison.

**Parameters:**
- `@ShipCode` - Ship to report on
- `@Period` - Accounting period (YYYY-MM format)

**Returns:**
- Account-level details (child accounts only)
- Period Actual, Budget, Variance
- YTD Actual, Budget, Variance
- Only includes accounts with non-zero values

#### 3. usp_GetFinancialReportSummary
Generates summary financial report (parent accounts only).

**Parameters:**
- `@ShipCode` - Ship to report on
- `@Period` - Accounting period (YYYY-MM format)

**Returns:**
- Aggregated parent account values
- Period and YTD metrics

#### Helper Functions

**fn_GetYTDPeriods**
- Calculates all periods in fiscal year up to specified period
- Handles different fiscal year configurations

**fn_CalculateAge**
- Calculates age from date of birth

**fn_GetCrewStatus**
- Determines crew status based on dates

**fn_FormatDate**
- Formats dates as 'DD MMM YYYY'

## 🚀 Database Initialization

### Quick Start (Recommended)

If you prefer the automated approach, use the initialization script:

```bash
cd database
./init-db.sh
```

## Database Maintenance

The script will:
1. Test database connection
2. Prompt for cleanup (optional)
3. Create all tables
4. Insert sample data (ships, users, crew)
5. Insert financial data (budget, transactions)
6. Create stored procedures
7. Display summary of records created

**Features:**
- ✅ Works with both Azure SQL and Local SQL Server
- ✅ Auto-detects server type
- ✅ Interactive cleanup option
- ✅ Color-coded output
- ✅ Error handling with detailed messages
- ✅ Connection testing before initialization

### Environment Variables

Override default configuration:

```bash
# Mac/Linux
export DB_SERVER="yourserver.database.windows.net"
export DB_NAME="ship"
export DB_USER="yourusername"
export DB_PASSWORD="yourpassword"
./init-db.sh

# Windows
set DB_SERVER=yourserver.database.windows.net
set DB_NAME=ship
set DB_USER=yourusername
set DB_PASSWORD=yourpassword
init-db.bat
```

### Azure SQL Database

For Azure SQL Server, use the dedicated initializer:

```bash
cd database/DatabaseInitializer
dotnet run
```

This will:
- Connect to Azure SQL Server
- Clean up existing data
- Execute all SQL scripts in order
- Display summary of inserted records

**Connection String:**
Update in `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=tcp:yourserver.database.windows.net,1433;Initial Catalog=ship;User ID=username;Password=password;Encrypt=True;TrustServerCertificate=False;"
  }
}
```

### Manual Setup

If you prefer to run scripts manually:

**Step 1: Create Database**
```sql
CREATE DATABASE ShipManagementDB;
GO
USE ShipManagementDB;
GO
```

**Step 2: Run SQL Scripts**

Execute in this order:

```bash
# 1. Create tables
sqlcmd -S localhost -U sa -P YourPassword -d ShipManagementDB -i 01_CreateTables.sql

# 2. Insert sample data (ships, users, crew, ranks)
sqlcmd -S localhost -U sa -P YourPassword -d ShipManagementDB -i 02_InsertSampleData.sql

# 3. Insert financial data (budget and transactions)
sqlcmd -S localhost -U sa -P YourPassword -d ShipManagementDB -i 03_InsertBudgetAndTransactions.sql

# 4. Create stored procedures
sqlcmd -S localhost -U sa -P YourPassword -d ShipManagementDB -i 04_CreateStoredProcedures.sql
```

**Step 3: Verify**

```sql
-- Check record counts
SELECT 'Ships' AS TableName, COUNT(*) AS RecordCount FROM Ships
UNION ALL
SELECT 'Users', COUNT(*) FROM Users
UNION ALL
SELECT 'CrewMembers', COUNT(*) FROM CrewMembers
UNION ALL
SELECT 'ChartOfAccounts', COUNT(*) FROM ChartOfAccounts;
```

Expected results:
- Ships: 5
- Users: 5
- CrewMembers: 100
- ChartOfAccounts: 68
- BudgetData: 690
- AccountTransactions: 828

## 📝 Sample Data Overview

### Ships
- **SHIP01** - Flying Dutchman (Fiscal: 0112 = Jan-Dec)
- **SHIP02** - Thousand Sunny (Fiscal: 0403 = Apr-Mar)
- **SHIP03** - Black Pearl (Fiscal: 0112 = Jan-Dec)
- **SHIP04** - Queen Anne's Revenge (Fiscal: 0403 = Apr-Mar)
- **SHIP05** - HMS Endeavour (Fiscal: 0712 = Jul-Jun, Inactive)

### Users
- 5 users with different roles
- Multiple ship assignments per user

### Crew Members
- 100 crew members distributed across ships
- ~20 crew per active ship
- Various nationalities and ages
- Mix of statuses: Onboard, Relief Due, Planned, Signed Off

### Crew Ranks
18 ranks across 3 departments:
- **Deck**: Master, Chief Officer, Second Officer, Third Officer, Bosun, Able Seaman, Ordinary Seaman, Deck Cadet
- **Engine**: Chief Engineer, Second Engineer, Third Engineer, Fourth Engineer, Oiler, Wiper, Cadet Engineer
- **Catering**: Chief Cook, Cook, Messman

### Chart of Accounts
Hierarchical structure with 68 accounts:
- **5000000** - OPERATING EXPENSES (Parent)
  - **5110000** - HEAVY FUEL OIL (Child)
  - **5210000** - DIESEL OIL (Child)
  - ...
- **6000000** - CREW COSTS (Parent)
  - **6110000** - OFFICER WAGES (Child)
  - **6120000** - RATING WAGES (Child)
  - ...

### Financial Data
- **Budget Data**: 690 records covering 2024-2025
- **Transactions**: 828 records with realistic variations
- Sample data for 4 active ships
- Monthly data for 23 months (Jan 2024 - Nov 2025)

## 🔧 Database Maintenance

### Backup

```bash
# SQL Server backup
sqlcmd -S localhost -U sa -P YourPassword -Q "BACKUP DATABASE ShipManagementDB TO DISK='/var/opt/mssql/backup/ShipManagementDB.bak'"
```

### Restore

```bash
# SQL Server restore
sqlcmd -S localhost -U sa -P YourPassword -Q "RESTORE DATABASE ShipManagementDB FROM DISK='/var/opt/mssql/backup/ShipManagementDB.bak' WITH REPLACE"
```

### Clean Up and Reinitialize

```bash
# Run cleanup script
sqlcmd -S localhost -U sa -P YourPassword -d ShipManagementDB -i 00_CleanupData.sql

# Then run initialization scripts again
./init-db-quick.sh
```

## 🎯 Design Principles

### Security
- All data access through stored procedures
- Parameterized queries prevent SQL injection
- No direct table access from application

### Performance
- Proper indexing on foreign keys and search columns
- Efficient pagination with ROW_NUMBER()
- Optimized stored procedures with CTEs

### Maintainability
- Clear naming conventions
- Normalized database structure
- Comprehensive constraints and checks
- Audit timestamps on all tables

### Scalability
- Indexed for fast queries
- Partitioning-ready design
- Efficient hierarchical queries

## 🐛 Troubleshooting

### Connection Issues
```bash
# Test connection
sqlcmd -S localhost -U sa -P YourPassword -Q "SELECT @@VERSION"
```

### Permission Issues
```sql
-- Grant permissions
GRANT EXECUTE ON SCHEMA::dbo TO YourUser;
```

### Data Issues
```sql
-- Check for orphaned records
SELECT * FROM CrewServiceHistory cs
WHERE NOT EXISTS (SELECT 1 FROM CrewMembers cm WHERE cm.CrewId = cs.CrewId);
```

---

**For more information:**
- See [ERD.md](ERD.md) for complete database diagram
- See [API Documentation](API_DOCUMENTATION.md) for API usage
- See [AZURE_SETUP.md](AZURE_SETUP.md) for Azure-specific setup
