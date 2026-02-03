DROP FUNCTION IF EXISTS fun_grabar_escolaridad(integer, character varying, integer);
DROP TYPE IF EXISTS type_grabar_escolaridad;

CREATE TYPE type_grabar_escolaridad AS
   (estado integer,
    msj character varying(50));

	
CREATE OR REPLACE FUNCTION fun_grabar_escolaridad(integer, character varying, integer)
  RETURNS SETOF type_grabar_escolaridad AS
$BODY$
DECLARE    
iescolaridad ALIAS FOR $1;        
nescolaridad ALIAS FOR $2;
iempleado_registro ALIAS FOR $3;
registro type_grabar_escolaridad;

estado integer;

BEGIN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
     /*
     No. petición APS               : 8613.1
     Fecha                          : 02/09/2016
     Número empleado                : 96753269
     Nombre del empleado            : Jesús Ramón Vega Taboada
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : Graba los datos de las escolaridades
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de estudios
     Ejemplo                        : select * from fun_grabar_escolaridad (0, 'PRIMARIA', 93902761)
  ------------------------------------------------------------------------------------------------------ */
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
	IF (EXISTS (SELECT nom_escolaridad FROM cat_escolaridades WHERE trim(nom_escolaridad)=upper(trim(nescolaridad)))) then
		estado:=2;
	ELSE
		
		IF (EXISTS (SELECT idu_escolaridad FROM cat_escolaridades WHERE idu_escolaridad=iescolaridad)) then   
			UPDATE cat_escolaridades SET nom_escolaridad = upper(trim(nescolaridad)), idu_empleado_registro = iempleado_registro, fec_captura = now()
			WHERE idu_escolaridad=iescolaridad;
			estado:=1; 
		ELSE              
			INSERT INTO cat_escolaridades (nom_escolaridad, idu_empleado_registro, fec_captura) 
			VALUES (upper(trim(nescolaridad)), iempleado_registro, now());
			estado:=0; 
		END if;
	END IF;
	for registro in select estado, case when estado = 1 then 'Escolaridad actualizada correctamente' when estado = 2 then 'La Escolaridad ya existe'
	else 'Escolaridad registrada correctamente' END
	loop
		return next registro;
	end loop;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_escolaridad(integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_escolaridad(integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_escolaridad(integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_escolaridad(integer, character varying, integer) TO postgres;