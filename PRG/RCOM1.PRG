*
* send data file (xmodem)
*
private yprompt, yresp

f_clrscn ("DTP/MI - Send File")

* get comm patameters
f_use ("rastn")
seek f_truncate (gstation, 8)
if eof ()
   f_valid (.f., "Invalid Setup...")
   close data
   return
else
   port = fcomm
   baud = fbaud
   parity = fparity
   stopbits = fstopbit
   wordlen = fdatabit
   modemstr = if (empty(finitstr), "E0S0=0V1Q0X1B0M1", finitstr)
   rbuf = frd
   xbuf = fsd
   number1 = fphone1
endif
use

if .not. modemsetup (modemstr)  
   f_valid (.f., "Please Setup Modem Parameters first...")
   return
endif

key = 0                           && inkey value
fileout = "800g014.txt"           && 

* start communication here ...

* check modem ...
if .not. modemok ()
   f_valid (.f., "Modem not responding...")
   return
endif

* start dialing number ...
f_popback ()
if dial (number1)
   starttime = time ()
   connlost = .f.
   yrow = 2
   do while lastkey() <> 27
      @ yrow, 04 
      do while .not. rxempty (port)
         ?? chr (rxchar (port))
      enddo
      Accept ">>" to yresp
      if upper(yresp) $ [ASCII;XMODEM;YMODEM]
         exit
      endif
      txflush (port)
      if upper(yresp) $ [X;Y;U]
         txstring (port, yresp)
      else
         txstring (port, yresp+chr (13))
      endif
      swdelay (12)
      yrow = yrow + 2
   enddo

   f_popback ()
   if .not. statuscd (port)
       do r_connlost
   else
       f_popup ("SENDING FILE...")
       rxflush (port)
       txflush (port)
       swdelay (12)        
       if upper(yresp) = [XMODEM]
          error = errorchk (txxmodem (port, fileout))
       elseif upper(yresp) = [YMODEM]
          error = errorchk (txymodem (port, fileout))
       elseif upper(yresp) = [ASCII]
          error = errorchk (txascii (port, fileout, 0, 27))
       endif
       if left (error,4) = "SUCC"
          f_valid (.f., "File Transfer Complete...")
          txflush (port)
          txstring (port, chr (27))
          f_popup ("Hanging Up Phone Line...")
          do r_hangup
       else
          f_valid (.f., "Error: " + error)
       endif
   endif
endif

f_popback ()

* ===========================================================================
* comm functions
* ===========================================================================
* hang up routine

procedure r_hangup

do while statuscd (port)
   smescape (port)
   txstring (port, "AT H0" + chr (13))
enddo
swdelay (12)

* ===========================================================================
* clean up after connection is dropped

procedure r_connlost

connlost = .t.
f_valid (.f., "ERROR: CONNECTION LOST")
do r_hangup

* ===========================================================================
* dialing routine

function dial

parameters num     && telephone number

key = inkey ()
conn = .f.
numco = 1
rxflush (port)
txflush (port)
do while key <> 27 
   key = inkey ()
   if key = 27
      do r_hangup
      return .f.
   endif
   smescape (port)
   do r_hangup
   f_popup ("DIALING NUMBER " + num )
   smdial (port, num) 
   swdelay (9)
   rxflush (port)
   txflush (port)
   sec = seconds ()
   cd_on = .f.
   do while seconds () < (sec + 60) .and. seconds () <> 0 .and. .not. cd_on ;
         .and. key <> 27
      key = inkey ()
      cd_on = statuscd (port)
   enddo
   if cd_on
      return .t.
   endif
enddo
return conn

* ===========================================================================
* initialize modem

function modemsetup

parameter initstr

if (opencomm (port, rbuf, xbuf) <> 0)
   f_valid (.f., "ERROR: [E5] NO COMM PORTS DETECTED. ****")
   return .f.
endif

if .not. modemok ()
   return .f.
endif

f_popup ("START: MODEM INITIALIZING")

txstring (port,[AT Z]+chr (13))
swdelay (9)

setbaud (port, baud, parity, stopbits, wordlen)
swdelay (9)

txstring (port, [AT ] + initstr + chr (13))
swdelay (9)

rxflush (port)
return .t.

* ===========================================================================
* send AT command
function modemok

if statuscd (port)
   return .t.
endif
rxflush (port)
sec = seconds () + 10
do while rxempty (port) .and. seconds () < sec
   f_popup ("START: CHECKING MODEM")
   txstring (port,[AT]+chr (13))
   swdelay (9)
enddo
if rxempty (port)
   f_valid (.f., "ERROR: [E6] MODEM NOT RESPONDING")
   return .f.
endif
rxflush (port)
txflush (port)
return .t.


* ===========================================================================
* communication error codes, refer to silverware ...

function errorchk

parameters eret

error = [ ]
do  case
case eret = 0
   error = [SUCCESSFUL      ]
case eret = -96
   error = [INSUFF_MEMORY   ]
case eret = -95
   error = [DEVICEABSENT    ]
case eret = -94
   error = [NOTINITIALIZED  ]
case eret = -89
   error = [TIMEOUT         ]
case eret = -88
   error = [USERABORT       ]
case eret = -87
   error = [DOSDISKERROR    ]
case eret = -86
   error = [NOCARRIER       ]
case eret = -85
   error = [LOSTCARRIER     ]
case eret = -84
   error = [NOINITIALNAK    ]
case eret = -83
   error = [NOREMOTERESPONSE]
case eret = -82
   error = [REMOTEUSERABORT ]
case eret = -81
   error = [NOMORERETRIES   ]
case eret = -80
   error = [BLOCKFRAMEERROR ]
case eret = -79
   error = [SHORTBLOCK      ]
case eret = -78
   error = [BLOCKSEQUENERROR]
case eret = -77
   error = [CHECKSUMERROR   ]
endcase

return error


