* -----------------------------------------------------
* update vehicle inventory
*
* -----------------------------------------------------
* 12.01.04: new plate config. AAA9999
* -----------------------------------------------------
* 10.01.08: add FYEAR, FMAKE, FMSRP, FSTYLE, FFEE
* -----------------------------------------------------
f_clrscn ("DTP/MI - Update Vehicle Record")

* -- 10.01.08
f_use ("rabody")
f_use ("rafee")
f_use ("ravin")
* --

f_use ("ravm")

f_box (01, 02, 22, 78)
@ 02, 04 say "    VIN #         Yr/Make         MSRP/Body/Fee Plate   Prv Plate Titled  "
@ 03, 04 say "ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄÄ ÄÄÄÄÄÄÄÄ"
yrow = 4                        
set key 28 to rinvh1
do while .t.
   restore from (gmempath + "ravm") additive
   @ yrow, 04 get l_fvin picture "!!!!!!!!!!!!!!!!!"
   if f_rd () = 27
      exit
   endif
   select ravm
   if len(trim(l_fvin)) > 8
      seek substr(l_fvin,10,8)
   elseif len(trim(l_fvin)) = 8
      seek l_fvin
      if eof ()
         f_valid (.f., "Please Check VIN...")
         loop
      endif
      if f_pick_f (04, 05, "", "", "fvin+[ ]+fyear+[ ]+fmake+[ ]+str(fmsrp,6)+[ ]+fplate+[ ]+dtoc(fdate1)")
         l_fvin = fvin
      else
         loop
      endif
   elseif empty(l_fvin)
      f_valid (.f., "Press <F1> for Help...")
      loop
   endif
   if .not. eof ()
      l_fvin = ravm->fvin
      f_retrieve ()
   endif
   * check vin #
   if .not. f_goodvin (l_fvin)
      loop
   endif
   @ yrow, 04 say l_fvin
   do while .t.
      @ yrow, 22 get l_fyear pict "99"            && 10.01.08
      @ yrow, 25 get l_fmake pict "!!!!!!!!!!!!"
      @ yrow, 38 get l_fmsrp pict "999999" valid rinv1a ()   
      @ yrow, 45 get l_fstyle pict "!!!" valid rinv1b ()
      @ yrow, 49 get l_ffee pict "99" valid ;
        f_valid (f_verify("rafee",1,l_ffee),"Press <F1> for help...")
      @ yrow, 52 get l_fplate pict "!!!!!!!"     
      @ yrow, 60 get l_fpplate pict "!!!!!!!"
      @ yrow, 70 get l_fdate1 valid f_y2k(@l_fdate1) 
      f_rd ()
      xkey = f_confirm ("[C]onfirm  [E]dit  [D]elete  [I]gnore Changes", "CEDI")
      do case
      case xkey = "C"
         @ yrow, 22 say l_fyear pict "99"            && 10.01.08
         @ yrow, 25 say l_fmake pict "!!!!!!!!!!!!"
         @ yrow, 38 say l_fmsrp pict "999999" 
         @ yrow, 45 say l_fstyle pict "!!!" 
         @ yrow, 49 say l_ffee pict "99" 
         @ yrow, 52 say l_fplate pict "!!!!!!!"     
         @ yrow, 60 say l_fpplate pict "!!!!!!!"
         @ yrow, 70 say l_fdate1 
         select ravm
         seek substr(l_fvin,10,8)
         if eof ()
            append blank
         endif
         reclock ()
         f_replace ()
         exit
      case xkey = "E"
         loop
      case xkey = "D"
         select ravm
         seek substr(l_fvin,10,8)
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
close data

**************************
* validate MSRP
function rinv1a
private ykey

if l_fmsrp <= 0
   f_valid (.f.,"Must be greater than Zero...")
   return .f.
endif

ykey = substr(l_fvin,1,8)+substr(l_fvin,10,1)
select ravin
seek ykey
if .not. eof ()
   if abs(l_fmsrp - ravin->fmsrp) > 1000
      f_valid (.f., "Warning: MSRP is shown as "+str(ravin->fmsrp,6,0)+"in VIN Chart..." )
      if f_confirm ("[R]etype    [C]ontinue ", "RC") = "R"
         select ravm
         return .f.
      endif
   endif
endif

select ravm
return .t.

*****************************************
function rinv1b

if f_verify ("rabody",1,l_fstyle) 
   f_compute (@l_ffee, rabody->ftype)
   return .t.
else
   f_valid (.f., "Press <F1> for help...")
   return .f.
endif
               
**************************
procedure rinvh1

private yvar, yscn, ycolor, yname, ystr
yvar = alltrim (upper (readvar ()))
ycolor = setcolor (gsubcolor)
do case
case yvar = "L_FVIN"
   select ravm
   set softseek on
   seek &yvar
   set softseek off
   if f_valid (.not. eof (), "Invalid VIN...")
      if f_pick_f (04, 05, "", "", "fvin+[ ]+fyear+[ ]+fmake+[ ]+str(fmsrp,6)+[ ]+fplate+[ ]+dtoc(fdate1)")
         &yvar = ravm->fvin
         keyboard chr (13)
      endif
   endif
case yvar = "L_FSTYLE"      && pick body style
   select rabody
   set softseek on
   seek l_fstyle
   if eof ()
      go bottom
   endif
   set softseek off
   if f_pick_f (05, 05, "", "", "fcode+[ - ]+fdesc")
      &yvar = rabody->fcode
      f_compute (@l_ffee, rabody->ftype)
      keyboard chr (13)
   endif
   select ravm
case yvar = "L_FFEE"      && pick fee code
   select rafee
   set softseek on
   seek l_ffee
   if eof ()
      go bottom
   endif
   set softseek off
   if f_pick_f (05, 05, "", "", "fcode+[ - ]+fdesc")
      &yvar = rafee->fcode
      keyboard chr (13)
   endif
   select ravm
otherwise
   tone (500,9)
   f_popup ("No Help information for this Field. Press Any Key to Continue...",.t.)
endcase
setcolor (ycolor)
return
