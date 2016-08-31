#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"

#Define CLRF CHAR(13) + CHAR(10)
//************************************************************************************************************************************************* 
User Function DELETEOrdenP(C2_PRODUTOPADRE) 
            //U_DELETEOrdenP
//*************************************************************************************************************************************************

Local aMATA650:= {}       //-Array com os campos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Inclusao     ³
//³ 4 - Alteracao    ³
//³ 5 - Exclusao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpc:= 5
Local cOrPr:= C2_PRODUTOPADRE
Private lMsErroAuto     := .F.

//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"

aMata650  := {  {'C2_FILIAL'   	,"0101" ,NIL},;
	{'C2_NUM'	,cOrPr		,NIL}}
 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se alteracao ou exclusao, deve-se posicionar no registro     ³
//³ da SC2 antes de executar a rotina automatica                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If nOpc == 4 .Or. nOpc == 5
    SC2->(DbSetOrder(1)) // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
    SC2->(DbSeek(xFilial("SC2")+"000097"+"01"+"002"))
EndIf*/
    cOrPr:= SC2->C2_NUM 
	msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
	
	/*If lMsErroAuto
		cOrPr:= SC2->C2_NUM
		cXML += '<OrdenProduccion Cod="'+cOrPr+'">' + CLRF
		cQuerrrry:= " Select D4_OP,D4_COD "
		cQuerrrry+= " From "+RetSQLName("SD4")+" "
		cQuerrrry+= " where D4_FILIAL = '"+xFilial("SD4")+"' "
		cQuerrrry+= " and substring(D4_OP,1,6) = '"+cOrPr+"' "
		cQuerrrry+= " and D_E_L_E_T_ <>'*' "
		cQuerrrry+= " order by D4_OP, D4_COD "
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuerrrry),Querrrry,.T.,.T.)
		
		while (Querrrry)->(!EOF())
			cItemOP:= (Querrrry)->D4_OP
			cXML += '<OP Item="'+Alltrim(cItemOP)+'">'+ CLRF
			cXML += '<Productos>'+ CLRF
			while (Querrrry)->D4_OP == cItemOP
				cCodD4:= (Querrrry)->D4_COD
				cXML += '<Producto>'+alltrim(cCodD4)+'</Producto>'+ CLRF
				(Querrrry)->(dbskip())
			enddo
			cXML += '</Productos>'+ CLRF
			cXML += '<Lote>'+cLoteCtl+'</Lote>'+ CLRF
			cXML += '</OP>'
		enddo
		
		(Querrrry)->(dbCloseArea())	//Cierra Querrrry
		
		cXML += '</OrdenProduccion>'
		cRet:= cXML
		ConOut("Concluido con exito")
		
		//Actualiza la Autoexplosión con el número de lote
		cUpd:= " UPDATE "+RetSQLName("SC2")+" "
		cUpd+= " Set C2_LOTECTL = '"+cLoteCtl+"' "
		cUpd+= " where C2_FILIAL = '"+xFilial("SC2")+"' "
		cUpd+= " and C2_NUM = '"+cRet+"' "
		cUpd+= " and D_E_L_E_T_ <>'*' "
		
		IF TcSqlExec(cUpd) <> 0 //o
			MSGALERT(TCSQLERROR())
		endif
	Else
		ConOut("Error!")
		cRet:= "NO GENERADA"
		MostraErro()
	EndIf*/

If !lMsErroAuto
    ConOut("Sucesso! ")
Else
    ConOut("Erro!")
    MostraErro()
EndIf
 
ConOut("Fim  : "+Time())
 
//RESET ENVIRONMENT
 
Return 

//SaldoSB2(.T., , ,lConsTerc,lConsNPT)+SB2->B2_SALPEDI-SB2->B2_QEMPN+AvalQtdPre("SB2",2)