Use Windows.pkg
Use DFClient.pkg
Use DFEntry.pkg
Use cEGRESOSDataDictionary.dd
Use cPRESUPUESTO_DataDictionary.dd
Use SUB_EGRESOS.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use sql.pkg
Use dfLine.pkg
Use dfTabDlg.pkg

Deferred_View Activate_Egresos for ;
Object Egresos is a dbView
    Property String psFiltro ''
    Property Integer psOpcionPago 0
    Property Integer piOpcionVista 0
    Property Integer pProximoE public 0
    
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
    
    Object oPRESUPUESTO_DD is a cPRESUPUESTODataDictionary
        Procedure Relate_Main_File
            Send Totales
            Set Shadow_State of oPRESUPUESTO_CLAVE          to True
            Set Shadow_State of oPRESUPUESTO_FECHA_INICIO   to True
            Set Shadow_State of oPRESUPUESTO_FECHA_FIN      to True
            //Set Shadow_State of oPRESUPUESTO_VLR_QUINCENA   to True 
        End_Procedure
    End_Object
    

    Object oEGRESOS_DD is a cEGRESOSDataDictionary
        Set Constrain_file to PRESUPUESTO.File_number
        Set DDO_Server to oPRESUPUESTO_DD
        Set pbUseDDSQLFilters to True
        
        Procedure Relate_Main_File
            Forward Send Relate_Main_File
            Set Value of oSubdetalle_title to Egresos.DESCRIPCION
        End_Procedure
        
        Procedure Request_Save
            Forward Send Request_Save
            Local Integer iProxE
            Get pProximoE to iProxE
            Move iProxE             to EGRESOS.NUMERO
            Move PRESUPUESTO.NUMERO to EGRESOS.PRESUPUESTO
            
            //Evalua si el Egreso exede los egresos por mes
            If (Egresos.PAGADO_SN eq 'S') 
        End_Procedure
        
        Procedure OnConstrain
            Forward Send OnConstrain
            Local String sFiltro
            Get psFiltro to sFiltro
            Set psSQLFilter to sFiltro  
        End_Procedure
        
        
    End_Object

    Object oSUB_EGRESOS_DD is a SUB_EGRESOS_DataDictionary
        Set Constrain_file to EGRESOS.File_number
        Set DDO_Server to oEGRESOS_DD
        
        Procedure Relate_Main_File
            Send Totales
        End_Procedure
        
        Procedure Update 
            Forward Send Update 
            Add SUB_EGRESOS.MONTO to EGRESOS.MONTO
        End_Procedure
        
        Procedure Backout 
            Forward Send Backout 
            Subtract SUB_EGRESOS.MONTO from EGRESOS.MONTO
        End_Procedure
    End_Object

    Set Main_DD to oPRESUPUESTO_DD
    Set Server to oPRESUPUESTO_DD
    Set Color to 16641499
    Set Auto_Top_View_State to True

    //FUNCIONES Y PROCEDIMIENTOS
    Procedure Totales 
        Local String sQ
        Local Handle hdbc69 hstmt69
        local Integer iOptionTipoPago iOpcionVista
        Local Number nVal_TD nValPgdo nValPgdo_EF nValDispo nValDispo_EF nEgresos_EF nTotalTD_EF
        Local Number nTOTAL_EGRESOS nTOTAL_INGRESOS nDIFERENCIA nPENDIENTE_PAGO nTOTAL_PGO nDISPONIBLE
        
        Get piOpcionVista to iOpcionVista
        Get psOpcionPago  to iOptionTipoPago
    
        Move '' to sQ
        Move 0  to nVal_TD
        Append sQ " SELECT * FROM dbo.fn_ObtenerTotalesPresupuesto(" PRESUPUESTO.NUMERO ", " iOpcionVista ", " iOptionTipoPago "); " 
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nTOTAL_EGRESOS
              Get SQLColumnValue of hstmt69   2 to nTOTAL_INGRESOS
              Get SQLColumnValue of hstmt69   3 to nDIFERENCIA
              Get SQLColumnValue of hstmt69   4 to nPENDIENTE_PAGO
              Get SQLColumnValue of hstmt69   5 to nTOTAL_PGO
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
        
        
       
        
        
        //COLOREA TOTAL SEGUN RANGO
        If (oTOTAL_E < oTOTAL_INGRESOS) Begin
            Set Color of oTOTAL_E  to 16777088 
            Set Color of Egresos   to 16641499
        End
        Else Begin
            Set Color of oTOTAL_E to 4227327
            Set Color of Egresos  to 12111868
        End
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
    
    Set Border_Style to Border_Thick
    Set Size to 342 682
    Set Location to 2 2
    Set Label to "Egresos"
    
    Object oDbContainer3d2 is a dbContainer3d
        Set Size to 116 411
        Set Location to 139 16

        Object oEgresos is a cDbCJGrid
            Set Server to oEGRESOS_DD
            Set Size to 103 396
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
                Set piWidth to 30
                Set psCaption to "#"
                //Set pbEditable to False
            End_Object

            Object oEGRESOS_TIPO is a cDbCJGridColumn
                Entry_Item EGRESOS.TIPO
                Set piWidth to 48
                Set psCaption to "Tipo"
                Set pbCapslock to True 
                Set Prompt_Button_Mode to PB_PromptOn
            End_Object

            Object oEGRESOS_DESCRIPCION is a cDbCJGridColumn
                Entry_Item EGRESOS.DESCRIPCION
                Set piWidth to 196
                Set psCaption to "Descripcion"
            End_Object

            Object oEGRESOS_FECHA_REALIZADO is a cDbCJGridColumn
                Entry_Item EGRESOS.FECHA_REALIZADO
                Set piWidth to 87
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
                Set piWidth to 86
                Set psCaption to "Proyectado"
            End_Object

            Object oEGRESOS_MONTO is a cDbCJGridColumn
                Entry_Item EGRESOS.MONTO
                Set piWidth to 97
                Set psCaption to "Monto"
            End_Object

            Object oEGRESOS_PAGADO_SN is a cDbCJGridColumn
                Entry_Item EGRESOS.PAGADO_SN
                Set piWidth to 56
                Set psCaption to "Pgdo?"
                Set pbCapslock to True 
                Set pbCheckbox to True
            End_Object

            Object oEGRESOS_FORMA_PAGO is a cDbCJGridColumn
                Entry_Item EGRESOS.FORMA_PAGO
                Set piWidth to 74
                Set psCaption to "F.Pago"
                Set pbCapslock to True
            End_Object

            Object oEGRESOS_MARCAR is a cDbCJGridColumn
                Entry_Item EGRESOS.MARCAR
                Set piWidth to 63
                Set psCaption to "Marcar"
                Set pbCheckbox to True
            End_Object
        End_Object
    End_Object

    Object oCargaFijos is a Button
        Set Size to 23 30
        Set Location to 9 331
        Set Label to 'CargaFijos'
        Set Bitmap to 'upload.bmp'
    
        // fires when the button is clicked
        Procedure OnClick
            Send Cargar_Eg_Fijos
        End_Procedure
    
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 9 40
        Set Location to 16 366
        Set Label to 'Cargar Fijos'
    End_Object

    Object oCargaPendientes is a Button
        Set Size to 23 30
        Set Location to 38 331
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
        Set Size to 18 54
        Set Location to 40 364
        Set Label to 'Cargar Gastos Pendientes'
        Set Justification_Mode to JMode_Left
    End_Object

    Object oLineControl4 is a LineControl
        Set Size to 2 68
        Set Location to 108 230
    End_Object

    Object oGroup1 is a Group
        Set Size to 44 69
        Set Location to 64 332
        Set Label to '--'
        Set Color to 16777215

        Object oText_TOT_INGRESOS is a TextBox
            Set Auto_Size_State to False
            Set Size to 9 47
            Set Location to 7 13
            Set Label to 'oTextBox3'
            Set Justification_Mode to JMode_Right
        End_Object
        Object oText_TOT_EGRESOS is a TextBox
            Set Auto_Size_State to False
            Set Size to 9 47
            Set Location to 18 13
            Set Label to 'oTextBox3'
            Set Justification_Mode to JMode_Right
        End_Object
        Object oDiferencia is a TextBox
            Set Auto_Size_State to False
            Set Size to 10 47
            Set Location to 30 13
            Set Label to '--'
            Set Justification_Mode to JMode_Right
        End_Object
    End_Object

    Object oRadioGroup1 is a RadioGroup
        Set Location to 114 17
        Set Size to 22 208
        Set Label to 'Vista de Gastos'
    
        Object oRadio1 is a Radio
            Set Label to "Pendientes"
            Set Size to 10 48
            Set Location to 10 5
        End_Object
    
        Object oRadio2 is a Radio
            Set Label to "Pagados"
            Set Size to 10 42
            Set Location to 10 59
        End_Object
    
        Object oRadio3 is a Radio
            Set Label to "No esperados"
            Set Size to 10 57
            Set Location to 10 106
        End_Object

        Object oRadio4 is a Radio
            Set Size to 10 50
            Set Location to 11 169
            Set Label to 'Todos'
        End_Object
    
        Procedure Notify_Select_State Integer iToItem Integer iFromItem
            Forward Send Notify_Select_State iToItem iFromItem
            If iToItem Eq 0 Set psFiltro to " PAGADO_SN = 'N'"
            If iToItem Eq 1 Set psFiltro to " PAGADO_SN = 'S'"
            If iToItem Eq 2 Set psFiltro to " MONTO > MONTO_PROYECTADO"
            If iToItem Eq 3 Set psFiltro to " "
            Set piOpcionVista to iToItem
            Send OnConstrain of oEGRESOS_DD
            Send Refresh of oEgresos 2
        End_Procedure
    
        // If you set Current_Radio, you must set it AFTER the
        // radio objects have been created AND AFTER Notify_Select_State has been
        // created. i.e. Set in bottom-code of object at the end!!
    //    Set Current_Radio to 0
    
    End_Object

    Object oTextBox4 is a TextBox
        Set Size to 9 34
        Set Location to 192 436
        Set Label to 'Sumador: '
    End_Object
    Object oTextTotal_Suma is a TextBox
        Set Auto_Size_State to False
        Set Size to 9 35
        Set Location to 193 478
        Set Label to '--'
        Set Justification_Mode to JMode_Right
    End_Object

    Object oDbContainer3d3 is a dbContainer3d
        Set Size to 82 316
        Set Location to 258 67

        Object oDbCJGrid1 is a cDbCJGrid
            Set Server to oSUB_EGRESOS_DD
            Set Size to 59 290
            Set Location to 16 9

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

        Object oSubdetalle_title is a TextBox
            Set Auto_Size_State to False
            Set Size to 9 290
            Set Location to 3 9
            Set Label to "-"
            Set Color to 16777088
        End_Object
    End_Object

    Object oTab_MONTOS is a dbTabDialog
        Set Size to 109 308
        Set Location to 1 17
    
        Set Rotate_Mode to RM_Rotate

        Object oDbTabPage1 is a dbTabPage
            Set Label to 'MONTOS'

            Object oGroupTD is a Group
                Set Size to 91 288
                Set Location to 0 7
                Set Label to "Tarjeta Debito"

                Object oTOTAL_INGRESOS is a Form
                    Set Size to 13 62
                    Set Location to 23 70
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
                    Set Size to 13 62
                    Set Location to 38 70
                    Set Numeric_Mask 0 to 4 2
                    Set Entry_State to False
                    Set Label to "Total Egresos:"
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to JMode_Right
                    Set Numeric_Mask item 0 to 8 2 ",*"
                End_Object

                Object oTOTAL_PGDO is a Form
                    Set Size to 13 62
                    Set Location to 23 189
                    Set Numeric_Mask 0 to 4 2
                    Set Entry_State to False
                    Set Label to "Total Pagado:"
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to JMode_Right
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    Set Enabled_State to False
                End_Object

                Object oDISPONIBLE is a Form
                    Set Size to 13 62
                    Set Location to 53 189
                    Set Numeric_Mask 0 to 4 2
                    Set Entry_State to False
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to JMode_Right
                    Set Label to "Disponible:"
                    Set Numeric_Mask item 0 to 8 2 ",*"
                End_Object

                Object oDIFERENCIA2 is a Form
                    Set Size to 13 62
                    Set Location to 53 70
                    Set Numeric_Mask 0 to 4 2
                    Set Entry_State to False
                    Set Label_Col_Offset to 2
                    Set Label to "Diferencia:"
                    Set Label_Justification_Mode to JMode_Right
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    Set Enabled_State to False
                End_Object

                Object oPENDIENTE is a Form
                    Set Size to 13 62
                    Set Location to 38 189
                    Set Numeric_Mask 0 to 4 2
                    Set Entry_State to False
                    Set Label to "Pendiente:"
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to JMode_Right
                    Set Numeric_Mask item 0 to 8 2 ",*"
                End_Object
            End_Object
        End_Object
        
        Object oTab_PRESUPUESTO is a dbTabPage
            Set Label to 'PRESUPUESTO'

            Object oPRESUPUESTO_NUMERO is a dbForm
                Entry_Item PRESUPUESTO.NUMERO
                Set Location to 23 70
                Set Size to 13 66
                Set Label to "N£mero:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPRESUPUESTO_CLAVE is a dbForm
                Entry_Item PRESUPUESTO.CLAVE
                Set Location to 23 178
                Set Size to 13 66
                Set Label to "Clave:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 2
            End_Object

            Object oPRESUPUESTO_FECHA_INICIO is a dbForm
                Entry_Item PRESUPUESTO.FECHA_INICIO
                Set Location to 38 70
                Set Size to 13 66
                Set Label to "Fecha Inicio:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPRESUPUESTO_FECHA_FIN is a dbForm
                Entry_Item PRESUPUESTO.FECHA_FIN
                Set Location to 53 70
                Set Size to 13 66
                Set Label to "Fecha Fin:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPRESUPUESTO_VLR_QUINCENA is a dbForm
                Entry_Item PRESUPUESTO.VLR_QUINCENA
                Set Location to 38 178
                Set Size to 13 66
                Set Label to "Quincena"
                Set Numeric_Mask 0 to 4 2
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPRESUPUESTO_VLR_EFECTIVO is a dbForm
                Entry_Item PRESUPUESTO.VLR_EFECTIVO
                Set Location to 53 178
                Set Size to 13 66
                Set Label to "Efectivo"
                Set Numeric_Mask 0 to 4 2
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
        End_Object
    
    End_Object

    Object oRadioGroupTipos is a RadioGroup
        Set Location to 115 229
        Set Size to 22 159
        Set Label to "Tipo Gasto"
    
        Object oRadio1 is a Radio
            Set Label to "Todos"
            Set Size to 10 48
            Set Location to 10 5
        End_Object
    
        Object oRadio2 is a Radio
            Set Label to "TD"
            Set Size to 10 42
            Set Location to 10 45
        End_Object
    
        Object oRadio3 is a Radio
            Set Label to "TC"
            Set Size to 10 57
            Set Location to 10 78
        End_Object

        Object oRadio4 is a Radio
            Set Size to 10 50
            Set Location to 10 111
            Set Label to "EF"
        End_Object
    
        Procedure Notify_Select_State Integer iToItem Integer iFromItem
            Forward Send Notify_Select_State iToItem iFromItem
            Set psOpcionPago to iToItem
            Send Totales
        End_Procedure
    
        // If you set Current_Radio, you must set it AFTER the
        // radio objects have been created AND AFTER Notify_Select_State has been
        // created. i.e. Set in bottom-code of object at the end!!
    //    Set Current_Radio to 0
    
    End_Object

Cd_End_Object
