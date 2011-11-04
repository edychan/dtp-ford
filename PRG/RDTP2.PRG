*
* audit dtp trans.
* delete only
* Revision.
* 08.13.97. Delete plate # from audit also
* 12.01.04: new plate config. AAA9999
*
* 12.11.06: display fpplate + fplate info.
*
restore from (gmempath + "radtrh") additive
f_clrscn ("DTP/MI - Delete Transaction")
f_box (01, 02, 04, 78)
@ 02, 04 say "Office #......"
@ 02, 41 say "Clerk ID......"
@ 03, 04 say "Date.........."
l_floc = gloc
l_fdate = date()
l_fclerk = gclerk

* check last post date
f_use ("rasys")
xdate = fpostdate
use

do while .t.
   @ 02, 19 get l_floc pict "!!!" valid ;
     f_valid (rdtp2a())
   @ 02, 56 say l_fclerk
   @ 03, 19 get l_fdate valid   ;
     f_valid (f_y2k(@l_fdate).and.l_fdate>xdate, "Must be later than "+dtoc(xdate))
   if f_rd () = 27
      return
   endif
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "C"
      exit
   elseif yret = "Q"
      return
   endif
enddo

set key 28 to rdtph2
f_use ("raaudit")
f_use ("ratab")
f_use ("raplate")
f_use ("radtrh")
f_box (01, 02, 22, 78)
@ 02, 04 say "SEQ # VIN #             Type  Plate     Tab #   Title  Reg Fee Transfer "
@ 03, 04 say "ÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄ  ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ "           
yrow = 4
do while .t.
   l_fseq = space (4)
   @ yrow, 04 get l_fseq pict "9999" valid rdtp2b ()
   if f_rd () = 27
      exit 
   endif
   @ yrow, 04 say l_fseq
   @ yrow, 10 say l_fvin
   @ yrow, 30 say l_faction pict "!" 
   @ yrow, 35 say l_fplate pict "!!!!!!!"    && 12.01.04
   @ yrow, 44 say l_ftab pict "9999999" 
   @ yrow, 52 say l_ftitle pict "999.99"
   @ yrow, 60 say l_freg pict "999.99"
   @ yrow, 68 say l_ftfee pict "999.99" 
   xkey = f_confirm ("Delete this transaction [Y/N] ?", "YN")
   if xkey = "Y"
      select raaudit
      seek substr(l_fvin,10,8)
      if .not. eof ()
          reclock ()
          delete
          commit
          unlock
      endif
      * 08.13.97 audit plate
      if .not. empty(l_fplate)
         select raaudit
         seek l_fplate
         if .not. eof ()
             reclock ()
             delete
             commit
             unlock
         endif
      endif
      if .not. empty (l_ftab)
         select ratab
         seek l_ftab
         if .not. eof ()
            reclock ()
            replace fstatus with "A"
            commit
            unlock
         endif
      endif
      if .not. empty (l_fplate) .and. l_faction $ [2;5]
         select raplate
         seek l_fplate
         if .not. eof ()
            reclock ()
            replace fstatus with "A"
            commit
            unlock
         endif
      endif        
      select radtrh
      reclock ()
      delete
      commit
      unlock
      if yrow < 22
         yrow = yrow + 1
      else
         scroll (4, 04, 21, 77, 1)
      endif
   else
      @ yrow, 04 clear to yrow, 77
   endif
enddo

set key 28 to
close data

****************
function rdtp2a

f_use ("raloc")
seek l_floc
if eof ()
   return .f.
else
   l_fbranch = fbranch
   return .t.
endif

*************************
function rdtp2b

select radtrh
l_fseq = strtran(str(val(l_fseq),4), " ","0")
seek l_fbranch+dtos(l_fdate)+l_fseq
if eof ()
   f_valid (.f., "Invalid SEQ #...")
   return .f.
else
   f_retrieve ()
   return .t.
endif

***************************
procedure rdtph2

select radtrh
set softseek on
seek l_fbranch+dtos(l_fdate)
set softseek off
if eof ()
   f_valid (.f., "No Transaction...")
   return 
endif

* 12.11.06
if f_pick_f (4, 04, "", "", "fseq+[  ]+substr(fvin,10,8)+[ ]+fclerk+[  ]+faction+[ ]+" + ;
             "fplate+[ / ]+fpplate+[  ]+ftab+[  ]+str(ftitle,6,2)+[ ]+str(freg,6,2)+[ ]+" + ;
             "str(ftfee,6,2)", "",   +  ;
             "fbranch+dtos(fdate)", "l_fbranch+dtos(l_fdate)")
   l_fseq = radtrh->fseq
   keyboard chr (13)
endif
