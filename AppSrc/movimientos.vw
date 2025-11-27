Use Windows.pkg
Use DFClient.pkg
Use cPRESUPUESTO_DataDictionary.dd
Use cEGRESOSDataDictionary.dd
Use DFEntry.pkg
Use dfTable.pkg

Deferred_View Activate_movimientos for ;
Object movimientos is a dbView
    Object oPRESUPUESTO_DD is a cPRESUPUESTODataDictionary
        Procedure Relate_Main_File
            Forward Send Relate_Main_File
            Send Totales
        End_Procedure
    End_Object

    Object oEGRESOS_DD is a cEGRESOSDataDictionary
        Set DDO_Server to oPRESUPUESTO_DD
        Procedure OnConstrain
            Constrain EGRESOS.FORMA_PAGO eq 'TC' and EGRESOS.TC eq 0
        End_Procedure
    End_Object
    
    Procedure Calcula_disponible
        Local String sQ 
        Local Handle hdbc69 hstmt69
        Local Number nValor_Disponible nValor_Liquidar
        
        Move '' to sQ
        Move 0  to nValor_Disponible
        Append sQ " SELECT DISPONIBLE FROM dbo.fn_ObtenerTotalesPresupuesto(" PRESUPUESTO.NUMERO ",3, 'todos'); " 
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nValor_Disponible
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oDISPONIBLE to nValor_Disponible
    End_Procedure
    
    Procedure Totales
        Local String sQ 
        Local Handle hdbc69 hstmt69
        Local Number nValor_Disponible nValor_Liquidar
        
        Move '' to sQ
        Move 0  to nValor_Liquidar
        Append sQ " SELECT SUM(MONTO) FROM EGRESOS WHERE LIQUIDAR = 'S' "  
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nValor_Liquidar
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oVLR_LIQUIDAR to nValor_Liquidar
    End_Procedure
    
    Procedure Liquidar 
        Local String sQ 
        Local Handle hdbc69 hstmt69
        Local Number nValor_Disponible nValor_Liquidar
        
        Move '' to sQ
        Move 0  to nValor_Disponible
        Append sQ " SELECT DISPONIBLE FROM dbo.fn_ObtenerTotalesPresupuesto(" PRESUPUESTO.NUMERO ",3, 'todos'); " 
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nValor_Disponible
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Move '' to sQ
        Move 0  to nValor_Liquidar
        Append sQ " SELECT SUM(MONTO) FROM EGRESOS WHERE LIQUIDAR = 'S' AND PRESUPUESTO = " PRESUPUESTO.NUMERO 
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nValor_Liquidar
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oDISPONIBLE to nValor_Disponible
        Set Value of oVLR_LIQUIDAR to nValor_Liquidar
        
        If (nValor_Disponible < nValor_Liquidar) Begin
            Local Integer iRespuesta
            Get Confirm 'Monto a liquidar es mayor al disponible. Desea usar todo el disponible?' to iRespuesta
            
            If (iRespuesta eq 1) Begin
                Send Stop_Box 'Liquidacion detenida...' '!'
                Procedure_Return
            End
        End
    
        Move '' to sQ
        Append sQ " UPDATE EGRESOS SET LIQUIDAR = 'N', LIQUIDADO = 'S', PAGADO_SN = 'S' where LIQUIDAR = 'S' AND PRESUPUESTO = " PRESUPUESTO.NUMERO 
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Send Request_Find of oEGRESOS_DD ge Egresos.File_Number 1
    End_Procedure

    Set Main_DD to oEGRESOS_DD
    Set Server to oEGRESOS_DD

    Set Border_Style to Border_Thick
    Set Size to 232 472
    Set Location to 0 0
    Set Label to "Liquidacion Tarjetas de credito"

    Object oEgresos is a dbGrid
        Set Size to 157 376
        Set Location to 48 26

        Begin_Row
            Entry_Item EGRESOS.FECHA_REALIZADO
            Entry_Item EGRESOS.DESCRIPCION
            Entry_Item EGRESOS.MONTO
            Entry_Item EGRESOS.LIQUIDAR
            Entry_Item EGRESOS.LIQUIDADO
            Entry_Item PRESUPUESTO.NUMERO
        End_Row

        Set Main_File to EGRESOS.File_Number

        Set Form_Width 0 to 44
        Set Header_Label 0 to "Fecha"
        Set Form_Width 1 to 140
        Set Header_Label 1 to "Descripcion"
        Set Form_Width 2 to 45
        Set Header_Label 2 to "Monto"
        Set Form_Width 3 to 43
        Set Header_Label 3 to "Liquidar?"
        Set Column_CheckBox_State 3 to True
        Set Form_Width 4 to 49
        Set Header_Label 4 to "Liquidado"
        Set Column_CheckBox_State 4 to True
        
        Set Form_Width 5 to 49
        Set Header_Label 5 to "Presupuesto"
        
        
        Set Column_Shadow_State item 0 to True 
        Set Column_Shadow_State item 1 to True 
        Set Column_Shadow_State item 2 to True 
        Set Column_Shadow_State item 4 to True 
        Set Column_Shadow_State item 5 to True 
        Set CurrentRowColor to 8454143
        Set CurrentCellColor to 16777088
    End_Object

    Object oDISPONIBLE is a Form
        Set Size to 13 55
        Set Location to 12 177
        Set Label to "Disponible:"
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
        Set Entry_State to False
    
        // OnChange is called on every changed character
    //    Procedure OnChange
    //        String sValue
    //    
    //        Get Value to sValue
    //    End_Procedure
    
    End_Object

    Object oPRESUPUESTO_NUMERO is a dbForm
        Entry_Item PRESUPUESTO.NUMERO
        Set Location to 12 71
        Set Size to 13 55
        Set Label to "Presupuesto:"
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oVLR_LIQUIDAR is a Form
        Set Size to 13 55
        Set Location to 12 282
        Set Label to "Liquidar:"
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
        Set Entry_State to False
    
        // OnChange is called on every changed character
    //    Procedure OnChange
    //        String sValue
    //    
    //        Get Value to sValue
    //    End_Procedure
    
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 9 28
        Set Location to 115 423
        Set Label to "Liquidar"
    End_Object
    Object oLiquidar is a Button
        Set Size to 23 30
        Set Location to 90 421
        Set Label to 'CargaFijos'
        Set Bitmap to 'Tarjeta_mini.bmp'
    
        // fires when the button is clicked
        Procedure OnClick
            Send Liquidar
        End_Procedure
    
    End_Object

Cd_End_Object
