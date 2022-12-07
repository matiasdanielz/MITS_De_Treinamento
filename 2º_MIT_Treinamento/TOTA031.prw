#INCLUDE 'PROTHEUS.CH'
#Include 'FWMVCDef.ch'
#include 'TOPCONN.CH'

/*-----------------------------------------------*
 | Função: TOTA030                               |
 | Autor : D.Miguel                              |
 | Descr.: Exportar tabela de Produtos           |
 *-----------------------------------------------*/



User function TOTA030(cEmpresa)
    Static cTitulo   := "Exportação das Especificações Técnicas"
    Static nOpcao    := 0
    Static aButtons  := {}
    Static aSays     := {}
    Static cArea     := GetArea()
    Static cPerg  	 := Padr("TOTA030",10)
	//Local  cQuery	 :=""

    _ValidPerg(cPerg)


    AADD(aSays,OemToAnsi("Esta rotina exporta as especificações técnicas (SZF) Para um arquivo .TXT"))
    AADD(aSays,"")  
    AADD(aSays,OemToAnsi("Clique no botão PARAM para informar o arquivo que será Exportado."))
    AADD(aSays,"")  
    AADD(aSays,OemToAnsi("Após isso, clique no botão OK."))
    
	AADD(aButtons, { 5,.T.,{| | pergunte(cPerg,.T.)  } } ) 
    AADD(aButtons, { 2,.T.,{|o| nOpcao:= 2,o:oWnd:End()} } )
	AADD(aButtons, { 1,.T.,{|o| nOpcao:= 1,o:oWnd:End()} } )
    
    FormBatch( cTitulo, aSays, aButtons,,200,530 )

	

    if nOpcao == 1 
		Processa({|| fSalvArq()},"Aguarde....") 
	
    endif
    
    RestArea(cArea)
Return

/*-----------------------------------------------*
 | Função: fSalvArq                              |
 | Descr.: Função para gerar um arquivo texto    |
 *-----------------------------------------------*/

Static Function fSalvArq()
    Local cFileNom :='\x_arq_'+dToS(Date())+StrTran(Time(),":")+".txt"
    Local lOk      := .T.
	//Local cTime	   :=""
	Local cImprime :=""
	Local cEspaco  := "--------------------------------------------------------" + CRLF
    //Pegando o caminho do arquivo
    cFileNom := cGetFile( "Arquivo TXT *.txt | *.txt", "Arquivo .txt...",,'',.T., GETF_LOCALHARD)
	

    //Se o nome não estiver em branco    
    If !Empty(cFileNom)
        //Teste de existência do diretório
        If ! ExistDir(SubStr(cFileNom,1,RAt('\',cFileNom)))
            Alert("Diretório não existe:" + CRLF + SubStr(cFileNom, 1, RAt('\',cFileNom)) + "!")
            Return
        EndIf

//Query

	cQuery:= "SELECT " 
	cQuery+= "*	"		 + CRLF
	cQuery+= "FROM	"
	cQuery+= ""+RetSQLName("SB1")+ " SB1" + CRLF
	cQuery+= "WHERE "
	cQuery+= "SB1.B1_COD "
	cQuery+= "BETWEEN '"+ MV_PAR01+"' "
	cQuery+= "AND  '"+ MV_PAR02+"' " + CRLF
	cQuery+= "AND SB1.B1_TIPO "
	cQuery+= "BETWEEN '"+ Alltrim(MV_PAR03) +"' "
	cQuery+= "AND  '"+ Alltrim(MV_PAR04) +"' "	
	
	/*SELECT * FROM SB1990 SB1
	WHERE SB1.B1_COD BETWEEN '000000000000001' AND '000000000000003' 
	AND SB1.B1_TIPO BETWEEN 'EM' AND 'EM'*/

	MemoWrite("C:\TOTVS_LG\teste.txt",cQuery)

	cQuery := ChangeQuery(cQuery)
    //Executando a consulta
    TCQuery cQuery New Alias "TRA"

	While TRA->(!EOF()) 
        //Montando a mensagem

		cImprime+="CÓDIGO: " + TRA->B1_COD +CRLF 
		cImprime+="DESCRIÇÃO: " + TRA->B1_DESC +CRLF
		cImprime+="DATA: " + DOTS(TRA->B1_DATREF +CRLF)
		cImprime+= cEspaco

	TRA->(DbSkip())	 

	End	    
        //Testando se o arquivo já existe
        If File(cFileNom)
            lOk := MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
			//If MsgYesNo("Arquivo já existe, deseja substituir?", "Atenção")
				
				  
        EndIf
         
        If lOk
            MemoWrite(cFileNom, cImprime)
            MsgInfo("Arquivo Gerado com Sucesso:"+CRLF+cFileNom,"Atenção")
        EndIf 
    EndIf

RETURN

Static Function _ValidPerg(cPerg)
    
	Local aArea  := GetArea()
	Local aRegs  := {}
	Local aHelps := {}
	Local i      := 0
	Local j      := 0
	aRegs= {}
	//           GRUPO  ORDEM PERGUNT                       PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID           VAR01       DEF01         DEFSPA1 DEFENG1 CNT01 VAR02 DEF02        DEFSPA2 DEFENG2 CNT02 VAR03 DEF03    DEFSPA3 DEFENG3 CNT03 VAR04 DEF04 DEFSPA4 DEFENG4 CNT04 VAR05 DEF05 DEFSPA5 DEFENG5 CNT05 F3  PYME   GRPSXG  HELP  PICTURE
	AADD(aRegs, {cPerg, "01", "Produto de?"                 , "",    "",    "mv_ch1", "", 15, 0,  0,     "G", "",             "MV_PAR01", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "ZSB1", "",    "",     "",   ""})
    AADD(aRegs, {cPerg, "02", "Produto até?"                , "",    "",    "mv_ch2", "", 15, 0,  0,     "G", "",             "MV_PAR02", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "ZSB1", "",    "",     "",   ""})
    AADD(aRegs, {cPerg, "03", "Tipo de?"                    , "",    "",    "mv_ch3", "", 15, 0,  0,     "G", "",             "MV_PAR03", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "ZSB2", "",    "",     "",   ""})
	AADD(aRegs, {cPerg, "04", "Tipo até?"                   , "",    "",    "mv_ch4", "", 15, 0,  0,     "G", "",             "MV_PAR04", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",  "ZSB2", "",    "",     "",   ""})
    // Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.Z
	aHelps = {}
	
DbSelectArea("SX1")
DbSetOrder(1)
For i := 1 to Len (aRegs)
	If ! DbSeek (cPerg + aRegs [i, 2])
		RecLock("SX1", .T.)
	Else
		RecLock("SX1", .F.)
	Endif
	For j := 1 to FCount ()
		// Campos CNT nao sao gravados para preservar conteudo anterior.
		If j <= Len (aRegs [i]) .and. left(fieldname(j), 6) != "X1_CNT" .and. fieldname(j) != "X1_PRESEL"
			FieldPut(j, aRegs [i, j])
		Endif
	Next
	MsUnlock()
Next

	// Deleta do SX1 as perguntas que nao constam em _aRegs
	DbSeek(cPerg, .T.)
	Do While !Eof() .And. x1_grupo == cPerg
		If Ascan(aRegs, {|aVal| aVal [2] == sx1->x1_ordem}) == 0
			Reclock("SX1", .F.)
			Dbdelete()
			Msunlock()
		Endif
		Dbskip()
	enddo

	// Gera helps das perguntas
	For i := 1 to Len(aHelps)
		PutSX1Help ("P." + alltrim(cPerg) + aHelps [i, 1] + ".", aHelps [i, 2], {}, {})
	Next

	Restarea(aArea)
Return


