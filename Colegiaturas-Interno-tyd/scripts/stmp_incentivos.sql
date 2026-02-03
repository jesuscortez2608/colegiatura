/*
	No. petición APS               : 16559
	Fecha                          : 29/10/2018
	Número empleado                : 94827443
	Nombre del empleado            : Omar Alejandro Lizárraga Hernández
	Base de datos                  : 
	Usuario de BD                  : 
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : Tabla que concentra los incentivos del sistema anterior con el nuevo	
	Sistema                        : Colegiaturas
	Módulo                         : 
	Repositorio del proyecto       : svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
	
		
------------------------------------------------------------------------------------------------------ */
CREATE TABLE stmp_incentivos
(
	num_empresa integer,
	nom_empresa character varying(200),
	num_empleado integer,
	nombre character varying(200),
	imp_factura numeric(12,2),
	imp_isr numeric(12,2),
	total numeric(12,2)
)