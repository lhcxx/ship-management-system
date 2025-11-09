#!/bin/bash

# Ship Management System - Test Runner Script
# Runs both unit tests and E2E tests

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print banner
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Ship Management System - Test Suite Runner        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Parse arguments
RUN_UNIT=true
RUN_E2E=true
VERBOSE=false
COVERAGE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --unit-only)
            RUN_E2E=false
            shift
            ;;
        --e2e-only)
            RUN_UNIT=false
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --help)
            echo "Usage: ./test.sh [options]"
            echo ""
            echo "Options:"
            echo "  --unit-only    Run only unit tests"
            echo "  --e2e-only     Run only E2E tests"
            echo "  --verbose      Show detailed test output"
            echo "  --coverage     Generate code coverage report"
            echo "  --help         Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help to see available options"
            exit 1
            ;;
    esac
done

# Navigate to solution directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Build the solution first
echo -e "${BLUE}▶ Building solution...${NC}"
if dotnet build --configuration Release > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Build successful${NC}"
    echo ""
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Prepare test arguments
TEST_ARGS=""
if [ "$VERBOSE" = true ]; then
    TEST_ARGS="--logger \"console;verbosity=detailed\""
fi

if [ "$COVERAGE" = true ]; then
    TEST_ARGS="$TEST_ARGS --collect:\"XPlat Code Coverage\""
fi

# Run Unit Tests
if [ "$RUN_UNIT" = true ]; then
    echo -e "${YELLOW}Running Unit Tests...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    UNIT_TEST_FILTER="FullyQualifiedName!~E2ETests"
    
    if eval dotnet test --filter \"$UNIT_TEST_FILTER\" --configuration Release --no-build $TEST_ARGS; then
        echo -e "${GREEN}✅ Unit tests passed${NC}"
        echo ""
    else
        echo -e "${RED}❌ Unit tests failed${NC}"
        exit 1
    fi
fi

# Run E2E Tests
if [ "$RUN_E2E" = true ]; then
    echo -e "${YELLOW}Running E2E Tests...${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    E2E_TEST_FILTER="FullyQualifiedName~E2ETests"
    
    # Check if API is needed (E2E tests use in-memory test server)
    echo -e "${BLUE}ℹ E2E tests use in-memory test server (no need to start API separately)${NC}"
    echo ""
    
    if eval dotnet test --filter \"$E2E_TEST_FILTER\" --configuration Release --no-build $TEST_ARGS; then
        echo -e "${GREEN}✅ E2E tests passed${NC}"
        echo ""
    else
        echo -e "${RED}❌ E2E tests failed${NC}"
        exit 1
    fi
fi

# Summary
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            All Tests Passed Successfully! ✨           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Show coverage info if generated
if [ "$COVERAGE" = true ]; then
    echo -e "${BLUE}📊 Code coverage report generated${NC}"
    echo -e "${BLUE}Location: tests/ShipManagement.Tests/TestResults/*/coverage.cobertura.xml${NC}"
    echo ""
    echo "To view coverage report:"
    echo "  1. Install ReportGenerator: dotnet tool install -g dotnet-reportgenerator-globaltool"
    echo "  2. Generate HTML report: reportgenerator -reports:\"tests/ShipManagement.Tests/TestResults/*/coverage.cobertura.xml\" -targetdir:\"coverage-report\" -reporttypes:Html"
    echo "  3. Open: coverage-report/index.html"
    echo ""
fi

echo -e "${BLUE}Test Summary:${NC}"
if [ "$RUN_UNIT" = true ]; then
    echo -e "  ${GREEN}✓${NC} Unit Tests"
fi
if [ "$RUN_E2E" = true ]; then
    echo -e "  ${GREEN}✓${NC} E2E Tests"
fi
echo ""
