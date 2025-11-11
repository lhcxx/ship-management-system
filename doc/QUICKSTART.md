# Quick Start Guide

## Ship Management System - Getting Started in 5 Minutes

### Prerequisites

- .NET 8 SDK
- SQL Server (Azure SQL or Local SQL Server)
- Optional: SQL Server Management Studio

### Setup Steps

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd ship-management-system
   ```

2. **Setup Database**:   
  Run the database initialization script:
   ```bash
   cd database
   
   # Windows PowerShell
   .\init-db.ps1
   
   # macOS/Linux
   chmod +x init-db.sh
   ./init-db.sh
   ```
   
   This will automatically:
   - Clean up any existing data
   - Create all tables (9 tables)
   - Insert sample data (5 ships, 100 crew members, 5 users)
   - Insert budget and transaction data
   - Create stored procedures (10 SPs)

3. **Run the API**:
   ```bash
   cd src/ShipManagement.API
   dotnet run
   ```

4. **Access Swagger UI**:
   - Navigate to http://localhost:5050
   - Or the URL shown in console

---

## Quick API Testing

### Using Swagger UI (Recommended)

1. Open http://localhost:5050
2. Click on any endpoint to expand
3. Click "Try it out"
4. Fill in parameters
5. Click "Execute"
6. View the response

### Using curl

```bash
# Get all ships
curl http://localhost:5050/api/ships

# Get all active ships
curl http://localhost:5050/api/ships/active

# Create a new ship
curl -X POST http://localhost:5050/api/ships \
  -H "Content-Type: application/json" \
  -d '{
    "shipCode": "SHIP99",
    "shipName": "Test Ship",
    "fiscalYearCode": "0112",
    "status": "Active"
  }'

# Get crew list with search
curl "http://localhost:5050/api/crew?shipCode=SHIP01&searchTerm=John&pageSize=5"

# Get financial summary
curl "http://localhost:5050/api/financial/report/summary?shipCode=SHIP01&period=2025-01"
```

## Sample Data Overview

The database comes pre-loaded with sample data:

### Ships
- **SHIP01** - Flying Dutchman (Fiscal: Jan-Dec, Active)
- **SHIP02** - Thousand Sunny (Fiscal: Apr-Mar, Active)  
- **SHIP03** - Black Pearl (Fiscal: Jan-Dec, Active)
- **SHIP04** - Queen Anne's Revenge (Fiscal: Apr-Mar, Active)
- **SHIP05** - HMS Endeavour (Fiscal: Jul-Jun, Inactive)

### Users
- 5 users with different roles
- Users assigned to multiple ships

### Crew
- 100+ crew members
- 20+ crew per ship
- Various ranks (Master, Chief Engineer, Officers, Ratings, etc.)
- Mix of statuses: Onboard, Relief Due, Planned

### Financial Data
- Full 2024 and 2025 budget data
- Transaction data for multiple periods
- Multiple account types (Operating, Crew Costs, Fuel, Maintenance, etc.)

---

## Common Tasks

### 1. Get Crew List for a Ship

**Request**:
```http
GET /api/crew?shipCode=SHIP01&pageNumber=1&pageSize=20&sortColumn=RankName&sortDirection=ASC
```

**Response**:
```json
{
  "crew": [
    {
      "rankName": "Master",
      "crewId": "CREW001",
      "firstName": "Soka",
      "lastName": "Philip",
      "age": 45,
      "nationality": "Greek",
      "signOnDate": "2025-04-05",
      "signOnDateFormatted": "05 Apr 2025",
      "status": "Onboard"
    }
  ],
  "totalRecords": 20,
  "totalPages": 1,
  "currentPage": 1,
  "pageSize": 20
}
```

### 2. Get Financial Report

**Request**:
```http
GET /api/financial/report/detail?shipCode=SHIP01&period=2025-01
```

**Response**:
```json
[
  {
    "coaDescription": "OPERATING EXPENSES",
    "accountNumber": "7000000",
    "periodActual": 1500.00,
    "periodBudget": 1400.00,
    "periodVariance": 100.00,
    "ytdActual": 1500.00,
    "ytdBudget": 1400.00,
    "ytdVariance": 100.00
  }
]
```

### 3. Assign Ship to User

**Request**:
```http
POST /api/users/1/ships
Content-Type: application/json

"SHIP01"
```

**Response**: 204 No Content

### 4. Search Crew

**Request**:
```http
GET /api/crew?shipCode=SHIP01&searchTerm=Greek&pageNumber=1&pageSize=10
```

Searches across all fields (name, nationality, rank, etc.)

---

**Problem**: Port already in use
- Change port in `src/ShipManagement.API/Properties/launchSettings.json`
- Or kill the process using port 5050

---

## Next Steps
   - Read [doc/DATABASE.md](DATABASE.md) for database details
   - Check [doc/TESTING.md](TESTING.md) for testing guide
   - See [doc/DOCKER.md](DOCKER.md) for Docker deployment

---

## Useful Commands

```bash
# Build the solution
dotnet build

# Run all tests (unit + E2E)
./test.sh              # Mac/Linux
.\test.ps1             # Windows PowerShell

# Run tests with dotnet CLI
dotnet test

# Run with watch (auto-reload on changes)
cd src/ShipManagement.API
dotnet watch run

# Test database connection
cd database/ConnectionTester
dotnet run
```

---

## Support

- **Documentation**: See main [README.md](../README.md) for detailed information
- **Database Schema**: See [doc/ERD.md](ERD.md) for entity relationship diagram
- **API Reference**: Access Swagger UI at http://localhost:5050
- **Docker Deployment**: See [doc/DOCKER.md](DOCKER.md) for containerized deployment

---

