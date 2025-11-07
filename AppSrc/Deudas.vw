Use Windows.pkg
Use DFClient.pkg
Use cDEUDA_H_DataDictionary.dd
Use cDEUDA_D_DataDictionary.dd
Use DFEntry.pkg
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use DFEnChk.pkg

Deferred_View Activate_Deudas for ;
Object Deudas is a dbView
    Procedure Request_Clear
        Forward Send Request_Clear
            Set Shadow_State of oDEUDA_H_CLAVE        to False
            Set Shadow_State of oDEUDA_H_MONTO        to False
            Set Shadow_State of oDEUDA_H_TIPO         to False 
            Set Shadow_State of oDEUDA_H_FECHA_INICIO to False
            Set Shadow_State of oDEUDA_H_FECHA_FIN    to False
            Set Shadow_State of oDEUDA_H_DESCRIPCION  to False
            Set Value of oTOTAL         to ''
            Set Value of oTOTAL_PROYECT to ''
    End_Procedure
    
    Procedure Request_Clear_All
        Forward Send Request_Clear_All
            Set Shadow_State of oDEUDA_H_CLAVE        to False
            Set Shadow_State of oDEUDA_H_MONTO        to False
            Set Shadow_State of oDEUDA_H_TIPO         to False 
            Set Shadow_State of oDEUDA_H_FECHA_INICIO to False
            Set Shadow_State of oDEUDA_H_FECHA_FIN    to False
            Set Shadow_State of oDEUDA_H_DESCRIPCION  to False
            Set Value of oTOTAL         to ''
            Set Value of oTOTAL_PROYECT to ''
    End_Procedure
    
    
    Object oDEUDA_H_DD is a cDEUDA_H_DataDictionary
        Procedure Relate_Main_File
            Forward Send Relate_Main_File
            
            // SI ES A FAVOR LOS TOTALES SON CON DIFERENTE LOGICA 
            If (DEUDA_H.A_FAVOR eq 'N') Send Totales
            Else Send Totales2
            
            Set Shadow_State of oDEUDA_H_CLAVE        to True
            Set Shadow_State of oDEUDA_H_MONTO        to True
            Set Shadow_State of oDEUDA_H_TIPO         to True 
            Set Shadow_State of oDEUDA_H_FECHA_INICIO to True
            Set Shadow_State of oDEUDA_H_FECHA_FIN    to True
            Set Shadow_State of oDEUDA_H_DESCRIPCION  to True
        End_Procedure
        
    End_Object

    Object oDEUDA_D_DD is a cDEUDA_D_DataDictionary
        Set Constrain_file to DEUDA_H.File_number
        Set DDO_Server to oDEUDA_H_DD
        
        
        Procedure Request_Save 
            Forward Send Request_Save
                Move DEUDA_H.NUMERO to DEUDA_D.DEUDA_H
        End_Procedure
        
    End_Object
    
    
    //FUNCIONES Y PROCEDIMIENTOS
    Procedure Totales 
        Local String sQ
        Local Handle hdbc69 hstmt69
        Local Number nMonto nMontoEsp nTotalDeuda 
    
        Move '' to sQ
        Move 0  to nMonto
        Move 0  to nMontoEsp
        Append sQ " SELECT SUM(MONTO) FROM DEUDA_D WHERE PAGADO_SN = 'S' AND DEUDA_H =  " DEUDA_H.NUMERO 
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
        Append sQ " SELECT SUM(MONTO_PROYECTADO) FROM DEUDA_D WHERE DEUDA_H =  " DEUDA_H.NUMERO 
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
        
        Get Value of oDEUDA_H_MONTO to nTotalDeuda
        
        Move (DEUDA_H.MONTO -nMonto)    to nMonto
        Move (DEUDA_H.MONTO -nMontoEsp) to nMontoEsp
        
        Set Value of oTOTAL         to nMonto
        Set Value of oTOTAL_PROYECT to nMontoEsp
        Set Value of oTextDIFERENCIA to '--'
        
    End_Procedure
    
    
    //FUNCIONES Y PROCEDIMIENTOS
    Procedure Totales2 
        Local String sQ
        Local Handle hdbc69 hstmt69
        Local Number nMonto nMontoEsp nTotalDeuda nDiferencia
    
        Move '' to sQ
        Move 0  to nMonto
        Move 0  to nMontoEsp
        Append sQ " SELECT SUM(MONTO) FROM DEUDA_D WHERE PAGADO_SN = 'S' AND DEUDA_H =  " DEUDA_H.NUMERO 
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
        Append sQ " SELECT SUM(MONTO_PROYECTADO) FROM DEUDA_D WHERE DEUDA_H =  " DEUDA_H.NUMERO 
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
        Move (nMontoEsp-nMonto) to nDiferencia
        Set Value of oTextDIFERENCIA to ("Pendiente: "+String(nDiferencia))
        
        
        Reread DEUDA_H
        Move nMontoEsp to DEUDA_H.MONTO
        SaveRecord DEUDA_H
        Unlock
        
    End_Procedure

    Set Main_DD to oDEUDA_H_DD
    Set Server to oDEUDA_H_DD

    Set Border_Style to Border_Thick
    Set Size to 284 263
    Set Location to 2 2
    Set Label to "Deudas"
    Set Delegation_Mode to No_Delegate_Or_Error
    Set Color to 16641499

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 122 247
        Set Location to 4 9
        Set Color to clMenu

        Object oDEUDA_H_NUMERO is a dbForm
            Entry_Item DEUDA_H.NUMERO
            Set Location to 4 56
            Set Size to 12 66
            Set Label to "NUMERO:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oDEUDA_H_CLAVE is a dbForm
            Entry_Item DEUDA_H.CLAVE
            Set Location to 4 165
            Set Size to 12 66
            Set Label to "CLAVE:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oDEUDA_H_DESCRIPCION is a dbForm
            Entry_Item DEUDA_H.DESCRIPCION
            Set Location to 52 55
            Set Size to 12 176
            Set Label to "DESCRIPCION:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oDEUDA_H_MONTO is a dbForm
            Entry_Item DEUDA_H.MONTO
            Set Location to 20 56
            Set Size to 12 66
            Set Label to "MONTO:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oDEUDA_H_FECHA_INICIO is a dbForm
            Entry_Item DEUDA_H.FECHA_INICIO
            Set Location to 36 56
            Set Size to 12 66
            Set Label to "FECHA INICIO:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oDEUDA_H_FECHA_FIN is a dbForm
            Entry_Item DEUDA_H.FECHA_FIN
            Set Location to 36 165
            Set Size to 12 66
            Set Label to "FECHA FIN:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oDEUDA_H_TIPO is a dbForm
            Entry_Item DEUDA_H.TIPO
            Set Location to 20 165
            Set Size to 12 20
            Set Label to "TIPO:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oDbGroup1 is a dbGroup
            Set Size to 43 225
            Set Location to 66 7
            Set Label to 'Totales'
            Set Color to 16641499

            Object oTextBox1 is a TextBox
                Set Size to 9 38
                Set Location to 11 18
                Set Label to 'Proyect.'
            End_Object
            Object oTOTAL_PROYECT is a dbForm
                Set Size to 13 68
                Set Location to 8 48
                Set Entry_State to False
                Set Numeric_Mask 0 to 4 2
                Set Color to 16744576
            End_Object

            Object oTextBox1 is a TextBox
                Set Size to 9 19
                Set Location to 27 23
                Set Label to 'Pdgo.'
            End_Object
            Object oTOTAL is a dbForm
                Set Size to 13 68
                Set Location to 24 48
                Set Entry_State to False
                Set Color to 16776960
                Set Numeric_Mask 0 to 4 2
            End_Object

            Object oTextDIFERENCIA is a TextBox
                Set Auto_Size_State to False
                Set Size to 10 83
                Set Location to 25 125
                Set Label to '--'
                Set Color to 16641499
                Set Justification_Mode to JMode_Right
            End_Object
        End_Object

        Object oDEUDA_H_A_FAVOR is a dbCheckBox
            Entry_Item DEUDA_H.A_FAVOR
            Set Location to 22 192
            Set Size to 10 60
            Set Label to "A FAVOR"
        End_Object
    End_Object

    Object oDbContainer3d2 is a dbContainer3d
        Set Size to 154 247
        Set Location to 131 9

        Object oDbCJGrid1 is a cDbCJGrid
            Set Server to oDEUDA_D_DD
            Set Size to 157 236
            Set Location to 5 3
            Set piSelectedRowBackColor to 65535
            Set piGridLineColor to clScrollBar
            Set piSelectedRowForeColor to 65408
            Set peVisualTheme to xtpReportThemeVisualStudio2012Light

            Object oDEUDA_D_NUMERO is a cDbCJGridColumn
                Entry_Item DEUDA_D.RENGLON
                Set piWidth to 20
                Set psCaption to "#"
            End_Object

            Object oDEUDA_H_DESCRIPCION1 is a cDbCJGridColumn
                Entry_Item DEUDA_D.DESCRIPCION
                Set piWidth to 131
                Set psCaption to "Descripcion"
            End_Object

            Object oDEUDA_D_MONTO is a cDbCJGridColumn
                Entry_Item DEUDA_D.MONTO
                Set piWidth to 93
                Set psCaption to "Monto"
            End_Object

            Object oDEUDA_D_MONTO_PROYECTADO is a cDbCJGridColumn
                Entry_Item DEUDA_D.MONTO_PROYECTADO
                Set piWidth to 84
                Set psCaption to "Proyectado"
            End_Object

            Object oDEUDA_D_FECHA_REALIZADO is a cDbCJGridColumn
                Entry_Item DEUDA_D.FECHA_REALIZADO
                Set piWidth to 91
                Set psCaption to "F. Realizado"
            End_Object

            Object oDEUDA_D_PAGADO_SN is a cDbCJGridColumn
                Entry_Item DEUDA_D.PAGADO_SN
                Set piWidth to 53
                Set psCaption to "Pgdo?"
                Set pbCheckbox to True
            End_Object
        End_Object
    End_Object

Cd_End_Object
