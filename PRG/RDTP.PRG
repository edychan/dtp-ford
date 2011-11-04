* ===========================================================================
* DTP - title/plate processing
*
* Date:   09/22/94
* Author: EDC
*
* Revision:
* 09.21.98: ADD LASER PRINTER ROUTINE (PR_INIT, PR_TR11, PR_TR1L)
* 03.16.99: print garage code on registration (PR_TR1L)
* 12.15.99: printing: allow commercial plate on passenger cars
* 03.26.03: address assignment according to tag type (override)
* 11.06.03: add parameter to set printer in (pr_tr11, pr_tr1l)
* 03.20.06: print odometer reading (10 miles) for title application (TR11)
* 10.03.06: add F tag (pr_tr11, pr_tr1l)
* 10.03.06: print lien holder info (pr_tr11)
* 12.01.06: print previous plate # on registration form
* 02.26.06: add fields fcounty1, fcounty2, fctyname1, fctyname2 in RALOC.DBF
*
* 01.24.08: Special handling of LAND ROVER
* ===========================================================================

do while .t.
   xret1 = f_pushmenu (xoption0)
   if xret1 = 0
      exit
   endif
   xoption1 = substr (goption [xret1], 4)
   do case
      case xret1 = 1            && create tran
         do rdtp1
      case xret1 = 2            && edit tran
         do rdtp2
      case xret1 = 3            && print TR11
         do rdtp3 
      case xret1 = 4            && end of day processing
         do rdtp4
      case xret1 = 5            && print/reprint end of day reports
         do rdtp5
      case xret1 = 6            && view history record
         do rdtp6
      case xret1 = 7            && renewal sub system
         do rdtp7
      case xret1 = 8            && view 812 initial req. records
         do rdtp8
   endcase
enddo

*********************
* initialize laser printer
function pr_init
parameter xprinter, xtype
private yfil

if xtype = 1
   yfil = "VTLE.DEF"
else
   yfil = "VREG.DEF"
endif
if .not. file (yfil)
   f_valid (.f., "Macro File Missing ...")
   return .f.
endif
f_popup ("Please Wait While Loading Macros...")
! copy &yfil &xprinter >null
if file ("jqp.ldf")     && signature file
   ! copy jqp.ldf &xprinter >null
endif
f_popback ()
return .t.

**********************
* print tab
* note:
* 1. calling routine open radtrh, ravm, rabody, raplate
* 2. xtype = 1 ==> print tab
* 3. xtype = 2 ==> print registration form
*
* 10.01.08: use yr, make, MSRP ... etc. in ravm instead of ravin
function pr_tr1l
parameter xprinter, xtype, xbranch, xdate, xseq, xprtsw
private yy1, xdate, xplate, xmsrp, xexp, xdesc
private yplatetyp, ymake
* set up transaction table
private ydesc [9]
ydesc [1] = "Original Title Only"
ydesc [2] = "Original Title/Original Plate"
ydesc [3] = "Original Title/Transfer Plate"
ydesc [4] = "Original Title/Renewal-Transfer"
ydesc [5] = "Original Plate Only"
ydesc [6] = "Renewal Plate Only"
ydesc [7] = "Transfer Plate Only"
ydesc [8] = "                   "
ydesc [9] = "Renewal-Transfer Plate Only"

* 11.06.03
if pcount() < 6
   xprtsw = .t.
endif

select radtrh
xplate = radtrh->fplate
xdate = radtrh->fdate
if empty(radtrh->fpplate) .or. (radtrh->fplate=radtrh->fpplate)  && 12.01.06
   xdesc = ydesc [val(radtrh->faction)]
else
   xdesc = ydesc [val(radtrh->faction)] + [ (] + trim(radtrh->fpplate) + [)]
endif
xexp = space(6)
yplatetyp = if(f_verify("raplate",1,radtrh->fplate),raplate->ftype,[U])   && 12.15.99

* -- 10.01.08:
* select ravin
* seek substr(radtrh->fvin,1,8)+substr(radtrh->fvin,10,1)
select ravm
seek substr(radtrh->fvin,10,8)

select rabody
seek ravm->fstyle      && 10.01.08

if ravm->ffee = [01] .and. yplatetyp <> [03]
   if radtrh->faction $ [3;7]
      select raplate
      seek radtrh->fplate
      if .not. eof()
         xexp = strtran(dtoc(raplate->frenewal),"/","") 
      endif
   endif
   if empty(xexp)
      yy1 = val(substr(dtos(xdate),1,4))         && 199X
      if substr(dtoc(xdate),1,2) $ [12]    && for month = dec
          yy1 = yy1 + 2
      else
          yy1 = yy1 + 1
      endif
      yy1 = str(yy1,4)
      xexp = [0401]+substr(yy1,3,2)
   endif
   if ravm->fmsrp > 99999
      xmsrp = strtran(str(ravm->fmsrp,6,0)," ","0")
   else
      xmsrp = strtran(str(int(ravm->fmsrp/1000),6,0)," ","0")
   endif
else
   if radtrh->faction $ [3;7]
      select raplate
      seek radtrh->fplate
      if .not. eof()
         xexp = strtran(dtoc(raplate->frenewal),"/","") 
      endif
   endif
   if empty(xexp)
      yy1 = val(substr(dtos(xdate),1,4))         && 199X
      if substr(dtoc(xdate),1,2) $ [10,11,12]    && for month = oct,nov,dec
          yy1 = yy1 + 2
      else
          yy1 = yy1 + 1
      endif
      yy1 = str(yy1,4)
      xexp = [0228]+substr(yy1,3,2)
   endif
   if ravm->fmsrp > 99999
      xmsrp = strtran(str(ravm->fmsrp,6,0)," ","0")
   elseif ravm->fmsrp > 10000
      xmsrp = strtran(str(int(ravm->fmsrp/1000),6,0)," ","0")
   else
      xmsrp = strtran(str(ravm->fmsrp,6,0)," ","0")
   endif
endif
xexp1 = substr(xexp,1,2)+"/"+substr(xexp,3,2)+"/"+substr(xexp,5,2)

* 01.24.08: LAND ROVER
if ravm->fmake = "LAND"
   ymake = "LAND ROVER"
else
   ymake = ravm->fmake
endif

* 08.18.99: get appropriate address
private yaddr, ycity, ystate, yzip, ycounty, yctyname
* 03.26.03: address assignment according to tag type
* if upper(substr(radtrh->fref,8,1)) $ "W;Y;T;H"       
if upper(substr(radtrh->fref,8,1)) $ "F;W;Y;T;H"       && add F tag
   yaddr = raloc->FADDR2
   ycity = raloc->FCITY2               
   ystate = raloc->FSTATE2             
   yzip = raloc->FZIP2                 
   ycounty = raloc->fcounty2
   yctyname = raloc->fctyname2
elseif upper(substr(radtrh->fref,8,1)) = "G"     && damaged vehicle
   yaddr = raloc->FADDR1
   ycity = raloc->FCITY1               
   ystate = raloc->FSTATE1             
   yzip = raloc->FZIP1                 
   ycounty = raloc->fcounty1
   yctyname = raloc->fctyname1
else
   yaddr = raloc->FCADDR
   ycity = raloc->FCCITY                                             
   ystate = raloc->FCSTATE                                          
   yzip = raloc->FCZIP                                                
   ycounty = raloc->fcounty
   yctyname = raloc->fctyname
endif

if xprtsw      && 11.06.03
   set console off
   set print on
   set printer to &xprinter
   * set printer to tr-1l         && debug
endif 

if xtype = 1
   * ? [!R! FSET 1p50v4s3b4148t;SMB 7;UNIT C;CASS 0;COPY 1;MAP 14,11;EXIT;]+substr(xexp,1,2)
   * ? [!R! FSET 1p33v4s3b1418t; MAP 15.75,10.75;TEXT '-'; MAP 16,10.7;EXIT;]+substr(xexp,5,2)
   * ? [!R! FSET 1p12v4s3b4148t; MAP 15.55,9.55;EXIT;]+xplate
   * ? [!R! FONT 42; MAP 14.25,9.5;TEXT 'MI';MAP 15,11.5;EXIT;]+radtrh->fbranch+jdate(xdate)
   * ? [!R! EXIT;]

   * ---------- 08.10.00: changes per SOS
   xmonth = "JAN;FEB;MAR;APR;MAY;JUN;JUL;AUG;SEP;OCT;NOV;DEC;"
   xmth = substr(xmonth, ((val(substr(xexp,1,2))-1) * 4) + 1, 3)
   if substr(xexp,1,2) $ "03;05"    && just in case: for 800 branches, exp. [02,04,08,09]
      ? [!R! FSET 1p53v4s3b4148t;UNIT C;CASS 0;COPY 1;MAP 13.80,11;EXIT;]+xmth
      ? [!R! FSET 1p12v4s3b4148t;MAP 15.55,9.55;EXIT;]+xplate
      ? [!R! FONT 42;MAP 14.25,9.5;TEXT 'MI';EXIT;]
      ? [!R! FONT 42;MAP 14.25,11.5;EXIT;]+[20]+substr(xexp,5,2)+[  ]+radtrh->fbranch+jdate(xdate)
      ? [!R! EXIT;]
   else
      ? [!R! FSET 1p55v4s3b4148t;UNIT C;CASS 0;COPY 1;MAP 14,11;EXIT;]+xmth
      ? [!R! FSET 1p12v4s3b4148t;MAP 15.55,9.55;EXIT;]+xplate
      ? [!R! FONT 42;MAP 14.25,9.5;TEXT 'MI';EXIT;]
      ? [!R! FONT 42;MAP 14.25,11.5;EXIT;]+[20]+substr(xexp,5,2)+[  ]+radtrh->fbranch+jdate(xdate)
      ? [!R! EXIT;]
   endif
   * ----------
   ? [!R! FONT 62; MAP 0,-.015; CALL VREG; EXIT,E;]
else
   ? [!R! SMB 7;UNIT C;CASS 1;COPY 1;EXIT;]
   ? [!R! FONT 62; MAP 0,-.015; CALL VREG; EXIT,E;]
endif
?
?
? space(6)+xplate+space(15)+xexp1+space(39)+xplate+space(16)+xexp1
? space(3)+f_truncate(xdesc,40)+space(26)+xdesc                && 12.01.06
? space(3)+ravm->fyear+space(6)+f_truncate(ymake,15)+space(5)+f_truncate(rabody->fdesc,15)+ ;
  space(23)+ravm->fyear+space(6)+f_truncate(ymake,15)+space(5)+f_truncate(rabody->fdesc,15)
? space(12)+radtrh->fvin+space(24)+xmsrp+space(22)+radtrh->fvin+space(26)+xmsrp
? space(46)+f_truncate(yctyname,15)+space(55)+f_truncate(yctyname,15)
? space(3)+f_truncate(radtrh->fref,30)+radtrh->fcontrol+space(32)+radtrh->fref      && 03.16.98
?
? space(3)+f_truncate(radtrh->fowner,30)+space(36)+f_truncate(radtrh->fowner,30)
?
? space(3)+f_truncate(yaddr,35)+space(31)+f_truncate(yaddr,35)
? space(3)+f_truncate(ycity,20)+"  "+ystate+"  "+yzip+  ;
  space(30)+f_truncate(ycity,20)+"  "+ystate+"  "+yzip
? space(53)+str(radtrh->ftotal,6,2)+space(65)+str(radtrh->ftotal,6,2) 
yy1 = strtran(dtoc(xdate),"/","")
? space(5)+yy1+" "+radtrh->fclerk+"1 "+jdate(xdate)+" "+radtrh->fbranch+" "+ ;
  radtrh->fseq+space(4)+str(radtrh->ftotal,6,2)+space(31)+ ;
  yy1+" "+radtrh->fclerk+"1 "+jdate(xdate)+" "+radtrh->fbranch+" "+ ;
  radtrh->fseq+space(4)+str(radtrh->ftotal,6,2)
?                                                                                                           
?
?
?
? [!R! EXIT,E;]
? [!R! FSET 0p12h12v0s3b0t; CALL VREG; EXIT,E;]
? space(5)+xplate+" "+ravm->ffee+space(8)+xexp1+"  "+str(radtrh->fmonth,2)
? space(2)+xdesc
? 
? space(2)+ravm->fyear+space(6)+f_truncate(ymake,15)+space(5)+f_truncate(rabody->fdesc,15)
? space(9)+radtrh->fvin+space(14)+xmsrp
?
? space(31)+f_truncate(yctyname,12)+" "+ycounty
? "  "+radtrh->fowner
?
? "  "+yaddr
? "  "+f_truncate(ycity,20)+"  "+ystate+"  "+yzip+ ;
  space(2)+str(radtrh->ftotal,6,2)
?
yy1 = strtran(dtoc(xdate),"/","")
? space(2)+yy1+" "+radtrh->fclerk+"1 "+jdate(xdate)+" "+radtrh->fbranch+" "+ ;
  radtrh->fseq+space(4)+str(radtrh->ftotal,6,2)+space(4)+radtrh->ftab
?
? [!R! PAGE;CASS 1;EXIT,E;]

if xprtsw     && 11.06.03
   set print off
   set printer to
   set console on
   set device to screen
endif

return .t.


***********************
* print tr11
* note: calling routine open radtrh, ravm, rabody, raplate
function pr_tr11
parameter xprinter, xcopy, xbranch, xdate, xseq, xprtsw
private yaddr, ycity, ystate, yzip, ycounty, yctyname
private ylhname, ylhaddr, ylhcity, ylhstate, ylhzip
private yplatetyp, ymake

* set up transaction table
private ydesc [9]
ydesc [1] = "Original Title Only"
ydesc [2] = "Original Title/Original Plate"
ydesc [3] = "Original Title/Transfer Plate"
ydesc [4] = "Org Title/Renewal-Transfer"
ydesc [5] = "Original Plate Only"
ydesc [6] = "Renewal Plate Only"
ydesc [7] = "Transfer Plate Only"
ydesc [8] = "                   "
ydesc [9] = "Renewal-Transfer Plate Only"

* 11.06.03
if pcount() < 6
   xprtsw = .t.
endif

select radtrh
seek xbranch+dtos(xdate)+xseq
xplate = radtrh->fplate
xdate = radtrh->fdate
xdesc = ydesc [val(radtrh->faction)]
xexp = space(6)
yplatetyp = if(f_verify("raplate",1,radtrh->fplate),raplate->ftype,[U])   && 12.15.99
* -- 10.01.08
select ravm
seek substr(radtrh->fvin,10,8)
* ---
select rabody
seek ravm->fstyle

if ravm->ffee = [01] .and. yplatetyp <> [03]
   if radtrh->faction $ [3;7]
      select raplate
      seek radtrh->fplate
      if .not. eof()
         xexp = strtran(dtoc(raplate->frenewal),"/","") 
      endif
   endif
   if empty(xexp)
      yy1 = val(substr(dtos(xdate),1,4))         && 199X
      if substr(dtoc(xdate),1,2) $ [12]    && for month = dec
          yy1 = yy1 + 2
      else
          yy1 = yy1 + 1
      endif
      yy1 = str(yy1,4)
      xexp = [0401]+substr(yy1,3,2)
   endif
   if ravm->fmsrp > 99999
      xmsrp = strtran(str(ravm->fmsrp,6,0)," ","0")
   else
      xmsrp = strtran(str(int(ravm->fmsrp/1000),6,0)," ","0")
   endif
else
   if radtrh->faction $ [3;7]
      select raplate
      seek radtrh->fplate
      if .not. eof()
         xexp = strtran(dtoc(raplate->frenewal),"/","") 
      endif
   endif
   if empty(xexp)
      yy1 = val(substr(dtos(xdate),1,4))         && 199X
      if substr(dtoc(xdate),1,2) $ [10,11,12]    && for month = oct,nov,dec
          yy1 = yy1 + 2
      else
          yy1 = yy1 + 1
      endif
      yy1 = str(yy1,4)
      xexp = [0228]+substr(yy1,3,2)
   endif
   if ravm->fmsrp > 99999
      xmsrp = strtran(str(ravm->fmsrp,6,0)," ","0")
   elseif ravm->fmsrp > 10000
      xmsrp = strtran(str(int(ravm->fmsrp/1000),6,0)," ","0")
   else
      xmsrp = strtran(str(ravm->fmsrp,6,0)," ","0")
   endif
endif
xexp1 = substr(xexp,1,2)+"/"+substr(xexp,3,2)+"/"+substr(xexp,5,2)

* 01.24.08: LAND ROVER
if ravm->fmake = "LAND"
   ymake = "LAND ROVER"
else
   ymake = ravm->fmake
endif

* 08.18.99: get appropriate address
* 03.26.03: address assignment according to tag type
* if upper(substr(radtrh->fref,8,1)) $ "W;Y;T;H"       
if upper(substr(radtrh->fref,8,1)) $ "F;W;Y;T;H"       && 10.03.06: add F tag
   yaddr = raloc->FADDR2
   ycity = raloc->FCITY2               
   ystate = raloc->FSTATE2             
   yzip = raloc->FZIP2                 
   ycounty = raloc->fcounty2
   yctyname = raloc->fctyname2
elseif upper(substr(radtrh->fref,8,1)) = "G"     && damaged vehicle
   yaddr = raloc->FADDR1
   ycity = raloc->FCITY1               
   ystate = raloc->FSTATE1             
   yzip = raloc->FZIP1                 
   ycounty = raloc->fcounty1
   yctyname = raloc->fctyname1
else
   yaddr = raloc->FCADDR
   ycity = raloc->FCCITY                                             
   ystate = raloc->FCSTATE                                          
   yzip = raloc->FCZIP                                                
   ycounty = raloc->fcounty
   yctyname = raloc->fctyname
endif
* 10.03.06: lien holder info
if [CSV LLC] $ upper(radtrh->fowner)   && for FMC CSV LLC ONLY
   ylhname = glhname                   && defined in rinit.prg
   ylhaddr = glhaddr
   ylhcity = glhcity
   ylhstate = glhstate
   ylhzip = glhzip
else
   ylhname = ""
   ylhaddr = ""
   ylhcity = ""
   ylhstate = ""
   ylhzip = ""
endif
* -- 
if xprtsw       && 11.06.03
   set console off
   set print on
   set printer to &xprinter
   * set printer to tr-11l         && debug
endif

if xcopy = 1
   ? [!R! FSET 0p12h12v0s3b0t;CASS 1;COPY 1;CALL VTLE;EXIT,E;]
else
   ? [!R! FSET 0p12h12v0s3b0t;CASS 1;COPY 2;CALL VTLE;EXIT,E;]
endif
?
?
? "  "+f_truncate(xdesc,30)+"   "+xplate+space(10)+xexp1+space(22)+ ;
  str(radtrh->freg,6,2)
?
? space(4)+ravm->fyear+space(7)+f_truncate(ymake,15)+space(29)+radtrh->fvin+ ;
  space(8)+str(radtrh->ftitle,6,2)
?
?
* -- 03.20.06: print blanket mileage: [10]
? "  "+f_truncate(rabody->fdesc,15)+"  "+xmsrp+ ;
  space(8)+[10]+space(35)+ ;
  "N"+space(11)+str(radtrh->ftax,6,2)
?
? "  "+f_truncate(radtrh->fowner,35)+space(5)+f_truncate(radtrh->fref,15)+  ;
  radtrh->fcontrol+space(21)+str(radtrh->ftfee,6,2)
?
? "  "+f_truncate(yaddr,35)+space(45)+str(radtrh->ftotal,6,2)
? "  "+f_truncate(ycity,20)+"  "+ystate+"  "+yzip+ ;
  space(15)+radtrh->ftab+space(15)+ycounty
?
?
* -- 10.03.06: print lien holder info
? "  "+if(empty(ylhname),[NONE]+space(33),f_truncate(ylhname,37))+ ;
  dtoc(xdate)+[    NONE]
? "  "+f_truncate(ylhaddr,35)
? "  "+f_truncate(ylhcity,20)+"  "+ylhstate+"  "+ylhzip
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
?
yy1 = strtran (dtoc(xdate),"/","")
? "  "+yy1+" "+radtrh->fclerk+"1 "+jdate(xdate)+" "+radtrh->fbranch+ ;
  " "+radtrh->fseq+"   "+str(radtrh->ftotal,6,2)+space(13)+ ;
  radtrh->fbranch+jdate(xdate)+radtrh->fseq
?
? [!R! PAGE;EXIT,E;]

if xprtsw       && 11.06.03
   set print off
   set printer to
   set console on
   set device to screen
endif

return .t.

