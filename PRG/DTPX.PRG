*
*  output monthly subtotal for transfer, new plate, renewals
parameter sdate, edate, xtype
clear
set confirm on
set excl off
set century on 

if pcount () < 2
   ? [usage is DTPX 09/01/2002 08/31/2003]
   quit
endif

ystart = ctod(sdate)
yend = ctod(edate)
* ytype = xtype             && eg. 3,4,7,9

* set the counter
declare nxfer[12], totxfer[12], nnew[12], totnew[12]
declare nc [12], totc [12], np [12], totp [12]
afill (nxfer, 0)
afill (totxfer, 0)
afill (nnew, 0)
afill (totnew, 0)
afill (nc, 0)
afill (totc, 0)
afill (np, 0)
afill (totp, 0)
* set the path
ypath = "f:\dtp\dbf\"
select 0
yfil = ypath + "radtrh"
use &yfil alias radtrh

select radtrh
go top
do while .not. eof ()
   if fdate >= ystart .and. fdate <= yend
      i = val(substr(dtoc(fdate),1,2))
      if i > 0 .and. i <=12
         if faction $ [3,7]
            nxfer[i] = nxfer[i] + 1
            totxfer[i] = totxfer[i] + ftfee
         endif
         if faction $ [2,5]
            nnew[i] = nnew[i] + 1
            totnew[i] = totnew[i] + freg
         endif
         if faction $ [4,6,9]
            if chkplate (fplate)
               np[i] = np[i] + 1
               totp[i] = totp[i] + freg
            else    && commercial
               nc[i] = nc[i] + 1
               totc[i] = totc[i] + freg
            endif
         endif
      endif
   endif
   skip
enddo

ystr1 = ""
ystr2 = ""
ystr3 = ""
ystr4 = ""
ystr5 = ""
ystr6 = ""
ystr7 = ""
ystr8 = ""
store 0 to t1,t2,t3,t4,t5,t6,t7,t8

for i = 1 to 12
   ystr1 = ystr1 + str(nxfer[i],10,0) + " "
   ystr2 = ystr2 + str(totxfer[i],10,2) + " "
   ystr3 = ystr3 + str(nnew[i],10,0) + " "
   ystr4 = ystr4 + str(totnew[i],10,2) + " "

   ystr5 = ystr5 + str(nc[i],10,0) + " "
   ystr6 = ystr6 + str(totc[i],10,2) + " "
   ystr7 = ystr7 + str(np[i],10,0) + " "
   ystr8 = ystr8 + str(totp[i],10,2) + " "

   t1 = t1 + nxfer[i]
   t2 = t2 + totxfer[i]
   t3 = t3 + nnew[i]
   t4 = t4 + totnew [i]
   t5 = t5 + nc[i]
   t6 = t6 + totc[i]
   t7 = t7 + np[i]
   t8 = t8 +totp[i]
next

set console off
set print on
set printer to sss         

? "1: "+ystr1 + " == " + str(t1,10,0)
? "2: "+ystr2 + " == " + str(t2,10,2)
?
? "3: "+ystr3 + " == " + str(t3,10,0)
? "4: "+ystr4 + " == " + str(t4,10,2)
?
? "5: "+ystr5 + " == " + str(t5,10,0)
? "6: "+ystr6 + " == " + str(t6,10,2)
?
? "7: "+ystr7 + " == " + str(t7,10,0)
? "8: "+ystr8 + " == " + str(t8,10,2)
?
? "[1]: # of transfer "
? "[2]: $ of transfer "
? "[3]: # of new plate "
? "[4]: $ of new plate "
? "[5]: # of commercial "
? "[6]: $ of commercial "
? "[7]: # of passenger "
? "[8]: $ of passenger "

set print off
set printer to
set console on
set device to screen

*****
function chkplate
parameter xplate
private yplate, yok
* if plate is passenger return .t. else .f.

yplate = xplate
yp1 = substr(yplate, 1, 1)
yp2 = substr(yplate, 2, 1)
yp3 = substr(yplate, 3, 1)
yp4 = substr(yplate, 4, 1)
yp5 = substr(yplate, 5, 1)
yp6 = substr(yplate, 6, 1)
yok = .t.
do case
   case len (alltrim(yplate)) = 5  && test for commermorative
      do case
      * AAA99
      case isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
         .not.isalpha (yp4) .and. .not.isalpha (yp5)            
         yok = .t.
      * 99AAA
      case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. ;
         isalpha (yp3) .and. isalpha (yp4) .and. isalpha (yp5)  
         yok = .t.
      endcase
   * 9AAA99 ==> [001]: Bridge plate
   case .not.isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
      isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6)
      yok = .t.
   * 99AAA9 
   case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. isalpha (yp3) .and. ;
      isalpha (yp4) .and. isalpha (yp5) .and. .not.isalpha (yp6)
      yok = .t.
   * 999AAA ==> [003]: Blue & white
   case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      isalpha (yp4) .and. isalpha (yp5) .and. isalpha (yp6)
      * ypdesc = [003]    && bug fix: 03.26.02
      yok = .t.           && 03.26.02
   * AAA999 
   case isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6)
      yok = .t.
   * AA999A
   case isalpha (yp1) .and. isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. isalpha (yp6)
      yok = .t.
   * A999AA
   case isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. isalpha (yp5) .and. isalpha (yp6)
      yok = .t.
   * commercial
   * A9999A ==> [001]: Bridge plate
   case isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. isalpha (yp6)
      yok = .f.
   * AA9999 ==> [003]: Blue & white 
   case isalpha (yp1) .and. isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6)
      yok = .f.
   * 9999AA
   case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. isalpha (yp5) .and. isalpha (yp6)
      yok = .f.
   * 9AA999
   case .not.isalpha (yp1) .and. isalpha (yp2) .and. isalpha (yp3) .and. ;
      .not.isalpha (yp4) .and. .not.isalpha (yp5) .and. .not.isalpha (yp6)
      yok = .f.
   * 999AA9
   case .not.isalpha (yp1) .and. .not.isalpha (yp2) .and. .not.isalpha (yp3) .and. ;
      isalpha (yp4) .and. isalpha (yp5) .and. .not.isalpha (yp6)
      yok = .f.
endcase

return yok

