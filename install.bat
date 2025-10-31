@echo off
setlocal enabledelayedexpansion

set "TOML_FILE=package.toml"
set "INSTALL_SCOPE=local"

if "%~1"=="" goto :parse_done
:parse_args
if "%~1"=="--texmflocal" (
    set "INSTALL_SCOPE=local"
) else if "%~1"=="--texmfhome" (
    set "INSTALL_SCOPE=home"
) else if "%~1"=="-h" (
    echo Usage: %~nx0 [--texmflocal^|--texmfhome]
    echo   --texmflocal  Install into TEXMFLOCAL ^(requires admin, default^)
    echo   --texmfhome   Install into TEXMFHOME ^(user-local tree^)
    exit /b 0
) else (
    echo Unknown option: %~1
    exit /b 1
)
shift
if not "%~1"=="" goto :parse_args
:parse_done

for /f "tokens=2 delims== " %%a in ('findstr /C:"name =" "%TOML_FILE%"') do set "PACKAGE_NAME=%%~a"
for /f "tokens=2 delims== " %%a in ('findstr /C:"version =" "%TOML_FILE%"') do set "PACKAGE_VERSION=%%~a"
for /f "tokens=2 delims== " %%a in ('findstr /C:"entrypoint =" "%TOML_FILE%"') do set "PACKAGE_FILE=%%~a"

set "PACKAGE_NAME=%PACKAGE_NAME:"=%"
set "PACKAGE_VERSION=%PACKAGE_VERSION:"=%"
set "PACKAGE_FILE=%PACKAGE_FILE:"=%"
set "PACKAGE_FILE=%PACKAGE_FILE:/=\%"

call :detect_tex_distribution
if "%TEX_DISTRO%"=="" (
    echo No supported TeX distribution found.
    exit /b 1
)

call :get_texmf_path
if "%TEXMF_PATH%"=="" (
    echo Could not determine TEXMF path.
    exit /b 1
)

call :install_PACKAGE_FILE

echo.
echo Package %PACKAGE_NAME% version %PACKAGE_VERSION% installed successfully!
exit /b 0

:detect_tex_distribution
where tlmgr >nul 2>nul
if %ERRORLEVEL%==0 (
    set "TEX_DISTRO=texlive"
    exit /b 0
)

where miktex-console >nul 2>nul
if %ERRORLEVEL%==0 (
    set "TEX_DISTRO=miktex"
    exit /b 0
)

set "TEX_DISTRO="
exit /b 0

:get_texmf_path
if "%TEX_DISTRO%"=="texlive" (
    if "%INSTALL_SCOPE%"=="home" (
        for /f "delims=" %%A in ('kpsewhich -var-value=TEXMFHOME') do set "TEXMF_PATH=%%A"
    ) else (
        for /f "delims=" %%A in ('kpsewhich -var-value=TEXMFLOCAL') do set "TEXMF_PATH=%%A"
    )
    exit /b 0
)

if "%TEX_DISTRO%"=="miktex" (
    for /f "tokens=2 delims=," %%A in ('miktex-console --get-settings') do (
        set "TEXMF_PATH=%%A"
        goto :eof
    )
)

set "TEXMF_PATH="
exit /b 0


:install_PACKAGE_FILE
set "INSTALL_DIR=%TEXMF_PATH%\tex\latex\%PACKAGE_NAME%"

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>nul
)

copy "%PACKAGE_FILE%" "%INSTALL_DIR%" >nul

if "%TEX_DISTRO%"=="texlive" (
    if "%INSTALL_SCOPE%"=="home" (
        echo Installed to TEXMFHOME: %TEXMF_PATH%
        echo mktexlsr is not needed for TEXMFHOME.
    ) else (
        echo Running mktexlsr to refresh file database...
        mktexlsr
    )
)

if "%TEX_DISTRO%"=="miktex" (
    echo Updating MiKTeX file database...
    miktex-console --update-fndb
)

exit /b 0
