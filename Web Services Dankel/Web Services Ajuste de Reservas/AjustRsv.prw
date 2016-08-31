#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
#include "TbiConn.ch"

User Function AjustRsv(ORDENPRODUCCION,PRODUCTO,CANTIDADAJUSTE)

Local nT:= TamSX3("D4_COD")[1] //Tama�o del campo de Producto -->16
Local cOrdPrd:= ORDENPRODUCCION
Local cProdut:= PRODUCTO
Local nQtdAjs:= val(CANTIDADAJUSTE)
Local aVetor := {}
Local aEmpen := {}
Local nOpc   := 4 //Altera//3-Inclusao//5-Excluye
Local cQry	 := ""
Local cDat	 := "DATOSF4"
Local cRet	 := ""

nTr:= len(alltrim(cProdut))	//Tama�o real
nEs:= nT-nTr //Espacios a aumentar
cProdut:= alltrim(cProdut)+space(nEs)
cTipo:= Posicione("SB1",1,xFilial("SB1")+cProdut,"B1_TIPO")
cUm:= Posicione("SB1",1,xFilial("SB1")+cProdut,"B1_UM")
cDescUM:= alltrim(Posicione("SAH",1,xFilial("SAH")+cUm,"AH_DESCES"))

if !empty(Posicione("SB1",1,xFilial("SB1")+cProdut,"B1_COD"))
	
	//If cTipo == "MP"//Original
	//If cTipo == .T.
		//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01" MODULO "EST"

		cQry:= " Select * from "+RetSQLName("SD4")+" "
		cQry+= " Where D4_FILIAL = '"+xFilial("SD4")+"' "
		cQry+= " and substring(D4_OP,1,6) = '"+cOrdPrd+"' "
		cQry+= " and D4_COD = '"+alltrim(cProdut)+"' "
		cQry+= " and D_E_L_E_T_ <>'*' "
		dbUseArea( .T., "TOPCONN ", TCGENQRY(,,cQry),cDat, .F., .T.)

		if (cDat)->(!EOF())
			cOP:= (cDat)->D4_OP
			cTrt:= (cDat)->D4_TRT
			lMsErroAuto:= .F.
			nCntOrg:= (cDat)->D4_QTDEORI
			
			if nCntOrg > nQtdAjs
				
				aVetor:={{"D4_COD"	,cProdut    ,Nil},; //COM O TAMANHO EXATO DO CAMPO	//{"D4_LOCAL"   ,"01"             ,Nil},;
				{"D4_OP"            ,cOP		,Nil},;
				{"D4_DATA"          ,dDatabase  ,Nil},;
				{"D4_QUANT"         ,nQtdAjs	,Nil},;
				{"D4_QTDEORI"       ,nQtdAjs    ,Nil},;
				{"D4_TRT"           ,cTrt       ,Nil},;
				{"D4_QTSEGUM"       ,0          ,Nil}}
			Else
				aVetor:={{"D4_COD"	,cProdut    ,Nil},; //COM O TAMANHO EXATO DO CAMPO	//{"D4_LOCAL"   ,"01"             ,Nil},;
				{"D4_OP"            ,cOP		,Nil},;
				{"D4_DATA"          ,dDatabase  ,Nil},;
				{"D4_QTDEORI"       ,nQtdAjs    ,Nil},;
				{"D4_QUANT"         ,nQtdAjs	,Nil},;
				{"D4_TRT"           ,cTrt       ,Nil},;
				{"D4_QTSEGUM"       ,0          ,Nil}}
			Endif
			
			MSExecAuto({|x,y,z| mata380(x,y,z)},aVetor,nOpc/*,aEmpen*/)
			
			If lMsErroAuto
				Alert("Erro")
				cRet:= MostraErro()
			Else
				cRet:= "Ajuste a "+cValtoChar(nQtdAjs)+" "+cDescUM+" del producto:"+cProdut+" de la OP: "+cOP+" con EXITO!."
			EndIf
		Else
			cRet:= "No existen Orden de Producci�n y/o Producto informado, VERIFIQUE!"
		EndIf
		(cDat)->(dbCloseArea())
	//else
		//cRet:= cProdut+" NO es materia prima!"
	//Endif
Else
	cRet:= "No existe el Producto!"
Endif

Return cRet