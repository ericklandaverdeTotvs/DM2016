#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "stdwin.ch"

#Define CLRF CHAR(13) + CHAR(10)

User Function WSGNDK(CodPrd,CantLot,Familia)

Local cStructure:= ""
Local cProd:= CodPrd
Local nCantLt:= val(CantLot)
Local cProdPadr:= CodPrd

Local cQry1,cQry2,cQry3,cQry4,cQry5,cQry6,cQry7,cQry8,cQry9,cQry0,cQryQB,cQrySaldoReserv:= ""

Local cTab1:= "TAB01"
Local cTab2:= "TAB02"
Local cTab3:= "TAB03"
Local cTab4:= "TAB04"
Local cTab5:= "TAB05"
Local cTab6:= "TAB06"
Local cTab7:= "TAB07"
Local cTab8:= "TAB08"
Local cTab9:= "TAB09"
Local cTab0:= "TAB00"
Local cTabQB:= "TABQB"
Local cTabSaldoRes := "cTabSaldoRes"

Local nQB:=  0
Local nVeces:= 1
Local nNumEstr:= 0
Local n2Numestr:= 0
Local nCantNec1,nCantNec2,nCantNec3,nCantNec4,nCantNec5:= 0
Local nSaldoB8:= 0
Local nDif:= 0
Local nNvoEstr:= 99999
Local n2NvoEstr:= 99999
Local aLotes:= ""
Local nId:= 0
Local nOcupa:= 0
Local nV,x,cQB:= 0
Local nFormula:= 0
Local nSaldoRes:= 0


Local cXML := '<?xml version="1.0" encoding="UTF-8"?>' + CLRF
cXML += '<EstructurasProduccion>' + CLRF

//++++++++++++++++++++++++++++++++++++++++ INICIO ++++++++++++++++++++++++++++++++++++++++++++++++++++++//
nQB:=  nCantLt
// nQB:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_QB") * nCantLt
//Parámetros para generar solo un nivel de Orden de Producción: MV_GERASC
//Considera PG
//	--> SI = MV_GERAOPI = .F.
//	--> NO = MV_GERAOPI = .T. 
//++++++++++++++++++++++++++++++++++++++++ CALCULO ++++++++++++++++++++++++++++++++++++++++++++++++++++++//

//Seleccioname todo de la tabla SG1 (Estructuras) donde el codigo (G1_COD) sea igual al codigo digitado
cQry1:= " Select * from "+RetSQLName("SG1")+" "
cQry1+= " where G1_COD = '"+cProd+"' "
cQry1+= " and D_E_L_E_T_ <>'*' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),cTab1,.T.,.T.)

cQryQB:= " Select B1_QB from "+RetSQLName("SB1")+" "
cQryQB+=" where B1_COD = '"+cProd+"' "
cQryQB+=" and D_E_L_E_T_ <>'*' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryQB),cTabQB,.T.,.T.)


if (cTab1)->(!EOF())
	for nV:= 1 to 5
		(cTab1)->(dbgotop())
		while (cTab1)->(!EOF())
			nFactor:= nQB
			cProd:= (cTab1)->G1_COD
			cComp:= (cTab1)->G1_COMP
			cQB:= (cTabQB)->B1_QB 
			nCantNec1:= cQB
			nSaldoB8:= ExistSdo(cComp)
			nDif:= nSaldoB8 - nCantNec1
			n2Numestr:= nSaldoB8/nCantNec1
			cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
			cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
			cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
			
			if n2Numestr < n2NvoEstr .and. cTip <>"PI"// .and. ctip <>"PA"
				n2NvoEstr:= n2Numestr
			endif
			
			//+++++++++++++Codigo recurrente+++++++++++++++++++++//
			cQry2:= " Select * from "+RetSQLName("SG1")+" "
			cQry2+= " where G1_COD = '"+cComp+"' "
			cQry2+= " and D_E_L_E_T_ <>'*' "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cTab2,.T.,.T.)
			while (cTab2)->(!EOF())
				nFactor:= nCantNec1
				cProd:= (cTab2)->G1_COD
				cComp:= (cTab2)->G1_COMP
				nCantNec2:= (cTab2)->G1_QUANT//*nFactor
				nSaldoB8:= ExistSdo(cComp)
				nDif:= nSaldoB8 - nCantNec2
				n2Numestr:= nSaldoB8/nCantNec2
				cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
				cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
				cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
				if n2Numestr < n2NvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
					n2NvoEstr:= n2Numestr
				endif
				//-->
				//+++++++++++++Codigo recurrente+++++++++++++++++++++//
				cQry3:= " Select * from "+RetSQLName("SG1")+" "
				cQry3+= " where G1_COD = '"+cComp+"' "
				cQry3+= " and D_E_L_E_T_ <>'*' "
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry3),cTab3,.T.,.T.)
				while (cTab3)->(!EOF())
					nFactor:= nCantNec2
					cProd:= (cTab3)->G1_COD
					cComp:= (cTab3)->G1_COMP
					nCantNec3:= (cTab3)->G1_QUANT//*nFactor
					nSaldoB8:= ExistSdo(cComp)
					nDif:= nSaldoB8 - nCantNec3
					n2Numestr:= nSaldoB8/nCantNec3
					cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
					cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
					cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
					if n2Numestr < n2NvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
						n2NvoEstr:= n2Numestr
					endif
					//-->
					//+++++++++++++Codigo recurrente+++++++++++++++++++++//
					cQry4:= " Select * from "+RetSQLName("SG1")+" "
					cQry4+= " where G1_COD = '"+cComp+"' "
					cQry4+= " and D_E_L_E_T_ <>'*' "
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry4),cTab4,.T.,.T.)
					while (cTab4)->(!EOF())
						nFactor:= nCantNec3
						cProd:= (cTab4)->G1_COD
						cComp:= (cTab4)->G1_COMP
						nCantNec4:= (cTab4)->G1_QUANT//*nFactor
						nSaldoB8:= ExistSdo(cComp)
						nDif:= nSaldoB8 - nCantNec4
						n2Numestr:= nSaldoB8/nCantNec4
						cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
						cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
						cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
						if n2Numestr < n2NvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
							n2NvoEstr:= n2Numestr
						endif
						//-->
						//+++++++++++++Codigo recurrente+++++++++++++++++++++//
						cQry5:= " Select * from "+RetSQLName("SG1")+" "
						cQry5+= " where G1_COD = '"+cComp+"' "
						cQry5+= " and D_E_L_E_T_ <>'*' "
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry5),cTab5,.T.,.T.)
						while (cTab5)->(!EOF())
							nFactor:= nCantNec4
							cProd:= (cTab5)->G1_COD
							cComp:= (cTab5)->G1_COMP
							nCantNec5:= (cTab5)->G1_QUANT//*nFactor
							nSaldoB8:= ExistSdo(cComp)
							nDif:= nSaldoB8 - nCantNec5
							n2Numestr:= nSaldoB8/nCantNec5
							cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
							cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
							cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
							if n2Numestr < n2NvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
								n2NvoEstr:= n2Numestr
							endif
							//-->
							
							//-->
							(cTab5)->(dbskip())
						enddo
						(cTab5)->(dbCloseArea())
						//+++++++++++++Codigo recurrente+++++++++++++++++++++//
						//-->
						(cTab4)->(dbskip())
					enddo
					(cTab4)->(dbCloseArea())
					//+++++++++++++Codigo recurrente+++++++++++++++++++++//
					//-->
					(cTab3)->(dbskip())
				enddo
				(cTab3)->(dbCloseArea())
				//+++++++++++++Codigo recurrente+++++++++++++++++++++//
				//-->
				(cTab2)->(dbskip())
			enddo
			(cTab2)->(dbCloseArea())
			//+++++++++++++Codigo recurrente+++++++++++++++++++++//
			(cTab1)->(dbskip())
		enddo
	next
	(cTab1)->(dbCloseArea())
	//n2NvoEstr
endif

//+++++++++++++++++++++++++++++++++++++++  FIN CALCULO  +++++++++++++++++++++++++++++++++++++++++++++++++//

cQry1:= " Select * from "+RetSQLName("SG1")+" "
cQry1+= " where G1_COD = '"+cProd+"' "
cQry1+= " and D_E_L_E_T_ <>'*' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry1),cTab1,.T.,.T.)

cQrySaldoReserv:= " Select SUM(D4_QTDEORI) SALDO from "+RetSQLName("SD4")+" "
cQrySaldoReserv+= " where D4_COD = '"+cProd+"' "
cQrySaldoReserv+= " and D_E_L_E_T_ <>'*' "
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySaldoReserv),cTabSaldoRes,.T.,.T.)

nSaldoRes:=(cTabSaldoRes)->SALDO

if (cTab1)->(!EOF())
    cXML += ''+ CLRF //Salto de linea
	cXML += '<ProductoPrincipal>'+ CLRF
	cXML += '<CodigoProd>' + alltrim(cProd) + '</CodigoProd>'+ CLRF
	cXML += '<Descripcion>' + alltrim(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC")) + '</Descripcion>'+ CLRF
	cXML += '<CantSolicitada>' + cValtoChar(nCantLt) + '</CantSolicitada>'+ CLRF
	cXML += '<CantDisponible>' + cValtoChar(n2NvoEstr) + '</CantDisponible>'+ CLRF
	cXML += '<CantBase>' + cValtoChar(cQB) + '</CantBase>'+ CLRF
	cXML += '<SaldoRestante>' + cValtoChar(nSaldoRes) + '</SaldoRestante>'+ CLRF
	if n2NvoEstr >= nCantLt
		cProc:= "SI"
	else
		cProc:= "NO"
	endif
	cXML += '<Procede>' + cProc + '</Procede>'+ CLRF
	//if n2NvoEstr >= nCantLt
	cXML += ''+ CLRF //Salto de linea
	cXML += '<Componentes>'

	for nV:= 1 to 5
		(cTab1)->(dbgotop())
		while (cTab1)->(!EOF())
			nFactor:= nQB
			cProd:= (cTab1)->G1_COD
			cComp:= (cTab1)->G1_COMP
			nFormula:=(cTab1)->G1_QUANT
			nCantNec1:= nFormula*nFactor/cQB
			nSaldoRes:=saldosRes(cComp)
			nSaldoB8:= ExistSdo(cComp)
			nDif:= nSaldoB8 - nCantNec1
			nNumEstr:= nSaldoB8/nCantNec1
			cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
			cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
			cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
			if nNumEstr < nNvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
				nNvoEstr:= nNumEstr
			endif
			cNivAct:= strzero(nV,2)
			if cNivAct = "01"
				//if cTip =="PI" .and. ctip <>"PA"
				nId+=1
				cXML += '<Componente Id="'+strzero(nId,3)+'">'+ CLRF
				cXML += '<CodigoComp>' + alltrim(cComp) + '</CodigoComp>' + CLRF
				cXML += '<Descripcion>' + alltrim(Posicione("SB1",1,xFilial("SB1")+cComp,"B1_DESC")) + '</Descripcion>'+ CLRF
				cXML += '<CodigoPadre>' +alltrim(cProd)+'</CodigoPadre>' + CLRF
				cXML += '<Formula>' +cValtoChar(nFormula)+'</Formula>' + CLRF //Nuevo
				cXML += '<UM>' +alltrim(cUM)+'</UM>' + CLRF //Nuevo
				cXML += '<Familia>' +alltrim(cTip)+'</Familia>' + CLRF //Nuevo
				cXML += '<CantidadRequerida>' + cValtoChar(nCantNec1) + '</CantidadRequerida>' + CLRF
				cXML += '<Saldo>'+cValtochar(nSaldoB8)+'</Saldo>'+ CLRF
				cXML += '<SaldoRes>'+cValtochar(nSaldoRes)+'</SaldoRes>'+ CLRF
				cXML += '<Resultado>'+cValtochar(nSaldoRes)+'</Resultado>'+ CLRF //Nuevo
				if nDif < 0
					cXML += '<Faltante>'+ cValtochar(abs(nDif))+'</Faltante>'+ CLRF
					cXML += ''+ CLRF //Salto de linea
				endif
				if nDif>=0
					nOcupa:= nCantNec1
					cXML += '<Lotes>'
					aLotes:= UseLotes(cComp)
					for x:= 1 to len(aLotes)
						cXML += '<Lote Num="'+alltrim(aLotes[x,1])+'">'+ CLRF
						cXML += '<FechaLote>' +(aLotes[x,2])  + '</FechaLote>'+ CLRF	//Fecha
						cXML += '<Orden>' + cValtochar(aLotes[x,3]) + '</Orden>'+ CLRF	//Orden
						cXML += '<SaldoLote>' + cValtochar(aLotes[x,4]) + '</SaldoLote>'
						cXML += '</Lote>'
						nOcupa:= nOcupa-aLotes[x,4]
						if nOcupa<=0
							exit
						Endif
					Next
					cXML += '</Lotes>'+ CLRF
					cXML += ''+ CLRF //Salto de linea
				endif
				cXML += '</Componente>'
			endif
			//+++++++++++++ Codigo recurrente +++++++++++++++++++++//
			/*cQry2:= " Select * from "+RetSQLName("SG1")+" "
			cQry2+= " where G1_COD = '"+cComp+"' "
			cQry2+= " and D_E_L_E_T_ <>'*' "
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cTab2,.T.,.T.)
			while (cTab2)->(!EOF())    
				nFactor:= nQB
				cProd:= (cTab2)->G1_COD //Codigo del producto
				cComp:= (cTab2)->G1_COMP //Codigo del Componente
				nFormula:= (cTab2)->G1_QUANT //Formula
				nCantNec2:= nFormula*nFactor/cQB //Cantidad Necesaria
				nSaldoRes:=saldosRes(cComp) //Saldo restante
				nSaldoB8:= ExistSdo(cComp) //Saldo B8
				nDif:= nSaldoB8 - nCantNec2 //Diferencia
				nNumEstr:= nSaldoB8/nCantNec2
				cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
				cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
				cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
				if nNumEstr < nNvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
					nNvoEstr:= nNumEstr
				endif
				cNivAct:= strzero(nV,2)
				//+++++++++++++ Se imprime el codigo +++++++++++++++++++++//
				if cNivAct = "02"
					//if cTip <>"PI" .and. ctip <>"PA"
					nId+=1
					cXML += '<Componente Id= "'+strzero(nId,3)+'">'+ CLRF
					cXML += '<CodigoComp>' + alltrim(cComp) + '</CodigoComp>' + CLRF
					cXML += '<Descripcion>' + alltrim(Posicione("SB1",1,xFilial("SB1")+cComp,"B1_DESC")) + '</Descripcion>'+ CLRF
					cXML += '<CodigoPadre>' +alltrim(cProd)+'</CodigoPadre>'+ CLRF
					cXML += '<Formula>' +cValtoChar(nFormula)+'</Formula>' + CLRF //Nuevo
					cXML += '<UM>' +alltrim(cUM)+'</UM>' + CLRF //Nuevo
					cXML += '<Familia>' +alltrim(cTip)+'</Familia>' + CLRF //Nuevo
					cXML += '<CantidadRequerida>' + cValtoChar(nCantNec2) + '</CantidadRequerida>'+ CLRF
					cXML += '<Saldo>'+cValtochar(nSaldoB8)+'</Saldo>'+ CLRF
					cXML += '<SaldoRes>'+cValtochar(nSaldoRes)+'</SaldoRes>'+ CLRF 
					cXML += '<Resultado>'+cValtochar(nSaldoRes)+'</Resultado>'+ CLRF //Nuevo
					if nDif < 0
						cXML += '<Faltante>'+ cValtochar(abs(nDif))+'</Faltante>'+ CLRF
					Endif
					if nDif>=0
						nOcupa:= nCantNec2
						cXML += ''+ CLRF
						cXML += '<Lotes>'
						aLotes:= UseLotes(cComp)
						for x:= 1 to len(aLotes)
							cXML += '<Lote Num= "'+alltrim(aLotes[x,1])+'">'+ CLRF
							cXML += '<FechaLote>' +(aLotes[x,2])  + '</FechaLote>'+ CLRF	//Fecha
							cXML += '<Orden>' + cValtochar(aLotes[x,3]) + '</Orden>'+ CLRF	//Orden
							cXML += '<SaldoLote>' + cValtochar(aLotes[x,4]) + '</SaldoLote>' + CLRF //Saldo
							cXML += '</Lote>'
							nOcupa:= nOcupa-aLotes[x,4]
							if nOcupa<=0
								exit
							Endif
						Next
						cXML += '</Lotes>'
					Endif
					cXML += '</Componente>'+ CLRF
					//endif
				endif
				//-->
				//+++++++++++++Codigo recurrente+++++++++++++++++++++//
				cQry3:= " Select * from "+RetSQLName("SG1")+" "
				cQry3+= " where G1_COD = '"+cComp+"' "
				cQry3+= " and D_E_L_E_T_ <>'*' "
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry3),cTab3,.T.,.T.)
				while (cTab3)->(!EOF())
					nFactor:= nQB
					cProd:= (cTab3)->G1_COD //Codigo del producto
					cComp:= (cTab3)->G1_COMP //Codigo del Componente
					nFormula:= (cTab3)->G1_QUANT //Formula
					nCantNec3:= nFormula*nFactor/cQB //Cantidad Necesaria
					nSaldoRes:=saldosRes(cComp) //Saldo restante
					nSaldoB8:= ExistSdo(cComp) //Saldo B8
					nDif:= nSaldoB8 - nCantNec3  //Diferencia
					nNumEstr:= nSaldoB8/nCantNec3
					cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
					cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
					cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
					if nNumEstr < nNvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
						nNvoEstr:= nNumEstr
					endif
					cNivAct:= strzero(nV,2)
					if cNivAct = "03"
						//if cTip <>"PI" .and. ctip <>"PA"
						nId+=1
						cXML += '<Componente Id= "'+strzero(nId,3)+'">'+ CLRF
						cXML += '<CodigoComp>' + alltrim(cComp) + '</CodigoComp>' + CLRF
						cXML += '<Descripcion>' + alltrim(Posicione("SB1",1,xFilial("SB1")+cComp,"B1_DESC")) + '</Descripcion>'+ CLRF
						cXML += '<CodigoPadre>' +alltrim(cProd)+'</CodigoPadre>'+ CLRF
						cXML += '<Formula>' +cValtoChar(nFormula)+'</Formula>' + CLRF //Nuevo
				     	cXML += '<UM>' +alltrim(cUM)+'</UM>' + CLRF //Nuevo
				    	cXML += '<Familia>' +alltrim(cTip)+'</Familia>' + CLRF //Nuevo
						cXML += '<CantidadRequerida>' + cValtoChar(nCantNec3) + '</CantidadRequerida>'+ CLRF
						cXML += '<Saldo>'+cValtochar(nSaldoB8)+'</Saldo>'+ CLRF
						cXML += '<SaldoRes>'+cValtochar(nSaldoRes)+'</SaldoRes>'+ CLRF
						cXML += '<Resultado>'+cValtochar(nSaldoRes)+'</Resultado>'+ CLRF //Nuevo
						if nDif < 0
							cXML += '<Faltante>'+ cValtochar(abs(nDif))+'</Faltante>'+ CLRF
						Endif
						if nDif>=0
							nOcupa:= nCantNec3
							cXML += ''+ CLRF
							cXML += '<Lotes>'
							aLotes:= UseLotes(cComp)
							for x:= 1 to len(aLotes)
								cXML += '<Lote Num= "'+alltrim(aLotes[x,1])+'">'+ CLRF
								cXML += '<FechaLote>' +(aLotes[x,2])  + '</FechaLote>'+ CLRF	//Fecha
								cXML += '<Orden>' + cValtochar(aLotes[x,3]) + '</Orden>'+ CLRF	//Orden
								cXML += '<SaldoLote>' + cValtochar(aLotes[x,4]) + '</SaldoLote>' + CLRF //Saldo
								cXML += '</Lote>'
								nOcupa:= nOcupa-aLotes[x,4]
								if nOcupa<=0
									exit
								Endif
							Next
							cXML += '</Lotes>'
						Endif
						cXML += '</Componente>'+ CLRF
						//endif
					endif
					//-->
					//+++++++++++++Codigo recurrente+++++++++++++++++++++//
					cQry4:= " Select * from "+RetSQLName("SG1")+" "
					cQry4+= " where G1_COD = '"+cComp+"' "
					cQry4+= " and D_E_L_E_T_ <>'*' "
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry4),cTab4,.T.,.T.)
					while (cTab4)->(!EOF())
						nFactor:= nQB
						cProd:= (cTab4)->G1_COD //Codigo del producto
						cComp:= (cTab4)->G1_COMP //Codigo del Componente
						nFormula:= (cTab4)->G1_QUANT //Formula
						nCantNec4:= nFormula*nFactor/cQB //Cantidad Necesaria
						nSaldoRes:=saldosRes(cComp) //Saldo restante
						nSaldoB8:= ExistSdo(cComp) //Saldo B8
						nDif:= nSaldoB8 - nCantNec4 //Diferencia
						nNumEstr:= nSaldoB8/nCantNec4
						cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
						cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
						cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
						if nNumEstr < nNvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
							nNvoEstr:= nNumEstr
						endif
						cNivAct:= strzero(nV,2)
						if cNivAct = "04"
							//if cTip <>"PI" .and. ctip <>"PA"
							nId+=1
							cXML += '<Componente Id= "'+strzero(nId,3)+'">'+ CLRF
							cXML += '<CodigoComp>' + alltrim(cComp) + '</CodigoComp>' + CLRF
							cXML += '<Descripcion>' + alltrim(Posicione("SB1",1,xFilial("SB1")+cComp,"B1_DESC")) + '</Descripcion>'+ CLRF
							cXML += '<CodigoPadre>' +alltrim(cProd)+'</CodigoPadre>'+ CLRF
							cXML += '<Formula>' +cValtoChar(nFormula)+'</Formula>' + CLRF //Nuevo
					        cXML += '<UM>' +alltrim(cUM)+'</UM>' + CLRF //Nuevo
					        cXML += '<Familia>' +alltrim(cTip)+'</Familia>' + CLRF //Nuevo
							cXML += '<CantidadRequerida>' + cValtoChar(nCantNec4) + '</CantidadRequerida>'+ CLRF
							cXML += '<Saldo>'+cValtochar(nSaldoB8)+'</Saldo>'+ CLRF
							cXML += '<SaldoRes>'+cValtochar(nSaldoRes)+'</SaldoRes>'+ CLRF
							cXML += '<Resultado>'+cValtochar(nSaldoRes)+'</Resultado>'+ CLRF //Nuevo
							if nDif < 0
								cXML += '<Faltante>'+ cValtochar(abs(nDif))+'</Faltante>'+ CLRF
							Endif
							if nDif>=0
								nOcupa:= nCantNec4
								cXML += ''+ CLRF
								cXML += '<Lotes>'
								aLotes:= UseLotes(cComp)
								for x:= 1 to len(aLotes)
									cXML += '<Lote Num= "'+alltrim(aLotes[x,1])+'">'+ CLRF
									cXML += '<FechaLote>' +(aLotes[x,2])  + '</FechaLote>'+ CLRF	//Fecha
									cXML += '<Orden>' + cValtochar(aLotes[x,3]) + '</Orden>'+ CLRF	//Orden
									cXML += '<SaldoLote>' + cValtochar(aLotes[x,4]) + '</SaldoLote>' + CLRF //Saldo
									cXML += '</Lote>'
									nOcupa:= nOcupa-aLotes[x,4]
									if nOcupa<=0
										exit
									Endif
								Next
								cXML += '</Lotes>'+ CLRF
							Endif
							cXML += '</Componente>'
							cXML += ''+ CLRF //Salto de linea
							//endif
						endif
						//-->
						//+++++++++++++Codigo recurrente+++++++++++++++++++++//
						cQry5:= " Select * from "+RetSQLName("SG1")+" "
						cQry5+= " where G1_COD = '"+cComp+"' "
						cQry5+= " and D_E_L_E_T_ <>'*' "
						dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry5),cTab5,.T.,.T.)

						while (cTab5)->(!EOF())
							nFactor:= nQB
							cProd:= (cTab5)->G1_COD //Codigo del producto
							cComp:= (cTab5)->G1_COMP //Codigo del Componente
							nFormula:= (cTab5)->G1_QUANT //Formula
							nCantNec4:= nFormula*nFactor/cQB //Cantidad Necesaria
							nSaldoRes:=saldosRes(cComp) //Saldo restante
							nSaldoB8:= ExistSdo(cComp) //Saldo B8
							nDif:= nSaldoB8 - nCantNec5 //Diferencia
							nNumEstr:= nSaldoB8/nCantNec5
							cUM:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_UM")
							cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUM,"AH_DESCES"))
							cTip:= Posicione("SB1",1,xFilial("SB1")+cComp,"B1_TIPO")
							if nNumEstr < nNvoEstr //.and. cTip <>"PI" .and. ctip <>"PA"
								nNvoEstr:= nNumEstr
							endif
							cNivAct:= strzero(nV,2)
							if cNivAct = "05"
								//if cTip <>"PI" .and. ctip <>"PA"
								nId+=1
								cXML += '<Componente Id= "'+strzero(nId,3)+'">'+ CLRF
								cXML += '<CodigoComp>' + alltrim(cComp) + '</CodigoComp>' + CLRF
								cXML += '<Descripcion>' + alltrim(Posicione("SB1",1,xFilial("SB1")+cComp,"B1_DESC")) + '</Descripcion>'+ CLRF
								cXML += '<CodigoPadre>' +alltrim(cProd)+'</CodigoPadre>'+ CLRF
								cXML += '<Formula>' +cValtoChar(nFormula)+'</Formula>' + CLRF //Nuevo
					            cXML += '<UM>' +alltrim(cUM)+'</UM>' + CLRF //Nuevo
					            cXML += '<Familia>' +alltrim(cTip)+'</Familia>' + CLRF //Nuevo
								cXML += '<CantidadRequerida>' + cValtoChar(nCantNec5) + '</CantidadRequerida>'+ CLRF
								cXML += '<Saldo>'+cValtochar(nSaldoB8)+'</Saldo>'+ CLRF
								cXML += '<SaldoRes>'+cValtochar(nSaldoRes)+'</SaldoRes>'+ CLRF
								cXML += '<Resultado>'+cValtochar(nSaldoRes)+'</Resultado>'+ CLRF //Nuevo
								if nDif < 0
									cXML += '<Faltante>'+ cValtochar(abs(nDif))+'</Faltante>'+ CLRF
								Endif
								if nDif>=0
									nOcupa:= nCantNec5
									cXML += ''+ CLRF
									cXML += '<Lotes>'
									aLotes:= UseLotes(cComp)
									for x:= 1 to len(aLotes)
										cXML += '<Lote Num= "'+ alltrim(aLotes[x,1])+'">'+ CLRF
										cXML += '<FechaLote>' +(aLotes[x,2])  + '</FechaLote>'+ CLRF	//Fecha
										cXML += '<Orden>' + cValtochar(aLotes[x,3]) + '</Orden>'+ CLRF	//Orden
										cXML += '<SaldoLote>' + cValtochar(aLotes[x,4]) + '</SaldoLote>' + CLRF //Saldo
										cXML += '</Lote>'
										nOcupa:= nOcupa-aLotes[x,4]
										if nOcupa<=0
											exit
										Endif
									Next
									cXML += '</Lotes>'
								endif
								cXML += '</Componente>'
								//endif
							endif
							//-->
							
							//-->
							(cTab5)->(dbskip())
						enddo
						(cTab5)->(dbCloseArea())
						//+++++++++++++Codigo recurrente+++++++++++++++++++++//
						//-->
						(cTab4)->(dbskip())
					enddo
					(cTab4)->(dbCloseArea())
					//+++++++++++++Codigo recurrente+++++++++++++++++++++//
					//-->
					(cTab3)->(dbskip())
				enddo
				(cTab3)->(dbCloseArea())
				//+++++++++++++Codigo recurrente+++++++++++++++++++++//
				//-->
				(cTab2)->(dbskip())
			enddo
			(cTab2)->(dbCloseArea())*/
			//+++++++++++++Codigo recurrente+++++++++++++++++++++//
			(cTab1)->(dbskip())
		enddo
	next
	(cTab1)->(dbCloseArea())
	(cTabQB)->(dbCloseArea())

	cXML += '</Componentes>'+ CLRF
	//endif
	cXML += '</ProductoPrincipal>'+ CLRF
	cXML += '</EstructurasProduccion>' + CLRF
endif

cStructure:= cXML
msgalert(cXML)
Return cStructure

Static Function ExistSdo(cPrdComp)

Local cProdC:= cPrdComp
Local cFechBse:= dtos(ddatabase)
Local cQrySdo:= ""
Local cSdoB8:= "SDOB8"

cQrySdo:= " Select SUM(B8_SALDO-B8_EMPENHO-B8_QEMPPRE-B8_QACLASS) SALDO "
cQrySdo+= " from "+RetSQLName("SB8")+" "
cQrySdo+= " where B8_FILIAL = '"+xFilial("SB8")+"' "
cQrySdo+= " and B8_PRODUTO = '"+cProdC+"' "
cQrySdo+= " and B8_DTVALID >='"+cFechBse+"' "
cQrySdo+= " and B8_LOCAL <>'98' "
cQrySdo+= " and B8_SALDO-B8_EMPENHO-B8_QEMPPRE-B8_QACLASS <>0 "
cQrySdo+= " and D_E_L_E_T_ <>'*' "
dbUseArea( .T., "TOPCONN ", TCGENQRY(,,cQrySdo),cSdoB8, .F., .T.)
if (cSdoB8)->(!EOF())
	nSdoB8:= (cSdoB8)->SALDO
Else
	nSdoB8:= 0
endif
(cSdoB8)->(dbCloseArea())

Return nSdoB8

Static Function UseLotes(cPrdComp)

Local cProdLt := cPrdComp
Local cFechBse:= dtos(ddatabase)
Local cQryLote:= ""
Local cSdoLote:= "LOTES"
Local aDatos:= {}

cQryLote:= " Select B8_LOTECTL,B8_DATA,R_E_C_N_O_ REC,SUM(B8_SALDO-B8_EMPENHO-B8_QEMPPRE-B8_QACLASS) SALDO "
cQryLote+= " from "+RetSQLName("SB8")+" "
cQryLote+= " where B8_FILIAL = '"+xFilial("SB8")+"' "
cQryLote+= " and B8_PRODUTO = '"+cProdLt+"' "
cQryLote+= " and B8_DTVALID >='"+cFechBse+"' "
cQryLote+= " and B8_LOCAL <>'98' "
cQryLote+= " and B8_SALDO-B8_EMPENHO-B8_QEMPPRE-B8_QACLASS <>0 "
cQryLote+= " and D_E_L_E_T_ <>'*' "
cQryLote+= " group by B8_LOTECTL,B8_DATA,R_E_C_N_O_ "
cQryLote+= " order by B8_DATA,R_E_C_N_O_ "
dbUseArea( .T., "TOPCONN ", TCGENQRY(,,cQryLote),cSdoLote, .F., .T.)

(cSdoLote)->(dbgotop())
while (cSdoLote)->(!EOF())
	aadd(aDatos,{(cSdoLote)->B8_LOTECTL,(cSdoLote)->B8_DATA,(cSdoLote)->REC,(cSdoLote)->SALDO})
	(cSdoLote)->(dbskip())
enddo
(cSdoLote)->(dbCloseArea())

Return aDatos

Static Function saldosRes(cPrdComp)

Local cProdLt := cPrdComp
Local cFechBse:= dtos(ddatabase)
Local cQrySaldoReserv:= ""
Local cSaldoRes:= "SALDOSRES"
Local aSaldosRes:= {}

cQrySaldoReserv:= " Select SUM(D4_QTDEORI) SALDO from "+RetSQLName("SD4")+" "
cQrySaldoReserv+= " where D4_COD = '"+cProdLt+"' "
cQrySaldoReserv+= " and D_E_L_E_T_ <>'*' "

//Funcion verificar filtro entrada de productos
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySaldoReserv),cSaldoRes,.T.,.T.)
nSaldoRes:= (cSaldoRes)->SALDO
(cSaldoRes)->(dbCloseArea())

Return nSaldoRes