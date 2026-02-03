/*
	No. petición APS               : 16995.1 Mejoras al sistema de colegiaturas
	Fecha                          : 12/09/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : personal
	Descripción                    : Tabla de puestos gerenciales
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
------------------------------------------------------------------------------------------------------ */
-- Definición
    DROP TABLE IF EXISTS cat_puestos_jefaturas;
    
    create table cat_puestos_jefaturas (idu_puesto integer not null default(0)
        , idu_usuario integer not null default(0)
        , fec_registro timestamp without time zone not null default(now())
    );

-- Índices
    CREATE INDEX ix_cat_puestos_jefaturas_idu_puesto ON cat_puestos_jefaturas(idu_puesto);

-- Documentación
    comment on column cat_puestos_jefaturas.idu_puesto is 'ID del puesto de jefe'; 
    comment on column cat_puestos_jefaturas.idu_usuario is 'ID del usuario que captura'; 
    comment on column cat_puestos_jefaturas.fec_registro is 'Fecha de captura'; 

-- Datos iniciales
    insert into cat_puestos_jefaturas (idu_puesto, idu_usuario)
        values (103, 95194185),
            (104, 95194185);