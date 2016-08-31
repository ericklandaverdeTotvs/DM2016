#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"

User Function genTabla()

dbSelectArea("ZOP") 
RECLOCK("ZOP", .T.)
 
ZOP->ZOP_FILIAL:= xFilial("ZOP")   // Retorna a filial de acordo com as configurações do ERP Protheus

MSUNLOCK()//Destrava o registro
Return