# Ship Management System

A comprehensive backend solution for managing ships, crew, and financial reporting. This project is built using .NET 9, SQL Server, and follows clean architecture principles.

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Database Setup](#database-setup)
- [API Documentation](#api-documentation)
- [Docker Deployment](#docker-deployment)
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
│   │   ├── Controllers/             # API Controllers
│   │   ├── Program.cs               # Application entry point
│   │   └── appsettings.json         # Configuration
│   ├── ShipManagement.Core/         # Domain Layer
│   │   ├── Entities/                # Domain entities
│   │   ├── DTOs/                    # Data Transfer Objects
│   │   └── Interfaces/              # Repository interfaces
│   └── ShipManagement.Infrastructure/ # Data Access Layer
│       ├── Data/                    # Database context
│       └── Repositories/            # Repository implementations
├── tests/
│   └── ShipManagement.Tests/        # Unit tests
├── database/
│   ├── 01_CreateTables.sql          # DDL scripts
│   ├── 02_InsertSampleData.sql      # Sample data
│   ├── 03_InsertBudgetAndTransactions.sql # Financial data
│   └── 04_CreateStoredProcedures.sql # Stored procedures
├── Dockerfile                        # Docker configuration
├── docker-compose.yml               # Docker Compose setup
└── README.md                        # This file
```

## 🚀 Getting Started

### Prerequisites

- .NET 9 SDK
- SQL Server 2022 or later (or SQL Server Express)
- Docker & Docker Compose (optional, for containerized deployment)

### Option 1: Running Locally

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ship-management-system
   ```

2. **Update connection string**
   
   Edit `src/ShipManagement.API/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Server=localhost,1433;Database=ShipManagementDB;User Id=sa;Password=YourPassword;TrustServerCertificate=True"
     }
   }
   ```

3. **Setup database** (see [Database Setup](#database-setup))

4. **Run the application**
   ```bash
   cd src/ShipManagement.API
   dotnet run
   ```

5. **Access Swagger UI**
   
   Navigate to `https://localhost:5001` (or the port shown in console)

### Option 2: Running with Docker

```bash
# Build and start all services
docker-compose up --build

# Access the API
# http://localhost:5000
```

## 💾 Database Setup

### Manual Setup

1. **Create the database** (if not using Docker)
   ```sql
   CREATE DATABASE ShipManagementDB;
   GO
   USE ShipManagementDB;
   GO
   ```

2. **Run the SQL scripts in order**:
   ```bash
   # From the database directory
   sqlcmd -S localhost -U sa -P YourPassword -i 01_CreateTables.sql
   sqlcmd -S localhost -U sa -P YourPassword -i 02_InsertSampleData.sql
   sqlcmd -S localhost -U sa -P YourPassword -i 03_InsertBudgetAndTransactions.sql
   sqlcmd -S localhost -U sa -P YourPassword -i 04_CreateStoredProcedures.sql
   ```

### Database Schema

**Main Tables:**
- `Ships` - Ship master data
- `Users` - System users
- `UserShipAssignments` - User-ship relationships
- `CrewMembers` - Crew personal data
- `CrewRanks` - Rank definitions
- `CrewServiceHistory` - Crew assignments and contracts
- `ChartOfAccounts` - Financial account hierarchy
- `BudgetData` - Budget information
- `AccountTransactions` - Actual transactions

**Stored Procedures:**
- `usp_GetCrewList` - Retrieves crew with pagination, sorting, and search
- `usp_GetFinancialReportDetail` - Detailed financial report
- `usp_GetFinancialReportSummary` - Summary financial report

## 📖 API Documentation

Once the application is running, access the Swagger UI for interactive API documentation:
- Local: `https://localhost:5001`
- Docker: `http://localhost:5000`

### Main Endpoints

#### Ships
- `GET /api/ships` - Get all ships
- `GET /api/ships/active` - Get active ships only
- `GET /api/ships/{shipCode}` - Get ship by code
- `POST /api/ships` - Create new ship
- `PUT /api/ships/{shipCode}` - Update ship

#### Users
- `GET /api/users` - Get all users
- `GET /api/users/{userId}` - Get user by ID
- `POST /api/users` - Create new user
- `GET /api/users/{userId}/ships` - Get user's assigned ships
- `POST /api/users/{userId}/ships` - Assign ship to user
- `DELETE /api/users/{userId}/ships/{shipCode}` - Remove ship from user

#### Crew
- `GET /api/crew` - Get crew list with pagination and filtering
  - Query parameters: `shipCode`, `pageNumber`, `pageSize`, `sortColumn`, `sortDirection`, `searchTerm`, `asOfDate`

#### Financial
- `GET /api/financial/report` - Get financial report
  - Query parameters: `shipCode`, `period` (YYYY-MM), `isSummary`
- `GET /api/financial/report/summary` - Get summary report
- `GET /api/financial/report/detail` - Get detailed report

## 🐳 Docker Deployment

The project includes Docker configuration for easy deployment:

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

**Services:**
- `sqlserver`: SQL Server 2022 database
- `api`: .NET API application

**Ports:**
- API: http://localhost:5000
- SQL Server: localhost:1433

## 🧪 Testing

```bash
# Run all tests
dotnet test

# Run tests with coverage
dotnet test /p:CollectCoverage=true
```

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
- 5 ships with different fiscal years and statuses
- 5 users with various roles
- 100+ crew members across ships
- 18 crew ranks covering deck, engine, and catering departments
- Hierarchical chart of accounts (50+ accounts)
- 2 years of budget data (2024-2025)
- Transaction data for multiple ships and periods

## 🔐 Security Considerations

- Parameterized queries (via Dapper) prevent SQL injection
- Stored procedures provide an additional security layer
- CORS configuration for controlled API access
- Input validation on all endpoints
- Environment-based configuration for sensitive data

## 📈 Future Enhancements

- JWT authentication and authorization
- Role-based access control (RBAC)
- Audit logging for all operations
- Real-time notifications
- Bulk data import/export
- Advanced reporting with charts
- Mobile app support
- Multi-tenancy support

## 👨‍💻 Development

### Adding a New Feature

1. Define entities in `ShipManagement.Core/Entities`
2. Create DTOs in `ShipManagement.Core/DTOs`
3. Define repository interface in `ShipManagement.Core/Interfaces`
4. Implement repository in `ShipManagement.Infrastructure/Repositories`
5. Create controller in `ShipManagement.API/Controllers`
6. Write tests in `ShipManagement.Tests`

### Code Style

- Follow C# coding conventions
- Use meaningful variable and method names
- Add XML comments for public APIs
- Keep controllers thin, move logic to services/repositories

## 📄 License

This project is created for the AE Backend Code Challenge.

## 🙏 Acknowledgments

- Anglo-Eastern for the code challenge specification
- Microsoft for .NET and SQL Server
- Community contributors to Dapper, Swagger, and other libraries used

---

**Contact**: support@shipmanagement.com  
**Documentation**: See Swagger UI when application is running  
**Issues**: Please report any issues in the GitHub repository
