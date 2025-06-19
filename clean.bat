@echo off
echo Cleaning temporary files, please wait...

del /f /s /q .\*.d
del /f /s /q .\*.obj
del /f /s /q .\*.o
del /f /s /q .\*.pdb
del /f /s /q .\*.tlog
del /f /s /q .\*.VC.db
del /f /s /q .\*CMakeCache.txt

echo Cleanup completed!
@REM echo. & pause
