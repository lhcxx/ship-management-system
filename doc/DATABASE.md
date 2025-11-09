# Database Design and Setup

## 📊 Database Architecture

### Overview

The Ship Management System uses SQL Server with a normalized relational database design. All data access is performed through stored procedures for security and performance.

### Database Schema

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

### Quick Start 

Use the initialization script:

```bash
cd database
./init-db.sh
```
