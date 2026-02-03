/*
Nombre: Omar Alejandro Lizárraga Hernández
Fecha: 21-05-2019
Sistema: Colegiaturas WEB
Servidor Produccion: 10.44.1.13
Servidor Desarrollo: 10.44.1.135
BD: Personal
*/
CREATE TABLE stmp_empleados_cancelados(
	numemp integer not null default 0,
	cancelado char(1) not null default '',
	conexion integer not null default 0
);