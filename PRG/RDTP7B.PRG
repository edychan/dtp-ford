*
* print renewals
*
* 09.17.97: print msrp for pickup/van weigh < 5000 lb
*

f_clrscn ("DTP - PRINT RENEWAL TRANSACTIONS")
private xformno, yrow, ybuffer, yfld, ypict, ysel, xmsrp

f_box (01, 02, 07, 78)
@ 02, 04 say "Branch #......"
@ 03, 04 say "Date.........."
@ 04, 04 say "Starting......"
@ 05, 04 say "Ending........"
@ 06, 04 say "Printer.......      [LPT1/LPT2/LPT3]"
f_use ("radtrh")

xmsrp = []
xloc = space (3)
xbranch = space (3)
xdate = date()
xstart = 0
xend = 0
xprt = [LPT1]
do while .t.
   @ 02, 19 get xbranch pict "999" valid f_valid (f_findloc ())
   @ 03, 19 get xdate valid f_y2k(@xdate)
   @ 04, 19 get xstart pict "9999" valid f_valid (xstart >= 0)
   @ 05, 19 get xend pict "9999" valid f_valid (xend >= xstart)
   @ 06, 19 get xprt pict "!!!!" valid f_valid (xprt $ "LPT1;LPT2;LPT3")
   if f_rd () = 27
      close data
      return
   endif
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "C"
      select radtrh
      set softseek on
      seek xbranch+dtos(xdate)
      set softseek off
      if eof () .or. radtrh->fdate <> xdate
         f_valid (.f., "No transaction to be printed...") 
         loop
      else
         exit
      endif
   elseif yret = "Q"
      close data
      return
   endif
enddo

* print routine
if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
   close data
   return
endif

* set filter
select radtrh
set filter to funit = "TR-1C"

f_popup ("Please Wait While Printing...")

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

* set up condition
if xstart = 0
   xcond = ".t."
else
   xcond = "val(radtrh->fseq) >= xstart .and. val(radtrh->fseq) <= xend"
endif

y1 = dtoc (xdate)
xfd = substr(y1,1,2)+substr(y1,4,2)+substr(y1,7,2)
xjdate = jdate (xdate)

ykey = 0
* xformno = 2           && for from tr-1c
xformno = 1           && 12.02.97 change to generic form
xtr11 = [1]           && 12.02.97 control address printing
xtyp = "R"            && reprint

f_use ("raform")
f_use ("rabody")
f_use ("ravin")
select radtrh
set softseek on
seek xbranch+dtos(xdate)+strtran(str(xstart,4,0)," ","0")
set softseek off
set console off
set print on
set printer to &xprt
* printer control code for tr1-c
* yfrmlg = "chr(27)+chr(65)+chr(12)+chr(27)+chr(67)+chr(24)"   
yfrmlg = "chr(27)+chr(65)+chr(12)+chr(27)+chr(67)+chr(66)"
?? &yfrmlg
begin sequence
   do while .not. eof () .and. radtrh->fbranch = xbranch .and.   ;
      radtrh->fdate = xdate .and. &xcond
      key = inkey ()
      if key = 27
         set console on
         set print off
         if f_confirm ("Do you want to quit ? ", "YN") = "N"
            set console off
            set print on
         else
            exit
         endif
      endif
     
      yrow = 0
      ybuffer = space (132)
      select ravin
      seek substr(radtrh->fvin,1,8)+substr(radtrh->fvin,10,1)
      if ravin->ffee = [01]
         yy1 = val(substr(dtoc(xdate),7,2))
         if substr(dtoc(xdate),1,2) = [12]    && for month = dec
             yy1 = yy1 + 2
         else
             yy1 = yy1 + 1
         endif
         yy1 = if(yy1>99, yy1-100, yy1)             && for year 2000
         xexp = [04/01/]+strtran(str(yy1,2)," ","0")
         * 04/16/96
         if ravin->fmsrp > 99999
            xmsrp = str(ravin->fmsrp,6,0)
         else
            xmsrp = str(int(ravin->fmsrp/1000),6,0)
         endif
      else
         yy1 = val(substr(dtoc(xdate),7,2))
         if substr(dtoc(xdate),1,2) $ [10,11,12]    && for month = oct,nov,dec
             yy1 = yy1 + 2
         else
             yy1 = yy1 + 1
         endif
         yy1 = if(yy1>99, yy1-100, yy1)             && for year 2000
         xexp = [02/28/]+strtran(str(yy1,2)," ","0")
         * 09.17.97
         if ravin->fmsrp > 99999
            xmsrp = str(ravin->fmsrp,6,0)
         elseif ravin->fmsrp > 10000
            xmsrp = str(int(ravin->fmsrp/1000),6,0)
         else
            xmsrp = str(ravin->fmsrp,6,0)
         endif
         *
      endif

      * print form uses rabody
      select rabody
      seek ravin->fstyle

      * "1" should be station id
      xid = radtrh->fclerk+"1"+xjdate+xbranch+radtrh->fseq
      xseq = xbranch+xjdate+radtrh->fseq
      *
      select raform
      seek str (xformno, 2) + xtyp
      do while .not. eof () .and. ffrmno = xformno .and. ffrmtyp = xtyp
         do while frow > yrow
            ? trim (ybuffer)
            ybuffer = space (132)
            yrow = yrow + 1
         enddo

         yfld = ffield
         ypict = trim (fpict)
         yfld = transform (&yfld, ypict)
         ybuffer = stuff (ybuffer, fcol + 1, len (yfld), yfld)
         skip
      enddo
      ? trim (ybuffer)
      eject
      select radtrh
      skip
   enddo
end
set print off
set printer to
set console on
set device to screen

set filter to
close data
f_valid (.f., "Process Completed...")

*****************************************
function f_findloc

f_use ("ractr")
locate for fbranch = xbranch
if eof ()
   return .f.
else
   return .t.
endif


