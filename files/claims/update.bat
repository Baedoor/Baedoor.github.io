:: File to keep claim browser up-to-date
:: ! Requires Python
pushd %~dp0

:: Downloads latest files
python .\download.py

:: Runs asset browser generator
nim r webgen.nim

pause