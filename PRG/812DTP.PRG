* ===============================================
* QEK/CVMS - 812 daily processing control program
* changes:
* 04.18.06: add 804 transaction processing
* 12.11.06: reject blue plate (plate desc code=[003]
* 01.03.07: skip [U] for jdate !!
* 05.03.07: take out 804 transaction (NREPORT.*) & process in DTPP.prg
* ===============================================
set excl off
set delete on
clear

* gdbfpath = "f:\dtp\ford\dtp\dbf\"     && in house use only **
gdbfpath = "f:\dtp\dbf\"

? "812 Daily processing"
*
yfil = "transit.dbf"
if .not. file (yfil)
   ytmp = "tmp.dbf"
   create &ytmp
   append blank
   replace field_name with "FIELD"
   replace field_type with "C"
   replace field_len with 132
   replace field_dec with 0 
   create &yfil from &ytmp
   use
   erase &ytmp
endif
*
* yfil = "c:\spool\NREPORT.*"
* if file (yfil)
*    do d804TR
* else
*    ? "Skip: 804 transaction process "
* endif
*
yfil = "c:\spool\812INT.*"
if file (yfil)
   do d812int
else
  ? "Skip: Initial REQ process "
endif
*
yfil = "c:\spool\812FIN.*"
if file (yfil)
   do d812fin
else
   ? "Skip: Final Approval process"
endif
*
? "812 daily processing completed"
inkey(5)

close all
return

************************
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
endcase
return (yyr+strtran(str(yday,3)," ","0"))

*********************
function chkplate
* changes:
* 10.30.06: add new white plate configuration
*           add new return parameter for plate desc 
*
parameter xplate, xpdesc
private yplate, yok
private yp1, yp2, yp3, yp4, yp5, yp6, yp7

yplate = xplate
yp1 = substr(yplate, 1, 1)
yp2 = substr(yplate, 2, 1)
yp3 = substr(yplate, 3, 1)
yp4 = substr(yplate, 4, 1)
yp5 = substr(yplate, 5, 1)
yp6 = substr(yplate, 6, 1)
yp7 = substr(yplate, 7, 1)
yok = .f.
xpdesc = space(3)

do case
   * 12.01.04: AAA9999
   case len (alltrim(yplate)) = 7
      do case
      case isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6) .and. ;
      .not.isalpha (yp7)
         if yplate >= [AAA0000] .and. yplate <= [AZZ9999]
            xpdesc = [003]
         else   
            xpdesc = [009]       && new passenger white plate
         endif
         yok = .t.
      * AA99999 
      case isalpha (yp1) .and. isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6) .and. ;
      .not.isalpha (yp7)
         if (yplate >= [CA00000] .and. yplate <= [EZ99999]) .or. ;
          (yplate >= [GA00000] .and. yplate <= [QZ99999]) .or. ;
          (yplate >= [SA00000] .and. yplate <= [ZZ99999]) 
           xpdesc = [009]       && new commercial white plate
         endif
         yok = .t.
      endcase
   case len (alltrim(yplate)) = 5  && test for commermorative
      do case
      * AAA99
      case isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
         .not.isalpha (yp4) .and. .not.isalpha (yp5)            
         xpdesc = [004]
         yok = .t.
      * 99AAA
      case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. ;
         isalpha (yp3) .and. isalpha (yp4) .and. isalpha (yp5)  
         xpdesc = [004]
         yok = .t.
      endcase
   * 9AAA99 ==> [001]: Bridge plate
   case .not.isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
      isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6)
      if yp2+yp3+yp4 >= [AAA] .and. yp2+yp3+yp4 <= [GZZ]
         xpdesc = [001]
      else 
         xpdesc = [010]      && 10.30.06: new passenger distinctive plate
      endif
      yok = .t.
   * 99AAA9 
   case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. isalpha (yp3) .and. ;
      isalpha (yp4) .and. isalpha (yp5) .and. .not.isalpha (yp6)
      xpdesc = [001]
      yok = .t.
   * 999AAA ==> [003]: Blue & white
   case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      isalpha (yp4) .and. isalpha (yp5) .and. isalpha (yp6)
      xpdesc = [003]      && bug fix: 03.26.02
      yok = .t.           && 03.26.02
   * AAA999 
   case isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6)
      xpdesc = [003] 
      yok = .t.
   * AA999A
   case isalpha (yp1) .and. isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. isalpha (yp6)
      xpdesc = [003]
      yok = .t.
   * A999AA
   case isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. isalpha (yp5) .and. isalpha (yp6)
      xpdesc = [003]
      yok = .t.
   * A9999A ==> [001]: Bridge plate
   case isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. isalpha (yp6)
      if yplate >= [A0000A] .and. yplate <= [F9999Z]
         xpdesc = [001]
      else
         xpdesc = [010]      && 10.30.06: new commercial distinctive plate
      endif
      yok = .t.
   * AA9999 ==> [003]: Blue & white 
   case isalpha (yp1) .and. isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6)
      xpdesc = [003] 
      yok = .t.
   * 9999AA
   case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. isalpha (yp5) .and. isalpha (yp6)
      xpdesc = [003]
      yok = .t.
   * 9AA999
   case .not.isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6)
      xpdesc = [003]
      yok = .t.
   * 999AA9
   case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      isalpha (yp4) .and. isalpha (yp5) .and. .not.isalpha (yp6)
      xpdesc = [003]
      yok = .t.
endcase

return yok
