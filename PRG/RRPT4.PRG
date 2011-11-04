*
* end of month process
*
* send data to Ford Data warehouse

f_clrscn ("Process Data to Send to FORD IT")

f_use ("rasys")
xpost = feomdate                 && last posted date
use

f_box (01, 02, 10, 78)
@ 02, 04 say "Branch #......"
@ 02, 50 say "Last Posted on.... " + dtoc(xpost)
@ 03, 04 say "Start Date...."
@ 04, 04 say "End Date......"

xbranch = gloc
xdate1 = xpost+1
xdate2 = xpost+1

f_use ("radtrh")

do while .t.
   set century on
   @ 02, 19 say xbranch pict "!!!" 
   @ 03, 19 get xdate1 valid f_valid(.not.empty(xdate1))
   @ 04, 19 get xdate2 valid f_valid(xdate2>xdate1)
   f_rd ()
   set century off
   if lastkey () = 27
      close data
      return
   endif
   f_y2k (@xdate1)
   f_y2k (@xdate2)
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "E"
      loop
   elseif yret = "Q"
      close data
      return
   else
      exit
   endif
enddo

do rrpt4b with xbranch, xdate1, xdate2

* update post date
f_use ("rasys")
go top
reclock ()
replace feomdate with xdate2
unlock
commit

f_valid (.f., "Process completed...")
close data

*****
procedure rrpt4b
parameters xbranch, xdate1, xdate2

ypath = "c:\spool\"
yfil = ypath+"cvmsdata.txt"
set device to print
set printer to &yfil
setprc (0,0)
yln = 0
go top
do while .not. eof ()
   if fbranch = xbranch .and. fdate >= xdate1 .and. fdate <= xdate2
      @ yln, 00 say fbranch+dtos(fdate)+fvin+fplate+fclerk+faction+ftab+   ;
            str(ftitle,6,2)+str(ftfee,6,2)+str(freg,6,2)+str(ftotal,6,2)+  ;
            fref+fowner
      yln = yln + 1
   endif
   skip
enddo
@ yln, 00 say str(yln,10)
set printer to
set console on
set print off
set device to screen


