#include "totvs.ch"
#include "apwebsrv.ch"

WSSERVICE DELETEWSORDENPRODUCCION DESCRIPTION "Web Services Eliminar Ordenes de Produccion"
	WSDATA C2_PRODUTOPADRE as string  
	WSDATA DELETEORDENP as string
	WSMETHOD DELETEORDENPRODUCCION DESCRIPTION "Elimina Ordenes de Produccion" //
ENDWSSERVICE 
                   
WSMETHOD DELETEORDENPRODUCCION WSRECEIVE C2_PRODUTOPADRE WSSEND DELETEORDENP WSSERVICE DELETEWSORDENPRODUCCION
Private lexist:= .T.                                                                                                
	::DELETEORDENP:= U_DELETEOrdenP(C2_PRODUTOPADRE)
RETURN lexist

/*
SB1 Descripcion Generica de Producto
SB2 Saldo Fisico Y Financiero
SB8 Saldos por Lote
*/