**************************************

f_clrscn ()
set key 28 to rcomh3
f_popup ("Please Wait While Retrieving Setup Information...", .f.)
f_use ("RAMDMSU")
f_use ("RASTN")
seek f_truncate (gstation, 8)
l_finitstr = finitstr
l_fmodem = fmodem
l_fcomm = fcomm
l_fbaud = fbaud
l_fdatabit = fdatabit
l_fstopbit = fstopbit
l_fparity = fparity
l_fsd = fsd
l_frd = frd
l_ftimeout = ftimeout
l_fphone1 = fphone1
l_fphone2 = fphone2
select ramdmsu
seek l_fmodem
if .not. found ()
   go top
endif
f_getscn ("RAMDM")

do while .t.
   f_screen (1, "RAMDM")
   f_rd ()
   ykey = f_confirm ("[C]onfirm  [E]dit  [I]gnore Changes", "CEI")
   do case
   case ykey = "C"
      select rastn
      reclock ()
      replace finitstr with l_finitstr
      replace fmodem with l_fmodem
      replace fcomm with l_fcomm
      replace fbaud with l_fbaud
      replace fdatabit with l_fdatabit, fstopbit with l_fstopbit
      replace fparity with l_fparity, fsd with l_fsd, frd with l_frd
      replace ftimeout with l_ftimeout
      replace fphone1 with l_fphone1
      replace fphone2 with l_fphone2
      commit
      unlock
      exit
   case ykey = "E"
      loop
   case ykey = "I"
      exit
   endcase
enddo
set key 28 to
close databases

******************************
procedure rcomh3

private yvar, yarray [4], yptr

yvar = alltrim (upper (readvar ()))
do case
case yvar = "L_FMODEM"
   select ramdmsu
   if f_pick_f (3, 55, "", "", "FMODEM")
      l_fmodem = ramdmsu->fmodem
      l_finitstr = ramdmsu->finit
   endif
   keyboard chr (13)
case yvar = "L_FCOMM"
   yarray [1] = "0"
   yarray [2] = "1"
   yarray [3] = "2"
   yarray [4] = "3"
   yptr = f_pick_a (5, 27, "", "", YARRAY, 4, ;
      ascan (yarray, str (l_fcomm, 1)))
   if yptr > 0
      l_fcomm = val (yarray [yptr])
      keyboard chr (13)
   endif
case yvar = "L_FBAUD"
   yarray [1] = " 300"
   yarray [2] = "1200"
   yarray [3] = "2400"
   yptr = f_pick_a (5, 27, "", "", YARRAY, 3, ;
      ascan (yarray, str (l_fbaud, 4)))
   if yptr > 0
      l_fbaud = val (yarray [yptr])
      keyboard chr (13)
   endif
case yvar = "L_FPARITY"
   yarray [1] = "0 - None"
   yarray [2] = "1 - Odd "
   yarray [3] = "2 - Even"
   yptr = f_pick_a (5, 27, "", "", YARRAY, 3, ;
      ascan (yarray, str (l_fparity, 1)))
   if yptr > 0
      l_fparity = val (yarray [yptr]) - 1
      keyboard chr (13)
   endif
case yvar = "L_FSTOPBIT"
   yarray [1] = "1"
   yarray [2] = "2"
   yptr = f_pick_a (5, 27, "", "", YARRAY, 2, ;
      ascan (yarray, str (l_fstopbit, 1)))
   if yptr > 0
      keyboard chr (13)
      l_fstopbit = val (yarray [yptr])
   endif
case yvar = "L_FDATABIT"
   yarray [1] = "7"
   yarray [2] = "8"
   yptr = f_pick_a (5, 27, "", "", YARRAY, 2, ;
      ascan (yarray, str (l_fdatabit, 1)))
   if yptr > 0
      keyboard chr (13)
      l_fdatabit = val (yarray [yptr])
   endif
endcase
set cursor on


