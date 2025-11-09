-- Clean up script - delete all data
-- This allows re-running the initialization scripts

PRINT 'Cleaning up existing data...';

-- Delete in reverse order of dependencies
DELETE FROM dbo.CrewServiceHistory;
DELETE FROM dbo.UserShipAssignments;
DELETE FROM dbo.AccountTransactions;
DELETE FROM dbo.BudgetData;
DELETE FROM dbo.ChartOfAccounts;
DELETE FROM dbo.CrewMembers;
DELETE FROM dbo.Users;
DELETE FROM dbo.CrewRanks;
DELETE FROM dbo.Ships;

PRINT 'Cleanup complete. All data deleted.';
