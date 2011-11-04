clipper dtpsu -l -o..\obj
if errorlevel 1 goto exit 
cd ..\obj
blinker @dtpsu
copy dtpsu.exe F:\dtp\FORD\DTP
del dtpsu.exe
cd ..\PRG
