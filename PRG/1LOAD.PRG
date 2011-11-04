*
* initial load for CVMS data warehouse
*
* Branch #        1       3
* Date            4      11
* VIN             12     28
* Plate #         29     35 
* Clerk ID        36     36 
* Action Code     37     37 
* Tab #           38     44 
* Title Fee       45     50 
* Transfer Fee    51     56 
* Reg. Fee        57     62
* Total           63     68 
* Reference       69     83
* Owner           84    109

ydate1 = ctod ('01/01/2002')
ydate2 = ctod ('01/31/2004')

use radtrh

ypath = "c:\spool\"
yfil = ypath+"cvmsdata.txt"
set device to print
set printer to &yfil
setprc (0,0)
yln = 0
go top
do while .not. eof ()
   if fdate >= ydate1 .and. fdate <= ydate2
      @ yln, 00 say fbranch+dtos(fdate)+fvin+fplate+fclerk+faction+ftab+   ;
            str(ftitle,6,2)+str(ftfee,6,2)+str(freg,6,2)+str(ftotal,6,2)+  ;
            fref+fowner
      yln = yln + 1
   endif
   skip
enddo
@ yln, 00 say str(yln,10)
set printer to
set console on
set print off
set device to screen

