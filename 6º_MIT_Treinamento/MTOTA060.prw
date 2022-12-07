#include 'protheus.ch'

User Function MTOTA060()
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := ''
    Local cIdPonto   := ''
    Local cIdModel   := ''

    If aParam <> NIL
        oObj       := aParam[1]
        cIdPonto   := aParam[2]
        cIdModel   := aParam[3]
        
            If cIdPonto == 'MODELVLDACTIVE' .and. z03->z03_status == '2' .and. oObj:getOperation() == 4
                Help( ,, 'Help',, 'Não é possivel alterar registros fechados', 1, 0 )
                xRet := .f.
            endif
    endif
Return xRet
