# Ship Management System

A comprehensive backend solution for managing ships, crew, and financial reporting. This project is built using .NET 9, SQL Server, and follows clean architecture principles.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Design Decisions](#design-decisions)

## 🎯 Overview

This Ship Management System implements a complete backend solution for maritime operations management, including:

- Ship management (CRUD operations)
- User management and ship assignments
- Crew roster management with status tracking
- Financial reporting with budget vs actual analysis
- Fiscal year-based calculations

## ✨ Features

### 1. Ship Management
- Create, read, update ships
- Support for different fiscal year configurations (e.g., Jan-Dec, Apr-Mar)
- Active/Inactive status tracking

### 2. User Management
- User CRUD operations
- Many-to-many relationship between users and ships
- Role-based user categorization

### 3. Crew Management
- Comprehensive crew roster tracking
- Automatic status calculation (Onboard, Relief Due, Planned, Signed Off)
- Pagination, sorting, and searching capabilities
- Age calculation from date of birth
- Service history tracking with sign-on/sign-off dates

### 4. Financial Reporting
- Budget vs Actual expense reporting
- Year-to-Date (YTD) calculations based on fiscal year
- Hierarchical Chart of Accounts (COA)
- Period and summary reports
- Variance analysis

## 🛠 Tech Stack

- **Framework**: .NET 9 (C#)
- **Database**: SQL Server (T-SQL)
- **ORM**: Dapper (micro-ORM for stored procedure calls)
- **API**: ASP.NET Core Web API
- **Documentation**: Swagger/OpenAPI
- **Testing**: xUnit
- **Containerization**: Docker & Docker Compose

## 📁 Project Structure

```
ship-management-system/
├── src/
│   ├── ShipManagement.API/              # Web API Layer
│   │   ├── Controllers/                 # API Controllers
│   │   ├── appsettings.json             # API configuration
│   │   └── Program.cs                   # Application entry point
│   ├── ShipManagement.Core/             # Domain Layer
│   │   ├── Entities/                    # Domain entities
│   │   ├── DTOs/                        # Data Transfer Objects
│   │   └── Interfaces/                  # Repository interfaces
│   └── ShipManagement.Infrastructure/   # Data Access Layer
│       ├── Repositories/                # Repository implementations
│       └── appsettings.json             # Infrastructure configuration
├── tests/
│   └── ShipManagement.Tests/            # Test projects
│       ├── E2ETests/                    # End-to-end tests (9 tests)
│       ├── Entities/                    # Unit tests (3 tests)
│       └── DTOs/                        # Test DTOs
├── database/                             # Database scripts & tools
│   ├── init-db.sh                       # Database initialization (Mac/Linux)
│   ├── init-db.bat                      # Database initialization (Windows)
│   ├── 00_CleanupData.sql               # Data cleanup script
│   ├── 01_CreateTables.sql              # Table creation (9 tables)
│   ├── 02_InsertSampleData.sql          # Sample data (ships, crew, users)
│   ├── 03_InsertBudgetAndTransactions.sql # Financial data
│   ├── 04_CreateStoredProcedures.sql    # Stored procedures (10 SPs)
│   ├── DatabaseInitializer/             # Database initialization tool
│   ├── ConnectionTester/                # Connection testing tool
│   └── QuickTest/                       # Quick database query tool
├── doc/                                  # Documentation
│   ├── ERD.md                           # Entity Relationship Diagram
│   ├── DATABASE.md                      # Database design and setup
│   ├── DOCKER.md                        # Docker deployment guide
│   ├── TESTING.md                       # Testing guide
│   ├── QUICKSTART.md                    # Quick start guide
│   └── API_BACKGROUND.md                # Background API management
├── test.sh / test.bat                    # Test runner scripts
├── docker-compose.yml                    # Docker Compose configuration
├── Dockerfile                            # Docker image definition
├── .env.example                          # Environment variables template
└── ShipManagement.sln                    # Solution file
```

## 🚀 Quick Start

### Prerequisites

- .NET 9 SDK
- SQL Server (Local, Azure, or Docker)
- Docker (optional, for containerized deployment)

### Option 1: Quick Setup with Azure SQL (Recommended)

1. **Clone and navigate**
   ```bash
   git clone <repository-url>
   cd ship-management-system
   ```

2. **Initialize database** 
   ```bash
   # Mac/Linux
   cd database
   ./init-db.sh
   
   # Windows
   cd database
   init-db.bat
   ```

3. **Update API connection string**
   
   Edit `src/ShipManagement.API/appsettings.json` with your database details

4. **Run the API**
   ```bash
   cd src/ShipManagement.API
   dotnet run
   ```

5. **Open Swagger UI**: http://localhost:5050

### Option 2: Docker Deployment

```bash
docker compose up --build
```

Access API at http://localhost:5000

For detailed Docker setup, see [doc/DOCKER.md](doc/DOCKER.md)

## 📚 Documentation

- **[doc/ERD.md](doc/ERD.md)** - Entity Relationship Diagram
  - Database schema visualization
  - Table relationships
  - Entity descriptions

- **[doc/DATABASE.md](doc/DATABASE.md)** - Complete database documentation
  - Database architecture and schema
  - Stored procedures and functions
  - Initialization guides

- **[doc/DOCKER.md](doc/DOCKER.md)** - Docker deployment guide
  - Docker setup and installation
  - Container configuration
  - Service management

- **[doc/TESTING.md](doc/TESTING.md)** - Testing guide
  - Unit tests and E2E tests
  - Running tests
  - Code coverage

- **[doc/QUICKSTART.md](doc/QUICKSTART.md)**

- **[doc/API_BACKGROUND.md](doc/API_BACKGROUND.md)** - Background API management

## 📖 API Documentation

Access Swagger UI when the API is running:
- Local: http://localhost:5050
- Docker: http://localhost:5000

### Key Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/ships` | GET | Get all ships |
| `/api/ships/{shipCode}` | GET | Get ship details |
| `/api/users` | GET | Get all users |
| `/api/crew` | GET | Get crew list (with pagination, sorting, search) |
| `/api/financial/report/summary` | GET | Financial summary report |
| `/api/financial/report/detail` | GET | Detailed financial report |

**Query Parameters:**
- Crew: `shipCode`, `pageNumber`, `pageSize`, `sortColumn`, `sortDirection`, `searchTerm`, `asOfDate`
- Financial: `shipCode`, `period` (YYYY-MM)

See Swagger UI for complete API documentation and testing interface.

## 🧪 Testing

The project includes comprehensive unit and E2E tests.

```bash
# Run all tests (unit + E2E)
./test.sh             # Mac/Linux
test.bat              # Windows

# Run specific test types
./test.sh --unit-only    # Unit tests only (3 tests)
./test.sh --e2e-only     # E2E tests only (9 tests)
./test.sh --coverage     # With code coverage

# Or use dotnet CLI
dotnet test
```

### Test Coverage

**Total: 12 tests - All passing ✅**

**Unit Tests (3)**
- Ship entity validation
- Crew member entity validation  
- Financial calculation logic

**E2E Tests (9)**
- ✅ GetAllShips - Retrieve all ships from API
- ✅ GetActiveShips - Filter active ships only
- ✅ GetCrewList_WithPagination - Paginated crew list
- ✅ GetCrewList_WithSearch - Search crew by name
- ✅ GetCrewList_WithSorting - Sort crew by different columns
- ✅ GetFinancialSummaryReport - Summary financial report
- ✅ GetFinancialDetailReport - Detailed financial report
- ✅ GetCrewList_InvalidShipCode - Error handling for invalid ship
- ✅ GetFinancialReport_InvalidPeriod - Error handling for invalid period

See [doc/TESTING.md](doc/TESTING.md) for detailed testing guide.

## 🏗 Design Decisions

### Architecture
- **Clean Architecture**: Separation of concerns with Core, Infrastructure, and API layers
- **Repository Pattern**: Abstraction of data access logic
- **Dependency Injection**: For loose coupling and testability

### Database Access
- **Stored Procedures Only**: All database access goes through stored procedures for:
  - Security (SQL injection prevention)
  - Performance optimization
  - Centralized business logic
  - Easier maintenance and testing

### Fiscal Year Handling
- Flexible fiscal year configuration using MMDD format
- Dynamic YTD calculation based on ship's fiscal year
- Supports various fiscal year patterns (calendar year, financial year, etc.)

### Crew Status Logic
- **Onboard**: Signed on, not signed off, within contract dates
- **Relief Due**: More than 30 days past end of contract
- **Planned**: Sign-on date in the future
- **Signed Off**: Has sign-off date

### Financial Reporting
- Hierarchical account structure with parent/child relationships
- Parent account values calculated by aggregating children
- Only non-zero budget/actual values included in reports
- Separate detail and summary views

### Error Handling
- Comprehensive exception handling in controllers
- Meaningful error messages and HTTP status codes
- Logging for debugging and monitoring

## 📝 Sample Data

The database includes comprehensive sample data:
- 5 ships (SHIP01-SHIP05) with different fiscal years
- 100 crew members with realistic profiles
- 5 users with ship assignments
- 18 crew ranks (deck, engine, catering)
- 68 chart of accounts with hierarchy
- 2 years of budget and transaction data (2024-2025)

See [doc/DATABASE.md](doc/DATABASE.md) for complete details.

## 🔐 Security & Best Practices

- **Stored Procedures Only**: All database access via stored procedures (SQL injection prevention)
- **Parameterized Queries**: Using Dapper with parameter binding
- **Input Validation**: DTO validation on all endpoints
- **Clean Architecture**: Separation of concerns for maintainability
- **Repository Pattern**: Abstraction of data access

## 👨‍💻 Development

### Running Tests

See [doc/TESTING.md](doc/TESTING.md) for comprehensive testing guide.

```bash
# All tests
./test.sh

# With detailed output
dotnet test --logger "console;verbosity=detailed"
```

### Adding New Features

1. Define entity in `Core/Entities`
2. Create DTOs in `Core/DTOs`
3. Define interface in `Core/Interfaces`
4. Implement repository in `Infrastructure/Repositories`
5. Create controller in `API/Controllers`
6. Write tests in `Tests` (both unit and E2E)

### Database Changes

1. Update SQL scripts in `database/`
2. Run migration scripts
3. Update stored procedures if needed
4. Test with sample data

See [doc/DATABASE.md](doc/DATABASE.md) for more details.

---

**Project Status**: ✅ Production Ready  
**Build**: Passing (12/12 tests)  
**Database**: Azure SQL Server  
**API**: Running on port 5050

**Documentation**: [ERD.md](doc/ERD.md) | [DATABASE.md](doc/DATABASE.md) | [DOCKER.md](doc/DOCKER.md) | [TESTING.md](doc/TESTING.md) | [QUICKSTART.md](doc/QUICKSTART.md)

# With detailed output
```
dotnet test --logger "console;verbosity=detailed"
```

### Adding New Features

1. Define entity in `Core/Entities`
2. Create DTOs in `Core/DTOs`
3. Define interface in `Core/Interfaces`
4. Implement repository in `Infrastructure/Repositories`
5. Create controller in `API/Controllers`
6. Write tests in `Tests`

### Database Changes

1. Update SQL scripts in `database/`
2. Run migration scripts
3. Update stored procedures if needed
4. Test with sample data

---

**Project Status**: ✅ Production Ready  
**Build**: Passing (9/9 tests)  
**Database**: Azure SQL Server  
**API**: Running on port 5050
