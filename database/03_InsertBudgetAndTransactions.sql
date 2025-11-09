-- Insert Budget and Transaction Data
-- SQL Server T-SQL

-- =============================================
-- Insert Budget Data for SHIP01 (Flying Dutchman)
-- Fiscal Year: 0112 (Jan-Dec)
-- =============================================
DECLARE @ship1 NVARCHAR(20) = 'SHIP01';
DECLARE @year INT = 2024;
DECLARE @period INT;

-- Budget for 2024 (full year)
SET @period = 1;
WHILE @period <= 12
BEGIN
    INSERT INTO dbo.BudgetData (ShipCode, AccountNumber, AccountingPeriod, BudgetAmount) VALUES
    (@ship1, '7120000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 1000 + (@period * 10)),
    (@ship1, '7135000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 2200 + (@period * 50)),
    (@ship1, '7210000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 1500 + (@period * 30)),
    (@ship1, '7230000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 800 + (@period * 20)),
    (@ship1, '7310000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 500 + (@period * 15)),
    (@ship1, '6110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 15000 + (@period * 100)),
    (@ship1, '6120000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 12000 + (@period * 80)),
    (@ship1, '5110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 25000 + (@period * 200)),
    (@ship1, '9110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 3000 + (@period * 50)),
    (@ship1, '8310000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 1200 + (@period * 25));
    
    SET @period = @period + 1;
END

-- Budget for 2025 (full year)
SET @year = 2025;
SET @period = 1;
WHILE @period <= 12
BEGIN
    INSERT INTO dbo.BudgetData (ShipCode, AccountNumber, AccountingPeriod, BudgetAmount) VALUES
    (@ship1, '7120000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 1100 + (@period * 10)),
    (@ship1, '7135000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 2300 + (@period * 50)),
    (@ship1, '7210000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 1600 + (@period * 30)),
    (@ship1, '7230000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 900 + (@period * 20)),
    (@ship1, '7310000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 600 + (@period * 15)),
    (@ship1, '6110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 16000 + (@period * 100)),
    (@ship1, '6120000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 13000 + (@period * 80)),
    (@ship1, '5110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 26000 + (@period * 200)),
    (@ship1, '9110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 3200 + (@period * 50)),
    (@ship1, '8310000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 1300 + (@period * 25));
    
    SET @period = @period + 1;
END

PRINT 'Budget data for SHIP01 inserted';
GO

-- =============================================
-- Insert Budget Data for SHIP02 (Thousand Sunny)
-- Fiscal Year: 0403 (Apr-Mar)
-- =============================================
DECLARE @ship2 NVARCHAR(20) = 'SHIP02';
DECLARE @year INT;
DECLARE @period INT;

-- Budget for FY 2024-2025 (Apr 2024 to Mar 2025)
SET @period = 4; -- April
WHILE @period <= 12
BEGIN
    INSERT INTO dbo.BudgetData (ShipCode, AccountNumber, AccountingPeriod, BudgetAmount) VALUES
    (@ship2, '7120000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 950 + (@period * 10)),
    (@ship2, '7135000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 2100 + (@period * 50)),
    (@ship2, '7210000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 1450 + (@period * 30)),
    (@ship2, '7230000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 780 + (@period * 20)),
    (@ship2, '7310000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 480 + (@period * 15)),
    (@ship2, '6110000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 14500 + (@period * 100)),
    (@ship2, '6120000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 11500 + (@period * 80)),
    (@ship2, '5110000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 24000 + (@period * 200)),
    (@ship2, '9110000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 2900 + (@period * 50)),
    (@ship2, '8310000', FORMAT(DATEFROMPARTS(2024, @period, 1), 'yyyy-MM'), 1150 + (@period * 25));
    
    SET @period = @period + 1;
END

SET @period = 1; -- January
WHILE @period <= 3
BEGIN
    INSERT INTO dbo.BudgetData (ShipCode, AccountNumber, AccountingPeriod, BudgetAmount) VALUES
    (@ship2, '7120000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 950 + (@period * 10)),
    (@ship2, '7135000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 2100 + (@period * 50)),
    (@ship2, '7210000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 1450 + (@period * 30)),
    (@ship2, '7230000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 780 + (@period * 20)),
    (@ship2, '7310000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 480 + (@period * 15)),
    (@ship2, '6110000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 14500 + (@period * 100)),
    (@ship2, '6120000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 11500 + (@period * 80)),
    (@ship2, '5110000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 24000 + (@period * 200)),
    (@ship2, '9110000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 2900 + (@period * 50)),
    (@ship2, '8310000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 1150 + (@period * 25));
    
    SET @period = @period + 1;
END

-- Budget for FY 2025-2026 (Apr 2025 to Mar 2026)
SET @period = 4; -- April
WHILE @period <= 12
BEGIN
    INSERT INTO dbo.BudgetData (ShipCode, AccountNumber, AccountingPeriod, BudgetAmount) VALUES
    (@ship2, '7120000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 1000 + (@period * 10)),
    (@ship2, '7135000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 2200 + (@period * 50)),
    (@ship2, '7210000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 1500 + (@period * 30)),
    (@ship2, '7230000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 800 + (@period * 20)),
    (@ship2, '7310000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 500 + (@period * 15)),
    (@ship2, '6110000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 15000 + (@period * 100)),
    (@ship2, '6120000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 12000 + (@period * 80)),
    (@ship2, '5110000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 25000 + (@period * 200)),
    (@ship2, '9110000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 3000 + (@period * 50)),
    (@ship2, '8310000', FORMAT(DATEFROMPARTS(2025, @period, 1), 'yyyy-MM'), 1200 + (@period * 25));
    
    SET @period = @period + 1;
END

PRINT 'Budget data for SHIP02 inserted';
GO

-- =============================================
-- Insert Budget Data for SHIP03 (Black Pearl)
-- Fiscal Year: 0112 (Jan-Dec)
-- =============================================
DECLARE @ship3 NVARCHAR(20) = 'SHIP03';
DECLARE @year INT;
DECLARE @period INT;

-- Budget for 2024 and 2025
DECLARE @years TABLE (yr INT);
INSERT INTO @years VALUES (2024), (2025);

DECLARE year_cursor CURSOR FOR SELECT yr FROM @years;
OPEN year_cursor;

FETCH NEXT FROM year_cursor INTO @year;
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @period = 1;
    WHILE @period <= 12
    BEGIN
        INSERT INTO dbo.BudgetData (ShipCode, AccountNumber, AccountingPeriod, BudgetAmount) VALUES
        (@ship3, '7120000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 980 + (@period * 12)),
        (@ship3, '7135000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 2150 + (@period * 48)),
        (@ship3, '7210000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 1520 + (@period * 28)),
        (@ship3, '7230000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 820 + (@period * 18)),
        (@ship3, '7310000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 520 + (@period * 14)),
        (@ship3, '6110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 14800 + (@period * 95)),
        (@ship3, '6120000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 11800 + (@period * 75)),
        (@ship3, '5110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 24500 + (@period * 180)),
        (@ship3, '9110000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 2950 + (@period * 48)),
        (@ship3, '8310000', FORMAT(DATEFROMPARTS(@year, @period, 1), 'yyyy-MM'), 1180 + (@period * 22));
        
        SET @period = @period + 1;
    END
    
    FETCH NEXT FROM year_cursor INTO @year;
END

CLOSE year_cursor;
DEALLOCATE year_cursor;

PRINT 'Budget data for SHIP03 inserted';
GO

PRINT 'All budget data inserted successfully!';
GO

-- =============================================
-- Insert Account Transactions (Actuals) for SHIP01
-- =============================================
DECLARE @ship1 NVARCHAR(20) = 'SHIP01';

-- Transactions for 2024 (full year)
DECLARE @month INT = 1;
WHILE @month <= 12
BEGIN
    DECLARE @periodStr NCHAR(7) = FORMAT(DATEFROMPARTS(2024, @month, 1), 'yyyy-MM');
    DECLARE @baseDate DATE = DATEFROMPARTS(2024, @month, 1);
    
    -- Multiple transactions per period for each account
    INSERT INTO dbo.AccountTransactions (ShipCode, AccountNumber, AccountingPeriod, TransactionAmount, TransactionDate, Description) VALUES
    (@ship1, '7120000', @periodStr, 300 + (@month * 8), DATEADD(DAY, 5, @baseDate), 'Monthly awards'),
    (@ship1, '7120000', @periodStr, 450 + (@month * 7), DATEADD(DAY, 15, @baseDate), 'Performance awards'),
    (@ship1, '7120000', @periodStr, 200 + (@month * 5), DATEADD(DAY, 25, @baseDate), 'Special recognition'),
    
    (@ship1, '7135000', @periodStr, 700 + (@month * 15), DATEADD(DAY, 3, @baseDate), 'Crew scholarships Q' + CAST((@month-1)/3 + 1 AS VARCHAR)),
    (@ship1, '7135000', @periodStr, 850 + (@month * 18), DATEADD(DAY, 18, @baseDate), 'Training scholarships'),
    (@ship1, '7135000', @periodStr, 600 + (@month * 12), DATEADD(DAY, 28, @baseDate), 'Educational support'),
    
    (@ship1, '7210000', @periodStr, 500 + (@month * 10), DATEADD(DAY, 2, @baseDate), 'Deck supplies purchase'),
    (@ship1, '7210000', @periodStr, 650 + (@month * 12), DATEADD(DAY, 14, @baseDate), 'Equipment order'),
    (@ship1, '7210000', @periodStr, 300 + (@month * 8), DATEADD(DAY, 22, @baseDate), 'Consumables'),
    
    (@ship1, '6110000', @periodStr, 15200 + (@month * 80), @baseDate, 'Officer salaries'),
    (@ship1, '6120000', @periodStr, 12100 + (@month * 60), @baseDate, 'Rating wages'),
    (@ship1, '5110000', @periodStr, 24800 + (@month * 150), DATEADD(DAY, 10, @baseDate), 'Fuel bunker'),
    (@ship1, '5110000', @periodStr, 0, DATEADD(DAY, 20, @baseDate), 'Fuel adjustment'),
    (@ship1, '9110000', @periodStr, 2850 + (@month * 40), DATEADD(DAY, 12, @baseDate), 'Engine parts');
    
    SET @month = @month + 1;
END

-- Transactions for 2025 (at least 6 periods)
SET @month = 1;
WHILE @month <= 10
BEGIN
    SET @periodStr = FORMAT(DATEFROMPARTS(2025, @month, 1), 'yyyy-MM');
    SET @baseDate = DATEFROMPARTS(2025, @month, 1);
    
    INSERT INTO dbo.AccountTransactions (ShipCode, AccountNumber, AccountingPeriod, TransactionAmount, TransactionDate, Description) VALUES
    (@ship1, '7120000', @periodStr, 320 + (@month * 8), DATEADD(DAY, 5, @baseDate), 'Monthly awards'),
    (@ship1, '7120000', @periodStr, 470 + (@month * 7), DATEADD(DAY, 15, @baseDate), 'Performance awards'),
    (@ship1, '7120000', @periodStr, 210 + (@month * 5), DATEADD(DAY, 25, @baseDate), 'Special recognition'),
    
    (@ship1, '7135000', @periodStr, 720 + (@month * 15), DATEADD(DAY, 3, @baseDate), 'Crew scholarships Q' + CAST((@month-1)/3 + 1 AS VARCHAR)),
    (@ship1, '7135000', @periodStr, 870 + (@month * 18), DATEADD(DAY, 18, @baseDate), 'Training scholarships'),
    (@ship1, '7135000', @periodStr, 610 + (@month * 12), DATEADD(DAY, 28, @baseDate), 'Educational support'),
    
    (@ship1, '7210000', @periodStr, 520 + (@month * 10), DATEADD(DAY, 2, @baseDate), 'Deck supplies'),
    (@ship1, '7210000', @periodStr, 670 + (@month * 12), DATEADD(DAY, 14, @baseDate), 'Equipment'),
    (@ship1, '7210000', @periodStr, 310 + (@month * 8), DATEADD(DAY, 22, @baseDate), 'Consumables'),
    
    (@ship1, '7230000', @periodStr, 450 + (@month * 9), DATEADD(DAY, 4, @baseDate), 'Galley supplies'),
    (@ship1, '7230000', @periodStr, 380 + (@month * 7), DATEADD(DAY, 16, @baseDate), 'Food provisions'),
    
    (@ship1, '7310000', @periodStr, 290 + (@month * 6), DATEADD(DAY, 1, @baseDate), 'Electricity bill'),
    (@ship1, '7310000', @periodStr, 320 + (@month * 8), DATEADD(DAY, 20, @baseDate), 'Port utility fees'),
    
    (@ship1, '6110000', @periodStr, 16100 + (@month * 85), @baseDate, 'Officer salaries'),
    (@ship1, '6120000', @periodStr, 13050 + (@month * 65), @baseDate, 'Rating wages'),
    (@ship1, '5110000', @periodStr, 25900 + (@month * 160), DATEADD(DAY, 10, @baseDate), 'Fuel bunker'),
    (@ship1, '5110000', @periodStr, 0, DATEADD(DAY, 20, @baseDate), 'Fuel credit note'),
    (@ship1, '9110000', @periodStr, 3100 + (@month * 42), DATEADD(DAY, 12, @baseDate), 'Engine maintenance'),
    (@ship1, '8310000', @periodStr, 650 + (@month * 11), DATEADD(DAY, 8, @baseDate), 'Crew training');
    
    SET @month = @month + 1;
END

PRINT 'Transaction data for SHIP01 inserted';
GO

-- =============================================
-- Insert Account Transactions for SHIP02
-- =============================================
DECLARE @ship2 NVARCHAR(20) = 'SHIP02';

-- Transactions for 2024 (Apr-Dec)
DECLARE @month INT = 4;
WHILE @month <= 12
BEGIN
    DECLARE @periodStr NCHAR(7) = FORMAT(DATEFROMPARTS(2024, @month, 1), 'yyyy-MM');
    DECLARE @baseDate DATE = DATEFROMPARTS(2024, @month, 1);
    
    INSERT INTO dbo.AccountTransactions (ShipCode, AccountNumber, AccountingPeriod, TransactionAmount, TransactionDate, Description) VALUES
    (@ship2, '7120000', @periodStr, 290 + (@month * 7), DATEADD(DAY, 5, @baseDate), 'Awards distribution'),
    (@ship2, '7120000', @periodStr, 420 + (@month * 6), DATEADD(DAY, 15, @baseDate), 'Performance bonus'),
    
    (@ship2, '7135000', @periodStr, 680 + (@month * 14), DATEADD(DAY, 3, @baseDate), 'Scholarships'),
    (@ship2, '7135000', @periodStr, 810 + (@month * 16), DATEADD(DAY, 18, @baseDate), 'Educational grants'),
    
    (@ship2, '7210000', @periodStr, 480 + (@month * 9), DATEADD(DAY, 2, @baseDate), 'Deck supplies'),
    (@ship2, '7210000', @periodStr, 620 + (@month * 11), DATEADD(DAY, 14, @baseDate), 'Equipment'),
    
    (@ship2, '6110000', @periodStr, 14600 + (@month * 85), @baseDate, 'Officer salaries'),
    (@ship2, '6120000', @periodStr, 11600 + (@month * 65), @baseDate, 'Rating wages'),
    (@ship2, '5110000', @periodStr, 24100 + (@month * 170), DATEADD(DAY, 10, @baseDate), 'Bunker fuel'),
    (@ship2, '9110000', @periodStr, 2800 + (@month * 45), DATEADD(DAY, 12, @baseDate), 'Engine spares');
    
    SET @month = @month + 1;
END

-- Transactions for 2025 (Jan-Oct)
SET @month = 1;
WHILE @month <= 10
BEGIN
    SET @periodStr = FORMAT(DATEFROMPARTS(2025, @month, 1), 'yyyy-MM');
    SET @baseDate = DATEFROMPARTS(2025, @month, 1);
    
    INSERT INTO dbo.AccountTransactions (ShipCode, AccountNumber, AccountingPeriod, TransactionAmount, TransactionDate, Description) VALUES
    (@ship2, '7120000', @periodStr, 300 + (@month * 7), DATEADD(DAY, 5, @baseDate), 'Awards'),
    (@ship2, '7120000', @periodStr, 430 + (@month * 6), DATEADD(DAY, 15, @baseDate), 'Incentives'),
    
    (@ship2, '7135000', @periodStr, 690 + (@month * 14), DATEADD(DAY, 3, @baseDate), 'Scholarships'),
    (@ship2, '7135000', @periodStr, 820 + (@month * 16), DATEADD(DAY, 18, @baseDate), 'Training support'),
    
    (@ship2, '7210000', @periodStr, 490 + (@month * 9), DATEADD(DAY, 2, @baseDate), 'Supplies'),
    (@ship2, '7210000', @periodStr, 630 + (@month * 11), DATEADD(DAY, 14, @baseDate), 'Materials'),
    
    (@ship2, '7230000', @periodStr, 410 + (@month * 8), DATEADD(DAY, 4, @baseDate), 'Galley provisions'),
    (@ship2, '7310000', @periodStr, 270 + (@month * 6), DATEADD(DAY, 1, @baseDate), 'Utilities'),
    
    (@ship2, '6110000', @periodStr, 15100 + (@month * 90), @baseDate, 'Officer wages'),
    (@ship2, '6120000', @periodStr, 12100 + (@month * 70), @baseDate, 'Crew wages'),
    (@ship2, '5110000', @periodStr, 25200 + (@month * 180), DATEADD(DAY, 10, @baseDate), 'Fuel'),
    (@ship2, '9110000', @periodStr, 2950 + (@month * 47), DATEADD(DAY, 12, @baseDate), 'Maintenance'),
    (@ship2, '8310000', @periodStr, 600 + (@month * 10), DATEADD(DAY, 8, @baseDate), 'Training');
    
    SET @month = @month + 1;
END

PRINT 'Transaction data for SHIP02 inserted';
GO

-- =============================================
-- Insert Account Transactions for SHIP03
-- =============================================
DECLARE @ship3 NVARCHAR(20) = 'SHIP03';

-- Transactions for 2024 (full year)
DECLARE @month INT = 1;
WHILE @month <= 12
BEGIN
    DECLARE @periodStr NCHAR(7) = FORMAT(DATEFROMPARTS(2024, @month, 1), 'yyyy-MM');
    DECLARE @baseDate DATE = DATEFROMPARTS(2024, @month, 1);
    
    INSERT INTO dbo.AccountTransactions (ShipCode, AccountNumber, AccountingPeriod, TransactionAmount, TransactionDate, Description) VALUES
    (@ship3, '7120000', @periodStr, 285 + (@month * 7), DATEADD(DAY, 5, @baseDate), 'Monthly awards'),
    (@ship3, '7120000', @periodStr, 415 + (@month * 6), DATEADD(DAY, 15, @baseDate), 'Bonuses'),
    
    (@ship3, '7135000', @periodStr, 675 + (@month * 13), DATEADD(DAY, 3, @baseDate), 'Scholarships'),
    (@ship3, '7135000', @periodStr, 805 + (@month * 15), DATEADD(DAY, 18, @baseDate), 'Educational aid'),
    
    (@ship3, '7210000', @periodStr, 475 + (@month * 9), DATEADD(DAY, 2, @baseDate), 'Deck items'),
    (@ship3, '7210000', @periodStr, 615 + (@month * 10), DATEADD(DAY, 14, @baseDate), 'Supplies'),
    
    (@ship3, '6110000', @periodStr, 14900 + (@month * 80), @baseDate, 'Officer pay'),
    (@ship3, '6120000', @periodStr, 11900 + (@month * 60), @baseDate, 'Crew pay'),
    (@ship3, '5110000', @periodStr, 24600 + (@month * 155), DATEADD(DAY, 10, @baseDate), 'Fuel oil'),
    (@ship3, '9110000', @periodStr, 2850 + (@month * 42), DATEADD(DAY, 12, @baseDate), 'Engine parts');
    
    SET @month = @month + 1;
END

-- Transactions for 2025 (at least 6 periods)
SET @month = 1;
WHILE @month <= 10
BEGIN
    SET @periodStr = FORMAT(DATEFROMPARTS(2025, @month, 1), 'yyyy-MM');
    SET @baseDate = DATEFROMPARTS(2025, @month, 1);
    
    INSERT INTO dbo.AccountTransactions (ShipCode, AccountNumber, AccountingPeriod, TransactionAmount, TransactionDate, Description) VALUES
    (@ship3, '7120000', @periodStr, 295 + (@month * 7), DATEADD(DAY, 5, @baseDate), 'Awards'),
    (@ship3, '7120000', @periodStr, 425 + (@month * 6), DATEADD(DAY, 15, @baseDate), 'Recognition'),
    
    (@ship3, '7135000', @periodStr, 685 + (@month * 13), DATEADD(DAY, 3, @baseDate), 'Scholarships'),
    (@ship3, '7135000', @periodStr, 815 + (@month * 15), DATEADD(DAY, 18, @baseDate), 'Training fund'),
    
    (@ship3, '7210000', @periodStr, 485 + (@month * 9), DATEADD(DAY, 2, @baseDate), 'Supplies'),
    (@ship3, '7210000', @periodStr, 625 + (@month * 10), DATEADD(DAY, 14, @baseDate), 'Equipment'),
    
    (@ship3, '7230000', @periodStr, 405 + (@month * 8), DATEADD(DAY, 4, @baseDate), 'Galley'),
    (@ship3, '7310000', @periodStr, 265 + (@month * 6), DATEADD(DAY, 1, @baseDate), 'Power'),
    
    (@ship3, '6110000', @periodStr, 14980 + (@month * 82), @baseDate, 'Officers'),
    (@ship3, '6120000', @periodStr, 11980 + (@month * 62), @baseDate, 'Ratings'),
    (@ship3, '5110000', @periodStr, 24750 + (@month * 158), DATEADD(DAY, 10, @baseDate), 'Bunkers'),
    (@ship3, '9110000', @periodStr, 2900 + (@month * 43), DATEADD(DAY, 12, @baseDate), 'Spare parts'),
    (@ship3, '8310000', @periodStr, 590 + (@month * 10), DATEADD(DAY, 8, @baseDate), 'Crew development');
    
    SET @month = @month + 1;
END

PRINT 'Transaction data for SHIP03 inserted';
GO

PRINT 'All transaction data inserted successfully!';
PRINT 'Budget and Transaction data insertion completed!';
GO
