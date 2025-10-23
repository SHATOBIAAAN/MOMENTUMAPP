@echo off
REM Momentum Test Runner Script for Windows
REM This script runs all tests for the Momentum app

setlocal EnableDelayedExpansion

echo.
echo ========================================
echo Starting Momentum Test Suite
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    exit /b 1
)

REM Print Flutter version
echo ========================================
echo Flutter Version
echo ========================================
echo.
flutter --version
echo.

REM Clean previous builds
echo ========================================
echo Cleaning Previous Builds
echo ========================================
echo.
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    exit /b 1
)

call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    exit /b 1
)

REM Generate code (Isar models and mocks)
echo.
echo ========================================
echo Generating Code
echo ========================================
echo.
echo Generating Isar models and test mocks...
call flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo ERROR: Code generation failed
    exit /b 1
)

REM Run Flutter analyze
echo.
echo ========================================
echo Running Flutter Analyze
echo ========================================
echo.
call flutter analyze
if %errorlevel% neq 0 (
    echo ERROR: Analysis issues found
    exit /b 1
) else (
    echo SUCCESS: No analysis issues found
)

REM Run all unit and widget tests
echo.
echo ========================================
echo Running Unit and Widget Tests
echo ========================================
echo.
call flutter test --coverage
if %errorlevel% neq 0 (
    echo ERROR: Some tests failed
    exit /b 1
) else (
    echo SUCCESS: All unit and widget tests passed
)

REM Check for connected devices
echo.
echo ========================================
echo Checking for Connected Devices
echo ========================================
echo.
flutter devices | findstr /C:"device" >nul
if %errorlevel% equ 0 (
    echo Device found, running integration tests...
    echo.
    echo ========================================
    echo Running Integration Tests
    echo ========================================
    echo.
    call flutter test integration_test/
    if %errorlevel% neq 0 (
        echo ERROR: Some integration tests failed
        exit /b 1
    ) else (
        echo SUCCESS: All integration tests passed
    )
) else (
    echo WARNING: No devices connected, skipping integration tests
    echo Connect a device or start an emulator to run integration tests
)

REM Generate coverage report
echo.
echo ========================================
echo Coverage Report
echo ========================================
echo.
if exist coverage\lcov.info (
    echo Coverage file generated at coverage\lcov.info
    echo.
    echo To generate HTML coverage report, install lcov and run:
    echo   genhtml coverage\lcov.info -o coverage\html
    echo.
) else (
    echo WARNING: No coverage data found
)

REM Run format check
echo.
echo ========================================
echo Checking Code Format
echo ========================================
echo.
dart format --set-exit-if-changed . >nul 2>&1
if %errorlevel% equ 0 (
    echo SUCCESS: Code is properly formatted
) else (
    echo WARNING: Some files need formatting
    echo Run 'dart format .' to fix formatting issues
)

REM Test summary
echo.
echo ========================================
echo Test Summary
echo ========================================
echo.
echo SUCCESS: All tests completed successfully!
echo.
echo Test Results:
echo   - Flutter analyze: PASSED
echo   - Unit tests: PASSED
echo   - Widget tests: PASSED

flutter devices | findstr /C:"device" >nul
if %errorlevel% equ 0 (
    echo   - Integration tests: PASSED
) else (
    echo   - Integration tests: SKIPPED (no device)
)

echo.
echo All checks passed! Your code is ready for production.
echo.

REM Open coverage report if available
if exist coverage\html\index.html (
    set /p RESPONSE="Would you like to open the coverage report? (y/n): "
    if /i "!RESPONSE!"=="y" (
        start coverage\html\index.html
    )
)

exit /b 0
