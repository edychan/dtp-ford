*
* print misc form
*
f_clrscn ("DTP - PRINT MISC. FORM")

f_use (rafrmtbl)
go top
ycnt = reccount()
declare yfrm [ycnt]
for i = 1 to ycnt
   yfrm [i] = ffrm
   skip
next 

yptr = 1
yret = f_pick_a (02, 05, "", "", yfrm, ycnt, yptr)
if yret <= 0
   close data
   return
endif

f_box (02, 03, 06, 78, "You have selected to print")
@ 03, 05 say yfrm [yret]
ykeyin = f_confirm ("[C]ontinue  [Q]uit", "CQ")
if ykeyin = "Q"
   close data
   return
endif

select rafrmtbl
go yret
yfrmno = upper(alltrim(ffrmno))
yfil = fprtfil
yprt = fprinter
ycmd1 = alltrim(fcmd1)
ycmd2 = alltrim(fcmd2)
use
select 0
use c:\dtp\dbf\trans excl alias trans
zap
if file (yfil)
   append from &yfil sdf
else
   close data
   return 
endif

do rrpt4a with yfrmno        && alignment test

if f_popup ("Press <Enter> to Begin or <Esc> to Stop Printing...", .t.) = 27
   close data
   return
endif

set console off
set print on
set printer to &yprt
if .not. empty (ycmd1)
   ?? &ycmd1
endif
go top
do while .not. eof ()
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
   ? trim(field)
   skip
enddo
if .not. empty(ycmd2)
   ?? &ycmd2
endif
set print off
set printer to
set console on
set device to screen
f_valid (.f., "Process completed...")

close data

*******************************************
procedure rrpt4a
parameter xfrmno

do while .t.
   SET PRINT OFF
   SET CONSOLE ON
   ytemp = "N"
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
      ? "           XXXXXXX                     XXX                                             XXXXXXX"
      ? 
      ? 
      ? "          XX    XXXX    XXXXXXXXXXXXXXXXX        XX     XX    XX             X       XX    XXXX    XXXXXXXXXXXXXXXXX       XX-XX-XX"
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
   endcase 
enddo
