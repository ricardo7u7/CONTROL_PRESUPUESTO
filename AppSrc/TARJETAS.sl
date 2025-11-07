Use Windows.pkg
Use DFClient.pkg
Use cDbCJGridPromptList.pkg
Use cTIPO_GASTO_DataDictionary.dd
Use TARJETA.dd
Use cdbCJGridColumn.pkg

Object TARJETAS_SL is a dbModalPanel
    Object oTARJETA_DD is a TARJETA_DataDictionary
    End_Object

    Set Main_DD to oTARJETA_DD
    Set Server to oTARJETA_DD


    Set Size to 88 171
    Set Location     to 4 5
    Set Border_Style to Border_Thick
    Set Label to "TIPO_GASTO"
    Set Column_Offset to 1
    
     Object oSelList is a dbList
        Set Main_File to TARJETA.File_Number
        Set Size to 62 159
        Set Location to 6 6
    
        Begin_Row
            Entry_Item TARJETA.Numero
            Entry_Item TARJETA.CLAVE
            Entry_Item TARJETA.DIA_CORTE
            Entry_Item TARJETA.DIA_PAGO
        End_Row
    
        Set Form_Width 0 to 19
        Set Header_Label  item 0 to "#"
        
        Set Form_Width 1 to 42
        Set Header_Label  item 1 to "Clave"
        
        Set Form_Width 2 to 49
        Set Header_Label  item 2 to "Dia Corte"
        
        Set Form_Width 3 to 43
        Set Header_Label  item 3 to "Dia Pago"
        
        Set Export_Column to 0
        Set Initial_Column to 0
        
    End_Object    // oSelList

    Object oOK_bn is a Button
        Set Label     to "&OK"
        Set Location to 71 7
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Ok of oSelList
        End_Procedure

    End_Object

    Object oCancel_bn is a Button
        Set Label     to "&Cancel"
        Set Location to 71 61
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object

    Object oSearch_bn is a Button
        Set Label     to "&Search..."
        Set Location to 71 115
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

End_Object

