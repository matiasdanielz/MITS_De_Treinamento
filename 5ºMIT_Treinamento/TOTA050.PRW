#include 'protheus.ch'

/*
author carlos.simon
since 04/11/2022
return variant, return_description
*/
user function Tota050()
    local cAlias      := 'Z02'
    LOCAL aCores      :={{ 'Z02->Z02_STATUS=="I"' , 'ENABLE'},; // Ativo
                         {'Z02->Z02_STATUS=="E"'  , 'DISABLE'}} // Inativo

    private cCadastro := 'Logs de registro'
    private aRotina   :={}

    AADD(aRotina, { 'Visualizar', 'AxVisual'  , 0, 2 })
    
    dbSelectArea(cAlias)
    dbSetOrder(1)
    mBrowse(,,,,cAlias,,,,,,aCores,,,,,,,,)

    return
