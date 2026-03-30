:: Runs all automated tasks for website
pushd %~dp0

cd files
cd claims
call update.bat

nim r validator.nim

:: if you add more .bat files elsewhere, remember to 'cd..' out of 'claims' folder
cd..
cd..
:: sets better timestamps
set "YYYY=%DATE:~-4,4%"
set "MM=%DATE:~-7,2%"
set "DD=%DATE:~-10,2%"

set "HH=%TIME:~0,2%"
set "MIN=%TIME:~3,2%"
:: adds and commits all updated claim files, so that they don't clutter Git's diff
@REM git add "files/claims/b3d"
git add "files/claims/bdata"
@REM git add "files/claims/fsam"
@REM git add "files/claims/ioa"
:: adds log file, so that you can see in commit what changed (due to how Git works, log.txt diff will serve as sort of quicker commit diff)
git add "files/claims/log.txt"
git commit -m "Automated claims update: %YYYY%-%MM%-%DD%, %HH%:%MIN%"
:: push is ommited so that it can be bundled with other actions if needed; new window is opened though for easier git management
start cmd.exe /k echo Automated claim update might have been commited. Opened terminal window for easier management. ^
If you want to upload your commits to the Git, use `git push origin HEAD` command, creating new branch you can use for PR.