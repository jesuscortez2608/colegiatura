CREATE TYPE type_grabar_configuracion_de_descuentos AS
   (estado integer,
    msj character varying(70));
	
CREATE OR REPLACE FUNCTION fun_grabar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer)
  RETURNS SETOF type_grabar_configuracion_de_descuentos AS
$BODY$
DECLARE 
Opcion Alias FOR $1;    
empleado ALIAS FOR $2; 
centro ALIAS FOR $3;
puesto ALIAS FOR $4;
seccion ALIAS FOR $5;
escolaridad ALIAS FOR $6;
parentesco ALIAS FOR $7; 
porcentaje ALIAS FOR $8; 
comentario ALIAS FOR $9;
empleadocap ALIAS FOR $10;


registro type_grabar_configuracion_de_descuentos;

estado integer;

BEGIN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
     /*
     No. petición APS               : 8613.1
     Fecha                          : 26/09/2016
     Número empleado                : 96753269
     Nombre del empleado            : Jesús Ramón Vega Taboada
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : 
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de estudios
     Ejemplo                        : Graba los datos de los Descuentos
     select * from fun_grabar_configuracion_de_descuentos (1, 96753269, 0, 0, 0, 1, 1, 1, 'hola', 95194185);
     select * from fun_grabar_configuracion_de_descuentos (2, 0, 230468,77, 0, 1, 1, 1, 'hola', 95194185);
     select * from fun_grabar_configuracion_de_descuentos (3, 0, 0, 77, 2, 1, 1, 2, 'hola', 95194185);
------------------------------------------------------------------------------------------------------
	No. peticion APS		: 16559.1
	Fecha				: 23/04/2018
	Número empleado			: 98439677
	Nombre del empleado		: Rafael Ramos Gutiérrez
	BD				: Personal
	Descripcion del Cambio		: Se elimino validación para agregar descuento a escolaridad Maestria sin Ser al mismo colaborador al que se le aplicaria.
  ------------------------------------------------------------------------------------------------------ */
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
	--IF (escolaridad=6 and parentesco!=11) THEN
	--	estado:=7; 
	--ELSE
	IF Opcion = 1 THEN
		IF (EXISTS (SELECT idu_empleado FROM ctl_configuracion_descuentos 
		WHERE idu_empleado = empleado and idu_parentesco=parentesco and idu_escolaridad=escolaridad )) then
			estado:=2;
		ELSE            
			INSERT INTO ctl_configuracion_descuentos (idu_empleado, idu_escolaridad, idu_parentesco, por_porcentaje, des_comentario, fec_registro, idu_empleado_registro) 
			VALUES (empleado, escolaridad, parentesco, porcentaje, comentario, now(), empleadocap);
			estado:=1; 
		END IF;
	ELSIF Opcion = 2 THEN
		IF (EXISTS (SELECT idu_centro FROM ctl_configuracion_descuentos
		WHERE idu_centro = centro and idu_puesto = puesto and idu_parentesco=parentesco  and idu_escolaridad=escolaridad)) then
			estado:=4;
		ELSE            
			INSERT INTO ctl_configuracion_descuentos (idu_centro, idu_puesto, idu_escolaridad, idu_parentesco, por_porcentaje, des_comentario, fec_registro, idu_empleado_registro ) 
			VALUES (centro, puesto, escolaridad, parentesco, porcentaje, comentario, now(), empleadocap);
			estado:=3; 
		END IF;
	ELSE
		IF (EXISTS (SELECT idu_puesto FROM ctl_configuracion_descuentos
		WHERE idu_seccion = seccion and idu_puesto = puesto and idu_parentesco=parentesco  and idu_escolaridad=escolaridad)) then
			estado:=6;

		ELSE            
			INSERT INTO ctl_configuracion_descuentos (idu_puesto, idu_seccion , idu_escolaridad, idu_parentesco, por_porcentaje, des_comentario, fec_registro, idu_empleado_registro ) 
			VALUES (puesto, seccion, escolaridad, parentesco, porcentaje, comentario, now(), empleadocap);
			estado:=5; 
		END IF;
	END IF;
	--END IF;
	for registro in select estado, case when estado = 1 then 'Descuento empleado agregado correctamente' when estado = 2 then 'Descuento empleado ya existe' when estado = 3 then 'Descuento de centro agregado correctamente'
	when estado = 4 then 'Descuento de centro ya existe' when estado = 5 then'Descuento de puesto agregado correctamente' when estado = 6 then 'Descuento de puesto ya existe' else 'El estudio de maestría sólo se permite para el colaborador ' END
	loop
		return next registro;
	end loop;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_grabar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_configuracion_de_descuentos(integer, integer, integer, integer, integer, integer, integer, integer, character varying, integer) IS 'FUNCION PARA GRABAR LA CONFIGURACION DE DESCUENTOS.';
