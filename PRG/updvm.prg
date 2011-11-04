*
* update RAVM with existing RAVIN
*
parameter xrecno

set excl off
clear

if pcount() < 1
   quit
endif

yrecno = val(xrecno)

* ypath="f:\dtp\ford\dtp\dbf\"  && debug
ypath="f:\dtp\dbf\"

yfil = ypath+"ravin"
select 0
use &yfil index &yfil alias ravin

yfil = ypath+"ravm"
select 0
use &yfil alias ravm
go yrecno
do while .not. eof()
   select ravin
   ykey = substr(ravm->fvin,1,8)+substr(ravm->fvin,10,1)
   seek ykey
   if .not. eof ()
      select ravm
      rlock ()
      replace fyear with ravin->fyear, fmake with ravin->fmake
      replace fstyle with ravin->fstyle, ffee with ravin->ffee
      replace fmsrp with ravin->fmsrp
      commit
      unlock
   endif
   select ravm
   skip
enddo

close all

