CREATE OR REPLACE FUNCTION fun_grabar_escuelas_colegiaturas(
IN opc_tipo integer, 
IN nom_esc character, 
IN razon_social character, 
IN rfc_clv_sep character, 
IN clave_sep character, 
IN id_estado integer, 
IN id_municipio integer, 
IN id_localidad integer, 
IN nom_cont character, 
IN email_cont character, 
IN escolaridad integer, 
IN tel_cont character, 
IN ext_cont character, 
IN area_cont character, 
IN iusuario integer, 
OUT estado integer, 
OUT mensaje character, 
OUT id_escuela integer)
  RETURNS SETOF record AS
$BODY$
DECLARE
valor record;
iestado integer;
id_esc integer;
cmensaje varchar(150);
sEscuela varchar(150);
	
BEGIN
	CREATE TEMP TABLE tmp(
		iestatus integer not null default 0,
		cmsg varchar(150) not null default '',
		idescuela integer not null default 0		
	) ON COMMIT DROP;	
	--
	IF (EXISTS(SELECT nom_escuela FROM CAT_ESCUELAS_COLEGIATURAS WHERE idu_estado=id_estado AND idu_municipio=id_municipio AND idu_localidad=id_localidad 
		and rfc_clv_sep=rfc_clave_sep and idu_escolaridad=escolaridad /*AND nom_escuela=nom_esc*/)) THEN
		iestado := 1;
		sEscuela := (SELECT nom_escuela FROM CAT_ESCUELAS_COLEGIATURAS WHERE idu_estado=id_estado AND idu_municipio=id_municipio AND idu_localidad=id_localidad and rfc_clv_sep=rfc_clave_sep and idu_escolaridad=escolaridad);		
		cmensaje := 'Ya existe la escuela ' || sEscuela || ' con el mismo RFC y escolaridad en esta localidad, Favor de seleccionarla';
		id_esc:=0;
	ELSE
		--id_esc:= (SELECT idu_escuela FROM cat_escuelas_colegiaturas ORDER BY idu_escuela DESC LIMIT 1)+1;
		id_esc:= (SELECT max(idu_escuela) FROM cat_escuelas_colegiaturas )+1;
		
		INSERT INTO CAT_ESCUELAS_COLEGIATURAS (idu_escuela, opc_tipo_escuela, nom_escuela,razon_social,idu_escolaridad, rfc_clave_sep, clave_sep, idu_estado, idu_municipio, idu_localidad,opc_escuela_bloqueada,nom_contacto, email_contacto, tel_contacto, ext_contacto,area_contacto, id_empleado_registro) 
		VALUES (id_esc, opc_tipo, nom_esc, razon_social,escolaridad,rfc_clv_sep, clave_sep, id_estado, id_municipio, id_localidad, 0, nom_cont, email_cont, tel_cont, ext_cont,area_cont,iusuario);

		--Agregar a bandeja de entrada de servicios compartidos
		INSERT INTO MOV_REVISION_COLEGIATURAS (idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura)
		VALUES (id_esc, 9,1,iUsuario);

		insert into CAT_CONTACTOS_ESCUELA (idu_escuela, nom_contacto, telefono, email, area, ext, idu_usuario_registro, fec_registro)
		values(id_esc,nom_cont,tel_cont,email_cont,area_cont,ext_cont,iusuario, NOW());		
		
		iestado := 0;
		cmensaje := 'Escuela agregada correctamente';
	END IF;	

	INSERT INTO tmp (iestatus, cmsg, idescuela) VALUES (iestado, cmensaje,id_esc);

	FOR valor IN (SELECT iestatus, cmsg, idescuela FROM tmp)
	LOOP
		estado:=valor.iestatus;
		mensaje:=valor.cmsg;
		id_escuela:=valor.idescuela;
		RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_grabar_escuelas_colegiaturas(integer, character, character, character, character, integer, integer, integer, character, character, integer, character, character, character, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_escuelas_colegiaturas(integer, character, character, character, character, integer, integer, integer, character, character, integer, character, character, character, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_escuelas_colegiaturas(integer, character, character, character, character, integer, integer, integer, character, character, integer, character, character, character, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_escuelas_colegiaturas(integer, character, character, character, character, integer, integer, integer, character, character, integer, character, character, character, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_escuelas_colegiaturas(integer, character, character, character, character, integer, integer, integer, character, character, integer, character, character, character, integer)IS 'La función graba las escuelas de colegiaturas';