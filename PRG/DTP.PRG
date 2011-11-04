* ===========================================================================
*
* DTP - Direct Transaction Processing -  main program
*       start date: 08/05/96
*
* changes:
* 1. change radtrp.ntx to FCONTROL
* 2. allow user to enter company name (RDTRP1)
* 3. reprint misc form by control # (RRPTC)
* 4. verify plate # against plate history supplied by sos
* 5. print misc form by starting control # and ending control #
* 6. reprint from previous download file (RRPTC)
* 7. full-right to survivor should always be [N] (RDTP5A)
* 8. assign seq # in syn with control #  (RDTP1/DTPP)
* 9. correct calculation for commercial vehicle (RDTP1)
*10. add year to Tab file (ratab)
*    -dbsetup, raidx (ratab1, ratab2)
*11. system automatically assigned tab # (RDTP1)
*12. Create daily audit file (raaudit)
*    - dsetup, rapath, raidx (raaudit)
*13. check for daily duplication (RDTP1)
*14. Clean up tab file (ratab) & audit file (raaudit) during eod (rdpt5)
*15. ** major fault 05.10.98
*    check if vehicle has been plated (RDTP1)
*    update vehicle with org. plate, ie. when code = 5 (RDTP5a)
*    load tab with leading 0 (RINV4)
*    update tab with leading 0 (RINV5)
*    delete tab with leading 0 (RINV6)
* 08.18.99
* convert tr11 to laser form
* see rdtp, rdtp1, rdtp3a, rrpt1
* 01.03.07: skip [U] & use [V] for year 2007 (jdate)
*
* ===========================================================================
do while .t.
   begin sequence
      do rinit
      restore from (gmempath + "RAPATH.MEM") additive

      do while .t.
         if .not. usrlgin ()
            loop
         endif
         do while .t.
            xret0 = f_pushmenu ("MAIN MENU")
            if xret0 = 0
               if usrlgout (.t.)
                  exit
               else
                  loop
               endif
            endif
            xoption0 = substr (goption [xret0], 4)
            bliovlclr ()
            do case
            case xret0 = 1        && D.T.P. transactions
               do rdtp

            case xret0 = 2        && VEHICLE RECORD
               do rinv

            case xret0 = 3        && D.T.P. communication
               do rcom

            case xret0 = 4        && REPORT
               do rrpt

            case xret0 = 5        && SYSTEM MAINT.
               do rsys

            endcase
         enddo
      enddo
   end
   set key 28 to
   set key -1 to
   set key -2 to
   set key -3 to
   set key -4 to
   set key -5 to
   set key -6 to               && calculator
   set key -7 to               && phone book
   set key -8 to               && reminder
   set key -9 to               && calendar
   usrlgout (.f.)
enddo

*****************************
function f_goodvin
parameter xvin
private yvin

p1 = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
p2 = "123456780123450709234567890123456789"
wf = "8765432X098765432"

if len(alltrim(xvin)) <> 17
   f_valid (.f., "Invalid VIN #...")
   return .f.
endif

yvin = upper(xvin)
y3 = 0
for i = 1 to 17
   y1 = substr(yvin,i,1)
   y2 = val(substr(p2,at(y1,p1),1)) *    ;
        if(substr(wf,i,1)="X",10,val(substr(wf,i,1)))
   y3 = y3 + y2
next i
y4 = y3 - int(y3/11) * 11
cd = if(y4 = 10, "X", str(y4,1)) 

if cd <> substr(yvin,9,1) 
   f_valid (.f., "Please re-check VIN #....")
   if f_confirm ("[R]etype    [C]ontinue ", "RC") = "R"
      return .f.
   endif
endif

return .t.

**********************************************************************
function jdate

parameter xdate
private ydate, y1, y2, y3, yday, yyr, y4

ydate = dtoc (xdate)

y1 = substr(ydate,4,2)
y2 = substr(ydate,1,2)
y3 = substr(ydate,7,2)
y4 = substr(dtos(xdate),1,4)     && 01.04.00

yday = ctod (y2+"/01/"+y4) - ctod ("01/01/"+y4) + val(y1)

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

