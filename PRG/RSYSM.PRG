do while .t.
   xret2 = f_pushmenu (xoption1)
   if xret2 = 0
      exit
   endif
   xoption2 = substr (goption [xret2], 4)
   do case
   case xret2 = 1
      f_clrscn ("MENU SECURITY MAINTENANCE")
      declare fgp [10], fgppk [10]
      f_use ("ragroup")
      for n = 1 to 10
         go n
         fgp [n] = fgroup
      next
      use
      f_use ("litebar")
      declare fopts [reccount ()], frecno [reccount ()]
      index on str (flevel, 1) + ftitle + foption to (gstnpath + "litebar")
      do while .t.
         if f_pick_f (2, 5, "", "Menu Title컴컴컴컴컴컴컴Menu " + ;
               "Option컴컴컴컴컴컴컴컴Security", ;
               "ftitle+[  ]+foption+[  ]+fsecurity")
            yoldsecur = fsecurity
            for n = 1 to 10
               if empty (fgp [n])
                  fgppk [n] = .f.
               else
                  fgppk [n] = (str (n - 1, 1) $ fsecurity)
               endif
            next
            do while .t.
               @ 2, 2 say "Menu Title: " + ftitle
               @ 3, 2 say "Menu Option: " + foption
               for n = 1 to 10
                  if .not. empty (fgp [n])
                     @ 4 + n, 2 say str (n - 1, 1) + " " + fgp [n] + " " ;
                        get fgppk [n] pict "Y"
                  endif
               next
               f_rd ()
               yans1 = f_confirm ("[C]onfirm  [E]dit  [I]gnore Changes", "CEI")
               if yans1 = "C"
                  yrecno = recno ()
                  yfopts = 1
                  fopts [yfopts] = str (flevel + 1, 1) + substr (foption, 4)
                  frecno [yfopts] = yrecno
                  yfoptscnt = 1
                  do while .t.
                     seek fopts [yfoptscnt]
                     do while str (flevel, 1) + ftitle = fopts [yfoptscnt] ;
                           .and. .not. eof ()
                        yfopts = yfopts + 1
                        fopts [yfopts] = str (flevel + 1, 1) + ;
                           substr (foption, 4)
                        frecno [yfopts] = recno ()
                        skip
                     enddo
                     if yfoptscnt = yfopts
                        exit
                     endif
                     yfoptscnt = yfoptscnt + 1
                  enddo
                  for yfoptscnt = 1 to yfopts
                     go (frecno [yfoptscnt])
                     ystr = space (10)
                     for n = 1 to 10
                        if (str (n - 1, 1) $ fsecurity .or. ;
                              .not. (str (n - 1, 1) $ yoldsecur)) .and. fgppk [n]
                           ystr = stuff (ystr, n, 1, str (n - 1, 1))
                        endif
                     next
                     reclock ()
                     replace fsecurity with ystr
                     commit
                     unlock
                     fopts [yfoptscnt] = ""
                     frecno [yfoptscnt] = ""
                  next
                  afill (fopts, "")
                  go (yrecno)
                  exit
               elseif yans1 = "I"
                  exit
               endif
            enddo
         else
            exit
         endif
      enddo
      use
   case xret2 = 2
      do rsysmri
   case xret2 = 3
      do rsysmpu
   endcase
enddo

release all like l_*
close database

