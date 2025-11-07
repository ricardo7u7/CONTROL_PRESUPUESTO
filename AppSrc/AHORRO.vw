Use Windows.pkg
Use DFClient.pkg
Use cAHORRO_H_DataDictionary.dd
Use cAHORRO_D_DataDictionary.dd
Use DFEntry.pkg
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use DfCentry.pkg

Deferred_View Activate_AHORRO for ;
Object AHORRO is a dbView
    Object oAHORRO_H_DD is a cAHORRO_H_DataDictionary
        Procedure Relate_Main_File 
            Forward Send Relate_Main_File
                Set Shadow_State of oAHORRO_H_DESCRIPCION         to True
                Set Shadow_State of oAHORRO_H_FECHA_INICIO        to True
                Set Shadow_State of oAHORRO_H_FECHA_OBJETIVO      to True 
                Set Shadow_State of oAHORRO_H_PRIORIDAD           to True
            Send Totales
        End_Procedure
    End_Object
    
    Procedure Request_Clear
        Forward Send Request_Clear
        Set Shadow_State of oAHORRO_H_DESCRIPCION         to False
        Set Shadow_State of oAHORRO_H_FECHA_INICIO        to False
        Set Shadow_State of oAHORRO_H_FECHA_OBJETIVO      to False 
        Set Shadow_State of oAHORRO_H_PRIORIDAD           to False
        Set Value of oTOTAL         to ''
        Set Value of oTOTAL_PROYECT to ''
    End_Procedure
    
    Procedure Request_Clear_All
        Forward Send Request_Clear_All
        Set Shadow_State of oAHORRO_H_DESCRIPCION         to False
        Set Shadow_State of oAHORRO_H_FECHA_INICIO        to False
        Set Shadow_State of oAHORRO_H_FECHA_OBJETIVO      to False 
        Set Shadow_State of oAHORRO_H_PRIORIDAD           to False
        Set Value of oTOTAL         to ''
        Set Value of oTOTAL_PROYECT to ''
    End_Procedure

    Object oAHORRO_D_DD is a cAHORRO_D_DataDictionary
        Set Constrain_file to AHORRO_H.File_number
        Set DDO_Server to oAHORRO_H_DD
        
        
        Procedure request_save
            Forward Send Request_Save
            Move AHORRO_H.NUMERO to AHORRO_D.AHORRO_H
        End_Procedure
    End_Object
    
    //FUNCIONES Y PROCEDIMIENTOS
    Procedure Totales 
        Local String sQ
        Local Handle hdbc69 hstmt69
        Local Number nMonto nMontoEsp nValPgdo nValDispo
    
        Move '' to sQ
        Move 0  to nMonto
        Move 0  to nMontoEsp
        Append sQ " SELECT SUM(MONTO) FROM AHORRO_D WHERE PAGADO_SN = 'S' AND AHORRO_H =  " AHORRO_H.NUMERO 
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nMonto
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Move '' to sQ
        Append sQ " SELECT SUM(MONTO_PROYECTADO) FROM AHORRO_D WHERE AHORRO_H =  " AHORRO_H.NUMERO //SUM(MONTO_PROYECTADO)
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nMontoEsp
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oTOTAL         to nMonto
        Set Value of oTOTAL_PROYECT to nMontoEsp
        
    End_Procedure

    Set Main_DD to oAHORRO_H_DD
    Set Server to oAHORRO_H_DD

    Set Border_Style to Border_Thick
    Set Size to 266 336
    Set Location to 2 2
    Set Label to "Control De Ahorros..."
    Set Color to 9824917

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 108 315
        Set Location to 3 11

        Object oDbGroup1 is a dbGroup
            Set Size to 101 238
            Set Location to 1 5
            Set Label to 'Ahorro'

            Object oAHORRO_H_NUMERO is a dbForm
                Entry_Item AHORRO_H.NUMERO
                Set Location to 17 67
                Set Size to 13 66
                Set Label to "NUMERO:"
            End_Object

            Object oAHORRO_H_DESCRIPCION is a dbForm
                Entry_Item AHORRO_H.DESCRIPCION
                Set Location to 32 67
                Set Size to 13 139
                Set Label to "DESCRIPCION:"
            End_Object

            Object oAHORRO_H_FECHA_INICIO is a dbForm
                Entry_Item AHORRO_H.FECHA_INICIO
                Set Location to 47 67
                Set Size to 13 66
                Set Label to "FECHA INICIO:"
            End_Object

            Object oAHORRO_H_FECHA_OBJETIVO is a dbForm
                Entry_Item AHORRO_H.FECHA_OBJETIVO
                Set Location to 62 67
                Set Size to 13 66
                Set Label to "FECHA OBJETIVO:"
            End_Object

            Object oAHORRO_H_PRIORIDAD is a dbComboForm
                Entry_Item AHORRO_H.PRIORIDAD
                Set Location to 79 67
                Set Size to 13 66
                Set Label to "PRIORIDAD:"
                
                Procedure Combo_Fill_List
                    Send Combo_Add_Item "ALTA"
                    Send Combo_Add_Item "MEDIA"
                    Send Combo_Add_Item "BAJA"
                End_Procedure

            End_Object
        End_Object

        Object oTOTAL is a dbForm
            Set Size to 13 57
            Set Location to 87 249
            Set Entry_State to False
            Set Color to 4643654
            Set Numeric_Mask 0 to 4 2
        End_Object

        Object oTOTAL_PROYECT is a dbForm
            Set Size to 13 57
            Set Location to 64 249
            Set Entry_State to False
            Set Numeric_Mask 0 to 4 2
        End_Object

        Object oTextBox1 is a TextBox
            Set Size to 9 40
            Set Location to 78 250
            Set Label to 'Total Actual'
        End_Object

        Object oTextBox1 is a TextBox
            Set Size to 9 57
            Set Location to 55 250
            Set Label to 'Total Proyectado'
        End_Object
    End_Object

    Object oDbContainer3d2 is a dbContainer3d
        Set Size to 148 314
        Set Location to 114 12

        Object oDbCJGrid1 is a cDbCJGrid
            Set Server to oAHORRO_D_DD
            Set Size to 139 301
            Set Location to 3 4

            Object oAHORRO_D_NUMERO is a cDbCJGridColumn
                Entry_Item AHORRO_D.NUMERO
                Set piWidth to 45
                Set psCaption to "#"
            End_Object

            Object oAHORRO_D_DESCRIPCION is a cDbCJGridColumn
                Entry_Item AHORRO_D.DESCRIPCION
                Set piWidth to 239
                Set psCaption to "Descripcion"
            End_Object

            Object oAHORRO_D_MONTO is a cDbCJGridColumn
                Entry_Item AHORRO_D.MONTO
                Set piWidth to 79
                Set psCaption to "Monto"
            End_Object

            Object oAHORRO_D_MONTO_PROYECTADO is a cDbCJGridColumn
                Entry_Item AHORRO_D.MONTO_PROYECTADO
                Set piWidth to 89
                Set psCaption to "Mnto Espe."
            End_Object

            Object oAHORRO_D_PAGADO_SN is a cDbCJGridColumn
                Entry_Item AHORRO_D.PAGADO_SN
                Set piWidth to 52
                Set psCaption to "Pgdo?"
                Set pbCheckbox to True
            End_Object

            Object oAHORRO_D_FECHA_REALIZADO is a cDbCJGridColumn
                Entry_Item AHORRO_D.FECHA_REALIZADO
                Set piWidth to 98
                Set psCaption to "Fecha"
            End_Object
        End_Object
    End_Object

Cd_End_Object
