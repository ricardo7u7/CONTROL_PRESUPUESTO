Use Windows.pkg
Use DFClient.pkg
Use DFEntry.pkg
Use cEGRESOSDataDictionary.dd
Use cPRESUPUESTO_DataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use sql.pkg
Use dfLine.pkg

Deferred_View Activate_Egresos for ;
Object Egresos is a dbView
    Property String psFiltro ''
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
        
        Procedure Request_Save
            Send Asigna_No_Detalle
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

    Set Main_DD to oPRESUPUESTO_DD
    Set Server to oPRESUPUESTO_DD
    Set Color to 16641499
    Set Auto_Top_View_State to True

    //FUNCIONES Y PROCEDIMIENTOS
    Procedure Totales 
        Local String sQ
        Local Handle hdbc69 hstmt69
        Local Number nVal_TD nValPgdo nValPgdo_EF nValDispo nValDispo_EF nEgresos_EF nTotalTD_EF
    
        Move '' to sQ
        Move 0  to nVal_TD
        Append sQ " SELECT SUM(MONTO) FROM EGRESOS WHERE FORMA_PAGO = 'TD' AND PRESUPUESTO = " PRESUPUESTO.NUMERO
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nVal_TD
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oTOTAL_E   to nVal_TD
        
        //Calculamos egresos en efectivo
        
        Move '' to sQ
        Move 0  to nEgresos_EF
        Append sQ " SELECT SUM(MONTO) FROM EGRESOS WHERE FORMA_PAGO = 'EF' AND PRESUPUESTO = " PRESUPUESTO.NUMERO
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nEgresos_EF
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Move (nVal_TD+nEgresos_EF) to nTotalTD_EF
        Set Value of oTOTAL_E_EF   to nEgresos_EF
        
        
        //COLOREA TOTAL SEGUN RANGO
        If (nTotalTD_EF < 2500) Begin
            Set Color of oTOTAL_E to 16777088 
            Set Color of Egresos   to 16641499
            Set Color of oTextBox1 to 16641499
            Set Color of oTextBox2 to 16641499
        End
        Else If (nTotalTD_EF < 3500) Begin
            Set Color of oTOTAL_E to 4227327
            Set Color of Egresos  to 12111868
            Set Color of oTextBox1 to 12111868
            Set Color of oTextBox2 to 12111868
        End
        Else If (nTotalTD_EF > 3500) Begin
            Set Color of oTOTAL_E to 255 
            Set Color of Egresos  to 9803263
            Set Color of oTextBox1 to 9803263
            Set Color of oTextBox2 to 9803263
        End
        
        // CALCULAMOS VALOR PAGADO TD 
        Move '' to sQ
        Move 0  to nValPgdo
        Append sQ " SELECT SUM(MONTO) FROM EGRESOS WHERE PAGADO_SN = 'S' AND FORMA_PAGO = 'TD' AND PRESUPUESTO = " PRESUPUESTO.NUMERO
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nValPgdo
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oTOTAL_PGDO to nValPgdo
        
        // CALCULAMOS VALOR PAGADO EF 
        Move '' to sQ
        Move 0  to nValPgdo_EF
        Append sQ " SELECT SUM(MONTO) FROM EGRESOS WHERE PAGADO_SN = 'S' AND FORMA_PAGO = 'EF' AND PRESUPUESTO = " PRESUPUESTO.NUMERO
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nValPgdo_EF
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oTOTAL_PGDO_EF to nValPgdo_EF
        
        // CALCULAMOS DISPONIBLE QUINCENA
        Local Number nIngreso nIngreso_EF
        Move '' to sQ
        Move 0  to nIngreso
        Move 0  to nIngreso_EF
        Append sQ " SELECT VLR_QUINCENA, VLR_EFECTIVO FROM PRESUPUESTO WHERE NUMERO = " PRESUPUESTO.NUMERO
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nIngreso
              Get SQLColumnValue of hstmt69   2 to nIngreso_EF
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Move (nIngreso - nValPgdo) to nValDispo
        Move (nIngreso_EF - nValPgdo_EF) to nValDispo_EF
        Set Value of oDISPONIBLE to nValDispo
        Set Value of oDISPONIBLE_EF to nValDispo_EF
        
        
        //PROCESO MUESTRA ITEMS SUMADOS
        Local Number nTotal_suma
        Move '' to sQ
        Move 0  to nTotal_suma
        Append sQ " SELECT SUM(MONTO) FROM EGRESOS WHERE MARCAR = 'S' AND PRESUPUESTO = " PRESUPUESTO.NUMERO
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to nTotal_suma
           End
        Until (not(SQLResult))
        SQLClose hstmt69
        SQLDisconnect hdbc69
        
        Set Value of oTextTotal_Suma to nTotal_suma
        
        //DIFERENCUAL VISUAL
        Local Number nValorDiferencia
        Move ((nIngreso+nIngreso_EF)-nTotalTD_EF) to nValorDiferencia
        Set Value of oText_TOT_INGRESOS to  ("+ Q."+(String(nIngreso+nIngreso_EF)))
        Set value of oText_TOT_EGRESOS  to  ("- Q."+(String(nTotalTD_EF)))
        Set Value of oDiferencia to ("= Q."+(String(nValorDiferencia)))
        
        If (nValorDiferencia gt 0) Set Color of oDiferencia to 16777088
        Else Set color of oDiferencia to 4227327
        
        
        //COLOREA TOTAL SEGUN RANGO
        If (nValDispo > 0) Begin
            Set Color of oDISPONIBLE to 16777088 
        End
        
        If (nValDispo_EF > 0) Begin
            Set Color of oDISPONIBLE_EF to 16777088 
        End
    End_Procedure
    
    Procedure Asigna_No_Detalle 
        Local String sQ
        Local Handle hdbc69 hstmt69
        Local Integer iProx
    
        Move '' to sQ
        Move 0  to iProx
        Append sQ " SELECT MAX(NUMERO) FROM EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        Repeat
           SQLFileFetch hstmt69
           If (SQLResult) Begin
              Get SQLColumnValue of hstmt69   1 to iProx
           End
        Until (not(SQLResult))
        
        Set pProximoE to iProx
        
        SQLClose hstmt69
        SQLDisconnect hdbc69
    End_Procedure
    
    Procedure Cargar_Eg_Fijos 
        Local String sQ
        Local Handle hdbc69 hstmt69
        Local Integer iProx
        Local Date dToday
        Sysdate dToday
    
        Move '' to sQ
        Append sQ "INSERT INTO EGRESOS (NUMERO, TIPO, DESCRIPCION, FECHA_REALIZADO, ES_FIJO_SN, MONTO, PRESUPUESTO) "
        Append sQ "SELECT (SELECT COALESCE(MAX(NUMERO), 0) FROM EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO ") + ROW_NUMBER() OVER (ORDER BY TIPO), TIPO, DESCRIPCION, " (fSQL_date(dToday)) ", 'S', MONTO, " PRESUPUESTO.NUMERO 
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
        Append sQ "INSERT INTO EGRESOS (NUMERO, TIPO, DESCRIPCION, FECHA_REALIZADO, ES_FIJO_SN, MONTO, PRESUPUESTO, FORMA_PAGO) "
        Append sQ "SELECT (SELECT COALESCE(MAX(NUMERO), 0) FROM EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO ") + ROW_NUMBER() OVER (ORDER BY TIPO), TIPO, DESCRIPCION, " (fSQL_date(dToday)) ", 'S', MONTO, " PRESUPUESTO.NUMERO ", 'TD'"
        Append sQ " FROM EGRESOS WHERE FORMA_PAGO = 'TC' AND PAGADO_SN = 'S' AND PRESUPUESTO = " (PRESUPUESTO.NUMERO-1)
        SQLFileConnect EGRESOS to hdbc69
        SQLOpen hdbc69 to hstmt69
        SQLExecDirect hstmt69 sQ
        
        Send Request_Find of oEGRESOS_DD ge Egresos.File_Number 1
        
        SQLClose hstmt69
        SQLDisconnect hdbc69
    End_Procedure
    
    Set Border_Style to Border_Thick
    Set Size to 342 409
    Set Location to 2 2
    Set Label to "Egresos"

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 106 301
        Set Location to 6 15

        Object oPRESUPUESTO_NUMERO is a dbForm
            Entry_Item PRESUPUESTO.NUMERO
            Set Location to 8 72
            Set Size to 13 66
            Set Label to "NUMERO:"
        End_Object

        Object oPRESUPUESTO_CLAVE is a dbForm
            Entry_Item PRESUPUESTO.CLAVE
            Set Location to 24 72
            Set Size to 13 66
            Set Label to "CLAVE:"
        End_Object

        Object oPRESUPUESTO_FECHA_INICIO is a dbForm
            Entry_Item PRESUPUESTO.FECHA_INICIO
            Set Location to 38 72
            Set Size to 13 66
            Set Label to "FECHA INICIO:"
        End_Object

        Object oPRESUPUESTO_FECHA_FIN is a dbForm
            Entry_Item PRESUPUESTO.FECHA_FIN
            Set Location to 53 72
            Set Size to 13 66
            Set Label to "FECHA FIN:"
        End_Object

        Object oDISPONIBLE is a dbForm
            Set Size to 13 56
            Set Location to 85 164
            Set Numeric_Mask 0 to 4 2
            Set Entry_State to False
        End_Object

        Object oTextBox1 is a TextBox
            Set Size to 9 48
            Set Location to 77 168
            Set Label to 'Disponible TD'
        End_Object

        Object oLineControl1 is a LineControl
            Set Size to 104 1
            Set Location to 0 150
            Set Horizontal_State to False
        End_Object

        Object oDISPONIBLE_EF is a dbForm
            Set Size to 13 56
            Set Location to 85 236
            Set Numeric_Mask 0 to 4 2
            Set Entry_State to False
        End_Object

        Object oTextBox1 is a TextBox
            Set Size to 9 46
            Set Location to 77 240
            Set Label to 'Disponible EF'
        End_Object

        Object oPRESUPUESTO_VLR_QUINCENA is a dbForm
            Entry_Item PRESUPUESTO.VLR_QUINCENA
            Set Location to 68 72
            Set Size to 13 66
            Set Label to "QUINCENA:"
            Set Numeric_Mask 0 to 4 2
        End_Object

        Object oPRESUPUESTO_VLR_EFECTIVO is a dbForm
            Entry_Item PRESUPUESTO.VLR_EFECTIVO
            Set Location to 83 72
            Set Size to 13 66
            Set Label to "EFECTIVO:"
            Set Numeric_Mask 0 to 4 2
        End_Object

        Object oLineControl1 is a LineControl
            Set Size to 104 1
            Set Location to 0 150
            Set Horizontal_State to False
        End_Object

        Object oLineControl2 is a LineControl
            Set Size to 2 100
            Set Location to 26213 226
        End_Object

        Object oLineControl3 is a LineControl
            Set Size to 105 1
            Set Location to 0 228
            Set Horizontal_State to False
        End_Object

        Object oTOTAL_PGDO is a dbForm
            Set Size to 13 56
            Set Location to 62 164
            Set Numeric_Mask 0 to 4 2
            Set Entry_State to False
        End_Object
        Object oTextBox1 is a TextBox
            Set Size to 9 44
            Set Location to 53 170
            Set Label to 'Total Pagado'
        End_Object
        Object oTOTAL_E is a dbForm
            Set Size to 13 56
            Set Location to 38 164
            Set Numeric_Mask 0 to 4 2
            Set Entry_State to False
        End_Object
        Object oTextBox1 is a TextBox
            Set Size to 9 55
            Set Location to 29 164
            Set Label to 'Total de Egresos'
        End_Object
        Object oTextBox1 is a TextBox
            Set Size to 9 55
            Set Location to 9 164
            Set Label to 'TARJETA DEBITO'
        End_Object

        Object oTOTAL_PGDO_EF is a dbForm
            Set Size to 13 56
            Set Location to 62 236
            Set Numeric_Mask 0 to 4 2
            Set Entry_State to False
        End_Object
        Object oTextBox1 is a TextBox
            Set Size to 9 44
            Set Location to 53 242
            Set Label to 'Total Pagado'
        End_Object
        Object oTOTAL_E_EF is a dbForm
            Set Size to 13 56
            Set Location to 38 236
            Set Numeric_Mask 0 to 4 2
            Set Entry_State to False
        End_Object
        Object oTextBox1 is a TextBox
            Set Size to 9 55
            Set Location to 29 236
            Set Label to 'Total de Egresos'
        End_Object
        Object oTextBox1 is a TextBox
            Set Size to 9 55
            Set Location to 9 245
            Set Label to 'EFECTIVO'
        End_Object
    End_Object
    
    Object oDbContainer3d2 is a dbContainer3d
        Set Size to 187 375
        Set Location to 116 16

        Object oEgresos is a cDbCJGrid
            Set Server to oEGRESOS_DD
            Set Size to 173 360
            Set Location to 6 4
            Set peHorizontalGridStyle to xtpGridSmallDots
            Set peVerticalGridStyle to xtpGridSmallDots
            Set piFocusCellBackColor to 16776960
            Set piSelectedRowBackColor to 16777132
            Set peBorderStyle to xtpBorderNone
            Set piHighlightBackColor to clBlue

            Object oEGRESOS_NUMERO is a cDbCJGridColumn
                Entry_Item EGRESOS.NUMERO
                Set piWidth to 32
                Set psCaption to "#"
                //Set pbEditable to False
            End_Object

            Object oEGRESOS_TIPO is a cDbCJGridColumn
                Entry_Item EGRESOS.TIPO
                Set piWidth to 51
                Set psCaption to "Tipo"
                Set pbCapslock to True 
                Set Prompt_Button_Mode to PB_PromptOn
            End_Object

            Object oEGRESOS_DESCRIPCION is a cDbCJGridColumn
                Entry_Item EGRESOS.DESCRIPCION
                Set piWidth to 218
                Set psCaption to "Descripcion"
            End_Object

            Object oEGRESOS_FECHA_REALIZADO is a cDbCJGridColumn
                Entry_Item EGRESOS.FECHA_REALIZADO
                Set piWidth to 89
                Set psCaption to "Fecha"
            End_Object

            Object oEGRESOS_ES_FIJO_SN is a cDbCJGridColumn
                Entry_Item EGRESOS.ES_FIJO_SN
                Set piWidth to 57
                Set psCaption to "Es fijo?"
                Set pbCapslock to True 
                Set pbCheckbox to True
            End_Object

            Object oEGRESOS_MONTO is a cDbCJGridColumn
                Entry_Item EGRESOS.MONTO
                Set piWidth to 93
                Set psCaption to "Monto"
            End_Object

            Object oEGRESOS_PAGADO_SN is a cDbCJGridColumn
                Entry_Item EGRESOS.PAGADO_SN
                Set piWidth to 52
                Set psCaption to "Pgdo?"
                Set pbCapslock to True 
                Set pbCheckbox to True
            End_Object

            Object oEGRESOS_FORMA_PAGO is a cDbCJGridColumn
                Entry_Item EGRESOS.FORMA_PAGO
                Set piWidth to 67
                Set psCaption to "F.Pago"
                Set pbCapslock to True
            End_Object

            Object oEGRESOS_MARCAR is a cDbCJGridColumn
                Entry_Item EGRESOS.MARCAR
                Set piWidth to 61
                Set psCaption to "Marcar"
                Set pbCheckbox to True
            End_Object
        End_Object
    End_Object

    Object oCargaFijos is a Button
        Set Size to 23 30
        Set Location to 6 320
        Set Label to 'CargaFijos'
        Set Bitmap to 'upload.bmp'
    
        // fires when the button is clicked
        Procedure OnClick
            Send Cargar_Eg_Fijos
        End_Procedure
    
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 9 40
        Set Location to 13 353
        Set Label to 'Cargar Fijos'
    End_Object

    Object oCargaPendientes is a Button
        Set Size to 23 30
        Set Location to 34 320
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
        Set Location to 36 353
        Set Label to 'Cargar Gastos Pendientes'
        Set Justification_Mode to JMode_Left
    End_Object

    Object oLineControl4 is a LineControl
        Set Size to 2 68
        Set Location to 108 230
    End_Object

    Object oGroup1 is a Group
        Set Size to 44 69
        Set Location to 65 322
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

    Object oTextTotal_Suma is a TextBox
        Set Auto_Size_State to False
        Set Size to 9 35
        Set Location to 310 352
        Set Label to '--'
        Set Justification_Mode to JMode_Right
    End_Object

    Object oTextBox4 is a TextBox
        Set Size to 9 23
        Set Location to 310 312
        Set Label to 'Sumador: '
    End_Object

    Object oRadioGroup1 is a RadioGroup
        Set Location to 311 15
        Set Size to 27 159
        Set Label to 'Vista de Gastos'
    
        Object oRadio1 is a Radio
            Set Label to "Pendientes"
            Set Size to 10 48
            Set Location to 10 5
        End_Object
    
        Object oRadio2 is a Radio
            Set Label to "Pagados"
            Set Size to 10 42
            Set Location to 10 58
        End_Object
    
        Object oRadio3 is a Radio
            Set Label to "Todos"
            Set Size to 10 61
            Set Location to 10 109
        End_Object
    
        Procedure Notify_Select_State Integer iToItem Integer iFromItem
            Forward Send Notify_Select_State iToItem iFromItem
            If iToItem Eq 0 Set psFiltro to " PAGADO_SN = 'N'"
            If iToItem Eq 1 Set psFiltro to " PAGADO_SN = 'S'"
            If iToItem Eq 2 Set psFiltro to " "
            Send OnConstrain of oEGRESOS_DD
            Send Refresh of oEgresos 2
        End_Procedure
    
        // If you set Current_Radio, you must set it AFTER the
        // radio objects have been created AND AFTER Notify_Select_State has been
        // created. i.e. Set in bottom-code of object at the end!!
    //    Set Current_Radio to 0
    
    End_Object

Cd_End_Object
