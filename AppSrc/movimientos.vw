Use Windows.pkg
Use DFClient.pkg
Use cTIPO_GASTO_DataDictionary.dd
Use cPRESUPUESTO_DataDictionary.dd
Use cEGRESOSDataDictionary.dd
Use SUB_EGRESOS.dd
Use DFEntry.pkg
Use dfTable.pkg

Deferred_View Activate_movimientos for ;
Object movimientos is a dbView
    Object oPRESUPUESTO_DD is a cPRESUPUESTODataDictionary
    End_Object

    Object oTIPO_GASTO_DD is a cTIPO_GASTO_DataDictionary
    End_Object

    Object oEGRESOS_DD is a cEGRESOSDataDictionary
        Set DDO_Server to oPRESUPUESTO_DD
        Set DDO_Server to oTIPO_GASTO_DD
    End_Object

    Object oSUB_EGRESOS_DD is a SUB_EGRESOS_DataDictionary
        Set Constrain_file to EGRESOS.File_number
        Set DDO_Server to oEGRESOS_DD
    End_Object

    Set Main_DD to oEGRESOS_DD
    Set Server to oEGRESOS_DD

    Set Border_Style to Border_Thick
    Set Size to 233 497
    Set Location to 1 2
    Set Label to "movimientos"

    Object oPRESUPUESTO_NUMERO is a dbForm
        Entry_Item PRESUPUESTO.NUMERO
        Set Location to 6 82
        Set Size to 13 66
        Set Label to "NUMERO:"
        Set Prompt_Object to PRESUPUESTO_SL
        Set Prompt_Button_Mode to PB_PromptOn
    End_Object

    Object oDbGrid1 is a dbGrid
        Set Size to 100 470
        Set Location to 25 13

        Begin_Row
            Entry_Item EGRESOS.NUMERO
            Entry_Item TIPO_GASTO.CLAVE
            Entry_Item EGRESOS.DESCRIPCION
            Entry_Item EGRESOS.FECHA_REALIZADO
            Entry_Item EGRESOS.MONTO
            Entry_Item EGRESOS.MONTO_PROYECTADO
        End_Row

        Set Main_File to EGRESOS.File_Number

        Set Form_Width 0 to 45
        Set Header_Label 0 to "NUMERO"
        Set Form_Width 1 to 52
        Set Header_Label 1 to "TIPO"
        Set Form_Width 2 to 105
        Set Header_Label 2 to "DESCRIPCION"
        Set Form_Width 3 to 60
        Set Header_Label 3 to "FECHA REALIZADO"
        Set Form_Width 4 to 72
        Set Header_Label 4 to "MONTO"
        Set Form_Width 5 to 72
        Set Header_Label 5 to "MONTO PROYECTADO"
    End_Object

    Object oDbGrid2 is a dbGrid
        Set Size to 67 458
        Set Location to 135 18

        Begin_Row
            Entry_Item SUB_EGRESOS.NUMERO
            Entry_Item SUB_EGRESOS.DESCRIPCION
            Entry_Item SUB_EGRESOS.MONTO
            Entry_Item SUB_EGRESOS.FECHA_REALIZADO
        End_Row

        Set Main_File to SUB_EGRESOS.File_Number

        Set Server to oSUB_EGRESOS_DD

        Set Form_Width 0 to 60
        Set Header_Label 0 to "NUMERO"
        Set Form_Width 1 to 239
        Set Header_Label 1 to "DESCRIPCION"
        Set Form_Width 2 to 72
        Set Header_Label 2 to "MONTO"
        Set Form_Width 3 to 69
        Set Header_Label 3 to "FECHA REALIZADO"
    End_Object

Cd_End_Object
