DROP TABLE IF EXISTS stmp_escuelas_colegiaturas_sep;

CREATE TABLE stmp_escuelas_colegiaturas_sep (periodo VARCHAR(12) --] => 2014-2015
	, tipo_educativo VARCHAR(50) --] => educaci&#211;n media superior
	, nivel_educativo VARCHAR(50) --] => bachillerato
	, servicio_educativo VARCHAR(50) --] => bachillerato general
	, clave_entidad INTEGER --] => 01
	, entidad VARCHAR(60) --] => aguascalientes
	, clave_mun_del INTEGER --] => 010
	, municipio  VARCHAR(150) --] => el llano
	, clave_localidad INTEGER --] => 0107
	, localidad  VARCHAR(150) --] => santa rosa (el huizache)
	, clave VARCHAR(20) --] => 01etk0002m
	, turno  VARCHAR(50) --] => vespertino
	, ambito VARCHAR(50) --] => rural
	, centro_educativo VARCHAR(150) --] => telebachillerato comunitario santa rosa
	, control VARCHAR(50) --] => p&#218;blico
	, domicilio VARCHAR(100) --] => pedro martinez
	, num_exterior VARCHAR(50) --] => &nbsp;
	, entre_calle VARCHAR(100) --] => pedro gomez
	, y_calle VARCHAR(100) --] => ninguno
	, calle_posterior VARCHAR(100) --] => &nbsp;
	, codigo_postal VARCHAR(20) --] => 20350
	, lada VARCHAR(10) --] => &nbsp;
	, telefono VARCHAR(50) --] => &nbsp;
	, correo_electronico VARCHAR(100) --] => &nbsp;
	, total_de_personal INTEGER --] => 3
	, personal_mujeres INTEGER --] => 3
	, personal_hombres INTEGER --] => 0
	, total_de_docentes INTEGER --] => 3
	, docentes_mujeres INTEGER --] => 3
	, docentes_hombres INTEGER --] => 0
	, total_de_alumnos INTEGER --] => 44
	, alumnos_mujeres INTEGER --] => 24
	, alumnos_hombres INTEGER --] => 20
	, total_de_grupos INTEGER --] => 2
	, aulas_existentes INTEGER --] => 5
	, aulas_en_uso INTEGER --] => 5
	, laboratorios INTEGER --] => 0
	, talleres INTEGER --] => 0
	, computadoras_en_operacion INTEGER --] => 0
	, computadoras_en_operacion_internet INTEGER --] => 0
	, computadoras_en_operacion_uso_educativo INTEGER --] => 0
	, altitud_msnm VARCHAR(50) --] => 2028
	, longitud VARCHAR(50) --] => -102.021944
	, latitud VARCHAR(50) --] => 21.935000
	, longitud_gms VARCHAR(50) --] => -102:01:19.000
	, latitud_gms VARCHAR(50) --] => 21:56:06.000
);

create index idx_stmp_escuelas_colegiaturas_sep_periodo on stmp_escuelas_colegiaturas_sep(periodo);
create index idx_stmp_escuelas_colegiaturas_sep_nivel_educativo on stmp_escuelas_colegiaturas_sep(nivel_educativo);
create index idx_stmp_escuelas_colegiaturas_sep_clave_entidad on stmp_escuelas_colegiaturas_sep(clave_entidad);
create index idx_stmp_escuelas_colegiaturas_sep_clave_mun_del on stmp_escuelas_colegiaturas_sep(clave_mun_del);
create index idx_stmp_escuelas_colegiaturas_sep_clave_localidad on stmp_escuelas_colegiaturas_sep(clave_localidad);
create index idx_stmp_escuelas_colegiaturas_sep_clave on stmp_escuelas_colegiaturas_sep(clave);
create index idx_stmp_escuelas_colegiaturas_sep_turno on stmp_escuelas_colegiaturas_sep(turno);
create index idx_stmp_escuelas_colegiaturas_sep_ambito on stmp_escuelas_colegiaturas_sep(ambito);
create index idx_stmp_escuelas_colegiaturas_sep_control on stmp_escuelas_colegiaturas_sep(control);
create index idx_stmp_escuelas_colegiaturas_sep_codigo_postal on stmp_escuelas_colegiaturas_sep(codigo_postal);