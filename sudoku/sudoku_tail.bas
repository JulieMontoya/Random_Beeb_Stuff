  900CALLreset_grid:PROCpoke(alt_ptr,grp_map-&80)
  910END
 1000PROCginit
 1010PROChelp
 1020R%=0:C%=0:M$=" "
 1030REPEAT
 1040PRINTTAB(0,1);:PROCdisp_cands(R%*9+C%):PRINTTAB(30,1);M$:D%=FNsolved(R%*9+C%):PROCwrt_digit(C%,R%,10):M%=FNpeek(scr_ptr)+40
 1050K$=INKEY$10
 1060N%=R%*9+C%+cands_17:IF?N%=&7F ANDN%?81=&C0 PROCwrt_digit(C%,R%,0)ELSEPROCdisp_cont(R%*9+C%):!M%=!M%AND&2F2F2FFF
 1070IFK$="Z"ANDC%>0C%=C%-1
 1080IFK$="X"ANDC%<8C%=C%+1
 1090IFK$=":"ANDR%>0R%=R%-1
 1100IFK$="/"ANDR%<8R%=R%+1
 1110IFK$<>"R"GOTO1130
 1120IFM$="R"M$=" "ELSEM$="R"
 1130IFK$<>"D"GOTO1150
 1140IFM$="D"M$=" "ELSEM$="D"
 1150IFK$<"1"ORK$>"9"GOTO1210
 1160IFFNtest_cand(R%*9+C%,ASCK$-48)=0VDU7:GOTO1210
 1170PROCwrt_digit(C%,R%,ASCK$-48)
 1180IFD%PROCclr_digit(R%*9+C%)
 1190PROCset_digit(R%*9+C%,ASCK$-48)
 1200PROCelim_out(R%*9+C%,ASCK$-48):CLS
 1210IFK$<>"0"GOTO1240
 1220PROCwrt_digit(C%,R%,0)
 1230PROCclr_digit(R%*9+C%)
 1240IFK$<>" "AND(K$<"0"ORK$>"9")GOTO1270
 1250IFM$="R"C%=C%+1:IFC%>8C%=C%-9:R%=(R%+1)MOD9
 1260IFM$="D"R%=R%+1:IFR%>8R%=R%-9:C%=(C%+1)MOD9
 1270IFK$="S"PROCsave
 1280IFK$="L"PROCload
 1290IFK$="P"PROCposs
 1300IFK$="E"PROCexport
 1310IFK$="H"PROChelp
 1320UNTILK$=CHR$13
 1330CALLcount_solved
 1340CLS:PRINT;?solved;"/81 digits."
 1350PRINT'"Press"CHR$129"f3"CHR$135"to solve puzzle.":END
 1360DEFPROCsave
 1370PRINT"Filename ";:INPUTF$
 1380OSCLI"SAVE "+F$+" "+STR$~cands_17+" +A2"
 1390CLS:ENDPROC
 1400DEFPROCload
 1410PRINT"Filename ";:INPUTF$
 1420OSCLI"LOAD "+F$+" "+STR$~cands_17
 1430PROCposs:CALLcount_solved:ENDPROC
 1440DEFPROCposs
 1450LOCALM%,X%:FORX%=0TO80:M%=X%+cands_17
 1460IF?M%=&7F ANDM%?81=&C0 PROCwrt_digit(C%,R%,0)ELSEPROCdisp_cont(X%)
 1470NEXT:CLS:ENDPROC
 1480DEFPROCexport
 1490LOCALF$,L$,R%,C%,I%,D%
 1500PRINT"Filename ";:INPUTF$
 1510PRINT"Line (";L%;")";:INPUTL$:IFL$>"0"L%=VALL$
 1520ONERRORGOTO1660
 1530IFF$>""OSCLI"SPOOL "+F$
 1540I%=0:FORR%=0TO8:PRINTRIGHT$("    "+STR$L%,5);:L%=L%+10
 1550FORC%=0TO8:IFC%PRINT",";ELSEPRINT"DATA";
 1560D%=FNsolved(I%):I%=I%+1:PRINT;D%;
 1570NEXT:PRINT:NEXT
 1580*SP.
 1590ONERROROFF
 1600CLS:ENDPROC
 1610DEFPROChelp
 1620PRINTTAB(0,3)CHR$131"ZX*/"CHR$135"move cursor "CHR$131"0"CHR$135"clear digit"CHR$131"1-9"CHR$135"place digit  "CHR$131"SPACE"CHR$135"advance";
 1630PRINTCHR$131"R"CHR$134"ight"CHR$131"D"CHR$134"own"CHR$135"after placing"
 1640PRINTCHR$131"P"CHR$135"ossible"CHR$131"S"CHR$135"ave"CHR$131"L"CHR$135"oad"CHR$131"E"CHR$135"xport";
 1650ENDPROC
 1660ONERROROFF
 1670*SP.
 1680REPORT:PRINT" at line ";ERL;" *SPOOL off"
 1690END
 2000T%=TIME:PROCginit
 2010PRINT"Starting line (FIRST) ";:INPUTL$:IFL$>"0"RESTOREVALL$
 2020CALLreset_grid:I%=0
 2030FORR%=0TO8
 2040FORC%=0TO8
 2050READD%
 2060IFD%=0GOTO2090
 2070PROCset_digit(I%,D%)
 2080PROCelim_out(I%,D%)
 2090I%=I%+1
 2100NEXT
 2110NEXT
 2120PRINT'"Press"CHR$129"f3"CHR$135"to solve puzzle.":END
 3000T%=TIME
 3010IFW%W%=FALSE:*SP.O.SOLVE
 3020PROCdump_grid
 3030REPEAT
 3040os%=?solved
 3050PROCsolve_all
 3060UNTIL?solved=81OR?solved=os%
 3070IF?solved=81PROCtest_int
 3080PRINT"Finished (";?solved;"/81) in ";(TIME-T%)/100;" sec."
 3090*SP.
 3100END
 4000DEFFNsolved(X%)=USRtest_solved AND&F
 4010DEFPROCdisp_pos(X%)
 4020CALLdisp_pos:ENDPROC
 4030DEFFNhex(V%,L%)=RIGHT$(STRING$(L%,"0")+STR$~V%,L%)
 4040DEFPROCshow_set(Y%)
 4050CALLshow_set:ENDPROC
 4060DEFPROCtally_set
 4070CALLtally_set:ENDPROC
 4080DEFFNtest_cand(X%,A%)=(USRtest_cand AND&2000000)=0
 4090DEFFNpeek(M%):LOCALV%
 4100V%=!M%AND&FFFF
 4110=V%
 4120DEFPROCpoke(M%,V%)
 4130!M%=!M%AND&FFFF0000 ORV%AND&FFFF
 4140ENDPROC
 4150DEFFNsee(X%,Y%)
 4160LOCALU%:U%=USRget_see
 4170=(U%AND&2000000)=0
 4180DEFPROCginit
 4190LOCALY%:VDU22,7
 4200FORY%=0TO17:VDU31,0,Y%,151:NEXT
 4210FORY%=0TO2:VDU31,32,Y%+22,146,154,31,32,Y%+19,147,154:NEXT
 4220VDU28,0,24,31,18,23,0,10,32,0;0;0;
 4230ENDPROC
 4240DEFPROCset_digit(X%,A%)
 4250REMPRINT"Pos ";X%;" ";:PROCdisp_pos(X%):PRINT" becomes ";A%;":"
 4260CALLset_digit
 4270ENDPROC
 4280DEFPROCwrt_digit(X%,Y%,A%)
 4290CALLwrt_digit:ENDPROC
 4300DEFPROCclr_digit(X%)
 4310CALLclr_digit:ENDPROC
 4320DEFPROCdisp_cont(X%)
 4330CALLdisp_cont:ENDPROC
 4340DEFPROCelim_out(X%,A%)
 4350CALLelim_out:ENDPROC
 4360DEFPROCreset_tally
 4370CALLreset_tally:ENDPROC
 4380DEFPROCtally
 4390LOCALI%:FORI%=0TO9:PRINT;I%?cand_count;" ";:NEXT:PRINT
 4400ENDPROC
 4410DEFFNcell(Y%)
 4420LOCALU%:U%=USRget_cell:=(U%AND&2000000)=0
 4430DEFPROCfill_set(A%)
 4440CALLfill_set:ENDPROC
 4450DEFPROCelim_in(X%)
 4460CALLelim_in:ENDPROC
 4470DEFPROCelim_set
 4480CALLelim_set:ENDPROC
 4490DEFPROCdisp_cands(X%)
 4500LOCALM%,B%,C%,I%,J%
 4510C%=cands_17?X%*256+cands_89v?X%
 4520PROCdisp_pos(X%):PRINT"=";
 4530IFC%AND&8000PRINT"*";C%AND&0F;"*      ":GOTO4590
 4540B%=&4000:J%=9:FORI%=1TO9
 4550REMPRINTFNhex(B%,4);" ";FNhex(C%,4)
 4560IFC%ANDB%PRINT;I%;:J%=J%-1
 4570B%=B%DIV2:NEXT
 4580PRINTSTRING$(J%," ")
 4590ENDPROC
 4600DEFPROCinit_alt1
 4610CALLinit_alt1:ENDPROC
 4620DEFPROCshow_alt(Y%)
 4630CALLshow_alt:ENDPROC
 4640DEFPROCand_seen(X%)
 4650CALLand_seen:ENDPROC
 4660DEFFNtest_alt=(USRtest_alt AND&2000000)=0
 4670DEFPROCman_elim_ext(D%)
 4680LOCALA%,X%,Y%,I%,J%
 4690PROCinit_alt_d(D%):PROCshow_alt(66)
 4700FORI%=0TO80
 4710IFFNcell(I%)=0GOTO4730
 4720IFFNtest_cand(I%,D%)PROCand_seen(I%):PROCshow_alt(66):IFFNtest_alt=0I%=80
 4730NEXT
 4740IFFNtest_alt=0GOTO4780
 4750FORI%=0TO80
 4760IFFNalt(I%)PROCelim_cand(I%,D%)
 4770NEXT
 4780ENDPROC
 4800DEFFNalt(Y%)
 4810LOCALU%:U%=USRget_alt:=(U%AND&2000000)=0
 4820DEFPROCelim_cand(X%,A%)
 4830CALLelim_cand:ENDPROC
 4840DEFPROCand_digit(A%)
 4850CALLand_digit:ENDPROC
 4860DEFPROCinit_alt_d(A%)
 4870CALLinit_alt_d:ENDPROC
 4880DEFPROCelim_ext(A%)
 4890CALLelim_ext:ENDPROC
 4900DEFPROCdisp_grp
 4910CALLdisp_grp:ENDPROC
 4920DEFPROCshow_rcs
 4930LOCALI%:FORI%=0TO8:PRINTFNhex(I%?pos07,2);FNhex(I%?pos8,2);" ";:NEXT
 4940PRINT:ENDPROC
 4950DEFPROCdump_grid
 4960ENDPROC:REMCALLdump_grid:ENDPROC
 4970DEFPROCtest_int
 4980CALLtest_int:ENDPROC
 4990DEFPROCsolve_grp
 5000CALLsolve_grp:ENDPROC
 5010DEFPROCsolve_all
 5020CALLsolve_all:ENDPROC
 8000DATA0,0,0,2,0,0,6,0,0
 8010DATA0,5,0,9,0,0,0,7,0
 8020DATA0,1,0,0,8,0,5,0,0
 8030DATA2,0,0,0,0,0,0,0,0
 8040DATA0,4,5,0,0,3,2,0,7
 8050DATA0,0,7,0,0,9,3,0,0
 8060DATA0,0,0,8,9,0,0,0,0
 8070DATA0,0,0,0,0,0,0,5,0
 8080DATA9,0,1,4,0,7,0,0,0
 8100REM..METRO 20230516 H..
 8110DATA0,0,2,0,7,0,0,0,0
 8120DATA0,1,0,0,0,3,2,0,7
 8130DATA0,9,0,0,0,5,0,0,6
 8140DATA0,0,4,0,1,0,0,0,5
 8150DATA0,0,0,7,0,9,0,0,0
 8160DATA1,0,0,0,5,0,3,0,0
 8170DATA8,0,0,5,0,0,0,6,0
 8180DATA9,0,3,6,0,0,0,5,0
 8190DATA0,0,0,0,2,0,7,0,0
 8200REM..METRO 20230516 M..
 8210DATA0,0,0,2,1,9,0,0,0
 8220DATA0,0,3,0,5,0,9,0,0
 8230DATA0,9,7,0,0,0,8,5,0
 8240DATA7,0,0,5,0,4,0,0,9
 8250DATA5,3,0,0,0,0,0,7,4
 8260DATA6,0,0,3,0,1,0,0,2
 8270DATA0,5,2,0,0,0,4,6,0
 8280DATA0,0,6,0,9,0,2,0,0
 8290DATA0,0,0,7,6,2,0,0,0
 8300REM..PAD PUZZLE ****..
 8310DATA6,5,0,0,0,0,3,0,0
 8320DATA0,0,0,0,0,5,9,0,0
 8330DATA7,0,0,0,0,6,0,8,0
 8340DATA0,0,0,0,3,0,4,9,2
 8350DATA2,0,1,0,0,7,0,6,0
 8360DATA8,0,0,0,0,0,0,0,0
 8370DATA0,0,0,0,0,9,0,0,0
 8380DATA0,0,6,1,0,0,0,7,8
 8390DATA1,0,8,0,0,0,0,0,0
 8500REM..TATOOINE SUNSET..
 8510DATA0,0,0,0,0,0,0,0,0
 8520DATA0,0,9,8,0,0,0,0,7
 8530DATA0,8,0,0,6,0,0,5,0
 8540DATA0,5,0,0,4,0,0,3,0
 8550DATA0,0,7,9,0,0,0,0,2
 8560DATA0,0,0,0,0,0,0,0,0
 8570DATA0,0,2,7,0,0,0,0,9
 8580DATA0,4,0,0,5,0,0,6,0
 8590DATA3,0,0,0,0,6,2,0,0
 9000DATA9,6,0,0,8,0,0,4,0
 9010DATA0,0,0,0,0,0,0,0,0
 9020DATA4,0,0,0,0,6,7,0,8
 9030DATA0,0,9,0,0,7,0,5,3
 9040DATA0,0,0,0,6,0,0,2,0
 9050DATA0,2,0,0,0,5,0,0,0
 9060DATA1,0,0,9,4,0,0,8,0
 9070DATA8,5,0,0,0,0,0,1,4
 9080DATA0,0,0,0,5,0,0,0,7
 9100DATA1,0,2,0,0,0,5,0,3
 9110DATA0,0,0,9,0,8,0,0,0
 9120DATA0,3,0,0,0,0,0,4,0
 9130DATA0,9,0,0,8,0,7,0,0
 9140DATA0,0,0,5,0,9,0,0,0
 9150DATA0,0,3,0,4,0,0,1,0
 9160DATA0,7,0,0,0,0,0,5,0
 9170DATA0,0,0,2,0,1,0,0,0
 9180DATA8,0,9,0,0,0,6,0,7
10000REM.. T.EL0001 ..
10010DATA0,0,3,0,0,0,0,8,0
10020DATA0,5,0,1,0,0,0,0,6
10030DATA6,0,0,0,0,7,4,0,0
10040DATA0,0,8,0,9,0,0,4,0
10050DATA7,0,0,0,0,5,0,0,0
10060DATA0,1,0,6,0,0,8,0,0
10070DATA0,0,0,9,0,0,0,2,0
10080DATA0,0,0,0,2,0,0,0,8
10090DATA0,0,2,0,0,0,3,0,4
10100REM.. T.EL0002 ..
10110DATA0,2,0,4,0,0,0,8,0
10120DATA0,0,0,0,8,0,0,0,6
10130DATA8,0,0,0,0,7,1,0,0
10140DATA2,0,0,5,0,0,0,9,0
10150DATA0,9,5,0,0,0,0,0,0
10160DATA0,4,0,0,3,0,0,0,0
10170DATA0,0,0,0,0,1,0,0,7
10180DATA0,0,2,8,0,0,0,4,0
10190DATA0,0,0,0,6,0,3,0,0
10200REM.. T.EL0003 ..
10210DATA0,0,3,0,0,0,0,8,0
10220DATA0,5,0,0,0,0,2,0,1
10230DATA7,0,0,0,0,0,0,0,0
10240DATA0,0,0,5,0,8,0,0,6
10250DATA0,9,0,1,2,0,0,0,0
10260DATA8,0,0,0,0,3,0,0,0
10270DATA0,6,0,9,0,0,0,0,5
10280DATA0,0,4,0,0,0,0,7,0
10290DATA0,0,0,0,1,0,6,0,2
10300REM.. T.EL0004 ..
10310DATA0,0,3,0,0,6,0,8,0
10320DATA0,0,0,1,0,0,2,0,0
10330DATA0,0,0,0,7,0,0,0,4
10340DATA0,0,9,0,0,8,0,6,0
10350DATA0,3,0,0,4,0,0,0,1
10360DATA0,7,0,2,0,0,0,0,0
10370DATA3,0,0,0,0,5,0,0,0
10380DATA0,0,5,0,0,0,6,0,0
10390DATA9,8,0,0,0,0,0,5,0
10400REM.. T.EL0005 ..
10410DATA1,0,0,0,0,0,0,0,9
10420DATA0,0,6,7,0,0,0,2,0
10430DATA0,8,0,0,0,0,4,0,0
10440DATA0,0,0,0,7,5,0,3,0
10450DATA0,0,5,0,0,2,0,0,0
10460DATA0,6,0,3,0,0,0,0,0
10470DATA0,9,0,0,0,0,8,0,0
10480DATA6,0,0,0,4,0,0,0,1
10490DATA0,0,2,5,0,0,0,6,0
10500REM.. T.EL0006 ..
10510DATA1,0,0,0,0,6,0,8,0
10520DATA0,0,0,7,0,0,1,0,0
10530DATA0,0,0,0,0,0,5,0,6
10540DATA0,0,9,0,4,0,0,0,0
10550DATA0,7,0,2,0,0,0,3,0
10560DATA8,0,0,0,0,7,6,0,0
10570DATA3,0,0,0,0,1,0,0,5
10580DATA0,4,0,9,0,0,0,0,0
10590DATA0,0,2,0,7,0,0,0,0
10600REM.. T.EL0007 ..
10610DATA0,0,0,4,0,0,0,8,9
10620DATA0,0,7,0,0,9,2,0,0
10630DATA0,0,0,0,3,0,0,0,5
10640DATA2,6,0,0,0,1,0,0,0
10650DATA0,0,1,9,0,0,0,0,0
10660DATA7,0,0,0,0,0,1,0,0
10670DATA5,0,0,0,9,0,0,4,0
10680DATA0,0,6,0,0,2,9,0,0
10690DATA0,0,0,8,0,0,0,0,3
10700REM.. T.EL0008 ..
10710DATA0,0,0,0,0,0,0,0,9
10720DATA4,0,0,0,0,9,2,0,0
10730DATA0,0,0,0,7,0,0,4,5
10740DATA0,0,1,0,3,0,0,0,0
10750DATA0,7,0,6,0,0,9,0,0
10760DATA8,0,0,0,0,7,0,0,2
10770DATA0,3,0,7,0,0,8,0,0
10780DATA0,0,6,0,1,0,0,0,0
10790DATA9,0,0,0,0,5,0,2,0
10800REM.. T.EL0009 ..
10810DATA0,0,0,4,0,0,0,8,0
10820DATA0,0,7,0,0,9,2,0,0
10830DATA0,0,0,0,3,0,0,0,5
10840DATA2,6,0,0,0,1,0,0,0
10850DATA0,0,1,9,0,0,0,0,0
10860DATA0,7,0,0,0,0,1,0,0
10870DATA5,0,0,0,0,0,0,4,0
10880DATA0,1,0,8,0,0,0,0,3
10890DATA0,0,6,0,0,2,9,0,0
10900REM.. T.EL0010 ..
10910DATA0,2,0,4,0,0,7,0,0
10920DATA0,0,6,0,0,0,0,0,1
10930DATA7,0,0,0,3,0,0,0,0
10940DATA0,0,5,0,0,0,0,6,0
10950DATA0,4,0,2,0,0,9,0,0
10960DATA0,0,0,0,0,5,0,0,8
10970DATA0,0,1,0,0,8,0,0,0
10980DATA0,9,0,0,7,0,0,0,0
10990DATA0,0,0,9,2,0,3,0,0
11000REM.. T.17CELLS ..
11010DATA0,0,0,0,0,0,0,1,0
11020DATA0,0,0,0,0,2,0,0,3
11030DATA0,0,0,4,0,0,0,0,0
11040DATA0,0,0,0,0,0,5,0,0
11050DATA4,0,1,6,0,0,0,0,0
11060DATA0,0,7,1,0,0,0,0,0
11070DATA0,5,0,0,0,0,2,0,0
11080DATA0,0,0,0,8,0,0,4,0
11090DATA0,3,0,9,1,0,0,0,0
11100REM.. T.BIGED ..
11110DATA0,0,0,0,0,0,0,0,9
11120DATA0,0,0,0,0,1,0,3,5
11130DATA0,0,3,0,9,0,0,6,0
11140DATA0,0,5,0,3,0,0,0,6
11150DATA0,7,0,0,0,2,0,0,0
11160DATA1,0,0,4,0,0,0,0,0
11170DATA0,0,9,0,8,0,0,5,0
11180DATA0,2,0,7,0,0,0,0,0
11190DATA4,0,0,0,0,0,8,0,0
11200REM.. T.HARD1 ..
11210DATA0,0,0,0,0,0,0,0,8
11220DATA0,0,3,0,0,0,4,0,0
11230DATA0,9,0,0,2,0,0,6,0
11240DATA0,0,0,0,7,9,0,0,0
11250DATA0,0,0,0,6,1,2,0,0
11260DATA0,6,0,5,0,2,0,7,0
11270DATA0,0,8,0,0,0,5,0,0
11280DATA0,1,0,0,0,0,0,2,0
11290DATA4,0,5,0,0,0,0,0,3
11300REM.. T.HARD2 ..
11310DATA0,0,0,0,0,0,0,3,9
11320DATA0,0,0,0,0,1,0,0,5
11330DATA0,0,3,0,5,0,8,0,0
11340DATA0,0,8,0,9,0,0,0,6
11350DATA0,7,0,0,0,2,0,0,0
11360DATA1,0,0,4,0,0,0,0,0
11370DATA0,0,9,0,8,0,0,5,0
11380DATA0,2,0,0,0,0,6,0,0
11390DATA4,0,0,7,0,0,0,0,0
11400REM.. T.HARDEST ..
11410DATA8,0,0,0,0,0,0,0,0
11420DATA0,0,3,6,0,0,0,0,0
11430DATA0,7,0,0,9,0,2,0,0
11440DATA0,5,0,0,0,7,0,0,0
11450DATA0,0,0,0,4,5,7,0,0
11460DATA0,0,0,1,0,0,0,3,0
11470DATA0,0,1,0,0,0,0,6,8
11480DATA0,0,8,5,0,0,0,1,0
11490DATA0,9,0,0,0,0,4,0,0
