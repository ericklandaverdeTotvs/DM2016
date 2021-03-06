#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
 
User Function DELETEOrdenP(PRODUTO,NUM,ITEM,SEQUEN)
Local aMATA650:={} //-Array com os campos
//旼컴컴컴컴컴컴컴컴커
//� 3 - Inclusao     �
//� 4 - Alteracao    �
//� 5 - Exclusao     �
//읕컴컴컴컴컴컴컴컴켸
Local nOpc:= 5

Local cProd:= PRODUTO
Local cNum:= NUM
Local cItem:= ITEM
Local cSequen:= SEQUEN
//Local cXML:= '<?xml version="1.0" encoding="UTF-8"?>' + CLRF

Private lMsErroAuto:= .F.
 
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0101"
 
aMata650  := {  {'C2_FILIAL'   ,"0101"                ,NIL},;
                {'C2_PRODUTO'  ,cProd		          ,NIL},;          
                {'C2_NUM'      ,cNum                  ,NIL},;          
                {'C2_ITEM'     ,cItem                 ,NIL},;          
                {'C2_SEQUEN'   ,cSequen               ,NIL}}             
                 
ConOut("Inicio  : "+Time())
  
//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
//� Se alteracao ou exclusao, deve-se posicionar no registro     �
//� da SC2 antes de executar a rotina automatica                 �
//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸
If nOpc == 4 .Or. nOpc == 5
    SC2->(DbSetOrder(1)) // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
    SC2->(DbSeek(xFilial("SC2")+cNum+cItem+cSequen))
EndIf
     
msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
If !lMsErroAuto
    ConOut("Sucesso! ")
    //cXML += '<EstadoSI>''</EstadoSI>'+ CLRF
Else
    ConOut("Erro!")
    MostraErro()
    //cXML += '<EstadoNO>''</EstadoNO>'+ CLRF
EndIf
 
ConOut("Fim  : "+Time())
 
//RESET ENVIRONMENT
 Return Nil