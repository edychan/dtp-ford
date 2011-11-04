*
* delete tab inventory
*
* 05.10.98: allow leading 0

private  ystart, yend, y1, y2, yyr

f_clrscn ("DTP/MI - TAB INVENTORY")
*
close data       && 02/05/97
*
f_box (02, 05, 05, 65, "Delete TAB Inventory")

ystart = [0000000]
yend = [0000000]
@ 03, 07 say "Starting Number.......... "
@ 04, 07 say "Ending Number............ "

do while .t.
   @ 03, 33 get ystart pict "9999999" valid ;
     f_valid (len(alltrim(ystart))=7, "Must be 7 digits...")
   @ 04, 33 get yend pict "9999999" valid ;
     f_valid (len(alltrim(yend))=7 , "Must be 7 digits...")
   f_rd ()
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit", "CEQ")
   if yret = "Q"
      set key 28 to
      return
   elseif yret = "E"
     loop
   endif
   if len(alltrim(ystart)) < 7 .or. len(alltrim(yend)) < 7
      f_valid (.f., "Please Re-enter...")
      loop
   endif
   if yend < ystart
      f_valid (.f., "Ending Number cannot be greater than Starting Number...")
      loop
   endif
   exit
enddo

f_box (11, 05, 22, 65, "Processing Transaction")
yrow = 11
* 
close data
*
y1 = val(ystart)
y2 = val(yend)
f_use ("ratab")
set softseek on
seek ystart
set softseek off
do while .not. eof() .and. val(ratab->ftab)>=y1 .and. val(ratab->ftab)<=y2
   if yrow >= 21
      scroll (12, 10, 21, 60, 1)
   else
      yrow = yrow + 1
   endif
   @ yrow, 13 say ratab->ftab
   reclock ()
   delete 
   commit
   unlock 
   skip
enddo

close data
f_valid (.f., "Process completed...")




