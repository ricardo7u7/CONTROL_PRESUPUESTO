Use Windows.pkg
Use DFClient.pkg
Use cDbCJGridPromptList.pkg
Use cPRESUPUESTO_DataDictionary.dd
Use cdbCJGridColumn.pkg

Object PRESUPUESTO_SL is a dbModalPanel
    Object oPRESUPUESTO_DD is a cPRESUPUESTODataDictionary
    End_Object

    Set Main_DD to oPRESUPUESTO_DD
    Set Server to oPRESUPUESTO_DD

    Set Size to 94 197
    Set Location     to 4 5
    Set Border_Style to Border_Thick
    Set Label to "PRESUPUESTO"

    Object oSelList is a dbList
        Set Main_File to PRESUPUESTO.File_Number
        Set Size to 65 185
        Set Location to 6 7
    
        Begin_Row
            Entry_Item PRESUPUESTO.Numero
            Entry_Item PRESUPUESTO.CLAVE
            Entry_Item PRESUPUESTO.FECHA_INICIO
            Entry_Item PRESUPUESTO.FECHA_FIN
        End_Row
    
        Set Form_Width 0 to 19
        Set Header_Label  item 0 to "#"
        
        Set Form_Width 1 to 43
        Set Header_Label  item 1 to "Clave"
        
        Set Form_Width 2 to 58
        Set Header_Label  item 2 to "Fecha Inicio"
        
        Set Form_Width 3 to 56
        Set Header_Label  item 3 to "Fecha Fin"
        
         Set Export_Column to  0
         Set Initial_Column to 0
        
    End_Object    // oSelList

    Object oOK_bn is a Button
        Set Label     to "&OK"
        Set Location to 76 19
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Ok of oSelList
        End_Procedure

    End_Object

    Object oCancel_bn is a Button
        Set Label     to "&Cancel"
        Set Location to 76 73
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object

    Object oSearch_bn is a Button
        Set Label     to "&Search..."
        Set Location to 76 127
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

End_Object

