
CREATE OR REPLACE FUNCTION fun_obtener_claves_uso_permitidas(OUT clv_uso character varying, OUT des_uso character varying, OUT fec_registro character varying, OUT idu_empleado integer, OUT nombreempleado character varying, OUT apellidopaterno character varying, OUT apellidomaterno character varying, OUT keyx integer)
  RETURNS SETOF record AS
$BODY$
 declare
	rec record;
begin
-- ===================================================
-- Peticion						: 16559.1
-- Autor						: Rafael Ramos Gutiérrez 98439677
-- Fecha						: 02/04/2018
-- Descripción General			: La función obtiene un listado de las claves de uso permitidas en las facturas de colegiaturas.
-- Sistema						: Colegiaturas
-- Ruta Tortoise				: 
-- Servidor Productivo			: 10.44.2.183
-- Servidor Desarrollo			: 10.44.114.75
-- Base de Datos				: personal
-- Ejemplo						: SELECT clv_uso, des_uso, fec_registro, idu_empleado, nombreempleado, apellidopaterno, apellidomaterno, keyx  FROM fun_obtener_claves_uso_permitidas()
-- ===================================================
	create temporary table tmp_ClvUso(
	iClv_uso character varying not null,
	cDes_uso character varying not null,
	dFec_registro character varying not null default '1900-01-01',
	idu_empleado_registro integer not null,
	cNombre_empleado character varying ,
	cApellidoPaterno character varying ,
	cApellidoMaterno character varying ,
	iKeyx integer not null
	) on commit drop;

	insert into	tmp_ClvUso (iClv_uso, cDes_uso, dFec_registro, idu_empleado_registro, iKeyx)
	select		UPPER(a.clv_uso), UPPER(a.des_uso), to_char(a.fec_registro, 'dd/mm/yyyy'), a.idu_empleado_registro, a.keyx
	from		cat_claves_uso_permitidas a;

	update	tmp_ClvUso 
	set	cNombre_empleado = b.nombre, cApellidoPaterno = b.apellidopaterno, cApellidoMaterno = b.apellidomaterno
	from	sapcatalogoempleados b
	where	idu_empleado_registro = b.numempn;

	for rec in(select	
			iClv_uso,
			cDes_uso,
			dFec_registro,
			idu_empleado_registro,
			cNombre_empleado,
			cApellidoPaterno,
			cApellidoMaterno,
			iKeyx
			from tmp_ClvUso 
			order by iKeyx)
			loop
				clv_uso		:=	rec.iClv_uso;
				des_uso		:=	rec.cDes_uso;
				fec_registro	:=	rec.dFec_registro;
				idu_empleado	:=	rec.idu_empleado_registro;
				nombreempleado	:=	rec.cNombre_empleado;
				apellidopaterno	:=	rec.cApellidoPaterno;
				apellidomaterno :=	rec.cApellidoMaterno;
				keyx		:=	rec.iKeyx;
			return next;
			end loop;				
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_claves_uso_permitidas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_claves_uso_permitidas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_claves_uso_permitidas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_claves_uso_permitidas() TO postgres;
COMMENT ON FUNCTION fun_obtener_claves_uso_permitidas() IS 'La función obtiene un listado de las claves de uso permitidas en las facturas de colegiaturas.';