* 
* SOS Renewal Module
*
do while .t.
   xret2 = f_pushmenu (xoption1)
   if xret2 = 0
      exit
   endif
   xoption2 = substr (goption [xret2], 4)
   do case
      case xret2 = 1     
         do rdtp7a        && process renewal
      case xret2 = 2
         * do rdtp7b        && print renewal: no longer in use 10.01.08
      case xret2 = 3
         * do rdtp7c        && print envelope: no longer needed (edc)
   endcase
enddo
close database


