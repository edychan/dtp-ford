* =======================================
* re-create c:\spool\ford804.txt
* 1. get missing file (804JXXX.txt) from 804 (remote)
* 2. Run snd804 ;
*        xdate=missing date, xbatchno=804 CTR (rasys.dbf)
* 3. Send ford804.txt to 804
* 4. 804 resend file ford804.txt to Ford CVMS
* =========================================
clear
yfil = space(50)
xdate = date()
xbatchno = 0

@ 03,05 say "Date:  " get xdate
@ 04,05 say "Batch: " get xbatchno pict "9999"
@ 05,05 say "File:  " get yfil
read

use sostran alias sostran
zap
append from &yfil sdf

yfil = "c:\spool\ford804.txt"
set device to print
set printer to &yfil
setprc (0,0)


* write header
yln = 0
@yln, 0 say [HDR]+[  ]+[CVMS 435U  ]+  ;
        strtran(dtoc(xdate),"/","-")+[   ]+strtran(str(xbatchno,10)," ","0")
yln = yln + 1
select sostran
go top
do while .not. eof () 
   do case
   case F06RCODE = [P] .and. F07TCODE = [A]
      ycode = [1]
   case F06RCODE = [A] .and. F07TCODE = [A]
      ycode = [2]
   case F06RCODE = [G] .and. F07TCODE = [A]
      ycode = [3]
   case F06RCODE = [H] .and. F07TCODE = [A]
      ycode = [4]
   case F06RCODE = [A] .and. F07TCODE = [ ]
      ycode = [5]
   case F06RCODE = [B] .and. F07TCODE = [ ]
      ycode = [6]
   case F06RCODE = [G] .and. F07TCODE = [ ]
      ycode = [7]
   case F06RCODE = [H] .and. F07TCODE = [ ]
      ycode = [9]
   otherwise
      ycode = [ ]
   endcase
   yfld = F09BRANCH + ;
          F08JDATE + ;
          F10SEQ + ;
          F32VIN + ;
          F21PLATE + ;
          F22PPLATE + ;
          ycode + ;
          F16TITLE + ;        && Title + transfer fee (e.g. 15+8)
          F19REG + ;          && registration fee
          [00000000] + ;      && extra fee not used
          F25TAB + ;
          substr(F23EXP,1,4)+[20]+substr(F23EXP,5,2) + ;  
          substr(F45NAME,1,36)
   @yln, 0 say yfld
   yln = yln + 1
   skip
enddo

* write trailer
@yln, 0 say "TRL"+[  ]+strtran(dtoc(xdate),"/","-")+[   ]+strtran(str(yln-1,5)," ","0")

set printer to
set console on
set print off
set device to screen

