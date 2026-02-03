DROP FUNCTION IF EXISTS fun_obtener_contactos_escuela(integer, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_obtener_contactos_escuela(
IN iescuela integer
, IN sordercolumn character varying
, IN sordertype character varying
, OUT iidu_contacto integer
, OUT iidu_escuela integer
, OUT nom_estado character varying
, OUT nom_municipio character varying
, OUT nom_localidad character varying
, OUT ctelefono character varying
, OUT cemail character varying
, OUT cnom_contacto character varying
, OUT carea character varying
, OUT cext character varying
, OUT cobservaciones text
, OUT iidu_usuario_registro integer
, OUT nom_usuario_registro character varying
, OUT dfec_registro character)
  RETURNS SETOF record AS
$BODY$
DECLARE
	--DECLARACION DE VARIABLES	
	sQuery TEXT;	
	valor record;	
	--sColumns VARCHAR(3000);
	iStart integer;
	iRecords integer;
	iTotalPages INTEGER;
	sRfc varchar(20);  

BEGIN
	--ESCUELAS	
	CREATE TEMP TABLE tmpEscuela(
		idEscuela integer not null,
		idEstado integer not null,
		idMunicipio integer not null,
		idLocalidad integer not null
	) ON COMMIT DROP;

	--CONTACTOS	
	CREATE TEMP TABLE tmpContactos(
		--idEscuela integer not null
		idu_contacto integer not null, 
		idu_escuela integer not null,
		idu_estado integer ,
		nom_estado character varying(100),
		idu_municipio integer,
		nom_municipio character varying(100),
		idu_localidad integer,
		nom_localidad character varying(100),
		telefono character varying(100), 
		email character varying(100), 
		nom_contacto character varying(100), 
		area character varying(100),
		ext character varying(100),
		observaciones character varying(100),
		idu_usuario_registro text,
		nom_usuario_registro character varying(300) not null default '',
		fec_registro date
	) ON COMMIT DROP;

	--RFC
	sRfc:=(select rfc_clave_sep from CAT_ESCUELAS_COLEGIATURAS where idu_escuela=iescuela);
	
	--ESCUELAS		
	insert 	into tmpEscuela (idEscuela,idEstado, idMunicipio, idLocalidad)
	select 	idu_escuela, idu_estado, idu_municipio, idu_localidad
	from 	CAT_ESCUELAS_COLEGIATURAS
	where	rfc_clave_Sep=sRfc;
	
	--
	insert into tmpContactos(idu_contacto,idu_escuela,telefono,email,nom_contacto,area,ext,observaciones,idu_usuario_registro,fec_registro)	
	select idu_contacto, idu_escuela, telefono, email, nom_contacto, area,ext,observaciones,idu_usuario_registro, fec_registro 
	FROM   CAT_CONTACTOS_ESCUELA 
	WHERE  idu_escuela in (select idescuela from tmpEscuela);

	update	tmpContactos
	set	idu_estado = esc.idEstado
		, idu_municipio = esc.idMunicipio
		, idu_localidad = esc.idLocalidad
	from	tmpEscuela esc
	where	esc.idEscuela = tmpContactos.idu_escuela;

	update	tmpContactos
	set	nom_estado = est.nom_estado
	from	cat_estados_colegiaturas est
	where	tmpContactos.idu_estado = est.idu_estado;

	update	tmpContactos
	set	nom_municipio = mun.nom_municipio
	from	cat_municipios_colegiaturas mun
	where	tmpContactos.idu_estado = mun.idu_estado
		AND tmpContactos.idu_municipio = mun.idu_municipio;

	update	tmpContactos
	set	nom_localidad = loc.nom_localidad
	from	cat_localidades_colegiaturas loc
	where	tmpContactos.idu_estado = loc.idu_estado
		AND tmpContactos.idu_municipio = loc.idu_municipio
		AND tmpContactos.idu_localidad = loc.idu_localidad;

	update	tmpContactos
	set	nom_usuario_registro = trim(UPPER(a.nombre)) || ' ' || trim(UPPER(a.apellidopaterno)) || ' ' || trim(UPPER(a.apellidomaterno))
	from	sapcatalogoempleados a
	where	tmpContactos.idu_usuario_registro::INTEGER = a.numempn;

	
	
	--CODIGO
	/*sQuery := 'SELECT idu_contacto, idu_escuela, telefono, email, nom_contacto, area,ext,observaciones,idu_usuario_registro, fec_registro 
		   FROM   CAT_CONTACTOS_ESCUELA 
		   WHERE  idu_escuela=' || iEscuela || ' ORDER  BY ' || sOrderColumn || ' ' || sOrderType;*/

	sQuery := 'SELECT idu_contacto, idu_escuela,nom_estado, nom_municipio, nom_localidad, telefono, email, nom_contacto, area,ext,observaciones,idu_usuario_registro, nom_usuario_registro, fec_registro 
		   FROM   tmpContactos 
		   ORDER  BY ' || sOrderColumn || ' ' || sOrderType;
		
	FOR valor IN EXECUTE (sQuery)
	LOOP
		--records:=valor.records;
		iidu_contacto:=valor.idu_contacto;
		iidu_escuela:=valor.idu_escuela;
		nom_estado:=valor.nom_estado;
		nom_municipio:=valor.nom_municipio;
		nom_localidad:=valor.nom_localidad;
		ctelefono:=valor.telefono;
		cemail:=valor.email;
		cnom_contacto:=valor.nom_contacto;
		carea:=valor.area;
		cext:=valor.ext;
		cobservaciones:=valor.observaciones;
		iidu_usuario_registro:=valor.idu_usuario_registro;
		nom_usuario_registro:=valor.nom_usuario_registro;
		dfec_registro:=valor.fec_registro;
		
	RETURN NEXT;
	END LOOP;
	
end;	
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_contactos_escuela(integer, character varying, character varying)  TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_contactos_escuela(integer, character varying, character varying)  TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_contactos_escuela(integer, character varying, character varying)  TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_contactos_escuela(integer, character varying, character varying)  TO postgres;
COMMENT ON FUNCTION fun_obtener_contactos_escuela(integer, character varying, character varying)  IS 'La función obtiene los contactos agregados a la escuela.';