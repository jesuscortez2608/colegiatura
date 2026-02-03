CREATE OR REPLACE FUNCTION fun_grabar_descuentos_revision(IN iusuario integer, IN ikeyx integer, IN irevision integer, IN iescuela integer, IN icicloescolar integer, IN iescolaridad integer, IN icarrera integer, IN itpp integer, IN iprcdescuento integer, IN imotivodescuento integer, IN itiporegistro smallint, OUT iestado integer, OUT smensaje character)
  RETURNS SETOF record AS
$BODY$
DECLARE
	--DECLARACION DE VARIABLES
	--dFecha timestamp;	
	--sQuery TEXT;	
	valor record;	
	--sColumns VARCHAR(3000);
	--iStart integer;
	--iRecords integer;
	--iTotalPages INTEGER; 
	anio integer;
	idkeyx integer;
	tipo_registro integer;
	sRfc varchar(20);
	iEsc integer;

BEGIN
	anio:=(SELECT DATE_PART('year',CURRENT_DATE));
	
	--TABLA TEMPORAL
	CREATE TEMP TABLE tmpEstado(
		estado integer not null default 0,
		mensaje varchar(50) not null default ''		
	) ON COMMIT DROP;

	if (anio=iCicloEscolar) then
		tipo_registro=1;
	else 
		tipo_registro=2;
	end if;

	--ESCUELAS	
	CREATE TEMP TABLE tmpEscuela(
		idEscuela integer not null,
		idEstado  integer not null default 0,
		idMunicipio integer not null default 0,
		idLocalidad integer not null default 0
	) ON COMMIT DROP;

	--RFC
	sRfc:=(select rfc_clave_sep from CAT_ESCUELAS_COLEGIATURAS where idu_escuela=iescuela);
	
	--ESCUELAS		
	/*insert 	into tmpEscuela (idEscuela)
	select 	idu_escuela 
	from 	CAT_ESCUELAS_COLEGIATURAS
	where	rfc_clave_Sep=sRfc;*/
	
	--ESCUELA 	
	insert 	into tmpEscuela (idEscuela, idEstado, idMunicipio, idLocalidad)
	select 	idu_escuela, idu_estado, idu_municipio, idu_localidad 
	from 	CAT_ESCUELAS_COLEGIATURAS
	where	idu_escuela=iescuela;
		--rfc_clave_Sep=sRfc;
		
	--ESCUELA DE LA MISMA LOCALIDAD CON DIFERENTE ESCOLARIDAD
	insert 	into tmpEscuela (idEscuela, idEstado, idMunicipio, idLocalidad)
	select 	idu_escuela, idu_estado, idu_municipio, idu_localidad 
	from 	CAT_ESCUELAS_COLEGIATURAS
	where	rfc_clave_Sep=sRfc
			and idu_estado= (select idEstado from tmpEscuela)
			and idu_municipio= (select idMunicipio from tmpEscuela)
			and idu_localidad= (select idLocalidad from tmpEscuela)
			and idu_escuela!=iescuela;
	
	--CODIGO	
	if (iKeyx=0) then

		if exists (
			SELECT 	idu_revision 
			FROM 	STMP_DETALLE_REVISION_COLEGIATURAS 	
			WHERE 	idu_escuela in (select idEscuela from tmpEscuela)
				and idu_ciclo_escolar=iCicloEscolar 
				and idu_escolaridad=iEscolaridad 
				and idu_carrera=0 --iCarrera 
				and idu_tipo_pago=iTPP 
				--and prc_descuento=iPrcDescuento 
				and idu_motivo=iMotivoDescuento 
				--and idu_tipo_registro=iTipoRegistro  
				and idu_usuario=iUsuario
				) then

			INSERT INTO tmpEstado (estado, mensaje) VALUES (1,'Descuentos para este tipo de pago ya existe') ;
		elsif  exists (
			SELECT 	idu_revision 
			FROM 	stmp_detalle_revision_colegiaturas 	
			WHERE 	idu_escuela in (select idEscuela from tmpEscuela)
				and idu_ciclo_escolar=iCicloEscolar 
				and idu_escolaridad=iEscolaridad 
				and idu_carrera=iCarrera 
				and idu_tipo_pago=iTPP 
				--and prc_descuento=iPrcDescuento 
				and idu_motivo=iMotivoDescuento 
				--and idu_tipo_registro=iTipoRegistro  
				and idu_usuario=iUsuario
				) then

			INSERT INTO tmpEstado (estado, mensaje) VALUES (1,'Descuentos para este tipo de pago ya existe') ;
		else	
			IF (exists(
				SELECT 	keyx 
				from 	stmp_detalle_revision_colegiaturas 
				WHERE 	idu_usuario=iUsuario 
					and idu_tipo_registro=tipo_registro 
					and idu_escuela in (select idEscuela from tmpEscuela))) then
					
				idkeyx:=(SELECT MAX(Keyx) from stmp_detalle_revision_colegiaturas WHERE idu_usuario=iUsuario and idu_tipo_registro=tipo_registro and idu_escuela in (select idEscuela from tmpEscuela))+1;
			else
				idkeyx:=1;
			end if;

			--SELECT keyx from stmp_detalle_revision_colegiaturas WHERE idu_usuario=94827443 and idu_tipo_registro=1
			--select idu_escuela, idu_escolaridad from CAT_ESCUELAS_COLEGIATURAS where rfc_clave_sep='E5CPENDIENTEX' and idu_escolaridad>0
			--iEsc:=(select idu_escuela from CAT_ESCUELAS_COLEGIATURAS where trim(rfc_clave_sep)=trim(sRfc) and idu_escolaridad=iEscolaridad);
			
			insert 	into stmp_detalle_revision_colegiaturas (idu_revision,idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago, prc_descuento, idu_motivo,importe_concepto, idu_tipo_registro, Keyx, idu_usuario)
			VALUES (iRevision, iEscuela, iCicloEscolar, iEscolaridad,iCarrera,iTPP,iPrcDescuento,iMotivoDescuento,0,tipo_registro,idkeyx,iUsuario);
			--VALUES (iRevision, iEsc, iCicloEscolar, iEscolaridad,iCarrera,iTPP,iPrcDescuento,iMotivoDescuento,0,tipo_registro,idkeyx,iUsuario);

			INSERT INTO tmpEstado (estado, mensaje) VALUES (0,'Descuento agregado correctamente') ;
		end if;
	else
		if  exists(
			SELECT 	idu_revision 
			FROM 	stmp_detalle_revision_colegiaturas 	
			WHERE 	idu_escuela in (select idEscuela from tmpEscuela)
				and idu_ciclo_escolar=iCicloEscolar 
				and idu_escolaridad=iEscolaridad 
				and idu_carrera=0 --iCarrera 
				and idu_tipo_pago=iTPP 
				--and prc_descuento=iPrcDescuento 
				and idu_motivo=iMotivoDescuento
				and keyx!=ikeyx 
				--and idu_tipo_registro=iTipoRegistro  
				and idu_usuario=iUsuario
				) then

			INSERT INTO tmpEstado (estado, mensaje) VALUES (1,'Descuentos para este tipo de pago ya existe') ;
		elsif  exists (
			SELECT 	idu_revision 
			FROM 	stmp_detalle_revision_colegiaturas 	
			WHERE 	idu_escuela in (select idEscuela from tmpEscuela)
				and idu_ciclo_escolar=iCicloEscolar 
				and idu_escolaridad=iEscolaridad 
				and idu_carrera=iCarrera 
				and idu_tipo_pago=iTPP 
				--and prc_descuento=iPrcDescuento 
				and idu_motivo=iMotivoDescuento 
				and keyx!=ikeyx
				--and idu_tipo_registro=iTipoRegistro  
				and idu_usuario=iUsuario
				) then

			INSERT INTO tmpEstado (estado, mensaje) VALUES (1,'Descuentos para este tipo de pago ya existe') ;
		else	
			update 	STMP_DETALLE_REVISION_COLEGIATURAS 
				SET 
				--idu_revision=iRevision 
				-- ,idu_escuela=iEscuela 
				-- ,idu_ciclo_escolar=iCicloEscolar 
				-- ,idu_escolaridad=iEscolaridad 
				-- ,idu_carrera=iCarrera 
				-- ,idu_tipo_pago=iTPP
				prc_descuento=iPrcDescuento 
				,idu_motivo=iMotivoDescuento 
				--,idu_tipo_registro=iTipoRegistro 
			WHERE	idu_usuario=iUsuario 
				AND keyx=iKeyx
				AND idu_escuela in (select idEscuela from tmpEscuela)
				and idu_tipo_registro=tipo_registro
				and prc_descuento>0;

			INSERT INTO tmpEstado (estado, mensaje) VALUES (0,'Descuento actualizado correctamente') ;
		end if;
	end if;	

	--RETORNA VALOR DE UNA CONSULTA
	FOR valor IN (SELECT estado, mensaje FROM tmpEstado)
	LOOP
		iEstado:=valor.estado;
		sMensaje:=valor.mensaje;	
		
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_descuentos_revision(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, smallint) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_descuentos_revision(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, smallint) TO syspersonal;
COMMENT ON FUNCTION fun_grabar_descuentos_revision(integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, smallint) IS 'La función graba los descuentos de la escuela en la revisión.';