* -----------------------------------------------------
* print end of day reports
* -----------------------------------------------------
* 09/11/96: add 10th digit (model year) to vin chart
* 12.05.07: add tag #
* -----------------------------------------------------
* 12.15.99: allow commercial plate on passenger cars
* 12.01.04: new plate config. AAA9999
* -----------------------------------------------------
* 10.01.08: use ravm for vehicle pertinent info
* -----------------------------------------------------
parameter xbranch, xdate

* -- 10.01.08
* -- open tables (call also by rdtp5 eod process)
f_use ("ravm")
f_use ("raplate")
f_use ("radtrh")
* --
select radtrh
set softseek on
seek xbranch+dtos(xdate)
set softseek off
declare y3 [4], y4 [4]
y3 [1] = 0
y3 [2] = 0
y3 [3] = 0
y3 [4] = 0
y4 [1] = 0
y4 [2] = 0
y4 [3] = 0
y4 [4] = 0

private ytrans, ysum, yplatetyp
ytrans = 0
ysum = 0
do while .not. eof () .and. radtrh->fbranch = xbranch .and.   ;
   radtrh->fdate = xdate
   ytrans = ytrans + 1
   if radtrh->ftitle > 0
      y3 [3] = y3 [3] + 1
      y4 [3] = y4 [3] + radtrh->ftitle
   endif
   if radtrh->ftfee > 0
      y3 [4] = y3 [4] + 1
      y4 [4] = y4 [4] + radtrh->ftfee
   endif
   if radtrh->freg > 0
      yplatetyp = if(f_verify("raplate",1,radtrh->fplate),raplate->ftype,[U])  && 12.15.99
      select ravm
      * -- 10.01.08
      * seek substr(radtrh->fvin,1,8)+substr(radtrh->fvin,10,1)
      seek substr(radtrh->fvin,10,8)

      if ravm->ffee = "01" .and. yplatetyp <> "03"
         y3 [1] = y3 [1] + 1
         y4 [1] = y4 [1] + radtrh->freg
      else
         y3 [2] = y3 [2] + 1
         y4 [2] = y4 [2] + radtrh->freg
      endif
   endif 
   select radtrh
   skip
enddo
ysum = y4 [1] + y4 [2] + y4 [3] + y4 [4]

* start printing here
if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
   close data
   return
endif

l_formlen = 80
l_date = dtoc(date())
l_time = time()

set console off
set print on
set device to print
set printer to lpt1
* yfil = "eod.prn"          && for testing purpose only...
* set printer to &yfil

@ 02, 02 say "DATE: "+dtoc(date())
@ 02, 28 say gtitle
@ 02, 65 say "INVOICE: "+jdate(xdate)
@ 03, 02 say "TIME: "+time()
@ 03, 22 say "END OF DAY REPORT - FEE DISTRIBUTION"
@ 04, 27 say "BRANCH #: "+xbranch+"   "+"DATE: "+ dtoc(xdate)
@ 06, 01 say " TRANS CODE     DESCRIPTION                          # TRANS    TRANS TOTAL"
@ 07, 01 say " ----------     ----------------------------------   ---------  -----------"
@ 09, 01 say "    01          PASSENGER PLATES "
@ 09, 57 say str(y3[1],4)
@ 09, 66 say str(y4[1],10,2)
@ 11, 01 say "    03          COMMERCIAL PLATES "
@ 11, 57 say str(y3[2],4)
@ 11, 66 say str(y4[2],10,2)
@ 13, 01 say "    21          TITLE APPLICATION FEE "
@ 13, 57 say str(y3[3],4)
@ 13, 66 say str(y4[3],10,2)
@ 15, 01 say "    22          PLATE TRANSFER "
@ 15, 57 say str(y3[4],4)
@ 15, 66 say str(y4[4],10,2)
@ 17, 66 say str(ysum,10,2)
@ 18, 66 say "=========="
@ 20, 01 say "TOTAL RECORDS TRANSMITTED: "+str(ytrans, 6)
eject

* License Plate Tabs used report

l_ftitle1 = "END OF DAY REPORT - LICENSE PLATE TABS USED"
l_ftitle2 = "BRANCH #: "+xbranch+"   "+"DATE: "+ dtoc(xdate)
l_header1 = " TAB #      TRANS     PLATE #    VIN / TAG #                   REG. FEE "
l_header2 = " -------    ------    -------    --------------------------    ---------"

yc1 = max (20, int (l_formlen/2) - int (len (gtitle) / 2))
yc2 = max (20, int (l_formlen/2) - int (len (l_ftitle1) / 2))
yc3 = l_formlen - 12

l_page = 1
yrow = f_hdr ()

select radtrh
set softseek on
seek xbranch+dtos(xdate)
set softseek off
ytrans = 0
do while .not. eof () .and. radtrh->fbranch = xbranch .and.   ;
   radtrh->fdate = xdate
   if empty(radtrh->ftab)
      skip
      loop
   endif
   ytrans = ytrans + 1
   @ yrow, 02 say radtrh->ftab
   @ yrow, 14 say radtrh->fseq
   @ yrow, 23 say radtrh->fplate
   @ yrow, 34 say radtrh->fvin
   @ yrow, 53 say substr(radtrh->fref,5,7)      && 12.05.97 add tag #
   @ yrow, 65 say str(radtrh->freg,8,2)
   if yrow > 62
      eject
      yrow = f_hdr ()
   else
      yrow = yrow + 1
   endif
   skip
enddo
* output summary
yrow = yrow + 1
@ yrow, 02 say "TOTAL LICENSE PLATE TABS USED: "+str(ytrans,8)
eject

* summary of daily transactions

l_ftitle1 = "END OF DAY REPORT - DAILY TRANSACTION SUMMARY"
l_ftitle2 = "BRANCH #: "+xbranch+"   "+"DATE: "+ dtoc(xdate)
l_header1 = " TRAN CODE        VIN         PLATE   YR/MAKE      REG      TITLE    TOTAL  "
l_header2 = " ---- ----  ----------------- ------- ----------   -------  ------  --------"

yc1 = max (20, int (l_formlen/2) - int (len (gtitle) / 2))
yc2 = max (20, int (l_formlen/2) - int (len (l_ftitle1) / 2))
yc3 = l_formlen - 12

l_page = 1
yrow = f_hdr ()

* build tran code array 
private yc [9]
yc[1] = "PA"
yc[2] = "AA"
yc[3] = "GA"
yc[4] = "HA"
yc[5] = "A "
yc[6] = "B "
yc[7] = "G "
yc[8] = "  "
yc[9] = "H "

* -- 10.01.08
* f_use ("ravin")
* select radtrh
* set relation to substr(fvin,1,8)+substr(fvin,10,1) into ravin
* --

f_use ("ravm")
select radtrh
set relation to substr(fvin,10,8) into ravm
set softseek on
seek xbranch+dtos(xdate)
set softseek off
ytrans = 0
ysum = 0
do while .not. eof () .and. radtrh->fbranch = xbranch .and.   ;
   radtrh->fdate = xdate
   ytrans = ytrans + 1
   ysum = ysum + radtrh->ftotal 
   y1 = val(radtrh->faction)
   @ yrow, 02 say radtrh->fseq
   if y1 >= 1 .and. y1 <= 9
      @ yrow, 08 say yc [y1]
   endif
   @ yrow, 13 say radtrh->fvin
   @ yrow, 31 say radtrh->fplate     && 12.01.04
   @ yrow, 39 say ravm->fyear
   @ yrow, 42 say substr(ravm->fmake,1,7)
   @ yrow, 51 say str(radtrh->freg+radtrh->ftfee,8,2)
   @ yrow, 59 say str(radtrh->ftitle,8,2)
   @ yrow, 69 say str(radtrh->ftotal,8,2)
   if yrow > 62
      eject
      yrow = f_hdr ()
   else
      yrow = yrow + 1
   endif
   skip
enddo
* output summary
yrow = yrow + 1
@ yrow, 67 say str(ysum,10,2)
yrow = yrow + 1
@ yrow, 67 say "=========="
yrow = yrow + 2
@ yrow, 02 say "TOTAL RECORDS TRANSMITTED: "+str(ytrans,8)
eject

set printer to
set console on
set device to screen

