#include 'protheus.ch'
#include 'FWMVCDef.ch'

user function TOTA060()
    local cAlias  := 'Z03'
    local oBrowse
    private aRotina := MenuDef()

    //Instancia do mbrowse
    oBrowse := FWMBrowse():New()

    //Setando a tabela de solicitacao de materiais como padrao
    oBrowse:SetAlias(cAlias)

    oBrowse:AddLegend( "Z03->Z03_STATUS == '1'", "GREEN")
    oBrowse:AddLegend( "Z03->Z03_STATUS == '2'", "RED")

    //Setando a descricao da rotina
    oBrowse:SetDescription('Titulo')

    //Ativa a browse
    oBrowse:Activate()
    return

static function MenuDef()
    Local aRot := {}
    ADD OPTION aRot Title 'Visualizar' Action 'VIEWDEF.TOTA060' OPERATION 2 ACCESS 0
    ADD OPTION aRot Title 'Incluir' Action 'VIEWDEF.TOTA060' OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRot Title 'Alterar' Action 'VIEWDEF.TOTA060' OPERATION isOpen() ACCESS 0
    ADD OPTION aRot Title 'Excluir' Action 'VIEWDEF.TOTA060' OPERATION 5 ACCESS 0
    Return aRot

static function isOpen()
    if Z03->Z03_STATUS == '1'
        return 4
    else
        return
    endif 

static function ModelDef()
    Local aZ03Rel  := {}
    local oModel
    Local oStruZ03 := FWFormStruct( 1, 'Z03' , {|cCampo| AllTRim(cCampo) $ "Z03_COD;Z03_USER;Z03_NOME;Z03_DATA;Z03_STATUS"})
    local oStSon   := FWFormStruct(1, 'Z03' , {|cCampo| AllTRim(cCampo) $ "Z03_ITEM;Z03_PROD;Z03_DESC;Z03_QTD;Z03_VAL;Z03_TOTAL;"})

    //Cria a instancia do model
    oModel := MPFormModel():New('MTOTA060')

    oModel:AddFields('FORMCAB',, oStruZ03)
    oModel:AddGrid('Z03Detail', 'FORMCAB', oStSon)

    //Seta a chave primaria do browse
    oModel:SetPrimaryKey({'Z03_FILIAL','Z03_COD'})

    aAdd(aZ03Rel, {'Z03_FILIAL', "xFilial('Z03')"})
    aAdd(aZ03Rel, {'Z03_COD', "Z03_COD"})

    oModel:SetRelation('Z03Detail', aZ03Rel, Z03->(IndexKey(1)))

    //Seta a descricao do model
    oModel:SetDescription('Modelo de dados do cadastro')

    oModel:GetModel('FORMCAB'):SetDescription('Contato' )
    oModel:GetModel('Z03Detail'):SetDescription('Detalhamento de produtos')

    return oModel

static function ViewDef()
    local oModel   := FWLoadModel( 'TOTA060' )
    Local oStruZ03 := FWFormStruct( 2, 'Z03' , {|cCampo| AllTRim(cCampo) $ "Z03_COD;Z03_USER;Z03_NOME;Z03_DATA;Z03_STATUS"})
    local oStSon   := FWFormStruct(2, 'Z03' , {|cCampo| AllTRim(cCampo) $ "Z03_ITEM;Z03_PROD;Z03_DESC;Z03_QTD;Z03_VAL;Z03_TOTAL;"})
    local oView    := FWFormView():New()

    oView:SetModel(oModel)

    oView:AddField('VIEW_CAB', oStruZ03, 'FORMCAB' )
    oView:AddGrid('VIEW_Z03', oStSon, 'Z03Detail')

    oView:AddIncrementField('VIEW_Z03', 'Z03_ITEM')

    oView:CreateHorizontalBox('CABEC', 30)
    oView:CreateHorizontalBox('Grid', 70)

    oView:SetOwnerView('VIEW_CAB', 'CABEC')
    oView:SetOwnerView('VIEW_Z03', 'Grid')

    oView:EnableTitleView("VIEW_CAB","Contato")
    oView:EnableTitleView("VIEW_Z03","Detalhamento de produtos")

    return oView
