DROP FUNCTION IF EXISTS fun_grabar_estatus_factura(integer, integer, integer, text, integer);
drop type if exists type_grabar_estatus_factura;

CREATE TYPE type_grabar_estatus_factura AS
   (estatus integer,
    mensaje character varying(100));

CREATE OR REPLACE FUNCTION fun_grabar_estatus_factura(integer, integer, integer, text, integer)
  RETURNS SETOF type_grabar_estatus_factura AS
$BODY$
DECLARE
	/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		SELECT fun_grabar_estatus_factura(15::INTEGER, 93902761::INTEGER, 1::INTEGER, 'AUTORIZADO POR GERENTE'::TEXT)
	------------------------------------------------------------------------------------------------------ 
	Fecha				: 07/03/2018
	Numero empleado			: 98439677
	Nombre del empleado		: Rafael Ramos Gutierrez
	Descripcion del cambio		: Se le agrega valor al campo "idu_motivo_rechazo"
	------------------------------------------------------------------------------------------------------ */
	iFactura alias for $1;
	iEmpleadoMarcoEstatus alias for $2;
	iEstatus alias for $3;
	sDesObservaciones alias FOR $4;
	iMotivo alias for $5;
	iEstatusAnterior integer;
	iDiasTranscurridos integer;
	iReturn integer;
	sMensaje VARCHAR(100);
	returnrec type_grabar_estatus_factura;
BEGIN
    iEstatusAnterior := (select idu_estatus from mov_facturas_colegiaturas where idfactura = iFactura limit 1);
    iDiasTranscurridos := (select extract(DAY from current_timestamp - fec_marco_estatus::timestamp)
        from mov_facturas_colegiaturas 
        where idfactura = iFactura limit 1);
    
    if iEstatusAnterior = 1 
        and iEstatus = 0 
        and iDiasTranscurridos > 0 then
        iReturn := -1; -- El gerente sólo podrá cancelar facturas si no ha pasado un día de haberla autorizado
        sMensaje := 'El gerente sólo podrá rechazar facturas si no ha pasado un día de haberla autorizado';
    else
        update mov_facturas_colegiaturas set idu_estatus = iEstatus
            , fec_marco_estatus = now()
            , emp_marco_estatus = iEmpleadoMarcoEstatus
            , des_observaciones = RTRIM(LTRIM(UPPER(sDesObservaciones)))
            , idu_motivo_rechazo = iMotivo	-- <--- Cambio(Agrego linea)
        where idfactura = iFactura;
        iReturn := 1;
        sMensaje := 'Estatus actualizado correctamente';
    end if;
    
    FOR returnrec IN (
        select iReturn as estado
            , sMensaje as mensaje
    ) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_factura(integer, integer, integer, text, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_factura(integer, integer, integer, text, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_factura(integer, integer, integer, text, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_estatus_factura(integer, integer, integer, text, integer) TO postgres;