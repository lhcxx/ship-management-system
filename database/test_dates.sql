-- Test individual inserts to find the problem

-- This should work
BEGIN TRY
    INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) 
    VALUES ('TESTCREW001', 'SHIP01', 1, '2025-04-05', NULL, '2025-07-05');
    PRINT 'Test 1: OK - Normal record with NULL SignOffDate';
    DELETE FROM dbo.CrewServiceHistory WHERE CrewId = 'TESTCREW001';
END TRY
BEGIN CATCH
    PRINT 'Test 1: FAILED - ' + ERROR_MESSAGE();
END CATCH;

-- This should work - past dates
BEGIN TRY
    INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) 
    VALUES ('TESTCREW002', 'SHIP01', 1, '2024-10-01', '2025-03-31', '2025-04-01');
    PRINT 'Test 2: OK - Historical record with SignOffDate';
    DELETE FROM dbo.CrewServiceHistory WHERE CrewId = 'TESTCREW002';
END TRY
BEGIN CATCH
    PRINT 'Test 2: FAILED - ' + ERROR_MESSAGE();
END CATCH;

-- Test actual data
BEGIN TRY
    INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) VALUES
    ('CREW001', 'SHIP01', 1, '2025-04-05', NULL, '2025-07-05'),
    ('CREW002', 'SHIP01', 6, '2025-04-04', NULL, '2025-07-04'),
    ('CREW003', 'SHIP01', 2, '2025-04-08', NULL, '2025-07-08');
    PRINT 'Test 3: OK - First 3 crew records';
END TRY
BEGIN CATCH
    PRINT 'Test 3: FAILED - ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
END CATCH;

-- Check dates explicitly
SELECT 
    'SignOn=2025-04-05, EndContract=2025-07-05' AS TestCase,
    CASE WHEN CAST('2025-04-05' AS DATE) <= CAST('2025-07-05' AS DATE) THEN 'PASS' ELSE 'FAIL' END AS Result
UNION ALL
SELECT 
    'SignOn=2024-10-01, EndContract=2025-04-01',
    CASE WHEN CAST('2024-10-01' AS DATE) <= CAST('2025-04-01' AS DATE) THEN 'PASS' ELSE 'FAIL' END
UNION ALL
SELECT 
    'SignOff=2025-03-31, SignOn=2024-10-01',
    CASE WHEN CAST('2025-03-31' AS DATE) >= CAST('2024-10-01' AS DATE) THEN 'PASS' ELSE 'FAIL' END;
