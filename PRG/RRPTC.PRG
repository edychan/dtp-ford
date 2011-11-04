*
* print misc form
*
* changes: 08/13/96 reprint form by control #
*          09/23/96 reprint from previous download file
*          04.21.98 add special purpose printing rrptc3
*          10.20.98 select to reprint multiple download files
*
* 12.04.03: add garage / rep code labels indicator
*           print form is set as Word .doc

f_clrscn ("DTP - PRINT COMPUTER FORMS")

f_use ("rafrmtbl")
go top
ycnt = reccount()
declare yfrm [ycnt], ysw [ycnt]
for i = 1 to ycnt
   if file (fprtfil)
      yfrm [i] = ffrm + chr(16) + chr(16) + chr(16)
   else
      yfrm [i] = ffrm + space(3)
   endif
   skip
next 

yptr = 1
yret = f_pick_a (02, 05, "", "", yfrm, ycnt, yptr)

if yret <= 0               
   close data
   return
endif

select rafrmtbl
go yret
yfrmno = upper(alltrim(ffrmno))
yprtfil = fprtfil
yprt = fprinter
ycmd1 = alltrim(fcmd1)
ycmd2 = alltrim(fcmd2)
use

f_box (02, 03, 06, 78, "You have selected to print")
@ 03, 05 say yfrm [yret]

* reprint from previous date
yans = "N"
xfile = space(12)
ydate = date()
do while .t.
   @ 04, 05 say "Reprint from Previous Date ? [Y/N] " get yans pict "!"
   f_rd ()
   if yans = [Y]
      @ 05, 05 say "Enter Date: " get ydate valid ;
        f_valid (f_rrptc(ydate, @xfile), "Cannot Locate Download File...")
      f_rd ()
   endif
   ykeyin = f_confirm ("[C]ontinue  [E]dit  [Q]uit", "CEQ")
   if ykeyin = "Q"
      close data
      return
   elseif ykeyin = "C"
      exit
   else
      loop
   endif
enddo
* prepare transit
yfil = gstnpath + "transit.dbf"
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
yfil = gstnpath + "transit" 
select 0
use &yfil excl alias transit
zap

do rrptc1 with yfrmno        && alignment test

if yans = [Y]
   do rrptc2 with yfrmno, xfile
   select transit
   go top
   if eof ()
      f_valid (.f., "Cannot Locate Form from Download File...")
      close data
      return 
   endif      
else
   if file (yprtfil)
      select transit
      append from &yprtfil sdf
   else
      * check for special purpose printing here.... 04.21.98
      do rrptc3 with yfrmno
      *
      f_valid (.f., "All Printed...")
      close data
      return 
   endif
endif

* user can input starting control #
yc1 = space(4)              && start control #
yc2 = space(4)              && end control #
yrec1 = 0            && start record pointer
yrec2 = 0            && end record pointer
do while .t.
   @ 05, 05 say "Starting / Ending Control # or <Enter> to Begin   "
   @ 05, 55 get yc1 pict "9999" valid f_valid (val(yc1) >=0)
   @ 05, 61 get yc2 pict "9999" valid f_valid (val(yc2) >= val(yc1))
   if f_rd () = 27
      close data
      return
   endif 
   if empty(yc1)                           && start from the top
      select transit
      go top
      yrec1 = recno()
   else
      ys1 = [ ] + alltrim(yc1) + [ ]    && start the search 
      select transit
      locate for ys1 $ field
      if eof ()
         f_valid (.f., "Cannot Locate Starting Control #, Please re-enter...")
         loop
      else
         * rewind to page break
         do while .not. bof () .and. substr(field,1,1) <> chr(12) 
            if substr(field,1,1) = [1]
               skip
               exit
            endif
            skip -1
            loop
         enddo
         yrec1 = recno()
      endif
   endif
   if empty(yc2) .or. val(yc2) = 9999                       && print all
      select transit
      go bottom
      yrec2 = recno()
      exit
   else
      ys1 = [ ] + alltrim(yc2) + [ ]    && start the search 
      select transit
      locate for ys1 $ field
      do while .t.
         if eof ()
            f_valid (.f., "Cannot Locate Ending Control #, Please re-enter...")
            exit
         elseif recno() < yrec1
            continue
            loop
         else
            * advance to next page break
            do while .not. eof () .and. substr(field,1,1) <> chr(12) 
               if substr(field,1,1) = [1]
                  exit
               endif
               skip 
               loop
            enddo
            yrec2 = recno()
            exit
         endif
      enddo
      if yrec2 > yrec1
         exit
      else
         loop
      endif
   endif
enddo

* debug here....
* ? YREC1
* ? YREC2
* INKEY(0)

if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
   close data
   return
endif

set console off
set print on
set printer to &yprt
* set printer to xxx         && debug
if .not. empty (ycmd1)
   ?? &ycmd1
endif
select transit
go yrec1
do while .not. eof () .and. recno() >= yrec1 .and. recno() <= yrec2
   key = inkey ()
   if key = 27
      set console on
      set print off
      if f_confirm ("Do you want to quit ? ", "YN") = "N"
         set console off
         set print on
      else
         exit
      endif
   endif
   if substr(field,1,1) = [1]
      ? chr (12)
   else
      ? trim(field)
   endif
   skip
enddo
if .not. empty(ycmd2)
   ?? &ycmd2
endif
eject
set print off
set printer to
set console on
set device to screen

f_valid (.f., "Process completed...")

close data

*******************************************
procedure rrptc1
parameter xfrmno

do while .t.
   SET PRINT OFF
   SET CONSOLE ON
   ytemp = "N"
   @ 04, 05 say "Please select printer: [LPT1/LPT2/LPT3] "
   @ 04, 55 get yprt pict "!!!!" valid  ;
     f_valid (yprt $ "LPT1;LPT2;LPT3")
   @ 05, 05 say "Do you want to print an alignment test ? [Y/N] "
   @ 05, 55 get ytemp pict "!" valid f_valid (ytemp $ "YN")
   f_rd ()
   if ytemp = "N"
      return
   endif
   SET CONSOLE OFF
   SET PRINT ON
   set printer to &yprt
   if .not. empty (ycmd1)
      ?? &ycmd1
   endif
   do case
   case xfrmno = "TR11D"
      ? 
      ? 
      ? 
      ? 
      ? " XX   XXXXXXXXX    XXXX         XXXXXXX   XX   XXXXXXXXXX    XXXX        XXXXXXX"                                                    
      ? 
      ? 
      ? " XXXXXXXXXXXXXXXXX    XXXXX     XXXXXXX   XXXXXXXXXXXXXXXXX    XXXXXX    XXXXXXX"
      ? 
      ? "                               XXXXXXXX                                 XXXXXXXX"
      ? 
      ? 
      ? "                                XXXXXXX                                  XXXXXXX"
      ? 
      ? "           XXXXXXX     XXX      XXXXXXX             XXXXXXX     XXX      XXXXXXX"
      ? 
      ? 
      ? 
      ? 
      ? "                            XXXX  XX/XX"                                                                                             
      ? 
      eject
   case xfrmno = "765A"
      ?   
      ? 
      ? 
      ? "    XXXXXXXXX       XXXXXXXXXXXXXXX                 XXXXXXXXXXXXXXXXX       XXX     XXXXXXXXXXXXX"
      ? 
      ? 
      ? "    XXXXXXXXXXXXXXXXXXXX              XXXXXXXXXXXX                XX     XXXXX       XXXXX"
      ? 
      ? 
      ? 
      ? "    XXXXXXXXXXXXXXXXX               XXXXXXXXXXXX                                  XXX.XX"
      ? 
      ? 
      ? 
      ? "                                                                                        XX  XX/XX"
      eject
   case xfrmno = "T164"
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? "  XXXXXXX                     XXX                                             XXXXXXX"
      ? 
      ? 
      ? " XX    XXXX    XXXXXXXXXXXXXXXXX        XX     XX    XX             X       XX    XXXX    XXXXXXXXXXXXXXXXX       XX-XX-XX"
      eject
   case xfrmno = "2023"
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? "                                       XXXXXXXX"
      ? 
      ? 
      ? "                             XXXXXXXXXXXXXXXXXX                                          XXXXXXXXXX"
      ? "                                                                                            XX  XXXXX"
      ? 
      ? 
      ? 
      ? 
      ? "                                                                         XXXXX"
      ? 
      ? "                    XX         XXXXXXXXXXX                             XXXXXXXXXXXXXXXXX"
      ? 
      ? 
      ? 
      ? 
      ? 
      ? "                                        XXXXXXXXXXXXXXXXXX              XXXXXXXXXXXXXXXXXXXXXXXX"
      ? "                                        XXXXXXXX                     XX  XXXXX"
      ? 
      ? 
      ? 
      ? "            XXXX XX/XX XXX XXXXXXX"
      ? 
      ? "            TAX DEFERMENT CODE: XXXXXX"
      ? 
      eject
   case xfrmno = "51A"
      ? 
      ? 
      ? "                                                                    XX  XXX"
      ? 
      ? "                           X X   X X   X X"
      ? 
      ? "                           X X X X X X X X X X X X X X X X X"
      ? 
      ? "                           X X X X X X X"
      ? 
      ? "                           X X X X X X X                   X"
      ? 
      ? "                           X X X   X X X   X X X X"
      ? 
      ? "                                XX,XXX.XX"
      ? 
      ? 
      ? 
      ? "                                     X"
      ? 
      ? 
      ? 
      ? 
      ? 
      ? "                                     X"
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? "     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
      ? 
      ? 
      ? 
      eject
   case xfrmno = "37100A"
      ? 
      ? 
      ? 
      ? "                                               XXXXX XX    XX  XXXXXXXXXXXXXX    XXXXXXXXXXXXXXXXX XXX"
      ? 
      ? "                                               XXX         X        XXXXXX              XXXXXXX"
      ? "      XXXXXXXXXXXXXX"
      ? "                                                        XXX"
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? "                 XXXXXXXXXXXXXXXXXX"
      ? 
      ? "                 XXXXXXXXXXXXXXXXXX"
      ? "                                                        XXXXX.XX"
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? 
      ? "       XX  XX/XX"
      eject
   case xfrmno = "37100B"  
      ? "PROCESS DATE: XXXX-XX-XX                                 PROGRAM NAME: XXXXXXXX"
      ? "PROCESS TIME: XX:XX:XX           VEHICLE INVOICE                 PAGE:        1"
      ? 
      ? 
      ? 
      ? "VIN: XXXXXXXXXXXXXXXXX  TAG: XXXXXXX  ASSIGNEE NAME: XXXXXXXXXXXXXX"
      ? 
      ? "A-PLAN TOTAL:     XX,XXX.XX   LEASE FEE:    XXXX.XX   INVOICE DATE: XX/XX/XXXX"
      ? "REP CODE: XXXXXX"
      ? 
      ? "SOLD TO:                                SHIP TO:"
      ? " XXXXXXXXXXXXXXXXXXX                     XXXXXXXXXXXXXXXXXXX"
      ? " XXXXXXXXXXXXXXXXXXX                     XXXXXXXXXXXXXXXXXXXXXXXX"
      ? " XXXXXXXXXXXX                XX XXXXX    XXXXXXXX               XX"
      ? 
      ? "                                                    XXXXX XXX    XXXXXX"
      ? 
      ? 
      eject
   case xfrmno = "AC5011"
      ? "       XXXXXXXXXXXXXX "                                                                                                             
      ?                                                                                                                                    
      ?                                                                                                                                    
      ? "                 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"                                                                                 
      ?                                                                                                                                     
      ?                                                                                                                                     
      ? "     XXXXXXXXXX                XXXXXXXXXX              XXXXXXXXXX     "                                                                                 
      ?                                                                                                                                      
      ?                                                                                                                                      
      ? "     XX               XXXX                  XXXXXXXXXXXXXXXXX"                                                                                
      ?                                                                                                                                      
      ?                                                                                                                                      
      ? "     XXXXXXXXXXXXXXXXXXXXXX           "                                                                                             
      ? "     XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX  "                                                                                             
      ? "     XXXXXXXXXXXXXXXXXXXXXX           "                                                                                             
      ?                                                                                                                                      
      ?                                                                                                                                      
      ?                                                                                                                                      
      ? "         XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX "                                                                             
      ? "         XXXXXXXXXXXXXXXXX                            "                                                                             
      ? "         XXXXXXXXXXXXXXXXXX                           "
      eject
   endcase 
enddo

********************************
function f_rrptc
parameter xdate, xfile
private ip, nf, nfile[5], yfile, ydate

ydate = xdate
f_y2k (@ydate)

yfile = "f:\dtp\ftp\"+jdate(ydate)+"*.ftp"
nf = adir (yfile, nfile)
if nf > 1
   for ip = 1 to nf
      yfile = f_truncate (nfile [ip], 15)
      nfile [ip] = yfile
   next 
   ip = f_pick_a (07, 05, "", "", nfile, nf, 1)
   if ip > 0
      xfile = nfile [ip]
      return .t.
   else
      return .f.
   endif
elseif nf = 1
   xfile = nfile [1]
   return .t.
else
   return .f.
endif

*********************
procedure rrptc2

parameter xfrmno, xfile
private y1, y2, yfile

yfile = "f:\dtp\ftp\"+xfile
select transit
append from &yfile sdf
do case
case xfrmno = "765A"      && 06
   do rrptc2a with [06]
case xfrmno = "T164"      && 07
   do rrptc2a with [07]
case xfrmno = "2023"      && 10
   do rrptc2a with [10]
case xfrmno = "51A"       && 11
   do rrptc2a with [11]
case xfrmno = "37100A"    && 05
   do rrptc2a with [05]
case xfrmno = "37100B"    && 16
   do rrptc2a with [16]
case xfrmno = "AC5011"    && 17
   do rrptc2a with [17]
endcase 

**********************
procedure rrptc2a
parameter xrectype

f_popup ("Please Wait While Processing...")
select transit
locate for "RECORD "+xrectype $ field
if eof ()
   zap
   return
endif
y1 = recno()
y2 = reccount()
skip
do while .not. eof ()
   if "RECORD " $ field .or. "END OF FILE" $ field
      y2 = recno() 
      exit
   endif
   skip
enddo
select transit
delete for recno() <= y1 .or. recno() >= y2
pack
if reccount() < 5
   zap
*elseif xrectype = [07]
*   go top
*   replace field with substr(field,10) for substr(field,1,1) <> chr(12)
endif

f_popback()
return

**********************
procedure rrptc3
parameter xfrmno

do case
   case xfrmno = "AC5011"      && out of state ins.
      do rrptc3a
   otherwise
      return
endcase

***********************
* print out of state ins. form
procedure rrptc3a
private ykey, ictr, ncopy
* get data
ncopy = 0
f_box (08, 03, 10, 78)
@ 09, 05 say "Enter # of copies for special printing or <Esc> to Exit: " ;
         get ncopy pict "9999"
if f_rd() = 27
   return
endif
* print data
set console off
set print on
set printer to &yprt
if .not. empty (ycmd1)
   ?? &ycmd1
endif
ictr = 1
do while ictr <= ncopy
   ykey = inkey ()
   if ykey = 27
      set console on
      set print off
      if f_confirm ("Do you want to quit ? ", "YN") = "N"
         set console off
         set print on
      else
         exit
      endif
   endif
   ? 
   ?                                                                                                                                    
   ?                                                                                                                                    
   ? "     214         Michigan Mutual Insurance Company"                                                                                 
   ?                                                                                                                                     
   ?                                                                                                                                     
   ? "     CPP0052141"
   ?                                                                                                                                      
   ?                                                                                                                                      
   ? "     ALL OWNED AND LEASED VEHICLES"
   ?                                                                                                                                      
   ?                                                                                                                                      
   ? "     J&H Marsh & McLennan, Inc.       "                                                                                             
   ? "     One Woodward Avenue, Suite 1200  "                                                                                             
   ? "     Detroit, MI  48226-3493          "                                                                                             
   ?                                                                                                                                      
   ?                                                                                                                                      
   ?                                                                                                                                      
   ? "           Ford Motor Company and Its U.S. Subsidiaries"                                                                            
   ? "           P.O. BOX 0520                              "                                                                             
   ? "           ALLEN PARK, MI  48101                      "
   eject
   ictr = ictr + 1
enddo
if .not. empty(ycmd2)
   ?? &ycmd2
endif
eject
set print off
set printer to
set console on
set device to screen
return
