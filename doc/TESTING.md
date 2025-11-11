# Testing Guide

## Overview

This project includes comprehensive testing with both unit tests and end-to-end (E2E) tests to ensure code quality and functionality.

## Test Structure

```
tests/
└── ShipManagement.Tests/
    ├── E2ETests/                    # End-to-end API tests
    │   └── ShipManagementApiE2ETests.cs
    ├── CrewListRequestDtoTests.cs   # Unit tests
    ├── FinancialReportDtoTests.cs
    └── ShipTests.cs
```

## Quick Start

### Run All Tests

```bash
# Mac/Linux
./test.sh

# Windows PowerShell
.\test.ps1
```

### Run Specific Test Types

```bash
# Unit tests only
./test.sh --unit-only      # Mac/Linux
.\test.ps1 -UnitOnly       # Windows

# E2E tests only
./test.sh --e2e-only       # Mac/Linux
.\test.ps1 -E2eOnly        # Windows

# With detailed output
./test.sh --verbose        # Mac/Linux
.\test.ps1 -Verbose        # Windows

# With code coverage
./test.sh --coverage       # Mac/Linux
.\test.ps1 -Coverage       # Windows
```

## Test Types

### 1. Unit Tests

**Purpose**: Test individual components in isolation

**Location**: `tests/ShipManagement.Tests/*.cs`

**Examples**:
- `ShipTests.cs` - Tests for Ship entity validation
- `CrewListRequestDtoTests.cs` - Tests for DTO validation
- `FinancialReportDtoTests.cs` - Tests for financial data structures

**Run**:
```bash
dotnet test --filter "FullyQualifiedName!~E2ETests"
```

### 2. E2E Tests

**Purpose**: Test complete API workflows with HTTP requests

**Location**: `tests/ShipManagement.Tests/E2ETests/`

**Test Scenarios**:
1. **Get All Ships** - Verifies ship list retrieval
2. **Get Active Ships** - Verifies filtering by status
3. **Get Crew List** - Tests pagination and crew retrieval
4. **Search Crew** - Tests search functionality
5. **Financial Reports** - Tests summary and detail reports
6. **Get Users** - Verifies user list retrieval
7. **Error Handling** - Tests 404 and invalid inputs

**Run**:
```bash
dotnet test --filter "FullyQualifiedName~E2ETests"
```

**Note**: E2E tests use `WebApplicationFactory` which creates an in-memory test server. No need to start the API separately.

## Running Tests

### Using dotnet CLI

```bash
# All tests
dotnet test

# With detailed output
dotnet test --logger "console;verbosity=detailed"

# Specific test
dotnet test --filter "GetAllShips_ReturnsSuccessAndShipsList"

# Specific class
dotnet test --filter "FullyQualifiedName~ShipManagementApiE2ETests"
```

### Using Test Scripts

**Mac/Linux**:
```bash
# All tests
./test.sh

# Options
./test.sh --unit-only      # Unit tests only
./test.sh --e2e-only       # E2E tests only
./test.sh --verbose        # Detailed output
./test.sh --coverage       # Generate coverage report
./test.sh --help           # Show help
```

**Windows**:
```powershell
.\test.ps1                 # All tests
.\test.ps1 -UnitOnly       # Unit tests only
.\test.ps1 -E2eOnly        # E2E tests only
.\test.ps1 -Verbose        # Detailed output
.\test.ps1 -Coverage       # Generate coverage report
.\test.ps1 -Help           # Show help
```

## Code Coverage

### Generate Coverage Report

```bash
# Using test script
./test.sh --coverage

# Or manually
dotnet test --collect:"XPlat Code Coverage"
```

### View Coverage Report

1. **Install ReportGenerator**:
   ```bash
   dotnet tool install -g dotnet-reportgenerator-globaltool
   ```

2. **Generate HTML Report**:
   ```bash
   reportgenerator \
     -reports:"tests/ShipManagement.Tests/TestResults/*/coverage.cobertura.xml" \
     -targetdir:"coverage-report" \
     -reporttypes:Html
   ```

3. **Open Report**:
   ```bash
   open coverage-report/index.html  # Mac
   start coverage-report/index.html # Windows
   ```