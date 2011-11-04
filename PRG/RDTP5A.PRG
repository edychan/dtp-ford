* ----------------------------------------------------
*
* post batch
*
* important: no puncuation
*            no decimal
*
* changes:
* 09/11/96: add 10th digit (model year) to vin chart
* 09/24/96: full right to survivor should always be [N]
* 09/24/96: move ref # (garage id) to company name line
* 06.26.97: add tr11-T for test vehicle ==> different address
* 09.17.97: send msrp for pickup/van weigh < 5000 lb
* 10.27.98: year 2000 (frenewal)
* 12.15.99: allow commerical plate on passenger cars
* ----------------------------------------------------
* 02.18.99: y2k format for layout # BR044D
* ----------------------------------------------------
* 08.06.01: add plate desc field
* 12.10.01: fix plate desc field
* 10.03.02: move ref. # to Name Line 2 (F45NAME)
* 03.26.03: address assignment according to tag type (override)
* ----------------------------------------------------
* 05.19.04: major format changes (from 624 to 720)
*           use 136.181.135.38 for sending test files.
*           userid: DOSC800 password: DOSC800
*           put "filename" DOS800D@DOS800D
* 12.01.04: new passenger plate config. AAA9999
* ----------------------------------------------------
* 03.20.06: report odometer to SOS (10 miles)
* 10.03.06: add F tag
* 10.03.06: send lien holder info if titled by FORD MOTOR CREDIT CSV LLC only
* 10.30.06: use chkplate to get plate desc code
* 12.18.06: add new parameter xbatchno
* 12.18.06: add return file for 804 (wrt804fil)
* 02.26.06: change address for ELS tag (add fcounty1, fcounty2, fctyname1, fctyname2)
* ----------------------------------------------------
* 11.05.08: return MSRP (e.g. 028225)
* ----------------------------------------------------
* F01ID = [U ]                    && C2 MESSAGE ID
* F02VER = [1005]                 && C4 PROGRAM VERSION 
* F03F1 = [00000]                 && C5 FILLER  
* F04CLERK = [A]                  && C1 CLERK CODE  (A - Z) 
* F05AREA = [R]                   && C1 AREA CODE (Always R)
* F06RCODE =                      && C1 REG. TRAN CODE 
* F07TCODE =                      && C1 TITLE TRAN CODE
*                                 && 1 org title             ==> PA
*                                 && 2 org title/org plate   ==> AA
*                                 && 3 org title/tran plate  ==> GA
*                                 && 4 org title/renew plate ==> HA
*                                 && 5 org plate             ==> Ab
*                                 && 6 renew plate           ==> Bb
*                                 && 7 tran plate            ==> Gb
*                                 && 8 replace plate/Tab     ==> Fb
*                                 && 9 renew/tran plate      ==> Hb
* F08JDATE = [G005]               && C4 JULIAN DATE   
*                                 && G   ==> 1996  (skip I, O & Q)
*                                 && 005 ==> Jan 05
* F09BRANCH = [800]               && N3 BRANCH # (use 800 for testing)
* F10SEQ = [0001]                 && N4 SEQ # 
* F11F2 = [    ]                  && C4 FILLER 
* F12ICODE = [13]                 && C2 INQUIRY CODE    
* F13ITI = [N]                    && C1 INSTANT TITLE INDICATOR 
* F14TAX = [0]                    && C1 TAX CODE (per chris johnson)
                                  &&    [ ] for no tax
                                  &&    [0] for sales tax
                                  &&    [1] for use tax
* F15TAXAMT = [00000000]          && N8 TAX PAID 
* F16TITLE =                      && N8 TITLE FEE
* F17LATE = [00000000]            && N8 LATE FEE 
* F18VAF = [00000000]             && C8 VIN ASSIGNMENT FEE (not used)
* F19REG =                        && N8 REGISTRATION FEE  
* F20ADDED = [00000000]           && N8 ADDED FEE                       
* F21PLATE =                      && C7 PLATE #                         
* F22PPLATE =                     && C7 PREVIOUS PLATE #                
* F23EXP =                        && ** N6 EXPIRATION DATE (MMDDYYYY)        
* F24MONTH =                      && N2 NUMBER OF MONTHS                

* F25TAB =                        && N7 TAB #
* F26FEE =                        && N2 FEE CODE                        
*                                 && 01 ==> Passenger
*                                 && 03 ==> Commercial
*                                 && 04 ==> Trailers
*                                 && 05 ==> GVW plates
*                                 && 06 ==> GVW plates (less than full year)
* F27RPI = [N]                    && C1 REPLACEMENT PLATE INDICATOR     
* F28RTI = [N]                    && C1 REPLACEMENT TAB INDICATOR       
* F29COUNTY =                     && C2 COUNTY CODE                     
* F30YEAR = [96]                  && ** C4 VEHICLE MODEL YEAR              
* F31MAKE =                       && C12 MAKE                            
* F32VIN =                        && C17 VIN                             
* F33BODY =                       && C3 BODY STYLE                      
* F34WFC =                        && N6 WEIGHT/FEE CATAGORY             
* F35ORG = [   ]                  && ** not used N3 ORGANIZATIONAL CODE             
* F36F3 = space (2)               && ** not used C2 FILLER                          
* F37PTN = space (11)             && ** not used C11 PREVIOUS TITLE #                
* F38F4 = space (31)              && ** not used C31 FILLER                          
* F39ADDR =                       && C36 ADDRESS                         
* F40CITY =                       && C19 CITY                            
* F41STATE =                      && C2 STATE                           
* F42ZIP =                        && C5 ZIP                             
* F43COI = [C]                    && C13 DLN/COMPANY OWNED INDICATOR     
* F44MODEL =  space(17)           && C17 MODEL (filled in by sos mainframe)
* F45NAME =                       && ** C72 NAME                            
                                  && C36 NAME1
                                  && C36 NAME2
* F46MI = [E]                     && C1 MILEAGE INDICATOR
*                                 && A ==> actual mileage
*                                 && B ==> not actual mileage
*                                 && C ==> over 99,999
*                                 && E ==> exempt
* F47AET = [K]                    && C1 AET EXEMPT CODE                 
*                                 &&    K ==> New vehicle exemption
* F48MLG = [000000]               && C6 MILEAGE                         
* F491LIEN =                      && C36 1ST LIEN NAME                   
* F501LFD =                       && ** C8 1ST LIEN FILING DATE (MMDDYYYY)   
* F511ADDR =                      && C20 1ST LIEN ADDRESS                
* F521CITY =                      && C19 1ST LIEN CITY                   
* F531STATE =                     && C2 1ST LIEN STATE                  
* F541ZIP =                       && C5 1ST LIEN ZIP                    
* F552LIEN = space (36)           && C36 2ND LIEN NAME                   
* F562LFD  = space (8)            && ** C8 2ND LIEN FILING DATE (MMDDYYYY)   
* F572ADDR = space (20)           && C20 2ND LIEN ADDRESS                
* F582CITY = space (19)           && C19 2ND LIEN CITY                   
* F592STATE = space (2)           && C2 2ND LIEN STATE                  
* F602ZIP = space (5)             && C5 2ND LIEN ZIP                    
* F61HSI = [N]                    && C1 HANDICAP STICKER INDICATOR      
* F62RTS = [N]                    && C1 FULL RIGHTS TO SURVIVOR         
* F63TEI = [Y]                    && C1 TAX EXEMPT INDICATOR            
* F64TER = [Y]                    && C33 TAX EXEMPT REASON               
* F65DLN = space (5)              && C5 DEALER #                        
* F66MSRP = [00000000]            && N8 PURCHASE PRICE                  
*                                 && ** C62 FILLER
* ----------------------------------------------------
parameter xbranch, xdate, xbatchno
private ydate, yplatetyp, ymsrp

restore from (gmempath+"radtrh") additive
restore from (gmempath+"ratran") additive
L_F01ID = [U ]                    && C2 MESSAGE ID  
L_F02VER = [1005]                 && C4 PROGRAM VERSION - 05.19.04
L_F03F1 = [00000]                 && C5 FILLER  
L_F05AREA = [R]                   && C1 AREA CODE (Always R)
L_F08JDATE = JDATE (XDATE)        && C4 JULIAN DATE   
L_F11F2 = [    ]                  && C4 FILLER 
L_F12ICODE = [13]                 && C2 INQUIRY CODE    
L_F13ITI = [N]                    && C1 INSTANT TITLE INDICATOR 
L_F14TAX = [0]                    && C1 TAX CODE per chris johnson
L_F15TAXAMT = [00000000]          && N8 TAX PAID 
L_F17LATE = [00000000]            && N8 LATE FEE 
L_F18VAF = [00000000]             && C8 VIN ASSIGNMENT FEE (not used)
L_F20ADDED = [00000000]           && N8 ADDED FEE                       
L_F27RPI = [N]                    && C1 REPLACEMENT PLATE INDICATOR     
L_F28RTI = [N]                    && C1 REPLACEMENT TAB INDICATOR       
L_F35ORG = [   ]                  && N3 ORGANIZATIONAL CODE             
L_F36F3 = space (2)               && C2 FILLER                          
L_F37PTN = space (11)             && C11 PREVIOUS TITLE #                
L_F38F4 = space (31)              && C31 FILLER                          
L_F43COI = [C]                    && C13 DLN/COMPANY OWNED INDICATOR     
L_F44MODEL = space (17)           && C17 filled in by sos mainframe
L_F46MI = [E]                     && C1 MILEAGE INDICATOR               
L_F47AET = [K]                    && C1 AET EXEMPT CODE                 
L_F48MLG = [000000]               && C6 MILEAGE                         
L_F61HSI = [N]                    && C1 HANDICAP STICKER INDICATOR      
L_F62RTS = [N]                    && C1 FULL RIGHTS TO SURVIVOR         
L_F63TEI = [Y]                    && C1 TAX EXEMPT INDICATOR            
L_F65DLN = space (5)              && C5 DEALER #                        
L_F66MSRP = [00000000]            && N8 PURCHASE PRICE                  


* -- f_use ("ravin")  && 10.01.08

f_use ("radtrh")
f_use ("raplate")
f_use ("ravm")
f_use ("raloc")
set excl on                && only one user can post at one time
f_use ("ratran")
zap
set excl off

select radtrh
set softseek on
seek xbranch+dtos(xdate)
set softseek off
@ 06, 45 say "records processed"
ytrans = 1
do while .not. eof () .and. fbranch = xbranch .and. fdate = xdate

   * --03.08.11
   @ 06,40 say str(ytrans,4)
   ytrans = ytrans + 1
   select raloc
   * seek radtrh->floc
   seek radtrh->fbranch
   if .not. eof ()
      L_F09BRANCH = raloc->FBRANCH             && N3 BRANCH # (use 800 for testing)
      * 03.26.03: address assignment according to tag type
      if upper(substr(radtrh->fref,8,1)) $ "F;W;Y;T;H"    && 10.03.06 add F tag
         L_F29COUNTY = raloc->FCOUNTY2               && C2 COUNTY CODE                     
         L_F39ADDR = raloc->FADDR2
         L_F40CITY = raloc->FCITY2               
         L_F41STATE = raloc->FSTATE2             
         L_F42ZIP = raloc->FZIP2                 
      elseif upper(substr(radtrh->fref,8,1)) = "G"   && TR11-D use alt address
         L_F29COUNTY = raloc->FCOUNTY1               && C2 COUNTY CODE                     
         L_F39ADDR = raloc->FADDR1
         L_F40CITY = raloc->FCITY1               
         L_F41STATE = raloc->FSTATE1             
         L_F42ZIP = raloc->FZIP1                 
      else                                           && TR-11
         L_F29COUNTY = raloc->FCOUNTY                && C2 COUNTY CODE                     
         L_F39ADDR = raloc->FCADDR
         L_F40CITY = raloc->FCCITY                   && C19 CITY                            
         L_F41STATE = raloc->FCSTATE                 && C2 STATE                           
         L_F42ZIP = raloc->FCZIP                     && C5 ZIP                             
      endif
      *X1LIEN = raloc->FOWNER                        && C36 1ST LIEN NAME                   
      *YLFD = DTOC(XDATE)
       *X1LFD = SUBSTR(YLFD,1,2)+SUBSTR(YLFD,4,2)+SUBSTR(YLFD,7,2)
      *X1ADDR = FOADDR               && C20 1ST LIEN ADDRESS                
      *X1CITY = FOCITY               && C19 1ST LIEN CITY                   
      *X1STATE = FOSTATE             && C2 1ST LIEN STATE                  
      *X1ZIP = FOZIP                 && C5 1ST LIEN ZIP                    
      L_F491LIEN = space(36) 
      L_F501LFD = space(8)   
      L_F511ADDR = space(20) 
      L_F521CITY = space(19) 
      L_F531STATE = space(2) 
      L_F541ZIP = space(5)   
      L_F552LIEN = space (36)           && C36 2ND LIEN NAME                   
      L_F562LFD  = space (8)            && **C8 2ND LIEN FILING DATE (MMDDYYYY)   
      L_F572ADDR = space (20)           && C20 2ND LIEN ADDRESS                
      L_F582CITY = space (19)           && C19 2ND LIEN CITY                   
      L_F592STATE = space (2)           && C2 2ND LIEN STATE                  
      L_F602ZIP = space (5)             && C5 2ND LIEN ZIP                    
      L_F64TER = FREASON                && C33 TAX EXEMPT REASON               
   endif

   * 10/21/96: name + tag #
   * 11/27/96: name + trim(tag #)
   * 10.03.02: move fref to Name Line 2
   L_F45NAME = f_truncate(if(empty(radtrh->fowner),alltrim(raloc->fname),alltrim(radtrh->fowner)),36)+ ;
               f_truncate(alltrim(radtrh->fref),36)                             

   * 10.03.06: add lien holder info
   * lien holder info. is required for title application only
   if radtrh->faction $ [1;2;3;4] .and. [CSV LLC] $ upper(radtrh->fowner)
      L_F491LIEN = glhname 
      YLFD = DTOC(XDATE)
      L_F501LFD = SUBSTR(YLFD,1,2)+SUBSTR(YLFD,4,2)+SUBSTR(YLFD,7,2)   
      L_F511ADDR = glhaddr 
      L_F521CITY = glhcity 
      L_F531STATE = glhstate 
      L_F541ZIP = glhzip     
   endif

   select radtrh
   do case
   case faction = [1]
      L_F06RCODE = [P]
      L_F07TCODE = [A]
   case faction = [2]
      L_F06RCODE = [A]
      L_F07TCODE = [A]
   case faction = [3]
      L_F06RCODE = [G]
      L_F07TCODE = [A]
   case faction = [4]
      L_F06RCODE = [H]
      L_F07TCODE = [A]
   case faction = [5]
      L_F06RCODE = [A]
      L_F07TCODE = [ ]
   case faction = [6]
      L_F06RCODE = [B]
      L_F07TCODE = [ ]
   case faction = [7]
      L_F06RCODE = [G]
      L_F07TCODE = [ ]
   *case faction =[8]
   *   L_F06RCODE = [F]
   *   L_F07TCODE = [ ]
   case faction = [9]
      L_F06RCODE = [H]
      L_F07TCODE = [ ]
   otherwise
      L_F06RCODE = [ ]
      L_F07TCODE = [ ]
   endcase
   L_F04CLERK = radtrh->fclerk                  && C1 CLERK CODE  (A - Z) 
   L_F10SEQ = radtrh->fseq
   L_F16TITLE = strtran(str(ftitle*100,8,0), " ", "0")
   L_F19REG = strtran(str((freg+ftfee)*100,8,0), " ", "0")
   L_F21PLATE = fplate
   L_F22PPLATE = fpplate      
   L_F23EXP = space(6)
   L_F25TAB = ftab
   L_F32VIN = fvin  
   L_F24MONTH = strtran(str(radtrh->fmonth,2,0)," ","0")
   yplatetyp = if(f_verify("raplate",1,radtrh->fplate),raplate->ftype,[U])    && 12.15.99
   select ravm
   * --seek substr(radtrh->fvin,1,8)+substr(radtrh->fvin,10,1)
   seek substr(radtrh->fvin,10,8)
   L_F26FEE = ravm->ffee        
   L_F30YEAR = ravm->fyear
   L_F31MAKE = if(upper(ravm->fmake)="LAND","LAND ROVER",ravm->fmake)
   L_F33BODY = ravm->fstyle
   if ravm->ffee = [01] .and. yplatetyp <> [03]
      * 12/10/96: edc
      if radtrh->faction $ [3;7]
         select raplate
         seek radtrh->fplate
         if .not. eof()
            L_F23EXP = strtran(dtoc(raplate->frenewal),"/","") 
         endif
      endif
      if empty(l_f23exp)
         yy1 = val(substr(dtos(xdate),1,4))         && 199X
         if substr(dtoc(xdate),1,2) = [12]    && for month = dec
             yy1 = yy1 + 2
         else
             yy1 = yy1 + 1
         endif
         yy1 = str(yy1,4)
         L_F23EXP = [0401]+substr(yy1,3,2)
      endif
      * -- 11.05.08: return full MSRP amount to CVMS
      * if ravm->fmsrp > 99999
      *    L_F34WFC = strtran(str(ravm->fmsrp,6,0)," ","0")
      * else
      *    L_F34WFC = strtran(str(int(ravm->fmsrp/1000),6,0)," ","0")
      * endif
      L_F34WFC = strtran(str(ravm->fmsrp,6,0)," ","0")
      * --
   else
      if radtrh->faction $ [3;7]
         select raplate
         seek radtrh->fplate
         if .not. eof()
            L_F23EXP = strtran(dtoc(raplate->frenewal),"/","") 
         endif
      endif
      if empty(l_f23exp)
         yy1 = val(substr(dtos(xdate),1,4))         && 199X
         if substr(dtoc(xdate),1,2) $ [10,11,12]    && for month = oct,nov,dec
             yy1 = yy1 + 2
         else
             yy1 = yy1 + 1
         endif
         yy1 = str(yy1,4)
         L_F23EXP = [0228]+substr(yy1,3,2)
      endif

      * -- 11.05.08
      * if ravm->fmsrp > 99999
      *    L_F34WFC = strtran(str(ravm->fmsrp,6,0)," ","0")
      * elseif ravm->fmsrp > 10000
      *    L_F34WFC = strtran(str(int(ravm->fmsrp/1000),6,0)," ","0")
      * else
      *    L_F34WFC = strtran(str(ravm->fmsrp,6,0)," ","0")
      * endif
      L_F34WFC = strtran(str(ravm->fmsrp,6,0)," ","0")
      * --

   endif
   * L_F44MODEL = ""
   * 03.20.06: report odometer reading for branch 804 (10 miles)
   if L_F07TCODE = [A]                            && Title application only
      L_F46MI = [A]                               && C1 Actual MILEAGE INDICATOR               
      L_F48MLG = [000010]                         && C6 MILEAGE                         
   else
      L_F46MI = [E]                       
      L_F48MLG = [000000]              
   endif
   *
   select ratran
   append blank
   f_replace ()

   * update plate file
   if .not. empty (radtrh->fplate)       && 12.11.06: 
      select raplate
      seek radtrh->fplate
      if eof ()
         append blank
      else 
         reclock ()
      endif
      replace fplate with radtrh->fplate
      replace fvin with substr(radtrh->fvin,10,8), fstatus with "U"
      if .not. empty(radtrh->ftab)
         replace ftab with radtrh->ftab
      endif
      if empty (ftype)
         replace ftype with ravm->ffee
      endif
      if empty (fstate)
         replace fstate with [MI]
      endif
      if empty (fedate)
         replace fedate with xdate
      endif
      if radtrh->faction $ [2;4;5;6;9]
         * 10.27.98: year 2000
         ydate = ctod(substr(l_f23exp,1,2)+"/"+  ;
              substr(l_f23exp,3,2)+"/"+substr(l_f23exp,5,2))
         f_y2k (@ydate)
         replace frenewal with ydate
      endif
      commit
      unlock
   endif

   * update ravm
   select ravm
   seek substr(radtrh->fvin,10,8)
   if .not. eof ()
      reclock ()
      replace funit with radtrh->funit 
      if radtrh->faction $ [1;2;3;4]
         replace fdate1 with xdate
      endif
      if radtrh->faction $ [3;7;9]
         replace fpplate with ravm->fplate
      endif
      if radtrh->faction $ [2;4;6]
         replace fplate with radtrh->fplate
      endif
   endif
   select radtrh 
   skip
enddo

* y2k changes
* not used: F35ORG, F36F3, F37PTN, F38F4
* field need to be modified: F23EXP     - MMDDYYYY (exp. date)
*                            F30YEAR    - YYYY (model year)
*                            F33BODY    - from C3 to C2 (no effect)
*                            F501LFD    - MMDDYYYY (filing date)
*                            F562LFD    - MMDDYYYY (filing date)
*                            F45NAME    - 10.03.02 (see below) 
* new field: special body use code - default to blank now as part of F33BODY         
*            add space(62) as filler at end of record
select ratran
go top
if .not. eof ()
   yfil = gcompath+xbranch+jdate(xdate)+".txt"
   * f_popup ("Creating Send File "+xbranch+jdate(xdate)+".txt")

   @ 06, 40 say "Creating SOS electronic send file ..."
  
   set device to print
   set printer to &yfil
   setprc (0,0)
   yln = 0
   do while .not. eof ()
      * 08.06.01: define plate description
      * ypdesc = space (3)
      ypdesc = space(3)
      if .not. empty (F21PLATE)
         yplate = F21PLATE
         chkplate (yplate, @ypdesc)        && 10.30.06
         if ypdesc = [003]                 && 01.01.07: just in case, stop everything
            exit
         endif
      endif
      * seperate reg fee & transfer fee
      ytfee = [000]
      yregfee = f19reg
      if f06rcode = [G]    && back out $8 plate transfer fee
         ytfee = [008]     && special case: no decimal for transfer fee 
         yregfee = val(f19reg) - 800
         yregfee = strtran(str(yregfee,8,0), " ", "0")
      endif
      * other service fee
      yosfee = [000]
      * 10.30.06: add new plate desc code: [010]
      if ypdesc $ [001;010] .and. f06rcode = [A]  && original (new) bridge plate
         yosfee = [005]                       && no decimal for $5 plate fee
         yregfee = val(f19reg) - 500
         yregfee = strtran(str(yregfee,8,0), " ", "0")
      endif

      * -- 11.05.08:
      if val(F34WFC) > 10000 .and. val(F34WFC) < 100000   && assume vehicle weight if MSRP < 10000
         L_F34WFC = [0000]+substr(F34WFC,2,2)   && i.e. [000028]
      else
         L_F34WFC = F34WFC
      endif
      * --

      @yln, 00 say F01ID + F02VER + [00000] + F04CLERK + F05AREA + ;
       F06RCODE + ;     && reg. trans code
       F07TCODE + ;     && title trans code
       F08JDATE + ;     && julian date
       F09BRANCH + ;    && branch #
       F10SEQ + ;       && seq #
       space(4) + ;     && filler
       F12ICODE + ;     && inquiry code: [13]
       F13ITI + ;       && instant title indicator: [N]
       F14TAX + ;       && tax code
       F15TAXAMT + ;    && tax amount: [00000000]
       F16TITLE + ;     && title fee
       F17LATE + ;      && title late fee: [00000000]
       [00000000] + ;   && filler
       yregfee + ;      && reg. fee
       [0000] + ;       && reg. late fee
       [N] + ;          && reg. late fee indicator
       F25TAB + ;       && tab #
       [ ] + ;          && filler
       F21PLATE + ;     && plate #
       F22PPLATE + ;    && previous plate #
       if(substr(F23EXP,5,2)>[90],substr(F23EXP,1,4)+[19]+substr(F23EXP,5,2), ;
         substr(F23EXP,1,4)+[20]+substr(F23EXP,5,2)) + ;    && exp. date
       F24MONTH +  ;    && # of month
       [0]+F26FEE + ;   && 08.06.01 increase from C2 to C3
       F27RPI  + ;      && replacement plate indicator
       F28RTI +  ;      && replacement tab indicator
       F29COUNTY +  ;   && county code
       if(empty(F30YEAR),[1999],if(F30YEAR>[90], [19]+F30YEAR, [20]+F30YEAR)) + ;
       F31MAKE + ;      && make
       F32VIN + ;       && VIN
       F33BODY + ;      && body type+special use code
       L_F34WFC   + ;   && weight/fee cat.  -- 11.05.08
       F39ADDR + ;      && street
       F40CITY + ;      && city
       F41STATE + ;     && state
       F42ZIP + ;       && zip
       F43COI + ;       && DLN or company owned indicator
       F44MODEL + ;     && model
       F45NAME + ;      && first owner name + second owner name
       F46MI + ;        && mileage indicator
       F47AET + ;       && AET exempt code
       F48MLG + ;       && mileage: [000000]
       F491LIEN + ;     && first lien name
       space(8) + ;     && filing date [mmddyyyy]
       F511ADDR + ;     && address
       F521CITY + ;
       F531STATE + ;
       F541ZIP  + ;
       F552LIEN + ;     && 2nd lien name
       space(8) + ;     && filing date [mmddyyyy]
       F572ADDR + ;     && address
       F582CITY + ;
       F592STATE + ;
       F602ZIP   + ;
       F61HSI + ;       && handicate sticker indicator
       F62RTS + ;       && rights to survivor
       F63TEI + ;       && tax exempt indicator
       F64TER + ;       && tax exempt reason
       space(67) + ;    && filler
       F65DLN + ;       && dealer #
       space(2) + ;     && filler
       F66MSRP + ;      && purchase price
       ypdesc + ;       && plate desc
       ytfee + ;        && transfer fee
       yosfee + ;       && other service fee
       space(81)        && filler

      yln = yln + 1
      skip
   enddo
   
   set printer to
   set console on
   set print off
   set device to screen

   * --03.08.11
   if ypdesc = [003]   && 01.01.07
      erase &yfil
      f_valid (.f., "ERROR: Invalid Blue Plate Transaction Found !!")
      close data
      return
   endif

   * create Ford804.txt
   if xbranch = [804]
      @ 06, 40 say "Creating CVMS communication file ..."
      do wrt804fil
   endif

endif

close data

**************************************
procedure wrt804fil
private yfil, yln, yfld, ycode

yfil = "c:\spool\ford804.txt"
set device to print
set printer to &yfil
setprc (0,0)

* write header
yln = 0
@yln, 0 say [HDR]+[  ]+[CVMS 435U  ]+  ;
        strtran(dtoc(xdate),"/","-")+[   ]+strtran(str(xbatchno,10)," ","0")
yln = yln + 1
select ratran
go top
do while .not. eof () 
   do case
   case F06RCODE = [P] .and. F07TCODE = [A]
      ycode = [1]
   case F06RCODE = [A] .and. F07TCODE = [A]
      ycode = [2]
   case F06RCODE = [G] .and. F07TCODE = [A]
      ycode = [3]
   case F06RCODE = [H] .and. F07TCODE = [A]
      ycode = [4]
   case F06RCODE = [A] .and. F07TCODE = [ ]
      ycode = [5]
   case F06RCODE = [B] .and. F07TCODE = [ ]
      ycode = [6]
   case F06RCODE = [G] .and. F07TCODE = [ ]
      ycode = [7]
   case F06RCODE = [H] .and. F07TCODE = [ ]
      ycode = [9]
   otherwise
      ycode = [ ]
   endcase
   * -- 11.05.08: only return MSRP for title trans
   if ycode $ [1;2;3;4]
       ymsrp = F34WFC
   else
       ymsrp = [000000]
   endif
   * --
   yfld = F09BRANCH + ;
          F08JDATE + ;
          F10SEQ + ;
          F32VIN + ;
          F21PLATE + ;
          F22PPLATE + ;
          ycode + ;
          F16TITLE + ;        && Title + transfer fee (e.g. 15+8)
          F19REG + ;          && registration fee
          [00000000] + ;      && extra fee not used
          F25TAB + ;
          substr(F23EXP,1,4)+[20]+substr(F23EXP,5,2) + ;  
          substr(F45NAME,1,36) + ;
          ymsrp              && 11.05.08: return MSRP (e.g. 000028)
   @yln, 0 say yfld
   yln = yln + 1
   skip
enddo

* write trailer
@yln, 0 say "TRL"+[  ]+strtran(dtoc(xdate),"/","-")+[   ]+strtran(str(yln-1,5)," ","0")

set printer to
set console on
set print off
set device to screen

*****************************
