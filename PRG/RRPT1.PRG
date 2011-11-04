* -----------------------------------------------------------
* dtp - print computer form
*
* -----------------------------------------------------------
* 09/11/96: add 10th digit (model year) to vin chart
* 09.17.97: print msrp for pickup/van weigh < 5000 lb
* 11.07.03: set printer to here instead of (pr_tr11, pr_tr1l)
* -----------------------------------------------------------
* 10.01.08: open ravm instead of ravin for printing
* -----------------------------------------------------------
f_clrscn ("DTP - REPRINT FORM TR11")
private xbranch, xdate, xstart, xend, xprt, xfrm, xcond, xfilter

f_box (01, 02, 09, 78)
@ 02, 04 say "Branch #......"
@ 03, 04 say "Date.........."
@ 04, 04 say "Starting......"
@ 05, 04 say "Ending........"
@ 06, 04 say "Printer.......      [LPT1/LPT2/LPT3]"
@ 07, 04 say "Form..........      [1] TR-11L [Title Application]"
@ 08, 04 say "                    [2] TR-1L  [Registration ]    "
f_use ("radtrh")

xbranch = gloc
xdate = date()
xstart = 0
xend = 0
xprt = [LPT1]
xfrm = [1]
xfilter = [.t.]
do while .t.
   set century on
   @ 02, 19 get xbranch pict "999"
   @ 03, 19 get xdate 
   @ 04, 19 get xstart pict "9999" valid f_valid (xstart >= 0)
   @ 05, 19 get xend pict "9999" valid f_valid (xend >= xstart)
   @ 06, 19 get xprt pict "!!!!" valid f_valid (xprt $ "LPT1;LPT2;LPT3")
   @ 07, 19 get xfrm pict "9" valid f_valid (xfrm $ "12")
   f_rd ()
   set century off
   if lastkey () = 27
      close data
      return
   endif
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "C"
      f_y2k (@xdate)
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

if xfrm = [1]
   xfilter = "radtrh->faction $ [1234]"
   if .not. pr_init (xprt, 1)      && load tr11 macros
      close data
      return
   endif
elseif xfrm = [2]
   xfilter = "radtrh->faction $ [2345679]"
   if .not. pr_init (xprt, 2)
      close data
      return
   endif
else
   close data
   return
endif

if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
   close data
   return
endif

f_popup ("Please Wait While Printing...")

* get name, addr, city etc
f_use ("raloc")
seek xbranch
if eof ()
   f_valid (.f., "Missing Setup for Branch "+xbranch)
   close data
   return
endif

* set up condition
if xstart = 0
   xcond = ".t."
else
   xcond = "val(radtrh->fseq) >= xstart .and. val(radtrh->fseq) <= xend"
endif

* 11.06.03: set printer here
set console off
set print on
set printer to &xprt
* set printer to tr-1l         && debug

* open tables here
f_use ("rabody")
* -- 10.01.08
f_use ("ravm")
* --
f_use ("raplate")
f_use ("radtrh")
select radtrh
set softseek on
seek xbranch+dtos(xdate)+strtran(str(xstart,4,0)," ","0")
set softseek off
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
   if &xfilter
      if xfrm = [1]
         pr_tr11 (xprt, 1, radtrh->fbranch, radtrh->fdate, radtrh->fseq, .f.)     && 11.07.03
      elseif xfrm = [2]
         pr_tr1l (xprt, 2, radtrh->fbranch, radtrh->fdate, radtrh->fseq, .f.)     && 11.07.03
      endif
   endif
   select radtrh
   skip
enddo

* 11.06.03: 
set print off
set printer to
set console on
set device to screen
*
close data
f_valid (.f., "Process Completed...")



