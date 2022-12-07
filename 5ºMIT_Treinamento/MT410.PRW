#include 'protheus.ch'

User Function MT410TOK()
	Local lRet := .T. // Conteudo de retorno
	Local nOpc := PARAMIXB[1] // Opcao de manutencao

	UptRegs(nOpc)

Return lRet

static function UptRegs(nOpc)
	//db variaveis
	local aArea     := GetArea()
	local cAlias    := 'Z02'
	local nAcolsLen := len(acols)
	local nIndex    := 0

	for nIndex := 1 to nAcolsLen
		dbSelectArea(cAlias)

		reclock(cAlias, .T.)
		Z02->Z02_FILIAL := '01'
		Z02->Z02_CODVEN := M->C5_VEND1
		Z02->Z02_NUMPED := M->C5_NUM

		//acols e aheader
		Z02->Z02_ITEMPV := alltrim(acols[nIndex][1])
		Z02->Z02_PROD   := alltrim(acols[nIndex][2])
		Z02->Z02_DESC   := alltrim(acols[nIndex][24])
		Z02->Z02_VALOR  := acols[nIndex][6]
		Z02->Z02_USR    := LogUserName()

		if nOpc == 3
			Z02->Z02_STATUS := 'I'
		elseif nOpc == 1
			Z02->Z02_STATUS := 'E'
		endif
		msUnlock()
	next
	

restArea(aArea)
return
