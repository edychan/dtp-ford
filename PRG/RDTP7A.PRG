* ---------------------------------------------------------------
* process renewal
*
* ---------------------------------------------------------------
* changes
* 01.17.2002: check plate configuration
* 02.20.2002: check renewal date in case
* ---------------------------------------------------------------
* 12.16.06: blue/white plate exchange (SOS mandatory change)
*   Important: Passenger White Plate AAA9999
*              Commercial White Plate AA99999
* ---------------------------------------------------------------
private xfil, xtrans, xseq, xdate, xholiday, xyear
private yfil, yscn,yret, yrow, ypdesc, yptype
private ydigits, yspldate, yeplate, yxplate

f_clrscn ("DTP/MI - Process Renewal Transactions")
xfil = gdbfpath+"renewal"
if .not. file (xfil+".dbf")
   f_valid (.f., "Missing Renewal File...")
   return
endif

f_box (01, 02, 04, 78)
@ 02, 04 say "Office #......"
@ 02, 41 say "Clerk ID......"
@ 03, 04 say "Date.........."
l_floc = gloc
l_fdate = date()
l_fclerk = gclerk
* check last post date
f_use ("rasys")
xdate = fpostdate
use
* 09.12.05: check holiday table
yfil = gmempath + substr(dtos(date()),1,4) + ".mem"
if file (yfil)
   restore from (yfil) additive
else
   xholiday = ""
endif

do while .t.
   @ 02, 19 get l_floc pict "!!!" valid ;
     f_valid (f_verify("raloc",1,l_floc))
   @ 02, 56 say l_fclerk
   @ 03, 19 get l_fdate valid rdtp7x ()      && 12.16.06
   if f_rd () = 27
      return
   endif
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "C"
      exit
   elseif yret = "Q"
      return
   endif
enddo

f_use ("raloc")
seek l_floc
if eof ()
   f_valid (.f., "Please Setup Branch Office First...")
   close data
   return
else
   l_fbranch = fbranch
endif
use

f_use ("ractr")
f_use ("radtrh")
f_use ("ratab")
f_use ("raplate")   && 02.20.02

* only 1 person can process renewal
select 0
set excl on
use &xfil index &xfil alias renewal
set excl off

go top
* ycnt = reccount()
* if eof ()
* 01.18.01
f_popup ("Please Wait...")
count for .not. deleted() to ycnt
f_popback ()
if ycnt = 0
   f_valid (.f., "All Processed...")
   close data
   return
endif

f_box (06, 02, 09, 78, "Total of "+alltrim(str(ycnt,6))+" Renewals ")
@ 07, 04 say "Renewals to be processed.. "
@ 08, 04 say "  Starting TAB #.......... "

xtrans = 0
xtab = space(7)
do while .t.
   @ 07, 31 get xtrans pict "999" valid f_valid (xtrans>0, "Must be Greater than 0...")
   @ 08, 31 get xtab pict "9999999" valid ;
     f_valid (f_verify("ratab",1,xtab),"Invalid Tab #...")
   if f_rd () = 27
      close data
      return
   endif
   xyear = ratab->fyear
   @ 08, 50 say xyear
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "C"
      exit
   elseif yret = "Q"
      close data
      return
   endif
enddo

select renewal
go top

* 12.16.06: Assume blue plate is the 1st record...
ydigits = 0
ypdesc = space(3)
ysplate = space(7)
yeplate = space(7)
chkplate (renewal->fplate, @ypdesc)
if ypdesc = [003]
   @ 7, 41 say "Starting White Plate # :"
   @ 8, 41 say "  Ending White Plate # :"
   do while .t.
      @ 7, 66 get ysplate pict "!!!!!!!" valid ;
         f_valid(f_verify("raplate",1,ysplate),"Invalid Plate # !")
      @ 8, 66 get yeplate pict "!!!!!!!" valid ;
         f_valid(f_verify("raplate",1,yeplate),"Invalid Plate # !")
      f_rd ()
      yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
      if yret = "C"
         if ysplate > yeplate
            f_valid (.f., "Ending Plate # must be greater than Starting Plate # !")
            loop
         else
            exit
         endif
      elseif yret = "Q"
         close data
         return
      endif
   enddo
   select raplate
   seek ysplate
   if raplate->ftype = [01]       && passenger
      ydigits = 4
   elseif raplate->ftype = [03]   && commercial
      ydigits = 5
   else       && just in case
      f_valid (.f., "Missing Plate Type: "+ysplate)
      close data
      return
   endif
endif
* start processing
f_box (11, 05, 22, 65, "Processing Transaction")
yrow = 11
*
l_ftab = xtab
for i = 1 to xtrans
   if eof ()
      exit
   endif
   * 12.16.06: check for blue plate
   ypdesc = space(3)
   if .not. chkplate (renewal->fplate, @ypdesc)
      select renewal
      skip
      loop
   endif
   * 02.20.2002: check if plate need renew
   select raplate
   seek renewal->fplate
   if .not. eof ()
      if raplate->frenewal > (l_fdate + 150) .or. ;    && plate is current
         raplate->fstatus = "I"   && 01.23.07: plate is inactive
         select renewal
         delete
         skip
         loop
      endif
   endif
   * 12.16.06: exchange white plate
   if ypdesc = [003]
      if empty(ysplate)      && in case encounter blue plate later in the batch
         f_valid (.f., "Please enter White Plate for "+renewal->fplate)
         close data
         return
      endif
      yxplate = ysplate
      select raplate
      seek yxplate
      if raplate->fstatus <> [A]
         f_valid (.f., "Error: Plate "+yxplate+" is In Use !")
         close data
         return
      endif
   endif
   * assign tab
   select ratab
   seek l_ftab
   do while .not. eof ()
      if ratab->fstatus $ "A;X" .and. ratab->fyear = xyear
          reclock ()
          replace fstatus with "U"
          commit
          unlock
          exit
      endif
      skip
   enddo
   if eof ()
      f_valid (.f., "No more tabs available, Please load new ones...")
      close data
      return
   endif
   l_ftab = ratab->ftab
   * assign seq #
   select ractr
   locate for fbranch = l_fbranch
   reclock ()
   l_fseq = strtran(str(fseq1,4), " ", "0")     
   replace fseq1 with fseq1 + 1
   commit
   unlock
   select radtrh
   append blank
   * assign other value
   replace floc with l_floc       && 01/06/97 edc
   replace fbranch with l_fbranch
   replace fdate with l_fdate
   replace fseq with l_fseq
   replace ftab with l_ftab
   replace fclerk with l_fclerk
   if ypdesc = [003]
      replace fplate with yxplate    && 12.16.06   
   else
      replace fplate with renewal->fplate
   endif
   replace fpplate with renewal->fpplate
   replace fvin with renewal->fvin
   replace faction with renewal->faction
   replace fmonth with renewal->fmonth
   replace fowner with renewal->fowner
   replace fref with renewal->fref
   replace freg with renewal->freg
   replace fstate with renewal->fstate
   replace ftotal with renewal->ftotal
   replace fcontrol with renewal->fcontrol
   replace ftax with renewal->ftax
   replace ftfee with renewal->ftfee
   replace ftitle with renewal->ftitle
   replace ftr11 with renewal->ftr11
   replace funit with "TR-1C"          && for renewal only
   commit
   unlock 
   *

   if yrow >= 21
      scroll (12, 10, 21, 60, 1)
   else
      yrow = yrow + 1
   endif
   @ yrow, 13 say radtrh->fvin+[ ]+radtrh->fplate+[ ]+radtrh->fseq+[ ]+radtrh->ftab

   * 01.23.07: house keeping for old blue plates ...
   if ypdesc = [003]
      select raplate
      seek renewal->fplate
      if eof ()
         append blank
         replace fplate with renewal->fplate, fstatus with "I"
      else
         reclock ()
         replace fstatus with "I"
      endif
      commit
      unlock
   endif
   *
   select renewal
   delete
   skip

   * 12.16.06
   if ypdesc = [003]
      select raplate
      seek yxplate
      reclock ()
      replace fstatus with "U"
      commit
      unlock
      ysplate = substr(ysplate,1,7-ydigits) + ;
         strtran(str(val(substr(ysplate,8-ydigits))+1,ydigits)," ","0")
      if ysplate > yeplate
         f_valid (.f., "Please load More Plates !")
         close data
         return
      endif
      select renewal
   endif
   *
next i

* housekeeping   && 01.18.01 skip cause out of memory when renewal is big...
* select renewal
* pack

f_valid (.f., "Process Completed...")

close data
return

***************************************************************
* 03.07.06: only allow to process 1 day ahead
function rdtp7x

f_y2k(@l_fdate)
do case
case l_fdate<=xdate
   f_valid (.f.,"Must be later than "+dtoc(xdate)) 
   return .f.
case dow(l_fdate)=1.or.dow(l_fdate)=7
   f_valid (.f.,"Must be Monday thru Friday only...")
   return .f.
case dtos(l_fdate) $ xholiday
   f_valid (.f.,"Date entered is a state holiday...")
   return .f.
case date()>xdate .and. l_fdate>date()
   f_valid (.f.,"Please run End of Day first...")
   return .f.
case l_fdate<>date()
   if dow(date())=6
      if date()+3<>l_fdate
         f_valid (.f.,"Valid date is "+dtoc(date()+3))
         return .f.
      endif
   else
      if date()+1<>l_fdate
         f_valid (.f.,"Valid date is "+dtoc(date()+1))
         return .f.
      endif
   endif
endcase

return .t.


