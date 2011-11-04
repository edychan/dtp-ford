* ----------------------------------------------------------------------
* dtp - print computer form
* ----------------------------------------------------------------------
* 09/11/96: add 10th digit (model year) to vin chart
* 09.17.97: print msrp for pickup/van weigh < 5000 lb
* 11.06.03: set printer to lpt1/lpt2 here instead of pr_tr1l / pr_tr11l
* ----------------------------------------------------------------------
* 10.01.08: open RAVM instead of RAVIN for printing ...
* ----------------------------------------------------------------------
f_clrscn ("DTP - PRINT FORM TR11")
private xprt, xfrm, xcond, xclerk

f_use ("radtrp")
go top
if eof ()
   f_valid (.f., "All Printed...")
   close data
   return
endif

xprt = [LPT1]
xfrm = [1]
xcond = ".t."
f_box (01, 02, 05, 78)
@ 02, 04 say "Printer.......      [LPT1/LPT2/LPT3]"
@ 03, 04 say "Form..........      [1] TR-11L [Title Application]"
@ 04, 04 say "                    [2] TR-1L  [Registration For Transfer Plate]"
@ 02, 19 get xprt pict "!!!!" valid f_valid (xprt $ "LPT1;LPT2;LPT3")
@ 03, 19 get xfrm pict "9" valid f_valid (xfrm $ "1;2")
if f_rd () = 27
   close data
   return
endif
if xfrm = [1]
   xcond = "radtrp->faction $ [1234]"
   if .not. pr_init (xprt, 1)      && load tr11 macros
      close data
      return
   endif
elseif xfrm = [2]
   xcond = "radtrp->faction $ [37]"
   if .not. pr_init (xprt, 2)      && load tr-1l macros
      close data
      return
   endif
endif

if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
   close data
   return
endif

f_popup ("Please Wait While Printing...")

* get name, addr, city etc
f_use ("raloc")
seek gloc
if eof ()
   f_valid (.f., "Missing Setup for Branch "+gloc)
   close data
   return
endif

* 11.06.03: set printer here

set console off
set print on
set printer to &xprt
* set printer to tr-1l         && debug

f_use ("rabody")
* --
* f_use ("ravin")
* --
f_use ("ravm")                 && 10.01.08
f_use ("raplate")
f_use ("radtrh")
f_use ("radtrp")
select radtrp
go top
do while .not. eof () 
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
   if .not. &xcond
      skip
      loop
   endif
   select radtrh
   seek radtrp->fbranch+dtos(radtrp->fdate)+radtrp->fseq
   if eof ()          && transaction deleted by user-> don't print
      select radtrp
      reclock ()
      delete
      commit
      unlock
      skip
      loop
   endif
   if xfrm = [1] .and. .not. radtrp->ftr11    && do not print if printed already
      * 02.24.00: only print 1 copy
      * pr_tr11 (xprt, 2, radtrp->fbranch, radtrp->fdate, radtrp->fseq)
      * 11.06.03: pr_tr11 (xprt, 1, radtrp->fbranch, radtrp->fdate, radtrp->fseq)
      pr_tr11 (xprt, 1, radtrp->fbranch, radtrp->fdate, radtrp->fseq, .f.)
      if radtrp->faction = [3]
         select radtrp
         reclock ()
         replace ftr11 with .t.
         commit
         unlock
      else
         select radtrp
         reclock ()
         delete
         commit
         unlock
      endif
   elseif xfrm = [2]
      * 11.06.03: pr_tr1l (xprt, 2, radtrp->fbranch, radtrp->fdate, radtrp->fseq) 
      pr_tr1l (xprt, 2, radtrp->fbranch, radtrp->fdate, radtrp->fseq, .f.) 
      if radtrp->faction = [3] .and. radtrp->ftr11
         select radtrp
         reclock ()
         delete
         commit
         unlock
      endif
   endif
   select radtrp
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

