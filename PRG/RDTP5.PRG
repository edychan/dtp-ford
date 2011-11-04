* ----------------------------------------------------
* end of day processing
* ----------------------------------------------------
* 09/11/96: add 10th digit (model year) to vin chart
* 10/25/96: cleanup ratab & raaudit
* 09.12.05: special processing for 812
* ----------------------------------------------------
* 10.01.08: use ravm for vehicle pertinent info.
* ----------------------------------------------------
private yfil, yret

f_clrscn ("End of Day Processing")
*
close data         && 02/05/97
*
f_use ("rasys")
xpost = fpostdate                 && last posted date
x804ctr = f804ctr                 && 12.16.06: batch no for 804 return file
use
* 09.12.05: check holiday table
yfil = gmempath + substr(dtos(date()),1,4) + ".mem"
if file (yfil)
   restore from (yfil) additive
else
   xholiday = ""
endif

f_box (01, 02, 10, 78)
@ 02, 04 say "Branch #......"
@ 02, 50 say "Last Posted on.... " + dtoc(xpost)
@ 03, 04 say "Date.........."

f_use ("radtrh")
xbranch = gloc
xdate = date()

do while .t.
   @ 02, 19 get xbranch pict "!!!" valid f_valid (rdtp4a())
   @ 03, 19 get xdate valid f_valid(f_y2k(@xdate).and. ;
     if(xbranch=[812],.t.,xdate > xpost),"Last posted on "+dtoc(xpost)) .and. ;
     f_valid (dow(xdate)>=2.and.dow(xdate)<=6, "Monday thru Friday ONLY") .and. ;
     f_valid (.not.(dtos(xdate) $ xholiday), "State Holiday")

   if f_rd () = 27
      close data
      return
   endif
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "C"
      select radtrh
      set softseek on
      seek xbranch + dtos(xdate)
      set softseek off     
      if fbranch <> xbranch .or. fdate <> xdate    && 09.12.05 
         f_valid (.f., "No transaction to be processed...") 
         loop
      else                             
         if f_confirm ("Are you sure [Y/N] ? ","YN") = "Y"
            exit
         else
            loop
         endif
      endif
   elseif yret = "Q"
      close data
      return
   endif
enddo

* confirm user to run eod processing
* special process for branch 812
if xbranch = [812]
   * step 1
   @ 05, 04 say "Step 1. Create Send File "
   do rdtp5a with xbranch, xdate, x804ctr
   @ 06, 04 say "Step 2. Print End of Day Report "
   do rdtp4b with xbranch, xdate
else
   * step 1
   @ 05, 04 say "Step 1. Reset Counter "
   f_use ("ractr")
   locate for fbranch = xbranch
   if .not. eof ()
      reclock ()
      replace fseq1 with 1
      commit
      unlock
   endif
   use
   
   * step 2
   @ 06, 04 say "Step 2. Create Send File "
   do rdtp5a with xbranch, xdate, x804ctr

   * step 3
   @ 07, 04 say "Step 3. Reset Print File "

   * delete print files
   declare yprt [10]
   y1 = "f:\dtp\forms\*.txt"
   nf=adir(y1,yprt)
   nf=if(nf>10,10,nf)
   for i = 1 to nf
      yfil = "f:\dtp\forms\" + yprt[i]
      erase &yfil
   next i

   xfil = "f:\dtp\dbf\radtrp"
   yfil = "f:\dtp\dbf\tmp"
   set excl on
   f_use ("radtrp")
   copy stru to &yfil
   use
   use &yfil
   copy stru to &xfil
   use
   f_use ("radtrp") 
   reindex
   use
   set excl off

   * clean tab file
   xfil = "f:\dtp\dbf\ratab"
   yfil = "f:\dtp\dbf\tmp"
   set excl on
   f_use ("ratab")
   copy to &yfil for fstatus <> "U" .and. .not. deleted()
   use
   use &yfil
   copy to &xfil
   use
   f_use ("ratab")
   reindex
   use
   set excl off

   * delete audit file
   xfil = "f:\dtp\dbf\raaudit"
   yfil = "f:\dtp\dbf\tmp"
   set excl on
   f_use ("raaudit")
   copy stru to &yfil
   use
   use &yfil
   copy stru to &xfil
   use
   f_use ("raaudit")
   reindex
   use
   set excl off

   * step 4
   @ 08, 04 say "Step 4. Print End of Day Report "
   do rdtp4b with xbranch, xdate

   * update post date
   f_use ("rasys")
   go top
   reclock ()
   replace fpostdate with xdate
   replace f804ctr with f804ctr + 1     && 804 return file batch no
   unlock
   commit
endif

f_valid (.f., "Process completed...")

close data


