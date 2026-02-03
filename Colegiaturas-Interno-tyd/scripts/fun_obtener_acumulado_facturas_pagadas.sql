DROP FUNCTION IF EXISTS fun_obtener_acumulado_facturas_pagadas(integer, integer);
DROP TYPE IF EXISTS type_acumulado_facturas_pagadas;

CREATE TYPE type_acumulado_facturas_pagadas AS
   (acumuladofacturas numeric(12,2),
    toperestante numeric(12,2));

CREATE OR REPLACE FUNCTION fun_obtener_acumulado_facturas_pagadas(integer, integer)
  RETURNS SETOF type_acumulado_facturas_pagadas AS
$BODY$
declare 
	iNumEmp ALIAS FOR $1;
	iSueldo ALIAS FOR $2;
	anioActual integer;
	nImportePagado numeric (12,2);
	nImporteAutorizado numeric (12,2);
	nSueldo numeric (12,2);
	
	cAcumuladoFacturas varchar(20);
	cTopeRestante varchar(20);
	registros type_acumulado_facturas_pagadas;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 05/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.24
	     Descripción del funcionamiento : Regresa el acumulado de la facturas del año de un empleado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Facturas
	     Ejemplo                        : 
		 select * from fun_obtener_acumulado_facturas_pagadas (95194185,1000000);
	---------------------------------------------------------------------------------------------------------------
		Peticion: 		16659.1
		Colaborador:		98439677 Rafael Ramos
		Descripcion cambio:	Se agregan los totales de los ajustes de las facturas
		Ejemplo:
			SELECT * FROM fun_obtener_acumulado_facturas_pagadas (98439677, 1160000);
	*/
	
BEGIN
	nSueldo:= cast((iSueldo/100)*6 as numeric (12,2));
	anioActual:= cast((DATE_PART('year', now())) as integer);
	nImportePagado:=0.00;
	nImporteAutorizado:=0.00;
	IF EXISTS ( SELECT idu_empleado from his_facturas_colegiaturas where idu_empleado = iNumEmp and cast((DATE_PART('year', fec_factura)) as integer) = anioActual) then
	    SELECT sum(det.importe_concepto) INTO nImportePagado
            from his_detalle_facturas_colegiaturas as det
		INNER JOIN his_facturas_colegiaturas as his on (det.idfactura = his.idfactura)
            where det.idu_empleado=iNumEmp 
		AND his.idu_estatus = 6
                and cast((DATE_PART('year', det.fec_registro)) as integer)=anioActual
                and his.idu_beneficiario_externo = 0
                and his.idu_tipo_documento in (1,3,4);
            
            nImportePagado :=  coalesce(nImportePagado, 0.00);

		select	sum(det.importe_concepto) into nImporteAutorizado
		from 	mov_detalle_facturas_colegiaturas as det
			INNER JOIN mov_facturas_colegiaturas as mov on (det.idfactura = mov.idfactura)
		where	det.idu_empleado=iNumEmp 
			AND mov.idu_estatus = 2
			and cast((DATE_PART('year', det.fec_registro)) as integer)=anioActual
			and mov.idu_beneficiario_externo = 0
			and mov.idu_tipo_documento in (1,3,4);
            
		nImportePagado := nImportePagado + coalesce(nImporteAutorizado, 0);

        elsif exists ( select idu_empleado from mov_facturas_colegiaturas where idu_empleado = iNumEmp and cast((DATE_PART('year', fec_factura)) as integer) = anioActual) then
		SELECT	sum(det.importe_concepto) INTO nImportePagado
		from 	his_detalle_facturas_colegiaturas as det
			INNER JOIN his_facturas_colegiaturas as his on (det.idfactura = his.idfactura)
		where 	det.idu_empleado=iNumEmp 
			AND his.idu_estatus = 6
			and cast((DATE_PART('year', det.fec_registro)) as integer)=anioActual
			and his.idu_beneficiario_externo = 0
			and his.idu_tipo_documento in (1,3,4);
            
		nImportePagado :=  coalesce(nImportePagado, 0.00);
            
		select	sum(det.importe_concepto) into nImporteAutorizado
		from 	mov_detalle_facturas_colegiaturas as det
			INNER JOIN mov_facturas_colegiaturas as mov on (det.idfactura = mov.idfactura)
		where	det.idu_empleado=iNumEmp 
			AND mov.idu_estatus = 2
			and cast((DATE_PART('year', det.fec_registro)) as integer)=anioActual
			and mov.idu_beneficiario_externo = 0
			and mov.idu_tipo_documento in (1,3,4);
            
		nImportePagado := nImportePagado + coalesce(nImporteAutorizado, 0);
	END IF ;
	
	FOR registros IN 
	(
		SELECT (nImportePagado), (nSueldo - nImportePagado)
	) 
	LOOP
		RETURN NEXT registros;
	END LOOP;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_acumulado_facturas_pagadas(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_acumulado_facturas_pagadas(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_acumulado_facturas_pagadas(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_acumulado_facturas_pagadas(integer, integer) TO postgres;
