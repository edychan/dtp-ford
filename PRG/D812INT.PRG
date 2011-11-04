* ------------------------------------------------------------
* QEK/CVMS - 812 Initial request processing
*
* ------------------------------------------------------------
* 12.11.06: reject all blue plate trans
*           new error code [003] ==> blue plate
*                          [004] ==> invalid plate config 
* ------------------------------------------------------------

? "Process: 812 Initial request..."

xbranch = [812]
xdate = date()       && processing date
*
select 0 
set excl on
use transit alias transit
zap
set excl off

* append data
declare nfile[9]
lpat = "812INT.*"       
ylocal = "c:\spool\"      && data collected on local hard drive
ltxt = ylocal + lpat
nf=adir(ltxt,nfile)
asort(nfile)
nf=if(nf>9,9,nf)
  
if nf = 0  
  ?
  ? "Skip: Initial REQ process "
  ?
  close data
  return
endif

* copy data files to network drive & erase data files from local drive
ypath = "f:\dtp\ftp\"
for i = 1 to nf
   y1 = ylocal + nfile [i]
   y2 = ypath + nfile [i]
   copy file &y1 to &y2
   erase &y1
next i
  
for ictr=nf to 1 step -1    && multiple file: 812INT.001, 812INT.002, etc
   yfil = ypath+alltrim(upper(nfile[ictr]))
   ysav = ypath + [812]+jdate(date()) + "a.ftp"
   ? "Copying Data from ..." + yfil
   if file (yfil)
      yfunit = fopen (yfil)
      ylen = fseek (yfunit, 0, 2)
      fclose (yfunit)
      if ylen > 0
         select transit
         append from &yfil sdf
         *
         if file (ysav)       && just in case
            erase &ysav
         endif
         rename &yfil to &ysav
      else
         erase &yfil
      endif
   endif
   ** 03.15.04: check hdr/tlr record here...
   * yfil = "f:\dtp\dbf\rasys"
   * select 0
   * use &yfil alias rasys
   * ydlyctr = 0
   ** header record should be among the 1st 10 record::=HDR 03-15-2004 G9999V99
   select transit
   go top
   do while .not. eof()
      if [HDR] $ substr(transit->field,1,5) .or. recno() > 10
         exit
      endif
      skip
   enddo
   if .not. [HDR] $ substr(transit->field,1,5)
      ?
      ? "Error:  Initial Request file (Missing Header Record)..."
      ?
      ? "Status: Please report to supervisor..."
      ?
      ? "Press any key..."
      ?
      inkey (0)
      close data
      return
   else
      * check if counter is in sequence
      * yctr = at('G',transit->field)
      * ydlyctr = val(substr(transit->field, yctr+1, 4))
      * if rasys->fdlyctr > 0
      *   if ydlyctr - rasys->fdlyctr > 1
      *      ?
      *      ? "Error:  Seq # Out of Sync in Header Record..."
      *      ?
      *      ? "Status: Please report to supervisor..."
      *      ?
      *      ? "Press any key..."
      *      ?
      *      inkey (0)
      *      close data
      *      return
      *   endif
      * endif
   endif
   ** trailer record should be among the last 10 record
   select transit
   go bottom
   skip -10
   do while .not. eof ()
      if [TLR] $ transit->field 
         exit
      endif
      skip
   enddo
   if .not. [TLR] $ transit->field 
      ?
      ? "Error:  Initial Request file (Missing Trailer Record)..."
      ?
      ? "Status: Please report to supervisor..."
      ?
      ? "Press any key..."
      ?
      inkey (0)
      close data
      return
   endif
   * update system counter
   * select rasys
   * if ydlyctr > fdlyctr
   *   rlock ()
   *   replace fdlyctr with ydlyctr
   *   commit
   *   unlock
   * endif
   * use
next ictr

do qekint     && process initial request

do qekwrtint  && write initial response file

close all
?
? "Status: Process Completed..."
?
inkey (5)

***********************
procedure qekint
private ypath, yfil, yidx, ypdesc

* open data file
ypath = gdbfpath
* initial request table
yfil = ypath + "RAREQ"
select 0
use &yfil index &yfil alias rareq
* vehicle table
yfil = ypath + "RAVM"
yidx = ypath + "RAVM1"     && substr(fvin,10,8)
select 0
use &yfil index &yidx alias ravm
* plate table
yfil = ypath + "RAPLATE"
select 0
use &yfil index &yfil alias raplate
*
select transit
go top
do while .not. eof ()
   yfld = substr(field,1,5)
   if .not. [HDR] $ yfld .and. .not. [TLR] $ yfld    && skip header/trailer
      xplate = strtran(substr(field,44,7)," ","")
      xvin = substr(field,27,17)
      xref = substr(field,76,3)+[ ]+substr(field,79,7)+[ ]+substr(field,86,3)
      xcode = [000]          && approved
      * vehcile title ?
      select ravm
      seek substr(xvin,10,8)
      if eof ()
         xcode = [001]       && vehicle not title
      elseif empty(fdate1)
         xcode = [001]
      endif
      if xcode = [000]
         * valid plate ?
         select raplate
         seek xplate
         if eof()
            xcode = [002]       && plate not valid
         endif
      endif
      * 12.11.06
      if xcode = [000]
         ypdesc = space(3)
         if chkplate (xplate, @ypdesc)
            if ypdesc = [003]
               xcode = [003]    && Invalid Blue plate
            endif
         else
            xcode = [004]       && Invalid plate config
         endif
      endif
      *
      select rareq
      seek xbranch+dtos(xdate)+xplate
      ? "Processing -> " + xplate
      if eof ()
         append blank
      else
         rlock ()
      endif
      replace fbranch with [812]
      replace fdate with date()
      replace fplate with xplate
      replace fvin with xvin
      replace fref with xref
      replace fcode with xcode
      commit
      unlock
   endif
   select transit
   skip
enddo

************************
* write response file to c:\spool as QEKINT.TXT
procedure qekwrtint

xpath = "c:\spool\"
xbranch = [812]
xdate = date()

yfil = xpath + "QEKINT.TXT"
set device to print
set printer to &yfil
setprc (0,0)

* write header
yln = 0
@yln, 0 say "INT  QEKAPPROVAL  "+dtos(xdate)
yln = yln + 1
select rareq
seek xbranch+dtos(xdate)
do while .not. eof () .and. fbranch = xbranch .and. fdate = xdate
   @yln, 0 say fvin+fplate+fcode+jcode(fcode)
   yln = yln + 1
   skip
enddo
* write trailer

@yln, 0 say "QEKAPPROVAL  "+dtos(date())+"   "+strtran(str(yln-1,5)," ","0")

set printer to
set console on
set print off
set device to screen

***********************
function jcode
parameter xcode
private ydesc

do case
case xcode = [000]
   ydesc = [APPROVED]
case xcode = [001]
   ydesc = [VEHICLE NOT TITLE]
case xcode = [002]
   ydesc = [PLATE NOT VALID]
case xcode = [003]
   ydesc = [ERR: BLUE PLATE]
case xcode = [004]
   ydesc = [ERR: PLATE CONFIG]
otherwise
   ydesc = [APPROVED]
endcase
return (ydesc)



