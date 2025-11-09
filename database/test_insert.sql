-- Quick test to find the problematic row
SET NOCOUNT ON;

-- Try inserting one by one to find which one fails
BEGIN TRY
    INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) 
    VALUES ('CREW001', 'SHIP01', 1, '2025-04-05', NULL, '2025-07-05');
    PRINT 'CREW001: OK';
END TRY
BEGIN CATCH
    PRINT 'CREW001: FAILED - ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
    INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) 
    VALUES ('CREW002', 'SHIP01', 6, '2025-04-04', NULL, '2025-07-04');
    PRINT 'CREW002: OK';
END TRY
BEGIN CATCH
    PRINT 'CREW002: FAILED - ' + ERROR_MESSAGE();
END CATCH;

-- Check what data is in CrewMembers
SELECT CrewId, FirstName, LastName FROM dbo.CrewMembers WHERE CrewId LIKE 'CREW00%' ORDER BY CrewId;

-- Check what ships exist
SELECT ShipCode, ShipName FROM dbo.Ships;

-- Check what ranks exist  
SELECT RankId, RankName FROM dbo.CrewRanks ORDER BY RankId;
