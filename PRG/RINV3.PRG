************************
* update plate inventory
*
* 12.01.04: new passenger plate AAA9999
*************************
f_clrscn ("DTP/MI - Update Plate Inventory")
f_use ("raplate")
f_box (01, 02, 22, 78)
@ 02, 04 say "Plate/State  Type  Expires    Tab #   VIN      Fee   Stat Effective" 
@ 03, 04 say "ÄÄÄÄÄÄÄÄÄÄÄ  ÄÄÄÄ  ÄÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄ  ÄÄÄÄÄÄÄÄ ÄÄÄÄ- ÄÄÄÄ ÄÄÄÄÄÄÄÄÄ" 
yrow = 4

set key 28 to rinvh3

do while .t.
   restore from (gmempath + "raplate") additive
   @ yrow, 04 get l_fplate picture "!!!!!!!" valid ;
     f_valid (.not.empty(l_fplate),"This Field Cannot be Blank...")
   if f_rd () = 27
      exit
   endif
   select raplate
   seek l_fplate
   if .not. eof ()
      f_retrieve ()
   endif
   * XXX99  for special plate ==> additional fee
   * XXX999 for normal plate  ==> normal fee
   @ yrow, 04 say l_fplate    
   do while .t.
      @ yrow, 12 get l_fstate pict "!!"
      @ yrow, 17 get l_ftype pict "!!" valid f_valid (l_ftype $ "01;03;04;05;06")
      @ yrow, 23 get l_frenewal valid f_y2k(@l_frenewal)
      @ yrow, 33 get l_ftab pict "9999999"
      @ yrow, 42 get l_fvin pict "!!!!!!!!"
      @ yrow, 51 get l_fadded pict "99.99"
      @ yrow, 59 get l_fstatus pict "!" valid f_valid (l_fstatus $ "AIU")
      @ yrow, 62 get l_fedate valid f_y2k(@l_fedate)
      f_rd ()
      xkey = f_confirm ("[C]onfirm  [E]dit  [D]elete  [I]gnore Changes", "CEDI")
      do case
      case xkey = "C"
         @ yrow, 12 say l_fstate pict "!!"
         @ yrow, 17 say l_ftype pict "!!" 
         @ yrow, 23 say l_frenewal
         @ yrow, 33 say l_ftab pict "9999999"
         @ yrow, 42 say l_fvin pict "!!!!!!!!"
         @ yrow, 51 say l_fadded pict "99.99"
         @ yrow, 59 say l_fstatus pict "!" 
         @ yrow, 62 say l_fedate
         select raplate
         seek l_fplate
         if eof ()
            append blank
         endif
         f_replace ()
         exit
      case xkey = "E"
         loop
      case xkey = "D"
         select raplate
         seek l_fplate
         if .not. eof ()
            if f_confirm ("Are you sure you want to delete this " + ;
               "record? [Y/N]", "YN") = "Y"
               reclock ()
               delete
               commit
               unlock
            endif
         endif
         exit 
      case xkey = "I"
         exit
      endcase
   enddo
   if xkey <> "I"
      if yrow <= 20
         yrow = yrow + 1
      else
         scroll (4, 04, 21, 77, 1)
      endif
   else
      @ yrow, 04 clear to yrow, 77
   endif
enddo

set key 28 to
close database

****************************************************************
procedure rinvh3

private yvar, yarray[3], yptr

yvar = alltrim (upper(readvar()))
do case
case yvar = "L_FPLATE"
   select raplate
   set softseek on
   seek &yvar
   if eof()
      go bottom
   endif
   if f_pick_f (04, 05, "", "Plate/State Ä Type Ä ExpirationÄ Tab # Ä VIN # ÄÄÄ StatÄ",   ;
         "fplate+[ ]+fstate+[      ]+ftype+[    ]+dtoc(frenewal)+[   ]+ftab+[ ]+fvin+[   ]+fstatus+[   ]")
      &yvar = raplate->fplate
      keyboard chr(13)
   endif
   set softseek off
case yvar = "L_FSTATUS"
   yarray[1] = " [A]ctive    "
   yarray[2] = " [I]nactive  "
   yarray[3] = " [U]sed      "
   yptr = at (&yvar, "AIU")
   if yptr = 0
      yptr = 1
   endif
   yptr = f_pick_a (05,62,"","",yarray,3,yptr)
   if yptr > 0
      &yvar = substr(yarray[yptr],3,1)
      keyboard chr(13)
   endif
case yvar = "L_FTYPE"      && pick fee code
   f_use ("RAFEE")
   go top
   if f_valid (.not. eof (), "Missing Chart...")
      set softseek on
      seek l_ftype
      if eof ()
         go bottom
      endif
      set softseek off
      if f_pick_f (05, 05, "", "", "fcode+[ - ]+fdesc")
         &yvar = rafee->fcode
         keyboard chr (13)
      endif
   endif
   select raplate
otherwise
   tone (500,9)
   f_popup ("No Help information for this Field. Press Any Key to Continue...",.t.)
endcase
set cursor on


