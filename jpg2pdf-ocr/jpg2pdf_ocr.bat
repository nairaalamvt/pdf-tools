@echo off
setlocal

if "%~1"=="" (
    echo Usage: drag a .zip file onto this .bat file
    echo    or: %~nx0 "C:\path\to\your.zip"
    echo.
    pause
    exit /b 1
)

if not exist "%~1" (
    echo File not found: %~1
    echo.
    pause
    exit /b 1
)

rem --- locate the .sh sitting next to this .bat ---
set "SCRIPTDIR=%~dp0"
if not exist "%SCRIPTDIR%jpg2pdf_ocr.sh" (
    echo Could not find jpg2pdf_ocr.sh next to this .bat file.
    echo Both files must live in the SAME folder.
    echo.
    pause
    exit /b 1
)

rem --- convert both Windows paths to WSL paths ---
for /f "delims=" %%i in ('wsl wslpath -a "%~1" 2^>nul') do set "WSLZIP=%%i"
if not defined WSLZIP (
    echo Could not convert the zip path via wslpath.
    echo Try running `wsl` on its own first to confirm WSL launches.
    echo.
    pause
    exit /b 1
)

for /f "delims=" %%i in ('wsl wslpath -a "%SCRIPTDIR%jpg2pdf_ocr.sh" 2^>nul') do set "WSLSH=%%i"
if not defined WSLSH (
    echo Could not convert the script path via wslpath.
    echo.
    pause
    exit /b 1
)

echo ============================================
echo Processing: %~nx1
echo ============================================
echo.

wsl bash "%WSLSH%" "%WSLZIP%"

echo.
echo ============================================
echo Finished - see the _ocr.pdf file inside the
echo *_extracted folder next to your original zip.
echo ============================================
pause
