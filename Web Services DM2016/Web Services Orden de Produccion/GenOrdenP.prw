#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"

#Define CLRF CHAR(13) + CHAR(10)

//************************************************************************************************************************************************************************
User Function GenOrdenP(CODPRODOP,CANTIDOP,FECHINIOP,FECHFINOP,FECHAORDP,CONSIDSUBSTRUCT,EMITIO,REVISO,AUTORIZO,NUMSOLIFLU)
//************************************************************************************************************************************************************************

Local aMATA650:= {}       //-Array com os campos
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ 3 - Inclusao     ³
//³ 4 - Alteracao    ³
//³ 5 - Exclusao     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nOpc:= 3
Local cProd:= CODPRODOP
Local nCant:= val(CANTIDOP)
Local dOpIni:= stod(FECHINIOP)
Local dOpFin:= stod(FECHFINOP)
Local dOprod:= stod(FECHAORDP)
Local cConsSub:= alltrim(CONSIDSUBSTRUCT)

Local cEmitio:= EMITIO
Local cReviso:= REVISO
Local cAutorizo:= AUTORIZO
Local cNumSoliFlu:= NUMSOLIFLU

Local cRet:= ""
Local cLoteCtl:= ""
Local lParOpi:= GetMV("MV_GERAOPI") //T=Crea Todo - F=No crea todo, solo 1er nivel.
Local lOrigOpi:= GetMV("MV_GERAOPI") //Guarda Valor Original.
Local cQuerrrry	:= ""
Local Querrrry:= "QUERRRRYTO"
Local cXML:= '<?xml version="1.0" encoding="UTF-8"?>' + CLRF
Private lMsErroAuto:= .T. //.F.

If 	cConsSub$"SI|NO" .or. empty(cConsSub)
	//NO ||Crea el producto sin subestructuras
	//SI ||Crea la orden con subestructuras
	if cConsSub=="SI" .or. cConsSub=="S"
		lIs:= .T. //cConsSub:= "S"
		if lParOpi == .F.
			//No cambia parámetro
		Else //
			//Cambia parámetro a .F.
			AlteraX6(".F.")
		Endif
		
		//MV_GERAOPI:= "N"
	Elseif cConsSub=="NO" .or. cConsSub=="N" .or. empty(cConsSub)
		lIs:= .F. //cConsSub:= "N"
		
		if lParOpi == .T.
			//No cambia parámetro
		Else //
			//Cambia parámetro a .T.
			AlteraX6(".T.")
		Endif
		
	Endif
	
	//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"
    cTipo:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_TIPO")
	IF cTipo == "PI"
		cLoteCtl:= GenLote(cProd,dOprod,dOpIni,dOpFin)	    
	EndIf

	aMata650  := {  {'C2_FILIAL'   	,"0101" ,NIL},;
	{'C2_PRODUTO'  	,cProd     		,NIL},;
	{'C2_QUANT'    	,nCant			,NIL},;
	{'C2_DATPRI'	,dOPIni			,NIL},;
	{'C2_DATPRF'    ,dOpFin			,NIL},;
	{'C2_EMISSAO'	,dOProd			,NIL},;
	{'C2_LOTECTL'	,cLoteCtl       ,NIL},;
	{'C2_EMITIO'	,cEmitio		,NIL},;
	{'C2_REVISO'	,cReviso		,NIL},;
	{'C2_AUTORI'	,cAutorizo		,NIL},;
	{'C2_NSFLU'		,cNumSoliFlu	,NIL},;
	{'AUTEXPLODE'	,"S"			,NIL}}
	
	ConOut("Inicio  : "+Time())
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se alteracao ou exclusao, deve-se posicionar no registro     ³
	//³ da SC2 antes de executar a rotina automatica                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	/*
	If nOpc == 4 .Or. nOpc == 5
	SC2->(DbSetOrder(1)) // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
	SC2->(DbSeek(xFilial("SC2")+"000097"+"01"+"002"))
	EndIf
	*/
	msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Aqui esta creada la orden de produccion
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//Llenado del XML
	If lMsErroAuto
		cOrPr:= SC2->C2_NUM
		cLoteCtl:=""
		cXML += '<OrdenProduccion Cod="'+cOrPr+'">' + CLRF
		cQuerrrry:= " Select D4_OP,D4_COD,D4_LOTECTL "
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
				
          		if alltrim(evalTipo(alltrim(cCodD4))== 'PI'
          			cLoteCtl:= D4_LOTECTL
          		endif

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
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
		//Actualiza la Autoexplosión con el número de lote
		cUpd:= " UPDATE "+RetSQLName("SC2")+" "
		cUpd+= " Set C2_LOTECTL = '"+cLoteCtl+"'"
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
	EndIf
	
	//Deja valor inicial del Parámetro MV_GERAOPI
	if lOrigOpi
		AlteraX6(".T.")
	Else
		AlteraX6(".F.")
	endif
	//+++++++++++++++++++++++++++++++++++++++++++
	ConOut("Fin  : "+Time())
else
	cRet:= "Considera Sub-Estructuras: Respuesta No válida: S/N"
Endif
//RESET ENVIRONMENT
Return cRet

//***********************************************************************************************************************************************
Static Function GenLote(cProdf,dOprodf,dOpInif,dOpFinf)
//************************************************************************************************************************************************
cProdLot:= cProdf
dFechG:= dOprodf //Tipo Date -> 
dFechI:= dOpInif //Tipo Date -> 
dFechE:= dOpFinf //Tipo Date -> 
cRetLot:= ""

//Lógica para la generación de lotes en automático
cTipo:= Posicione("SB1",1,xFilial("SB1")+cProdLot,"B1_TIPO")

cMes:= MONTH(DATE())
cAnio:= cValToChar(YEAR(dFechG)) //Tipo Date //dFechaG ->Tipo 
ctablaLotes:="TABLALOTES"
nlotes:=""
cConse:=""

aMesLetra := Nil
cMesLetra := ""


//+----------------------------------------------------------------------------+
//|Exemplifica o uso da função Array                                           |
//+----------------------------------------------------------------------------+
aMesLetra := Array(1, 12)
aMesLetra[1] := {"A","B","C","D","E","F","G","H","I","J","K","L","N"}
cMesLetra += cValToChar(aMesLetra[1][cMes])

cQueryResul:= "SELECT COUNT(*) REGA FROM "+RetSQLName("ZOP")+" WHERE YEAR(ZOP_FHE) = '"+cAnio+"' AND D_E_L_E_T_ <>'*'" //Tipo String
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryResul),ctablaLotes,.T.,.T.)

nlotes:= (ctablaLotes)->REGA
(ctablaLotes)->(dbCloseArea())	

//colocaNumero,numero de zeros, colocar 0´s
cConse:= STRZERO(nlotes+1, 3, 0)

//LOTE/MES/AÑO/CONSECUTIVO
cRetLot:=""+cMesLetra+RIGHT(cAnio,2)+cConse

dbSelectArea("ZOP")
RECLOCK("ZOP",.T.)
 
ZOP->ZOP_FILIAL:= xFilial("ZOP")   // Retorna a filial de acordo com as configurações do ERP Protheus
ZOP->ZOP_ID:= "01"
ZOP->ZOP_TIPO:= cTipo
ZOP->ZOP_NLOTES:= cRetLot    //Nombre del lote
ZOP->ZOP_ENTREGAG:= dFechG   //Fecha de Generacion de Orden de Produccion
ZOP->ZOP_FECHAI:= dFechI     //Fecha de Inicio
ZOP->ZOP_FHE:= dFechE     //Fecha de Entrega
MSUNLOCK()// Destrava o registro

Return cRetLot

//******************************************************************************************************************************************
Static function AlteraX6(cResp)
//******************************************************************************************************************************************
dbSelectArea("SX6")
dbSetOrder(1)

If dbSeek(xFilial("SX6")+"MV_GERAOPI",.T.)
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD	:= cResp
	SX6->X6_CONTSPA := cResp
	SX6->X6_CONTENG := cResp
	MsUnlock()
endif

//dbCloseArea("SX6")

Return

Static function evalTipo(cCodD4)
 cTipo:= Posicione("SB1",1,xFilial("SB1")+cCodD4,"B1_TIPO")
return cTipo
/*
SD4 REQUISICIONES RESERVADAS
*/