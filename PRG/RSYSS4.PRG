*
* set up misc. chart
*

do while .t.
   xret3 = f_pushmenu (xoption2)
   if xret3 = 0
      exit
   endif
   xoption3 = substr (goption [xret3], 4)
   do case
      case xret3 = 1            && transaction type
         private ydbfld [4], ydbcol [4], ydbvalid [4], ydbpict [4]
         f_clrscn ("DTP/MI - TRANSACTION TYPE CHART")
         f_use ("raaction")
         go top
         ydbfld[1]="faction"
         ydbfld[2]="fdesc"
         ydbfld[3]="frcode"
         ydbfld[4]="ftcode"
         ydbcol[1]="Action"
         ydbcol[2]="Description"
         ydbcol[3]="Reg. Code"
         ydbcol[4]="Tran Code"
         ydbvalid[1]=".t."
         ydbvalid[2]=".t."
         ydbvalid[3]=".t."
         ydbvalid[4]=".t."
         ydbpict[1]="!"
         ydbpict[2]="XXXXXXXXXXXXXXXXXXXXXXXXX"
         ydbpict[3]="!"
         ydbpict[4]="!"
         f_edit (ydbfld, ydbcol, 0, .t., ydbvalid, ydbpict)
         set filter to
         use
      case xret3 = 2            && body style
         private ydbfld [3], ydbcol [3], ydbvalid [3], ydbpict [3]
         f_clrscn ("DTP/MI - BODY STYLE CHART")
         f_use ("rabody")
         go top
         ydbfld[1]="fcode"
         ydbfld[2]="fdesc"
         ydbfld[3]="ftype"
         ydbcol[1]="Use Code"
         ydbcol[2]="Body Style"
         ydbcol[3]="Fee Code"
         ydbvalid[1]=".t."
         ydbvalid[2]=".t."
         ydbvalid[3]=".t."
         ydbpict[1]="!!"
         ydbpict[2]="XXXXXXXXXXXXXXX"
         ydbpict[3]="99"
         f_edit (ydbfld, ydbcol, 0, .t., ydbvalid, ydbpict)
         set filter to
         use
      case xret3 = 3            && fee code
         private ydbfld [2], ydbcol [2], ydbvalid [2], ydbpict [2]
         f_clrscn ("DTP/MI - FEE CODE")
         f_use ("rafee")
         go top
         ydbfld[1]="fcode"
         ydbfld[2]="fdesc"
         ydbcol[1]="Code"
         ydbcol[2]="Description"
         ydbvalid[1]=".t."
         ydbvalid[2]=".t."
         ydbpict[1]="!!"
         ydbpict[2]="XXXXXXXXXXXXXXX"
         f_edit (ydbfld, ydbcol, 0, .t., ydbvalid, ydbpict)
         set filter to
         use
      case xret3 = 4            && county code
         private ydbfld [2], ydbcol [2], ydbvalid [2], ydbpict [2]
         f_clrscn ("VTP/MI - COUNTY CODE CHART")
         f_use ("racty")
         go top
         ydbfld[1]="fcode"
         ydbfld[2]="fdesc"
         ydbcol[1]="Code"
         ydbcol[2]="County"
         ydbvalid[1]=".t."
         ydbvalid[2]=".t."
         ydbpict[1]="!!"
         ydbpict[2]="XXXXXXXXXXXXXXX"
         f_edit (ydbfld, ydbcol, 0, .t., ydbvalid, ydbpict)
         set filter to
         use
      case xret3 = 5            && value fee
         private ydbfld [13], ydbcol [13], ydbvalid [13], ydbpict [13]
         f_clrscn ("VTP/MI - VALUE FEE CHART")
         f_use ("ravalue")
         go top
         ydbfld[1]="fval"
         ydbfld[2]="flevel"
         ydbfld[3]="f6"
         ydbfld[4]="f7"
         ydbfld[5]="f8"
         ydbfld[6]="f9"
         ydbfld[7]="f10"
         ydbfld[8]="f11"
         ydbfld[9]="f12"
         ydbfld[10]="f14"
         ydbfld[11]="f15"
         ydbfld[12]="f16"
         ydbfld[13]="f17"
         ydbcol[1]="Value"
         ydbcol[2]="Lv"
         ydbcol[3]=" 6 "
         ydbcol[4]=" 7 "
         ydbcol[5]=" 8 "
         ydbcol[6]=" 9 "
         ydbcol[7]=" 10 "
         ydbcol[8]=" 11 "
         ydbcol[9]=" 12 "
         ydbcol[10]=" 14 "
         ydbcol[11]=" 15 "
         ydbcol[12]=" 16 "
         ydbcol[13]=" 17 "
         ydbvalid[1]=".t."
         ydbvalid[2]=".t."
         ydbvalid[3]=".t."
         ydbvalid[4]=".t."
         ydbvalid[5]=".t."
         ydbvalid[6]=".t."
         ydbvalid[7]=".t."
         ydbvalid[8]=".t."
         ydbvalid[9]=".t."
         ydbvalid[10]=".t."
         ydbvalid[11]=".t."
         ydbvalid[12]=".t."
         ydbvalid[13]=".t."
         ydbpict[1]="99999"
         ydbpict[2]="9"
         ydbpict[3]="9999"
         ydbpict[4]="9999"
         ydbpict[5]="9999"
         ydbpict[6]="9999"
         ydbpict[7]="9999"
         ydbpict[8]="9999"
         ydbpict[9]="9999"
         ydbpict[10]="9999"
         ydbpict[11]="9999"
         ydbpict[12]="9999"
         ydbpict[13]="9999"
         f_edit (ydbfld, ydbcol, 0, .t., ydbvalid, ydbpict)
         set filter to
         use
   endcase
enddo


