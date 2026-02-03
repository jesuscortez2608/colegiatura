CREATE OR REPLACE FUNCTION fun_grabar_escolaridad_nueva_escuela(
IN srfc character varying, 
IN iestado integer, 
IN imunicipio integer, 
IN ilocalidad integer, 
IN iescolaridad integer, 
IN iusuario integer, 
IN sescuela character varying, 
IN iescuela integer, 
OUT estado integer, 
OUT mensaje character)
  RETURNS SETOF record AS
$BODY$
DECLARE
valor record;
idestado integer;
id_escuela integer;
cmensaje varchar(150);
cNombreAnt varchar(100);
sNomEscuela varchar(150);
	
BEGIN	

	CREATE TEMP TABLE tmp(
		iestatus integer not null default 0,
		cmsg varchar(150) not null default '',
		idescuela integer not null default 0		
	) ON COMMIT DROP;
	
	if (sescuela!='' AND iescuela>0 ) then		
		cNombreAnt:=(select nom_escuela from CAT_ESCUELAS_COLEGIATURAS where idu_escuela=iescuela); 

		update 	CAT_ESCUELAS_COLEGIATURAS set nom_escuela=sescuela 
		where 	--idu_escuela=iescuela;
				idu_estado= iestado
				and idu_municipio=imunicipio
				and idu_localidad=ilocalidad
				and rfc_clave_Sep=srfc
				and nom_escuela=cNombreAnt;
	end if;

	--
	IF (EXISTS(
		SELECT 	nom_escuela 
		FROM 	CAT_ESCUELAS_COLEGIATURAS 
		WHERE 	idu_escolaridad=iEscolaridad 
				and rfc_clave_sep= srfc 
				AND idu_estado=iEstado 
				and idu_municipio=iMunicipio 
				and idu_localidad=iLocalidad 
			--and trim(nom_escuela)=trim(sEscuela)
			)) THEN
		idestado := 1;
		sNomEscuela := (SELECT nom_escuela FROM CAT_ESCUELAS_COLEGIATURAS WHERE idu_escolaridad=iEscolaridad and rfc_clave_sep= srfc AND idu_estado=iEstado and idu_municipio=iMunicipio and idu_localidad=iLocalidad);		
		cmensaje := 'Ya existe la escuela ' || sNomEscuela || ' con el mismo RFC y escolaridad en esta localidad, Favor de seleccionarla';
		
	ELSE
		id_escuela:=(select max(idu_escuela) from CAT_ESCUELAS_COLEGIATURAS)+1;

		if (exists(select id_escuela 
			from 	CAT_ESCUELAS_COLEGIATURAS
			where	rfc_clave_sep= srfc 
					AND  idu_estado=iEstado
					and idu_municipio=iMunicipio
					and idu_localidad=iLocalidad
					and trim(nom_escuela)=trim(sEscuela) )) then

				insert 	into CAT_ESCUELAS_COLEGIATURAS (
						idu_escuela
						, opc_tipo_escuela
						, rfc_clave_sep
						, nom_escuela
						, razon_social
						, idu_escolaridad
						, idu_carrera
						, opc_educacion_especial
						, opc_obligatorio_pdf
						, opc_nota_credito
						, idu_tipo_deduccion
						, opc_escuela_bloqueada
						, clave_sep
						, idu_estado
						, idu_municipio
						, idu_localidad
						, nom_contacto
						, email_contacto
						, tel_contacto
						, ext_contacto
						, area_contacto
						, fec_captura
						, id_empleado_registro
						, observaciones
				)
				select 
						id_escuela
						, opc_tipo_escuela
						, rfc_clave_sep
						, nom_escuela
						, razon_social
						, iEscolaridad
						--, iCarrera
						, idu_carrera
						, opc_educacion_especial
						, opc_obligatorio_pdf
						, opc_nota_credito
						, idu_tipo_deduccion
						, opc_escuela_bloqueada
						, clave_sep
						, idu_estado
						, idu_municipio
						, idu_localidad
						, nom_contacto
						, email_contacto
						, tel_contacto
						, ext_contacto
						, area_contacto
						, fec_captura
						--,id_empleado_registro
						,iusuario
						, observaciones
				from 	CAT_ESCUELAS_COLEGIATURAS
				where	rfc_clave_sep= srfc 
						AND  idu_estado=iEstado
						and idu_municipio=iMunicipio
						and idu_localidad=iLocalidad
						and trim(nom_escuela)=trim(sEscuela)
						limit 1;		
		else
				insert 	into CAT_ESCUELAS_COLEGIATURAS (
						idu_escuela
						, opc_tipo_escuela
						, rfc_clave_sep
						, nom_escuela
						, razon_social
						, idu_escolaridad
						, idu_carrera
						, opc_educacion_especial
						, opc_obligatorio_pdf
						, opc_nota_credito
						, idu_tipo_deduccion
						, opc_escuela_bloqueada
						, clave_sep
						, idu_estado
						, idu_municipio
						, idu_localidad
						, nom_contacto
						, email_contacto
						, tel_contacto
						, ext_contacto
						, area_contacto
						, fec_captura
						, id_empleado_registro
						, observaciones
				)
				select 
						id_escuela
						, opc_tipo_escuela
						, rfc_clave_sep
						, sescuela
						--, nom_escuela
						, razon_social
						, iEscolaridad
						--, iCarrera
						, idu_carrera
						, opc_educacion_especial
						, opc_obligatorio_pdf
						, opc_nota_credito
						, idu_tipo_deduccion
						, opc_escuela_bloqueada
						, clave_sep
						, idu_estado
						, idu_municipio
						, idu_localidad
						, nom_contacto
						, email_contacto
						, tel_contacto
						, ext_contacto
						, area_contacto
						, fec_captura
						--, id_empleado_registro
						,iusuario
						, observaciones
				from 	CAT_ESCUELAS_COLEGIATURAS
				where	rfc_clave_sep= srfc 
						AND  idu_estado=iEstado
						and idu_municipio=iMunicipio
						and idu_localidad=iLocalidad
						--and trim(nom_escuela)=trim(sEscuela)
						limit 1;		

		end if;
		
		idestado := 0;
		cmensaje := 'Escuela agregada correctamente';

		--id_escuela:= (SELECT MAX(idu_escuela) from CAT_ESCUELAS_COLEGIATURAS);

		--REVISION
		insert into MOV_REVISION_COLEGIATURAS  (idu_escuela, idu_motivo_revision, idu_estatus_revision, idu_usuario_captura, fec_captura)
		values (id_escuela, 9,1,iusuario,now());
		
	END IF;	

	--
	INSERT INTO tmp (iestatus, cmsg) VALUES (idestado, cmensaje);

	FOR valor IN (SELECT idestado, cmsg FROM tmp)
	LOOP
		estado:=valor.idestado;
		mensaje:=valor.cmsg;		
		RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_grabar_escolaridad_nueva_escuela(character varying, integer, integer, integer, integer, integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_escolaridad_nueva_escuela(character varying, integer, integer, integer, integer, integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_escolaridad_nueva_escuela(character varying, integer, integer, integer, integer, integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_escolaridad_nueva_escuela(character varying, integer, integer, integer, integer, integer, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_escolaridad_nueva_escuela(character varying, integer, integer, integer, integer, integer, character varying, integer)  IS 'La función graba una nueva escolaridad para la escuela';

