DROP FUNCTION if exists fun_grabar_escuela_escolaridad(integer, integer, integer, integer, integer, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying);
drop type if exists type_grabar_escuela_escolaridad;

CREATE TYPE type_grabar_escuela_escolaridad AS
   (estado integer,
    mensaje character varying(100));
CREATE OR REPLACE FUNCTION fun_grabar_escuela_escolaridad(integer, integer, integer, integer, integer, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying)
  RETURNS SETOF type_grabar_escuela_escolaridad AS
$BODY$
DECLARE    

idescuela 		ALIAS FOR $1;
tipo_escuela 		ALIAS FOR $2;
iEstado 		ALIAS for $3;
iMunicipio 		ALIAS for $4;
iLocalidad		ALIAS FOR $5;
rfcClave_sep 		ALIAS FOR $6;
nomescuela 		ALIAS FOR $7;
id_escolaridad 		ALIAS FOR $8;
id_deduccion 		ALIAS FOR $9;
idCarrera 		ALIAS FOR $10;
educacionEsp 		ALIAS FOR $11;
pdf 			ALIAS FOR $12;
notaCredito 		ALIAS FOR $13;
id_empleado 		ALIAS FOR $14;
obs 			ALIAS FOR $15;

registro type_grabar_escuela_escolaridad;
idescuelaN INTEGER;
estado integer;
sEstado varchar(60);
sMunicipio varchar(150);

BEGIN
-------------------------------------------------------------------------------------------------------------------------------------------------------------------
     /*
     No. petición APS               : 8613.1
     Fecha                          : 14/09/2016
     Número empleado                : 96753269
     Nombre del empleado            : Jesús Ramón Vega Taboada
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : 
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de estudios
     Ejemplo                        : Graba los datos de la  s escuelas
	select * from fun_grabar_escuela_escolaridad(0, 1, 'CL0257809XY'::VARCHAR, 'CLUB DE LEONES'::VARCHAR, 2, 1, 1, 96753269, 'A todo dar', 1); 
	select * from fun_grabar_escuela_escolaridad(0, 1, 'AILP790121'::VARCHAR, 'ALIBABA Y LOS TRESCIENTOS LADRONES'::VARCHAR, 2, 1, 1, 96753269, 'A todo dar', 1); 
	select * from fun_grabar_escuela_escolaridad(1, 1, 'CL0257809XY'::VARCHAR, 'CLUB DE LEONES DEL ESTADO DE SINALOA'::VARCHAR, 2, 1, 1, 96753269, 'oejirhfgoiwhnaero', 1); 

	select * from fun_grabar_escuela_escolaridad(2, 1, 'AILP7901221'::VARCHAR, 'ALIBABA Y LOS TRESCIENTOS LADRONES SA DE CV'::VARCHAR, 2, 1, 1, 96753269, 'oejirhfgoiwhnaero', 1); 
	SELECT * FROM cat_escuelas_colegiaturas
	DELETE FROM cat_escuelas_colegiaturas
SELECT rfc_clave_sep FROM cat_escuelas_colegiaturas WHERE rfc_clave_sep = rtrim(upper('ROSS')) and idu_escolaridad=6


select * from fun_grabar_escuela_escolaridad(0, 2, 1, 4, '51333KJK', 'ESCUELITA', 1, 0, 0, 0, 0, 93902761, '', )
	select * from fun_grabar_escuela_escolaridad(13528, 2, 5, 35, 'DASDA', 'INSTITUTO TECNOLÓGICO DE ESTUDIOS SUPERIORES DE MONTERREY CAMPUS LAGUNA', 5, 0, 0, 0, 1, 95194185, '')
	*/
--
/*------------------------------------------------------------------------------
	No. Peticion APS		:	16559.1
	Modifico				:	Rafael Ramos Gutiérrez 98439677
	Fecha					:	06/04/2018	
	Descripcion del cambio	:	-Se eliminaros parametros de entrada(sEstado, sMunicipio) que no existen en la tabla: CAT_ESCUELAS_COLEGIATURAS
								-Se agrego el parametro iLocalidad, para identificar a que localidad pertenece la escuela al registrarla
								-Se agrego el parametro idu_deduccion, que tiene valor de 1, ya que cuando se registre una nueva escuela, por default el tipo de deduccion sera "Deducible"
	Ejemplo(con cambio hecho):	fun_grabar_escuela_escolaridad(0, 2, 25, 18, 74, 'BBBBBBBBBBBB1', 'TEC21', 6, 1, 1, 0, 0, 0, 98439677, '')
*/--------------------------------------------------------------------------------
 	if idescuela>0 then --Actualiza
		--IF (EXISTS (SELECT rfc_clave_sep FROM cat_escuelas_colegiaturas WHERE rfc_clave_sep = rtrim(upper(rfcClave_sep)) /*and idu_escolaridad=id_escolaridad*/ and idescuela not in(idu_escuela)  and  trim(nom_escuela)=trim(upper(nomescuela)))) then
		if (exists (select rfc_clave_sep from cat_escuelas_colegiaturas where rfc_clave_sep = rtrim(upper(rfcClave_sep)) and idu_escolaridad = id_escolaridad and idescuela not in (idu_escuela))) then
			estado:=2;
		else
			UPDATE cat_escuelas_colegiaturas SET opc_tipo_escuela = tipo_escuela,
			idu_estado = iEstado,
			idu_municipio = iMunicipio,
			rfc_clave_sep = rtrim(upper(rfcClave_sep)), 
			nom_escuela = rtrim(upper(nomescuela)), 
			idu_escolaridad = id_escolaridad, 
			idu_tipo_deduccion = id_deduccion,
			idu_carrera=idCarrera, 
			opc_educacion_especial = educacionEsp,
			opc_obligatorio_pdf = pdf,
			opc_nota_credito=notaCredito,
			fec_captura = now(), 
			id_empleado_registro = id_empleado, 
			observaciones = rtrim(upper(obs))
			WHERE idu_escuela=idescuela;
			estado:=1;		
		end if;	
	else --Inserta  select * from cat_escuelas_colegiaturas
		
		IF (EXISTS (SELECT rfc_clave_sep FROM cat_escuelas_colegiaturas WHERE rfc_clave_sep = rtrim(upper(rfcClave_sep)) and idu_escolaridad = id_escolaridad/*nom_escuela = rtrim(upper(nomescuela))*/ ))then
			estado:=2;
		else
			idescuelaN:= (select COALESCE(MAX(idu_escuela),0)+1 from cat_escuelas_colegiaturas);
			
			INSERT INTO cat_escuelas_colegiaturas(idu_escuela, opc_tipo_escuela, idu_estado, idu_municipio, idu_localidad, idu_tipo_deduccion, rfc_clave_sep, nom_escuela, idu_escolaridad, idu_carrera, 
								opc_educacion_especial, opc_obligatorio_pdf, opc_nota_credito, opc_escuela_bloqueada, fec_captura, id_empleado_registro, observaciones)

			VALUES(idescuelaN, tipo_escuela, iEstado, iMunicipio, iLocalidad, id_deduccion, rtrim(upper(rfcClave_sep)), rtrim(upper(nomescuela)), id_escolaridad, idCarrera, educacionEsp, pdf, notaCredito, 
				0,now(), id_empleado, rtrim(upper(obs)));
			estado:=0; 
		end if;
	end if;
	
	for registro in select estado, case when estado = 1 then 'Los datos se actualizaron' when estado = 2 then 'La escuela con esa escolaridad ya existe, favor de verificar'
	else 'Los datos se guardaron' END
	loop
		return next registro;
	end loop;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_escuela_escolaridad(integer, integer, integer, integer, integer, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_escuela_escolaridad(integer, integer, integer, integer, integer, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_escuela_escolaridad(integer, integer, integer, integer, integer, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_escuela_escolaridad(integer, integer, integer, integer, integer, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying) TO postgres;
COMMENT ON FUNCTION fun_grabar_escuela_escolaridad(integer, integer, integer, integer, integer, character varying, character varying, integer, integer, integer, integer, integer, integer, integer, character varying) IS 'La función graba una escuela en el 
catálogo de escuelas (cat_escuelas_colegiaturas).';  