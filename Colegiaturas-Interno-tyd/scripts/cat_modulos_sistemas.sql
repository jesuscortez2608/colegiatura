/*
	No. petición APS               : 16995.1 Mejoras al sistema de colegiaturas
	Fecha                          : 12/09/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : personal
	Descripción                    : Tabla de control de acceso a los sistemas de colegiaturas
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
------------------------------------------------------------------------------------------------------ */
-- Definición
    DROP TABLE IF EXISTS cat_modulos_sistemas;
    
    create table cat_modulos_sistemas (idu_modulo SERIAL
        , idu_sistema INTEGER NOT NULL DEFAULT(0)
        , nom_modulo VARCHAR(150) NOT NULL DEFAULT('')
        , idu_usuario integer not null default(0)
        , fec_registro timestamp without time zone not null default(now())
    );
    
-- Índices
    CREATE INDEX ix_cat_modulos_sistemas_idu_modulo ON cat_modulos_sistemas(idu_modulo);
    CREATE INDEX ix_cat_modulos_sistemas_idu_sistema ON cat_modulos_sistemas(idu_sistema);
    CREATE INDEX ix_cat_modulos_sistemas_nom_modulo ON cat_modulos_sistemas(nom_modulo);
    CREATE INDEX ix_cat_modulos_sistemas_idu_usuario ON cat_modulos_sistemas(idu_usuario);
    CREATE INDEX ix_cat_modulos_sistemas_fec_registro ON cat_modulos_sistemas(fec_registro);

-- Documentación
    comment on column cat_modulos_sistemas.idu_modulo is 'ID del módulo (SERIAL)'; 
    comment on column cat_modulos_sistemas.idu_sistema is 'ID del sistema (cat_sistemas.id_sistema)'; 
    comment on column cat_modulos_sistemas.nom_modulo is 'Nombre del módulo'; 
    comment on column cat_modulos_sistemas.idu_usuario is 'ID del usuario'; 
    comment on column cat_modulos_sistemas.fec_registro is 'Fecha de registro'; 
    
-- Datos iniciales
    insert into cat_modulos_sistemas(idu_sistema, nom_modulo, idu_usuario)
        values (13, 'Colegiaturas', 95194185),
                (13, 'Control Facturas Electronicas', 95194185),
                (13, 'Seguimiento de Facturas Electronicas', 95194185);
    
    