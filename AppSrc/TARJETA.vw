Use Windows.pkg
Use DFClient.pkg
Use cDbCJGrid.pkg
Use TARJETA.dd
Use cPRESUPUESTO_DataDictionary.dd
Use cEGRESOSDataDictionary.dd
Use cdbCJGridColumn.pkg
Use DFEntry.pkg

Deferred_View Activate_TARJETA for ;
Object TARJETA is a dbView
    Object oPRESUPUESTO_DD is a cPRESUPUESTODataDictionary
    End_Object

    Object oEGRESOS_DD is a cEGRESOSDataDictionary
        Set DDO_Server to oPRESUPUESTO_DD
        
        Procedure OnConstrain
            Forward Send OnConstrain
            
            Constrain EGRESOS.TC eq TARJETA.NUMERO
        End_Procedure
        
    End_Object

    Object oTARJETA_DD is a TARJETA_DataDictionary
    End_Object

    Set Main_DD to oTARJETA_DD
    Set Server to oTARJETA_DD

    Set Border_Style to Border_Thick
    Set Size to 217 479
    Set Location to 2 2
    Set Label to "TARJETA"
    Set Color to 16641499

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 176 449
        Set Location to 12 15

        Object oDbGroup1 is a dbGroup
            Set Size to 53 414
            Set Location to 7 19
            Set Label to "Tarjetas de Credito:"

            Object oTARJETA_NUMERO is a dbForm
                Entry_Item TARJETA.NUMERO
                Set Location to 12 34
                Set Size to 13 53
                Set Label to "#"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 2
            End_Object
            Object oTARJETA_CLAVE is a dbForm
                Entry_Item TARJETA.CLAVE
                Set Location to 28 34
                Set Size to 13 53
                Set Label to "Clave:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oTARJETA_DESCRIPCION is a dbForm
                Entry_Item TARJETA.DESCRIPCION
                Set Location to 28 145
                Set Size to 13 124
                Set Label to "Descripcion:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oTARJETA_LIMITE is a dbForm
                Entry_Item TARJETA.LIMITE
                Set Location to 12 145
                Set Size to 13 33
                Set Label to "Limite TC:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oTARJETA_LIMITE_MAX is a dbForm
                Entry_Item TARJETA.LIMITE_MAX
                Set Location to 11 235
                Set Size to 13 33
                Set Label to "Limite Personal:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oTARJETA_DIA_PAGO is a dbForm
                Entry_Item TARJETA.DIA_PAGO
                Set Location to 11 319
                Set Size to 13 54
                Set Label to "D¡a Pago:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oTARJETA_DIA_CORTE is a dbForm
                Entry_Item TARJETA.DIA_CORTE
                Set Location to 28 319
                Set Size to 13 54
                Set Label to "D¡a Corte:"
                Set Label_Col_Offset to 2
                Set Label_Justification_Mode to JMode_Right
            End_Object
        End_Object

        Object oDbGroup2 is a dbGroup
            Set Size to 104 414
            Set Location to 61 18
            Set Label to 'Movimientos'

            Object oDbCJGrid1 is a cDbCJGrid
                Set Server to oEGRESOS_DD
                Set Size to 81 397
                Set Location to 14 11

                Object oEGRESOS_TIPO is a cDbCJGridColumn
                    Entry_Item EGRESOS.TIPO
                    Set piWidth to 41
                    Set psCaption to "Tipo"
                End_Object

                Object oEGRESOS_DESCRIPCION is a cDbCJGridColumn
                    Entry_Item EGRESOS.DESCRIPCION
                    Set piWidth to 153
                    Set psCaption to "Descripcion"
                End_Object

                Object oEGRESOS_FECHA_REALIZADO is a cDbCJGridColumn
                    Entry_Item EGRESOS.FECHA_REALIZADO
                    Set piWidth to 83
                    Set psCaption to "F.Realizado"
                End_Object

                Object oEGRESOS_ES_FIJO_SN is a cDbCJGridColumn
                    Entry_Item EGRESOS.ES_FIJO_SN
                    Set piWidth to 38
                    Set psCaption to "Fijo?"
                    Set pbCheckbox to True
                End_Object

                Object oEGRESOS_MONTO is a cDbCJGridColumn
                    Entry_Item EGRESOS.MONTO
                    Set piWidth to 72
                    Set psCaption to "Pagado"
                End_Object

                Object oEGRESOS_MONTO_PROYECTADO is a cDbCJGridColumn
                    Entry_Item EGRESOS.MONTO_PROYECTADO
                    Set piWidth to 80
                    Set psCaption to "Proyectado"
                End_Object

                Object oEGRESOS_PRESUPUESTO is a cDbCJGridColumn
                    Entry_Item PRESUPUESTO.NUMERO
                    Set piWidth to 87
                    Set psCaption to "Presupuesto"
                End_Object

                Object oEGRESOS_PAGADO_SN is a cDbCJGridColumn
                    Entry_Item EGRESOS.PAGADO_SN
                    Set piWidth to 60
                    Set psCaption to "Pgdo?"
                    Set pbCheckbox to True
                End_Object

                Object oEGRESOS_LIQUIDAR is a cDbCJGridColumn
                    Entry_Item EGRESOS.LIQUIDAR
                    Set piWidth to 96
                    Set psCaption to "Liquidar"
                    Set pbCheckbox to True
                End_Object

                Object oEGRESOS_LIQUIDADO is a cDbCJGridColumn
                    Entry_Item EGRESOS.LIQUIDADO
                    Set piWidth to 84
                    Set psCaption to "Liquidado"
                    Set pbCheckbox to True
                End_Object
            End_Object
        End_Object
    End_Object

Cd_End_Object
