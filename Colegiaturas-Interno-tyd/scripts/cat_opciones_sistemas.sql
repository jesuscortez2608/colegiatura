/*
	No. petición APS               : 16995.1 Mejoras al sistema de colegiaturas
	Fecha                          : 12/09/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : personal
	Descripción                    : Tabla de opciones para el acceso a sistemas
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
------------------------------------------------------------------------------------------------------ */
-- Definición
    DROP TABLE IF EXISTS cat_opciones_sistemas;
    
    create table cat_opciones_sistemas (idu_sistema INTEGER NOT NULL DEFAULT(0)
        , idu_modulo INTEGER NOT NULL DEFAULT(0)
        , idu_opcion SERIAL
        , nom_opcion VARCHAR(150) NOT NULL DEFAULT('')
        , on_select TEXT NOT NULL DEFAULT('')
        , idu_usuario integer not null default(0)
        , fec_registro timestamp without time zone not null default(now())
    );

-- Índices
    CREATE INDEX ix_cat_opciones_sistemas_idu_sistema ON cat_opciones_sistemas(idu_sistema);
    CREATE INDEX ix_cat_opciones_sistemas_idu_modulo ON cat_opciones_sistemas(idu_modulo);
    CREATE INDEX ix_cat_opciones_sistemas_idu_opcion ON cat_opciones_sistemas(idu_opcion);
    CREATE INDEX ix_cat_opciones_sistemas_idu_usuario ON cat_opciones_sistemas(idu_usuario);
    CREATE INDEX ix_cat_opciones_sistemas_fec_registro ON cat_opciones_sistemas(fec_registro);

-- Documentación
    comment on column cat_opciones_sistemas.idu_sistema is 'ID del sistema (cat_sistemas.id_sistema)'; 
    comment on column cat_opciones_sistemas.idu_modulo is 'ID del módulo (cat_modulos_sistemas.idu_modulo)'; 
    comment on column cat_opciones_sistemas.idu_opcion is 'ID de la opción (SERIAL)'; 
    comment on column cat_opciones_sistemas.nom_opcion is 'Nombre de la opción'; 
    comment on column cat_opciones_sistemas.on_select is 'Comando ejecutado al seleccionar la opción, (debe asegurarse de que este comando o función exista en el ambiente donde se carga la opción)'; 
    comment on column cat_opciones_sistemas.idu_usuario is 'ID del usuario'; 
    comment on column cat_opciones_sistemas.fec_registro is 'Fecha de registro'; 
    
-- Datos iniciales
    insert into cat_opciones_sistemas(idu_sistema, idu_modulo, nom_opcion, on_select, idu_usuario)
        values (13, 1, 'Sistema de colegiaturas', 'sendSessionColegiaturas();', 95194185),
                (13, 2, 'Subir factura', 'show(''subirfacturaselectronica'');', 95194185),
                (13, 2, 'Manuales', 'show(''manualesfacturas'')', 95194185),
                (13, 2, 'Administrador Factura', 'show(''facturaAdmin'');', 95194185),
                (13, 3, 'Facturas de Empleados por Gerente', 'show(''empger'');', 95194185),
                (13, 3, 'Facturas de Empleados por ELP', 'show(''facper'');', 95194185),
                (13, 3, 'Facturas Electr&oacute;nicas Colegiaturas por Personal', 'show(''fac_colegiaturas_personal'');', 95194185),
                (13, 3, 'Facturas Electr&oacute;nicas Gastos Viaje por Personal', 'show(''fac_gastos_personal'');', 95194185),
                (13, 3, 'Facturas Electr&oacute;nicas Empleados', 'show(''fac_empleados'');', 95194185);
    