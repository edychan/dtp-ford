*
* setup branch offices
*
do while .t.
   xret3 = f_pushmenu (xoption2)
   if xret3 = 0
      exit
   endif
   xoption3 = substr (goption [xret3], 4)
   f_clrscn ("BRANCH OFFICE FILE MAINTENANCE")
   rest from (gmempath+"raloc") additive
   do case
   case xret3 = 1
      f_use ("raloc")
      do while .t.
         @ 05, 02 say "Branch Office..... " get l_floc pict "!!!"
         if f_rd() = 27
            exit
         endif
         set exact on
         seek l_floc
         set exact off
         if .not. found ()
            l_fmoddt = date ()
            f_add ("raloc", "raloc")
            use
            do rsyss1a with l_fbranch
            exit
         else
            f_valid (.f., "Duplicate Branch Office...")
         endif
      enddo
   case xret3 = 2
      f_use ("raloc")
      if .not. eof ()
         if f_pick_f (05, 03, "", "", "trim(floc)+[ -> ]+f_truncate(trim(fname)+" ;
               + "[ ]+fccity,50)")
            f_update ("raloc", "raloc")
            use
            do rsyss1a with l_fbranch 
         endif
      else
         f_valid (.f., "File is Empty...")
      endif
   endcase
enddo
release all like l_*
close database

**********************
procedure rsyss1a
parameter xbranch

* update system counter
f_use ("ractr")
locate for fbranch = xbranch
if eof ()
   append blank
   replace fbranch with xbranch, fseq1 with 1
endif
use
   
