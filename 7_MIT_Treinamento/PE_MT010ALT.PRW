#include 'protheus.ch'
#include 'Tbiconn.ch'
#include "parmtype.ch"
#include "TopConn.ch"

User Function MT010ALT()
    setData()
Return

static function setData()
    Local aArea  := GetArea()
    local cAlias := 'Z05'

    dbSelectArea("Z05")
    Z05->(dbSetOrder(1))
    Z05->(DbGoTop())

    //RECLOCK
    RecLock(cAlias, .T.)
    Z05->Z05_CODUSR := RetCodUsr()
    Z05->Z05_DATA   := DATE()
    Z05->Z05_DESC   := M->B1_DESC
    Z05->Z05_HORA   := TIME()
    Z05->Z05_NOME   := Usrfullname()
    Z05->Z05_PROD   := M->B1_COD
    Z05->Z05_STATUS := 'A'
    msunlock()

    restArea(aArea)
    return
