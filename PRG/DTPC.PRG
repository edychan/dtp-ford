*
* supplement program to calculate individual document counts
*
* current setting:
* record 04 : TR11 for leasee
* record 05 : 37-100 used car Veh. Record      (stop using)
* record 06 : 765A Lease agreement
* record 07 : T164 Proof of Insurance
* record 08 : TR11 for Ind.
* record 09 : TR11 for damaged
* record 10 : 2023 Appointment of Agent
* record 11 : 51A statement of repair damages  (stop using)
* record 15 : TR11 for title only
* record 16 : Vehicle Invoices                 (stop using)
* record 17 : proof of ins. out of MI          (06.14.99)
*
* documents saved in f:\dtp\ftp\jdate(date())+[.ftp]
*
clear
set confirm on
set excl off

set century on 
ystart = date()
yend = date()
yans = [ ]
do while .t.
   @ 05, 05 say "Enter Starting Date: " get ystart pict "@D"
   @ 06, 05 say "Enter Ending Date:   " get yend pict "@D" valid  ;
     yend >= ystart 
   read
   @ 07, 05 say "Are you sure [Y/N] ? " get yans pict "!" valid  ;
     yans $ [YN]
   read
   if yans = [Y]
      exit
   elseif lastkey () = 27
      quit
   endif
enddo
set century off

* set the counter
t01 = 0     && tr11
t02 = 0     && tr11d
t05 = 0
t06 = 0
t07 = 0
t10 = 0
t11 = 0
t15 = 0
t16 = 0

* set the range
ypath = "f:\dtp\ftp\"
i = ystart
set excl on
select 0
use transit alias transit
zap
set excl off
do while i <= yend
   declare nfile[5]
   ypat = ypath + jdate(i) + "*.ftp"
   nf=adir(ypat,nfile)
   asort(nfile)
   nf=if(nf>5,5,nf)
   for j = 1 to nf
      @ 09, 05 say  "Processing " + nfile[j] + space(10)
      yfil = ypath+alltrim(upper(nfile[j]))
      select transit
      zap
      append from &yfil sdf
      y1 = 0
      y2 = 0
      * 37-100 Used Car Record
      t05 = t05 + f_getptr ("05", 44)     
      * 765A Lease
      t06 = t06 + f_getptr ("06", 16)     
      * T164 Proof of Ins
      t07 = t07 + f_getptr ("07", 16)     
      * 2023 Appointment of Agent
      t10 = t10 + f_getptr ("10", 38)     
      * 51A stmt of repair
      t11 = t11 + f_getptr ("11", 50)     
      * TR11 for titly only
      t15 = t15 + f_getptr ("15", 70)
      * accumulate proof of out of state ins instead of vehicle invoice
      * t16 = t16 + f_getptr ("16", 54)     
      t16 = t16 + f_getptr ("17", 21)     
   next j 
   i = i + 1
enddo
select transit
zap
use

* count tr11 from radtrh
yfil = "f:\dtp\dbf\radtrh"
select 0
use &yfil alias radtrh
go top
do while .not. eof ()
   if fdate >= ystart .and. fdate <= yend
      if ftr11
         t01 = t01 + 1
      else
         t02 = t02 + 1
      endif
   endif
   skip
enddo

clear
? "Report Summary:"
?
? "From: " + dtoc(ystart)
? "To:   " + dtoc(yend)
?
? "TR11:                           " + str(t01,10)
? "TR11D:                          " + str(t02,10)
? "Total TR11:                     " + str(t01+t02,10)                         
?
? "37-100 Used Car Vehicle Record: " + str(t05,10)
? "765A Lease Agreement:           " + str(t06,10)
? "T164 Proof of Insurance:        " + str(t07,10)
? "2023 Appointment of Agent:      " + str(t10,10)
? "51A Statement of Repair Damages:" + str(t11,10)
? "Out of State Proof of Insurance:" + str(t16,10)
? "TR11 for title only:            " + str(t15,10)
?
? "Total:                          " + str(t01+t02+t05+t06+t07+t10+t11+t15+t16,10)
?
?
?
?
?
?
? "Process Completed...<Press any key>"
inkey (0)

**********************************************************************
function f_getptr
parameter xnum, xlines

x1 = 0
x2 = 0
select transit
go top
locate for "RECORD " + xnum $ field 
if .not. eof ()
   x1 = recno()
   skip
   do while .not. eof () 
      if  "RECORD " $ field .or. "END OF FILE" $ field
         x2 = recno()
         exit
      endif
      skip
   enddo
   x2 = if(x2 > 0, x2, x1)
   return (int((x2-x1) / xlines))
else
   return (0)
endif


***********************************************
* 01.03.07: skip [U] & use [V] for year 2007
function jdate

parameter xdate
private ydate, y1, y2, y3, yday, yyr

ydate = dtoc (xdate)

y1 = substr(ydate,4,2)
y2 = substr(ydate,1,2)
y3 = substr(ydate,7,2)

yday = ctod (y2+"/01/"+y3) - ctod ("01/01/"+y3) + val(y1)

do case
   case y3 = "96"
     yyr = "G"
   case y3 = "97"
     yyr = "H"
   case y3 = "98"
     yyr = "J"
   case y3 = "99"
     yyr = "K"
   case y3 = "00"
     yyr = "L"
   case y3 = "01"
     yyr = "M"
   case y3 = "02"
     yyr = "N"
   case y3 = "03"
     yyr = "P"
   case y3 = "04"
     yyr = "R"
   case y3 = "05"
     yyr = "S"
   case y3 = "06"
     yyr = "T"
*   case y3 = "07"
*     yyr = "U"
   case y3 = "07"
     yyr = "V"
   case y3 = "08"
     yyr = "W"
   case y3 = "09"
     yyr = "X"
   case y3 = "10"
     yyr = "Y"
   case y3 = "11"
     yyr = "Z"
   otherwise
     yyr = " "
endcase
return (yyr+strtran(str(yday,3)," ","0"))

