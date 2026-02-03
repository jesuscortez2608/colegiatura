DROP FUNCTION IF EXISTS fun_grabar_grados_escolares(integer, integer, character varying);

CREATE OR REPLACE FUNCTION fun_grabar_grados_escolares(IN iescolaridad integer, IN igrado integer, IN snomgrado character varying, OUT estado integer, OUT mensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
/*-------------------------------------------------------------------------------------------
	No. Peticion:		16559.1
	Colaborador:		98439677 Rafael Ramos
	Sistema:		Colegiaturas
	Modulo:			Configuracion de Escolaridad
	Servidor Produccion:	10.44.2.183
	Servidor Desarrollo:	10.28.114.75
	BD:			Personal
	Descripcion del cambio:	N/A
-------------------------------------------------------------------------------------------*/

	valor record;
	sQuery text;
	iEstado smallint;
	cMensaje character varying(150);
	iConsecutivo integer;
BEGIN
	create temporary table tmp_resultado(
		estatus integer not null default 0
		, cmsg character varying(100) not null default ''
	) on commit drop;

	iConsecutivo := (SELECT COALESCE(MAX(idu_grado_escolar),0)+1 from cat_grados_escolares where idu_escolaridad = iEscolaridad);
	raise notice '%', iConsecutivo;
	--return;

	if (iGrado > -1 ) then
		if exists (SELECT nom_grado_escolar from cat_grados_escolares where idu_escolaridad = iEscolaridad and idu_grado_escolar = iGrado and nom_grado_escolar = sNomGrado) then
			iEstado := 2;
			cMensaje := 'Ya se encuentra registrado el grado escolar';
		else
			update	cat_grados_escolares
			set	nom_grado_escolar = sNomGrado
			where	idu_escolaridad = iEscolaridad
				and idu_grado_escolar = iGrado;

			iEstado := 1;
			cMensaje := 'Grado escolar actualizado correctamente';
		end if;
	else
		if exists (SELECT nom_grado_escolar from cat_grados_escolares where idu_escolaridad = iEscolaridad and nom_grado_escolar = sNomGrado) then
		 iEstado := 2;
		 cMensaje := 'Ya se encuentra registrado el grado escolar';
		else
			insert into	cat_grados_escolares (idu_escolaridad, idu_grado_escolar, nom_grado_escolar)
			VALUES		(iEscolaridad, iConsecutivo, sNomGrado);

			iEstado := 0;
			cMensaje := 'Grado escolar registrado correctamente';
		end if;
	end if;
	
	insert into tmp_resultado (estatus, cmsg) values(iEstado, cMensaje);

	for valor in (SELECT estatus, cmsg from tmp_resultado)
	loop
		estado := valor.estatus;
		mensaje := valor.cmsg;
	return next;
	end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_grados_escolares(integer, integer, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_grados_escolares(integer, integer, character varying) TO syspersonal;
COMMENT ON FUNCTION fun_grabar_grados_escolares(integer, integer, character varying) IS 'La función graba los grados escolares de las diferentes escolaridades del Sistema de Colegiaturas.';