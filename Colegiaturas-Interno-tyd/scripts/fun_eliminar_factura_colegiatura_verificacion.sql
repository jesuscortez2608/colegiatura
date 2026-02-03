DROP FUNCTION IF EXISTS fun_eliminar_factura_colegiatura_verificacion(integer, character varying);

CREATE OR REPLACE FUNCTION fun_eliminar_factura_colegiatura_verificacion(integer, character varying)
  RETURNS integer AS
$BODY$
/*
	No. petición APS               : 
	Fecha                          : 12/12/2019
	Número empleado                : 98439677
	Nombre del empleado            : Rafael Ramos Gutiérrez
	Base de datos                  : Personal
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : Funcion para validacion de estatus y eliminacion de facturas del sistema de colegiaturas de Intranet
	Descripción del cambio         : N/A
	Sistema                        : Colegiaturas
	Módulo                         : Seguimiento_facturas
	Ejemplo                        : 
		
	------------------------------------------------------------------------------------------------------ */


DECLARE
	idColaborador 	ALIAS FOR $1;
	sFolioFiscal	ALIAS FOR $2;
	
	iEstatusFactura INTEGER default 0;
	iResultado SMALLINT NOT NULL DEFAULT 0;
BEGIN
	create temp table tmp_resultado(
		state integer not null default 0
		, message character varying(200) not null default ''
	) on commit drop;

	create temp table tmp_estatus_validos_eliminar
	(
		idu_estatus integer not null default 0
		, nom_estatus character varying(150) not null default ''
	) on commit drop;

		INSERT INTO tmp_estatus_validos_eliminar (idu_estatus, nom_estatus)
		VALUES (0, 'PENDIENTE')
			, (2, 'RECHAZO GERENTE')
			, (4, 'RECHAZO PERSONAL SELECCION')
			, (6, 'RECHAZO AUDITORIA')
			, (8, 'RECHAZO PERSONAL ADMINISTRACION');
			
	iEstatusFactura := (SELECT ctl.idu_estatus_factura FROM ctl_facturas_empleados AS ctl
				WHERE ctl.idu_tipo_factura = 2 
					AND ctl.num_empleado = idColaborador 
					AND RTRIM(LTRIM(UPPER(ctl.idu_foliofiscal))) = RTRIM(LTRIM(UPPER(sFolioFiscal))) );

	if EXISTS(SELECT tmp.idu_estatus FROM tmp_estatus_validos_eliminar AS tmp WHERE tmp.idu_estatus = iEstatusFactura) THEn
	
		delete from ctl_facturas_empleados where num_empleado = idColaborador  and RTRIM(LTRIM(UPPER(idu_foliofiscal))) =  RTRIM(LTRIM(UPPER(sFolioFiscal)));
		delete from cat_detalles_factura where RTRIM(LTRIM(UPPER(num_folio))) = RTRIM(LTRIM(UPPER(sFolioFiscal)));

		iResultado := 1;
	ELSE
		iResultado := 0;
	END IF;

	return iResultado;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_eliminar_factura_colegiatura_verificacion(integer, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_eliminar_factura_colegiatura_verificacion(integer, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_eliminar_factura_colegiatura_verificacion(integer, character varying) TO sysetl;
COMMENT ON FUNCTION fun_eliminar_factura_colegiatura_verificacion(integer, character varying) IS 'La función verifica si el estatus de la factura esta en los permitidos para eliminar';