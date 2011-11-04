* ===========================================================================
* rate table maint.
*
* date: 05/01/91
* author: edc
*
* revision
* ===========================================================================
parameters xupd
private xrow, xcdw

f_clrscn ("Rate Table Maintenance")
setcolor (gbluecolor)
restore from (gmempath + "rartm") additive
f_use ("RARTM")

l_fcode = space (6)
ycnt = 1
do while .t.
   if xupd = "U"
      setcolor (gredcolor)
      @ 24, 00
      @ 24, 01 say "Press F1 For To Pick Rate"
   endif
   setcolor (gbluecolor)
   @ ycnt + 1, 1 say "Rate:        Daily:          Weekly:          Monthly:          Hourly:      " 
   @ ycnt + 2, 1 say "Airport Access Fee:          Disc  :        "
   @ ycnt + 3, 1 say "Remark: "
   if xupd = "U"
      set key 28 to rsysssrh
   endif
   @ ycnt+1, 7 get l_fcode picture "!!!!!!" valid f_valid (.not. empty (l_fcode))
   if f_rd () = 27
      set key 28 to
      exit
   endif
   set key 28 to

   select rartm
   seek l_fcode 
   if xupd = "U"
      if f_valid (found (), "Rate Not Found!!!")
         f_retrieve ()
      else
         loop
      endif
      clear gets
   else
      if .not. f_valid (.not. found (), "Rate Already Exists!!!")
         loop
      endif
   endif
   do while .t.
      @ ycnt + 1, 21 get l_fdlychg picture "999.99"
      @ ycnt + 1, 38 get l_fwkchg picture "999.99"
      @ ycnt + 1, 56 get l_fmthchg picture "999.99"
      @ ycnt + 1, 73 get l_fhrchg picture "999.99"
      @ ycnt + 2, 21 get l_fsurchg picture "999.99"
      @ ycnt + 2, 38 get l_fdisc picture "999.99"
      @ ycnt + 3, 09 get l_fremark
      f_rd ()
      if xupd = "A"
         xkey = f_confirm ("[C]onfirm  [E]dit  [V]oid", "CEV")
         do case
         case xkey = "C"
            append blank
            f_replace ()
            f_fupdate ("A")
            exit
         case xkey = "E"
            loop
         case xkey = "V"
            exit
         endcase
      else
         xkey = f_confirm ("[C]onfirm  [D]elete  [E]dit  [I]gnore Changes", ;
               "CDEI")
         do case
         case xkey = "C"
            f_fupdate ("C")
            f_replace ()
            exit
         case xkey = "E"
            loop
         case xkey = "D"
            if f_confirm ("Are You Sure? [Y/N]", "YN") = "Y"
               f_fupdate ("D")
               reclock ()
               delete
               unlock
            endif
            exit
         case xkey = "I"
            exit
         endcase
      endif
   enddo

   if xkey <> "I"
      if ycnt < 16
         ycnt = ycnt + 5
      else
         scroll (1, 0, 23, 79, 5)
      endif
   endif
   if ycnt > 1
      @ ycnt - 1, 1 say replicate (chr (196), 78)
   endif
enddo
set key 28 to
close databases


******************************
procedure rsysssrh

select rartm
go top
if .not. eof ()
   set softseek on
   seek l_fcode + l_floc 
   if eof ()
      go bottom
   endif
   set softseek off
   if f_pick_f (ycnt + 1, 9, "", "Rate   Remark              ", ;
         "FCODE + [ ] + FREMARK")
      setcolor ("N/W")
      l_fcode = rartm->fcode
      @ ycnt + 1, 7 say l_fcode
      setcolor (gbluecolor)
      keyboard chr (13)
   endif
endif

