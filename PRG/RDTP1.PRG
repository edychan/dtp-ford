* ------------------------------------------------------------------------
* add dtp transaction
* ------------------------------------------------------------------------
* 09/11/96: add 10th digit (model year) to vin chart
* 09/26/96: seq # should be assigned by dtpp.exe from download file
*           so that seq # will be in syn with control #
* 10/14/96: correct calculation for commercial plate
* 10/23/96: assign tab # automatically
* 06.10.97: fix calc.fee for 4 year or older with msrp > 99999
* 08.07.97: new user interface to add to vin chart
* 08.07.97: add plate to raaudit
* 09.17.97: change calc. for company pickup/van to base on msrp not weight
*           (for pickup/van weigh < 5000 lb)
* 10.14.97: multi user control
* 05.10.98: check if vehicle has been plated
* 09.21.98: y2k
* 10.27.98: y2k check on plate expiration date
* 08.18.99: print control for radtrp (set ftr11=.f.)
* 08.18.99: let user pick title address
* ------------------------------------------------------------------------
* 01.14.02: mem file (200?.mem) to validate SOS holidays
* 01.17.02: check plate configuration (see rdtp1b)
* 12.02.02: change to allow model year 2 + current year
* ------------------------------------------------------------------------
* 10.01.03: title fee and reg. fee increase by $3 (see rdtp1c)
* ------------------------------------------------------------------------
* 06.10.04: do not prorate for plate renewal (keep month = 12)
* 12.01.04: new passenger plate config. AAA9999
* ------------------------------------------------------------------------
* 03.20.06: only allow to process 1 day ahead
* 08.09.06: add new title entity FORD MOTOR CREDIT CSV LLC
* 12.01.06: 
*   1. stop issue new blue [003] and bridge [001] plate type
*   2. existing bridge [001] can be renewed and transfered
*   3. existing blue [003] cannot be renewed or transfered
*   4. new process to transfer/renew blue plate
*   5. issue new white [009] + new tag for blue [003] transactions
*   6. issue new distinctive [010] instead of [001]
* ------------------------------------------------------------------------
* 10.01.07: commercial plate fees are never prorated per SOS
* 12.07.07: bug/ previous plate shoud equal current plate during normal
*           transfer [3;7] 
* ------------------------------------------------------------------------
* 10.01.08: store Yr/Make/MSRP ... per vehicle instead of VIN
*           VIN chart use for range validation 
* ------------------------------------------------------------------------
* 04.16.09: allow proration calculation for passenger plate renewal
* ------------------------------------------------------------------------
private xrecno, xmsrp, xadded, xfee, xyr

restore from (gmempath + "radtr") additive
f_clrscn ("DTP/MI - Add D.T.P. Transaction")
f_box (01, 02, 04, 78)
@ 02, 04 say "Office #......"
@ 02, 41 say "Clerk ID......"
@ 03, 04 say "Date.........."
* @ 04, 04 say "Tab #........."
l_floc = gloc
l_fdate = date()
l_fclerk = gclerk
l_ftr11 = .t.           && assume tr11
* 12.02.02
xmodyr = 3              && 2 + current year 
* check last post date
f_use ("rasys")
xdate = fpostdate
use

* 200?.mem must be present
yfil = gmempath + substr(dtos(date()),1,4) + ".mem"
if file (yfil)
   restore from (yfil) additive
else
   xholiday = ""
endif
*if .not. file (yfil)
*   f_valid (.f., "Missing SOS Holiday Table...")
*   return
*endif
*restore from (yfil) additive

xplate = space(7)       && current plate
xyear = space(4)        && current exp. year e.g. 1997
xrecno = 0
xmsrp = 0
xadded = 0
xfee = [  ]
xyr = 0
xpdesc = space(3)       && 12.01.06: plate desc code; [001;003;009;010]
xrenewal = ctod("")     && 12.11.06: save previous blue plate renewal
set key 28 to rdtph1
set key -1 to rdtpf2         && 12.01.06: add new F2 function

do while .t.
   @ 02, 19 get l_floc pict "!!!" valid ;
     f_valid (f_verify("raloc",1,l_floc))
   @ 02, 56 say l_fclerk

   @ 03, 19 get l_fdate valid rdtp1x ()    && 03.20.06
   * -- for testing only
   * @ 03, 19 get l_fdate valid f_y2k(@l_fdate)
   * --

   if f_rd () = 27
      return
   endif
   yret = f_confirm ("[C]ontinue  [E]dit  [Q]uit ","CEQ")
   if yret = "C"
      exit
   elseif yret = "Q"
      return
   endif
enddo

* assign reg. / title fee
private yaddr1, yaddr2, yaddr3
f_use ("raloc")
seek l_floc
if eof ()
   f_valid (.f., "Please Setup Branch Office First...")
   close data
   return
else
   xtitle = ftitle
   xreg = freg
   l_fbranch = fbranch
   * 08.18.99:
   yaddr1 = fcaddr
   yaddr2 = faddr1
   yaddr3 = faddr2
endif
use

f_use ("raaudit")      && audit file
f_use ("ravm")
f_use ("ravin")
f_use ("raplate")
f_use ("ravalue")
f_use ("radtrh")
f_use ("radtrp")
f_use ("ractr")
f_use ("ratab")
f_use ("rawtfee")

f_use ("radtr")
* multi-user control by fclerk...
set filter to .not. empty(fvin)
go top
f_box (01, 02, 22, 78)
@ 02, 04 say "VIN #             Type  Plate     Tab #   Title  Reg Fee Transfer  Total"
@ 03, 04 say "컴컴컴컴컴컴컴컴� 컴컴  컴컴컴컴� 컴컴컴� 컴컴컴 컴컴컴� 컴컴컴컴  컴컴컴"           
yrow = 4
do while .t.
   @ yrow, 04 get l_fvin pict "!!!!!!!!!!!!!!!!!" valid rdtp1a ()
   if f_rd () = 27
      exit 
   endif

   l_ftotal = l_ftitle + l_freg + l_ftfee
   @ yrow, 24 say l_faction pict "!" 
   @ yrow, 29 say l_fplate pict "!!!!!!!"     && 12.01.04
   @ yrow, 38 say l_ftab pict "9999999" 
   @ yrow, 46 say l_ftitle pict "999.99"
   @ yrow, 54 say l_freg pict "999.99"
   @ yrow, 62 say l_ftfee pict "999.99" 
   @ yrow, 71 say l_ftotal pict "999.99" 

   yedit = .f.
   xchk = .t.
   do while .t.
      * @ yrow+1, 04 get l_funit pict "!!!!!!!!!!"
      @ yrow, 24 get l_faction pict "!" valid rdtp1e ()
      @ yrow, 29 get l_fplate pict "!!!!!!!" valid rdtp1b ()   && 12.01.04
      * @ yrow+1, 29 get l_fpplate pict "!!!!!!" 
      @ yrow, 38 get l_ftab pict "9999999" valid rdtp1d ()
      if yedit
         @ yrow, 46 get l_ftitle pict "999.99" valid l_ftitle >= 0
         @ yrow, 54 get l_freg pict "999.99"   valid l_freg >= 0
         @ yrow, 62 get l_ftfee pict "999.99"  valid l_ftfee >= 0
      endif
      f_rd () 
      l_ftotal = l_ftitle + l_freg + l_ftfee
      * @ yrow+1, 04 say l_funit pict "!!!!!!!!!!"
      @ yrow, 24 say l_faction pict "!" 
      @ yrow, 29 say l_fplate pict "!!!!!!!"     && 12.01.04
      * @ yrow+1, 29 say l_fpplate pict "!!!!!!" 
      @ yrow, 38 say l_ftab pict "9999999" 
      @ yrow, 46 say l_ftitle pict "999.99"
      @ yrow, 54 say l_freg pict "999.99"
      @ yrow, 62 say l_ftfee pict "999.99" 
      @ yrow, 71 say l_ftotal pict "999.99" 
      if xchk .and. l_ftotal > 0
         xkey = f_confirm ("[C]onfirm  [E]dit  [D]elete  [I]gnore Changes", "CEDI")
      else
         xkey = f_confirm ("[E]dit  [D]elete  [I]gnore Changes", "CEDI")
      endif
      do case
      case xkey = "C"
         * misc check
         if l_ftotal <> l_ftitle + l_freg + l_ftfee 
            f_valid (.f., "Out of Balance....")
            loop
         elseif l_faction $ [1;2;3;4] .and. l_ftitle <=0
            f_valid (.f., "Missing Title Fee...")
            loop
         elseif l_faction $ [2;4;5;6;9] .and. l_freg <=0
            f_valid (.f., "Missing Registration Fee...")
            loop
         elseif l_faction $ [2;4;5;6;9] .and. empty(l_fplate)
            f_valid (.f., "Missing Plate...")
            loop
         elseif l_faction $ [2;4;5;6;9] .and. empty(l_ftab)
            f_valid (.f., "Missing Tab...")
            loop
         elseif l_faction $ [3;7] .and. l_ftfee <=0
            f_valid (.f., "Missing Transfer Fee...")
            loop
         else
            * 12.11.06: check for duplicates in raaudit (just in case)
            select raaudit
            if .not.empty(l_fplate)
               seek l_fplate
               if .not. eof ()
                  f_valid (.f., "Duplicate transaction found for Plate "+l_fplate)
                  loop
               endif
            elseif .not.empty(l_fpplate)
               seek l_fpplate
               if .not. eof ()
                  f_valid (.f., "Duplicate transaction found for Plate "+l_fpplate)
                  loop
               endif
            endif
            *
         endif
         * update company name
         if empty(l_fowner)
            y1 = " "
            y2 = " "
            yscn = f_box (10, 5, 19, 60)
            * 08.18.99
            @ 11, 7 say "Company...      [1] FORD MOTOR COMPANY"
            @ 12, 7 say "                [2] FORD MOTOR CREDIT COMPANY"
            @ 13, 7 say "                [3] FORD MOTOR CREDIT CSV LLC"     && 08.09.06
            @ 14, 7 say "Address...      [1] "+f_truncate(yaddr1,30)
            @ 15, 7 say "                [2] "+f_truncate(yaddr2,30)
            @ 16, 7 say "                [3] "+f_truncate(yaddr3,30)
            @ 18, 7 say "Ref. #.... "
            do while .t.
               @ 11, 18 get y1 pict "9" valid f_valid(y1 $ "1;2;3")
               @ 14, 18 get y2 pict "9" valid f_valid(y2 $ "1;2;3")
               @ 18, 18 get l_fref pict "!!! !!!!!!! !!!"
               f_rd ()
               if f_confirm ("Are you sure ?  [Y/N]","YN") = "Y"
                  if empty(y1) .or. empty(y2)
                     loop
                  else
                     exit
                  endif
               endif
            enddo
            f_restbox (yscn)
            if y1 = [1]
               l_fowner = "FORD MOTOR COMPANY"
            elseif y1 = [2]
               l_fowner = "FORD MOTOR CREDIT COMPANY"
            elseif y1 = [3]
               l_fowner = "FORD MOTOR CREDIT CSV LLC"     && 08.09.06
            endif
            * 08.18.99
            if y2 = [3]
               l_fref = substr(l_fref,1,7)+"T"+substr(l_fref,9)
            elseif y2 = [2]
               l_ftr11 = .f.
            else
               l_ftr11 = .t.
            endif
         endif

         select ractr
         locate for fbranch = l_fbranch
         if eof ()
            f_valid (.f., "Error: System counter out of sequence...")
            close data
            return
         else
            reclock ()
            l_fseq = strtran(str(fseq1,4), " ", "0")     
            replace fseq1 with fseq1 + 1
            commit
            unlock
         endif

         select raaudit
         append blank
         replace fvin with substr(l_fvin,10,8)
         commit
         unlock 
         * 08.07.97 audit plate
         if .not. empty(l_fplate)
            select raaudit
            append blank
            replace fvin with l_fplate
            commit
            unlock 
            * 12.11.06: stop from issuing the plate again + update renewal date for transfer 
            select raplate
            seek l_fplate
            if .not. eof ()
                reclock ()
                replace fstatus with "U"    
                if empty(frenewal)
                   replace frenewal with xrenewal
                endif
                commit
                unlock
            endif
         endif

         * 12.11.06: deactive blue plate
         if .not.empty(l_fpplate) .and. l_fpplate<>l_fplate
            select raplate
            seek l_fpplate
            if .not. eof ()
                reclock ()
                replace fstatus with "I"    
                commit
                unlock
            endif
         endif

         select radtrh
         append blank
         f_replace ()
         * 08.18.99: print control
         l_ftr11 = .f.
         if xrecno > 0
            select radtr
            go xrecno
            select radtrp
            append blank
            f_replace ()
            select radtr 
            f_clrrec ()
         else 
            select radtrp
            append blank
            f_replace ()
            select radtr
            * just in case
            * 07.05.07: seek l_fbranch+dtos(l_fdate)+l_fclerk+substr(l_fvin,10,8)+l_faction
            seek l_fbranch+dtos(l_fdate)+l_fclerk
            if .not. eof ()
               f_clrrec ()
            endif
         endif
         xrecno = 0 
         xplate = space(7)
         exit
      case xkey = "D"
         select raaudit
         seek substr(l_fvin,10,8)
         if .not. eof ()
             reclock ()
             delete
             commit
             unlock
         endif
         * 08.07.97 audit plate
         if .not. empty(l_fplate)
            select raaudit
            seek l_fplate
            if .not. eof ()
                reclock ()
                delete
                commit
                unlock
            endif
         endif
         * 
         if .not. empty(l_ftab)
            select ratab
            seek l_ftab
            if .not. eof ()
               reclock ()
               replace fstatus with "A"
               commit
               unlock 
            endif
         endif  
         if .not. empty(l_fplate) .and. l_faction $ [2;5]
            select raplate
            seek l_fplate
            if .not. eof ()
                reclock ()
                replace fstatus with "A"
                commit
                unlock
            endif
         endif
         select radtr
         if xrecno > 0
            go xrecno 
            f_clrrec ()
         else 
            *07.05.07:seek l_fbranch+dtos(l_fdate)+l_fclerk+substr(l_fvin,10,8)+l_faction
            seek l_fbranch+dtos(l_fdate)+l_fclerk
            if .not. eof ()
               f_clrrec ()
            endif
         endif
         xrecno = 0 
         xplate = space(7)
         exit
      case xkey = "E"
         if .not. empty(l_ftab)
            select ratab
            seek l_ftab
            if .not. eof ()
               reclock ()
               replace fstatus with "A"
               commit
               unlock 
            endif
         endif  
         yedit = .t.
         loop
      case xkey = "I"
         if xrecno > 0
            select radtr
            go xrecno 
            reclock ()
            replace fclerk with " "
            commit
            unlock 
         endif
         if .not. empty(l_ftab)
            select ratab
            seek l_ftab
            if .not. eof ()
               reclock ()
               replace fstatus with "A"
               commit
               unlock 
            endif
         endif  

         if .not. empty(l_fplate) .and. l_faction $ [2;5]
            select raplate
            seek l_fplate
            if .not. eof ()
                reclock ()
                replace fstatus with "A"
                commit
                unlock
            endif
         endif

         xrecno = 0
         xplate = space(7)
         exit
      endcase
   enddo
   if xkey <> "I"
      if yrow < 20
         yrow = yrow + 1
      else
         scroll (4, 04, 20, 77, 1)
      endif
   else
      @ yrow, 04 clear to yrow, 77
   endif
   l_fvin = space(17)
   l_fcontrol = space(4)
   l_fref = space(15)
   l_ftr11 = .t.
   l_fowner = space(25)
   l_funit = space(10)
   l_faction = space(1)
   l_fplate = space(7)
   l_fpplate = space(7)
   l_freg = 0
   l_ftab = space(7)
   l_ftitle = 0 
   l_ftfee = 0
   l_ftotal = 0
   l_fseq = space(4)       && 09/26/96
   xpdesc = space(3)       && 12.01.06: plate desc code; [001;003;009;010]
   xrenewal = ctod("")     && 12.11.06: save previous plate renewal
enddo

set key 28 to
set key -1 to
set filter to
close database

***************************************************************
* 03.07.06: only allow to process 1 day ahead
function rdtp1x

f_y2k(@l_fdate)
do case
case l_fdate<=xdate
   f_valid (.f.,"Must be later than "+dtoc(xdate)) 
   return .f.
case dow(l_fdate)=1.or.dow(l_fdate)=7
   f_valid (.f.,"Must be Monday thru Friday only...")
   return .f.
case dtos(l_fdate) $ xholiday
   f_valid (.f.,"Date entered is a state holiday...")
   return .f.
case date()>xdate .and. l_fdate>date()
   f_valid (.f.,"Please run End of Day first...")
   return .f.
case l_fdate<>date()
   if dow(date())=6
      if date()+3<>l_fdate
         f_valid (.f.,"Valid date is "+dtoc(date()+3))
         return .f.
      endif
   else
      if date()+1<>l_fdate
         f_valid (.f.,"Valid date is "+dtoc(date()+1))
         return .f.
      endif
   endif
endcase

return .t.

***************************************************************
function rdtp1a
private yscn, ycolor, yptr
private yyvin, yydesc, yyfee, yymake, yymsrp, yystyle, yyyear
private yfail


if empty (l_fvin)
   f_valid (.f., "Press <F1> to display ready list...")
   return .f.
endif

if len(alltrim(l_fvin)) = 8    
   select ravm
   seek l_fvin
   if eof ()
      f_valid (.f., "Please enter complete VIN...")
      return .f.
   else
      l_fvin = ravm->fvin
   endif
else
   if f_goodvin (l_fvin)
      select ravm
      seek substr(l_fvin, 10, 8)
      if eof ()
         append blank
         replace fvin with l_fvin
         commit
         unlock
      endif
   else
      return .f.
   endif
endif

* check for duplicate transaction
select raaudit
seek substr(l_fvin,10,8)
if .not. eof ()
   f_valid (.f., "Duplicate Transaction, Please check today's work...")
   return .f.
endif

* -- 10.01.08: validate vm data using RAVIN
select ravin
seek substr(l_fvin,1,8)+substr(l_fvin,10,1) 
if eof ()
   f_valid (.f., "Please setup "+ ;
            substr(l_fvin,1,8)+substr(l_fvin,10,1)+" in VIN Chart first...") 
   return .f.
endif
*
select ravm
seek substr(l_fvin,10,8)
if eof () .or. ;
   abs (ravm->fmsrp - ravin->fmsrp) > 1000 .or. ;
   ravm->fyear <> ravin->fyear .or. ;
   ravm->fmake <> ravin->fmake .or. ;
   ravm->fstyle <> ravin->fstyle .or. ;
   ravm->ffee <> ravin->ffee
   *
   yfail = .f.
   set cursor on
   
   ycolor = setcolor (gsubcolor)
   yscn = f_box (10, 25, 15, 60)
   * @ 10, 27 say "VIN ......... "
   @ 11, 27 say "Year ........ "
   @ 12, 27 say "Make ........ "
   @ 13, 27 say "Body Style .. "
   @ 14, 27 say "MSRP ........ "
   
   yyvin = substr(l_fvin,1,8)+substr(l_fvin,10,1)
   
   if eof ()
      yyyear = space(2)
      yymake = space(12)
      yystyle = space(2)
      yymsrp = 0
      yyfee = space(2)
   else
      yyyear = ravm->fyear
      yymake = ravm->fmake
      yystyle = ravm->fstyle
      yymsrp = ravm->fmsrp
      yyfee = ravm->ffee
   endif
   
   do while .t.         && --- start edit loop

   * @ 10, 41 say l_fvin
   setcolor (gsubget)
   @ 11, 41 say yyyear pict "99"
   @ 12, 41 say yymake pict "XXXXXXXXXXXX"
   @ 13, 41 say yystyle pict "XX"
   @ 14, 41 say yymsrp pict "999999"
   
   yptr = 1
   do while .t.
      do case
      case yptr = 1
         f_getfld (@yyyear, 11, 41, "W/N", 0, "99", .t.)
      case yptr = 2
         f_getfld (@yymake, 12, 41, "W/N", 0, replicate ("!", 12), .t.)
      case yptr = 3
         f_getfld (@yystyle, 13, 41, "W/N", 0, "!!", .t.)
      case yptr = 4
         f_getnum (@yymsrp, 14, 41, "", "999999", .t.)
      endcase
      ykey = lastkey ()
      if (ykey = 24 .or. ykey = 13) .and. yptr < 5
         yptr = yptr + 1
      elseif ykey = 5 .and. yptr > 1
         yptr = yptr - 1
      elseif ykey = 27 .or. ykey = 13 .or. ykey = 3 .or. ykey = 18
         exit
      endif
   enddo
   
   * define fee code
   if f_verify ("rabody", 1, yystyle)
      yyfee = rabody->ftype
   else
      f_valid (.f., "Invalid Body Style ...")     && 09.30.98
      loop
   endif

   * -- update VIN chart & perform range check on MSRP
   select ravin
   seek yyvin
   if eof ()
      append blank
      replace fvin with yyvin, fyear with yyyear, fmake with yymake
      replace fstyle with yystyle, fmsrp with yymsrp
      replace ffee with yyfee
      commit
      unlock
   else
      if abs(yymsrp - ravin->fmsrp) > 1000
         f_valid (.f., "Warning: MSRP is shown as "+str(ravin->fmsrp,6,0)+" in VIN Chart" )
         yfail = .t.
      elseif yyyear <> ravin->fyear
         f_valid (.f., "Warning: Model Year is shown as "+ravin->fyear+" in VIN Chart" )
         yfail = .t.
      elseif yymake <> trim(ravin->fmake)
         f_valid (.f., "Warning: Make is shown as "+ravin->fmake+" in VIN Chart" )
         yfail = .t.
      elseif yystyle <> trim(ravin->fstyle)
         f_valid (.f., "Warning: Body Style is shown as "+ravin->fstyle+" in VIN Chart" )
         yfail = .t.
      endif
   endif

   if yfail
      ykey = f_confirm ("[C]ontinue  [R]etype  [I]gnore", "RCI") 
      if ykey = "R"
         yfail = .f.
         loop
      elseif ykey = "I"          && 10.16.08
         f_restbox (yscn)
         setcolor (ycolor)
         return .f.
      endif
   endif

   * -- update ravm
   select ravm
   if eof ()
      append blank
      replace fvin with l_fvin
   endif
   reclock ()
   replace fyear with yyyear, fmake with yymake
   replace fstyle with yystyle, fmsrp with yymsrp
   replace ffee with yyfee
   commit
   unlock

   f_restbox (yscn)
   setcolor (ycolor)
   exit

   enddo    && ----- end edit loop

endif

select ravm
seek substr(l_fvin,10,8)
if eof ()
   f_valid (.f., "Missing Vehicle Record...")
   return .f.
endif

* get msrp, fee code, body style, year, make etc
if empty (ravm->fstyle)
   f_valid (.f., "Missing Fee Code in Vehicle Record...")
   return .f.
elseif ravm->fmsrp <= 5000      
   f_valid (.f., "Please check MSRP in Vehicle Record...")
   return .f.
elseif empty (ravm->fyear) 
   f_valid (.f., "Missing Vehicle Year in Vehicle Record...")
   return .f.
elseif empty (ravm->fmake)
   f_valid (.f., "Missing Vehicle Make in Vehicle Record...")
   return .f.
endif

* model year cannot be ahead 2 year, calculation for year past 2000
xyr = val(ravm->fyear)
xyr = if(xyr>=50, xyr+1900, xyr+2000)
y2 = xyr - val(substr(dtos(l_fdate),1,4))
if y2 >= xmodyr       && 12.02.02 
   f_valid (.f., "Invalid Model Year "+ravm->fyear + "...")
   return (.f.)
endif

xfee = ravm->ffee

* if ravm->ffee = "01"      && passager
* 09.17.97
if ravm->fmsrp >  8000     && cut off for wt fee calc. 
   if ravm->fmsrp > 99999  && fee catagory
      xmsrp = ravm->fmsrp 
   else
      xmsrp = int(ravm->fmsrp/1000) * 1000
   endif
else
   xmsrp = ravm->fmsrp    && commercial weighs > 5000
endif

select radtr 
set order to 2
seek substr(l_fvin,10,8)
set order to 1
if .not. eof ()
   if .not. empty (radtr->fclerk) .and. radtr->fclerk <> l_fclerk     && 10.14.97
      f_valid (.f., "Record in use by Clerk Id: "+radtr->fclerk)
      return .f.
   endif
   reclock ()
   replace fclerk with l_fclerk
   commit 
   unlock
   xrecno = recno ()
   l_fcontrol = fcontrol     && control #
   l_fref = fref             && ref # (garage code)       
   l_ftr11 = ftr11           && tr11
   l_fowner = fowner         && company
   l_faction = faction
   l_fplate = fplate
   l_ftab = ftab
   l_freg = freg
   l_ftitle = ftitle
   l_ftfee = ftfee
   l_fseq = fseq             && 09/26/96
endif

@ yrow, 04 say l_fvin pict "!!!!!!!!!!!!!!!!!" 

return .t.

*************************************************
function rdtp1b

private y1, y2, ymo, ymess
private yplate, ypdesc, yscn, ycolor     && 12.01.06

if lastkey () = 5
   return .t.
endif

* 08.07.97 check daily audit file to make sure plate is not entered again
ypdesc = space(3)         && 12.11.06
if .not. empty (l_fplate)
   select raaudit
   seek l_fplate
   if .not. eof ()
      f_valid (.f., "Plate "+l_fplate+" is in use...")
      xchk = .f.
      return (.f.)
   endif
   * 12.11.06
   select raplate
   seek l_fplate
   if .not. eof ()
      if raplate->fstatus = "I"
         f_valid (.f., "Plate "+l_fplate+" is inactive...")
         xchk = .f.
         return (.f.)
      endif
   else
      f_valid (.f., "Plate "+l_fplate+" not on file...")
      xchk = .f.
      return (.f.)
   endif
   * 01.17.02 check configuration of plate entered
   if .not. chkplate (l_fplate, @ypdesc)      && 12.11.06: get plate desc code
      f_valid (.f., "Invalid Plate Configuration...")
      xchk = .f.
      return (.f.)
   endif
   * xpdesc = if(empty(xpdesc),ypdesc,xpdesc)    && DO NOT USE
   if empty(xpdesc)
      xpdesc = ypdesc
   endif
endif

* 12.01.06: stop issue bridge [001] and blue [003] for original plate
do case
case l_faction $ [2;5]
   if ypdesc = [001]
      f_valid (.f., "Cannot issue New Bridge Plate...")
      xchk = .f.
      return (.f.)
   elseif ypdesc = [003]
      f_valid (.f., "Cannot issue New Blue Plate...")
      xchk = .f.
      return (.f.)
   endif
* 12.01.06: handle transfer/renew blue plate here...
case l_faction $ [3;4;6;7;9] .and. xpdesc = [003]
   * l_fpplate = if (empty(l_fpplate),l_fplate,l_fpplate)    && DO NOT USE
   if empty(l_fpplate)       && retain 
      l_fpplate = l_fplate
   endif
   * issue new white plate to replace old blue plate
   ycolor = setcolor (gsubcolor)
   yscn = f_box (yrow-1, 38, yrow + 2, 60)
   @ yrow, 39 say "Blue Plate : "+l_fpplate
   @ yrow + 1, 39 say "White Plate: "
   yplate = l_fplate
   f_getfld (@yplate, yrow+1, 52, "W/N", 0, "!!!!!!!", .t.)
   f_restbox (yscn)
   setcolor (ycolor)
   l_fplate = yplate
   @ yrow, 29 say l_fplate pict "!!!!!!!"
endcase

xadded = 0

do case
case l_faction = [1] 
   if .not. empty (l_fplate)
      f_valid (.f., "Plate # must be blank for this transaction...")
      xchk = .f.
      return (.f.)
   endif
case l_faction $ [2;5]        && original plate
   if empty (l_fplate)
      f_valid (.f., "Plate # CANNOT be blank for this transaction...")
      xchk = .f.
      return (.f.)
   endif
   select raplate
   seek l_fplate
   if eof ()
      f_valid (.f.,"Invalid Plate #...")
      xchk = .f.
      return (.f.)
   elseif raplate->fstatus <> "A" .and. xplate <> l_fplate
      f_valid (.f.,"Plate # is not available...")
      xchk = .f.
      return (.f.) 
   elseif raplate->fstatus = "I" 
      f_valid (.f.,"Plate # is inactive...")
      xchk = .f.
      return (.f.)
   elseif raplate->ftype <> xfee
      ymess = if(xfee="01"," Passenger "," Commercial ")
      f_valid (.f., "Please enter a"+ymess+"Plate...")
      xchk = .f.
      return (.f.)
   endif
   xplate = l_fplate
   select raplate
   reclock ()
   replace fstatus with "U"
   commit
   unlock
   xadded = raplate->fadded
case l_faction $ [3;4;6;7;9]
   if empty (l_fplate)
      f_valid (.f., "Plate # CANNOT be blank for this transaction...")
      xchk = .f.
      return (.f.)
   endif
   select raplate
   seek l_fplate
   if eof ()
      f_valid (.f., "Plate # Not On File...")
      * 12.01.06: must enter plate in raplate table...
      * if f_confirm ("[R]etype  [C]ontinue ","CR") <> "C"
      *   xchk = .f.
      *   return (.f.)
      *endif
      xchk = .f.
      return (.f.)
   elseif raplate->fstatus <> "A" .and. xpdesc = [003]      && 12.11.06: blue plate exchange
      f_valid (.f.,"Plate "+l_fplate+" is in use")
      xchk = .f.
      return (.f.)
   elseif raplate->fstatus = "I"
      f_valid (.f.,"Plate "+l_fplate+" is inactive...")
      xchk = .f.
      return (.f.)
   elseif .not. empty(raplate->ftype) .and. raplate->ftype <> xfee 
      ymess = if(xfee="01"," Passenger "," Commercial ")
      f_valid (.f., "Please enter a"+ymess+"Plate...")
      xchk = .f.
      return (.f.)
   else   && 12.01.06
      ypdesc = space(3)
      if .not. chkplate (l_fplate, @ypdesc)
         f_valid (.f., "Invalid Plate Configuration...")
         xchk = .f.
         return (.f.)
      elseif ypdesc = [003]
         f_valid (.f., "Cannot enter a blue plate...")
         xchk = .f.
         return (.f.)
      endif
   endif
   if l_faction $ [3;7]      && 12.01.06
      if xpdesc = [003]      && check previous plate
         yplate = l_fpplate
      else
         yplate = l_fplate
      endif
      select raplate
      seek yplate
      if eof ()
         f_valid (.f., "Plate "+yplate+" not on file...")
         xchk = .f.
         return (.f.)
      elseif raplate->frenewal <= l_fdate
         f_valid (.f., "Plate "+yplate+"expires "+dtoc(raplate->frenewal))
         xchk = .f.
         return (.f.)
      elseif raplate->fstatus = "I" 
         f_valid (.f.,"Plate "+yplate+" is inactive...")
         xchk = .f.
         return (.f.)
      endif
      xyear = substr(dtos(frenewal),1,4)
      xrenewal = raplate->frenewal          && 12.11.06: get previous blue plate renewal
   endif
endcase

* calculate month poration

declare xmo1 [12], xmo3 [12]
* for passager fee code = [01] always expires 04/01
xmo1 [1] = 16
xmo1 [2] = 15
xmo1 [3] = 14
xmo1 [4] = 12
xmo1 [5] = 12
xmo1 [6] = 11
xmo1 [7] = 10
xmo1 [8] = 9
xmo1 [9] = 8
xmo1 [10] = 7 
xmo1 [11] = 6
xmo1 [12] = 17

* for commercial fee code = [03]  always expires 02/28
xmo3 [1] = 14
xmo3 [2] = 12
xmo3 [3] = 12
xmo3 [4] = 11
xmo3 [5] = 10
xmo3 [6] = 9
xmo3 [7] = 8
xmo3 [8] = 7
xmo3 [9] = 6
xmo3 [10] = 17
xmo3 [11] = 16
xmo3 [12] = 15

if xfee = [01]
   y1 = val(substr(dtoc(l_fdate),1,2))
   ymo = xmo1 [y1]
   l_fmonth = xmo1 [y1]

   * -- 06.16.04: as of 10/2003 no more poration for renewal
   * if .not. l_faction $ [2;5]
   *    l_fmonth = 12
   * endif
   * --

   * -- 04.16.09: proration for renewal ok
   do case
   case l_faction $ [1;3;7]   
      l_fmonth = 12
   case l_faction $ [4;6;9]   
      if l_fmonth > 12
         l_fmonth = 12
      endif
   endcase
   * --

else
   y1 = val(substr(dtoc(l_fdate),1,2))
   ymo = xmo3 [y1]

   *--------------------------------------------------------------
   * 10.01.07: commercial plate fees are never prorated per SOS
   * l_fmonth = xmo3 [y1]
   * 06.16.04: as of 10/2003 no more poration for renewal
   * if .not. l_faction $ [2;5]     
   *    l_fmonth = 12
   * endif

   * DTP allows 12 month commercial plate ONLY
   * except 12 mo plate at half fee for September ONLY
   if y1 = 9 .and. l_faction $ [2;5]
      l_fmonth = 6
   else
      l_fmonth = 12
   endif
   *----------------------------------------------------------------

endif

* check if plate need to buy new tab
if l_faction $ [2;4;5;6;9]
   xyear = substr(dtos(l_fdate + ymo * 30),1,4)
   if xpdesc = [003]        && 12.11.06
      yplate = l_fpplate
   else
      yplate = l_fplate
   endif
   select raplate
   seek yplate
   if .not. eof ()

      *------------10.01.07-----------------------
      if xfee = [01]
         * lead time is 121 for passenger plate renewal
         if raplate->frenewal - l_fdate > 121    
           f_valid (.f., "Plate "+yplate+" expires "+dtoc(raplate->frenewal))
           xchk = .f.
           return (.f.)
         endif   
      else
         * lead time is 150 for commercial plate renewal
         if raplate->frenewal - l_fdate > 150
           f_valid (.f., "Plate "+yplate+" expires "+dtoc(raplate->frenewal))
           xchk = .f.
           return (.f.)
         endif   
      endif
      *------------------------------------------

   endif

endif

* calc. title/reg/transfer fee
* calculate fee
* passenger renewal expires on 04/01
* commercial renewal expires on 02/28
do case
   case l_faction = "1"            && original title
      f_compute (@l_ftitle, xtitle)
      f_compute (@l_freg,0.00)
      f_compute (@l_ftfee,0.00)
   case l_faction = "2"            && original title/ plate
      f_compute (@l_freg, rdtp1c(xmsrp))
      f_compute (@l_ftitle, xtitle)
      f_compute (@l_ftfee, 0.00)
   case l_faction = "3"            && original title/ transfer plate
      f_compute (@l_ftitle, xtitle)
      f_compute (@l_ftfee, xreg)
      f_compute (@l_freg, 0.00)
   case l_faction = "4"            && original title/ renewal transfer
      f_compute (@l_freg, rdtp1c(xmsrp))
      f_compute (@l_ftitle, xtitle)
      f_compute (@l_ftfee, 0.00)
   case l_faction = "5"            && original plate
      f_compute (@l_freg, rdtp1c(xmsrp))
      f_compute (@l_ftitle, 0.00)
      f_compute (@l_ftfee, 0.00)
   case l_faction = "6"            && renewal plate
      f_compute (@l_freg, rdtp1c(xmsrp))
      f_compute (@l_ftitle, 0.00)
      f_compute (@l_ftfee, 0.00)
   case l_faction = "7"            && transfer plate
      f_compute (@l_ftfee, xreg)
      f_compute (@l_ftitle, 0.00)
      f_compute (@l_freg, 0.00)
   * case l_faction = "8"            && replacement plate/tab
   *    f_compute (@l_freg, 5.00)
   *    f_compute (@l_ftitle, 0.00)
   *    f_compute (@l_ftfee, 0.00)
   case l_faction = "9"            && renewal - transfer plate
      f_compute (@l_ftfee, 0.00)
      f_compute (@l_freg, rdtp1c(xmsrp))
      f_compute (@l_ftitle, 0.00) 
endcase   

* assign tab #
if (l_faction $ [2;4;5;6;9] .and. empty(l_ftab)) .or.  ;    && 12.01.06
   (l_faction $ [3;7] .and. xpdesc = [003] .and. empty(l_ftab))
   * update tab #
   select ratab
   set order to 2
   set softseek on
   seek xyear
   set softseek off
   do while .not. eof () .and. ratab->fyear =xyear
      if ratab->fstatus = "A" 
          reclock ()
          replace fstatus with "X"
          commit
          unlock
          exit
      endif
      skip
   enddo
   f_compute (@l_ftab, ratab->ftab)
   select ratab
   set order to 1
endif

* --------------------------------------
* 12.07.07: previous plate should equal current plate during normal transfer
*   i.e. xpdesc <> [003]
if l_faction $ [3;7] .and. xpdesc <> [003]
   l_fpplate = ""
endif

if empty (l_fpplate) .and. l_faction $ [3;4;6;7;9]
   * f_compute (@l_fpplate, l_fplate)
   l_fpplate = l_fplate
endif
* ---------------------------------------

f_compute (@l_fstate, "MI")

xchk = .t.

return .t.

*****************************************
function rdtp1c
* 10.01.03: add $3 to reg. fee
*           title fee can be changed from 12 to 15 in branch setup
parameter xmsrp
private y1, y2, y3, yfld, ylv, yfee, yxtra

yxtra = 3      && 10.01.03: add $3 to reg. fee
yfee = 0
* if xfee = [01]     && passenger car
if xmsrp > 8000     && 01.09.10: cut off for weight calc.
   * calculate level
   y2 = val(substr(dtos(l_fdate),1,4))    && taken year 2000 into account
   y3 = xyr
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
      otherwise 
         yfee = 0
      endcase
      yfee = f_round (yfee / 12 * l_fmonth, 0)   && prorate to l_fmonth
      yfee = yfee + 5                            && final fee
   else
      yfld = "ravalue->f"+strtran(str(l_fmonth,2)," ","")
      select ravalue
      seek str(xmsrp,5)+ylv
      if eof ()
         yfee = 0
      else
         yfee = &yfld
      endif             
   endif

   if yfee = 0        && warning:
      f_valid (.f., "Model Year exceeds Limit, Cannot Compute Reg. Fee...") 
   endif
   * for special plate  XXX99
   if l_faction $ [2;5] 
      yfee = yfee + xadded
   endif
   return (yfee + yxtra)
else                          && commercial must expire 02/28
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
      f_valid (.f., "Weight over 8000lb, Cannot Compute Reg. Fee...")
   endif 
   * for special plate  with added fee (normally added fee=0)
   if l_faction $ [2;5] 
      yfee = yfee + xadded
   endif
   return (yfee + yxtra)
endif

return (0)

***************************************************************
function rdtp1d

if lastkey () = 5
   return .t.
endif

if l_faction $ [2;4;5;6;9] .or. ;
   (l_faction $ [3;7] .and. xpdesc = [003])      && 12.01.06
   if empty (l_ftab)
      f_valid (.f., "Please enter Tab #...")
      xchk = .f.
      return .f.
   else
      * guard against duplicate tab
      select radtrh
      set order to 4
      seek l_ftab
      set order to 1
      if .not. eof ()
         f_valid (.f., "Duplicate tab, Please Check History Trans...")
         xchk = .f.
         return .f.
      endif 
      *
      select ratab
      seek l_ftab
      if eof () .or. .not. fstatus $ "A;X"
         f_valid (.f., "Invalid Tab #...")
         xchk = .f.
         return .f.
      elseif fyear <> xyear
         f_valid (.f., "This Tab is Only Valid for "+fyear+" Not "+xyear)
         xchk = .f.
         return .f.
      else
         reclock ()
         replace fstatus with "U"
         commit
         unlock
      endif 
   endif
else
   l_ftab = space(7)     
endif

xchk = .t.
return .t.

****************************************************************
function rdtp1e
private y1, y2

* check to see if vehicle has been titled
if l_faction $ [1;2;3;4]
   select ravm
   seek substr(l_fvin,10,8)
   if .not. eof() 
      if .not. empty(ravm->fdate1)
         f_valid (.f., "Vehicle has been titled already...")
         xchk = .f.
         return .f.
      endif
   endif                                                    
endif
* 05.10.98 check to see if vehicle have been plated already
if l_faction $ [2;5]
   select ravm
   seek substr(l_fvin,10,8)
   if .not. eof()
      if .not. empty(ravm->fplate)
         f_valid (.f., "Vehicle has been plated already...")
         xchk = .f.
         return .f.
      endif
   endif  
endif

select radtr
* 07.05.07: seek l_fbranch+dtos(l_fdate)+l_fclerk+substr(l_fvin,10,8)+l_faction
seek l_fbranch+dtos(l_fdate)+l_fclerk
if eof ()
   if f_verify ("raaction",1,l_faction)
      if l_faction = [1]
         f_compute (@l_fplate, space(7))
         f_compute (@l_fpplate, space(7))
      elseif l_faction $ [2;5]
         f_compute (@l_fpplate, space(7))
      endif
      return .t.
   else
      f_valid (.f., "Press <F1> for help.")
      return .f.
   endif
else
   l_fplate = fplate
   l_fpplate = fpplate
   xchk = .t.
   return .t. 
endif

****************************************************************
procedure rdtph1

private yvar, yscn, ycolor, yname, ystr
yvar = alltrim (upper (readvar ()))
ycolor = setcolor (gsubcolor)
do case
case yvar = "L_FVIN"
   * display data import from download to radtr
   select radtr
   * set softseek on
   * seek l_fbranch+dtos(l_fdate)+l_fclerk+trim(l_fvin)
   * set softseek off
   * if eof ()
   *    go bottom
   * endif
   go top
* 07.05.07:
*   if f_pick_f (4, 08, "", "", "faction+[  ]+fvin+[   ]+fclerk+[  ]+" +   ;
*             "fplate+[  ]+str(freg,6,2)+[ ]+str(ftitle,6,2)+[ ]+" +   ;
*             "str(ftfee,6,2)+[ ]+dtoc(fdate)")
   if f_pick_f (4, 08, "", "", "faction+[  ]+fvin+[   ]+fclerk+[  ]+" +   ;
             "fplate+[  ]+fref+[ ]+dtoc(fdate)")
      xrecno = recno ()
      l_fvin = fvin
      l_fcontrol = fcontrol     && control #
      l_fref = fref             && ref # 
      l_ftr11 = ftr11
      l_fowner = fowner
      l_faction = faction
      l_fplate = fplate
      l_ftab = ftab
      l_freg = freg
      l_ftitle = ftitle
      l_ftfee = ftfee
      l_fseq = fseq             && 09/26/96
      keyboard chr (13)
   endif
case yvar = "L_FACTION"      && 
   f_use ("RAACTION")
   go top
   if f_valid (.not. eof (), "Missing Chart...")
      set softseek on
      seek l_faction
      set softseek off
      if eof ()
         go bottom
      endif
      if f_pick_f (6, 15, "", "", "faction+[ - ]+fdesc")
         &yvar = raaction->faction
         keyboard chr (13)
      endif
   endif
case yvar = "L_FPLATE"
   f_use ("RAPLATE")
   set softseek on
   seek l_fplate
   if eof ()
      go bottom
   endif
   set softseek off
   if f_pick_f (6, 15, "", "", "fplate+[ ]+ftab+[ ]+ftype+[ ]+fstatus")
         &yvar = raplate->fplate
         keyboard chr (13)
   endif 
case yvar = "L_FLOC"
   f_use ("RALOC")
   set softseek on
   seek l_fplate
   if eof ()
      go bottom
   endif
   set softseek off
   if f_pick_f (05, 03, "", "", "trim(floc)+[ -> ]+f_truncate(trim(fname)+" ;
      + "[ ]+fccity,50)")
         &yvar = raloc->floc
         keyboard chr (13)
   endif 
case yvar $ "YTAB;L_FTAB"
   f_valid (.f., "Enter 7 digit tab #...")
otherwise
   * display value fee chart
   f_use ("RAVALUE")
   set softseek on
   seek str(xmsrp, 5)
   set softseek off
   f_pick_f (6,15,"","","str(fval,5)+[ ]+str(flevel,1)+[ ]+str(f6,4)"+  ;
             "+[ ]+str(f7,4)+[ ]+str(f8,4)+[ ]+str(f9,4)+[ ]+str(f10,4)"+  ;
             "+[ ]+str(f11,4)+[ ]+str(f12,4)+[ ]+str(f14,4)+[ ]+str(f15,4)"+  ;
             "+[ ]+str(f16,4)+[ ]+str(f17,4)") 
endcase
setcolor (ycolor)

*************************
* 12.01.06: add new F2 popup function
procedure rdtpf2
private yscn, ycolor

if l_faction $ [1;2;5]
   return
endif

ycolor = setcolor (gsubcolor)
yscn = f_box (yrow-1, 38, yrow + 2, 63)
@ yrow, 39 say "Previous Plate: "+l_fpplate
@ yrow + 1, 39 say "Current Plate : "+l_fplate
inkey(10)
f_restbox (yscn)
setcolor (ycolor)

return

***************************
function f_round
parameter xnum, xdec

return (round(xnum - .01, xdec))

