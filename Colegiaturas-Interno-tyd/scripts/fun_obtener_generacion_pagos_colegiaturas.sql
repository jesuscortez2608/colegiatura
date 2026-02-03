 DROP FUNCTION if exists fun_obtener_generacion_pagos_colegiaturas();

CREATE OR REPLACE FUNCTION fun_obtener_generacion_pagos_colegiaturas(
OUT idu_empleado integer
, OUT importe_pagado integer)
  RETURNS SETOF record AS
$BODY$
declare
/*----------------------------------------------------------------------------
	No.Petición:			16559.1
	Fecha:				13/06/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:				PERSONAL    
	Servidor:			10.44.2.183
	Sistema:			Colegiaturas
	Modulo: 			Generar Pagos Colegiaturas
----------------------------------------------------------------------------*/
	valor record;
Begin
	create temporary table tmp_pagos(
	 iEmpleado integer not null default 0
	 , nImportePagado integer not null default 0
	)on commit drop;

	insert into	tmp_pagos(iEmpleado, nImportePagado)
	select		GP.idu_empleado, (GP.importe_pagado*100)
	from		mov_generacion_pagos_colegiaturas GP;

	for valor in (select
			iEmpleado
			, nImportePagado
			from tmp_pagos
			order by iEmpleado
				, nImportePagado)
			loop
				idu_empleado	:= valor.iEmpleado::integer;
				importe_pagado	:= valor.nImportePagado::integer;
			return next;
			end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_generacion_pagos_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_generacion_pagos_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_generacion_pagos_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_generacion_pagos_colegiaturas() TO postgres;
COMMENT ON FUNCTION fun_obtener_generacion_pagos_colegiaturas() IS 'La función obtiene un listado con los pagos generados durante el proceso de generación de pagos para formar un XML que se enviará al servicio de Colegiaturas, que a su vez actualizará el ISR de los importes generados con esta consulta.';