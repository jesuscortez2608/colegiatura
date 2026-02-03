CREATE OR REPLACE FUNCTION fun_obtener_listado_beneficiarios_colegiaturas(
IN iempleado integer, 
OUT iidu_beneficiario integer, 
OUT snombre character varying, 
OUT sape_paterno character varying, 
OUT sape_materno character varying, 
OUT iidu_parentesco integer, 
OUT sdes_parentesco character varying, 
OUT itipo_beneficiario integer)
  RETURNS SETOF record AS
$BODY$
DECLARE  
	valor record;
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 06-06-2018
-- Descripción General: Obtiene los beneficiarios de la hoja azul y de la captura de beneficiarios de colegiaturas
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.44.114.75 
-- Ejemplo: SELECT * FROM fun_obtener_listado_beneficiarios_colegiaturas(94827443)
-- ====================================================================================================
BEGIN

	CREATE TEMPORARY TABLE tmp_Beneficiarios
	(
		idu_empleado integer not null default 0,
		idu_beneficiario integer not null default 0,
		nombre varchar(50) not null default '',
		ape_paterno varchar(50) not null default '',
		ape_materno varchar(50) not null default '',
		idu_parentesco integer  not null default 0,
		des_parentesco varchar (20) not null default '',
		tipo_beneficiario integer not null default 0		
	)on commit drop;

	--INSERTA BENEFICIARIOS HOJA AZUL	
	INSERT 	INTO tmp_Beneficiarios (idu_empleado,idu_beneficiario,nombre,ape_paterno,ape_materno,idu_parentesco,tipo_beneficiario)
	SELECT 	numemp, keyx, coalesce(trim(nombre), ''), coalesce(trim(apellidopaterno),''), coalesce(trim(apellidomaterno), ''), parentesco, 0 
	FROM 	SAPFAMILIARHOJAS 
	WHERE 	numemp=iEmpleado 
			AND beneficiarioactivo=1
			AND parentesco in (3,4);

	--INSERTA BENEFICIARIOS CAPTURA BENEFICIARIOS
	INSERT 	INTO tmp_Beneficiarios (idu_empleado,idu_beneficiario,nombre,ape_paterno,ape_materno,idu_parentesco,tipo_beneficiario)
	SELECT 	idu_empleado,idu_beneficiario,coalesce(trim(nom_beneficiario),''), coalesce(trim(ape_paterno),''), coalesce(trim(ape_materno),''), idu_parentesco,1
	FROM 	CAT_BENEFICIARIOS_COLEGIATURAS 
	WHERE 	idu_empleado=iEmpleado; 

	--PARENTESCO
	UPDATE 	tmp_Beneficiarios SET des_parentesco=B.des_parentesco
	FROM	CAT_PARENTESCOS B
	WHERE	tmp_Beneficiarios.idu_parentesco=B.idu_parentesco;	

	--RETORNA VALOR DE UNA CADENA DE CONSULTA
	FOR valor IN (SELECT idu_beneficiario,nombre,ape_paterno,ape_materno,idu_parentesco,des_parentesco,tipo_beneficiario FROM tmp_Beneficiarios ORDER BY nombre)
	LOOP		
		iidu_beneficiario:=valor.idu_beneficiario;
		snombre:=valor.nombre;
		sape_paterno:=valor.ape_paterno;
		sape_materno:=valor.ape_materno;
		iidu_parentesco:=valor.idu_parentesco;
		sdes_parentesco:=valor.des_parentesco;
		itipo_beneficiario:=valor.tipo_beneficiario;
				
	RETURN NEXT;
	END LOOP;
	
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_beneficiarios(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_beneficiarios(integer) IS 'La función obtiene un listado de los beneficiarios beneficiarios de un colaborador.';