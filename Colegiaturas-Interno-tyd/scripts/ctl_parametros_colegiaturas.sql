drop table if exists ctl_parametros_colegiaturas;
/**---------------------------------------------------------------------------------------------------------------------------------------------------------
	Peticion APS:			16559.1
	Número empleado:		98439677
	Nombre empleado:		Rafael Ramos Gutiérrez
	BD:						Personal
	Sistema:				Colegiaturas
	Descripcion:			Contiene parametros utilizados en el funcionamiento del sistema de colegiaturas
-----------------------------------------------------------------------------------------------------------------------------------------------------*/

create table ctl_parametros_colegiaturas(
    id SERIAL
    , nom_parametro CHARACTER VARYING(100)
    , tipo_parametro CHARACTER VARYING(50)
    , valor_parametro TEXT
);

--Datos
insert into ctl_parametros_colegiaturas (nom_parametro, tipo_parametro, valor_parametro) values ('PERMITIR_DESCUENTOS_DIFERENTES', 'INTEGER', '0');
insert into ctl_parametros_colegiaturas (nom_parametro, tipo_parametro, valor_parametro) values ('URL_SERVICIO_FACTURACION', 'VARCHAR', 'http://seguro.coppel.com/WsReceptorFacturacion/WsReceptorFacturacion.php?wsdl');
insert into ctl_parametros_colegiaturas (nom_parametro, tipo_parametro, valor_parametro) values ('URL_SERVICIO_COLEGIATURAS', 'VARCHAR', 'http://appadmon.coppel.com:8080/WsColegiaturas/rest');
insert into ctl_parametros_colegiaturas (nom_parametro, tipo_parametro, valor_parametro) values ('REGIONES_PERMITIDAS', 'VARCHAR', '1');
insert into ctl_parametros_colegiaturas (nom_parametro, tipo_parametro, valor_parametro) values ('PERMITIR_FACTURAS_ANIOS_ANTERIORES','INTEGER','0');
