CREATE OR REPLACE FUNCTION fun_obtener_notificaciones_por_empleado(integer, integer)
  RETURNS SETOF type_obtener_notificaciones_por_empleado AS
$BODY$
DECLARE
	nEmpleado alias for $1;
	nFactura alias for $2;

	nNotificar integer not null default 0;
	registros type_obtener_notificaciones_por_empleado;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 28/10/2016
	     Número empleado                : 96753269
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Obtiene las notificaciones de un empleado
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Autorizar o rechazar facturas
	     Ejemplo                        :
		select * from fun_obtener_notificaciones_por_empleado(93902761, 0)

		select * from fun_obtener_notificaciones_por_empleado(96799251, 0)

		SELECT id_factura, idu_empleado_origen, idu_empleado_destino, comentario, opc_leido, TRIM(to_char(fec_registro,'dd/MM/yyyy')),TRIM(to_char(fec_registro,'HH:MI PM'))
		--fec_registro , nNotificar
		from mov_blog_aclaraciones WHERE idu_empleado_destino != 96799251;    
		opc_leido=0 AND idu_empleado_destino = 96799251;

		select * from mov_blog_aclaraciones

  ------------------------------------------------------------------------------------------------------ */
begin
	create local temp table tmp_facturas  
	(
		id_factura integer,
		empleado_origen integer,
		nom_origen varchar(150),
		empleado_des integer,
		nom_des varchar(150),
		comentario text,
		opc_leido integer,
		fecha varchar(10),
		hora varchar(10),
		notificar integer, 
		fechareg timestamp
	) on commit drop; 
	
	IF nFactura!=0 THEN

		nNotificar:= COUNT(opc_leido) FROM mov_blog_aclaraciones WHERE opc_leido=0 AND idu_empleado_destino= nEmpleado AND id_factura=nFactura; --MOSTRAR NOTIFICACIONES PENDIENTES
		insert into tmp_facturas (id_factura, empleado_origen, empleado_des, comentario, opc_leido, fecha,hora,fechareg, notificar )
		SELECT id_factura, idu_empleado_origen, idu_empleado_destino, comentario, opc_leido, TRIM(to_char(fec_registro,'dd/MM/yyyy')),TRIM(to_char(fec_registro,'HH:MI PM')),fec_registro , nNotificar
		from mov_blog_aclaraciones WHERE  id_factura=nFactura;
	ELSE
		nNotificar:= COUNT(opc_leido) FROM mov_blog_aclaraciones WHERE opc_leido=0 AND idu_empleado_destino= nEmpleado; --MOSTRAR NOTIFICACIONES PENDIENTES
		insert into tmp_facturas (id_factura, empleado_origen, empleado_des, comentario, opc_leido, fecha,hora,fechareg, notificar )
		SELECT id_factura, idu_empleado_origen, idu_empleado_destino, comentario, opc_leido, TRIM(to_char(fec_registro,'dd/MM/yyyy')),TRIM(to_char(fec_registro,'HH:MI PM')),fec_registro , nNotificar
		from mov_blog_aclaraciones WHERE opc_leido=0 AND idu_empleado_destino = nEmpleado;

	END IF;

	update tmp_facturas set nom_origen=trim(a.nombre)||' '||trim(a.apellidopaterno)||' '||trim(a.apellidomaterno) from sapcatalogoempleados a
	WHERE a.numempn=tmp_facturas.empleado_origen;

	update tmp_facturas set nom_des=trim(a.nombre)||' '||trim(a.apellidopaterno)||' '||trim(a.apellidomaterno) from sapcatalogoempleados a
	WHERE a.numempn=tmp_facturas.empleado_des;
	

	for registros in SELECT id_factura, empleado_origen, nom_origen, empleado_des, nom_des, comentario, opc_leido, fecha ,hora, notificar  from tmp_facturas order by fechareg 
	loop	
		return next registros;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_notificaciones_por_empleado(integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_notificaciones_por_empleado(integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_notificaciones_por_empleado(integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_notificaciones_por_empleado(integer, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_notificaciones_por_empleado(integer, integer)  IS 'La función obtiene las notificaciones del blog del colaborador';

