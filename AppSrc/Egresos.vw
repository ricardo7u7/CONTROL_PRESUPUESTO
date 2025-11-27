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
Use cEGRESOSDataDictionary.dd
Use SUB_EGRESOS.dd
Use cTIPO_GASTO_DataDictionary.dd
Use dfTable.pkg

Deferred_View Activate_Egresos for ;
Object Egresos is a dbView
    
    Property String psFiltro ''
    Property String psOpcionPago 'TODOS'
    Property Integer piOpcionVista 3

    Object oTIPO_GASTO_DD is a cTIPO_GASTO_DataDictionary
    End_Object

    Object oPRESUPUESTO_DD is a cPRESUPUESTODataDictionary
        Procedure Relate_Main_File
            Forward Send Relate_Main_File
            Set Shadow_State of oPRESUPUESTO_CLAVE          to True
            Set Shadow_State of oPRESUPUESTO_FECHA_INICIO   to True
            Set Shadow_State of oPRESUPUESTO_FECHA_FIN      to True
            Set Shadow_State of oPRESUPUESTO_VLR_QUINCENA   to True 
            Set Shadow_State of oPRESUPUESTO_VLR_EFECTIVO   to True 
            
            If (PRESUPUESTO.ESTATUS eq 'B') Begin
                Set Bitmap of  oEstatus to 'lock-close.bmp'
                Set Read_Only_State of oEgresos to True
                Set Read_Only_State of oSubEgresos to True
            End
            Else Begin
                Set Bitmap of  oEstatus to 'lock-open.bmp'
                Set Read_Only_State of oEgresos to False
                Set Read_Only_State of oSubEgresos to False
            End
            Send Totales
        End_Procedure
    End_Object
    
    Function GetClientArea Returns Handle
        Handle hoClient
        Move (oClientArea(oMain(ghoApplication))) to hoClient
        Function_Return hoClient
    End_Function

    Object oEGRESOS_DD is a cEGRESOSDataDictionary
        //Set DDO_Server to oTIPO_GASTO_DD
        Set Constrain_file to PRESUPUESTO.File_number
        Set DDO_Server to oPRESUPUESTO_DD
        
        Procedure Relate_Main_File
            Forward Send Relate_Main_File
            Clear TIPO_GASTO
            Move Egresos.TIPO to TIPO_GASTO.CLAVE
            Find eq TIPO_GASTO by Index.2
        End_Procedure
        
       Procedure OnConstrain
            Forward Send OnConstrain
            Set pbUseDDSQLFilters to True
            Local String @Filtro @Filtro2 @Tipo_Gasto
            Local Integer @Vista 
            
            Move '' to @Filtro2
            
            // Usa una referencia directa al oClientArea
            Get psFiltro       to @Filtro
            Get piOpcionVista  to @Vista
            Get psOpcionPago   to @Tipo_Gasto
            
            If (@Filtro ne '') Begin
                Append @Filtro2 @Filtro 
            End
            
            If (@Tipo_Gasto ne 'TODOS' and @Tipo_Gasto ne '') Begin
                If (@Filtro ne '') Append @Filtro2 ' AND FORMA_PAGO = ' ("'"+@Tipo_Gasto+"'")
                Else               Append @Filtro2 ' FORMA_PAGO = ' ("'"+@Tipo_Gasto+"'")
            End
            
            If (@Vista ne 3) Begin
                If (@Filtro ne '') Append @Filtro2 " AND "
                If (@Vista EQ 0) Append @Filtro2   " PAGADO_SN = 'N'"
                If (@Vista EQ 1) Append @Filtro2   " PAGADO_SN = 'S'"
                If (@Vista EQ 2) Append @Filtro2   " MONTO > MONTO_PROYECTADO"
            End
            
            Set psSQLFilter to @Filtro2
        End_Procedure
    End_Object

    Object oSUB_EGRESOS_DD is a SUB_EGRESOS_DataDictionary
        Set Constrain_file to EGRESOS.File_number
        Set DDO_Server to oEGRESOS_DD
        
        Procedure Request_Save
            Forward Send Request_Save
            Move PRESUPUESTO.NUMERO to SUB_EGRESOS.PRESUPUESTO
            Move EGRESOS.NUMERO to SUB_EGRESOS.EGRESO
        End_Procedure
    End_Object

    Set Main_DD to oEGRESOS_DD
    Set Server to oEGRESOS_DD
    
    Procedure Request_Delete
        Send Totales
    End_Procedure
    
    
    Procedure Request_Clear
        Forward Send Request_Clear
        Set Shadow_State of oPRESUPUESTO_CLAVE          to False
        Set Shadow_State of oPRESUPUESTO_FECHA_INICIO   to False
        Set Shadow_State of oPRESUPUESTO_FECHA_FIN      to False
        Set Shadow_State of oPRESUPUESTO_VLR_QUINCENA   to False 
        Set Shadow_State of oPRESUPUESTO_VLR_EFECTIVO   to False 
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
        Set Shadow_State of oPRESUPUESTO_VLR_EFECTIVO   to False 
        Set Value of oTOTAL_E    to ''
        Set Value of oTOTAL_PGDO to ''
        Set Value of oDISPONIBLE to ''
        Set Color of Egresos  to 16641499
        Set Color of oTOTAL_E to 16777088 
    End_Procedure
    Set Color to 16641499
    Set Auto_Top_View_State to True

    //FUNCIONES Y PROCEDIMIENTOS
    
    Procedure Elimina_Registros
        Local String sQ
        Local Handle hdbc hstmt
        
        Move '' to sQ
        Append sQ "DELETE EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO
        
        SQLFileConnect EGRESOS to hdbc
        SQLOpen hdbc to hstmt
        SQLExecDirect hstmt sQ
        SQLClose hstmt
        SQLDisconnect hdbc
        
        Send Request_Find of oEGRESOS_DD ge Egresos.File_Number 1
        Send Beginning_of_Data to oEgresos
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
        Send Beginning_of_Data to oEgresos
    End_Procedure
    
    Procedure Totales 
        Local String sQ sOptionTipoPago
        Local Handle hdbc69 hstmt69
        local Integer iOptionTipoPago iOpcionVista
        Local Number nVal_TD nValPgdo nValPgdo_EF nValDispo nValDispo_EF nEgresos_EF nTotalTD_EF
        Local Number nTOTAL_EGRESOS nTOTAL_INGRESOS nDIFERENCIA nPENDIENTE_PAGO nTOTAL_PGO nDISPONIBLE
        
        Get piOpcionVista  to iOpcionVista
        Get psOpcionPago   to sOptionTipoPago
    
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
        
    End_Procedure
    
//    Procedure Cargar_Eg_Fijos 
//        Local String sQ
//        Local Handle hdbc69 hstmt69
//        Local Integer iProx
//        Local Date dToday
//        Sysdate dToday
//    
//        Move '' to sQ
//        Append sQ "INSERT INTO EGRESOS (NUMERO, TIPO, DESCRIPCION, FECHA_REALIZADO, ES_FIJO_SN, MONTO, MONTO_PROYECTADO, PRESUPUESTO, FORMA_PAGO) "
//        Append sQ "SELECT (SELECT COALESCE(MAX(NUMERO), 0) FROM EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO ") + ROW_NUMBER() OVER (ORDER BY TIPO), TIPO, DESCRIPCION, " (fSQL_date(dToday)) ", 'S', 0, MONTO_PROYECTADO, " PRESUPUESTO.NUMERO ", 'TD'"
//        Append sQ " FROM EGRESOS WHERE ES_FIJO_SN = 'S' AND PRESUPUESTO = " (PRESUPUESTO.NUMERO-1)
//        SQLFileConnect EGRESOS to hdbc69
//        SQLOpen hdbc69 to hstmt69
//        SQLExecDirect hstmt69 sQ
//        
//        Send Request_Find of oEGRESOS_DD ge Egresos.File_Number 1
//        
//        SQLClose hstmt69
//        SQLDisconnect hdbc69
//    End_Procedure

    Procedure Cargar_Eg_Fijos
        Local String sQ sFechaInicio
        Local Handle hdbc69 hstmt69
        Local Date dToday
        Local String sTipoQuincena
        Local Integer iDiaInicio
        
        Sysdate dToday
        Move PRESUPUESTO.FECHA_INICIO to sFechaInicio
        
        // Extraer el d¡a: saltar 3 caracteres (MM/) y leer 2 (dd)
        Move (Integer(Mid(sFechaInicio, 2, 1))) to iDiaInicio
        
        // Determinar tipo de quincena del presupuesto actual
        If (iDiaInicio <= 15) Begin
            Move 'PQ' to sTipoQuincena  // Primera Quincena
        End
        Else Begin
            Move 'SQ' to sTipoQuincena  // Segunda Quincena
        End
        
        // Construir query para insertar gastos fijos
        Move '' to sQ
        Append sQ "INSERT INTO EGRESOS (NUMERO, TIPO, DESCRIPCION, FECHA_REALIZADO, ES_FIJO_SN, MONTO, MONTO_PROYECTADO, PRESUPUESTO, FORMA_PAGO) "
        Append sQ "SELECT "
        Append sQ "(SELECT COALESCE(MAX(NUMERO), 0) FROM EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO ") + ROW_NUMBER() OVER (ORDER BY EF.TIPO), "
        Append sQ "EF.TIPO, "
        Append sQ "EF.DESCRIPCION, "
        Append sQ (fSQL_date(dToday)) ", "
        Append sQ "'S', "  // ES_FIJO_SN
        Append sQ "0, "    // MONTO (inicial en 0)
        Append sQ "EF.MONTO_PROYECTADO, "
        Append sQ PRESUPUESTO.NUMERO ", "
        Append sQ "EF.FORMA_PAGO "
        Append sQ "FROM EGRESOS_FIJOS EF "
        Append sQ "WHERE EF.QUINCENA = '2Q' "  // Siempre incluir los que aplican a ambas
        Append sQ "OR EF.QUINCENA = '" sTipoQuincena "'"  // M s los espec¡ficos de esta quincena
        
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
     
     
    Set Size to 348 543
    Set Location to 2 2
    Set Label to "„gados"
    
    Object oDbContainer3d2 is a dbContainer3d
        Set Size to 209 460
        Set Location to 117 16

        Object oDbGroup2 is a dbGroup
            Set Size to 79 440
            Set Location to 123 5
            Set Label to 'Integraci¢n de Gastos'
            Set Color to clScrollBar
            //Set Wrap_State to True 

            Object oSubEgresos is a dbGrid
                Set Size to 66 275
                Set Location to 8 86
                Set Wrap_State to True

                Begin_Row
                    Entry_Item SUB_EGRESOS.NUMERO
                    Entry_Item SUB_EGRESOS.FECHA_REALIZADO
                    Entry_Item SUB_EGRESOS.DESCRIPCION
                    Entry_Item SUB_EGRESOS.MONTO
                End_Row

                Set Main_File to SUB_EGRESOS.File_Number

                Set Server to oSUB_EGRESOS_DD

                Set Form_Width      item 0 to 19
                Set Header_Label    item 0 to "#"
                Set Form_Width      item 1 to 60
                Set Header_Label    item 1 to "Fecha"
                Set Form_Width 2 to 142
                Set Header_Label    item 2 to "Descripcion"
                Set Form_Width      item 3 to 50
                Set Header_Label    item 3 to "Monto"
                Set CurrentCellColor to 16777088
                Set CurrentRowColor to 8454143
                
                Set Column_Shadow_State item 0 to True 
                Set Column_Entry_msg item 1 to Salida 
                
                Procedure Salida 
                    Local Date dFechaIngresada dSysdate
                    Local Integer iRow
                    Local String sDescIngresada
                    
                    Sysdate dSysdate
                    Get Base_Item to iRow
                    Get Value (iRow+1) to dFechaIngresada
                    Get Value (iRow+2) to sDescIngresada
                    
                    If (dFechaIngresada eq '') Begin
                        Set value item (iRow+1) to dSysdate
                        Set Item_Changed_State (iRow+1) to True
                    End
                    If (sDescIngresada eq '') Begin
                        Set Value item (iRow+2) to ((trim(TIPO_GASTO.DESCRIPCION))+' '+String(dSysdate))
                        Set Item_Changed_State (iRow+2) to True
                    End
                End_Procedure
            End_Object
        End_Object

        Object oEgresos is a dbGrid
            Set Size to 94 448
            Set Location to 25 5
            Set Wrap_State to True

            Begin_Row
                Entry_Item EGRESOS.NUMERO
                Entry_Item EGRESOS.TIPO
                Entry_Item EGRESOS.DESCRIPCION
                Entry_Item EGRESOS.FECHA_REALIZADO
                Entry_Item EGRESOS.ES_FIJO_SN
                Entry_Item EGRESOS.MONTO_PROYECTADO
                Entry_Item EGRESOS.MONTO
                Entry_Item EGRESOS.PAGADO_SN
                Entry_Item EGRESOS.FORMA_PAGO
            End_Row

            Set Main_File to EGRESOS.File_Number

            Set Form_Width 0 to 18
            Set Header_Label 0 to "#"
            Set Form_Width 1 to 28
            Set Header_Label 1 to "Tipo"
            Set Form_Width 2 to 164
            Set Header_Label 2 to "Descripcion"
            Set Form_Width 3 to 47
            Set Header_Label 3 to "Fecha"
            Set Form_Width 4 to 25
            Set Header_Label 4 to "Fijo?"
            Set Column_CheckBox_State 4 to True
            Set Form_Width 5 to 47
            Set Header_Label 5 to "Proyectado"
            Set Form_Width 6 to 50
            Set Header_Label 6 to "Monto"
            Set Form_Width 7 to 27
            Set Header_Label 7 to "Pgdo?"
            Set Column_CheckBox_State 7 to True
            Set Form_Width 8 to 37
            Set Header_Label 8 to "F.Pago"
            
            Set CurrentRowColor to 65535
            Set CurrentCellColor to 16777088
            Set peGridLineColor to 12369084
            
            Set Column_Prompt_Object item 1 to TIPO_GASTO_SL
            Set Column_Exit_msg item 1 to Carga_Desc 
            Set Column_Entry_msg item 3 to AsignaFecha
            
            Set Column_Shadow_State item 0 to True 
            Set Column_CapsLock_State item 1 to True
            Set Column_CapsLock_State item 8 to True 
            
            Procedure AsignaFecha 
                Local Date dFechaIngresada dSysdate
                Local Integer iRow
                
                Sysdate dSysdate
                Get Base_Item to iRow
                Get Value (iRow+3) to dFechaIngresada
                
                If (dFechaIngresada eq '') Begin
                    Set value item (iRow+3) to dSysdate
                    Set Item_Changed_State (iRow+3) to True
                End
            End_Procedure
            
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

        Object oVISTA is a RadioGroup
            Set Location to -1 52
            Set Size to 21 207
            Set Current_Radio of oVISTA to 3  // Inicializa en "Todos"
        
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
                Send Beginning_of_Data to oEgresos
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
            Set Location to -1 264
            Set Size to 21 149
        
            Procedure Notify_Select_State Integer iToItem Integer iFromItem
                Forward Send Notify_Select_State iToItem iFromItem
                If (iToItem eq 0) Set psOpcionPago to 'TODOS'
                If (iToItem eq 1) Set psOpcionPago to 'TD'
                If (iToItem eq 2) Set psOpcionPago to 'TC'
                If (iToItem eq 3) Set psOpcionPago to 'EF'
                Send Totales
                Send OnConstrain of oEGRESOS_DD
                Send Beginning_of_Data to oEgresos
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
    End_Object

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 112 458
        Set Location to 3 17

        Object oDbGroup1 is a dbGroup
            Set Size to 45 360
            Set Location to 3 6
            Set Label to "PRESUPUESTO"

            Object oPRESUPUESTO_NUMERO is a dbForm
                Use PRESUPUESTO.sl
                Entry_Item PRESUPUESTO.NUMERO
                Set Location to 10 73
                Set Size to 13 48
                Set Label to "N£mero:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
                Set Prompt_Button_Mode to PB_PromptOn
                Set Prompt_Object to PRESUPUESTO_SL

                Procedure Exiting Handle hoDestination Returns Integer
                    Integer iRetVal
                    Forward Get msg_Exiting hoDestination to iRetVal
                    Local Integer iNumero_presupuesto
                    Get Value of oPRESUPUESTO_NUMERO to iNumero_presupuesto
                    
                    If (iNumero_presupuesto ne 0 or iNumero_presupuesto ne '') Begin
                        Clear PRESUPUESTO
                        Move iNumero_presupuesto to PRESUPUESTO.NUMERO
                        Find eq PRESUPUESTO by Index.1
                        If [not Found] Begin
                            Send Stop_Box 'Numero presupuesto Inv lido...' "!"
                            Move 1 to iRetVal
                        End
                        Else Begin
                            Send Request_Find of oPRESUPUESTO_DD GE PRESUPUESTO.File_Number 1 
                        End
                    End
                    
                    
                    Procedure_Return iRetVal
                End_Procedure
            End_Object

            Object oPRESUPUESTO_CLAVE is a dbForm
                Entry_Item PRESUPUESTO.CLAVE
                Set Location to 10 163
                Set Size to 13 48
                Set Label to "Clave:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 2
            End_Object

            Object oPRESUPUESTO_VLR_EFECTIVO is a dbForm
                Entry_Item PRESUPUESTO.VLR_EFECTIVO

                Set Server to oPRESUPUESTO_DD
                Set Location to 25 73
                Set Size to 13 48
                Set Label to "Efectivo"
                Set Numeric_Mask 0 to 4 2
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPRESUPUESTO_VLR_QUINCENA is a dbForm
                Entry_Item PRESUPUESTO.VLR_QUINCENA

                Set Server to oPRESUPUESTO_DD
                Set Location to 25 163
                Set Size to 13 48
                Set Label to "Quincena"
                Set Numeric_Mask 0 to 4 2
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
            Object oPRESUPUESTO_FECHA_INICIO is a dbForm
                Entry_Item PRESUPUESTO.FECHA_INICIO
                Set Location to 10 257
                Set Size to 13 48
                Set Label to "Fecha Inicio:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
            Object oPRESUPUESTO_FECHA_FIN is a dbForm
                Entry_Item PRESUPUESTO.FECHA_FIN
                Set Location to 25 257
                Set Size to 13 48
                Set Label to "Fecha Fin:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right

                Procedure Exiting Handle hoDestination Returns Integer
                    Integer iRetVal
                    Forward Get msg_Exiting hoDestination to iRetVal
                    Send Request_Save of oPRESUPUESTO_DD
                    Procedure_Return iRetVal
                End_Procedure
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
                Set Numeric_Mask item 0 to 8 2 ",*"
                Set Entry_State to False
            
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
                Set Label to "Total Egresos:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
                Set Numeric_Mask item 0 to 8 2 ",*"
                Set Entry_State to False
            End_Object

            Object oDIFERENCIA2 is a Form
                Set Size to 13 47
                Set Location to 19 124
                Set Numeric_Mask 0 to 4 2
                Set Label_Col_Offset to -1
                Set Label to "Diferencia:"
                Set Label_Justification_Mode to JMode_Top
                Set Numeric_Mask item 0 to 8 2 ",*"
                Set Enabled_State to False
                Set Entry_State to False
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

        Object oCargaFijos is a Button
            Set Size to 23 30
            Set Location to 7 380
            Set Label to 'CargaFijos'
            Set Bitmap to 'upload.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                If (PRESUPUESTO.ESTATUS eq 'B') Procedure_Return
                Send Cargar_Eg_Fijos
            End_Procedure
        
        End_Object
        Object oCargaPendientes is a Button
            Set Size to 23 30
            Set Location to 34 418
            Set Label to 'Carga Pendientes'
            Set Bitmap to 'delete.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                Local Integer iConfirm
                
                If (PRESUPUESTO.ESTATUS ne 'B') Begin
                    Get Confirm 'Se eliminaran todos los registros de la quincena, desea continuar?' 'Atencion!' to iConfirm
                
                    If (iConfirm eq 1) Procedure_Return
                
                    Send Elimina_Registros
                End
                
            End_Procedure
        
        End_Object

        Object oImprimir is a Button
            Set Size to 23 30
            Set Location to 7 417
            Set Label to 'Print'
            Set Bitmap to 'Print.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                Send RunReport of oReporte_VDF
            End_Procedure
        
        End_Object

        Object oEstatus is a Button
            Set Size to 23 30
            Set Location to 34 380
            Set Label to 'Print'
            Set Bitmap to 'lock-open.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                Local Integer iConfirm
                If (PRESUPUESTO.ESTATUS ne 'B') Begin
                    Get Confirm 'Desea cerrar el presupuesto ?' to iConfirm
                    If (iConfirm eq 0) Begin
                        
                        // calculamos valor de cierre 
                        Local String sQ 
                        Local Handle hdbc69 hstmt69
                        Local Number nValor_Disponible
                        
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
                        
                        
                        Reread PRESUPUESTO
                        Move 'B' to PRESUPUESTO.ESTATUS
                        Move nValor_Disponible to PRESUPUESTO.SALDO_CIERRE
                        SaveRecord PRESUPUESTO
                        Unlock
                        Send Request_Save to oPRESUPUESTO_DD
                    End
                    Else Procedure_Return
                End
                Else Begin
                    Reread PRESUPUESTO
                    Move 'A' to PRESUPUESTO.ESTATUS
                    Move 0 to PRESUPUESTO.SALDO_CIERRE
                    SaveRecord PRESUPUESTO
                    Unlock
                    Send Request_Save to oPRESUPUESTO_DD
                End
            End_Procedure
        
        End_Object

        Object oRecargar is a Button
            Set Size to 23 30
            Set Location to 61 380
            Set Label to 'Print'
            Set Bitmap to 'refresh.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                Local Integer iConfirm
                If (PRESUPUESTO.ESTATUS ne 'B') Begin
                    // calculamos valor de cierre 
                    Local String sQ 
                    Local Handle hdbc69 hstmt69
                    Local Number nValor_Disponible
                    
                    Move '' to sQ
                    Move 0  to nValor_Disponible
                    Append sQ " UPDATE PRESUPUESTO SET SALDO_INICIAL = (SELECT SALDO_CIERRE FROM PRESUPUESTO WHERE NUMERO_INTERNO = " (PRESUPUESTO.NUMERO-1) ") WHERE NUMERO_INTERNO = " PRESUPUESTO.NUMERO  
                    SQLFileConnect EGRESOS to hdbc69
                    SQLOpen hdbc69 to hstmt69
                    SQLExecDirect hstmt69 sQ
                    SQLClose hstmt69
                    SQLDisconnect hdbc69
                    Send Request_Save to oPRESUPUESTO_DD
                End
                Else Begin
                    Send UserError 'Presupuesto cerrado, imposible continuar...' 'Atencion!'
                    Procedure_Return
                End
            End_Procedure
        
        End_Object

        Object oGenerarMovimiento is a Button
            Set Size to 23 30
            Set Location to 61 418
            Set Label to 'Print'
            Set Bitmap to 'bajar.bmp'
        
            // fires when the button is clicked
            Procedure OnClick
                Local Integer iConfirm
                Local Date dSysdate
                Sysdate dSysdate
                If (PRESUPUESTO.ESTATUS ne 'B') Begin
                    Get Confirm 'Se generar  movimiento a partir de saldo anterior, desea continuar?' to iConfirm
                    If (iConfirm eq 0) Begin
                        
                        If (PRESUPUESTO.SALDO_INICIAL gt 0) Begin
                            Reread PRESUPUESTO
                            Add PRESUPUESTO.SALDO_INICIAL to PRESUPUESTO.VLR_EFECTIVO
                            SaveRecord PRESUPUESTO
                            Unlock
                            Send Request_Save to oPRESUPUESTO_DD
                        End
                        Else Begin
                            // Obtenemos el numero ultimo 
                            Local String sQ 
                            Local Handle hdbc69 hstmt69
                            Local Number nProx 
                            
                            Move '' to sQ
                            Move 0  to nProx
                            Append sQ " SELECT MAX(NUMERO) FROM EGRESOS WHERE PRESUPUESTO = " PRESUPUESTO.NUMERO 
                            SQLFileConnect EGRESOS to hdbc69
                            SQLOpen hdbc69 to hstmt69
                            SQLExecDirect hstmt69 sQ
                            Repeat
                               SQLFileFetch hstmt69
                               If (SQLResult) Begin
                                  Get SQLColumnValue of hstmt69   1 to nProx
                               End
                            Until (not(SQLResult))
                            SQLClose hstmt69
                            SQLDisconnect hdbc69
                            
                            Clear EGRESOS
                            Move (nProx+1)          to EGRESOS.NUMERO
                            Move PRESUPUESTO.NUMERO to EGRESOS.PRESUPUESTO
                            Move 0                  to EGRESOS.MONTO
                            Move (PRESUPUESTO.SALDO_INICIAL*-1) to EGRESOS.MONTO_PROYECTADO
                            Move 'N'                to EGRESOS.ES_FIJO_SN
                            Move 'OT'               to EGRESOS.TIPO
                            Move 'Gasto generado de saldo Inicial' to EGRESOS.DESCRIPCION
                            Move  dSysdate          to EGRESOS.FECHA_REALIZADO
                            Move 'N'                to EGRESOS.PAGADO_SN
                            Move 'TD'               to EGRESOS.FORMA_PAGO
                            Save EGRESOS
                            Send Beginning_of_Data to oEgresos
                        End
                    End
                    Else Procedure_Return
                End
                Else Begin
                    Send UserError 'Presupuesto cerrado, imposible continuar...' 'Atencion!'
                    Procedure_Return
                End
            End_Procedure
        
        End_Object

        Object oPRESUPUESTO_SALDO_INICIAL is a dbForm
            Entry_Item PRESUPUESTO.SALDO_INICIAL
            Set Location to 91 80
            Set Size to 13 102
            Set Label to "SALDO INICIAL:"
            Set Form_Datatype to Mask_Numeric_Window
            Set Entry_State to False
            Set Color to 16777088
        End_Object

        Object oPRESUPUESTO_SALDO_CIERRE is a dbForm
            Entry_Item PRESUPUESTO.SALDO_CIERRE
            Set Location to 90 258
            Set Size to 13 102
            Set Label to "SALDO CIERRE:"
            Set Entry_State to False
            Set Form_Datatype to Mask_Numeric_Window
            Set Color to 16777088
        End_Object
    End_Object
    
    
    // RV 03/07/2025: VDF REPORT 
     Object oReporte_VDF is a cDRReport
            Set psReportName to 'PPTO.dr'
            
            Procedure OnInitializeReport 
                // Basic Variables
                String sReportId sUsuario sQuery3 sTemp  sEmpresa
                Variant[][] vResultSQL 
                Integer iRow iFicha
                Handle  hdbc2 hstmt2
                Local Date dFechaIni dFechaFin
                Local String @Empresa @CtroCsto
                Local Integer iNivel
                Get psReportId  to sReportId
                
                // =============================  EJECUCION SQL =====================================
                
                Move 0 to iRow
                Append sQuery3 "SELECT P.CLAVE, IIF( E.ES_FIJO_SN = 'S', 'Gastos Fijos', 'Gastos Variables'), E.DESCRIPCION, "; 
                               " CONVERT(VARCHAR, E.FECHA_REALIZADO, 103) AS FECHA_REALIZADO," ;
                               " E.MONTO_PROYECTADO, E.MONTO, (E.MONTO_PROYECTADO - E.MONTO) AS DIFERENCIA FROM EGRESOS E "; 
                               " INNER JOIN TIPO_GASTO TG ON E.TIPO = TG.CLAVE INNER JOIN PRESUPUESTO P ON E.PRESUPUESTO = P.NUMERO " ;
                               " WHERE E.PRESUPUESTO = " PRESUPUESTO.NUMERO " AND (E.MONTO <> 0 OR E.MONTO_PROYECTADO <> 0)" ;
                               " ORDER BY E.ES_FIJO_SN DESC, E.MONTO DESC,  E.TIPO, FECHA_REALIZADO asc"
                SQLFileConnect EGRESOS to hdbc2
                SQLOpen hdbc2 to hstmt2
                SQLExecDirect hstmt2 sQuery3 
                
                Repeat
                    SQLFileFetch hstmt2
                    Number iSalarioTotal
                    If (SQLResult <> 0) Begin
                        Move (ToOEM(hstmt2)) to hstmt2 // TRADUCIMOS CON SIGNOS ESPECIALES
                        Get SQLColumnValue of hstmt2 1 to vResultSQL[iRow][0] 
                        Get SQLColumnValue of hstmt2 2 to vResultSQL[iRow][1] 
                        Get SQLColumnValue of hstmt2 3 to vResultSQL[iRow][2] 
                        Get SQLColumnValue of hstmt2 4 to vResultSQL[iRow][3] 
                        Get SQLColumnValue of hstmt2 5 to vResultSQL[iRow][4] 
                        Get SQLColumnValue of hstmt2 6 to vResultSQL[iRow][5] 
                        Get SQLColumnValue of hstmt2 7 to vResultSQL[iRow][6] 
//                        Get SQLColumnValue of hstmt2 8 to vResultSQL[iRow][7] 
                    End
                    Increment iRow
                Until (SQLResult = 0)  
                
                // CERRAR SQL ==========================================================================
                Send SQLClose of hstmt2
                Send SQLDisconnect of hdbc2
                
                tDRTableName[] TableNames
                Get RDSTableNames sReportId to TableNames
                
                //Enviar informacion a Tablas
                Send TableData sReportId 0 vResultSQL
                
            End_Procedure
            
            Procedure PreviewClick
            End_Procedure
     End_Object // fin de VDF report
     


Cd_End_Object
