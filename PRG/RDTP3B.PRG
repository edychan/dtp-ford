* ----------------------------------------------------------------------
* print tab
* ----------------------------------------------------------------------
*
* 10.01.08: open ravm instead of ravin for printing ...
* ----------------------------------------------------------------------
f_clrscn ("DTP - PRINT TAB")

f_box (01, 02, 04, 78)
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
f_use ("raplate")
f_use ("ravm")          && 10.01.08
f_use ("rabody")
f_use ("raaudit")
xtab = space(7)
@ 03, 04 say "TAB # ........      "
do while .t.
   @ 03, 19 get xtab pict "9999999" valid rdtp3b_a (xtab)
   if f_rd () = 27
      exit
   endif
   if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
      exit
   endif
   if pr_tr1l (xprt, 1, radtrh->fbranch, radtrh->fdate, radtrh->fseq)
      xtab = strtran (str(val(xtab)+1,7), " ", "0")
   endif
enddo
close data
return

*****************
function rdtp3b_a
parameter xtab

select radtrh
set order to 4   && order by tab #
seek xtab
set order to 1
if eof ()
   f_valid (.f., "Invalid TAB #, missing assignment...")
   return .f.
* elseif radtrh->fdate <= gpostdate
*    f_valid (.f., "Cannot reprint posted transactions...")
*    return .f.
endif
select raaudit
seek xtab
if .not. eof ()
   f_valid (.f., "Please Check TAB # ...")
   if f_confirm ("[R]etype  [C]ontinue ","CR") <> "C"
      return .f.
   else
      return .t.
   endif
else
   select raaudit
   append blank
   reclock ()
   replace fvin with xtab
   commit
   unlock
   return .t.
endif


