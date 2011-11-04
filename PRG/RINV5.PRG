*
* update tab inventory
*
* changes: 
* 10/25/96: add year to tab file
* 10/30/96: validate tab # against radtrh
*           make sure tab not loaded in more than once
* 05.10.98: allow leading 0
*
f_clrscn ("DTP/MI - Update Tab Inventory")
f_use ("radtrh",4)
f_use ("ratab")
f_box (01, 02, 22, 78)
@ 02, 04 say "  Tab #   Year  Stat" 
@ 03, 04 say "컴컴컴컴  컴컴  컴컴"
yrow = 4
set key 28 to rinvh5
do while .t.
   l_ftab = space (7)
   l_fyear = space(4)
   l_fstatus = " "
   @ yrow, 04 get l_ftab pict "9999999" valid ;
     f_valid (len(alltrim(l_ftab)) = 7,"Must be 7 digits...")
   if f_rd () = 27
      exit
   endif
   * 10/30/96
   select radtrh
   seek l_ftab
   if .not. eof ()
      f_valid (.f., "This is an used tab, Please Check History Trans ")
      * loop
   endif
   *
   select ratab
   seek l_ftab
   if .not. eof ()
      l_fyear = fyear
      l_fstatus = fstatus
   endif
   @ yrow, 04 say l_ftab    
   do while .t.
      @ yrow, 14 get l_fyear pict "9999" valid;
        f_valid (len(alltrim(l_fyear))=4, "Must be 4 digits, e.g. 1997...")
      @ yrow, 22 get l_fstatus pict "!" valid ;
        f_valid (l_fstatus $ "AVXU", "Enter [A]vailable [V]oid or [U]sed...")
      f_rd ()
      xkey = f_confirm ("[C]onfirm  [E]dit  [D]elete  [I]gnore Changes", "CEDI")
      do case
      case xkey = "C"
         select ratab
         seek l_ftab
         if eof ()
            append blank
         else
            reclock ()
         endif
         replace ftab with l_ftab
         replace fyear with l_fyear, fstatus with l_fstatus
         commit
         unlock
         exit
      case xkey = "E"
         loop
      case xkey = "D"
         select ratab
         seek l_ftab
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

close database
set key 28 to

*****************
procedure rinvh5

private yvar, yscn, ycolor, yname, ystr
yvar = alltrim (upper (readvar ()))
ycolor = setcolor (gsubcolor)
f_use ("RATAB")
set softseek on
seek &yvar
set softseek off
if f_valid (.not. eof (), "Invalid Tab #...")
   if f_pick_f (4, 15, "", "", "[ - ]+ ftab + [ - ] + fyear + " + ;
      "[ - ] + fstatus + [ - ]")
      &yvar = ratab->ftab
      keyboard chr (13)
   endif
endif
setcolor (ycolor)
return



