* --------------------------------------------------------------------
* QEK/CVMS - 804 TR11 tran processing
*
* --------------------------------------------------------------------
* Revisions.
* 10.05.07: add new customer label processing
* 10.24.07: implement new rules for faction 
*           [4] title/renewal/transfer ==> title>0 and reg>0 and xfer>0
*           [9] renewal/transfer ==> reg>0 and xfer>0
* --------------------------------------------------------------------
* 05.27.08: increase MAKE field from 7 to 10 (all the fields follow move back 3)
* --------------------------------------------------------------------
* 10.01.08: use ravm instead of ravin for vehicle pertinent info
* 11.07.08: allow more than 1 record for same VIN in RADTR
* --------------------------------------------------------------------
private lpat, ltxt
private i, j, nf, y1, y2
private yfil, ytmp, ylocal

? "Process: 804 TR11 transactions ..."

* --------10.05.07---------
yfil = "f:\dtp\dbf\nlabel.dbf"
if .not. file (yfil)
   ytmp = "tmp.dbf"
   create &ytmp
   append blank
   replace field_name with "FLINE1"
   replace field_type with "C"
   replace field_len with 50
   replace field_dec with 0 
   append blank
   replace field_name with "FLINE2"
   replace field_type with "C"
   replace field_len with 50
   replace field_dec with 0 
   append blank
   replace field_name with "FLINE3"
   replace field_type with "C"
   replace field_len with 50
   replace field_dec with 0 
   append blank
   replace field_name with "FLINE4"
   replace field_type with "C"
   replace field_len with 50
   replace field_dec with 0 
   append blank
   replace field_name with "FLINE5"
   replace field_type with "C"
   replace field_len with 50
   replace field_dec with 0 
   create &yfil from &ytmp
   use
   erase &ytmp
endif

yfil = "804tran.dbf"
if .not. file (yfil)
   ytmp = "tmp.dbf"
   create &ytmp
   append blank
   replace field_name with "FIELD"
   replace field_type with "C"
   replace field_len with 250        && current field length=234
   replace field_dec with 0 
   create &yfil from &ytmp
   use
   erase &ytmp
endif

* ----------------------------
select 0
set excl on
use 804tran alias transit
zap
set excl off

* append data
declare nfile[9]
lpat = "804TRAN.*"       
ylocal = "c:\spool\"      && data collected on local hard drive
ltxt = ylocal + lpat
nf=adir(ltxt,nfile)
asort(nfile)
nf=if(nf>9,9,nf)
  
if nf = 0  
  ?
  ? "Skip: 804 TR11 file process"
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
  
for ictr=nf to 1 step -1    && multiple file: 
   yfil = ypath+alltrim(upper(nfile[ictr]))
   ysav = ypath + [804]+jdate(date()) + "a.001"
   j = 2
   do while file (ysav) 
     ysav = ypath + [804]+jdate(date()) + "a.00" + str(j,1)
     j = j + 1
     if j > 9
        exit
     endif
   enddo
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
      ? "Error:  804 transaction file (Missing Header Record)..."
      ?
      ? "Status: Please report to supervisor..."
      ?
      ? "Press any key..."
      ?
      inkey (0)
      close data
      return
   else
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
      ? "Error:  804 transaction file (Missing Trailer Record)..."
      ?
      ? "Status: Please report to supervisor..."
      ?
      ? "Press any key..."
      ?
      inkey (0)
      close data
      return
   endif
next ictr

do p804tr 

close all
?
? "Status: Process 804 TRAN Completed..."
?
inkey (5)

* --------------------------------------------------------------------
procedure p804tr

private ypath, yfil, y1, y2
private ylline1, ylline2, ylline3, ylline4, ylline5   && label lines

* open data file
ypath = "f:\dtp\dbf\"
* sos trans table
yfil = ypath+"ravin"
select 0
use &yfil index &yfil alias ravin
yfil = ypath+"rabody"
select 0
use &yfil index &yfil alias rabody
yfil = ypath+"ravm"
y1 = ypath+"ravm1"
y2 = ypath+"ravm2"
select 0
use &yfil index &y1, &y2 alias ravm
yfil = ypath+"radtr"
y1 = ypath+"radtr1"
y2 = ypath+"radtr2"
select 0
use &yfil index &y2, &y1 alias radtr    && use susbstr(vin,10,8)

*-----10.05.07-----------
yfil = ypath+"nlabel"
select 0 
set excl on
use &yfil alias label
zap
* yfil = "f:\dtp\dbf\nlabel.ntx"
* index on substr(fline1,1,7)+substr(fline1,9,3) to &yfil
set excl off

*------------------------
*
xbranch = [804]
*
select transit
go top
do while .not. eof ()
   yfld = substr(field,1,5)
   if .not. [HDR] $ yfld .and. .not. [TLR] $ yfld    && skip header/trailer
      l_fowner = substr(field,1,26)
      l_fvin = substr(field,27,17)
      l_fplate = strtran(substr(field,44,7)," ","")
      l_fyear = substr(field,51,2)
      * l_fmake = substr(field,53,7)    && 05.27.08: increase to 10
      l_fmake = substr(field,53,10)     && all the fields follows move back 3 (+3)
      l_fstyle = substr(field,63,10)
      l_fstyle = substr(strtran(alltrim(l_fstyle),"/",""),1,2)

      l_fmsrp = substr(field,73,6)
      l_fmsrp = val(alltrim(l_fmsrp))
      l_fmsrp = if(l_fmsrp>999, l_fmsrp, l_fmsrp*1000)
      l_fmsrp = if(l_fmsrp>9999.and.l_fmsrp<100000,l_fmsrp,0)  && 04.20.06


      l_fref = substr(field,79,3)+[ ]+substr(field,82,7)+[ ]+substr(field,89,3)
      l_frectyp = val(substr(field,92,2))     && type = 4,8,9,15
      l_fcontrol = substr(field,103,4)        && pending: bill knight
      l_freg = val(substr(field,107,7))
      l_ftitle = val(substr(field,114,7))
      l_ftfee = val(substr(field,121,7))

      * --------10.05.07------------------
      ylline1 = substr(l_fref,1,11)
      ylline2 = substr(field,128,25)
      ylline3 = substr(field,153,30)
      ylline4 = substr(field,183,30)
      if empty(ylline4)
         ylline4 = alltrim(substr(field,213,14))+",  "+ ;
                   substr(field,227,2)+" "+substr(field,229,9) 
         ylline5 = ""
      else
         ylline5 = alltrim(substr(field,213,14))+",  "+ ;
                   substr(field,227,2)+" "+substr(field,229,9) 
      endif
      * ----------------------------------

      * end of parsing
      ? l_fvin+" "+l_fplate
      * update ravm, ravin, radtr
      if .not. empty(l_fvin) .and. l_frectyp > 0      && skip missing record type
         * define faction
         if l_freg = 0 .and. l_ftfee = 0 .and. l_ftitle > 0
            l_faction = [1]
         elseif l_freg > 0 .and. l_ftfee = 0 .and. l_ftitle > 0 .and. empty(l_fplate)
            l_faction = [2]
         elseif l_freg = 0 .and. l_ftfee > 0 .and. l_ftitle > 0
            l_faction = [3]
         elseif l_freg > 0 .and. l_ftfee > 0 .and. l_ftitle > 0 .and. .not.empty(l_fplate)
            l_faction = [4]      && 10.24.07
         elseif l_freg > 0 .and. l_ftfee = 0 .and. l_ftitle = 0 .and. empty(l_fplate)
            l_faction = [5]
         elseif l_freg > 0 .and. l_ftfee = 0 .and. l_ftitle = 0 .and. .not.empty(l_fplate)
            l_faction = [6]
         elseif l_freg = 0 .and. l_ftfee > 0 .and. l_ftitle = 0 .and. .not.empty(l_fplate)
            l_faction = [7]
         elseif l_freg > 0 .and. l_ftfee > 0 .and. .not.empty(l_fplate)
            l_faction = [9]      && 10.24.07
         else
            l_faction = [ ]
         endif

         select rabody
         seek l_fstyle
         if eof ()
            l_ffee = ""
         else
            l_ffee = rabody->ftype
         endif

         select ravm
         seek substr(l_fvin,10,8)
         if eof ()
            append blank
            replace fvin with l_fvin
            replace fyear with l_fyear, fmake with l_fmake
            replace fstyle with l_fstyle, ffee with l_ffee
            if l_faction $ [1;2;3;4]     && 10.01.08: only record msrp at title time
               replace fmsrp with l_fmsrp
            endif
            commit
            unlock
         endif 

         select ravin
         seek substr(l_fvin,1,8)+substr(l_fvin,10,1)
         if eof ()
            append blank
            replace fvin with substr(l_fvin,1,8)+substr(l_fvin,10,1)
            replace fmake with l_fmake
            replace fmsrp with l_fmsrp, fstyle with l_fstyle
            replace fyear with l_fyear, fdesc with "CVMS"
            replace ffee with l_ffee
            commit 
            unlock
         endif

         * define xswitch
         xswitch = if(l_frectyp=9,.f.,.t.)

         * only 1 vin record in radtr at 1 time
         select radtr
         * --11.07.08: allow more than 1 record for same VIN
         * (per Joy) in case transaction back up

         * seek substr(l_fvin,10,8)
         * if eof()
            seek space(8)          && re-use record
            if eof ()
               append blank
            else
               rlock ()
            endif
            replace faction with l_faction, ftr11 with xswitch
            replace fcontrol with l_fcontrol, fref with l_fref
            * replace ftitle with l_ftitle, freg with l_freg, ftfee with l_ftfee
            replace fvin with l_fvin, fplate with l_fplate
            replace fowner with l_fowner, fdate with date()
            commit 
            unlock 
         * endif

         *-------10.05.07--------------
         if .not.empty(ylline2)      && name
            select label
            append blank
            replace fline1 with ylline1, fline2 with ylline2
            replace fline3 with ylline3, fline4 with ylline4
            replace fline5 with ylline5
            commit
         endif
         *-----------------------------

      endif
   *
   endif
   select transit
   skip
enddo

* -------10.05.07-----------
* LABELS.DBF is used by [DTP Daily Label.doc] to generate labels for Renewal transaction
*    i.e. l_faction = [6]
*    order by garage code + tag #
select label
go top
if .not.eof()
   index on substr(fline1,1,7)+substr(fline1,9,3) to label
   yfil = "labels"
   copy to &yfil
endif

* ------------------------------------------------------------

