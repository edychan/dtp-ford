*
* audit check for reg. fee calc
*
parameter xrecno
set excl off
set delete on

if pcount() < 1
  yrecno = 1
else
  yrecno = val (xrecno)
endif

* ypath = "f:/dtp/ford/dtp/dbf/"
ypath = "f:/dtp/dbf/"

yfile = ypath + "err"
set excl on
select 0
use &yfile alias err
zap
set excl off

* f_use ("ravin")
yfile = ypath + "ravin"
select 0
use &yfile index &yfile alias ravin
* f_use ("ravalue")
yfile = ypath + "ravalue"
select 0
use &yfile index &yfile alias ravalue
* f_use ("rawtfee")
yfile = ypath + "rawtfee"
select 0
use &yfile alias rawtfee

* f_use ("radtrh")
yfile = ypath + "radtrh"
select 0
use &yfile alias radtrh

go yrecno
do while .not. eof()
   if radtrh->faction = [6]     && renewal
      select ravin
      seek substr(radtrh->fvin,1,8)+substr(radtrh->fvin,10,1)
      if .not.eof()
         xfee = calc_fee (ravin->fmsrp, ravin->fyear, radtrh->fdate)
         if xfee > 0
            if radtrh->freg - xfee > 10
               ? radtrh->fvin+[ ]+radtrh->fplate
               select err
               append blank
               replace fvin with radtrh->fvin, fplate with radtrh->fplate
               replace fdate with radtrh->fdate, fseq with radtrh->fseq
               replace fowner with radtrh->fowner, ftab with radtrh->ftab
               replace freg with radtrh->freg, ftotal with xfee
               replace fref with ravin->fyear+[ ]+ravin->fmake
               replace funit with str(ravin->fmsrp)
            endif
         endif
      endif
   endif
   select radtrh
   skip

enddo

close all
* ------------------------------------------------------------
function calc_fee
* 10.01.03: reg fee increase by $3
parameter xmsrp, xyear, xdate
private y1, y2, y3, yfld, ylv, yfee, ymonth, yxtra

ymonth = 12   && for renewal only
yxtra = 3     && 10.01.03
yfee = 0
if xmsrp > 8000     && 09.17.97
   * calculate level
   y2 = val(substr(dtos(xdate),1,4))    && taken year 2000 into account
   y3 = val(xyear)
   y3 = if(y3>=50, y3+1900, y3+2000)
   y1 = if(y2 - y3 >= 3, 3, y2 - y3)
   ylv = if(y1 <= 0, [0], str(y1,1))
   if xmsrp > 99999
      do case 
      case ylv = [0]
         yfee = f_round (xmsrp * .005, 0)           && 12 month base fee
      case ylv = [1]
         yfee = f_round (xmsrp * .005, 0)
         yfee = f_round (yfee * .9, 0)
      case ylv = [2]
         yfee = f_round (xmsrp * .005, 0)
         yfee = f_round (yfee * .9, 0)
         yfee = f_round (yfee * .9, 0)
      case ylv = [3]
         yfee = f_round (xmsrp * .005, 0)
         yfee = f_round (yfee * .9, 0)
         yfee = f_round (yfee * .9, 0)
         yfee = f_round (yfee * .9, 0)
      otherwise                                     && error: just in case
         yfee = 0
      endcase
      yfee = f_round (yfee / 12 * ymonth, 0)   && prorate to ymonth
      yfee = yfee + 5                            && final fee
      yfee = yfee + yxtra
   else
      xmsrp = int(xmsrp/1000) * 1000
      yfld = "ravalue->f"+strtran(str(ymonth,2)," ","")
      select ravalue
      seek str(xmsrp,5)+ylv
      if eof ()
         yfee = 0
      else
         yfee = &yfld
         yfee = yfee + yxtra
      endif             
   endif                  
   return yfee
else                          && 01.09.04: include wt. fee calc for wt>5000
   if xmsrp <= 5000
      do case
      case xmsrp > 0 .and. xmsrp <=4000
         yfee = 39.00
      case xmsrp >=4001 .and. xmsrp <=4500
         yfee = 44.00
      case xmsrp >=4501 .and. xmsrp <=5000
         yfee = 49.00
      endcase
   else
      select rawtfee
      locate for xmsrp >= fwt1 .and. xmsrp <= fwt2
      if .not. eof ()
         yfee = rawtfee->fx12fee
      endif
   endif
   if yfee = 0      && over 8000 lb
      return (0)
   else
      return (yfee + yxtra)
   endif
endif

return (0)

***************************
function f_round
parameter xnum, xdec

return (round(xnum - .01, xdec))
