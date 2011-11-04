* ------------------------------------------------------
* QEK/CVMS - 812 Final approval processing
*
* ------------------------------------------------------

? "Process: 812 Final approval..."

select 0
set excl on
use transit alias transit
zap
set excl off

* append data
declare nfile[9]
lpat = "812FIN.*"       
ylocal = "c:\spool\"      && data collected on local hard drive
ltxt = ylocal + lpat
nf=adir(ltxt,nfile)
asort(nfile)
nf=if(nf>9,9,nf)
  
if nf = 0  
  ?
  ? "Skip: Final APPROVAL file process"
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
   ysav = ypath + [812]+jdate(date()) + "p.ftp"
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
      ? "Error:  Final Approval file (Missing Header Record)..."
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
      ? "Error:  Final Approval file (Missing Trailer Record)..."
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

do qekfin 

do qekwrtfin      && write final response file

close all
?
? "Status: Process Completed..."
?
inkey (5)

***********************
procedure qekfin
private ypath, yfil, yidx1, yidx2, yidx3, yidx4

* open data file
ypath = gdbfpath
* sos trans table
yfil = ypath + "RADTRH"
yidx1 = ypath + "RADTRH1"
yidx2 = ypath + "RADTRH2"
yidx3 = ypath + "RADTRH3"
yidx4 = ypath + "RADTRH4"
select 0
use &yfil index &yidx1, &yidx2, &yidx3, &yidx4 alias radtrh
*
xtfee = 8          && transfer fee
xbranch = [812]
*
select transit
go top
do while .not. eof ()
   yfld = substr(field,1,5)
   if .not. [HDR] $ yfld .and. .not. [TLR] $ yfld    && skip header/trailer
      xowner = substr(field,1,26)
      xvin = substr(field,27,17)
      xplate = strtran(substr(field,44,7)," ","")
      * xyear = substr(field,51,2)
      * xmake = substr(field,53,7)
      * xstyle = substr(field,60,10)
      * xmsrp =
      xref = substr(field,76,3)+[ ]+substr(field,79,7)+[ ]+substr(field,86,3)
      * xrectyp =
      xdate = ctod(substr(field,93,2)+"/"+substr(field,95,2)+"/20"+substr(field,91,2))
      xclerk = substr(field,97,1)
      xseq = substr(field,100,4)
      * end of parsing
      if .not. empty(xvin)
         ? "Adding -> " + xvin
         select radtrh
         seek [812]+dtos(xdate)+xseq
         if eof ()
            append blank
         else
            rlock ()
         endif
         replace fbranch with xbranch
         replace fdate with xdate
         replace fplate with xplate
         replace fpplate with xplate
         replace fseq with xseq
         * replace ftab with 
         replace fvin with xvin
         replace faction with [7]           && transfer plate only
         replace fclerk with xclerk
         * replace fcontrol with
         replace floc with xbranch          && rdtp5a use floc for branch #
         replace fmonth with 12
         replace fowner with xowner
         replace fref with xref
         * replace freg with xreg
         replace fstate with [MI]
         * replace ftax with
         replace ftfee with xtfee      
         * replace ftitle with
         replace ftotal with xtfee
         replace ftr11 with .t.
      endif
   endif
   select transit
   skip
enddo

************************
* write final approval response file to c:\spool as QEKFIN.TXT
procedure qekwrtfin

xpath = "c:\spool\"
xbranch = [812]
xdate = date()

yfil = xpath + "QEKFIN.TXT"
set device to print
set printer to &yfil
setprc (0,0)
* write header
yln = 0
@yln, 0 say "FIN  QEKAPPROVAL  "+dtos(date())
yln = yln + 1
select transit
go top
do while .not. eof ()
   yfld = substr(field,1,5)
   if .not. [HDR] $ yfld .and. .not. [TLR] $ yfld    && skip header/trailer
      xvin = substr(field,27,17)
      * xplate = strtran(substr(field,44,7)," ","")
      xplate = substr(field,44,7)     && 10.13.05: should always be 7 digit
      @yln, 0 say xvin+xplate+[000APPROVED]
      yln = yln + 1
   endif
   skip
enddo
* write trailer
@yln, 0 say "QEKAPPROVAL  "+dtos(date())+"   "+strtran(str(yln-1,5)," ","0")

set printer to
set console on
set print off
set device to screen

