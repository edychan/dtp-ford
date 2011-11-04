*
* create refund.dbf
*
select 0
use refund alias refund
select 0
use err alias err
go top
do while .not. eof()

    ydate = jdate(err->fdate)
    yyear = [20]+substr(err->fref,1,2)
    ymake = substr(err->fref,4)
    ybranch = [804]
    yref = [804]+ydate+err->fseq
    xmsrp = val(funit)
    select refund
    append blank
    replace refno with yref
    replace vin with err->fvin
    replace branch with [804]
    replace jdate with ydate
    replace plate with err->fplate
    replace seq with err->fseq
    replace rundate with err->fdate
    replace make with ymake
    replace year with yyear
    replace owner with err->fowner
    replace type with [B]
    replace msrp with xmsrp
    replace paid with err->freg
    replace audit with err->ftotal
    replace adj with err->freg-err->ftotal

    select err
    skip
enddo

close all

**********************************************************************
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



    
