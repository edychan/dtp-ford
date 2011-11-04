@ECHO OFF
set obj=c:\dtp\lib
set lib=c:\dtp\lib
cd..\obj
BLINKER @BRAC
copy dtp.exe c:\dtp\ford\dtp\dtp.exe
DEL dtp.EXE
cd..\prg

