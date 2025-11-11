# Ship Management System - Test Runner Script (PowerShell)
# Runs both unit tests and E2E tests

param(
    [switch]$UnitOnly,
    [switch]$E2eOnly,
    [switch]$Verbose,
    [switch]$Coverage,
    [switch]$Help
)

# Show help
if ($Help) {
    Write-Host "Usage: .\test.ps1 [options]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -UnitOnly     Run only unit tests" -ForegroundColor White
    Write-Host "  -E2eOnly      Run only E2E tests" -ForegroundColor White
    Write-Host "  -Verbose      Show detailed test output" -ForegroundColor White
    Write-Host "  -Coverage     Generate code coverage report" -ForegroundColor White
    Write-Host "  -Help         Show this help message" -ForegroundColor White
    Write-Host ""
    exit 0
}

# Determine which tests to run
$runUnit = -not $E2eOnly
$runE2e = -not $UnitOnly

# Print banner
Write-Host ""
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "    Ship Management System - Test Suite Runner     " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host ""

# Navigate to solution directory
Set-Location $PSScriptRoot

# Build the solution first
Write-Host "Building solution..." -ForegroundColor Yellow
$buildOutput = dotnet build --configuration Release 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Build failed" -ForegroundColor Red
    Write-Host $buildOutput -ForegroundColor Red
    exit 1
}
Write-Host "OK: Build successful" -ForegroundColor Green
Write-Host ""

# Prepare test arguments
$testArgs = @(
    "--configuration", "Release",
    "--no-build"
)

if ($Verbose) {
    $testArgs += @("--logger", "console;verbosity=detailed")
}

if ($Coverage) {
    $testArgs += @("--collect:XPlat Code Coverage")
}

# Run Unit Tests
if ($runUnit) {
    Write-Host "Running Unit Tests..." -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Gray
    Write-Host ""
    
    $unitTestArgs = $testArgs + @("--filter", "FullyQualifiedName!~E2ETests")
    
    & dotnet test @unitTestArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Unit tests failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "OK: Unit tests passed" -ForegroundColor Green
    Write-Host ""
}

# Run E2E Tests
if ($runE2e) {
    Write-Host "Running E2E Tests..." -ForegroundColor Cyan
    Write-Host ("=" * 60) -ForegroundColor Gray
    Write-Host ""
    Write-Host "INFO: E2E tests use in-memory test server (no need to start API separately)" -ForegroundColor Gray
    Write-Host ""
    
    $e2eTestArgs = $testArgs + @("--filter", "FullyQualifiedName~E2ETests")
    
    & dotnet test @e2eTestArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: E2E tests failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "OK: E2E tests passed" -ForegroundColor Green
    Write-Host ""
}

# Summary
Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host "          All Tests Passed Successfully!           " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""

if ($Coverage) {
    Write-Host "Code coverage report generated" -ForegroundColor Cyan
    Write-Host "Location: tests\ShipManagement.Tests\TestResults\*\coverage.cobertura.xml" -ForegroundColor White
    Write-Host ""
    Write-Host "To view coverage report:" -ForegroundColor Yellow
    Write-Host "  1. Install ReportGenerator: dotnet tool install -g dotnet-reportgenerator-globaltool" -ForegroundColor White
    Write-Host "  2. Generate HTML report:" -ForegroundColor White
    Write-Host "     reportgenerator -reports:`"tests\ShipManagement.Tests\TestResults\*\coverage.cobertura.xml`" -targetdir:`"coverage-report`" -reporttypes:Html" -ForegroundColor Gray
    Write-Host "  3. Open: coverage-report\index.html" -ForegroundColor White
    Write-Host ""
}

Write-Host "Test Summary:" -ForegroundColor Cyan
if ($runUnit) {
    Write-Host "  - Unit Tests" -ForegroundColor Green
}
if ($runE2e) {
    Write-Host "  - E2E Tests" -ForegroundColor Green
}
Write-Host ""
