*
* find deleted record from radtrh
*
set excl off
set delete off
set century on
ystart = date()
yend = date()
clear
@ 01, 05 say "Enter Start Date: " get ystart
@ 02, 05 say "Enter End Date  : " get yend
read
use f:\dtp\dbf\radtrh index f:\dtp\dbf\radtrh1
seek '804'+dtos(ystart)
i = 0
do while .not. eof() .and. fdate <= yend
   if deleted()
      i = i + 1
      if i > 20
         ? "Press <Esc> to stop ..." 
         if inkey (0) = 27
            exit
         else
            i = 0
         endif
      endif
      ? dtoc(fdate) + " " + fvin + " " + fplate + " " + ftab + " " + faction + " " + fclerk
   endif
   skip
enddo
? "Process Completed...press any key"
inkey(0)
close all

