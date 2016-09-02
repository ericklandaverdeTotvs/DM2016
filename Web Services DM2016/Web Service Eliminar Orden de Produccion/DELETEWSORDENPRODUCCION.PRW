#include "totvs.ch"
#include "apwebsrv.ch"

WSSERVICE DELETEWSORDENPRODUCCION DESCRIPTION "Web Services Eliminar Ordenes de Produccion"
	WSDATA C2_PRODUTO as string
	WSDATA C2_NUM as string
	WSDATA C2_ITEM as string
	WSDATA C2_SEQUEN as string

	WSDATA DELETEORDENP as string
	WSMETHOD DELETEORDENPRODUCCION DESCRIPTION "Elimina Ordenes de Produccion" //
ENDWSSERVICE 
                   
WSMETHOD DELETEORDENPRODUCCION WSRECEIVE C2_PRODUTO,C2_NUM,C2_ITEM,C2_SEQUEN WSSEND DELETEORDENP WSSERVICE DELETEWSORDENPRODUCCION
Private lexist:= .T.                                                                                                
	::DELETEORDENP:= U_DELETEOrdenP(C2_PRODUTO,C2_NUM,C2_ITEM,C2_SEQUEN)
RETURN lexist

/*
SC2 Ordenes de Produccion
SB1 Descripcion Generica de Producto
SB2 Saldo Fisico Y Financiero
SB8 Saldos por Lote
*/