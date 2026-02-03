DROP FUNCTION IF EXISTS fun_grabar_escuelas_colegiaturas_sep(character varying(12),character varying(50),character varying(50),character varying(50),integer,character varying(60),integer,character varying(50),integer,character varying(50),character varying(20),character varying(50),character varying(50),character varying(100),character varying(50),character varying(50),character varying(50),character varying(50),character varying(50),character varying(50),CHARACTER VARYING(20),character varying(10),character varying(50),character varying(50),integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,character varying(50),character varying(50),character varying(50),character varying(50),character varying(50));

CREATE OR REPLACE FUNCTION fun_grabar_escuelas_colegiaturas_sep(character varying(12)
	,character varying(50)
	,character varying(50)
	,character varying(50)
	,integer
	,character varying(60)
	,integer
	,character varying(150)
	,integer
	,character varying(150)
	,character varying(20)
	,character varying(50)
	,character varying(50)
	,character varying(150)
	,character varying(50)
	,character varying(100)
	,character varying(50)
	,character varying(100)
	,character varying(100)
	,character varying(100)
	,character varying(20)
	,character varying(10)
	,character varying(50)
	,character varying(100)
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,integer
	,character varying(50)
	,character varying(50)
	,character varying(50)
	,character varying(50)
	,character varying(50))
  RETURNS integer AS
$function$
DECLARE
	/*
	No. petición APS               : 
	Fecha                          : 01/01/1900
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.
	Descripción del funcionamiento : 
	Descripción del cambio         : 
	Sistema                        : 
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.
	Ejemplo                        : 
		
	------------------------------------------------------------------------------------------------------ */
BEGIN
	INSERT INTO stmp_escuelas_colegiaturas_sep (periodo,tipo_educativo,nivel_educativo,servicio_educativo,clave_entidad,entidad,clave_mun_del,municipio,clave_localidad,localidad,clave,turno,ambito,centro_educativo,control,domicilio,num_exterior,entre_calle,y_calle,calle_posterior,codigo_postal,lada,telefono,correo_electronico,total_de_personal,personal_mujeres,personal_hombres,total_de_docentes,docentes_mujeres,docentes_hombres,total_de_alumnos,alumnos_mujeres,alumnos_hombres,total_de_grupos,aulas_existentes,aulas_en_uso,laboratorios,talleres,computadoras_en_operacion,computadoras_en_operacion_internet,computadoras_en_operacion_uso_educativo,altitud_msnm,longitud,latitud,longitud_gms,latitud_gms)
	VALUES ($1
		,$2
		,$3
		,$4
		,$5
		,$6
		,$7
		,$8
		,$9
		,$10
		,$11
		,$12
		,$13
		,$14
		,$15
		,$16
		,$17
		,$18
		,$19
		,$20
		,$21
		,$22
		,$23
		,$24
		,$25
		,$26
		,$27
		,$28
		,$29
		,$30
		,$31
		,$32
		,$33
		,$34
		,$35
		,$36
		,$37
		,$38
		,$39
		,$40
		,$41
		,$42
		,$43
		,$44
		,$45
		,$46);
	
	RETURN 1;
END;
$function$
LANGUAGE plpgsql VOLATILE;