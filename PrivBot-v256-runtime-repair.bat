@echo off
setlocal enableextensions

set "SCRIPT_DIR=%~dp0"
if defined SCRIPT_DIR if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "BASE=%SCRIPT_DIR%"
if not exist "%BASE%\PrivBotLauncher.jar" set "BASE=%LOCALAPPDATA%\PrivBot"
set "RUNTIME=%BASE%\runtime"
set "RUNTIME11=%BASE%\runtime-11"
set "EXE=%BASE%\PrivBot.exe"
set "JAR=%BASE%\PrivBotLauncher.jar"
set "MANIFEST_URL=https://downloads.privbot.dev/updates/manifest.json"
set "PORTABLE_URL_FORMAT=https://downloads.privbot.dev/PrivBot-{0}-portable.zip"

echo.
echo ============================================================
echo PrivBot Runtime Repair (Generic)
echo ============================================================
echo.
echo Install path: %BASE%
echo.

echo [1/5] Closing running PrivBot processes...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Get-CimInstance Win32_Process | Where-Object { ($_.Name -eq 'javaw.exe' -or $_.Name -eq 'java.exe' -or $_.Name -eq 'PrivBot.exe') -and ($_.CommandLine -like '*PrivBotLauncher.jar*' -or $_.CommandLine -like '*\AppData\Local\PrivBot\*') } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }" >nul 2>nul
taskkill /f /im PrivBot.exe >nul 2>nul

if not exist "%JAR%" (
  echo [WARN] PrivBot installation is missing/incomplete at:
  echo         %BASE%
  echo.
  echo Attempting automatic reinstall from latest portable package...
  call :reinstall_latest
  if errorlevel 1 (
    echo [ERROR] Automatic reinstall failed. Please run the latest PrivBot installer.
    pause
    exit /b 1
  )
  if not exist "%JAR%" (
    echo [ERROR] Reinstall finished but PrivBotLauncher.jar is still missing.
    pause
    exit /b 1
  )
)

call :runtime_ok "%RUNTIME%" RUNTIME_OK
call :runtime_ok "%RUNTIME11%" RUNTIME11_OK

if "%RUNTIME_OK%"=="0" (
  if "%RUNTIME11_OK%"=="0" (
    echo [WARN] Both runtime and runtime-11 are missing/corrupt:
    echo         %RUNTIME%
    echo         %RUNTIME11%
    echo.
    echo Attempting automatic reinstall from latest portable package...
    call :reinstall_latest
    if errorlevel 1 (
      echo [ERROR] Automatic reinstall failed. Please run the latest PrivBot installer.
      pause
      exit /b 1
    )
    call :runtime_ok "%RUNTIME%" RUNTIME_OK
    call :runtime_ok "%RUNTIME11%" RUNTIME11_OK
    if "%RUNTIME_OK%"=="0" if "%RUNTIME11_OK%"=="0" (
      echo [ERROR] Reinstall completed but runtimes are still unusable.
      pause
      exit /b 1
    )
    goto after_runtime_repair
  )
  echo [2/5] Restoring runtime from runtime-11...
  if exist "%RUNTIME%" rmdir /s /q "%RUNTIME%" >nul 2>nul
  robocopy "%RUNTIME11%" "%RUNTIME%" /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NC /NS >nul
  if errorlevel 8 (
    echo [ERROR] Runtime repair failed. Please reboot and run this fixer again.
    pause
    exit /b 1
  )
  call :runtime_ok "%RUNTIME%" RUNTIME_OK
  if "%RUNTIME_OK%"=="0" (
    echo [ERROR] Runtime is still unusable after repair.
    pause
    exit /b 1
  )
) else (
  echo [2/5] runtime folder is healthy. No copy needed.
)

:after_runtime_repair
echo [3/5] Clearing stuck pending update...
if exist "%BASE%\updates\pending" (
  rmdir /s /q "%BASE%\updates\pending" >nul 2>nul
)

echo [4/5] Starting PrivBot...
if exist "%RUNTIME%\bin\javaw.exe" if exist "%RUNTIME%\bin\awt.dll" (
  start "" "%RUNTIME%\bin\javaw.exe" -jar "%JAR%"
  goto launched
)
if exist "%RUNTIME%\bin\java.exe" if exist "%RUNTIME%\bin\awt.dll" (
  start "" "%RUNTIME%\bin\java.exe" -jar "%JAR%"
  goto launched
)
if exist "%RUNTIME11%\bin\javaw.exe" if exist "%RUNTIME11%\bin\awt.dll" (
  start "" "%RUNTIME11%\bin\javaw.exe" -jar "%JAR%"
  goto launched
)
if exist "%RUNTIME11%\bin\java.exe" if exist "%RUNTIME11%\bin\awt.dll" (
  start "" "%RUNTIME11%\bin\java.exe" -jar "%JAR%"
  goto launched
)
if exist "%EXE%" (
  start "" "%EXE%"
  goto launched
)

echo [ERROR] Unable to start PrivBot. Please reinstall the latest build.
pause
exit /b 1

:launched
echo [5/5] Repair complete. PrivBot should now launch and self-update.
echo.
pause
exit /b 0

:runtime_ok
set "%~2=0"
set "RT=%~1"
if not exist "%RT%\bin\awt.dll" goto :eof
if exist "%RT%\bin\javaw.exe" (
  set "%~2=1"
  goto :eof
)
if exist "%RT%\bin\java.exe" (
  set "%~2=1"
  goto :eof
)
if exist "%RT%\bin\java" set "%~2=1"
goto :eof

:reinstall_latest
echo [2/5] Downloading latest PrivBot portable package...
set "TMP_ZIP=%TEMP%\PrivBot-repair-%RANDOM%-%RANDOM%.zip"
set "TMP_STAGE=%TEMP%\PrivBot-repair-stage-%RANDOM%-%RANDOM%"
if exist "%TMP_ZIP%" del /f /q "%TMP_ZIP%" >nul 2>nul
if exist "%TMP_STAGE%" rmdir /s /q "%TMP_STAGE%" >nul 2>nul

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ErrorActionPreference='Stop';" ^
  "[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12;" ^
  "$manifestUrl='%MANIFEST_URL%';" ^
  "if ($manifestUrl.Contains('?')) { $manifestUrl += '&t=' + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() } else { $manifestUrl += '?t=' + [DateTimeOffset]::UtcNow.ToUnixTimeSeconds() };" ^
  "$manifest = Invoke-RestMethod -Uri $manifestUrl -Headers @{ 'Cache-Control'='no-cache, no-store, must-revalidate' };" ^
  "$version = [string]$manifest.version;" ^
  "if ([string]::IsNullOrWhiteSpace($version)) { throw 'Update manifest missing version' };" ^
  "$url = '';" ^
  "if ($manifest.bundle -and $manifest.bundle.url) { $url = [string]$manifest.bundle.url };" ^
  "if ([string]::IsNullOrWhiteSpace($url)) { $url = [string]::Format('%PORTABLE_URL_FORMAT%', $version.Trim()) };" ^
  "Invoke-WebRequest -Uri $url -OutFile '%TMP_ZIP%' -UseBasicParsing;" ^
  "Expand-Archive -Path '%TMP_ZIP%' -DestinationPath '%TMP_STAGE%' -Force;"
if errorlevel 1 (
  if exist "%TMP_ZIP%" del /f /q "%TMP_ZIP%" >nul 2>nul
  if exist "%TMP_STAGE%" rmdir /s /q "%TMP_STAGE%" >nul 2>nul
  exit /b 1
)

if not exist "%TMP_STAGE%\PrivBotLauncher.jar" (
  if exist "%TMP_ZIP%" del /f /q "%TMP_ZIP%" >nul 2>nul
  if exist "%TMP_STAGE%" rmdir /s /q "%TMP_STAGE%" >nul 2>nul
  exit /b 1
)

if not exist "%BASE%" mkdir "%BASE%" >nul 2>nul
robocopy "%TMP_STAGE%" "%BASE%" /E /R:1 /W:1 /NFL /NDL /NJH /NJS /NC /NS ^
  /XF "PrivBot-runtime-repair.bat" "PrivBot-v256-runtime-repair.bat" >nul
if errorlevel 8 (
  if exist "%TMP_ZIP%" del /f /q "%TMP_ZIP%" >nul 2>nul
  if exist "%TMP_STAGE%" rmdir /s /q "%TMP_STAGE%" >nul 2>nul
  exit /b 1
)

if exist "%TMP_ZIP%" del /f /q "%TMP_ZIP%" >nul 2>nul
if exist "%TMP_STAGE%" rmdir /s /q "%TMP_STAGE%" >nul 2>nul
echo     Reinstalled latest package into %BASE%
exit /b 0
