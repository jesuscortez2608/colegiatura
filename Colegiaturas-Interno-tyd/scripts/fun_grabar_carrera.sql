DROP FUNCTION if exists fun_grabar_carrera(integer, integer, character varying, integer);

CREATE OR REPLACE FUNCTION fun_grabar_carrera(
IN iopcion integer
, IN icarrera integer
, IN snomcarrera character varying
, IN iusuario integer
, OUT estado integer
, OUT mensaje character varying)
  RETURNS SETOF record AS
$BODY$
declare
/**----------------------------------------
	No.Petición:			16559.1
	Fecha:				30/05/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:				PERSONAL    
	Servidor:			10.44.2.183
	Sistema:			Colegiaturas
	Modulo: 			Catalogo de Carreras
	Ejemplo:	
		SELECT * fun_grabar_carrera('Medico general', 95194185)
----------------------------------------
*/
valor record;
iEstatus integer;
cMsg varchar(150);
	
begin

create temp table tmp_Carreras(
	iEstado integer not null default 0,
	cMensaje varchar(150) not null default ''
	)on commit drop;

	if (iOpcion < 1) then
		if exists (select 1 from cat_carreras where nom_carrera ilike TRIM(UPPER(snomCarrera))) then
			iEstatus := -1;
			cMsg := 'Ya se encuentra registrada la carrera';
		else
			insert into	cat_carreras(nom_carrera, idu_empleado_registro)
			values	(trim(UPPER(snomCarrera)), iUsuario);
			iEstatus := 1;
			cMsg := 'Carrera registrada correctamente';
		end if;
	else
		if exists (select 1 from cat_carreras where nom_carrera ilike trim(UPPER(snomCarrera))) then
			iEstatus := -1;
			cMsg := 'Ya se encuentra registrada la carrera, favor de verificar';
		else
			update cat_carreras
			set	nom_carrera = snomCarrera
				, idu_empleado_registro = iUsuario
			where	idu_carrera = iCarrera;
			iEstatus := 2;
			cMsg := 'Carrera actualizada correctamente';
		end if;
	end if;

	insert into tmp_Carreras(iEstado, cMensaje)VAlues(iEstatus, cMsg);

	for valor in (select iEstado, cMensaje from tmp_Carreras)
	loop
		estado := valor.iEstado;
		mensaje:= valor.cMensaje;
		return next;
	end loop;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_carrera(integer, integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_carrera(integer, integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_carrera(integer, integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_carrera(integer, integer, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_carrera(integer, integer, character varying, integer) IS 'La funcion guarda el registro de la nueva carrera.';