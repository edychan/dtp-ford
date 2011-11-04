*
* back up program for dtp
*
set excl off
set delete on
clear
bpath = "c:\dtp"+str(dow(date()),1)+"\"
yfil = bpath + "idle"
if .not. file (yfil)
   quit
endif
ypath = "f:\dtp\dbf\"
yfil = ypath + "rapath"
select 0 
use &yfil alias rapath
go top
do while .not. eof ()
   if rapath->fupdate = "U"
      yfil = ypath + alltrim(fname) + ".dbf"
      if file(yfil)
         ? "Backing Up --> " + falias
         bfile = bpath + alltrim(fname) + ".dbf"
         copy file &yfil to &bfile
      endif
   endif
   skip
enddo
   
close data

