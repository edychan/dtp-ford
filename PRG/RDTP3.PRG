* ===========================================================================
*
* print transactions
*
* ===========================================================================
do while .t.
   xret2 = f_pushmenu (xoption1)
   if xret2 = 0
      exit
   endif
   xoption2 = substr (goption [xret2], 4)
   do case
      case xret2 = 1            && print tr11
         do rdtp3a
      case xret2 = 2            && print tab
         do rdtp3b
      case xret2 = 3            && print replacement tab
         do rdtp3c 
   endcase
enddo



