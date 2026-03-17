@echo off
echo Cleaning up temporary files, please wait...

del /f /s /q .\*.d
del /f /s /q .\*.obj
del /f /s /q .\*.o
del /f /s /q .\*.tlog
del /f /s /q .\*.VC.db
del /f /s /q .\*.vcxproj
del /f /s /q .\*.vcxproj.filters
del /f /s /q .\*.sln
del /f /s /q .\*CMakeCache.txt

echo Clean up completed!
@REM echo. & pause
