CREATE OR REPLACE FUNCTION fun_grabar_contacto_escuela(IN icontacto integer, IN iescuela integer, IN snombre character varying, IN stelefono character varying, IN semail character varying, IN sarea character varying, IN sext character varying, IN sobservaciones text, IN iusuario integer, IN iopcion integer, IN irevision integer, IN sescuela character, IN imotivorevision integer, IN srfc character, IN srazonsocial character, IN iestado integer, IN imunicipio integer, IN ilocalidad integer, IN sclavesep character, OUT nestado integer, OUT smsg character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	--DECLARACION DE VARIABLES		
	valor record;	
BEGIN
	CREATE TEMP TABLE tmpDatos(
		icontacto integer not null default 0,
		iescuela  integer not null default 0,
		nom_contacto VARCHAR(60) not null default '',
		telefono VARCHAR(50) not null default '',
		email VARCHAR(50) not null default '',
		area VARCHAR(50) not null default '',
		ext VARCHAR(50) not null default '',
		observaciones text not null default '',
		usuario_registro integer not null default 0
	) ON COMMIT DROP;

	CREATE TEMP TABLE tmp(
		estado integer not null default 0,
		mensaje varchar(50) not null default ''
	) ON COMMIT DROP;	

	--CODIGO
	INSERT INTO MOV_BITACORA_COSTOS (idu_revision, idu_motivo_revision, idu_tipo_revision,idu_estado, idu_municipio, idu_escuela, nom_escuela, rfc, clave_sep, razon_social, nom_contacto, email_contacto, tel_contacto, ext_contacto, area_contacto, fec_revision, idu_usuario)
	values(iRevision, iMotivoRevision, 5, iEstado, iMunicipio, iEscuela,sEscuela,sRfc,sClaveSep,sRazonSocial,sNombre,sEmail,sTelefono,sExt,sArea,now(),iUsuario);
	
	if (iOpcion=1) then
		IF (iContacto=0) then
			INSERT INTO CAT_CONTACTOS_ESCUELA (idu_escuela, nom_contacto, telefono, email,area,ext,observaciones, idu_usuario_registro, fec_registro)
			VALUES (iEscuela,sNombre,sTelefono,sEmail,sArea,sExt,sObservaciones,iUsuario,NOW());

			insert into tmp(estado, mensaje)
			values (0,'Registro agregado exitosamente');
		ELSE
			update 	CAT_CONTACTOS_ESCUELA  
			SET 	idu_escuela=iEscuela
				, nom_contacto=sNombre
				, telefono=sTelefono
				, email=sEmail
				, area=sArea
				, ext=sExt
				, observaciones=sObservaciones
				, idu_usuario_registro=iUsuario				
			WHERE 	idu_contacto=iContacto;

			insert into tmp(estado, mensaje)
			values (0,'Registro modificado exitosamente');

		end if;		
	else
		delete from CAT_CONTACTOS_ESCUELA where idu_contacto=iContacto; 
		insert into tmp(estado, mensaje)
		values (0,'El registro ha sido eliminado');
	end if;	

	FOR valor IN (SELECT estado, mensaje FROM tmp) 
	loop
		nestado:=valor.estado;
		smsg:=valor.mensaje;
		return next;
	end loop;
	return;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;  
GRANT EXECUTE ON FUNCTION fun_grabar_contacto_escuela(integer, integer, character varying, character varying, character varying, character varying, character varying, text, integer, integer, integer, character, integer, character, character, integer, integer, integer, character)   TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_contacto_escuela(integer, integer, character varying, character varying, character varying, character varying, character varying, text, integer, integer, integer, character, integer, character, character, integer, integer, integer, character)   TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_contacto_escuela(integer, integer, character varying, character varying, character varying, character varying, character varying, text, integer, integer, integer, character, integer, character, character, integer, integer, integer, character)   TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_contacto_escuela(integer, integer, character varying, character varying, character varying, character varying, character varying, text, integer, integer, integer, character, integer, character, character, integer, integer, integer, character)   TO postgres;
COMMENT ON FUNCTION fun_grabar_contacto_escuela(integer, integer, character varying, character varying, character varying, character varying, character varying, text, integer, integer, integer, character, integer, character, character, integer, integer, integer, character)  IS 'La función graba contactos de la escuela en revisión';