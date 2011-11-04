*
ypath=""
yfil=ypath+"report17"
select 0
use &yfil alias insdb

yfil=ypath+"transit"
select 0
use &yfil alias transit
go top
do while .not. eof ()

   if substr(field,1,1)=[1]
      skip
      loop
   endif

   if empty(substr(field,9))
      skip 21
      loop
   endif
   * start line 1
   ystate = substr(field,9)
   skip 6    && line 7
   ypolicy = substr(field,8,10)
   yrcode = substr(field,27,3)
   ysdate = substr(field,37,10)
   yedate = substr(field,59,10)
   skip 3    && line 10
   yyear = substr(field,8,2)
   ymake = substr(field,25,12)
   yvin = substr(field,49,17)
   ytag = substr(field,38,7)
   skip 11   && line 21
   yseq = substr(field,59,4)
   * add record
   select insdb
   append blank
   replace fstate with ystate
   replace fpolicy with ypolicy, frcode with yrcode
   replace fsdate with ysdate, fedate with yedate
   replace fyear with yyear, fmake with ymake, fvin with yvin
   replace ftag with ytag, fseq with yseq
   commit
   *
   select transit
   skip
enddo


