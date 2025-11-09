-- Insert Sample Data for Ship Management System
-- SQL Server T-SQL

-- =============================================
-- Insert Crew Ranks
-- =============================================
SET IDENTITY_INSERT dbo.CrewRanks ON;

INSERT INTO dbo.CrewRanks (RankId, RankName, RankOrder, Department) VALUES
(1, 'Master', 1, 'Deck'),
(2, 'Chief Officer', 2, 'Deck'),
(3, 'Second Officer', 3, 'Deck'),
(4, 'Third Officer', 4, 'Deck'),
(5, 'Deck Cadet', 5, 'Deck'),
(6, 'Chief Engineer', 10, 'Engine'),
(7, 'Second Engineer', 11, 'Engine'),
(8, 'Third Engineer', 12, 'Engine'),
(9, 'Fourth Engineer', 13, 'Engine'),
(10, 'Oiler', 14, 'Engine'),
(11, 'Wiper', 15, 'Engine'),
(12, 'Cadet Engineer', 16, 'Engine'),
(13, 'Bosun', 20, 'Deck'),
(14, 'Able Seaman', 21, 'Deck'),
(15, 'Ordinary Seaman', 22, 'Deck'),
(16, 'Chief Cook', 30, 'Catering'),
(17, 'Cook', 31, 'Catering'),
(18, 'Mess man', 32, 'Catering');

SET IDENTITY_INSERT dbo.CrewRanks OFF;
GO

PRINT 'Crew Ranks inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

-- =============================================
-- Insert Ships
-- =============================================
INSERT INTO dbo.Ships (ShipCode, ShipName, FiscalYearCode, Status) VALUES
('SHIP01', 'Flying Dutchman', '0112', 'Active'),      -- Jan-Dec fiscal year
('SHIP02', 'Thousand Sunny', '0403', 'Active'),        -- Apr-Mar fiscal year
('SHIP03', 'Black Pearl', '0112', 'Active'),           -- Jan-Dec fiscal year
('SHIP04', 'Queen Anne''s Revenge', '0403', 'Active'), -- Apr-Mar fiscal year
('SHIP05', 'HMS Endeavour', '0712', 'Inactive');       -- Jul-Jun fiscal year
GO

PRINT 'Ships inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

-- =============================================
-- Insert Users
-- =============================================
SET IDENTITY_INSERT dbo.Users ON;

INSERT INTO dbo.Users (UserId, UserName, Email, Role) VALUES
(1, 'John Admin', 'john.admin@shipmanagement.com', 'Administrator'),
(2, 'Sarah Manager', 'sarah.manager@shipmanagement.com', 'FleetManager'),
(3, 'Mike Supervisor', 'mike.supervisor@shipmanagement.com', 'Supervisor'),
(4, 'Emily Analyst', 'emily.analyst@shipmanagement.com', 'Analyst'),
(5, 'David Operator', 'david.operator@shipmanagement.com', 'Operator');

SET IDENTITY_INSERT dbo.Users OFF;
GO

PRINT 'Users inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

-- =============================================
-- Insert User Ship Assignments
-- =============================================
INSERT INTO dbo.UserShipAssignments (UserId, ShipCode) VALUES
(1, 'SHIP01'), (1, 'SHIP02'), (1, 'SHIP03'), (1, 'SHIP04'), (1, 'SHIP05'),
(2, 'SHIP01'), (2, 'SHIP02'), (2, 'SHIP03'),
(3, 'SHIP01'), (3, 'SHIP02'),
(4, 'SHIP03'), (4, 'SHIP04'),
(5, 'SHIP01');
GO

PRINT 'User Ship Assignments inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

-- =============================================
-- Insert Crew Members (20+ per ship planned)
-- =============================================
INSERT INTO dbo.CrewMembers (CrewId, FirstName, LastName, DateOfBirth, Nationality) VALUES
-- Crew for SHIP01 (Flying Dutchman)
('CREW001', 'Soka', 'Philip', '1980-07-30', 'Greek'),
('CREW002', 'Masteros', 'Philip', '1980-07-30', 'Greek'),
('CREW003', 'John', 'Masterbear', '1975-05-15', 'Greek'),
('CREW004', 'Bob', 'Marley', '1998-03-20', 'Mexican'),
('CREW005', 'John', 'Chena', '1995-08-10', 'Mexican'),
('CREW006', 'James', 'Anderson', '1985-11-22', 'British'),
('CREW007', 'Michael', 'Chen', '1992-04-15', 'Chinese'),
('CREW008', 'David', 'Smith', '1988-09-30', 'American'),
('CREW009', 'Robert', 'Johnson', '1990-12-05', 'Canadian'),
('CREW010', 'William', 'Brown', '1987-06-18', 'Australian'),
('CREW011', 'Thomas', 'Garcia', '1993-02-25', 'Spanish'),
('CREW012', 'Daniel', 'Martinez', '1991-07-12', 'Mexican'),
('CREW013', 'Matthew', 'Rodriguez', '1989-10-08', 'Filipino'),
('CREW014', 'Joseph', 'Wilson', '1994-03-14', 'Indian'),
('CREW015', 'Charles', 'Moore', '1986-08-21', 'British'),
('CREW016', 'Christopher', 'Taylor', '1995-01-17', 'American'),
('CREW017', 'Paul', 'Anderson', '1992-11-29', 'Norwegian'),
('CREW018', 'Mark', 'Thomas', '1990-05-06', 'Swedish'),
('CREW019', 'Donald', 'Jackson', '1988-09-13', 'Danish'),
('CREW020', 'Steven', 'White', '1993-04-22', 'Greek'),

-- Crew for SHIP02 (Thousand Sunny)
('CREW021', 'George', 'Harris', '1987-07-30', 'British'),
('CREW022', 'Kenneth', 'Martin', '1991-02-14', 'American'),
('CREW023', 'Edward', 'Thompson', '1989-10-25', 'Canadian'),
('CREW024', 'Brian', 'Garcia', '1994-05-18', 'Spanish'),
('CREW025', 'Ronald', 'Martinez', '1990-12-09', 'Mexican'),
('CREW026', 'Anthony', 'Robinson', '1988-03-27', 'Filipino'),
('CREW027', 'Kevin', 'Clark', '1992-08-15', 'Indian'),
('CREW028', 'Jason', 'Rodriguez', '1993-01-22', 'Mexican'),
('CREW029', 'Jeff', 'Lewis', '1986-06-30', 'American'),
('CREW030', 'Ryan', 'Lee', '1995-11-11', 'Korean'),
('CREW031', 'Jacob', 'Walker', '1991-04-08', 'Australian'),
('CREW032', 'Gary', 'Hall', '1987-09-19', 'British'),
('CREW033', 'Nicholas', 'Allen', '1994-02-26', 'Canadian'),
('CREW034', 'Eric', 'Young', '1990-07-17', 'American'),
('CREW035', 'Jonathan', 'Hernandez', '1989-12-04', 'Mexican'),
('CREW036', 'Stephen', 'King', '1993-05-21', 'British'),
('CREW037', 'Larry', 'Wright', '1988-10-28', 'American'),
('CREW038', 'Justin', 'Lopez', '1992-03-15', 'Spanish'),
('CREW039', 'Scott', 'Hill', '1991-08-02', 'Canadian'),
('CREW040', 'Brandon', 'Scott', '1995-01-09', 'American'),

-- Crew for SHIP03 (Black Pearl)
('CREW041', 'Benjamin', 'Green', '1987-06-16', 'British'),
('CREW042', 'Samuel', 'Adams', '1992-11-23', 'American'),
('CREW043', 'Frank', 'Baker', '1988-04-30', 'Canadian'),
('CREW044', 'Gregory', 'Gonzalez', '1994-09-07', 'Spanish'),
('CREW045', 'Raymond', 'Nelson', '1990-02-14', 'American'),
('CREW046', 'Patrick', 'Carter', '1989-07-21', 'British'),
('CREW047', 'Dennis', 'Mitchell', '1993-12-28', 'Australian'),
('CREW048', 'Jerry', 'Perez', '1991-05-05', 'Mexican'),
('CREW049', 'Peter', 'Roberts', '1987-10-12', 'American'),
('CREW050', 'Harold', 'Turner', '1995-03-19', 'British'),
('CREW051', 'Douglas', 'Phillips', '1992-08-26', 'Canadian'),
('CREW052', 'Henry', 'Campbell', '1988-01-02', 'American'),
('CREW053', 'Carl', 'Parker', '1994-06-09', 'British'),
('CREW054', 'Arthur', 'Evans', '1990-11-16', 'American'),
('CREW055', 'Roger', 'Edwards', '1989-04-23', 'Canadian'),
('CREW056', 'Joe', 'Collins', '1993-09-30', 'British'),
('CREW057', 'Albert', 'Stewart', '1991-02-06', 'American'),
('CREW058', 'Walter', 'Sanchez', '1987-07-13', 'Mexican'),
('CREW059', 'Jack', 'Morris', '1996-12-20', 'British'),
('CREW060', 'Willie', 'Rogers', '1992-05-27', 'American'),

-- Crew for SHIP04 (Queen Anne's Revenge)
('CREW061', 'Terry', 'Reed', '1988-10-03', 'Canadian'),
('CREW062', 'Gerald', 'Cook', '1993-03-10', 'American'),
('CREW063', 'Keith', 'Morgan', '1991-08-17', 'British'),
('CREW064', 'Lawrence', 'Bell', '1989-01-24', 'American'),
('CREW065', 'Sean', 'Murphy', '1994-06-01', 'Irish'),
('CREW066', 'Christian', 'Bailey', '1990-11-08', 'American'),
('CREW067', 'Austin', 'Rivera', '1988-04-15', 'Mexican'),
('CREW068', 'Jesse', 'Cooper', '1993-09-22', 'American'),
('CREW069', 'Ethan', 'Richardson', '1992-02-28', 'Canadian'),
('CREW070', 'Philip', 'Cox', '1987-08-05', 'British'),
('CREW071', 'Johnny', 'Howard', '1995-01-12', 'American'),
('CREW072', 'Russell', 'Ward', '1991-06-19', 'Australian'),
('CREW073', 'Bruce', 'Torres', '1989-11-26', 'American'),
('CREW074', 'Wayne', 'Peterson', '1994-04-02', 'Canadian'),
('CREW075', 'Bobby', 'Gray', '1990-09-09', 'American'),
('CREW076', 'Louis', 'Ramirez', '1988-02-16', 'Mexican'),
('CREW077', 'Ralph', 'James', '1993-07-23', 'British'),
('CREW078', 'Roy', 'Watson', '1992-12-30', 'American'),
('CREW079', 'Eugene', 'Brooks', '1986-05-06', 'Canadian'),
('CREW080', 'Randy', 'Kelly', '1997-10-13', 'American'),

-- Additional Crew for SHIP01-04 rotation
('CREW081', 'Vincent', 'Sanders', '1990-03-20', 'American'),
('CREW082', 'Russell', 'Price', '1988-08-27', 'British'),
('CREW083', 'Louis', 'Bennett', '1993-01-03', 'Canadian'),
('CREW084', 'Philip', 'Wood', '1991-06-10', 'American'),
('CREW085', 'Bobby', 'Barnes', '1989-11-17', 'Australian'),
('CREW086', 'Johnny', 'Ross', '1994-04-24', 'American'),
('CREW087', 'Bradley', 'Henderson', '1992-09-01', 'British'),
('CREW088', 'Aaron', 'Coleman', '1987-02-08', 'American'),
('CREW089', 'Carlos', 'Jenkins', '1996-07-15', 'Mexican'),
('CREW090', 'Craig', 'Perry', '1990-12-22', 'American'),
('CREW091', 'Alan', 'Powell', '1988-05-29', 'British'),
('CREW092', 'Albert', 'Long', '1993-10-05', 'Canadian'),
('CREW093', 'Kyle', 'Patterson', '1991-03-12', 'American'),
('CREW094', 'Nathan', 'Hughes', '1989-08-19', 'American'),
('CREW095', 'Dylan', 'Flores', '1994-01-26', 'Mexican'),
('CREW096', 'Jordan', 'Washington', '1992-06-02', 'American'),
('CREW097', 'Bryan', 'Butler', '1987-11-09', 'British'),
('CREW098', 'Adam', 'Simmons', '1995-04-16', 'American'),
('CREW099', 'Wesley', 'Foster', '1990-09-23', 'Canadian'),
('CREW100', 'Cameron', 'Gonzales', '1988-02-29', 'Mexican');
GO

PRINT 'Crew Members inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

-- =============================================
-- Insert Crew Service History (Current assignments and history)
-- =============================================
-- SHIP01 Crew (Flying Dutchman) - Active crew
INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) VALUES
('CREW001', 'SHIP01', 1, '2025-04-05', NULL, '2025-07-05'),  -- Master - Onboard
('CREW002', 'SHIP01', 6, '2025-04-04', NULL, '2025-07-04'),  -- Chief Engineer - Onboard
('CREW003', 'SHIP01', 2, '2025-04-08', NULL, '2025-07-08'),  -- Chief Officer - Onboard
('CREW004', 'SHIP01', 12, '2025-04-05', NULL, '2025-07-05'), -- Cadet - Onboard
('CREW005', 'SHIP01', 10, '2025-04-08', NULL, '2025-10-08'), -- Oiler - Relief Due
('CREW006', 'SHIP01', 7, '2025-03-15', NULL, '2025-09-15'),  -- Second Engineer
('CREW007', 'SHIP01', 3, '2025-03-20', NULL, '2025-09-20'),  -- Second Officer
('CREW008', 'SHIP01', 8, '2025-04-01', NULL, '2025-10-01'),  -- Third Engineer
('CREW009', 'SHIP01', 4, '2025-04-10', NULL, '2025-10-10'),  -- Third Officer
('CREW010', 'SHIP01', 13, '2025-03-25', NULL, '2025-09-25'), -- Bosun
('CREW011', 'SHIP01', 14, '2025-04-05', NULL, '2025-10-05'), -- Able Seaman
('CREW012', 'SHIP01', 14, '2025-04-06', NULL, '2025-10-06'), -- Able Seaman
('CREW013', 'SHIP01', 15, '2025-04-08', NULL, '2025-10-08'), -- Ordinary Seaman
('CREW014', 'SHIP01', 11, '2025-04-10', NULL, '2025-10-10'), -- Wiper
('CREW015', 'SHIP01', 16, '2025-03-28', NULL, '2025-09-28'), -- Chief Cook
('CREW016', 'SHIP01', 17, '2025-04-02', NULL, '2025-10-02'), -- Cook
('CREW017', 'SHIP01', 18, '2025-04-05', NULL, '2025-10-05'), -- Messman
('CREW018', 'SHIP01', 9, '2025-04-12', NULL, '2025-10-12'), -- Fourth Engineer
('CREW019', 'SHIP01', 14, '2025-04-07', NULL, '2025-10-07'), -- Able Seaman
('CREW020', 'SHIP01', 15, '2025-04-09', NULL, '2025-10-09'), -- Ordinary Seaman
-- Some historical records (signed off)
('CREW081', 'SHIP01', 1, '2024-10-01', '2025-03-31', '2025-04-01'), -- Previous Master
('CREW082', 'SHIP01', 6, '2024-10-01', '2025-03-30', '2025-04-01'); -- Previous Chief Engineer
GO

-- SHIP02 Crew (Thousand Sunny)
INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) VALUES
('CREW021', 'SHIP02', 1, '2025-01-15', NULL, '2025-07-15'),
('CREW022', 'SHIP02', 6, '2025-01-15', NULL, '2025-07-15'),
('CREW023', 'SHIP02', 2, '2025-01-20', NULL, '2025-07-20'),
('CREW024', 'SHIP02', 7, '2025-01-18', NULL, '2025-07-18'),
('CREW025', 'SHIP02', 3, '2025-02-01', NULL, '2025-08-01'),
('CREW026', 'SHIP02', 8, '2025-02-01', NULL, '2025-08-01'),
('CREW027', 'SHIP02', 4, '2025-02-05', NULL, '2025-08-05'),
('CREW028', 'SHIP02', 9, '2025-02-10', NULL, '2025-08-10'),
('CREW029', 'SHIP02', 13, '2025-01-20', NULL, '2025-07-20'),
('CREW030', 'SHIP02', 14, '2025-01-25', NULL, '2025-07-25'),
('CREW031', 'SHIP02', 14, '2025-02-01', NULL, '2025-08-01'),
('CREW032', 'SHIP02', 15, '2025-02-05', NULL, '2025-08-05'),
('CREW033', 'SHIP02', 10, '2025-01-28', NULL, '2025-07-28'),
('CREW034', 'SHIP02', 11, '2025-02-03', NULL, '2025-08-03'),
('CREW035', 'SHIP02', 16, '2025-01-22', NULL, '2025-07-22'),
('CREW036', 'SHIP02', 17, '2025-01-25', NULL, '2025-07-25'),
('CREW037', 'SHIP02', 18, '2025-02-01', NULL, '2025-08-01'),
('CREW038', 'SHIP02', 14, '2025-02-08', NULL, '2025-08-08'),
('CREW039', 'SHIP02', 15, '2025-02-10', NULL, '2025-08-10'),
('CREW040', 'SHIP02', 12, '2025-02-12', NULL, '2025-08-12'),
-- Relief due crew member
('CREW083', 'SHIP02', 10, '2024-12-01', NULL, '2025-09-15'); -- Relief Due

-- SHIP03 Crew (Black Pearl)
INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) VALUES
('CREW041', 'SHIP03', 1, '2025-03-01', NULL, '2025-09-01'),
('CREW042', 'SHIP03', 6, '2025-03-01', NULL, '2025-09-01'),
('CREW043', 'SHIP03', 2, '2025-03-05', NULL, '2025-09-05'),
('CREW044', 'SHIP03', 7, '2025-03-08', NULL, '2025-09-08'),
('CREW045', 'SHIP03', 3, '2025-03-10', NULL, '2025-09-10'),
('CREW046', 'SHIP03', 8, '2025-03-12', NULL, '2025-09-12'),
('CREW047', 'SHIP03', 4, '2025-03-15', NULL, '2025-09-15'),
('CREW048', 'SHIP03', 9, '2025-03-18', NULL, '2025-09-18'),
('CREW049', 'SHIP03', 13, '2025-03-05', NULL, '2025-09-05'),
('CREW050', 'SHIP03', 14, '2025-03-08', NULL, '2025-09-08'),
('CREW051', 'SHIP03', 14, '2025-03-10', NULL, '2025-09-10'),
('CREW052', 'SHIP03', 15, '2025-03-12', NULL, '2025-09-12'),
('CREW053', 'SHIP03', 10, '2025-03-14', NULL, '2025-09-14'),
('CREW054', 'SHIP03', 11, '2025-03-16', NULL, '2025-09-16'),
('CREW055', 'SHIP03', 16, '2025-03-06', NULL, '2025-09-06'),
('CREW056', 'SHIP03', 17, '2025-03-09', NULL, '2025-09-09'),
('CREW057', 'SHIP03', 18, '2025-03-11', NULL, '2025-09-11'),
('CREW058', 'SHIP03', 14, '2025-03-13', NULL, '2025-09-13'),
('CREW059', 'SHIP03', 15, '2025-03-15', NULL, '2025-09-15'),
('CREW060', 'SHIP03', 12, '2025-03-17', NULL, '2025-09-17');

-- SHIP04 Crew (Queen Anne's Revenge)
INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) VALUES
('CREW061', 'SHIP04', 1, '2025-02-10', NULL, '2025-08-10'),
('CREW062', 'SHIP04', 6, '2025-02-10', NULL, '2025-08-10'),
('CREW063', 'SHIP04', 2, '2025-02-15', NULL, '2025-08-15'),
('CREW064', 'SHIP04', 7, '2025-02-18', NULL, '2025-08-18'),
('CREW065', 'SHIP04', 3, '2025-02-20', NULL, '2025-08-20'),
('CREW066', 'SHIP04', 8, '2025-02-22', NULL, '2025-08-22'),
('CREW067', 'SHIP04', 4, '2025-02-25', NULL, '2025-08-25'),
('CREW068', 'SHIP04', 9, '2025-02-28', NULL, '2025-08-28'),
('CREW069', 'SHIP04', 13, '2025-02-15', NULL, '2025-08-15'),
('CREW070', 'SHIP04', 14, '2025-02-18', NULL, '2025-08-18'),
('CREW071', 'SHIP04', 14, '2025-02-20', NULL, '2025-08-20'),
('CREW072', 'SHIP04', 15, '2025-02-22', NULL, '2025-08-22'),
('CREW073', 'SHIP04', 10, '2025-02-24', NULL, '2025-08-24'),
('CREW074', 'SHIP04', 11, '2025-02-26', NULL, '2025-08-26'),
('CREW075', 'SHIP04', 16, '2025-02-16', NULL, '2025-08-16'),
('CREW076', 'SHIP04', 17, '2025-02-19', NULL, '2025-08-19'),
('CREW077', 'SHIP04', 18, '2025-02-21', NULL, '2025-08-21'),
('CREW078', 'SHIP04', 14, '2025-02-23', NULL, '2025-08-23'),
('CREW079', 'SHIP04', 15, '2025-02-25', NULL, '2025-08-25'),
('CREW080', 'SHIP04', 12, '2025-02-27', NULL, '2025-08-27'),
-- Relief due
('CREW084', 'SHIP04', 10, '2024-11-01', NULL, '2025-08-10'); -- Relief Due

-- Future planned crew
INSERT INTO dbo.CrewServiceHistory (CrewId, ShipCode, RankId, SignOnDate, SignOffDate, EndOfContractDate) VALUES
('CREW085', 'SHIP01', 14, '2025-12-01', NULL, '2026-06-01'), -- Planned
('CREW086', 'SHIP02', 14, '2025-12-15', NULL, '2026-06-15'); -- Planned
GO

PRINT 'Crew Service History inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

-- =============================================
-- Insert Chart of Accounts (COA)
-- =============================================
-- Parent Accounts
INSERT INTO dbo.ChartOfAccounts (AccountNumber, AccountDescription, ParentAccountNumber, AccountType) VALUES
('7000000', 'OPERATING EXPENSES', NULL, 'Parent'),
('8000000', 'ADMINISTRATIVE EXPENSES', NULL, 'Parent'),
('9000000', 'MAINTENANCE & REPAIRS', NULL, 'Parent'),
('6000000', 'CREW COSTS', NULL, 'Parent'),
('5000000', 'FUEL & LUBRICANTS', NULL, 'Parent');

-- Level 2 (Children of Level 1)
INSERT INTO dbo.ChartOfAccounts (AccountNumber, AccountDescription, ParentAccountNumber, AccountType) VALUES
('7100000', 'AWARDS AND GRANTS TO INDIVIDUALS', '7000000', 'Parent'),
('7200000', 'SUPPLIES AND MATERIALS', '7000000', 'Parent'),
('7300000', 'UTILITIES', '7000000', 'Parent'),
('7400000', 'COMMUNICATION EXPENSES', '7000000', 'Parent'),
('7500000', 'INSURANCE', '7000000', 'Parent'),
('8100000', 'OFFICE SUPPLIES', '8000000', 'Parent'),
('8200000', 'PROFESSIONAL FEES', '8000000', 'Parent'),
('8300000', 'TRAINING & DEVELOPMENT', '8000000', 'Parent'),
('9100000', 'ENGINE MAINTENANCE', '9000000', 'Parent'),
('9200000', 'HULL MAINTENANCE', '9000000', 'Parent'),
('9300000', 'DECK EQUIPMENT', '9000000', 'Parent'),
('6100000', 'WAGES & SALARIES', '6000000', 'Parent'),
('6200000', 'CREW WELFARE', '6000000', 'Parent'),
('5100000', 'FUEL OIL', '5000000', 'Parent'),
('5200000', 'LUBRICANTS', '5000000', 'Parent');

-- Level 3 (Child accounts - where budget/actuals are recorded)
INSERT INTO dbo.ChartOfAccounts (AccountNumber, AccountDescription, ParentAccountNumber, AccountType) VALUES
('7120000', 'AWARDS', '7100000', 'Child'),
('7135000', 'SCHOLARSHIPS', '7100000', 'Child'),
('7140000', 'EMPLOYEE RECOGNITION', '7100000', 'Child'),
('7150000', 'INCENTIVE PROGRAMS', '7100000', 'Child'),
('7160000', 'GRANTS', '7100000', 'Child'),
('7210000', 'DECK SUPPLIES', '7200000', 'Child'),
('7220000', 'ENGINE SUPPLIES', '7200000', 'Child'),
('7230000', 'GALLEY SUPPLIES', '7200000', 'Child'),
('7240000', 'SAFETY EQUIPMENT', '7200000', 'Child'),
('7250000', 'CLEANING SUPPLIES', '7200000', 'Child'),
('7310000', 'ELECTRICITY', '7300000', 'Child'),
('7320000', 'WATER', '7300000', 'Child'),
('7330000', 'WASTE MANAGEMENT', '7300000', 'Child'),
('7410000', 'SATELLITE COMMUNICATION', '7400000', 'Child'),
('7420000', 'TELEPHONE & INTERNET', '7400000', 'Child'),
('7430000', 'POSTAL SERVICES', '7400000', 'Child'),
('7510000', 'HULL & MACHINERY INSURANCE', '7500000', 'Child'),
('7520000', 'P&I INSURANCE', '7500000', 'Child'),
('7530000', 'WAR RISK INSURANCE', '7500000', 'Child'),
('8110000', 'STATIONERY', '8100000', 'Child'),
('8120000', 'COMPUTER SUPPLIES', '8100000', 'Child'),
('8210000', 'LEGAL FEES', '8200000', 'Child'),
('8220000', 'AUDIT FEES', '8200000', 'Child'),
('8230000', 'CONSULTING FEES', '8200000', 'Child'),
('8310000', 'CREW TRAINING', '8300000', 'Child'),
('8320000', 'SAFETY TRAINING', '8300000', 'Child'),
('8330000', 'TECHNICAL TRAINING', '8300000', 'Child'),
('9110000', 'ENGINE SPARE PARTS', '9100000', 'Child'),
('9120000', 'ENGINE OVERHAUL', '9100000', 'Child'),
('9130000', 'AUXILIARY MACHINERY', '9100000', 'Child'),
('9210000', 'HULL PAINTING', '9200000', 'Child'),
('9220000', 'HULL REPAIRS', '9200000', 'Child'),
('9230000', 'DRYDOCKING', '9200000', 'Child'),
('9310000', 'DECK MACHINERY', '9300000', 'Child'),
('9320000', 'NAVIGATION EQUIPMENT', '9300000', 'Child'),
('9330000', 'CARGO EQUIPMENT', '9300000', 'Child'),
('6110000', 'OFFICER WAGES', '6100000', 'Child'),
('6120000', 'RATING WAGES', '6100000', 'Child'),
('6130000', 'OVERTIME', '6100000', 'Child'),
('6210000', 'CREW PROVISIONS', '6200000', 'Child'),
('6220000', 'MEDICAL EXPENSES', '6200000', 'Child'),
('6230000', 'REPATRIATION COSTS', '6200000', 'Child'),
('5110000', 'HEAVY FUEL OIL', '5100000', 'Child'),
('5120000', 'MARINE GAS OIL', '5100000', 'Child'),
('5130000', 'DIESEL OIL', '5100000', 'Child'),
('5210000', 'ENGINE OIL', '5200000', 'Child'),
('5220000', 'HYDRAULIC OIL', '5200000', 'Child'),
('5230000', 'GREASE', '5200000', 'Child');
GO

PRINT 'Chart of Accounts inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));

PRINT 'Sample data insertion completed successfully!';
GO
