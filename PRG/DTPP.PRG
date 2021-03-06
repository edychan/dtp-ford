*
* DTP interface program for FORD 
* process rcv files into dtp data files
*
* current setting:
* record 04 : TR11 for leasee
* record 05 : 37-100 used car Veh. Record
* record 06 : 765A Lease agreement
* record 07 : T164 Proof of Insurance
* record 08 : TR11 for Ind.
* record 09 : TR11 for damaged
* record 10 : 2023 Appointment of Agent
* record 11 : 51A statement of repair damages
* record 15 : TR11 for title only
* record 16 : Vehicle Invoices 
* record 17 : Proof of Insurance for non-michigan vehicles (07.01.97)
*
* changes:
* 1. 08/05/96: TR11D default to FORD MOTOR COMPANY
* 2. 08/13/96: get rid of extra chr(12) & blank lines (dtpp1)
* 3. 09/11/96: add 10th digit (model year) to vin chart
* 4. 07.01.97: add Record 17 
* 5. 06.30.03: changes for ANX connection
* 6. 07.19.03: Record 15 format changes (dtpp2)
* 7. 11.15.03: Process rep/garage address labels 
* 8. 03.08.04: add header/trailer records
* 9. 02.17.05: 7 digit plate config.
*10. 10.21.05: check for excess page breaks (dtpp2)
*11. 02.07.06: For record15, company name should be line 22 (not line 23)
*
* 01.03.07: Julian date: skip [U] & goto [V]
* 05.03.07: stop process SOS transactions from Record04, 08, 09 & 15
* 05.03.07: process c:\spool\804TRAN.*
* =====================================================
parameter xstep

set excl off
set delete on
clear

if file ("f:\dtp\forms\*.txt")  
  ?
  ? "Error:  Please run End of Day Processing First..."
  ?
  ? "Status: Report this problem to Supervisor..."
  ?
  ? "Press any key..."
  ?
  inkey (0)
  quit
endif

? "Please Wait ..."

** if pcount > 0, start process from RRINXX
if pcount() < 1
   yfil = "transit.dbf"
   if .not. file (yfil)
      ytmp = "tmp.dbf"
      create &ytmp
      append blank
      replace field_name with "FIELD"
      replace field_type with "C"
      replace field_len with 132
      replace field_dec with 0 
      create &yfil from &ytmp
      use
      erase &ytmp
   endif
      
   select 0 
   set excl on
   use transit alias transit
   zap
   
   * setup individual print files, RRINXX
   for i = 4 to 11
      y2 = "rrin"+strtran(str(i,2)," ","0")
      select transit
      copy to &y2
      select 0
      use &y2 alias &y2
   next i
   for i = 15 to 17
      y2 = "rrin"+str(i,2)
      select transit
      copy to &y2
      select 0
      use &y2 alias &y2
   next i
   * setup intrim RRTMP to process into RRINXX
   select transit
   y2 = "RRTMP"
   copy to &y2

   set excl off
   
   * append data
   
   declare nfile[9]
   lpat = "report.*"       
   ylocal = "c:\spool\"      && data collected on local hard drive
   ltxt = ylocal + lpat
   nf=adir(ltxt,nfile)
   asort(nfile)
   nf=if(nf>9,9,nf)
   
   if nf = 0  
     ?
     ? "Error:  Missing Data Files..."
     ?
     ? "Status: Please report to Supervisor..."
     ?
     ? "Press any key..."
     ?
     inkey (0)
     close data
     quit
   endif

   * copy data files to network drive & erase data files from local drive
   ypath = "f:\dtp\ftp\"
   for i = 1 to nf
      y1 = ylocal + nfile [i]
      y2 = ypath + nfile [i]
      copy file &y1 to &y2
      erase &y1
   next i
  
   * for ictr=1 to nf         && 06.28.04
   for ictr=nf to 1 step -1    && seq control: report.001=Sat, report.002=Fri,
      yfil = ypath+alltrim(upper(nfile[ictr]))
      ysav = ypath + jdate(date()) + ".ftp"
      j = 1
      do while file (ysav)
         ysav = ypath + jdate(date()) + "-" + str(j,1)+ ".ftp"
         j = j + 1
         if j > 9
            ?
            ? "Error:  Trying to process more than 10 Data Files..."
            ?
            ? "Status: Please report to supervisor..."
            ?
            ? "Press any key..."
            ?
            inkey (0)
            close data
            quit
         endif
      enddo 
      ? "Copying Data from ..." + yfil
      if file (yfil)
         yfunit = fopen (yfil)
         ylen = fseek (yfunit, 0, 2)
         fclose (yfunit)
         if ylen > 0
            select transit
            zap
            append from &yfil sdf
            * 06.30.03: ANX
            replace field with substr(field,2) for substr(field,1,1)=" "
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
      yfil = "f:\dtp\dbf\rasys"
      select 0
      use &yfil alias rasys
      ydlyctr = 0
      ** header record should be among the 1st 10 record::=HDR 03-15-2004 G9999V99
      select transit
      go top
      do while reccount() < 10
         if transit->field = "HDR"
            exit
         endif
         skip
      enddo
      if transit->field <> "HDR"
         ?
         ? "Error:  Incomplete file (Missing Header Record)..."
         ?
         ? "Status: Please report to supervisor..."
         ?
         ? "Press any key..."
         ?
         inkey (0)
         close data
         quit
      else
         * check if counter is in sequence
         yctr = at('G',transit->field)
         ydlyctr = val(substr(transit->field, yctr+1, 4))
         if rasys->fdlyctr > 0
            if ydlyctr - rasys->fdlyctr > 1
               ?
               ? "Error:  Seq # Out of Sync in Header Record..."
               ?
               ? "Status: Please report to supervisor..."
               ?
               ? "Press any key..."
               ?
               inkey (0)
               close data
               quit
            endif
         endif
      endif
      ** trailer record should be among the last 10 record
      select transit
      go bottom
      skip -10
      do while .not. eof ()
         if transit->field = "TLR"
            exit
         endif
         skip
      enddo
      if transit->field <> "TLR"
         ?
         ? "Error:  Incomplete file (Missing Trailer Record)..."
         ?
         ? "Status: Please report to supervisor..."
         ?
         ? "Press any key..."
         ?
         inkey (0)
         close data
         quit
      endif
      * update system counter
      select rasys
      if ydlyctr > fdlyctr
         rlock ()
         replace fdlyctr with ydlyctr
         commit
         unlock
      endif
      use
      ** start parsing into RRINXX
      ** valid doc 4,5,6,7,8,9,10,11,15,16
      for j = 4 to 11
         do dtpp1 with strtran(str(j,2)," ","0")    
      next j
      for j = 15 to 17
         do dtpp1 with str(j,2)
      next j
   next ictr

endif

** output print files from RRINXX to REPORTXX.TXT
for i = 4 to 11
   do dtpp1a with strtran(str(i,2)," ","0")    
next i
for i = 15 to 17
   do dtpp1a with str(i,2)
next i

close data        && close tmp files

** process tr11 from REPORTXX to radtr, ravin, ravm

*xseq = 1         && transaction seq # for sos send file

* === no need to open these tables ===

*set excl on
*use transit alias transit
*set excl off

*ypath = "f:\dtp\dbf\"
*yfil = ypath+"ravin"
*select 0
*use &yfil index &yfil alias ravin

*yfil = ypath+"rabody"
*select 0
*use &yfil index &yfil alias rabody

*yfil = ypath+"ravm"
*y1 = ypath+"ravm1"
*y2 = ypath+"ravm2"
*select 0
*use &yfil index &y1, &y2 alias ravm

*yfil = ypath+"radtr"
*y1 = ypath+"radtr1"
*y2 = ypath+"radtr2"
*select 0
*use &yfil index &y2, &y1 alias radtr

* 05.03.07: stop process Record04, 08, 09, 15

* do dtpp2 with "04", .t.       && tr11 for leasee
* do dtpp2 with "09", .f.       && tr11D for damaged
* do dtpp2 with "08", .t.       && tr11 for Ind.
* do dtpp2 with "15", .t.       && tr11 for title only 

* close data
           
* 05.03.07: new transaction format processing

do d804tr

* 11.15.03: Process rep/garage address labels
ypath = "c:\spool\"
yfil = ypath+"garage.001"
if file (yfil)
   do dtpp_g with yfil
endif
ypath = "c:\spool\"
yfil = ypath+"vehrep.001"
if file (yfil)
   do dtpp_r with yfil
endif

?
? "Press any key..."
?
inkey (0)

close data

*****************
procedure dtpp_g
parameter xtxtfil
private ypath, yfil, ykey, yfld, ychg, yln

* Garage file layout
* GARG-CD-GARAGE                    XXX            1      1       3  3
* GARG-NA-GARAGE                    X(30)          2      4      33 30 
* GARG-DS-GAR-ADDRESS               X(50)          3     34      83 50 
* GARG-DS-GAR-CITYSTZIP             X(35)          4     84     118 35 
* GARG-NO-GAR-PHONE                 X(14)          5    119     132 14 
* GARG-NA-GAR-REP                   X(20)          6    133     152 20 
* GARG-NA-GAR-COMPONENT             X(50)          7    153     202 50 
* GARG-TS-LAST-UPDATE               X(26)          8    203     228 26 
* GARG-CD-GAR-REP-PROFSID           X(8)           9    229     236  8 

? "processing garage labels..."

yfil = "f:\dtp\dbf\glabel.dbf"
yntx = "f:\dtp\dbf\glabel.ntx"
if .not. file (yfil)
   ytmp = "tmp.dbf"
   create &ytmp
   append blank
   replace field_name with "FKEY"
   replace field_type with "C"
   replace field_len with 3
   replace field_dec with 0 
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
   replace field_name with "FUPDATE"
   replace field_type with "C"
   replace field_len with 1
   replace field_dec with 0 
   create &yfil from &ytmp
   use
   erase &ytmp
endif


yfil = "gtrans.dbf"
if .not. file (yfil)
   ytmp = "tmp.dbf"
   create &ytmp
   append blank
   replace field_name with "FIELD"
   replace field_type with "C"
   replace field_len with 240
   replace field_dec with 0 
   create &yfil from &ytmp
   use
   erase &ytmp
endif
      
select 0 
set excl on
use gtrans alias gtrans
zap
append from &xtxtfil sdf
set excl off
erase &xtxtfil
* open garage label table
yfil = "f:\dtp\dbf\glabel.dbf"
yntx = "f:\dtp\dbf\glabel.ntx"
if .not. file (yntx)
   select 0
   use &yfil
   index on fkey to &yntx
   use &yfil index &yntx alias labels
else
   select 0
   use &yfil index &yntx alias labels
endif

select gtrans
go top
ychg = .f.
do while .not. eof ()
   yfld = gtrans->field
   ykey = substr (yfld,1,3)
   select labels
   seek ykey
   if eof ()
      append blank
   else
      rlock ()
   endif
   if fline1 <> substr(yfld,4,30) .or.  ;
      fline2 <> substr(yfld,34,50) .or. ;
      fline3 <> substr(yfld,84,35)
      ychg = .t.
      replace fupdate with "*"
   else
      replace fupdate with " "
   endif
   replace fkey with ykey
   replace fline1 with substr(gtrans->field,4,30)
   replace fline2 with substr(gtrans->field,34,50)
   replace fline3 with substr(gtrans->field,84,35)
   commit
   unlock
   select gtrans
   skip
enddo

* output to GARAGE.TXT
if ychg 
   yfil = "f:\dtp\forms\GARAGE.TXT"
   ? "Creating " + yfil + "..."
   SET CONSOLE OFF
   SET PRINT ON
   set device to print
   set printer to &yfil
   select labels
   go top
   *** column 1 reserved for page control ***
   yln = 0
   do while .not. eof ()
      if .not.empty(fupdate)
         ? [ ]+fkey+[ ]+trim(fline1)
         ? [ ]+trim(fline2)
         ? [ ]+trim(fline3)
         yln = yln + 3
         if yln > 50        && page control
            ? [1]
            yln = 0
         endif
      endif
      skip
   enddo
   set printer to
   set console on
   set print off
   set device to screen
endif

close data

***********************
procedure dtpp_r
parameter xtxtfil

private ypath, yfil, ykey, yfld, ychg, yln

* Rep. code file layout
* VREP-CD-REP                      XXX            1      1       3        3 
* VREP-NA-REP-FI                   X              2      4       4        1
* VREP-NA-REP-MI                   X              3      5       5        1 
* VREP-NA-REP-LAST                 X(15)          4      6      20       15 
* VREP-DS-REP-ADDRESS              X(50)          5     21      70       50 
* VREP-DS-REP-CITY                 X(20)          6     71      90       20 
* VREP-CD-REP-STATE                XX             7     91      92        2 
* VREP-CD-REP-ZIP                  X(9)           8     93     101        9 
* VREP-NO-REP-PHONE                X(14)          9    102     115       14 
* VREP-CD-ACCTG-LOC                X(4)          10    116     119        4 
* VREP-CD-OPER-LOC                 X(4)          11    120     123        4 
* VREP-NA-STAFF                    X(60)         12    124     183       60 
* VREP-CD-TAX-TYPE                 X             13    184     184        1 
* VREP-TS-LAST-UPDATE              X(26)         14    185     210       26 
* VREP-NO-DEPARTMENT               X(6)          15    211     216        6 
* VREP-CD-PROCESS-GROUP            X             16    217     217        1 
* VREP-CD-SALES-USE-TAX            XXX           17    218     220        3 
* VREP-CD-REP-PROFSID              X(8)          18    221     228        8 
* VREP-CD-REP-TYPE                 X             19    229     229        1 
* VREP-CD-COUNTRY-CODE             X             20    230     230        1 
* VREP-CD-ACT-INACT                X             21    231     231        1 

? "processing Vehicle Rep labels..."

yfil = "f:\dtp\dbf\rlabel.dbf"
yntx = "f:\dtp\dbf\rlabel.ntx"
if .not. file (yfil)
   ytmp = "tmp.dbf"
   create &ytmp
   append blank
   replace field_name with "FKEY"
   replace field_type with "C"
   replace field_len with 3
   replace field_dec with 0 
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
   replace field_name with "FUPDATE"
   replace field_type with "C"
   replace field_len with 1
   replace field_dec with 0 
   create &yfil from &ytmp
   use
   erase &ytmp
endif


yfil = "gtrans.dbf"
if .not. file (yfil)
   ytmp = "tmp.dbf"
   create &ytmp
   append blank
   replace field_name with "FIELD"
   replace field_type with "C"
   replace field_len with 240
   replace field_dec with 0 
   create &yfil from &ytmp
   use
   erase &ytmp
endif
      
select 0 
set excl on
use gtrans alias gtrans
zap
append from &xtxtfil sdf
set excl off
erase &xtxtfil
* open garage label table
yfil = "f:\dtp\dbf\rlabel.dbf"
yntx = "f:\dtp\dbf\rlabel.ntx"
if .not. file (yntx)
   select 0
   use &yfil
   index on fkey to &yntx
   use &yfil index &yntx alias labels
else
   select 0
   use &yfil index &yntx alias labels
endif

select gtrans
go top
ychg = .f.
do while .not. eof ()
   yfld = gtrans->field
   ykey = substr (yfld,1,3)
   select labels
   seek ykey
   if eof ()
      append blank
   else
      rlock ()
   endif
   if fline1 <> alltrim(substr(yfld,6,15)) .or. ;
      fline2 <> substr(yfld,21,50) .or. ;
      fline3 <> substr(yfld,71,20) .or. ;
      fline4 <> substr(yfld,91,2)+[  ]+substr(yfld,93,9)
      ychg = .t.
      replace fupdate with "*"
   else
      replace fupdate with " "
   endif
   replace fkey with ykey
   replace fline1 with alltrim(substr(yfld,6,15))+[ ]+substr(yfld,4,1)+[ ]+substr(yfld,5,1)
   replace fline2 with substr(yfld,21,50)
   replace fline3 with substr(yfld,71,20)
   replace fline4 with substr(yfld,91,2)+[  ]+substr(yfld,93,9)
   commit
   unlock
   select gtrans
   skip
enddo

* output to VEHREP.TXT
if ychg 
   yfil = "f:\dtp\forms\VEHREP.TXT"
   ? "Creating " + yfil + "..."
   SET CONSOLE OFF
   SET PRINT ON
   set device to print
   set printer to &yfil
   select labels
   go top
   yln = 0
   do while .not. eof ()
      *** column 1 reserved for page control ***
      if .not.empty(fupdate)
         ? [ ]+fkey+[ ]+trim(fline1)
         ? [ ]+trim(fline2)
         ? [ ]+trim(fline3)+[ ]+trim(fline4)
         yln = yln + 3
         if yln > 50        && page control
            ? [1]
            yln = 0
         endif
      endif
      skip
   enddo
   set printer to
   set console on
   set print off
   set device to screen
endif
close data

***********************
* 05.03.07: stop process Record 04, 08, 09, 15
procedure dtpp1
parameter xnum

if xnum $ "04;08;09;15"   && 05.03.07
   return
endif

* add data to RRINXX.DBF from TRANSIT.DBF (data recv from ford)
select transit
go top
ytxt = "RECORD " + xnum
locate for ytxt $ field

if eof ()
   return
endif

* take extra step to process into RRTMP first
* this step is necessary to get rid of extra blank lines or chr(12)
select 0
use rrtmp excl alias rrtmp
zap
append blank
replace field with chr (12)
select transit
skip           
do while .not. eof ()
   if "RECORD " $ field .or. "END OF FILE" $ field
      exit
   endif
   select rrtmp
   append blank
   replace field with transit->field
   select transit
   skip
enddo

* get rid of extra chr(12) & blank lines (08/13/96)
select rrtmp
locate for substr(field,1,1) = chr(12)
go bottom
skip -4
continue
do while .not. eof ()
   delete
   skip
enddo
pack
y1 = reccount()
if y1 > 5
   if xnum = [17]    && 01.09.04: out of state ins req'd special processing
     ? "Adding to rrin17..."
     do dtpp17
   else
      select rrtmp
      use
      yfil = "rrin"+xnum
      select &yfil
      ? "Adding to "+yfil+"..."
      append from rrtmp
   endif
else
   select rrtmp
   use
endif
return
***********************
* 01.09.04 special processing for out of state ins forms
procedure dtpp17
private ystatename
private ystate, ypolicy, yrcode, ysdate, yedate
private yyear, ymake, yvin, ytag, yseq
*
ystatename=[DELAWARE;FLORIDA;GEORGIA;HAWAII;KENTUCKY;LOUISIANA;OKLAHOMA;TEXAS;]

yfil="f:\dtp\dbf\report17"     && main table for RR8 reports
select 0
use &yfil excl alias report17
zap
select rrtmp
go top
do while .not. eof ()
   if substr(field,1,1)=[1] .or. substr(field,1,1)=chr(12)
      skip
      loop
   endif
   * start line 1
   ystate = upper(alltrim(substr(field,8)))
   if ystate $ ystatename .or. ;
      ystate = [NEW JERSEY] .or. ;
      ystate = [WEST VIRGINIA]
      skip 6    && line 7
      ypolicy = substr(field,7,10)
      yrcode = substr(field,26,3)
      ysdate = substr(field,36,10)
      yedate = substr(field,58,10)
      skip 3    && line 10
      yyear = substr(field,7,2)
      ymake = substr(field,24,12)
      yvin = substr(field,48,17)
      ytag = substr(field,37,7)
      skip 11   && line 21
      yseq = substr(field,58,4)
      * add record
      select report17
      append blank
      replace fstate with ystate
      replace fpolicy with ypolicy, frcode with yrcode
      replace fsdate with ysdate, fedate with yedate
      replace fyear with yyear, fmake with ymake, fvin with yvin
      replace ftag with ytag, fseq with yseq
      commit
   else
      * add to rrin17 
      select rrin17
      append blank
      replace field with [1]        && insert page break
      for i = 1 to 21
          select rrin17
          append blank
          replace field with rrtmp->field
          select rrtmp
          skip
      next i
   endif
   *
   select rrtmp
   skip
enddo
select rrtmp
use

***********************
* 05.03.07: stop process Record04, 08, 09, 15
procedure dtpp1a
parameter xnum

if xnum $ "04;08;09;15"
   return
endif

* create REPORTXX.TXT from RRINXX
yfil = "rrin"+xnum
select &yfil
go top
if reccount () <= 5
   return
endif

y2 = "report" + xnum + ".txt"
yprt = "f:\dtp\forms\" + y2
? "Creating " + yprt + "..."
set device to print
set printer to &yprt
setprc (0,0)       && important: suppress page break chr(12)
yln = 0
* special case for report07.txt, which is proof of ins. (T164)
* disable: 11.28.01
if xnum = "XX"
   do while .not. eof ()
      if substr(field,1,1) = chr(12)
         @yln, 00 say chr(12)
      else
         @yln, 00 say substr(field,10)    && truncate 10 spaces
      endif
      yln = yln + 1
      skip
   enddo
else
   do while .not. eof ()
      if substr(field,1,1) = [1]
         @yln, 00 say chr(12)
      else
         @yln, 00 say field
      endif
      yln = yln + 1
      skip
   enddo
endif
set printer to
set console on
set print off
set device to screen

***********************
procedure dtpp2
parameter xnum, xswitch

* process tr11 transactions from REPORT04, 08, 09 & 15
select transit
zap
y1 = "report" + xnum + ".txt"
yfil = "f:\dtp\forms\" + y1
if file (yfil)
   append from &yfil sdf
endif
if reccount() <= 5
   return 
endif
go top
locate for substr(field,1,1) = chr (12)  && page break
do while .not. eof ()
   * 10.21.05: check for excess page breaks
   skip
   do while .not. eof ()
      if substr(field,1,1) = chr (12)
         skip
      else
         exit
      endif
   enddo
   l_fowner = ""
   skip 2
   * line 4
   l_fplate = strtran(substr(field,24,7)," ","")      && 02.17.05
   if empty(l_fplate)
      l_fplate = strtran(substr(field,64,7)," ","")   && 02.17.05
   endif
   skip 2
   * line 6
   l_fyear = substr(field,2,2)
   if empty(l_fyear) 
      l_fyear = substr(field,43,2)  
   endif
   l_fmake = substr(field,7,7)
   if empty(l_fmake)
      l_fmake = substr(field,48,7)
   endif
   l_fstyle = substr(field,21,10)
   if empty(l_fstyle)
      l_fstyle = substr(field,63,10)
   endif
   l_fstyle = substr(strtran(alltrim(l_fstyle),"/",""),1,2)
   l_freg = val(alltrim(substr(field,33,7)))
   if l_freg <= 0
      l_freg = val(alltrim(substr(field,74,7)))
   endif
   skip 3
   * line 9
   l_fvin = substr(field,2,17)
   if empty(l_fvin)
      l_fvin = substr(field,43,17)
   endif   
   l_fmsrp = alltrim(substr(field,21,7))
   if empty (l_fmsrp)
      l_fmsrp = alltrim(substr(field,63,7))
   endif
   l_ftitle = val(alltrim(substr(field,33,7)))
   if l_ftitle <= 0
      l_ftitle = val(alltrim(substr(field,74,7)))
   endif
   skip 5
   l_ftfee =val(alltrim(substr(field,33,7)))
   if l_ftfee > 0
      l_ftfee =val(alltrim(substr(field,74,7)))
   endif
   if xswitch               && Record 04, 08, 15
      if xnum = [15]        && 07.19.03
         skip 2             && line 16
      else
         skip 3             && line 17
      endif

      y1 = substr(field,6,3)               && garage code
      if empty(y1)
         y1 = substr(field,47,3)
      endif
      y2 = substr(field,12,7)               && garage code
      if empty(y2)
         y2 = substr(field,53,7)
      endif
      y3 = substr(field,24,3)              && rep code
      if empty(y3)
         y3 = substr(field,65,3)
      endif
      l_fref = y1 + [ ] + y2 + [ ] + y3
      * skip 4       && 02.07.06
      if xnum = [15]       && 02.07.06
         skip 5
      else
         skip 4
      endif
      *
   else
      skip 2                && Record 09
      * line 16 (TR11D)
      y1 = substr(field,6,3)               && garage code
      if empty(y1)
         y1 = substr(field,47,3)
      endif
      y2 = substr(field,12,7)              && garage code
      if empty(y2)
         y2 = substr(field,53,7)
      endif
      y3 = substr(field,24,3)              && rep code
      if empty(y3)
         y3 = substr(field,65,3)
      endif
      l_fref = y1 + [ ] + y2 + [ ] + y3
      l_fowner = "FORD MOTOR COMPANY"      && default for TR11D
      skip 5
   endif
   * line 21
   l_fcontrol = substr(field,29,4)         && control # 9999
   l_fctr2 = alltrim(substr(field,35,5))   && date MM/DD
   if xswitch
      if xnum = [15]     && 07.19.03
         skip 1          && line 22
      else
         skip 2          && line 23
      endif
      * 
      l_fowner = substr(field,2,25)           && company name
      if empty(l_fowner)
         l_fowner = substr(field,43,25)
      endif
      * 02.15.06: leave as blank, user must pick the owner in RDTP1.prg
      * l_fowner = if(empty(l_fowner),"FORD MOTOR COMPANY",l_fowner)
   endif
   if .not. empty (l_fvin)
      ? "Adding -----> " + l_fvin + " " + l_fplate + " " + ;
                           l_fcontrol + " " + l_fctr2 + " " + l_fref
   endif

   * update ravm, ravin, radtr
   if .not. empty(l_fvin)
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
         commit 
         unlock
      endif 

      select ravin
      seek substr(l_fvin,1,8)+substr(l_fvin,10,1)
      if eof ()
         append blank
         replace fvin with substr(l_fvin,1,8)+substr(l_fvin,10,1)
         replace fmake with l_fmake
         l_fmsrp = val(alltrim(l_fmsrp))
         l_fmsrp = if(l_fmsrp>999, l_fmsrp, l_fmsrp*1000)
         replace fmsrp with l_fmsrp, fstyle with l_fstyle
         replace fyear with l_fyear, fdesc with "CVMS"
         replace ffee with l_ffee
         commit 
         unlock
      endif

      * define faction
      if l_freg = 0 .and. l_ftfee = 0 .and. l_ftitle > 0
         l_faction = [1]
      elseif l_freg > 0 .and. l_ftfee = 0 .and. l_ftitle > 0 .and. empty(l_fplate)
         l_faction = [2]
      elseif l_freg = 0 .and. l_ftfee > 0 .and. l_ftitle > 0
         l_faction = [3]
      elseif l_freg > 0 .and. l_ftfee = 0 .and. l_ftitle > 0 .and. .not.empty(l_fplate)
         l_faction = [4]
      elseif l_freg > 0 .and. l_ftfee = 0 .and. l_ftitle = 0 .and. empty(l_fplate)
         l_faction = [5]
      elseif l_freg > 0 .and. l_ftfee = 0 .and. l_ftitle = 0 .and. .not.empty(l_fplate)
         l_faction = [6]
      elseif l_freg = 0 .and. l_ftfee > 0 .and. l_ftitle = 0
         l_faction = [7]
      elseif l_freg > 0 .and. .not.empty(l_fplate)
         l_faction = [9]
      else
         l_faction = [ ]
      endif
      * only 1 vin record in radtr at 1 time
      select radtr
      seek substr(l_fvin,10,8)
      if eof()
         seek space(8)          && re-use record
         if eof ()
            append blank
         else
            rlock ()
         endif
         * 09/26/96: assign seq # to be in syn. with control #
         *           assume control # is in order in download file
         * 07.10.98: disable seq # assignment
         replace faction with l_faction, ftr11 with xswitch
         replace fcontrol with l_fcontrol, fref with l_fref
         replace ftitle with l_ftitle, freg with l_freg, ftfee with l_ftfee
         replace fvin with l_fvin, fplate with l_fplate
         replace fowner with l_fowner, fdate with date()
         * replace fseq with strtran(str(xseq,4), " ", "0")
         commit 
         unlock 
         * xseq = xseq + 1
      endif      
   endif
   select transit
   continue
enddo

**********************************************************************
function jdate

parameter xdate
private ydate, y1, y2, y3, yday, yyr

ydate = dtoc (xdate)

y1 = substr(ydate,4,2)
y2 = substr(ydate,1,2)
y3 = substr(ydate,7,2)

yday = ctod (y2+"/01/"+y3) - ctod ("01/01/"+y3) + val(y1)

do case
   case y3 = "96"
     yyr = "G"
   case y3 = "97"
     yyr = "H"
   case y3 = "98"
     yyr = "J"
   case y3 = "99"
     yyr = "K"
   case y3 = "00"
     yyr = "L"
   case y3 = "01"
     yyr = "M"
   case y3 = "02"
     yyr = "N"
   case y3 = "03"
     yyr = "P"
   case y3 = "04"
     yyr = "R"
   case y3 = "05"
     yyr = "S"
   case y3 = "06"
     yyr = "T"
*   case y3 = "07"
*     yyr = "U"
   case y3 = "07"
     yyr = "V"
   case y3 = "08"
     yyr = "W"
   case y3 = "09"
     yyr = "X"
   case y3 = "10"
     yyr = "Y"
   case y3 = "11"
     yyr = "Z"
endcase
return (yyr+strtran(str(yday,3)," ","0"))



