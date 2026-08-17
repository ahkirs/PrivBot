@echo off
setlocal
set "APPDIR=%~dp0"
set "JAVA="
if exist "%APPDIR%runtime-11\\bin\\javaw.exe" if exist "%APPDIR%runtime-11\\bin\\awt.dll" set "JAVA=%APPDIR%runtime-11\\bin\\javaw.exe"
if not defined JAVA if exist "%APPDIR%runtime-11\\bin\\java.exe" if exist "%APPDIR%runtime-11\\bin\\awt.dll" set "JAVA=%APPDIR%runtime-11\\bin\\java.exe"
if not defined JAVA if exist "%APPDIR%runtime\\bin\\javaw.exe" if exist "%APPDIR%runtime\\bin\\awt.dll" set "JAVA=%APPDIR%runtime\\bin\\javaw.exe"
if not defined JAVA if exist "%APPDIR%runtime\\bin\\java.exe" if exist "%APPDIR%runtime\\bin\\awt.dll" set "JAVA=%APPDIR%runtime\\bin\\java.exe"
if not defined JAVA (
  echo Bundled runtime not found.
  exit /b 1
)
start "" "%JAVA%" -jar "%APPDIR%PrivBotLauncher.jar"
