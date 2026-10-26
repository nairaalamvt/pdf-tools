@echo off
setlocal

if "%~1"=="" (
    echo Usage: %~nx0 "C:\path\to\your.pdf"
    echo.
    echo Or just drag and drop a PDF file onto this .bat file in File Explorer.
    echo.
    pause
    exit /b 1
)

set "WINPDF=%~1"
set "SCRIPTDIR=%~dp0"

echo Converting paths for WSL...
for /f "usebackq delims=" %%i in (`wsl wslpath "%WINPDF%"`) do set "WSLPDF=%%i"
for /f "usebackq delims=" %%i in (`wsl wslpath "%SCRIPTDIR%pdf2md.sh"`) do set "WSLSCRIPT=%%i"

if "%WSLPDF%"=="" (
    echo Could not convert the PDF path via wslpath. Is WSL installed and working?
    pause
    exit /b 1
)

echo.
echo Converting to Markdown:
echo   %WINPDF%
echo.

wsl bash "%WSLSCRIPT%" "%WSLPDF%"

echo.
echo ============================================
echo Finished - see the _md folder next to your
echo original PDF for the .md file and images.
echo ============================================
pause
