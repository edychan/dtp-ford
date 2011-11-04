* ===========================================================================
* System Configuration:
* ===========================================================================

set key 28 to rssschlp
restore from (gmempath + "TASYS") additive
f_use ("TASYS")
go top
if eof ()
   append blank
else
   f_retrieve ()
endif
f_screen (0, "TASYS")
do while .t.
   f_rd ()
   ykeyin = f_confirm ("[C]onfirm   [E]dit   [I]gnore Changes", "CEI")
   if ykeyin = "C"
      select tasys
      f_replace ()
      exit
   elseif ykeyin = "E"
      f_screen (1, "TASYS")
      loop
   else
      exit
   endif
enddo
set key 28 to
close databases


******************************
procedure rssschlp

private yvar, yarray[4], yptr

yvar = alltrim (upper (readvar()))
do case
otherwise
   tone (500,9)
   f_popup ("No Help information for this Field. Press Any Key to Continue...",.t.)
endcase
set cursor on
return


