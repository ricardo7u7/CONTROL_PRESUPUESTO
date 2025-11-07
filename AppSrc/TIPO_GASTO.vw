Use Windows.pkg
Use DFClient.pkg
Use cTIPO_GASTO_DataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg

Deferred_View Activate_TIPO_GASTO for ;
Object TIPO_GASTO is a dbView
    Object oTIPO_GASTO_DD is a cTIPO_GASTO_DataDictionary
    End_Object

    Set Main_DD to oTIPO_GASTO_DD
    Set Server to oTIPO_GASTO_DD

    Set Border_Style to Border_Thick
    Set Size to 142 300
    Set Location to 2 2
    Set Label to "Catalogo Tipos de Gastos"

    Object oDbGroup1 is a dbGroup
        Set Size to 130 277
        Set Location to 6 9
        Set Label to 'Cat logo Tipo de Gastos'

        Object oDbCJGrid1 is a cDbCJGrid
            Set Size to 100 267
            Set Location to 12 5

            Object oTIPO_GASTO_NUMERO is a cDbCJGridColumn
                Entry_Item TIPO_GASTO.NUMERO
                Set piWidth to 70
                Set psCaption to "#"
            End_Object

            Object oTIPO_GASTO_CLAVE is a cDbCJGridColumn
                Entry_Item TIPO_GASTO.CLAVE
                Set piWidth to 77
                Set psCaption to "Clave"
                Set pbCapslock to True
            End_Object

            Object oTIPO_GASTO_DESCRIPCION is a cDbCJGridColumn
                Entry_Item TIPO_GASTO.DESCRIPCION
                Set piWidth to 387
                Set psCaption to "Descripcion"
            End_Object
        End_Object
    End_Object

Cd_End_Object
