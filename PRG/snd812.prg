* =======================================
* re-create c:\spool\QEKFIN.txt (812 final approval respond)
* 1. get missing file (812JXXX.txt) - (remote)
* 2. Run snd812 ; xdate=missing date
* 3. Send qekfin.txt 
* 4. Resend file qekfin.txt to Ford CVMS
* =========================================
clear

xpath = "c:\spool\"
xbranch = [812]

yfil = space(50)
xdate = date()

@ 03,05 say "Date:  " get xdate
@ 04,05 say "File:  " get yfil
read

use sostran alias sostran
zap
append from &yfil sdf

yfil = xpath + "QEKFIN.TXT"
set device to print
set printer to &yfil
setprc (0,0)
* write header
yln = 0
@yln, 0 say "FIN  QEKAPPROVAL  "+dtos(xdate)
yln = yln + 1
select sostran
go top
do while .not. eof ()
   xvin = F32VIN
   xplate = F21PLATE
   @yln, 0 say xvin+xplate+[000APPROVED]
   yln = yln + 1
   skip
enddo
* write trailer
@yln, 0 say "QEKAPPROVAL  "+dtos(xdate)+"   "+strtran(str(yln-1,5)," ","0")

set printer to
set console on
set print off
set device to screen

