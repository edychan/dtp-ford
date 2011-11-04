* ===========================================================================
* GMARP - vehicle records
*
* Date:   09/22/94
* Author: EDC
*
* Revision:
*
* ===========================================================================
private yarray[2], yptr, yret, ykey, yval

do while .t.
   xret1 = f_pushmenu (xoption0)
   if xret1 = 0
      exit
   endif
   xoption1 = substr (goption [xret1], 4)
   do case
   case xret1 = 1
      do rinv1
   case xret1 = 2        && add plate
      do rinv2
   case xret1 = 3        && update plate
      do rinv3
   case xret1 = 4        && load tab
      do rinv4
   case xret1 = 5        && update tab
      do rinv5
   case xret1 = 6        && delete tab
      do rinv6
   endcase
enddo

release all like l_*
close database

