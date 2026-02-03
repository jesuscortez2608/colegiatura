CREATE OR REPLACE FUNCTION fun_obtener_contactos_hoja_azul(
IN iNumEmp integer, 
OUT bNumemp BIGINT,
OUT iClave INTEGER,
OUT iNumerofamiliares INTEGER,
OUT iParentesco INTEGER,
OUT sApellidopaterno CHARACTER(20),
OUT sApellidomaterno CHARACTER(20),
OUT sNombre CHARACTER(20),
OUT sFechanacimiento date,
OUT sEscolaridad CHARACTER(30),
OUT sEmpresa CHARACTER(40),
OUT sOcupacion CHARACTER(30),
OUT sTelefonoempresa CHARACTER(12),
OUT sTelefonocasa CHARACTER(12),
OUT bNumeroelp BIGINT,
OUT dFechacaptura DATE,
OUT iKeyx INTEGER,
OUT iPersonasdependientes INTEGER
)
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 09-11-2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.1.14
-- Servidor Desarrollo: 10.44.4.209
-- Ejemplo: SELECT * FROM fun_obtener_contactos_hoja_azul (94827443)
-- ====================================================================================================
  RETURNS SETOF record AS
$BODY$
DECLARE	
	valor record;

BEGIN	
		
	FOR valor IN 
		SELECT 	numemp, clave, numerofamiliares, parentesco, coalesce(apellidopaterno,'') as apellidopaterno, coalesce(apellidomaterno,'') as apellidomaterno, coalesce(nombre,'') as nombre, 
				fechanacimiento, escolaridad, empresa, coalesce(ocupacion,'') AS ocupacion, coalesce(telefonoempresa, '') AS telefonoempresa, coalesce(telefonocasa, '') AS telefonocasa, numeroelp, fechacaptura, keyx, personasdependientes
		FROM 	SAPFAMILIARHOJAS 
		WHERE	numemp=iNumEmp AND parentesco in (3,4)
	LOOP
		bNumemp:=valor.numemp;
		iClave:=valor.clave;
		iNumerofamiliares:=valor.numerofamiliares;
		iParentesco:=valor.parentesco;
		sApellidopaterno:=valor.apellidopaterno;
		sApellidomaterno:=valor.apellidomaterno;
		sNombre:=valor.nombre;
		sFechanacimiento:=valor.fechanacimiento;
		sEscolaridad:=valor.escolaridad;
		sEmpresa:=valor.empresa;
		sOcupacion:=valor.ocupacion;
		sTelefonoempresa:=valor.telefonoempresa;
		sTelefonocasa:=valor.telefonocasa;
		bNumeroelp:=valor.numeroelp;
		dFechacaptura:=valor.fechacaptura;
		iKeyx:=valor.keyx;
		iPersonasdependientes:=valor.personasdependientes;
		
	RETURN NEXT;
	END LOOP;
	
end;	
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_contactos_hoja_azul(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_contactos_hoja_azul(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_contactos_hoja_azul(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_contactos_hoja_azul(integer) IS 'La función obtiene los beneficiarios de la hoja azul siempre y cuando sean esposo(a), hijo(a).';