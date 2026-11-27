@echo off
title GoGoGo SuperApp Clone Server
echo Menjalankan GoGoGo SuperApp Clone di http://127.0.0.1:8080 ...
start "" "http://127.0.0.1:8080"
powershell -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port 8080
