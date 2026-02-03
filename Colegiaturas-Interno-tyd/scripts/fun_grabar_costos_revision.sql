CREATE OR REPLACE FUNCTION fun_grabar_costos_revision(IN iusuario integer, IN ikeyx integer, IN irevision integer, IN iescuela integer, IN icicloescolar integer, IN iescolaridad integer, IN icarrera integer, IN itipopago integer, IN nimporteconcepto numeric, IN itiporegistro smallint, OUT iestado integer, OUT smensaje character)
  RETURNS SETOF record AS
$BODY$
DECLARE
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 31/07/2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: 
-- ====================================================================================================
	--DECLARACION DE VARIABLES
	
	valor record;	
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
			FROM 	stmp_detalle_revision_colegiaturas 
			WHERE 	idu_escuela in (select idEscuela from tmpEscuela)
				and idu_ciclo_escolar=iCicloEscolar 
				and idu_escolaridad=iEscolaridad 
				and idu_carrera=0 
				and idu_tipo_pago=iTipoPago 
				and prc_descuento=0
				--and importe_concepto=nImporteConcepto 
				--and idu_tipo_registro=iTipoRegistro  
				and idu_usuario=iUsuario
			) then
			INSERT INTO tmpEstado (estado, mensaje) VALUES (1,'El Costo para este tipo de pago ya existe') ;	
		elsif exists (
			SELECT 	idu_revision 
			FROM 	stmp_detalle_revision_colegiaturas 
			WHERE 	idu_escuela in (select idEscuela from tmpEscuela)
				and idu_ciclo_escolar=iCicloEscolar 
				and idu_escolaridad=iEscolaridad 
				and idu_carrera=iCarrera 
				and idu_tipo_pago=iTipoPago 
				and prc_descuento=0
				--and importe_concepto=nImporteConcepto 
				--and idu_tipo_registro=iTipoRegistro  
				and idu_usuario=iUsuario
			) then
			INSERT INTO tmpEstado (estado, mensaje) VALUES (1,'El Costo para este tipo de pago ya existe') ;			
		else
			IF (exists(SELECT keyx from stmp_detalle_revision_colegiaturas WHERE idu_usuario=iUsuario and idu_tipo_registro=tipo_registro and idu_escuela in (select idEscuela from tmpEscuela))) then
				idkeyx:=(SELECT MAX(Keyx) from stmp_detalle_revision_colegiaturas WHERE idu_usuario=iUsuario and idu_tipo_registro=tipo_registro and idu_escuela in (select idEscuela from tmpEscuela))+1;
			else
				idkeyx:=1;
			end if;

			--iEsc:=(select idu_escuela from CAT_ESCUELAS_COLEGIATURAS where trim(rfc_clave_sep)=trim(sRfc) and idu_escolaridad=iEscolaridad);	
			
			insert 	into stmp_detalle_revision_colegiaturas (idu_revision,idu_escuela, idu_ciclo_escolar, idu_escolaridad, idu_carrera, idu_tipo_pago,importe_concepto,idu_motivo,idu_tipo_registro,Keyx, idu_usuario)
			VALUES (iRevision, iEscuela, iCicloEscolar, iEscolaridad,iCarrera,iTipoPago,nImporteConcepto,0,tipo_registro,idkeyx,iUsuario);
			--VALUES (iRevision, iEsc, iCicloEscolar, iEscolaridad,iCarrera,iTipoPago,nImporteConcepto,0,tipo_registro,idkeyx,iUsuario);

			INSERT INTO tmpEstado (estado, mensaje) VALUES (0,'Costo agregado correctamente') ;
		end if;
	else
		if exists (
			SELECT 	idu_revision 
			FROM 	stmp_detalle_revision_colegiaturas 
			WHERE 	idu_escuela in (select idEscuela from tmpEscuela) 
				and idu_ciclo_escolar=iCicloEscolar 
				and idu_escolaridad=iEscolaridad 
				and idu_carrera=0 
				and idu_tipo_pago=iTipoPago 
				and prc_descuento=0
				and keyx!=ikeyx
				--and importe_concepto=nImporteConcepto 
				--and idu_tipo_registro=iTipoRegistro  
				and idu_usuario=iUsuario
			) then
			INSERT INTO tmpEstado (estado, mensaje) VALUES (1,'El Costo para este tipo de pago ya existe') ;	
		elsif exists (
			SELECT 	idu_revision 
			FROM 	stmp_detalle_revision_colegiaturas 
			WHERE 	idu_escuela in (select idEscuela from tmpEscuela)
				and idu_ciclo_escolar=iCicloEscolar 
				and idu_escolaridad=iEscolaridad 
				and idu_carrera=iCarrera 
				and idu_tipo_pago=iTipoPago 
				and prc_descuento=0
				and keyx!=ikeyx
				--and importe_concepto=nImporteConcepto 
				--and idu_tipo_registro=iTipoRegistro  
				and idu_usuario=iUsuario
			) then
			INSERT INTO tmpEstado (estado, mensaje) VALUES (1,'El Costo para este tipo de pago ya existe') ;			
		else
			update 	stmp_detalle_revision_colegiaturas 
			SET 	--idu_revision=iRevision
				--,idu_escuela =iEscuela 
				--,idu_ciclo_escolar=iCicloEscolar 
				--,idu_escolaridad=iEscolaridad
				--,idu_carrera=iCarrera
				--,idu_tipo_pago=iTipoPago 
				importe_concepto=nImporteConcepto
				--,idu_tipo_registro=tipo_registro --iTipoRegistro 
			WHERE	idu_usuario=iUsuario 
				and idu_tipo_registro=tipo_registro
				AND keyx=iKeyx;
		

			INSERT INTO tmpEstado (estado, mensaje) VALUES (0,'Costo actualizado correctamente') ;
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
  
GRANT EXECUTE ON FUNCTION fun_grabar_costos_revision(integer, integer, integer, integer, integer, integer, integer, integer, numeric, smallint) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_costos_revision(integer, integer, integer, integer, integer, integer, integer, integer, numeric, smallint) TO syspersonal;
COMMENT ON FUNCTION fun_grabar_costos_revision(integer, integer, integer, integer, integer, integer, integer, integer, numeric, smallint)  IS 'La función graba los costos que se agregan a la escuela en la revisión';
