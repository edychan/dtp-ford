* --------------------------------------------------------------------
* view history record
* --------------------------------------------------------------------
* changes:
* 09.17.97: print msrp instead of weight for pickup/van under 5000 lb
* 12.01.04: new passenger plate config. AAA9999
* --------------------------------------------------------------------
* 12.11.06: display fpplate + fplate info
* --------------------------------------------------------------------
* 10.01.08: open ravm instead of ravin for printing ...
* --------------------------------------------------------------------
private yarray [3]
f_clrscn ("DTP/MI - View History Record")

do while .t.
   yarray[1] = " VIN.......... "
   yarray[2] = " Plate #...... "
   yarray[3] = " TAB #........ "
   yptr = 1
   yret = f_pick_a (02, 05, "", "", yarray, 3, yptr)
   if yret = 0
      exit
   endif
   if yret = 1
      yval = space (8)
   elseif yret = 2
      yval = space (7)
   else
      yval = space (7)
   endif
   @ 02, 02 clear to 02, 30
   @ 02, 02 say yarray [yret] get yval picture replicate ([!], len (yval))
   if f_rd ()	= 27
      exit
   endif
   yval = upper (alltrim (yval))
   set softseek on
   yfnd = .f.
   do case
   case yret = 1
      f_use ("radtrh", 2)
      seek yval
   case yret = 2
      f_use ("radtrh", 3)
      seek yval
   case yret = 3
      f_use ("radtrh", 4)
      seek yval
   endcase
   set softseek off
   if eof()
      go top
   endif
   if f_pick_f (04, 05, "", "컴 VIN 컴Code컴Plate컴컴컴컴컴Tab컴컴횭ranch컴Id컴Date컴컴Total",  ;
             "substr(fvin,10,8)+[  ]+faction+[  ]+fplate+[ / ]+fpplate+[ ]+ftab+[ ]+fbranch+[ ]+fseq+[ ]+"+    ;
             "fclerk+[ ]+dtoc(fdate)+[ ]+str(ftotal,6,2)")        && 12.11.06
      * get name, addr, city etc
      f_use ("raloc")
      seek radtrh->fbranch
      if eof ()
         f_valid (.f., "Missing Setup for Branch "+radtrh->fbranch)
         exit
      endif
      select radtrh
      set order to 1
      do rdtp6a
      exit
   endif
enddo

close data

***********************
procedure rdtp6a

* print routine
 
f_box (01, 02, 05, 78)
@ 02, 04 say "Printer.......      [LPT1/LPT2/LPT3]"
@ 03, 04 say "Form..........      [1] TR-11L [Title Application]"
@ 04, 04 say "                    [2] TR-1L  [Registration ]    "
xdate = date()
xprt = [LPT1]
xfrm = [1]
@ 02, 19 get xprt pict "!!!!" valid f_valid (xprt $ "LPT1;LPT2;LPT3")
@ 03, 19 get xfrm pict "9" valid f_valid (xfrm $ "12")
if f_rd () = 27
   return
endif

if xfrm = [1] .and. radtrh->faction $ [1234]
   if .not. pr_init (xprt, 1)      && load tr11 macros
      return
   endif
elseif xfrm = [2] .and. radtrh->faction $ [2345679]
   if .not. pr_init (xprt, 2)
      return
   endif
else
   f_valid (.f., "Invalid Form selection...")
   return
endif


if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
   return
endif
f_use ("rabody")
f_use ("ravm")           && 10.01.08
f_use ("raplate")
if xfrm = [1]
   pr_tr11 (xprt, 1, radtrh->fbranch, radtrh->fdate, radtrh->fseq)
elseif xfrm = [2]
   pr_tr1l (xprt, 2, radtrh->fbranch, radtrh->fdate, radtrh->fseq)
endif

f_valid (.f., "Process Completed...")
return

