:: File to keep claim browser up-to-date
:: ! Requires Python
pushd %~dp0

:: Downloads latest files
python .\download.py
python .\maps.py

:: Runs asset browser generator
nim r webgen.nim
cls
:: Reruns so that new users can be connected
nim r webgen.nim

pause