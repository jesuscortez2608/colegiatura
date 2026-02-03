DROP FUNCTION if exists fun_obtener_cifras_de_control(integer);

CREATE OR REPLACE FUNCTION fun_obtener_cifras_de_control(
IN iempleado integer
, OUT empleados integer
, OUT movimientos integer
, OUT importe_factura numeric
, OUT importe_pagos numeric
, OUT importe_ajuste numeric)
  RETURNS SETOF record AS
$BODY$
DECLARE
     /*
     No. petición APS               : 8613.1
     Fecha                          : 22/11/2016
     Número empleado                : 96753269
     Nombre del empleado            : Nallely Machado
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : Obtiene las cifras de control antes de trapasar
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Traspaso de movimientos
     Ejemplo                        :
			select * from fun_obtener_cifras_de_control(95194185)
			select * from mov_facturas_colegiaturas where idu_empleado = 94827443
			
  ------------------------------------------------------------------------------------------------------ 
	No. peticion			: 16559
	Fecha				: 04/07/2018
	Colaborador			: Rafael Ramos 98439677
	Descripcion del cambio		: Se modifico para adaptarse al nuevo modo de la consulta de las cifras
					 de control del traspaso de movimientos.
	Ejemplo				: 
			select * from fun_obtener_cifras_de_control(95194185)

-----------------------------------------------------------------------------------------------------*/
	valor record;
BEGIN
	create local temp table tmp_cifras_facturas  
	(	empleados integer,
		movimientos integer,
		importe_factura numeric(12,2),
		importe_pagos numeric(12,2),
		importe_ajuste numeric(12,2)
	) on commit drop; 
    
    INSERT INTO tmp_cifras_facturas(
		empleados
		, movimientos
		, importe_factura
		, importe_pagos
		, importe_ajuste)
	select count(distinct (a.empleado)) AS empleados
		, count(a.marcado) AS movimientos
		, sum(a.importe_fac) AS importe_factura
		, sum(CASE WHEN a.clv_tipo_registro = 1 THEN a.importe_pago ELSE 0.0::NUMERIC(12,2) END) as importe_pagos
		, sum(CASE WHEN a.clv_tipo_registro = 2 THEN a.importe_pago ELSE 0.0::NUMERIC(12,2) END) as importe_ajuste
	from stmp_traspaso_colegiaturas a
	where marcado=1 
        and a.usuario=iEmpleado;
    
	FOR valor IN (SELECT  T.empleados
				, T.movimientos
				, T.importe_factura
				, T.importe_pagos
				, T.importe_ajuste
			from tmp_cifras_facturas T) 
			LOOP
				empleados	:= valor.empleados;
				movimientos	:= valor.movimientos;
				importe_factura	:= valor.importe_factura;
				importe_pagos	:= valor.importe_pagos;
				importe_ajuste	:= valor.importe_ajuste;
			RETURN NEXT ;
			END LOOP;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_cifras_de_control(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_cifras_de_control(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_cifras_de_control(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_cifras_de_control(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_cifras_de_control(integer) IS 'La función obtiene la sumatoria de importe de factura y sumatoria de importes pagados agrupados por colaborador.';