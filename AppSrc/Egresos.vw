Use Windows.pkg
Use DFClient.pkg
Use DFEntry.pkg
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use sql.pkg
Use dfLine.pkg
Use dfTabDlg.pkg
Use TARJETAS.sl
Use cPRESUPUESTO_DataDictionary.dd
Use cTIPO_GASTO_DataDictionary.dd
Use TARJETA.dd
Use cEGRESOSDataDictionary.dd
Use SUB_EGRESOS.dd

Deferred_View Activate_Egresos for ;
Object Egresos is a dbView
    Object oTARJETA_DD is a TARJETA_DataDictionary
    End_Object

    Object oTIPO_GASTO_DD is a cTIPO_GASTO_DataDictionary
    End_Object

    Object oPRESUPUESTO_DD is a cPRESUPUESTODataDictionary
        Procedure Relate_Main_File
            Forward Send Relate_Main_File 
            Send Totales
        End_Procedure
    End_Object

    Object oEGRESOS_DD is a cEGRESOSDataDictionary
        Set DDO_Server to oTARJETA_DD
        Set Constrain_file to PRESUPUESTO.File_number
        Set DDO_Server to oPRESUPUESTO_DD
        Set DDO_Server to oTIPO_GASTO_DD
    End_Object

    Object oSUB_EGRESOS_DD is a SUB_EGRESOS_DataDictionary
        Set Constrain_file to EGRESOS.File_number
        Set DDO_Server to oEGRESOS_DD
    End_Object

    Set Main_DD to oPRESUPUESTO_DD
    Set Server to oPRESUPUESTO_DD
    
    Procedure Request_Delete
        Send Totales
    End_Procedure
    
    
    Procedure Request_Clear
        Forward Send Request_Clear
        Set Shadow_State of oPRESUPUESTO_CLAVE          to False
        Set Shadow_State of oPRESUPUESTO_FECHA_INICIO   to False
        Set Shadow_State of oPRESUPUESTO_FECHA_FIN      to False
        Set Shadow_State of oPRESUPUESTO_VLR_QUINCENA   to False 
        Set Value of oTOTAL_E    to ''
        Set Value of oTOTAL_PGDO to ''
        Set Value of oDISPONIBLE to ''
        Set Color of Egresos  to 16641499
        Set Color of oTOTAL_E to 16777088 
    End_Procedure
    Procedure Request_Clear_All
        Forward Send Request_Clear_All
        Set Shadow_State of oPRESUPUESTO_CLAVE          to False
        Set Shadow_State of oPRESUPUESTO_FECHA_INICIO   to False
        Set Shadow_State of oPRESUPUESTO_FECHA_FIN      to False
        Set Shadow_State of oPRESUPUESTO_VLR_QUINCENA   to False 
        Set Value of oTOTAL_E    to ''
        Set Value of oTOTAL_PGDO to ''
        Set Value of oDISPONIBLE to ''
        Set Color of Egresos  to 16641499
        Set Color of oTOTAL_E to 16777088 
    End_Procedure
    Set Color to 16641499
    Set Auto_Top_View_State to True

    //FUNCIONES Y PROCEDIMIENTOS
    
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
        Send Refresh of oEgresos 2
    End_Procedure
    
    Procedure Totales 
        Local String sQ sOptionTipoPago
        Local Handle hdbc69 hstmt69
        local Integer iOptionTipoPago iOpcionVista
        Local Number nVal_TD nValPgdo nValPgdo_EF nValDispo nValDispo_EF nEgresos_EF nTotalTD_EF
        Local Number nTOTAL_EGRESOS nTOTAL_INGRESOS nDIFERENCIA nPENDIENTE_PAGO nTOTAL_PGO nDISPONIBLE
        
        Get piOpcionVista of (oClientArea(oMain(Current_object))) to iOpcionVista
        Get psOpcionPago  of (oClientArea(oMain(Current_object))) to sOptionTipoPago
    
        Move '' to sQ
        Move 0  to nVal_TD
        Append sQ " SELECT * FROM dbo.fn_ObtenerTotalesPresupuesto(" PRESUPUESTO.NUMERO ", " iOpcionVista ", '" sOptionTipoPago "'); " 
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nTOTAL_INGRESOS
              Get SQLColumnValue of hstmt69   2 to nTOTAL_EGRESOS
              Get SQLColumnValue of hstmt69   3 to nDIFERENCIA
              Get SQLColumnValue of hstmt69   4 to nTOTAL_PGO
              Get SQLColumnValue of hstmt69   5 to nPENDIENTE_PAGO
              Get SQLColumnValue of hstmt69   6 to nDISPONIBLE
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oTOTAL_E           to nTOTAL_EGRESOS
        Set Value of oTOTAL_INGRESOS    to nTOTAL_INGRESOS
        Set Value of oDIFERENCIA2       to nDIFERENCIA
        Set Value of oPENDIENTE         to nPENDIENTE_PAGO
        Set Value of oTOTAL_PGDO        to nTOTAL_PGO
        Set Value of oDISPONIBLE        to nDISPONIBLE
        
        
        If (nTOTAL_EGRESOS > nTOTAL_INGRESOS) Begin
            Set Color of oTOTAL_E to 9079551
        End
        
        If (nDISPONIBLE > 0) Begin
            Set Color of oDISPONIBLE to 16777088
        End
        
       
        
        
//        //COLOREA TOTAL SEGUN RANGO
//        If (oTOTAL_E < oTOTAL_INGRESOS) Begin
//            Set Color of oTOTAL_E  to 16777088 
//            Set Color of Egresos   to 16641499
//        End
//        Else Begin
//            Set Color of oTOTAL_E to 4227327
//            Set Color of Egresos  to 12111868
//        End
//        //COLOREA TOTAL SEGUN RANGO
//        If (nValDispo > 0) Set Color of oDISPONIBLE to 16777088 
//        Else Set Color of oDISPONIBLE_EF to 16777088 
//        
//        If (nValorDiferencia gt 0) Set Color of oDiferencia to 16777088
//        Else Set color of oDiferencia to 4227327
//
//        
//        //DIFERENCUAL VISUAL
//        Local Number nValorDiferencia
//        Move ((nIngreso+nIngreso_EF)-nTotalTD_EF) to nValorDiferencia
//        Set Value of oText_TOT_INGRESOS to  ("+ Q."+(String(nIngreso+nIngreso_EF)))
//        Set value of oText_TOT_EGRESOS  to  ("- Q."+(String(nTotalTD_EF)))
//        Set Value of oDiferencia to ("= Q."+(String(nValorDiferencia)))
//        
        
        
        
        
    End_Procedure
    
    Procedure Cargar_Eg_Fijos 
        Local String sQ
        Local Handle hdbc69 hstmt69
        Local Integer iProx
        Local Date dToday
        Sysdate dToday
    
        Move '' to sQ
        Append sQ "INSERT INTO EGRESOS (NUMERO, TIPO, DESCRIPCION, FECHA_REALIZADO, ES_FIJO_SN, MONTO, MONTO_PROYECTADO, PRESUPUESTO, FORMA_PAGO) "
        Append sQ "SELECT (SELECT COALESCE(MAX(NUMERO), 0) FROM EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO ") + ROW_NUMBER() OVER (ORDER BY TIPO), TIPO, DESCRIPCION, " (fSQL_date(dToday)) ", 'S', 0, MONTO_PROYECTADO, " PRESUPUESTO.NUMERO ", 'TD'"
        Append sQ " FROM EGRESOS WHERE ES_FIJO_SN = 'S' AND PRESUPUESTO = " (PRESUPUESTO.NUMERO-1)
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        
        Send Request_Find of oEGRESOS_DD ge Egresos.File_Number 1
        
        SQLClose hstmt69
        SQLDisconnect hdbc69
    End_Procedure
    
     Procedure Cargar_Eg_Pendientes 
        Local String sQ
        Local Handle hdbc69 hstmt69
        Local Integer iProx
        Local Date dToday
        Sysdate dToday
    
        Move '' to sQ
        Append sQ "INSERT INTO EGRESOS (NUMERO, TIPO, DESCRIPCION, FECHA_REALIZADO, ES_FIJO_SN, MONTO, MONTO_PROYECTADO, PRESUPUESTO, FORMA_PAGO) "
        Append sQ "SELECT (SELECT COALESCE(MAX(NUMERO), 0) FROM EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO ") + ROW_NUMBER() OVER (ORDER BY TIPO), TIPO, DESCRIPCION, " (fSQL_date(dToday)) ", 'N', 0, MONTO_PROYECTADO, " PRESUPUESTO.NUMERO ", 'TD'"
        Append sQ " FROM EGRESOS WHERE FORMA_PAGO = 'TC' AND PAGADO_SN = 'S' AND PRESUPUESTO = " (PRESUPUESTO.NUMERO-1)
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        
        Send Request_Find of oEGRESOS_DD ge Egresos.File_Number 1
        
        SQLClose hstmt69
        SQLDisconnect hdbc69
    End_Procedure
    Set Size to 380 501
    Set Location to 2 2
    Set Label to "„gados"
    
    Object oDbContainer3d2 is a dbContainer3d
        Set Size to 226 460
        Set Location to 117 16

        Object oEgresos is a cDbCJGrid
            Set Server to oEGRESOS_DD
            Set Size to 117 444
            Set Location to 6 4
            Set peHorizontalGridStyle to xtpGridSmallDots
            Set peVerticalGridStyle to xtpGridSmallDots
            Set piFocusCellBackColor to 16776960
            Set piSelectedRowBackColor to clRed
            Set peBorderStyle to xtpBorderNone
            Set piHighlightBackColor to clBlue
            Set pbUseAlternateRowBackgroundColor to  True

            Object oEGRESOS_NUMERO is a cDbCJGridColumn
                Entry_Item EGRESOS.NUMERO
                Set piWidth to 34
                Set psCaption to "#"
                //Set pbEditable to False
            End_Object

            Object oEGRESOS_TIPO is a cDbCJGridColumn
                Entry_Item EGRESOS.TIPO
                Set piWidth to 56
                Set psCaption to "Tipo"
                Set pbCapslock to True 
                Set Prompt_Button_Mode to PB_PromptOn
            End_Object

            Object oEGRESOS_DESCRIPCION is a cDbCJGridColumn
                Entry_Item EGRESOS.DESCRIPCION
                Set piWidth to 234
                Set psCaption to "Descripcion"
            End_Object

            Object oEGRESOS_FECHA_REALIZADO is a cDbCJGridColumn
                Entry_Item EGRESOS.FECHA_REALIZADO
                Set piWidth to 83
                Set psCaption to "Fecha"
            End_Object

            Object oEGRESOS_ES_FIJO_SN is a cDbCJGridColumn
                Entry_Item EGRESOS.ES_FIJO_SN
                Set piWidth to 55
                Set psCaption to "Es fijo?"
                Set pbCapslock to True 
                Set pbCheckbox to True
            End_Object

            Object oEGRESOS_MONTO_PROYECTADO is a cDbCJGridColumn
                Entry_Item EGRESOS.MONTO_PROYECTADO
                Set piWidth to 81
                Set psCaption to "Proyectado"
            End_Object

            Object oEGRESOS_MONTO is a cDbCJGridColumn
                Entry_Item EGRESOS.MONTO
                Set piWidth to 84
                Set psCaption to "Monto"
            End_Object

            Object oEGRESOS_PAGADO_SN is a cDbCJGridColumn
                Entry_Item EGRESOS.PAGADO_SN
                Set piWidth to 51
                Set psCaption to "Pgdo?"
                Set pbCapslock to True 
                Set pbCheckbox to True
            End_Object

            Object oEGRESOS_FORMA_PAGO is a cDbCJGridColumn
                Entry_Item EGRESOS.FORMA_PAGO
                Set piWidth to 65
                Set psCaption to "F.Pago"
                Set pbCapslock to True

                Procedure OnExit
                    Forward Send OnExit
                    
                    If (EGRESOS.FORMA_PAGO eq 'TC') Begin
                        Send Popup to oPanel_TC
                    End
                End_Procedure
            End_Object

            Object oEGRESOS_LIQUIDAR is a cDbCJGridColumn
                Entry_Item EGRESOS.LIQUIDAR
                Set piWidth to 69
                Set psCaption to "Liquidar?"
                Set pbCheckbox to True
            End_Object

            Object oEGRESOS_LIQUIDADO is a cDbCJGridColumn
                Entry_Item EGRESOS.LIQUIDADO
                Set piWidth to 76
                Set psCaption to "Liquidado"
                Set pbCheckbox to True
                Set pbEditable to False
            End_Object
        End_Object

        Object oDbGroup2 is a dbGroup
            Set Size to 90 440
            Set Location to 130 5
            Set Label to 'Integraci¢n de Gastos'
            Set Color to clScrollBar

            Object oSubdetalle_title is a TextBox
                Set Auto_Size_State to False
                Set Size to 9 290
                Set Location to 9 75
                Set Label to "-"
                Set Color to 16777088
            End_Object
            Object oDbCJGrid1 is a cDbCJGrid
                Set Server to oSUB_EGRESOS_DD
                Set Size to 61 290
                Set Location to 20 75
                Set pbUseAlternateRowBackgroundColor to True
    
                Object oSUB_EGRESOS_NUMERO is a cDbCJGridColumn
                    Entry_Item SUB_EGRESOS.NUMERO
                    Set piWidth to 34
                    Set psCaption to "#"
                End_Object
    
                Object oSUB_EGRESOS_FECHA_REALIZADO is a cDbCJGridColumn
                    Entry_Item SUB_EGRESOS.FECHA_REALIZADO
                    Set piWidth to 116
                    Set psCaption to "Fecha"
                End_Object
    
                Object oSUB_EGRESOS_DESCRIPCION is a cDbCJGridColumn
                    Entry_Item SUB_EGRESOS.DESCRIPCION
                    Set piWidth to 345
                    Set psCaption to "Descripcion"
                End_Object
    
                Object oSUB_EGRESOS_MONTO is a cDbCJGridColumn
                    Entry_Item SUB_EGRESOS.MONTO
                    Set piWidth to 85
                    Set psCaption to "Monto"
                End_Object
            End_Object
        End_Object

        Object oPanel_TC is a dbContainer3d
            Set Size to 40 124
            Set Location to 28 268
            Set Color to 16776960
            Set Popup_State to true
    
            Object oEGRESOS_TC is a dbForm
                Entry_Item EGRESOS.TC
    
                Set Server to oEGRESOS_DD
                Set Location to 15 16
                Set Size to 13 51
                Set Label to "Tarjeta Credito"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 1
                Set Prompt_Button_Mode to PB_PromptOn
            End_Object
    
            Object oButton1 is a Button
                Set Size to 20 25
                Set Location to 10 80
                Set Label to 'ok'
                Set Bitmap to 'aceptar.bmp'
            
                // fires when the button is clicked
                Procedure OnClick
                    Send Msg_Exit to oPanel_TC
                End_Procedure
            
            End_Object
        End_Object
    End_Object

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 112 458
        Set Location to 3 17

        Object oDbGroup1 is a dbGroup
            Set Size to 45 360
            Set Location to 3 6
            Set Label to "PRESUPUESTO"

            Object oPRESUPUESTO_NUMERO is a dbForm
                Entry_Item PRESUPUESTO.NUMERO
                Set Location to 10 83
                Set Size to 13 48
                Set Label to "N£mero:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
            Object oPRESUPUESTO_FECHA_INICIO is a dbForm
                Entry_Item PRESUPUESTO.FECHA_INICIO
                Set Location to 10 267
                Set Size to 13 48
                Set Label to "Fecha Inicio:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
            Object oPRESUPUESTO_FECHA_FIN is a dbForm
                Entry_Item PRESUPUESTO.FECHA_FIN
                Set Location to 25 267
                Set Size to 13 48
                Set Label to "Fecha Fin:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
            Object oPRESUPUESTO_CLAVE is a dbForm
                Entry_Item PRESUPUESTO.CLAVE
                Set Location to 10 173
                Set Size to 13 48
                Set Label to "Clave:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 2
            End_Object
            Object oPRESUPUESTO_VLR_QUINCENA is a dbForm
                Entry_Item PRESUPUESTO.VLR_QUINCENA
                Set Location to 25 173
                Set Size to 13 48
                Set Label to "Quincena"
                Set Numeric_Mask 0 to 4 2
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
            Object oPRESUPUESTO_VLR_EFECTIVO is a dbForm
                Entry_Item PRESUPUESTO.VLR_EFECTIVO
                Set Location to 25 83
                Set Size to 13 48
                Set Label to "Efectivo"
                Set Numeric_Mask 0 to 4 2
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
        End_Object

        Object oDbContainer3d4 is a dbContainer3d
            Set Size to 37 360
            Set Location to 50 6
            Set Border_Style to Border_StaticEdge

            Object oTOTAL_INGRESOS is a Form
                Set Size to 13 47
                Set Location to 4 73
                Set Label_Col_Offset to 2
                Set Label to "Total Ingresos:"
                Set Label_Justification_Mode to JMode_Right
                Set Entry_State to False
                Set Numeric_Mask item 0 to 8 2 ",*"
            
                // OnChange is called on every changed character
            //    Procedure OnChange
            //        String sValue
            //    
            //        Get Value to sValue
            //    End_Procedure
            
            End_Object
            Object oTOTAL_E is a Form
                Set Size to 13 47
                Set Location to 19 73
                Set Numeric_Mask 0 to 4 2
                Set Entry_State to False
                Set Label to "Total Egresos:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
                Set Numeric_Mask item 0 to 8 2 ",*"
            End_Object

            Object oDIFERENCIA2 is a Form
                Set Size to 13 47
                Set Location to 19 124
                Set Numeric_Mask 0 to 4 2
                Set Entry_State to False
                Set Label_Col_Offset to -1
                Set Label to "Diferencia:"
                Set Label_Justification_Mode to JMode_Top
                Set Numeric_Mask item 0 to 8 2 ",*"
                Set Enabled_State to False
            End_Object

            Object oTOTAL_PGDO is a Form
                Set Size to 13 47
                Set Location to 4 231
                Set Numeric_Mask 0 to 4 2
                Set Entry_State to False
                Set Label to "Total Pagado:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
                Set Numeric_Mask item 0 to 8 2 ",*"
                Set Enabled_State to False
            End_Object
            Object oPENDIENTE is a Form
                Set Size to 13 47
                Set Location to 19 231
                Set Numeric_Mask 0 to 4 2
                Set Entry_State to False
                Set Label to "Pendiente Pgo:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
                Set Numeric_Mask item 0 to 8 2 ",*"
            End_Object

            Object oDISPONIBLE is a Form
                Set Size to 13 47
                Set Location to 19 280
                Set Numeric_Mask 0 to 4 2
                Set Entry_State to False
                Set Label_Col_Offset to 0
                Set Label_Justification_Mode to JMode_Top
                Set Label to "Disponible:"
                Set Numeric_Mask item 0 to 8 2 ",*"
            End_Object
        End_Object

        Object oVISTA is a RadioGroup
            Set Location to 86 6
            Set Size to 21 207
        
            Object oRadio1 is a Radio
                Set Label to "Pendientes"
                Set Size to 10 47
                Set Location to 8 5
            End_Object
        
            Object oRadio2 is a Radio
                Set Label to "Pagados"
                Set Size to 10 40
                Set Location to 8 58
            End_Object
        
            Object oRadio3 is a Radio
                Set Label to "No esperados"
                Set Size to 10 60
                Set Location to 8 102
            End_Object
        
            Procedure Notify_Select_State Integer iToItem Integer iFromItem
                Forward Send Notify_Select_State iToItem iFromItem
                If (iToItem eq 0) Set psFiltro to " PAGADO_SN = 'N'"
                If (iToItem eq 1) Set psFiltro to " PAGADO_SN = 'S'"
                If (iToItem eq 2) Set psFiltro to " MONTO > MONTO_PROYECTADO "
                If (iToItem eq 3) Set psFiltro to ""
                Set piOpcionVista to iToItem
                Send Totales
                Send OnConstrain of oEGRESOS_DD
                Send Refresh of oEgresos 2
            End_Procedure

            Object oRadio4 is a Radio
                Set Size to 10 50
                Set Location to 9 169
                Set Label to "Todos"
            End_Object
        
            // If you set Current_Radio, you must set it AFTER the
            // radio objects have been created AND AFTER Notify_Select_State has been
            // created. i.e. Set in bottom-code of object at the end!!
        //    Set Current_Radio to 0
        
        End_Object

        Object oTIPO_GASTO is a RadioGroup
            Set Location to 86 217
            Set Size to 21 149
        
            Procedure Notify_Select_State Integer iToItem Integer iFromItem
                Forward Send Notify_Select_State iToItem iFromItem
                If (iToItem eq 0) Set psOpcionPago to 'TODOS'
                If (iToItem eq 1) Set psOpcionPago to 'TD'
                If (iToItem eq 2) Set psOpcionPago to 'TC'
                If (iToItem eq 3) Set psOpcionPago to 'EF'
                Send Totales
                Send OnConstrain of oEGRESOS_DD
                Send Refresh of oEgresos 2
                // for augmentation
            End_Procedure

            Object oRadio1 is a Radio
                Set Label to "Todos"
                Set Size to 10 32
                Set Location to 8 10
            End_Object
            Object oRadio2 is a Radio
                Set Label to "TD"
                Set Size to 10 23
                Set Location to 8 50
            End_Object
            Object oRadio3 is a Radio
                Set Label to "TC"
                Set Size to 10 23
                Set Location to 8 83
            End_Object
            Object oRadio4 is a Radio
                Set Size to 10 23
                Set Location to 9 116
                Set Label to "EF"
            End_Object
        
            // If you set Current_Radio, you must set it AFTER the
            // radio objects have been created AND AFTER Notify_Select_State has been
            // created. i.e. Set in bottom-code of object at the end!!
        //    Set Current_Radio to 0
        
        End_Object

        Object oCargaFijos is a Button
            Set Size to 23 30
            Set Location to 8 374
            Set Label to 'CargaFijos'
            Set Bitmap to 'upload.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                Send Cargar_Eg_Fijos
            End_Procedure
        
        End_Object
        Object oTextBox1 is a TextBox
            Set Size to 9 40
            Set Location to 33 371
            Set Label to 'Cargar Fijos'
        End_Object
        Object oCargaPendientes is a Button
            Set Size to 23 30
            Set Location to 50 375
            Set Label to 'Carga Pendientes'
            Set Bitmap to 'getmoney.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                Local Integer iConfirm
                Get Confirm 'Se cargar n los Movimientos a cr‚dito pagados de la quincena anterior, desea continuar?' 'Atencion!' to iConfirm
                
                If (iConfirm eq 1) Procedure_Return
                
                Send Cargar_Eg_Pendientes
            End_Procedure
        
        End_Object
        Object oTextBox2 is a TextBox
            Set Auto_Size_State to False
            Set Size to 23 38
            Set Location to 76 376
            Set Label to 'Cargar Gastos Pendientes'
            Set Justification_Mode to JMode_Left
        End_Object

        Object oLiquidar is a Button
            Set Size to 23 30
            Set Location to 8 417
            Set Label to 'CargaFijos'
            Set Bitmap to 'Tarjeta_mini.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                Send Liquidar
            End_Procedure
        
        End_Object

        Object oTextBox1 is a TextBox
            Set Size to 9 40
            Set Location to 33 419
            Set Label to "Liquidar"
        End_Object
    End_Object

Cd_End_Object
