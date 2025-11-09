-- Stored Procedures for Ship Management System
-- SQL Server T-SQL

-- =============================================
-- Helper Function: Calculate Crew Status
-- =============================================
IF OBJECT_ID('dbo.fn_GetCrewStatus', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetCrewStatus;
GO

CREATE FUNCTION dbo.fn_GetCrewStatus(
    @SignOnDate DATE,
    @SignOffDate DATE,
    @EndOfContractDate DATE,
    @AsOfDate DATE
)
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @Status NVARCHAR(20);
    
    -- If signed off, status is "Signed Off"
    IF @SignOffDate IS NOT NULL
    BEGIN
        SET @Status = 'Signed Off';
    END
    -- If sign on date is in the future, status is "Planned"
    ELSE IF @SignOnDate > @AsOfDate
    BEGIN
        SET @Status = 'Planned';
    END
    -- If more than 30 days past end of contract, status is "Relief Due"
    ELSE IF DATEDIFF(DAY, @EndOfContractDate, @AsOfDate) > 30
    BEGIN
        SET @Status = 'Relief Due';
    END
    -- Otherwise, if sign on date is in past and not signed off, status is "Onboard"
    ELSE IF @SignOnDate <= @AsOfDate AND @SignOffDate IS NULL
    BEGIN
        SET @Status = 'Onboard';
    END
    ELSE
    BEGIN
        SET @Status = 'Unknown';
    END
    
    RETURN @Status;
END
GO

-- =============================================
-- Helper Function: Calculate Age from DOB
-- =============================================
IF OBJECT_ID('dbo.fn_CalculateAge', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_CalculateAge;
GO

CREATE FUNCTION dbo.fn_CalculateAge(
    @DateOfBirth DATE,
    @AsOfDate DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Age INT;
    
    SET @Age = DATEDIFF(YEAR, @DateOfBirth, @AsOfDate);
    
    -- Adjust if birthday hasn't occurred this year yet
    IF (MONTH(@AsOfDate) < MONTH(@DateOfBirth)) OR 
       (MONTH(@AsOfDate) = MONTH(@DateOfBirth) AND DAY(@AsOfDate) < DAY(@DateOfBirth))
    BEGIN
        SET @Age = @Age - 1;
    END
    
    RETURN @Age;
END
GO

-- =============================================
-- Stored Procedure: Get Crew List with Pagination, Sorting, and Searching
-- =============================================
IF OBJECT_ID('dbo.usp_GetCrewList', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetCrewList;
GO

CREATE PROCEDURE dbo.usp_GetCrewList
    @ShipCode NVARCHAR(20),
    @AsOfDate DATE = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 20,
    @SortColumn NVARCHAR(50) = 'RankOrder',
    @SortDirection NVARCHAR(4) = 'ASC',
    @SearchTerm NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Default to today if not specified
    IF @AsOfDate IS NULL
        SET @AsOfDate = CAST(GETUTCDATE() AS DATE);
    
    -- Validate pagination parameters
    IF @PageNumber < 1 SET @PageNumber = 1;
    IF @PageSize < 1 SET @PageSize = 20;
    IF @PageSize > 100 SET @PageSize = 100; -- Max page size
    
    -- Validate sort direction
    IF @SortDirection NOT IN ('ASC', 'DESC')
        SET @SortDirection = 'ASC';
    
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
    
    ;WITH CrewData AS (
        SELECT 
            r.RankName,
            r.RankOrder,
            c.CrewId,
            c.FirstName,
            c.LastName,
            dbo.fn_CalculateAge(c.DateOfBirth, @AsOfDate) AS Age,
            c.Nationality,
            csh.SignOnDate,
            dbo.fn_GetCrewStatus(csh.SignOnDate, csh.SignOffDate, csh.EndOfContractDate, @AsOfDate) AS Status,
            -- For searching with date formatting
            FORMAT(csh.SignOnDate, 'dd MMM yyyy') AS SignOnDateFormatted,
            FORMAT(csh.SignOnDate, 'dd MMM') AS SignOnDateShort
        FROM 
            dbo.CrewServiceHistory csh
            INNER JOIN dbo.CrewMembers c ON csh.CrewId = c.CrewId
            INNER JOIN dbo.CrewRanks r ON csh.RankId = r.RankId
        WHERE 
            csh.ShipCode = @ShipCode
            AND csh.SignOffDate IS NULL  -- Exclude signed off crew
            AND dbo.fn_GetCrewStatus(csh.SignOnDate, csh.SignOffDate, csh.EndOfContractDate, @AsOfDate) IN ('Onboard', 'Relief Due')
    ),
    FilteredData AS (
        SELECT *
        FROM CrewData
        WHERE 
            @SearchTerm IS NULL OR
            (
                RankName LIKE '%' + @SearchTerm + '%' OR
                CrewId LIKE '%' + @SearchTerm + '%' OR
                FirstName LIKE '%' + @SearchTerm + '%' OR
                LastName LIKE '%' + @SearchTerm + '%' OR
                Nationality LIKE '%' + @SearchTerm + '%' OR
                SignOnDateFormatted LIKE '%' + @SearchTerm + '%' OR
                SignOnDateShort LIKE '%' + @SearchTerm + '%' OR
                CAST(Age AS NVARCHAR) LIKE '%' + @SearchTerm + '%'
            )
    ),
    TotalCount AS (
        SELECT COUNT(*) AS TotalRecords FROM FilteredData
    )
    SELECT 
        fd.RankName,
        fd.CrewId,
        fd.FirstName,
        fd.LastName,
        fd.Age,
        fd.Nationality,
        fd.SignOnDate,
        fd.SignOnDateFormatted,
        fd.Status,
        tc.TotalRecords,
        CEILING(CAST(tc.TotalRecords AS FLOAT) / @PageSize) AS TotalPages,
        @PageNumber AS CurrentPage,
        @PageSize AS PageSize
    FROM 
        FilteredData fd
        CROSS JOIN TotalCount tc
    ORDER BY
        CASE WHEN @SortColumn = 'RankName' AND @SortDirection = 'ASC' THEN fd.RankOrder END ASC,
        CASE WHEN @SortColumn = 'RankName' AND @SortDirection = 'DESC' THEN fd.RankOrder END DESC,
        CASE WHEN @SortColumn = 'CrewId' AND @SortDirection = 'ASC' THEN fd.CrewId END ASC,
        CASE WHEN @SortColumn = 'CrewId' AND @SortDirection = 'DESC' THEN fd.CrewId END DESC,
        CASE WHEN @SortColumn = 'FirstName' AND @SortDirection = 'ASC' THEN fd.FirstName END ASC,
        CASE WHEN @SortColumn = 'FirstName' AND @SortDirection = 'DESC' THEN fd.FirstName END DESC,
        CASE WHEN @SortColumn = 'LastName' AND @SortDirection = 'ASC' THEN fd.LastName END ASC,
        CASE WHEN @SortColumn = 'LastName' AND @SortDirection = 'DESC' THEN fd.LastName END DESC,
        CASE WHEN @SortColumn = 'Age' AND @SortDirection = 'ASC' THEN fd.Age END ASC,
        CASE WHEN @SortColumn = 'Age' AND @SortDirection = 'DESC' THEN fd.Age END DESC,
        CASE WHEN @SortColumn = 'Nationality' AND @SortDirection = 'ASC' THEN fd.Nationality END ASC,
        CASE WHEN @SortColumn = 'Nationality' AND @SortDirection = 'DESC' THEN fd.Nationality END DESC,
        CASE WHEN @SortColumn = 'SignOnDate' AND @SortDirection = 'ASC' THEN fd.SignOnDate END ASC,
        CASE WHEN @SortColumn = 'SignOnDate' AND @SortDirection = 'DESC' THEN fd.SignOnDate END DESC,
        CASE WHEN @SortColumn = 'Status' AND @SortDirection = 'ASC' THEN fd.Status END ASC,
        CASE WHEN @SortColumn = 'Status' AND @SortDirection = 'DESC' THEN fd.Status END DESC,
        -- Default sort by rank order if column not matched
        fd.RankOrder ASC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
GO

PRINT 'Crew list stored procedure created';
GO

-- =============================================
-- Helper Function: Get Fiscal Year Start Month
-- =============================================
IF OBJECT_ID('dbo.fn_GetFiscalYearStartMonth', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_GetFiscalYearStartMonth;
GO

CREATE FUNCTION dbo.fn_GetFiscalYearStartMonth(@FiscalYearCode NCHAR(4))
RETURNS INT
AS
BEGIN
    RETURN CAST(SUBSTRING(@FiscalYearCode, 1, 2) AS INT);
END
GO

-- =============================================
-- Helper Function: Calculate YTD Period Range
-- Returns table with periods for YTD calculation
-- =============================================
IF OBJECT_ID('dbo.fn_GetYTDPeriods', 'IF') IS NOT NULL
    DROP FUNCTION dbo.fn_GetYTDPeriods;
GO

CREATE FUNCTION dbo.fn_GetYTDPeriods(
    @Period NCHAR(7),  -- Format: YYYY-MM
    @FiscalYearCode NCHAR(4) -- Format: MMDD (e.g., '0112', '0403')
)
RETURNS TABLE
AS
RETURN
(
    WITH PeriodInfo AS (
        SELECT 
            CAST(LEFT(@Period, 4) AS INT) AS PeriodYear,
            CAST(RIGHT(@Period, 2) AS INT) AS PeriodMonth,
            CAST(SUBSTRING(@FiscalYearCode, 1, 2) AS INT) AS FYStartMonth
    ),
    FiscalYearCalc AS (
        SELECT 
            PeriodYear,
            PeriodMonth,
            FYStartMonth,
            -- Calculate fiscal year start date
            CASE 
                WHEN PeriodMonth >= FYStartMonth THEN 
                    DATEFROMPARTS(PeriodYear, FYStartMonth, 1)
                ELSE 
                    DATEFROMPARTS(PeriodYear - 1, FYStartMonth, 1)
            END AS FYStartDate,
            DATEFROMPARTS(PeriodYear, PeriodMonth, 1) AS CurrentPeriodDate
        FROM PeriodInfo
    ),
    Numbers AS (
        -- Recursive CTE to generate numbers 0-12
        SELECT 0 AS num
        UNION ALL
        SELECT num + 1
        FROM Numbers
        WHERE num < 12
    ),
    MonthSequence AS (
        SELECT 
            FORMAT(DATEADD(MONTH, n.num, fyc.FYStartDate), 'yyyy-MM') AS AccountingPeriod,
            n.num AS MonthOffset
        FROM FiscalYearCalc fyc
        CROSS JOIN Numbers n
        WHERE n.num <= DATEDIFF(MONTH, fyc.FYStartDate, fyc.CurrentPeriodDate)
    )
    SELECT AccountingPeriod
    FROM MonthSequence
);
GO

-- ==============================================
-- Stored Procedure: Get Financial Report - Detail View
-- =============================================
IF OBJECT_ID('dbo.usp_GetFinancialReportDetail', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetFinancialReportDetail;
GO

CREATE PROCEDURE dbo.usp_GetFinancialReportDetail
    @ShipCode NVARCHAR(20),
    @Period NCHAR(7) -- Format: YYYY-MM
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get fiscal year code for the ship
    DECLARE @FiscalYearCode NCHAR(4);
    SELECT @FiscalYearCode = FiscalYearCode 
    FROM dbo.Ships 
    WHERE ShipCode = @ShipCode;
    
    IF @FiscalYearCode IS NULL
    BEGIN
        RAISERROR('Ship code not found', 16, 1);
        RETURN;
    END
    
    ;WITH 
    -- Current period actuals
    PeriodActuals AS (
        SELECT 
            AccountNumber,
            SUM(TransactionAmount) AS ActualAmount
        FROM dbo.AccountTransactions
        WHERE ShipCode = @ShipCode
          AND AccountingPeriod = @Period
        GROUP BY AccountNumber
    ),
    -- Current period budget
    PeriodBudget AS (
        SELECT 
            AccountNumber,
            SUM(BudgetAmount) AS BudgetAmount
        FROM dbo.BudgetData
        WHERE ShipCode = @ShipCode
          AND AccountingPeriod = @Period
        GROUP BY AccountNumber
    ),
    -- YTD Actuals
    YTDActuals AS (
        SELECT 
            at.AccountNumber,
            SUM(at.TransactionAmount) AS YTDActualAmount
        FROM dbo.AccountTransactions at
        WHERE at.ShipCode = @ShipCode
          AND at.AccountingPeriod IN (
              SELECT AccountingPeriod 
              FROM dbo.fn_GetYTDPeriods(@Period, @FiscalYearCode)
          )
        GROUP BY at.AccountNumber
    ),
    -- YTD Budget
    YTDBudget AS (
        SELECT 
            bd.AccountNumber,
            SUM(bd.BudgetAmount) AS YTDBudgetAmount
        FROM dbo.BudgetData bd
        WHERE bd.ShipCode = @ShipCode
          AND bd.AccountingPeriod IN (
              SELECT AccountingPeriod 
              FROM dbo.fn_GetYTDPeriods(@Period, @FiscalYearCode)
          )
        GROUP BY bd.AccountNumber
    )
    SELECT 
        coa.AccountDescription AS COADescription,
        coa.AccountNumber,
        ISNULL(pa.ActualAmount, 0) AS PeriodActual,
        ISNULL(pb.BudgetAmount, 0) AS PeriodBudget,
        ISNULL(pa.ActualAmount, 0) - ISNULL(pb.BudgetAmount, 0) AS PeriodVariance,
        ISNULL(ytda.YTDActualAmount, 0) AS YTDActual,
        ISNULL(ytdb.YTDBudgetAmount, 0) AS YTDBudget,
        ISNULL(ytda.YTDActualAmount, 0) - ISNULL(ytdb.YTDBudgetAmount, 0) AS YTDVariance
    FROM dbo.ChartOfAccounts coa
    LEFT JOIN PeriodActuals pa ON coa.AccountNumber = pa.AccountNumber
    LEFT JOIN PeriodBudget pb ON coa.AccountNumber = pb.AccountNumber
    LEFT JOIN YTDActuals ytda ON coa.AccountNumber = ytda.AccountNumber
    LEFT JOIN YTDBudget ytdb ON coa.AccountNumber = ytdb.AccountNumber
    WHERE (ISNULL(pa.ActualAmount, 0) <> 0 OR ISNULL(pb.BudgetAmount, 0) <> 0 OR 
           ISNULL(ytda.YTDActualAmount, 0) <> 0 OR ISNULL(ytdb.YTDBudgetAmount, 0) <> 0)
      AND coa.AccountType = 'Child' -- Only show child accounts (leaf accounts)
    ORDER BY coa.AccountNumber;
END
GO

PRINT 'Financial report detail stored procedure created';
GO

-- =============================================
-- Stored Procedure: Get Financial Report - Summary View
-- =============================================
IF OBJECT_ID('dbo.usp_GetFinancialReportSummary', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_GetFinancialReportSummary;
GO

CREATE PROCEDURE dbo.usp_GetFinancialReportSummary
    @ShipCode NVARCHAR(20),
    @Period NCHAR(7) -- Format: YYYY-MM
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Get fiscal year code for the ship
    DECLARE @FiscalYearCode NCHAR(4);
    SELECT @FiscalYearCode = FiscalYearCode 
    FROM dbo.Ships 
    WHERE ShipCode = @ShipCode;
    
    IF @FiscalYearCode IS NULL
    BEGIN
        RAISERROR('Ship code not found', 16, 1);
        RETURN;
    END
    
    -- Return only top-level parent accounts (summary view)
    ;WITH ChildAccountData AS (
        SELECT 
            coa.ParentAccountNumber,
            ISNULL(SUM(at.TransactionAmount), 0) AS PeriodActual,
            ISNULL(SUM(bd.BudgetAmount), 0) AS PeriodBudget
        FROM dbo.ChartOfAccounts coa
        LEFT JOIN dbo.AccountTransactions at ON coa.AccountNumber = at.AccountNumber 
            AND at.ShipCode = @ShipCode AND at.AccountingPeriod = @Period
        LEFT JOIN dbo.BudgetData bd ON coa.AccountNumber = bd.AccountNumber 
            AND bd.ShipCode = @ShipCode AND bd.AccountingPeriod = @Period
        WHERE coa.AccountType = 'Child'
        GROUP BY coa.ParentAccountNumber
    ),
    YTDChildAccountData AS (
        SELECT 
            coa.ParentAccountNumber,
            ISNULL(SUM(at.TransactionAmount), 0) AS YTDActual,
            ISNULL(SUM(bd.BudgetAmount), 0) AS YTDBudget
        FROM dbo.ChartOfAccounts coa
        LEFT JOIN dbo.AccountTransactions at ON coa.AccountNumber = at.AccountNumber 
            AND at.ShipCode = @ShipCode 
            AND at.AccountingPeriod IN (SELECT AccountingPeriod FROM dbo.fn_GetYTDPeriods(@Period, @FiscalYearCode))
        LEFT JOIN dbo.BudgetData bd ON coa.AccountNumber = bd.AccountNumber 
            AND bd.ShipCode = @ShipCode 
            AND bd.AccountingPeriod IN (SELECT AccountingPeriod FROM dbo.fn_GetYTDPeriods(@Period, @FiscalYearCode))
        WHERE coa.AccountType = 'Child'
        GROUP BY coa.ParentAccountNumber
    )
    SELECT 
        coa.AccountDescription AS COADescription,
        coa.AccountNumber,
        ISNULL(SUM(cad.PeriodActual), 0) AS PeriodActual,
        ISNULL(SUM(cad.PeriodBudget), 0) AS PeriodBudget,
        ISNULL(SUM(cad.PeriodActual), 0) - ISNULL(SUM(cad.PeriodBudget), 0) AS PeriodVariance,
        ISNULL(SUM(ytd.YTDActual), 0) AS YTDActual,
        ISNULL(SUM(ytd.YTDBudget), 0) AS YTDBudget,
        ISNULL(SUM(ytd.YTDActual), 0) - ISNULL(SUM(ytd.YTDBudget), 0) AS YTDVariance
    FROM dbo.ChartOfAccounts coa
    LEFT JOIN ChildAccountData cad ON coa.AccountNumber = cad.ParentAccountNumber 
        OR coa.AccountNumber IN (SELECT ParentAccountNumber FROM dbo.ChartOfAccounts WHERE AccountNumber = cad.ParentAccountNumber)
    LEFT JOIN YTDChildAccountData ytd ON coa.AccountNumber = ytd.ParentAccountNumber
        OR coa.AccountNumber IN (SELECT ParentAccountNumber FROM dbo.ChartOfAccounts WHERE AccountNumber = ytd.ParentAccountNumber)
    WHERE coa.ParentAccountNumber IS NULL -- Top-level parents only
      AND coa.AccountType = 'Parent'
    GROUP BY coa.AccountDescription, coa.AccountNumber
    HAVING ISNULL(SUM(cad.PeriodBudget), 0) > 0 OR ISNULL(SUM(cad.PeriodActual), 0) > 0
    ORDER BY coa.AccountNumber;
END
GO

PRINT 'Financial report summary stored procedure created';
GO

PRINT 'All stored procedures created successfully!';
GO
