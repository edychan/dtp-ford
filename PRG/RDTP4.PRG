* -----------------------------------------------------
* end of day report
*
* -----------------------------------------------------
* 09/11/96: add 10th digit (model year) to vin chart
* -----------------------------------------------------
* 10.01.08: open ravm instead of ravin for vehicle pertinent info
* -----------------------------------------------------
f_clrscn ("End of Day Report")

f_box (01, 02, 05, 78)
@ 02, 04 say "Branch #......"
@ 03, 04 say "Date.........."
xbranch = gloc
xdate = date()

* open tables
f_use ("radtrh")

do while .t.
   set century on
   @ 02, 19 get xbranch pict "!!!" valid f_valid (rdtp4a())
   @ 03, 19 get xdate valid f_valid(.not.empty(xdate))
   f_rd ()
   set century off
   if lastkey () = 27
      close data
      return
   endif
   f_y2k (@xdate)
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

do rdtp4b with xbranch, xdate

close data

******************************
function rdtp4a

f_use ("ractr")
locate for fbranch = xbranch
if eof ()
   return .f.
else
   return .t.
endif

******************************
function f_hdr

private i, yln, ylen, ycol, ydesc

@ 01, 01 say 'DATE: ' + l_date
@ 01, yc1 say gtitle
@ 01, yc3 say 'PAGE: ' + str (l_page, 3)
@ 02, 01 say 'TIME: ' + l_time
@ 02, yc2 say l_ftitle1
@ 03, yc2 say l_ftitle2
@ 05, 01 say l_header1
@ 06, 01 say l_header2
yln = 8
l_page = l_page + 1

return (yln)

