@echo off
REM Ship Management System - Test Runner Script (Windows)
REM Runs both unit tests and E2E tests

setlocal enabledelayedexpansion

REM Parse arguments
set RUN_UNIT=true
set RUN_E2E=true
set VERBOSE=false
set COVERAGE=false

:parse_args
if "%~1"=="" goto end_parse_args
if "%~1"=="--unit-only" (
    set RUN_E2E=false
    shift
    goto parse_args
)
if "%~1"=="--e2e-only" (
    set RUN_UNIT=false
    shift
    goto parse_args
)
if "%~1"=="--verbose" (
    set VERBOSE=true
    shift
    goto parse_args
)
if "%~1"=="--coverage" (
    set COVERAGE=true
    shift
    goto parse_args
)
if "%~1"=="--help" (
    echo Usage: test.bat [options]
    echo.
    echo Options:
    echo   --unit-only    Run only unit tests
    echo   --e2e-only     Run only E2E tests
    echo   --verbose      Show detailed test output
    echo   --coverage     Generate code coverage report
    echo   --help         Show this help message
    echo.
    exit /b 0
)
echo Unknown option: %~1
echo Use --help to see available options
exit /b 1

:end_parse_args

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║     Ship Management System - Test Suite Runner        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Navigate to solution directory
cd /d "%~dp0"

REM Build the solution first
echo [*] Building solution...
dotnet build --configuration Release >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Build failed
    exit /b 1
)
echo [OK] Build successful
echo.

REM Prepare test arguments
set TEST_ARGS=
if "%VERBOSE%"=="true" (
    set TEST_ARGS=--logger "console;verbosity=detailed"
)
if "%COVERAGE%"=="true" (
    set TEST_ARGS=%TEST_ARGS% --collect:"XPlat Code Coverage"
)

REM Run Unit Tests
if "%RUN_UNIT%"=="true" (
    echo Running Unit Tests...
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    dotnet test --filter "FullyQualifiedName!~E2ETests" --configuration Release --no-build %TEST_ARGS%
    if !ERRORLEVEL! NEQ 0 (
        echo [ERROR] Unit tests failed
        exit /b 1
    )
    echo [OK] Unit tests passed
    echo.
)

REM Run E2E Tests
if "%RUN_E2E%"=="true" (
    echo Running E2E Tests...
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    echo [INFO] E2E tests use in-memory test server (no need to start API separately)
    echo.
    
    dotnet test --filter "FullyQualifiedName~E2ETests" --configuration Release --no-build %TEST_ARGS%
    if !ERRORLEVEL! NEQ 0 (
        echo [ERROR] E2E tests failed
        exit /b 1
    )
    echo [OK] E2E tests passed
    echo.
)

REM Summary
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║            All Tests Passed Successfully! ✨           ║
echo ╚════════════════════════════════════════════════════════╝
echo.

if "%COVERAGE%"=="true" (
    echo 📊 Code coverage report generated
    echo Location: tests\ShipManagement.Tests\TestResults\*\coverage.cobertura.xml
    echo.
    echo To view coverage report:
    echo   1. Install ReportGenerator: dotnet tool install -g dotnet-reportgenerator-globaltool
    echo   2. Generate HTML report: reportgenerator -reports:"tests\ShipManagement.Tests\TestResults\*\coverage.cobertura.xml" -targetdir:"coverage-report" -reporttypes:Html
    echo   3. Open: coverage-report\index.html
    echo.
)

echo Test Summary:
if "%RUN_UNIT%"=="true" echo   ✓ Unit Tests
if "%RUN_E2E%"=="true" echo   ✓ E2E Tests
echo.

endlocal
