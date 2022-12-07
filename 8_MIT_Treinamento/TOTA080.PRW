#include 'protheus.ch'
#include 'FWMVCDef.ch'

user function tota080()
    local cAlias    := 'Z03'
    local oBrowse
    private aRotina := MenuDef()

    
    //Instancia do mbrowse
    oBrowse := FWMBrowse():New()

    //Setando a tabela de solicitacao de materiais como padrao
    oBrowse:SetAlias(cAlias)

    oBrowse:AddLegend("Z03->Z03_STATUS == '1'", "GREEN")
    oBrowse:AddLegend("Z03->Z03_STATUS == '2'", "RED")

    //Setando a descricao da rotina
    oBrowse:SetDescription('Titulo')

    //Ativa a browse
    oBrowse:Activate()
    return

static function MenuDef()
    Local aRot := {}
    ADD OPTION aRot Title 'Encerrar' Action 'VIEWDEF.TOTA080' OPERATION 2 ACCESS 0

    Return aRot

static function ViewDef()
    local aItems    := GetData()
    local cUserName := Usrfullname()
    local nUserId   := RetCodUsr()
    Local oNO       := LoadBitmap(GetResources(), 'br_vermelho' )
    Local oOK       := LoadBitmap(GetResources(), 'br_verde' )

    if len(aItems) >= 1
        //Janela de encerrar pedidos
            Define MsDialog oDialog;
            TITLE "Pedidos";
            From 0,0;
            To 400,700;
            PIXEL
        //Texto informando o codigo do usuario logado
            @ 02,10;
            SAY "Codigo do usuario logado no sistema";
            OF oDialog;
            PIXEL
        //Campo memo apresentando o codigo do usuario logado
            @ 10, 10;
            GET memoObject;
            var nUserId;
            of oDialog;
            SIZE 80, 10;
            COLORS 0, 16777215;
            PIXEL
        //Texto informando o nome do usuario logado
            @ 25,10;
            SAY;
            "Nome do usuario logado no sistema";
            OF oDialog;
            PIXEL
        //Campo memo apresentando o codigo do usuario logado
            @ 33, 10;
            GET memoObject;
            var cUserName;
            of oDialog;
            SIZE 80, 10;
            COLORS 0, 16777215;
            PIXEL
        //Texto informando o nome do usuario logado
            @ 02,170;
            SAY "Data de aprovacao";
            OF oDialog;
            PIXEL
        //Campo memo apresentando o codigo do usuario logado
            @ 10, 170;
            GET memoObject;
            var date();
            of oDialog;
            SIZE 80, 10;
            COLORS 0, 16777215;
            PIXEL
        //Texto informando o nome do usuario logado
            @ 25,170;
            SAY "Valor total";
            OF oDialog;
            PIXEL
        //Campo memo apresentando o codigo do usuario logado
            @ 33, 170;
            GET memoObject;
            var cUserName;
            of oDialog;
            SIZE 80, 10;
            COLORS 0, 16777215;
            PIXEL
        //Browse com todas as soliciações de pedidos
            oBrowse := TWBrowse():New(,,,,,,,oDialog,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)    
            oBrowse:nTop := 100
            oBrowse:nLeft := 02
            oBrowse:nHeight := 240
            oBrowse:nWidth := 698
            oBrowse:aHeaders := {'Status do pedido','Cod. requisicao','Cod. Requisitante', 'Nome Requisitante', 'Data', 'Valor total'}
            oBrowse:aColSizes := {20,40,60,60,30,20}
            oBrowse:SetArray(aItems)
            oBrowse:bLine := {||{If(aItems[oBrowse:nAt,01],oOK,oNO),aItems[oBrowse:nAt,02],aItems[oBrowse:nAt,03], aItems[oBrowse:nAt,04], aItems[oBrowse:nAt,05], aItems[oBrowse:nAt,06]}}    
            oBrowse:bLDblClick := {|| aItems[oBrowse:nAt][1] := !aItems[oBrowse:nAt][1],oBrowse:DrawSelect()}    
        //botao de sair
            @ 175, 300;
            BUTTON oCloseButton;
            PROMPT "Encerrar";
            SIZE 40,20; 
            ACTION (UptNewData(aItems),oDialog:End()) OF oDialog PIXEL
        
        ACTIVATE MSDIALOG oDialog
    else
        alert('Este registro ja esta encerrado')
    endif
    return

static function GetData()
    local aArea  := Z03->(GetArea())
    local aItem  := {}
    local aItems := {}

    BeginSql Alias "SQL_Z03"
        select
            Z03_STATUS,
            Z03_COD,
            Z03_USER,
            Z03_NOME,
            Z03_DATA,
            Z03_TOTAL
        FROM
            Z03990
        WHERE
            Z03_STATUS = 1
    EndSql

    While ! SQL_Z03->(EoF())
        AADD(aItem, Iif(SQL_Z03->Z03_STATUS == '1', .T., .F.))
        AADD(aItem, alltrim(SQL_Z03->Z03_COD))
        AADD(aItem, alltrim(SQL_Z03->Z03_USER))
        AADD(aItem, alltrim(SQL_Z03->Z03_NOME))
        AADD(aItem, Stod(SQL_Z03->Z03_DATA))
        AADD(aItem, CVALTOCHAR(SQL_Z03->Z03_TOTAL))

        AADD(aItems, aItem)
        aItem := {}
        SQL_Z03->(DbSkip())
    EndDo
    SQL_Z03->(DbCloseArea())

    restArea(aArea)
    return aItems

static function UptNewData(aArray)
    local aArea       := Z03->(GetArea())
    local aCldItems   := GetCldItems(aArray)
    local lenCldItems := len(aCldItems)
    local nIndex      := 0

    if lenCldItems != 0
        BeginSql Alias "SQL_Z03"
            select
                Z03_COD,
                Z03_STATUS,
                Z03_USRENC,
                Z03_DTENC
            FROM
                Z03990
        EndSql
        While ! SQL_Z03->(EoF())
            for nIndex := 1 to lenCldItems
                if Z03_COD = aCldItems[nIndex][2]
                    reclock('Z03',.f.)
                        Z03->Z03_STATUS := '2'
                        Z03->Z03_USRENC := Usrfullname()
                        Z03->Z03_DTENC := date()
                    Z03->(msunlock())
                endif
                SQL_Z03->(DbSkip())
            next
        EndDo
        SQL_Z03->(DbCloseArea())
    endif
    restArea(aArea)
    return

static function GetCldItems(aArray)
    local aCldItems := {}
    local nArryLen  := len(aArray)
    local nIndex    := 0

    for nIndex := 1 to nArryLen
        if aArray[nIndex][1] = .f.
            AADD(aCldItems, aArray[nIndex])
        endif
    next
    return aCldItems
