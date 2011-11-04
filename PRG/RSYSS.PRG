*
* system - setup parameters
*
do while .t.
   xret2 = f_pushmenu (xoption1)
   if xret2 = 0
      exit
   endif
   xoption2 = substr (goption [xret2], 4)
   do case
      case xret2 = 1     
         do rsyss1
      case xret2 = 2
         do rsyss2
      case xret2 = 3            && VIN chart
         do rsyss3
      case xret2 = 4            && misc chart
         do rsyss4
   endcase
enddo
release all like l_*
close database


