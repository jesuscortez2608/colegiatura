DROP FUNCTION IF EXISTS fun_obtener_escuelas_linea();

CREATE OR REPLACE FUNCTION fun_obtener_escuelas_linea(OUT iidu_escuela integer, OUT snom_escuela character varying, OUT srfc character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	/**-------------------------------------------------------
		No Peticion:		16559.1
		Núm.Colaborador:	94827443 
		Colaborador:		Omar Alejandro Lizarraga Hernandez
		Sistema:		Colegiaturas
		Modulo:			Captura de Facturas por Personal Admon.
		Descripción:		Obtiene el listado de escuelas dadas de alta como Extranjeras/En Linea
		Ejemplo:
					SELECT * FROM fun_obtener_escuelas_linea();
		---------------------------------------------------
		Colaborador:		98439677 Rafael Ramos Gutiérrez
		Descripcion del cambio:	Se agrega validación para que solo aparescan en el listado aquellas escuelas que no esten bloqueadas
					en la configuración de escuela/escolaridad.
	--------------------------------------------------------*/
	--DECLARACION DE VARIABLES
	valor record;		
BEGIN
	--TABLA TEMPORAL
	CREATE TEMP TABLE Datos(
		idu_escuela integer,
		nombre_escuela varchar(100),
		rfc varchar(20)		
	) ON COMMIT DROP;

	INSERT 	INTO Datos (idu_escuela, nombre_escuela,rfc)
	SELECT 	idu_escuela, nom_escuela, rfc_clave_sep 
	FROM 	CAT_ESCUELAS_COLEGIATURAS 
	WHERE 	idu_estado=0
		and opc_escuela_bloqueada = 0;
	
	--VALORES REGRESADOS
	FOR valor IN (SELECT idu_escuela, nombre_escuela, rfc FROM  Datos)
		LOOP
			 iidu_escuela:=valor.idu_escuela;
			 snom_escuela:=valor.nombre_escuela;
			 srfc:=valor.rfc;
			
		RETURN NEXT; 
		END LOOP;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_linea() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_linea() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_linea() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_escuelas_linea() TO postgres;
COMMENT ON FUNCTION fun_obtener_escuelas_linea() IS 'La función obtiene las diferentes escuelas configuradas como especiales. Estas escuelas son utilizadas para captura de facturas de colaboradores que tienen estudios en línea o en el extranjero.';