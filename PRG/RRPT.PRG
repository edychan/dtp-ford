* ===========================================================================
* report module
*
* date: 05/01/91
* author: edc
*
* ===========================================================================
private yret, yfile, i, yfld, ytitle, ycond, yopt, yfilter

rest from (gmempath + "rarpt") additive
bliovlclr ()

do while .t.
   xret1 = f_pushmenu (xoption0)
   blimempak (-1)
   if xret1 = 0
      exit
   endif
   xoption1 = substr (goption [xret1], 4)
   f_use ("rarpt")
   set filter to
   do case
   case xret1 = 1 
      * print computer form
      do rrptc
      loop
   case xret1 = 2
      * reprint tr11
      do rrpt1
      loop
   case xret1 = 3
      * a/p report
      f_clrscn ("SYSTEM REPORT")
      yfilter = "#1"
   case xret1 = 4
      * process data to send to ford IT
      do rrpt4
      loop
   case xret1 = 5
      do rrptrr
      loop
   endcase
   seek yfilter
   if .not. eof()
      if f_pick_f (02, 3, "", "", "[ -> ]+ftitle+[ <- ]","","fname","yfilter")
         yrname = rarpt->fname
         ytitle = ""
         ycond = ""
         yret = f_rr (yrname, ytitle)
         if yret < 0
            tone(500, 9)
            f_popup ("Invalid Report Setup... Error: "+str(yret,3) ;
               + ". Press Any Key...",.t.)
         endif
      endif
   else
      tone (500, 9)
      f_popup ("File is Empty. Press Any Key to Continue...",.t.)
   endif
enddo

release all like l_*
close database


