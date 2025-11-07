Use Windows.pkg
Use DFClient.pkg
Use cDbCJGridPromptList.pkg
Use cTIPO_GASTO_DataDictionary.dd
Use cdbCJGridColumn.pkg

Object TIPO_GASTO_SL is a dbModalPanel
    Object oTIPO_GASTO_DD is a cTIPO_GASTO_DataDictionary
    End_Object

    Set Main_DD to oTIPO_GASTO_DD
    Set Server to oTIPO_GASTO_DD

    Set Size to 133 171
    Set Location     to 4 5
    Set Border_Style to Border_Thick
    Set Label to "TIPO_GASTO"
    Set Column_Offset to 1
    
     Object oSelList is a dbList
        Set Main_File to TIPO_GASTO.File_Number
        Set Size to 105 168
        Set Location to 6 2
    
        Begin_Row
            Entry_Item TIPO_GASTO.Numero
            Entry_Item TIPO_GASTO.CLAVE
            Entry_Item TIPO_GASTO.DESCRIPCION
        End_Row
    
        Set Form_Width 0 to 19
        Set Header_Label  item 0 to "#"
        
        Set Form_Width 1 to 34
        Set Header_Label  item 1 to "Clave"
        
        Set Form_Width 2 to 111
        Set Header_Label  item 2 to "Descripcion"
         Set Export_Column to 1
         Set Initial_Column to 1
        
    End_Object    // oSelList

    Object oOK_bn is a Button
        Set Label     to "&OK"
        Set Location to 115 7
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Ok of oSelList
        End_Procedure

    End_Object

    Object oCancel_bn is a Button
        Set Label     to "&Cancel"
        Set Location to 115 61
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object

    Object oSearch_bn is a Button
        Set Label     to "&Search..."
        Set Location to 115 115
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

End_Object

