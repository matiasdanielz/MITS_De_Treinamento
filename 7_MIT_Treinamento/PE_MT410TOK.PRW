#include 'protheus.ch'

User Function MT410TOK()
    Local lRet := .T. // Conteudo de retorno
    Local cLockUsr := superGetMV('FB_ZUSER') 
    //Local nOpc := PARAMIXB[1] // Opcao de manutencao

    if alltrim(Usrfullname()) == cLockUsr
        lRet := .f.
        alert('O usu�rio Microsiga n�o tem permiss�o para incluir Pedidos de Venda.')
    endif
Return(lRet)
