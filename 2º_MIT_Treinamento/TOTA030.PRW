#include "protheus.ch"
#include "parmtype.ch"
#include "TopConn.ch"

user function tota030()
    alertUI()
    return

//Janela para confirmar a solicitação
static function alertUI()
    local cQuestion := "Deseja exportar as especificacoes tecnicas (SZF) a um arquivo csv ?"
    local cText     := "Exportacao de especificacoes tecnicas"

    if FWAlertYesNo(question, text)
        dispWPara()
    endif
    return


//Coloca os dados no arquivo CSV
static function setDataCSV(cod, desc, adata)
    local cBreakLin  := Chr(13) + Chr(10)
    local cHeader    := "B1_COD;B1_DESC;B1_DATA"
    private cTxtPath := "C:\Users\carlos.simon\Documents\GitHub\2º_MIT_TREINAMENTO\repositorio.csv"

    if alreadyHavecHeader == .f.
        newContent := cHeader + cBreakLin + cod + ";" + desc + ';' + cvaltochar(aData)
        memowrite(cTxtPath, newContent)
        alreadyHavecHeader := .T.
    else
        fContent := readCSVContent()
        newContent := fContent + cod + ";" + desc + ';' + cvaltochar(aData)
        memowrite(cTxtPath, newContent)
    end
    return

//Le o conteudo que ja esta no arquivo CSV
static function readCSVContent()
    local currentLine
    private fContent := ""
    private lineCount
    cBreakLin := Chr(13) + Chr(10)

    file := FWFileReader():New(cTxtPath)
    if (file:Open())
        fileLines := file:GetAllLines()
        lineCount := len(fileLines)
        file:Close()
    endif
    
    for currentLine:=1 to lineCount
        fContent += fileLines[currentLine] + cBreakLin
    next
    return fContent


//apresenta a janela de parametros

static function checkShields()
    if alltrim(lowerCod) == ""
        lowerCod := 0001
    end

    if alltrim(higherCod) == ""
        higherCod := 9999
    end

    if alltrim(lowerType) == ""
        lowerType := "AA"
    end

    if alltrim(higherType) == ""
        higherType := "ZZ"
    end
    return

static function dispWPara()
    //Dimensoes da janela
    windowHeight := 325
    windowWidth := 350

    //Posicoes dos botoes
    btnXPos := windowWidth / 2
    btnYPos := windowHeight / 2

    private lowerCod := space(10)
    private higherCod := space(10)
    private lowerType := space(2)
    private higherType := space(2)

        //WINDOW
            define msdialog ojan01;
            title "Buscar produtos";
            pixel from 0,0;
            to windowHeight,windowWidth;
            /*style nor(WS_VISIBLE,WS_POPUP)*/

                //Texto solicitando quais produtos o usuario deseja buscar
                @ 10, windowWidth / 8;
                Say;
                "Quais produtos deseja buscar ?";
                Pixel

                @ 20, 40;
                Say;
                "(Deixe em branco para buscar Todos)";
                Pixel

                //Texto para codigo de produto  
                @ 35, 65;
                Say;
                "Codigo de produto";
                Pixel

                //Campo para menor codigo de produto
                @ 50, 10;
                GET memoObject;
                var lowerCod;
                of ojan01;
                SIZE 65, 15;
                COLORS 0, 16777215;
                picture "9999999999";
                PIXEL

                //Texto divisor
                @ 55, 80;
                Say;
                "ate";
                Pixel

                //Campo solicitando maior codigo de busca
                @ 50, 95;
                GET memoObject;
                var higherCod;
                of ojan01;
                SIZE 65, 15;
                COLORS 0, 16777215;
                PIXEL;
                picture "9999999999";

                @ 85, 65;
                Say;
                "Tipo de produto";
                Pixel

                //
                @ 100, 10;
                GET memoObject;
                var lowerType;
                of ojan01;
                SIZE 65, 15;
                COLORS 0, 16777215;
                PICTURE "AA";
                PIXEL

                @ 105, 80;
                Say;
                "ate";
                Pixel

                //
                @ 100, 95;
                GET memoObject;
                var higherType;
                of ojan01;
                SIZE 65, 15;
                COLORS 0, 16777215;
                PICTURE "AA";
                PIXEL

                //Botao de sair
                @ 140, 100;
                button;
                "Sair";
                Pixel;
                size 30, 13;
                action oJan01:end()
                

                //Botao para buscar os parametros informados
                @ 140, 140;
                button;
                "Buscar";
                size 30, 13;
                Pixel;
                action (checkShields(), getData(),oJan01:end())
        activate dialog ojan01 centered   
    return

//Coleta os dados da tabela SB1
static function getData()
    local aArea := SB1->(GetArea())
    local cQuery := ""
    local aData := {}
    private alreadyHavecHeader := .f.

    cQuery := "SELECT" +CRLF
    cQuery += " B1_COD AS _CODIGO," +CRLF
    cQuery += " B1_DESC AS _DESCRICAO," +CRLF
    cQuery += " B1_DATREF AS _DATA " +CRLF
    cQuery += " FROM " +CRLF
    cQuery += RetSqlName("SB1") + CRLF
    cQuery += " WHERE " + CRLF
    cQuery += " B1_COD " + CRLF
    cQuery += " between " +CRLF
    cQuery += cvaltochar(lowerCod) + CRLF
    cQuery += " and " + CRLF
    cQuery += cvaltochar(higherCod) + CRLF
    cQuery += " and " + CRLF
    cQuery += " B1_TIPO " + CRLF
    cQuery += " between "+CRLF
    cQuery += "'" + alltrim(upper(lowerType)) + "'"+CRLF
    cQuery += " and " + CRLF
    cQuery += " '" + alltrim(upper(higherType)) + "'"

    tcQuery cQuery new Alias "TMP"

    while ! TMP->(EOF())
        AADD(aData, alltrim(TMP->_CODIGO))
        AADD(aData, alltrim(TMP->_DESCRICAO))
        AADD(aData, STOD(TMP->_DATA))

        setDataCSV(aData[1], aData[2], aData[3])
        aData := {}
        TMP->(DbSkip())
    end
    TMP->(DbCloseArea())
    RestArea(aArea)
    alreadyHavecHeader := .f.
    return
