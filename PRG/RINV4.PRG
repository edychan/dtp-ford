*
* load tab inventory
*
* changes: 
* 10/25/96: add year to tab file
* 10/30/96: validate tab # against radtrh
*           make sure tab not loaded in more than once
* 05.10.98: allow leading 0 
*
private  ystart, yend, y1, y2, yyr

f_clrscn ("DTP/MI - TAB INVENTORY")
* 
close data     && 02/05/97
*
f_box (02, 05, 06, 65, "Load TAB Inventory")

yyr = space(4)
ystart = [0000000]
yend = [0000000]
@ 03, 07 say "Year [e.g. 2007]......... "
@ 04, 07 say "Starting Number.......... "
@ 05, 07 say "Ending Number............ "

do while .t.
   @ 03, 33 get yyr pict "9999" valid ;
     f_valid (len(alltrim(yyr))=4, "Must be 4 digits...")
   @ 04, 33 get ystart pict "9999999" valid ;
     f_valid (len(alltrim(ystart))=7,"Must be 7 digits...")
   @ 05, 33 get yend pict "9999999" valid ;
     f_valid (len(alltrim(yend))=7,"Must be 7 digits...")
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
ystamp = gusrid+dtos(date())      && 02/11/97
f_use ("radtrh",4)
f_use ("ratab")
y1 = val(ystart)
y2 = val(yend)
for i = y1 to y2
   ytab = strtran (str(i,7)," ","0")
   select radtrh      && tab cannot be duplicate
   seek ytab
   if eof ()
      select ratab
      seek ytab
      if eof ()
         append blank
         replace fyear with yyr, ftab with ytab, fstatus with "A"
         replace fstamp with ystamp
         commit
         unlock
      endif
   endif
   if yrow >= 21
      scroll (12, 10, 21, 60, 1)
   else
      yrow = yrow + 1
   endif
   @ yrow, 13 say ytab

next i

close data
set key 28 to
f_valid (.f., "Process completed...")


