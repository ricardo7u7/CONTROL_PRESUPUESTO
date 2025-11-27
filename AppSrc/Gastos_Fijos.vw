Use Windows.pkg
Use DFClient.pkg
Use EGRESOS_FIJOS.dd
Use dfTable.pkg

Deferred_View Activate_Gastos_Fijos for ;
Object Gastos_Fijos is a dbView
    Object oEGRESOS_FIJOS_DD is a EGRESOS_FIJOS_DataDictionary
    End_Object

    Set Main_DD to oEGRESOS_FIJOS_DD
    Set Server to oEGRESOS_FIJOS_DD

    Set Border_Style to Border_Thick
    Set Size to 196 395
    Set Location to 2 2
    Set Label to "Gastos_Fijos"

    Object oDbGrid1 is a dbGrid
        Set Size to 176 352
        Set Location to 12 18
        Set Wrap_State to True

        Begin_Row
            Entry_Item EGRESOS_FIJOS.NUMERO
            Entry_Item EGRESOS_FIJOS.TIPO
            Entry_Item EGRESOS_FIJOS.DESCRIPCION
            Entry_Item EGRESOS_FIJOS.MONTO_PROYECTADO
            Entry_Item EGRESOS_FIJOS.QUINCENA
        End_Row

        Set Main_File to EGRESOS_FIJOS.File_Number

        Set Form_Width 0 to 15
        Set Header_Label 0 to "#"
        Set Form_Width 1 to 30
        Set Header_Label 1 to "Tipo"
        Set Form_Width 2 to 132
        Set Header_Label 2 to "Descripci¢n"
        Set Form_Width 3 to 81
        Set Header_Label 3 to "Monto Proyectado"
        Set CurrentCellColor to 16777088
        Set CurrentRowColor to 8454143
        Set Form_Width 4 to 90
        Set Header_Label 4 to "Aplicaci¢n"
        Set Column_Combo_State 4 to True
        
        Set Column_Shadow_State item 0 to True 
        Set Column_CapsLock_State item 1 to True 
        Set Column_CapsLock_State item 4 to True 
        Set Numeric_Mask item 3 to 8 2 '*,'
        Set Column_Entry_msg item 2 to Carga_Desc
        
        
        
        Procedure Carga_Desc
            Local Integer iRow
            Local String sDescripcionActual sTipoGasto
            Get Base_Item to iRow
            Get Value item (iRow+2) to sDescripcionActual
            Get Value item (iRow+1) to sTipoGasto
            
            If (sDescripcionActual eq '') Begin
                Clear TIPO_GASTO
                Move sTipoGasto to TIPO_GASTO.CLAVE
                Find eq TIPO_GASTO by Index.2
                If Found Begin
                    Set Value item (iRow+2) to (Trim(TIPO_GASTO.DESCRIPCION))
                    Set Item_Changed_State item 2 to True
                End
            End
        End_Procedure
    End_Object

Cd_End_Object
