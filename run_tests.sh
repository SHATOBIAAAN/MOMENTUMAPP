#!/bin/bash

# Momentum Test Runner Script
# This script runs all tests for the Momentum app

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print section header
print_header() {
    echo ""
    echo "========================================"
    print_message "$BLUE" "$1"
    echo "========================================"
    echo ""
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_message "$RED" "❌ Flutter is not installed or not in PATH"
    exit 1
fi

# Print Flutter version
print_header "Flutter Version"
flutter --version

# Clean previous builds
print_header "Cleaning Previous Builds"
flutter clean
flutter pub get

# Generate code (Isar models and mocks)
print_header "Generating Code"
print_message "$YELLOW" "Generating Isar models and test mocks..."
flutter pub run build_runner build --delete-conflicting-outputs

# Run Flutter analyze
print_header "Running Flutter Analyze"
if flutter analyze; then
    print_message "$GREEN" "✅ No analysis issues found"
else
    print_message "$RED" "❌ Analysis issues found"
    exit 1
fi

# Run all unit and widget tests
print_header "Running Unit and Widget Tests"
if flutter test --coverage; then
    print_message "$GREEN" "✅ All unit and widget tests passed"
else
    print_message "$RED" "❌ Some tests failed"
    exit 1
fi

# Run integration tests (if device/emulator is connected)
print_header "Checking for Connected Devices"
if flutter devices | grep -q "device"; then
    print_header "Running Integration Tests"
    if flutter test integration_test/; then
        print_message "$GREEN" "✅ All integration tests passed"
    else
        print_message "$RED" "❌ Some integration tests failed"
        exit 1
    fi
else
    print_message "$YELLOW" "⚠️  No devices connected, skipping integration tests"
    print_message "$YELLOW" "   Connect a device or start an emulator to run integration tests"
fi

# Generate coverage report
print_header "Generating Coverage Report"
if [ -f "coverage/lcov.info" ]; then
    # Check if genhtml is available (from lcov package)
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        print_message "$GREEN" "✅ Coverage report generated at coverage/html/index.html"

        # Calculate coverage percentage
        COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep "lines" | awk '{print $2}')
        print_message "$GREEN" "📊 Coverage: $COVERAGE"
    else
        print_message "$YELLOW" "⚠️  genhtml not found. Install lcov to generate HTML coverage report:"
        print_message "$YELLOW" "   macOS: brew install lcov"
        print_message "$YELLOW" "   Linux: sudo apt-get install lcov"
    fi

    # Show coverage summary
    print_message "$BLUE" "\nCoverage Summary:"
    lcov --summary coverage/lcov.info 2>&1 || true
else
    print_message "$YELLOW" "⚠️  No coverage data found"
fi

# Run format check
print_header "Checking Code Format"
if dart format --set-exit-if-changed .; then
    print_message "$GREEN" "✅ Code is properly formatted"
else
    print_message "$YELLOW" "⚠️  Some files need formatting. Run 'dart format .' to fix"
fi

# Test summary
print_header "Test Summary"
print_message "$GREEN" "✅ All tests completed successfully!"
echo ""
print_message "$BLUE" "Test Results:"
echo "  - Flutter analyze: ✅ Passed"
echo "  - Unit tests: ✅ Passed"
echo "  - Widget tests: ✅ Passed"
if flutter devices | grep -q "device"; then
    echo "  - Integration tests: ✅ Passed"
else
    echo "  - Integration tests: ⚠️  Skipped (no device)"
fi
echo ""

print_message "$GREEN" "🎉 All checks passed! Your code is ready for production."
echo ""

# Open coverage report if available
if [ -f "coverage/html/index.html" ]; then
    echo "Would you like to open the coverage report? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        # Detect OS and open accordingly
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open coverage/html/index.html
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            xdg-open coverage/html/index.html
        elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
            start coverage/html/index.html
        fi
    fi
fi

exit 0
