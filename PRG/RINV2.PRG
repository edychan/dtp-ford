*
* load plate inventory
*
* changes:
* 01.22.02: add new plate config.
*           for passenger: NAAANN
*           for commercial: ANNNNA
* 12.01.04: add new config for passenger, AAA1234
* 10.30.06: add new config for commercial AA12345
*
private  y1, y2, ytype, ypre, ysuf, ydate, ystate, yret, yplate, ysp

f_clrscn ("DTP/MI - License Plate Inventory Maintenance")
f_box (02, 05, 10, 65, "Load Plate Inventory")
ytype = " "
@ 03, 07 say "Passenger/Commerical..... "  
@ 03, 33 get ytype pict "!" valid f_valid (ytype $ "P;C",  ;
                    "Enter [P] for Passenger or [C] for Commercial")
if f_rd () = 27
   return
endif
ypre = "   "
ysuf = "  "
y1 = 0
y2 = 0
yswitch = " "
ydate = date()
ystate = [MI]
yadded = 0.00
ysp = space (7)
ynum = 0
if ytype = "P"
   ydigit = 3
   @ 04, 07 say "Starting Plate........... "
   @ 05, 07 say "# of Plate............... "
   @ 06, 07 say "Effective Date........... "
   @ 07, 07 say "State.................... "
   @ 08, 07 say "Added Fee................ "
   do while .t.
      @ 04, 33 get ysp pict "!!!!!!!" valid f_valid (chkplate(ysp),"Invalid plate configuration...")
      @ 05, 33 get ynum pict "999" valid f_valid (ynum > 0)
      @ 06, 33 get ydate valid f_valid (.not. empty(ydate).and.f_y2k(@ydate))
      @ 07, 33 get ystate pict "!!" valid f_valid (.not. empty(ystate))
      @ 08, 33 get yadded pict "99.99" valid f_valid (yadded >= 0)
      f_rd ()
      yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit", "CEQ")
      if yret = "Q"
         return
      elseif yret = "E"
        loop
      endif
      if len(alltrim(ysp)) < 5 .or. ynum <= 0
         f_valid (.f., "Please re-enter...")
         loop
      endif
      do case
      * AAANNNN   && 12.01.04
      case len(alltrim(ysp))=7 .and. ;
          isalpha(substr(ysp,1,1)) .and. isalpha(substr(ysp,2,1)) .and. ;
           isalpha(substr(ysp,3,1)) .and. .not.isalpha(substr(ysp,4,1)) .and. ;
           .not.isalpha(substr(ysp,5,1)) .and. .not.isalpha(substr(ysp,6,1)) .and. ;
           .not.isalpha(substr(ysp,7,1))
         yswitch = [1]
         ydigit = 4
         ypre = substr(ysp,1,3)
         y1 = val(substr(ysp,4,4))
         y2 = y1 + ynum - 1
      * AAANN
      case len(alltrim(ysp))=5 .and. ;
          isalpha(substr(ysp,1,1)) .and. isalpha(substr(ysp,2,1)) .and. ;
          isalpha(substr(ysp,3,1)) .and. .not.isalpha(substr(ysp,4,1)) .and. ;
          .not.isalpha(substr(ysp,5,1)) 
         yswitch = [1]
         ydigit = 2
         ypre = substr(ysp,1,3)
         y1 = val(substr(ysp,4,2))
         y2 = y1 + ynum - 1
         if y2 > 99
            f_valid (.f., "# of plate cannot exceed " + str(100-y1,3))
            loop
         endif
      * AAANNN
      case isalpha(substr(ysp,1,1)) .and. isalpha(substr(ysp,2,1)) .and. ;
           isalpha(substr(ysp,3,1)) .and. .not.isalpha(substr(ysp,4,1)) .and. ;
           .not.isalpha(substr(ysp,5,1)) .and. .not.isalpha(substr(ysp,6,1)) 
         yswitch = [1]
         ydigit = 3
         ypre = substr(ysp,1,3)
         y1 = val(substr(ysp,4,3))
         y2 = y1 + ynum - 1
      * NAAANN
      case .not.isalpha(substr(ysp,1,1)) .and. isalpha(substr(ysp,2,1)) .and. ;
           isalpha(substr(ysp,3,1)) .and. isalpha(substr(ysp,4,1)) .and. ;
           .not.isalpha(substr(ysp,5,1)) .and. .not.isalpha(substr(ysp,6,1)) 
         yswitch = [2]
         ydigit = 3
         ypre = substr(ysp,2,3)
         y1 = val(substr(ysp,1,1)+substr(ysp,5,2))
         y2 = y1 + ynum - 1
      otherwise
         f_valid (.f., "Invalid plate configuration for auto load...")
         loop
      endcase
      exit
   enddo
else
   ydigit = 4
   @ 04, 07 say "Starting Plate........... "
   @ 05, 07 say "# of Plate............... "
   @ 06, 07 say "Effective Date........... "
   @ 07, 07 say "State.................... "
   @ 08, 07 say "Added Fee................ "
   do while .t.
      @ 04, 33 get ysp pict "!!!!!!!" valid f_valid (chkplate(ysp),"Invalid plate configuration...")
      @ 05, 33 get ynum pict "999" valid f_valid (ynum > 0)
      @ 06, 33 get ydate valid f_valid (.not. empty(ydate).and.f_y2k(@ydate))
      @ 07, 33 get ystate pict "!!" valid f_valid (.not. empty(ystate))
      @ 08, 33 get yadded pict "99.99" valid f_valid (yadded >= 0)
      f_rd ()
      yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit", "CEQ")
      if yret = "Q"
         return
      elseif yret = "E"
        loop
      endif
      if len(alltrim(ysp)) < 6 .or. ynum <= 0
         f_valid (.f., "Please re-enter...")
         loop
      endif
      do case
      * 10.30.06: AA12345
      case len(alltrim(ysp))=7 .and. ;
          isalpha(substr(ysp,1,1)) .and. isalpha(substr(ysp,2,1)) .and. ;
           .not.isalpha(substr(ysp,3,1)) .and. .not.isalpha(substr(ysp,4,1)) .and. ;
           .not.isalpha(substr(ysp,5,1)) .and. .not.isalpha(substr(ysp,6,1)) .and. ;
           .not.isalpha(substr(ysp,7,1))
         yswitch = [1]
         ydigit = 5
         ysuf = substr(ysp,1,2)
         y1 = val(substr(ysp,3,5))
         y2 = y1 + ynum - 1
      * AANNNN
      case isalpha(substr(ysp,1,1)) .and. isalpha(substr(ysp,2,1)) .and. ;
          .not.isalpha(substr(ysp,3,1)) .and. .not.isalpha(substr(ysp,4,1)) .and. ;
          .not.isalpha(substr(ysp,5,1)) .and. .not.isalpha(substr(ysp,6,1))
         yswitch = [1]
         ysuf = substr(ysp,1,2)
         y1 = val(substr(ysp,3,4))
         y2 = y1 + ynum - 1
      * NNNNAA
      case .not.isalpha(substr(ysp,1,1)) .and. .not.isalpha(substr(ysp,2,1)) .and. ;
          .not.isalpha(substr(ysp,3,1)) .and. .not.isalpha(substr(ysp,4,1)) .and. ;
          isalpha(substr(ysp,5,1)) .and. isalpha(substr(ysp,6,1))
         yswitch = [2]
         ysuf = substr(ysp,5,2)
         y1 = val(substr(ysp,1,4))
         y2 = y1 + ynum - 1
      * ANNNNA
      case isalpha(substr(ysp,1,1)) .and. .not.isalpha(substr(ysp,2,1)) .and. ;
          .not.isalpha(substr(ysp,3,1)) .and. .not.isalpha(substr(ysp,4,1)) .and. ;
          .not.isalpha(substr(ysp,5,1)) .and. isalpha(substr(ysp,6,1))
         yswitch = [3]
         ysuf = substr(ysp,1,1)+substr(ysp,6,1)
         y1 = val(substr(ysp,2,4))
         y2 = y1 + ynum - 1
      otherwise
         f_valid (.f., "Invalid plate configuration for auto load...")
         loop
      endcase
      exit
   enddo
endif

ytype = if(ytype = "P", "01", "03")    && 01 ==> passenger
                                       && 03 ==> commercial

f_box (11, 05, 22, 65, "Processing Transaction")
yrow = 11
f_use ("raplate")
for i = y1 to y2

   if ytype = "01"
      yplate = ypre + strtran(str(i,ydigit)," ","0")    && normal plate
      if yswitch = [2]     && 01.22.2002
         yplate = substr(yplate,4,1)+substr(yplate,1,3)+substr(yplate,5,2)
      endif
   elseif ytype = "03"
      if yswitch = "1"       && CX9999
         yplate = ysuf + strtran(str(i,ydigit)," ","0")
      elseif yswitch = "2"   && 9999CX 
         yplate = strtran(str(i,ydigit)," ","0") + ysuf
      elseif yswitch = "3"   && C9999X                 
         yplate = substr(ysuf,1,1) + strtran(str(i,ydigit)," ","0") + substr(ysuf,2,1)
      endif
   endif

   seek yplate
   if eof ()
      append blank
      replace fplate with yplate, fstate with ystate 
      replace ftype with ytype, fstatus with "A"
      replace fedate with ydate, fadded with yadded
      commit
      unlock
   endif
   if yrow >= 21
      scroll (12, 10, 21, 60, 1)
   else
      yrow = yrow + 1
   endif
   @ yrow, 13 say yplate
   @ yrow, 23 say ystate
   @ yrow, 27 say ytype
   @ yrow, 37 say ydate

next i

select raplate
use

f_valid (.f., "Process completed...")
