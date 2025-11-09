# Entity Relationship Diagram (ERD)

## Ship Management System Database Schema

### Entity Overview

The database consists of 9 main tables organized into logical groups:

## 1. Ship Management

### Ships
**Purpose**: Store ship master data  
**Primary Key**: ShipCode (NVARCHAR(20))

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| ShipCode | NVARCHAR(20) | NO | Unique ship identifier (PK) |
| ShipName | NVARCHAR(100) | NO | Ship name |
| FiscalYearCode | NCHAR(4) | NO | Format: MMDD (e.g., '0112', '0403') |
| Status | NVARCHAR(20) | NO | 'Active' or 'Inactive' |
| CreatedAt | DATETIME2 | NO | Record creation timestamp |
| UpdatedAt | DATETIME2 | NO | Last update timestamp |

**Constraints**:
- CHK_Ships_Status: Status must be 'Active' or 'Inactive'
- CHK_Ships_FiscalYearCode: Must be 4 digits in MMDD format

---

## 2. User Management

### Users
**Purpose**: Store system user information  
**Primary Key**: UserId (INT IDENTITY)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| UserId | INT IDENTITY | NO | Auto-incrementing user ID (PK) |
| UserName | NVARCHAR(100) | NO | User's display name (Unique) |
| Email | NVARCHAR(255) | NO | User's email address (Unique) |
| Role | NVARCHAR(50) | NO | User role/position |
| CreatedAt | DATETIME2 | NO | Record creation timestamp |
| UpdatedAt | DATETIME2 | NO | Last update timestamp |

### UserShipAssignments
**Purpose**: Many-to-many relationship between Users and Ships  
**Primary Key**: AssignmentId (INT IDENTITY)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| AssignmentId | INT IDENTITY | NO | Auto-incrementing ID (PK) |
| UserId | INT | NO | Reference to Users (FK) |
| ShipCode | NVARCHAR(20) | NO | Reference to Ships (FK) |
| AssignedAt | DATETIME2 | NO | Assignment timestamp |

**Constraints**:
- FK_UserShipAssignments_Users: Foreign key to Users
- FK_UserShipAssignments_Ships: Foreign key to Ships
- UQ_UserShipAssignment: Unique constraint on (UserId, ShipCode)

---

## 3. Crew Management

### CrewRanks
**Purpose**: Define crew rank types  
**Primary Key**: RankId (INT IDENTITY)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| RankId | INT IDENTITY | NO | Auto-incrementing rank ID (PK) |
| RankName | NVARCHAR(100) | NO | Rank name (Unique) |
| RankOrder | INT | NO | Order for sorting ranks hierarchically |
| Department | NVARCHAR(50) | YES | Department (Deck, Engine, Catering) |
| CreatedAt | DATETIME2 | NO | Record creation timestamp |

### CrewMembers
**Purpose**: Store crew personal information  
**Primary Key**: CrewId (NVARCHAR(20))

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| CrewId | NVARCHAR(20) | NO | Unique crew identifier (PK) |
| FirstName | NVARCHAR(100) | NO | Crew first name |
| LastName | NVARCHAR(100) | NO | Crew last name |
| DateOfBirth | DATE | NO | Date of birth |
| Nationality | NVARCHAR(100) | NO | Crew nationality |
| CreatedAt | DATETIME2 | NO | Record creation timestamp |
| UpdatedAt | DATETIME2 | NO | Last update timestamp |

**Constraints**:
- CHK_CrewMembers_DateOfBirth: Date of birth must be in the past

### CrewServiceHistory
**Purpose**: Track crew assignments to ships  
**Primary Key**: ServiceHistoryId (INT IDENTITY)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| ServiceHistoryId | INT IDENTITY | NO | Auto-incrementing ID (PK) |
| CrewId | NVARCHAR(20) | NO | Reference to CrewMembers (FK) |
| ShipCode | NVARCHAR(20) | NO | Reference to Ships (FK) |
| RankId | INT | NO | Reference to CrewRanks (FK) |
| SignOnDate | DATE | NO | Date crew joined ship |
| SignOffDate | DATE | YES | Date crew left ship (NULL if still onboard) |
| EndOfContractDate | DATE | NO | Contract end date |
| CreatedAt | DATETIME2 | NO | Record creation timestamp |
| UpdatedAt | DATETIME2 | NO | Last update timestamp |

**Constraints**:
- FK_CrewServiceHistory_Crew: Foreign key to CrewMembers
- FK_CrewServiceHistory_Ship: Foreign key to Ships
- FK_CrewServiceHistory_Rank: Foreign key to CrewRanks
- CHK_CrewServiceHistory_Dates: SignOnDate <= EndOfContractDate AND SignOffDate >= SignOnDate

**Business Logic** (Implemented in fn_GetCrewStatus):
- Status = 'Onboard': SignOnDate <= Today AND SignOffDate IS NULL AND EndOfContractDate >= Today
- Status = 'Relief Due': SignOnDate <= Today AND SignOffDate IS NULL AND Today > EndOfContractDate + 30 days
- Status = 'Planned': SignOnDate > Today
- Status = 'Signed Off': SignOffDate IS NOT NULL

---

## 4. Financial Management

### ChartOfAccounts
**Purpose**: Hierarchical account structure  
**Primary Key**: AccountNumber (NVARCHAR(20))

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| AccountNumber | NVARCHAR(20) | NO | Unique account number (PK) |
| AccountDescription | NVARCHAR(255) | NO | Account description |
| ParentAccountNumber | NVARCHAR(20) | YES | Reference to parent account (FK, Self-referencing) |
| AccountType | NVARCHAR(20) | NO | 'Parent' or 'Child' |
| CreatedAt | DATETIME2 | NO | Record creation timestamp |

**Constraints**:
- FK_ChartOfAccounts_Parent: Self-referencing foreign key
- CHK_ChartOfAccounts_Type: AccountType must be 'Parent' or 'Child'

**Hierarchy Rules**:
- Parent accounts: Contain child accounts, values calculated by aggregation
- Child accounts: Store actual budget and transaction data

### BudgetData
**Purpose**: Store budget amounts per account and period  
**Primary Key**: BudgetId (INT IDENTITY)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| BudgetId | INT IDENTITY | NO | Auto-incrementing ID (PK) |
| ShipCode | NVARCHAR(20) | NO | Reference to Ships (FK) |
| AccountNumber | NVARCHAR(20) | NO | Reference to ChartOfAccounts (FK) |
| AccountingPeriod | NCHAR(7) | NO | Format: YYYY-MM (e.g., '2025-01') |
| BudgetAmount | DECIMAL(18,2) | NO | Budget amount (must be >= 0) |
| CreatedAt | DATETIME2 | NO | Record creation timestamp |

**Constraints**:
- FK_BudgetData_Ship: Foreign key to Ships
- FK_BudgetData_Account: Foreign key to ChartOfAccounts
- CHK_BudgetData_Amount: BudgetAmount >= 0
- CHK_BudgetData_Period: Period format YYYY-MM
- UQ_BudgetData: Unique constraint on (ShipCode, AccountNumber, AccountingPeriod)

### AccountTransactions
**Purpose**: Store actual transaction amounts  
**Primary Key**: TransactionId (INT IDENTITY)

| Column | Type | Nullable | Description |
|--------|------|----------|-------------|
| TransactionId | INT IDENTITY | NO | Auto-incrementing ID (PK) |
| ShipCode | NVARCHAR(20) | NO | Reference to Ships (FK) |
| AccountNumber | NVARCHAR(20) | NO | Reference to ChartOfAccounts (FK) |
| AccountingPeriod | NCHAR(7) | NO | Format: YYYY-MM |
| TransactionAmount | DECIMAL(18,2) | NO | Transaction amount (must be >= 0) |
| TransactionDate | DATE | NO | Transaction date |
| Description | NVARCHAR(500) | YES | Transaction description |
| CreatedAt | DATETIME2 | NO | Record creation timestamp |

**Constraints**:
- FK_AccountTransactions_Ship: Foreign key to Ships
- FK_AccountTransactions_Account: Foreign key to ChartOfAccounts
- CHK_AccountTransactions_Amount: TransactionAmount >= 0
- CHK_AccountTransactions_Period: Period format YYYY-MM

---

## Relationships

### One-to-Many Relationships

1. **Ships → CrewServiceHistory**
   - One ship has many crew assignments
   - CASCADE DELETE: Deleting a ship removes all crew history

2. **Ships → BudgetData**
   - One ship has many budget records
   - CASCADE DELETE: Deleting a ship removes all budget data

3. **Ships → AccountTransactions**
   - One ship has many transactions
   - CASCADE DELETE: Deleting a ship removes all transactions

4. **CrewMembers → CrewServiceHistory**
   - One crew member has many service assignments
   - CASCADE DELETE: Deleting a crew member removes their service history

5. **CrewRanks → CrewServiceHistory**
   - One rank is used in many service assignments
   - NO CASCADE: Rank cannot be deleted if in use

6. **ChartOfAccounts → ChartOfAccounts** (Self-referencing)
   - Parent accounts contain child accounts
   - Creates account hierarchy

7. **ChartOfAccounts → BudgetData**
   - One account has many budget records
   - NO CASCADE: Account cannot be deleted if budget data exists

8. **ChartOfAccounts → AccountTransactions**
   - One account has many transactions
   - NO CASCADE: Account cannot be deleted if transactions exist

### Many-to-Many Relationships

1. **Users ↔ Ships** (via UserShipAssignments)
   - Users can be assigned to multiple ships
   - Ships can have multiple assigned users
   - CASCADE DELETE on both sides

---

## Indexes

### Performance Optimization

**Ships**:
- IX_Ships_Status: Index on Status for filtering active ships

**Users**:
- IX_Users_Email: Index on Email for lookups

**UserShipAssignments**:
- IX_UserShipAssignments_UserId: Index for user lookups
- IX_UserShipAssignments_ShipCode: Index for ship lookups

**CrewMembers**:
- IX_CrewMembers_Name: Composite index on (LastName, FirstName)
- IX_CrewMembers_Nationality: Index for filtering by nationality

**CrewServiceHistory**:
- IX_CrewServiceHistory_CrewId: Index for crew lookups
- IX_CrewServiceHistory_ShipCode: Index for ship lookups
- IX_CrewServiceHistory_Dates: Composite index on date columns

**ChartOfAccounts**:
- IX_ChartOfAccounts_Parent: Index for hierarchy navigation
- IX_ChartOfAccounts_Type: Index for filtering by type

**BudgetData**:
- IX_BudgetData_ShipPeriod: Composite index on (ShipCode, AccountingPeriod)
- IX_BudgetData_Account: Index on AccountNumber

**AccountTransactions**:
- IX_AccountTransactions_ShipPeriod: Composite index on (ShipCode, AccountingPeriod)
- IX_AccountTransactions_Account: Index on AccountNumber
- IX_AccountTransactions_Date: Index on TransactionDate

---

## Stored Procedures and Functions

### Functions

1. **fn_GetCrewStatus**: Calculate crew status based on dates
2. **fn_CalculateAge**: Calculate age from date of birth
3. **fn_GetFiscalYearStartMonth**: Extract fiscal year start month
4. **fn_GetYTDPeriods**: Get periods for YTD calculation

### Stored Procedures

1. **usp_GetCrewList**: 
   - Retrieves crew for a ship with pagination, sorting, and search
   - Parameters: @ShipCode, @AsOfDate, @PageNumber, @PageSize, @SortColumn, @SortDirection, @SearchTerm

2. **usp_GetFinancialReportDetail**:
   - Detailed financial report with all accounts
   - Parameters: @ShipCode, @Period
   - Calculates period and YTD values with variances

3. **usp_GetFinancialReportSummary**:
   - Summary financial report with top-level parent accounts only
   - Parameters: @ShipCode, @Period

---

## Data Integrity Rules

### Ships
- FiscalYearCode must be valid MMDD format (01-12 for both months)
- Status must be 'Active' or 'Inactive'

### CrewMembers
- DateOfBirth must be in the past

### CrewServiceHistory
- SignOnDate must be <= EndOfContractDate
- SignOffDate (if not NULL) must be >= SignOnDate

### Financial Data
- Budget and transaction amounts must be non-negative (>= 0)
- AccountingPeriod must be in YYYY-MM format
- Only child accounts can have budget/transaction data
- Parent account values are calculated by aggregation

### UserShipAssignments
- Combination of UserId and ShipCode must be unique
- Both User and Ship must exist

---

## Visual Diagram

```
┌─────────────┐         ┌──────────────────┐         ┌─────────────┐
│   Ships     │◄───────►│UserShipAssignments│◄───────►│   Users     │
└─────────────┘         └──────────────────┘         └─────────────┘
      │                                                       
      │ 1:N                                                   
      ▼                                                       
┌──────────────────┐                                          
│CrewServiceHistory│                                          
└──────────────────┘                                          
      │                                                       
      │ N:1          N:1                                      
      ▼              ▼                                         
┌─────────────┐   ┌─────────────┐                            
│ CrewMembers │   │  CrewRanks  │                            
└─────────────┘   └─────────────┘                            
                                                              
┌─────────────┐         1:N                                   
│   Ships     │◄────────────────┐                            
└─────────────┘                 │                            
      │                         │                            
      │ 1:N                     │                            
      ▼                         │                            
┌─────────────┐          ┌──────────────────┐               
│ BudgetData  │          │AccountTransactions│               
└─────────────┘          └──────────────────┘               
      │                         │                            
      │ N:1                     │ N:1                        
      ▼                         ▼                            
┌─────────────────────────────────┐                          
│     ChartOfAccounts (Self-ref)  │                          
└─────────────────────────────────┘                          
```

---

## Sample Queries

### Get all crew onboard a ship
```sql
EXEC usp_GetCrewList 
    @ShipCode = 'SHIP01', 
    @PageNumber = 1, 
    @PageSize = 20;
```

### Get financial report for a period
```sql
EXEC usp_GetFinancialReportDetail 
    @ShipCode = 'SHIP01', 
    @Period = '2025-01';
```

### Get user's assigned ships
```sql
SELECT s.* 
FROM Ships s
INNER JOIN UserShipAssignments usa ON s.ShipCode = usa.ShipCode
WHERE usa.UserId = 1;
```
