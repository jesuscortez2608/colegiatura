CREATE OR REPLACE FUNCTION fun_actualizar_contactos_hoja_azul(integer, xml)
  RETURNS void AS
$BODY$
declare
	--iBloque alias for $1;
	iNumemp alias for $1;
	cXml alias for $2;
BEGIN
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 09-11-2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: 
-- ====================================================================================================
	
	CREATE temp TABLE stmpHojaAzul
	(
	  numemp bigint DEFAULT 0,
	  clave integer DEFAULT 0,
	  numerofamiliares integer DEFAULT 0,
	  parentesco integer DEFAULT 0,
	  apellidopaterno character(20) DEFAULT ''::bpchar,
	  apellidomaterno character(20) DEFAULT ''::bpchar,
	  nombre character(20) DEFAULT ''::bpchar,
	  fechanacimiento date DEFAULT '1900-01-01'::date,
	  escolaridad character(30) DEFAULT ''::bpchar,
	  empresa character(40) DEFAULT ''::bpchar,
	  ocupacion character(30) DEFAULT ''::bpchar,
	  telefonoempresa character(12) DEFAULT ''::bpchar,
	  telefonocasa character(12) DEFAULT ''::bpchar,
	  numeroelp bigint DEFAULT 0,
	  fechacaptura date DEFAULT now(),
	  keyx integer NOT NULL DEFAULT 0,
	  personasdepENDientes integer NOT NULL DEFAULT 0,
	  --beneficiarioactivo integer NOT NULL DEFAULT 0
	  actualizado integer DEFAULT 0
	)
	on commit drop;

    
	INSERT INTO stmpHojaAzul(numemp,clave,numerofamiliares,parentesco,apellidopaterno,apellidomaterno,nombre,fechanacimiento,escolaridad,empresa,ocupacion,telefonoempresa,telefonocasa,numeroelp,fechacaptura,keyx,personasdepENDientes)
	SELECT (xpath('//a/text()', myTempTable.myXmlColumn))[1]::TEXT::bigint AS bNumemp,
	(xpath('//b/text()', myTempTable.myXmlColumn))[1]::TEXT::integer AS iClave,
	(xpath('//c/text()', myTempTable.myXmlColumn))[1]::TEXT::integer AS iNumerofamiliares,
	(xpath('//d/text()', myTempTable.myXmlColumn))[1]::TEXT::integer AS iParentesco,
	--(xpath('//e/text()', myTempTable.myXmlColumn))[1]::TEXT::INTEGER AS empleado,
	(xpath('//e/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS sApellidopaterno,
	(xpath('//f/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS sApellidomaterno,
	(xpath('//g/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS sNombre,
	(xpath('//h/text()', myTempTable.myXmlColumn))[1]::TEXT::DATE AS sFechanacimiento,
	(xpath('//i/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS sEscolaridad,
	(xpath('//j/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS sEmpresa,
	(xpath('//k/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS sOcupacion,
	(xpath('//l/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR sTelefonoempresa,
	(xpath('//m/text()', myTempTable.myXmlColumn))[1]::TEXT::VARCHAR AS sTelefonocasa,
	(xpath('//n/text()', myTempTable.myXmlColumn))[1]::TEXT::bigint AS bNumeroelp,
	(xpath('//o/text()', myTempTable.myXmlColumn))[1]::TEXT::date AS dFechacaptura,
	(xpath('//p/text()', myTempTable.myXmlColumn))[1]::TEXT::integer AS iKeyx,
	(xpath('//q/text()', myTempTable.myXmlColumn))[1]::TEXT::integer AS iPersonasdepENDientes 
	FROM unnest(xpath('//Root/r', cXml)) AS myTempTable(myXmlColumn);

	UPDATE stmpHojaAzul SET actualizado=0;

	--INACTIVA BENEFICIARIOS QUE FUERON ELIMINADOS EN LA HOJA AZUL
	UPDATE 	SAPFAMILIARHOJAS SET beneficiarioactivo=0
	WHERE 	numemp=iNumemp;
	--and keyx not in (SELECT keyx FROM stmpHojaAzul);

	--REEMPLAZAR # POR Ñ
	UPDATE 	STMPHOJAAZUL SET 
			nombre=REPLACE (nombre, '#', 'Ñ'),
			apellidopaterno=REPLACE (apellidopaterno, '#', 'Ñ'),
			apellidomaterno=REPLACE (apellidomaterno, '#', 'Ñ');
	
	--ACTUALIZA BENEFICIARIOS
	UPDATE SAPFAMILIARHOJAS SET
			clave=B.clave,
			numerofamiliares=B.numerofamiliares,
			parentesco=B.parentesco,
			--apellidopaterno=B.apellidopaterno,
			--apellidomaterno=B.apellidomaterno,
			--nombre=B.nombre,
			--fechanacimiento=B.fechanacimiento,
			escolaridad=B.escolaridad,
			empresa=B.empresa,
			ocupacion=B.ocupacion,
			telefonoempresa=B.telefonoempresa,
			telefonocasa=B.telefonocasa,
			numeroelp=B.numeroelp,
			fechacaptura=B.fechacaptura,
			personasdepENDientes=B.personasdependientes,
			beneficiarioactivo=1,
			--keyx=B.keyx
			idhoja_azul=B.keyx 
	FROM 	STMPHOJAAZUL B
	WHERE  	SAPFAMILIARHOJAS.numemp=B.numemp
			--SAPFAMILIARHOJAS.keyx = B.keyx
			and trim(SAPFAMILIARHOJAS.nombre)=trim(B.nombre)
			and trim(SAPFAMILIARHOJAS.apellidopaterno)=trim(B.apellidopaterno)
			and trim(SAPFAMILIARHOJAS.apellidomaterno)=trim(B.apellidomaterno)
			and SAPFAMILIARHOJAS.fechanacimiento::date=B.fechanacimiento::date;

	update 	STMPHOJAAZUL SET actualizado=1
	from 	SAPFAMILIARHOJAS B
	where 	trim(STMPHOJAAZUL.nombre)=trim(B.nombre)
			and trim(STMPHOJAAZUL.apellidopaterno)=trim(B.apellidopaterno)
			and trim(STMPHOJAAZUL.apellidomaterno)=trim(B.apellidomaterno)
			and STMPHOJAAZUL.fechanacimiento::date=B.fechanacimiento::date
			and STMPHOJAAZUL.numemp=B.numemp;
			
	--INSERTA NUEVOS BENEFICIARIOS
	INSERT 	INTO SAPFAMILIARHOJAS (numemp,clave,numerofamiliares,parentesco,apellidopaterno,apellidomaterno,nombre,fechanacimiento,escolaridad, empresa, ocupacion, telefonoempresa, telefonocasa, numeroelp, fechacaptura, keyx,personasdepENDientes,beneficiarioactivo)
	SELECT 	numemp,clave,numerofamiliares,parentesco,apellidopaterno,apellidomaterno,nombre,fechanacimiento,escolaridad, empresa, ocupacion, telefonoempresa, telefonocasa, numeroelp, fechacaptura, keyx,personasdepENDientes,1
	FROM   	STMPHOJAAZUL 
	WHERE 	actualizado=0;

	--REEMPLAZAR # POR Ñ
	UPDATE SAPFAMILIARHOJAS SET nombre=REPLACE (nombre, '#', 'Ñ'), apellidopaterno=REPLACE (apellidopaterno, '#', 'Ñ'), apellidomaterno=REPLACE (apellidomaterno, '#', 'Ñ');
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_actualizar_contactos_hoja_azul(integer, xml) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_actualizar_contactos_hoja_azul(integer, xml) TO syspersonal;
COMMENT ON FUNCTION fun_actualizar_contactos_hoja_azul(integer, xml) IS 'La función obtiene un listado de los beneficiarios beneficiarios de un colaborador.';
