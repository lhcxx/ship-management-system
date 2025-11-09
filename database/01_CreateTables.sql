-- Ship Management System Database Schema
-- SQL Server T-SQL

-- =============================================
-- Create Database (Optional - uncomment if needed)
-- =============================================
-- CREATE DATABASE ShipManagementDB;
-- GO
-- USE ShipManagementDB;
-- GO

-- =============================================
-- Drop Tables if exists (for clean setup)
-- =============================================
IF OBJECT_ID('dbo.UserShipAssignments', 'U') IS NOT NULL DROP TABLE dbo.UserShipAssignments;
IF OBJECT_ID('dbo.AccountTransactions', 'U') IS NOT NULL DROP TABLE dbo.AccountTransactions;
IF OBJECT_ID('dbo.BudgetData', 'U') IS NOT NULL DROP TABLE dbo.BudgetData;
IF OBJECT_ID('dbo.ChartOfAccounts', 'U') IS NOT NULL DROP TABLE dbo.ChartOfAccounts;
IF OBJECT_ID('dbo.CrewServiceHistory', 'U') IS NOT NULL DROP TABLE dbo.CrewServiceHistory;
IF OBJECT_ID('dbo.CrewMembers', 'U') IS NOT NULL DROP TABLE dbo.CrewMembers;
IF OBJECT_ID('dbo.CrewRanks', 'U') IS NOT NULL DROP TABLE dbo.CrewRanks;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Ships', 'U') IS NOT NULL DROP TABLE dbo.Ships;
GO

-- =============================================
-- Table: Ships
-- =============================================
CREATE TABLE dbo.Ships (
    ShipCode NVARCHAR(20) PRIMARY KEY,
    ShipName NVARCHAR(100) NOT NULL,
    FiscalYearCode NCHAR(4) NOT NULL, -- Format: MMDD (e.g., '0112' = Jan-Dec, '0403' = Apr-Mar)
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active',
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT CHK_Ships_Status CHECK (Status IN ('Active', 'Inactive')),
    CONSTRAINT CHK_Ships_FiscalYearCode CHECK (
        LEN(FiscalYearCode) = 4 AND
        ISNUMERIC(FiscalYearCode) = 1 AND
        CAST(SUBSTRING(FiscalYearCode, 1, 2) AS INT) BETWEEN 1 AND 12 AND
        CAST(SUBSTRING(FiscalYearCode, 3, 2) AS INT) BETWEEN 1 AND 12
    )
);
GO

CREATE INDEX IX_Ships_Status ON dbo.Ships(Status);
GO

-- =============================================
-- Table: Users
-- =============================================
CREATE TABLE dbo.Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    UserName NVARCHAR(100) NOT NULL UNIQUE,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Role NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

CREATE INDEX IX_Users_Email ON dbo.Users(Email);
GO

-- =============================================
-- Table: UserShipAssignments (Many-to-Many)
-- =============================================
CREATE TABLE dbo.UserShipAssignments (
    AssignmentId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    ShipCode NVARCHAR(20) NOT NULL,
    AssignedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_UserShipAssignments_Users FOREIGN KEY (UserId) 
        REFERENCES dbo.Users(UserId) ON DELETE CASCADE,
    CONSTRAINT FK_UserShipAssignments_Ships FOREIGN KEY (ShipCode) 
        REFERENCES dbo.Ships(ShipCode) ON DELETE CASCADE,
    CONSTRAINT UQ_UserShipAssignment UNIQUE (UserId, ShipCode)
);
GO

CREATE INDEX IX_UserShipAssignments_UserId ON dbo.UserShipAssignments(UserId);
CREATE INDEX IX_UserShipAssignments_ShipCode ON dbo.UserShipAssignments(ShipCode);
GO

-- =============================================
-- Table: CrewRanks
-- =============================================
CREATE TABLE dbo.CrewRanks (
    RankId INT IDENTITY(1,1) PRIMARY KEY,
    RankName NVARCHAR(100) NOT NULL UNIQUE,
    RankOrder INT NOT NULL, -- For sorting ranks hierarchically
    Department NVARCHAR(50), -- e.g., 'Deck', 'Engine', 'Catering'
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE()
);
GO

-- =============================================
-- Table: CrewMembers
-- =============================================
CREATE TABLE dbo.CrewMembers (
    CrewId NVARCHAR(20) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Nationality NVARCHAR(100) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT CHK_CrewMembers_DateOfBirth CHECK (DateOfBirth <= CAST(GETUTCDATE() AS DATE))
);
GO

CREATE INDEX IX_CrewMembers_Name ON dbo.CrewMembers(LastName, FirstName);
CREATE INDEX IX_CrewMembers_Nationality ON dbo.CrewMembers(Nationality);
GO

-- =============================================
-- Table: CrewServiceHistory
-- =============================================
CREATE TABLE dbo.CrewServiceHistory (
    ServiceHistoryId INT IDENTITY(1,1) PRIMARY KEY,
    CrewId NVARCHAR(20) NOT NULL,
    ShipCode NVARCHAR(20) NOT NULL,
    RankId INT NOT NULL,
    SignOnDate DATE NOT NULL,
    SignOffDate DATE NULL,
    EndOfContractDate DATE NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_CrewServiceHistory_Crew FOREIGN KEY (CrewId) 
        REFERENCES dbo.CrewMembers(CrewId) ON DELETE CASCADE,
    CONSTRAINT FK_CrewServiceHistory_Ship FOREIGN KEY (ShipCode) 
        REFERENCES dbo.Ships(ShipCode) ON DELETE CASCADE,
    CONSTRAINT FK_CrewServiceHistory_Rank FOREIGN KEY (RankId) 
        REFERENCES dbo.CrewRanks(RankId),
    CONSTRAINT CHK_CrewServiceHistory_Dates CHECK (
        SignOnDate <= EndOfContractDate AND
        (SignOffDate IS NULL OR SignOffDate >= SignOnDate)
    )
);
GO

CREATE INDEX IX_CrewServiceHistory_CrewId ON dbo.CrewServiceHistory(CrewId);
CREATE INDEX IX_CrewServiceHistory_ShipCode ON dbo.CrewServiceHistory(ShipCode);
CREATE INDEX IX_CrewServiceHistory_Dates ON dbo.CrewServiceHistory(SignOnDate, SignOffDate, EndOfContractDate);
GO

-- =============================================
-- Table: ChartOfAccounts (COA)
-- =============================================
CREATE TABLE dbo.ChartOfAccounts (
    AccountNumber NVARCHAR(20) PRIMARY KEY,
    AccountDescription NVARCHAR(255) NOT NULL,
    ParentAccountNumber NVARCHAR(20) NULL,
    AccountType NVARCHAR(20) NOT NULL, -- 'Parent' or 'Child'
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_ChartOfAccounts_Parent FOREIGN KEY (ParentAccountNumber) 
        REFERENCES dbo.ChartOfAccounts(AccountNumber),
    CONSTRAINT CHK_ChartOfAccounts_Type CHECK (AccountType IN ('Parent', 'Child'))
);
GO

CREATE INDEX IX_ChartOfAccounts_Parent ON dbo.ChartOfAccounts(ParentAccountNumber);
CREATE INDEX IX_ChartOfAccounts_Type ON dbo.ChartOfAccounts(AccountType);
GO

-- =============================================
-- Table: BudgetData
-- =============================================
CREATE TABLE dbo.BudgetData (
    BudgetId INT IDENTITY(1,1) PRIMARY KEY,
    ShipCode NVARCHAR(20) NOT NULL,
    AccountNumber NVARCHAR(20) NOT NULL,
    AccountingPeriod NCHAR(7) NOT NULL, -- Format: YYYY-MM (e.g., '2025-01')
    BudgetAmount DECIMAL(18, 2) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_BudgetData_Ship FOREIGN KEY (ShipCode) 
        REFERENCES dbo.Ships(ShipCode) ON DELETE CASCADE,
    CONSTRAINT FK_BudgetData_Account FOREIGN KEY (AccountNumber) 
        REFERENCES dbo.ChartOfAccounts(AccountNumber),
    CONSTRAINT CHK_BudgetData_Amount CHECK (BudgetAmount >= 0),
    CONSTRAINT CHK_BudgetData_Period CHECK (
        LEN(AccountingPeriod) = 7 AND
        AccountingPeriod LIKE '[0-9][0-9][0-9][0-9]-[0-1][0-9]'
    ),
    CONSTRAINT UQ_BudgetData UNIQUE (ShipCode, AccountNumber, AccountingPeriod)
);
GO

CREATE INDEX IX_BudgetData_ShipPeriod ON dbo.BudgetData(ShipCode, AccountingPeriod);
CREATE INDEX IX_BudgetData_Account ON dbo.BudgetData(AccountNumber);
GO

-- =============================================
-- Table: AccountTransactions (Actuals)
-- =============================================
CREATE TABLE dbo.AccountTransactions (
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    ShipCode NVARCHAR(20) NOT NULL,
    AccountNumber NVARCHAR(20) NOT NULL,
    AccountingPeriod NCHAR(7) NOT NULL, -- Format: YYYY-MM
    TransactionAmount DECIMAL(18, 2) NOT NULL,
    TransactionDate DATE NOT NULL,
    Description NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    CONSTRAINT FK_AccountTransactions_Ship FOREIGN KEY (ShipCode) 
        REFERENCES dbo.Ships(ShipCode) ON DELETE CASCADE,
    CONSTRAINT FK_AccountTransactions_Account FOREIGN KEY (AccountNumber) 
        REFERENCES dbo.ChartOfAccounts(AccountNumber),
    CONSTRAINT CHK_AccountTransactions_Amount CHECK (TransactionAmount >= 0),
    CONSTRAINT CHK_AccountTransactions_Period CHECK (
        LEN(AccountingPeriod) = 7 AND
        AccountingPeriod LIKE '[0-9][0-9][0-9][0-9]-[0-1][0-9]'
    )
);
GO

CREATE INDEX IX_AccountTransactions_ShipPeriod ON dbo.AccountTransactions(ShipCode, AccountingPeriod);
CREATE INDEX IX_AccountTransactions_Account ON dbo.AccountTransactions(AccountNumber);
CREATE INDEX IX_AccountTransactions_Date ON dbo.AccountTransactions(TransactionDate);
GO

PRINT 'Tables created successfully!';
GO
