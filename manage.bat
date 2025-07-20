:: Runs all automated tasks for website
pushd %~dp0

cd files
cd claims
call update.bat

:: if you add more .bat files elsewhere, remember to 'cd..' out of 'claims' folder