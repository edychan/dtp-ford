*
* view 812 initial REQ record
*
private ypath, yfil, ydate, ybranch

f_clrscn ("DTP/MI - View 812 Initial Request Record")

ypath = gdbfpath
yfil = ypath + "RAREQ"
select 0
use &yfil index &yfil alias rareq
go top
ybranch = [812]
ydate = date()
do while .t.
  @ 02,02 say "Date: " get ydate valid f_valid(f_y2k(@ydate))
  if f_rd () = 27
     exit
  endif
  set softseek on
  seek ybranch+dtos(ydate)
  set softseek off
  if eof ()
     go top
  endif
  f_pick_f (04, 05, "", "컴Date컴훆IN컴컴컴컴컴컴컴횾late컴훀ef컴컴컴컴컴컴Code",  ;
             "dtoc(fdate)+[ ]+fvin+[ ]+fplate+[ ]+fref+[ ]+fcode")
enddo

select rareq
use

