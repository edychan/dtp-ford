*
*  print envelope 
*
*  note: 12.02.97
*  1. load labels data by addlab.exe into f:\dtp\dbf\labels.dbf
*  2. fkey = "E" or "L" class
*  3. clean up labels.dbf manually (after all is printed, zap labels.dbf)
*  
private y1, y2, yfil, yntx, ycc, ytot, xstart, xend, xprt, xnl

f_clrscn ("DTP - PRINT LABELS")

yfil = "f:\dtp\dbf\labels.dbf"
yntx = "f:\dtp\dbf\labels.ntx"
if .not. file (yfil)
   f_valid (.f., "Missing Label File...")
   return
else
   select 0
   use &yfil index &yntx alias labels
endif

ycnt = reccount()
go bottom
y2 = fline1
go top
y1 = fline1
f_box (01, 02, 06, 78,"Total of "+alltrim(str(ycnt,6))+" Labels ")
@ 02, 04 say "Starting......          ["+y1+"]"
@ 03, 04 say "Ending........          ["+y2+"]"
@ 04, 04 say "No. of Labels.          [Max.= 9999]"
@ 05, 04 say "Printer.......          [LPT1/LPT2/LPT3]"

ytot = 0           && total # of labels printed
xstart = space(7)
xend = space(7)
xnl = 0
xprt = [LPT1]
do while .t.
   @ 02, 19 get xstart pict "!!!!!!!" 
   @ 03, 19 get xend pict "!!!!!!!" valid f_valid (xend >= xstart .or. empty(xend))
   @ 04, 19 get xnl pict "9999" valid f_valid (xnl > 0)
   @ 05, 19 get xprt pict "!!!!" valid f_valid (xprt $ "LPT1;LPT2;LPT3")
   if f_rd () = 27
      close data
      return
   endif
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "C"
      exit
   elseif yret = "Q"
      close data
      return
   endif
enddo

if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
   close data
   return
endif

* setup print condition
do case
case empty(xstart) .and. empty(xend)
   xcond = "xnl >= ytot"
case empty(xstart) .and. .not. empty(xend)
   xcond = "xnl >= ytot .and. fline1 <= xend"
case .not. empty(xstart) .and. empty(xend)
   select labels
   set softseek on
   seek substr(xstart,4,1)+substr(xstart,1,3)+substr(xstart,5)
   set softseek off
   xcond = "xnl >= ytot"
case .not. empty(xstart) .and. .not. empty(xend)
   select labels
   set softseek on
   seek substr(xstart,4,1)+substr(xstart,1,3)+substr(xstart,5)
   set softseek off
   xcond = "xnl >= ytot .and. fline1 <= xend"
endcase

select labels
if eof ()
   f_valid (.f., "No Data...")
   close data
   return
endif

f_popup ("Please Wait While Printing...")
set console off
set print on
set printer to &xprt
ycc = "chr(27)+chr(65)+chr(12)+chr(27)+chr(67)+chr(66)"
?? &ycc
begin sequence
   do while .not. eof () .and. &xcond
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
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ? space(25)+trim (fline1)
      ? space(25)+trim (fline2)
      ? space(25)+trim (fline3)
      ? space(25)+trim (fline4)
      ? space(25)+trim (fline5)
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      ?
      skip
      if eof ()
         eject 
         exit
      endif
      ?
      ?
      ?
      ?
      ?
      ? space(25)+trim (fline1)
      ? space(25)+trim (fline2)
      ? space(25)+trim (fline3)
      ? space(25)+trim (fline4)
      ? space(25)+trim (fline5)
      ?
      eject
      ytot = ytot + 2
      skip
   enddo
end
* reset printer
* ? chr(18)

set print off
set printer to
set console on
set device to screen

set filter to
close data
f_valid (.f., "Process Completed...")

