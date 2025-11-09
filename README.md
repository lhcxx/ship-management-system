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
│   ├── ShipManagement.API/          # Web API Layer
│   ├── ShipManagement.Core/         # Domain Layer
│   └── ShipManagement.Infrastructure/ # Data Access Layer
├── tests/
│   └── ShipManagement.Tests/        # Unit tests
├── database/                         # Database scripts
│   ├── init-db.sh                   # Database initialization (Mac/Linux)
│   ├── init-db.bat                  # Database initialization (Windows)
│   ├── 01_CreateTables.sql
│   ├── 02_InsertSampleData.sql
│   ├── 03_InsertBudgetAndTransactions.sql
│   └── 04_CreateStoredProcedures.sql
├── test.sh / test.bat                # Test runner scripts
└── docs/                             # Documentation
    ├── DATABASE.md                   # Database design and setup
    ├── DOCKER.md                     # Docker deployment guide
    ├── CONFIGURATION.md              # Configuration management
    ├── TESTING.md                    # Testing guide
    └── QUICKSTART.md                 # Quick start guide
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

2. **Initialize database** (one command!)
   ```bash
   # Mac/Linux
   cd database
   export DB_PASSWORD="your-password"
   ./init-db.sh
   
   # Windows
   cd database
   set DB_PASSWORD=your-password
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

For detailed Docker setup, see [DOCKER.md](DOCKER.md)

## 📚 Documentation

- **[DATABASE.md](DATABASE.md)** - Complete database documentation
  - Database architecture and schema
  - Stored procedures and functions
  - Initialization guides
  - Sample data overview
  - Maintenance procedures

- **[DOCKER.md](DOCKER.md)** - Docker deployment guide
  - Docker setup and installation
  - Container configuration
  - Service management
  - Troubleshooting

- **[CONFIGURATION.md](CONFIGURATION.md)** - Configuration management
  - Connection string setup
  - Environment variables
  - Security best practices

- **[TESTING.md](TESTING.md)** - Testing guide
  - Unit tests and E2E tests
  - Running tests
  - Code coverage
  - Writing tests

- **[QUICKSTART.md](QUICKSTART.md)** - 5-minute getting started guide

- **[API_BACKGROUND.md](API_BACKGROUND.md)** - Background API management

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
./test.sh --unit-only    # Unit tests only
./test.sh --e2e-only     # E2E tests only
./test.sh --coverage     # With code coverage

# Or use dotnet CLI
dotnet test
```

See [TESTING.md](TESTING.md) for detailed testing guide.

**Current Coverage**: 12 tests (3 unit, 9 E2E) - All passing ✅

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

See [DATABASE.md](DATABASE.md) for complete details.

## 🔐 Security & Best Practices

- **Stored Procedures Only**: All database access via stored procedures (SQL injection prevention)
- **Parameterized Queries**: Using Dapper with parameter binding
- **Input Validation**: DTO validation on all endpoints
- **Clean Architecture**: Separation of concerns for maintainability
- **Repository Pattern**: Abstraction of data access

## 👨‍💻 Development

### Running Tests

See [TESTING.md](TESTING.md) for comprehensive testing guide.

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

See [DATABASE.md](DATABASE.md) and [CONFIGURATION.md](CONFIGURATION.md) for more details.

---

**Project Status**: ✅ Production Ready  
**Build**: Passing (12/12 tests)  
**Database**: Azure SQL Server  
**API**: Running on port 5050

**Documentation**: [DATABASE.md](DATABASE.md) | [DOCKER.md](DOCKER.md) | [TESTING.md](TESTING.md) | [CONFIGURATION.md](CONFIGURATION.md)

# With detailed output
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
