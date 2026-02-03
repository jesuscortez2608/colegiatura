CREATE OR REPLACE FUNCTION fun_blog_revision(
IN iempleado integer, 
IN ifactura integer, 
OUT iid_factura integer, 
OUT iempleado_origen integer, 
OUT snom_origen character, 
OUT iempleado_des integer, 
OUT snom_des character, 
OUT scomentario text, 
OUT iopc_leido integer, 
OUT dfecha character, 
OUT dhora character, 
OUT inotificar integer)
  RETURNS SETOF record AS
$BODY$
DECLARE
	-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 22/06/2018
-- Descripción General: consulta el blog de revisión
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.44.114.75
-- Ejemplo: SELECT * FROM fun_blog_revision (94827443, 206)
-- ==================================================================================================
	--DECLARACION DE VARIABLES
	nNotificar integer not null default 0;
	valor record;

BEGIN	
	--TABLA TEMPORAL
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

	IF iFactura!=0 THEN

		nNotificar:= COUNT(opc_leido) FROM MOV_BLOG_REVISION WHERE opc_leido=0 AND idu_empleado_destino= iEmpleado AND id_factura=iFactura; --MOSTRAR NOTIFICACIONES PENDIENTES
		INSERT 	INTO tmp_facturas (id_factura, empleado_origen, empleado_des, comentario, opc_leido, fecha,hora,fechareg, notificar )
		SELECT 	id_factura, idu_empleado_origen, idu_empleado_destino, comentario, opc_leido, TRIM(to_char(fec_registro,'dd/MM/yyyy')),TRIM(to_char(fec_registro,'HH:MI PM')),fec_registro , nNotificar
		FROM	MOV_BLOG_REVISION 
		WHERE  	id_factura=iFactura;
	ELSE
		nNotificar:= COUNT(opc_leido) FROM MOV_BLOG_REVISION WHERE opc_leido=0 AND idu_empleado_destino= iEmpleado; --MOSTRAR NOTIFICACIONES PENDIENTES
		INSERT 	INTO tmp_facturas (id_factura, empleado_origen, empleado_des, comentario, opc_leido, fecha,hora,fechareg, notificar )
		SELECT 	id_factura, idu_empleado_origen, idu_empleado_destino, comentario, opc_leido, TRIM(to_char(fec_registro,'dd/MM/yyyy')),TRIM(to_char(fec_registro,'HH:MI PM')),fec_registro , nNotificar
		FROM	MOV_BLOG_REVISION 
		WHERE 	opc_leido=0 AND idu_empleado_destino = iEmpleado;

	END IF;

	UPDATE 	tmp_facturas set nom_origen=trim(a.nombre)||' '||trim(a.apellidopaterno)||' '||trim(a.apellidomaterno) from sapcatalogoempleados a
	WHERE 	a.numempn=tmp_facturas.empleado_origen;

	UPDATE 	tmp_facturas set nom_des=trim(a.nombre)||' '||trim(a.apellidopaterno)||' '||trim(a.apellidomaterno) from sapcatalogoempleados a
	WHERE 	a.numempn=tmp_facturas.empleado_des;	
		
	--RETORNA VALOR DE UNA CONSULTA
	FOR valor IN (SELECT id_factura, empleado_origen, nom_origen, empleado_des, nom_des, comentario, opc_leido, fecha ,hora, notificar  FROM tmp_facturas ORDER BY fechareg ASC)
		LOOP
			iid_factura:=valor.id_factura;
			iempleado_origen:=valor.empleado_origen;
			snom_origen:=valor.nom_origen;
			iempleado_des:=valor.empleado_des;
			snom_des:=valor.nom_des;
			scomentario:=valor.comentario;
			iopc_leido:=valor.opc_leido;
			dfecha:=valor.fecha;
			dhora:=valor.hora;
			inotificar:=valor.notificar;			
		RETURN NEXT;
	END LOOP;

END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_blog_revision(IN iempleado integer, IN ifactura integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_blog_revision(IN iempleado integer, IN ifactura integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_blog_revision(IN iempleado integer, IN ifactura integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_blog_revision(IN iempleado integer, IN ifactura integer) TO postgres;
COMMENT ON FUNCTION fun_blog_revision(IN iempleado integer, IN ifactura integer) IS 'La función consulta el blog de la revisión de la factura.';