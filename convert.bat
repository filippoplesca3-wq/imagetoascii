@echo off
REM Double-click this to pick an image, or drag an image onto it.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0convert.ps1" %*
if errorlevel 1 pause