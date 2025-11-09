# Quick Start Guide

## Ship Management System - Getting Started in 5 Minutes

### Option 1: Docker (Recommended - Easiest)

1. **Prerequisites**: Install Docker Desktop

2. **Clone and Run**:
   ```bash
   git clone <repository-url>
   cd ship-management-system
   docker-compose up --build
   ```

3. **Wait for initialization** (about 2-3 minutes for first run)

4. **Access the API**:
   - Swagger UI: http://localhost:5000
   - API Base URL: http://localhost:5000/api

5. **Test the API**:
   ```bash
   # Get all ships
   curl http://localhost:5000/api/ships
   
   # Get crew list for SHIP01
   curl "http://localhost:5000/api/crew?shipCode=SHIP01&pageNumber=1&pageSize=10"
   
   # Get financial report
   curl "http://localhost:5000/api/financial/report/detail?shipCode=SHIP01&period=2025-01"
   ```

---

### Option 2: Local Development

1. **Prerequisites**:
   - .NET 9 SDK
   - SQL Server 2022 (or SQL Express)
   - SQL Server Management Studio (optional)

2. **Setup Database**:
   ```bash
   cd database
   
   # Windows
   init-db.bat
   
   # macOS/Linux
   chmod +x init-db.sh
   ./init-db.sh
   ```

3. **Update Connection String**:
   
   Edit `src/ShipManagement.API/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=localhost;Database=ShipManagementDB;Integrated Security=true;TrustServerCertificate=True"
     }
   }
   ```

4. **Run the API**:
   ```bash
   cd src/ShipManagement.API
   dotnet run
   ```

5. **Access Swagger UI**:
   - Navigate to the URL shown in console (usually https://localhost:5001)

---

## Quick API Testing

### Using Swagger UI (Easiest)

1. Open http://localhost:5000 (or https://localhost:5001 for local)
2. Click on any endpoint to expand
3. Click "Try it out"
4. Fill in parameters
5. Click "Execute"
6. View the response

### Using curl

```bash
# Get all active ships
curl http://localhost:5000/api/ships/active

# Create a new ship
curl -X POST http://localhost:5000/api/ships \
  -H "Content-Type: application/json" \
  -d '{
    "shipCode": "SHIP99",
    "shipName": "Test Ship",
    "fiscalYearCode": "0112",
    "status": "Active"
  }'

# Get crew list with search
curl "http://localhost:5000/api/crew?shipCode=SHIP01&searchTerm=John&pageSize=5"

# Get financial summary
curl "http://localhost:5000/api/financial/report/summary?shipCode=SHIP01&period=2025-01"
```

### Using Postman

1. Import the Swagger JSON from http://localhost:5000/swagger/v1/swagger.json
2. Create a new collection
3. Add requests for each endpoint
4. Test the APIs

---

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

## Troubleshooting

### Docker Issues

**Problem**: SQL Server container won't start
```bash
# Check logs
docker-compose logs sqlserver

# Solution: Increase Docker memory to at least 4GB
```

**Problem**: API can't connect to database
```bash
# Check if SQL Server is healthy
docker-compose ps

# Restart services
docker-compose down
docker-compose up
```

### Local Development Issues

**Problem**: Connection refused to SQL Server
- Ensure SQL Server service is running
- Check SQL Server is listening on port 1433
- Verify connection string in appsettings.json

**Problem**: Database doesn't exist
```bash
# Run initialization scripts
cd database
./init-db.sh  # or init-db.bat on Windows
```

**Problem**: Build errors
```bash
# Restore NuGet packages
dotnet restore

# Clean and rebuild
dotnet clean
dotnet build
```

---

## Next Steps

1. **Explore the API**:
   - Try different search and filter combinations
   - Test pagination and sorting
   - Compare summary vs detailed financial reports

2. **Customize**:
   - Add your own ships
   - Create users and assignments
   - Modify the sample data

3. **Develop**:
   - Add new endpoints
   - Implement additional business logic
   - Write more unit tests

4. **Deploy**:
   - Build Docker images for production
   - Deploy to cloud (Azure, AWS, etc.)
   - Configure authentication

---

## Useful Commands

```bash
# Build the solution
dotnet build

# Run tests
dotnet test

# Run with watch (auto-reload on changes)
cd src/ShipManagement.API
dotnet watch run

# Create database backup (SQL Server)
sqlcmd -S localhost -U sa -P YourPassword -Q "BACKUP DATABASE ShipManagementDB TO DISK='/tmp/backup.bak'"

# Docker commands
docker-compose up -d          # Start in background
docker-compose logs -f api    # Follow API logs
docker-compose down -v        # Stop and remove volumes
docker-compose restart api    # Restart API only
```

---

## Support

- **Documentation**: See main README.md for detailed information
- **API Reference**: Access Swagger UI when running
- **Database Schema**: See database/ERD.md for entity relationship diagram
- **Issues**: Report bugs in the GitHub repository

---

**Happy Coding! 🚢**
