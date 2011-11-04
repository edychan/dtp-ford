* ----------------------------------------------------------------------
* print replacement tab
*
* 10.01.08: open ravm instead of ravin for printing
* ----------------------------------------------------------------------
f_clrscn ("DTP - PRINT REPLACEMENT TAB")

f_box (01, 02, 05, 78)
xprt = [LPT1]
@ 02, 04 say "Printer.......      [LPT1/LPT2/LPT3]"
@ 02, 19 get xprt pict "!!!!" valid f_valid (xprt $ "LPT1;LPT2;LPT3")
if f_rd () = 27
   return
endif

if .not. pr_init (xprt, 2)        && load tab macros
   return
endif

* get name, addr, city etc
f_use ("raloc")
seek gloc
if eof ()
   f_valid (.f., "Missing Setup for Branch "+gloc)
   close data
   return
endif

f_use ("radtrh")     
f_use ("ratab", 1)
f_use ("raplate")
f_use ("ravm")               && 10.01.08
f_use ("rabody")

@ 03, 04 say "TAB # ........      "
@ 04, 04 say "Replacement #       "
do while .t.
   xtab = space(7)
   xrtab = space(7)
   @ 03, 19 get xtab pict "9999999" valid rdtp3c_a (xtab)
   @ 04, 19 get xrtab pict "9999999" valid rdtp3c_b (xrtab)
   if f_rd () = 27
      exit
   endif
   if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
      exit
   endif
   select ratab
   seek xrtab
   xyr = ratab->fyear
   if .not. eof ()
      reclock ()
      replace fstatus with "U"
      commit
      unlock
   endif
   seek xtab
   if eof ()
      append blank
      replace ftab with xtab, fyear with xyr
   endif
   reclock ()
   replace fstatus with "V" 
   commit
   unlock
   select radtrh
   set order to 4
   seek xtab
   set order to 1
   if .not. eof ()
      reclock ()
      replace ftab with xrtab
      commit
      unlock
      pr_tr1l (xprt, 1, radtrh->fbranch, radtrh->fdate, radtrh->fseq)  
   endif
enddo
close data
return

*****************
* check if tab is valid
function rdtp3c_a
parameter xtab

select radtrh
set order to 4
seek xtab
set order to 1
if eof ()
   f_valid (.f., "Invalid TAB #, missing assignment...")
   return .f.
elseif radtrh->fdate <= gpostdate
   f_valid (.f., "Cannot reprint posted transactions...")
   return .f.
else
   return .t.
endif

********************
* check replacement tab is valid
function rdtp3c_b
parameter xtab

select radtrh
set order to 4
seek xtab
set order to 1
if .not. eof ()
   f_valid (.f., "Invalid Replacement TAB #, Duplicate ...")
   return .f.
endif

select ratab
seek xtab
if eof ()
   f_valid (.f., "Missing Replacement TAB # ...")
   return .f.
elseif ratab->fstatus <> "A"
   f_valid (.f., "Please Check Replacement TAB # ...")
   return .f.
endif

return .t.


