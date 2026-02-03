CREATE OR REPLACE FUNCTION fun_grabar_blog_aclaraciones(integer, integer, integer, text)
  RETURNS void AS
$BODY$
   DECLARE

	iFactura 	ALIAS FOR $1;
        iEmpleado     	ALIAS FOR $2;
        iEmpleadoDes   	ALIAS FOR $3;
        cComentario   	ALIAS FOR $4;
        
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 01/11/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento :Graba un movimeinto de aclaración
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : BLOG
	     Ejemplo                        : 
		 SELECT * FROM fun_grabar_blog_aclaraciones(5,93902761,0, 'GUARDAR EN EL BLOG');
select * from mov_blog_aclaraciones
		 
	*/
	
BEGIN
	INSERT INTO mov_blog_aclaraciones(id_factura, idu_empleado_origen, idu_empleado_destino, comentario, opc_leido, fec_registro)
	VALUES(iFactura, iEmpleado, iEmpleadoDes, cComentario, 0, NOW());
end;
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_blog_aclaraciones(integer, integer, integer, text) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_blog_aclaraciones(integer, integer, integer, text) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_blog_aclaraciones(integer, integer, integer, text) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_blog_aclaraciones(integer, integer, integer, text) TO postgres;
