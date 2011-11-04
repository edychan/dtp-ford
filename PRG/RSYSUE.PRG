private yfil, ys1, yfilnum, yptr

do while .t.
   xret3 = f_pushmenu (xoption2)
   if xret3 = 0
      exit
   endif
   xoption3 = substr (goption [xret3], 4)
   f_clrscn ("E-MAIL MAINTENANCE")
   do case
   case xret3 = 1
      f_use ("rausr")
      if f_pick_f (05, 3, "", "", "fid + [ -> ] + " + ;
            "f_truncate (trim (ffname) + [ ] + flname, 27)")
         yfil = gmsgpath + alltrim(fid) + "_" + alltrim (gusrid) + ".msg"
         if file (yfil)
            f_rrout (yfil, .t., "Message To " + alltrim (fid))
         else
            ys1 = fcreate (yfil,0)
            if ys1 < 0
               f_popup ("Unable to create message file. Press Any Key to Retry...", .t.)
               loop
            endif
            fclose (ys1)
            f_rrout (yfil, .t., "Message To " + alltrim (fid))
         endif
         if gsup
            if f_confirm ("Send to other locations? [Y/N]", "YN") = "Y"
               copy file &yfil to (gsupmpath + alltrim(fid) + "_" + ;
                     alltrim (gusrid) + ".msg")
            endif
         endif
      endif
      select rausr
      use
   case xret3 = 2
      f_clrscn ("E-MAIL MAINTENANCE")
      yfil = gmsgpath + alltrim (gusrid) + "_*" + ".msg"
      yfilnum = adir (yfil)
      if yfilnum = 0
         f_popup ("No Message For Now...", .t.)
         loop
      endif

      private yfilary [yfilnum]
      adir (yfil, yfilary)
      for yptr = 1 to yfilnum
         yfilary [yptr] = f_truncate (strtran (upper (alltrim (substr (yfilary [yptr], ;
               len (alltrim (gusrid)) + 2))), ".MSG", ""), 4)
      next
      yptr = 1
      do while .t.
         if yfilnum > 1
            yptr = f_pick_a (2, 5, "", "From", yfilary, yfilnum, 1)
            if yptr = 0
               exit
            endif
         else
            yptr = 1
         endif
         yfil = gmsgpath + alltrim (gusrid) + "_" + alltrim (yfilary [yptr]) + ".msg"
         f_rrout (yfil, .f., "Message From " + alltrim (yfilary [yptr]))
         if f_confirm ("Do you want to erase this message? [Y/N]", "YN") = "Y"
            adel (yfilary, yptr)
            yfilnum = yfilnum - 1
            erase &yfil
            if yfilnum = 0
               exit
            endif
         elseif yfilnum = 1
            exit
         endif
      enddo
   endcase
enddo

