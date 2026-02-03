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
    DROP TABLE IF EXISTS ctl_permisos_sistemas;
    CREATE TABLE ctl_permisos_sistemas (idu_acceso SERIAL
        , idu_sistema INTEGER NOT NULL DEFAULT(0)
        , idu_modulo INTEGER NOT NULL DEFAULT(0)
        , idu_opcion INTEGER NOT NULL DEFAULT(0)
        , idu_empleado integer not null default(0)
        , idu_puesto integer not null default(0)
        , idu_centro integer not null default(0)
        , idu_ciudad integer not null default(0)
        , idu_region integer not null default(0)
        , idu_area integer not null default(0)
        , idu_seccion integer not null default(0)
        , opc_acceso_jefe INTEGER NOT NULL DEFAULT(0)
        , opc_acceso_gerente INTEGER NOT NULL DEFAULT(0)
        , opc_acceso_general INTEGER NOT NULL DEFAULT(0)
        , fec_inicial date not null default('19000101')
        , fec_final date not null default('19000101')
        , opc_indefinido smallint not null default(0)
        , opc_acceso_cancelado smallint not null default(0)
        , tipo_acceso smallint not null default(0)
        , idu_usuario integer not null default(0)
        , fec_registro timestamp without time zone not null default(now())
    );
    
-- Índices
    CREATE INDEX ix_ctl_permisos_sistemas_idu_acceso ON ctl_permisos_sistemas(idu_acceso);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_sistema ON ctl_permisos_sistemas(idu_sistema);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_modulo ON ctl_permisos_sistemas(idu_modulo);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_opcion ON ctl_permisos_sistemas(idu_opcion);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_empleado ON ctl_permisos_sistemas(idu_empleado);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_puesto ON ctl_permisos_sistemas(idu_puesto);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_centro ON ctl_permisos_sistemas(idu_centro);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_ciudad ON ctl_permisos_sistemas(idu_ciudad);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_region ON ctl_permisos_sistemas(idu_region);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_area ON ctl_permisos_sistemas(idu_area);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_seccion ON ctl_permisos_sistemas(idu_seccion);
    CREATE INDEX ix_ctl_permisos_sistemas_opc_acceso_jefe ON ctl_permisos_sistemas(opc_acceso_jefe);
    CREATE INDEX ix_ctl_permisos_sistemas_opc_acceso_gerente ON ctl_permisos_sistemas(opc_acceso_gerente);
    CREATE INDEX ix_ctl_permisos_sistemas_opc_acceso_general ON ctl_permisos_sistemas(opc_acceso_general);
    CREATE INDEX ix_ctl_permisos_sistemas_fec_inicial ON ctl_permisos_sistemas(fec_inicial);
    CREATE INDEX ix_ctl_permisos_sistemas_fec_final ON ctl_permisos_sistemas(fec_final);
    CREATE INDEX ix_ctl_permisos_sistemas_opc_indefinido ON ctl_permisos_sistemas(opc_indefinido);
    CREATE INDEX ix_ctl_permisos_sistemas_opc_acceso_cancelado ON ctl_permisos_sistemas(opc_acceso_cancelado);
    CREATE INDEX ix_ctl_permisos_sistemas_tipo_acceso ON ctl_permisos_sistemas(tipo_acceso);
    CREATE INDEX ix_ctl_permisos_sistemas_idu_usuario ON ctl_permisos_sistemas(idu_usuario);
    CREATE INDEX ix_ctl_permisos_sistemas_fec_registro ON ctl_permisos_sistemas(fec_registro);
    
-- Documentación
    comment on table ctl_permisos_sistemas is 'Tabla de control de acceso a los sistemas de colegiaturas'; 
    
    comment on column ctl_permisos_sistemas.idu_acceso is 'ID acceso (SERIAL)';
    comment on column ctl_permisos_sistemas.idu_sistema is 'ID sistema (cat_sistemas.id_sistema)';
    comment on column ctl_permisos_sistemas.idu_modulo is 'ID modulo (cat_modulos_sistemas.idu_modulo)';
    comment on column ctl_permisos_sistemas.idu_opcion is 'ID opcion (cat_opciones_sistemas.idu_opcion)';
    comment on column ctl_permisos_sistemas.idu_empleado is 'ID del colaborador con acceso'; 
    comment on column ctl_permisos_sistemas.idu_puesto is 'ID del puesto con acceso'; 
    comment on column ctl_permisos_sistemas.idu_centro is 'ID del centro con acceso'; 
    comment on column ctl_permisos_sistemas.idu_ciudad is 'ID de la ciudad con acceso'; 
    comment on column ctl_permisos_sistemas.idu_region is 'ID de la región con acceso'; 
    comment on column ctl_permisos_sistemas.idu_area is 'ID del área con acceso'; 
    comment on column ctl_permisos_sistemas.idu_seccion is 'ID de la sección con acceso'; 
    comment on column ctl_permisos_sistemas.opc_acceso_jefe is 'Indica si el permiso es para jefaturas'; 
    comment on column ctl_permisos_sistemas.opc_acceso_gerente is 'Indica si el permiso es para gerentes'; 
    comment on column ctl_permisos_sistemas.opc_acceso_general is 'Indica si el permiso es de acceso general'; 
    comment on column ctl_permisos_sistemas.fec_inicial is 'Fecha inicial de acceso'; 
    comment on column ctl_permisos_sistemas.fec_final is 'Fecha final de acceso'; 
    comment on column ctl_permisos_sistemas.opc_indefinido is 'Indica si el acceso será indefinido'; 
    comment on column ctl_permisos_sistemas.opc_acceso_cancelado is 'Indica si el colaborador tiene acceso al sistema aún estado cancelado en sapcatalogoempleados. Por default 0, si está cancelado no debiera entrar a ningún sistema'; 
    comment on column ctl_permisos_sistemas.tipo_acceso is 'El tipo de acceso: 1 - Activo; 0 - Inactivo'; 
    comment on column ctl_permisos_sistemas.idu_usuario is 'ID del usuario que registró'; 
    comment on column ctl_permisos_sistemas.fec_registro is 'Fecha en que se registró'; 
    
-- Nuevo Sistema
    delete from cat_sistemas where id_sistema = 13;
    insert into cat_sistemas (id_sistema, desc_sistema, num_capturo, fec_captura, desc_sesion)
        values (13, 'Sistemas Intranet / Personal', 95194185, now(), 'Personal');
    
-- Datos iniciales
    insert into ctl_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion
            , idu_empleado
            , idu_puesto
            , idu_centro
            , idu_ciudad
            , idu_region
            , idu_area
            , idu_seccion
            , opc_acceso_jefe
            , opc_acceso_gerente
            , opc_acceso_general
            , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado
            , tipo_acceso, idu_usuario)
        -- Acceso a región culiacán (inhabilitado, tipo_acceso = 0)
        select 13 as idu_sistema, 1 as idu_modulo, 1 as idu_opcion
            , 0 as idu_empleado
            , 0 as idu_puesto
            , 0 as idu_centro
            , 0 as idu_ciudad
            , 1 as idu_region
            , 0 as idu_area
            , 0 as idu_seccion
            , 0 as opc_acceso_jefe
            , 0 as opc_acceso_gerente
            , 0 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado
            , 0 as tipo_acceso, 95194185 as idu_usuario 
        union all
        -- Acceso a centro 230468 a nuevo sistema de colegiaturas
        select 13 as idu_sistema, 1 as idu_modulo, 1 as idu_opcion
            , 0 as idu_empleado
            , 0 as idu_puesto
            , 230468 as idu_centro
            , 0 as idu_ciudad
            , 0 as idu_region
            , 0 as idu_area
            , 0 as idu_seccion
            , 0 as opc_acceso_jefe
            , 0 as opc_acceso_gerente
            , 0 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado
            , 1 as tipo_acceso, 95194185 as idu_usuario 
        union all
        -- Acceso a opción Control Factura Electronica (Subir factura)
        select 13 as idu_sistema, 2 as idu_modulo, 2 as idu_opcion
            , 0 as idu_empleado
            , 0 as idu_puesto
            , 0 as idu_centro
            , 0 as idu_ciudad
            , 0 as idu_region
            , 0 as idu_area
            , 0 as idu_seccion
            , 0 as opc_acceso_jefe
            , 0 as opc_acceso_gerente
            , 1 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado
            , 1 as tipo_acceso, 95194185 as idu_usuario 
        union all
        -- Acceso a opción Control Factura Electronica (Administrador factura)
        select 13 as idu_sistema, 2 as idu_modulo, 4 as idu_opcion, 0 as idu_empleado, 0 as idu_puesto, 230508 as idu_centro, 0 as idu_ciudad, 0 as idu_region, 0 as idu_area, 0 as idu_seccion, 0 as opc_acceso_jefe, 0 as opc_acceso_gerente, 0 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado, 1 as tipo_acceso, 95194185 as idu_usuario
        UNION ALL
        -- Acceso a opción Seguimiento de Facturas Electronicas (Facturas de Empleados por Gerente)
        select 13 as idu_sistema, 3 as idu_modulo, 5 as idu_opcion, 0 as idu_empleado, 0 as idu_puesto, 0 as idu_centro, 0 as idu_ciudad, 0 as idu_region, 0 as idu_area, 0 as idu_seccion, 0 as opc_acceso_jefe, 1 as opc_acceso_gerente, 0 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado, 1 as tipo_acceso, 95194185 as idu_usuario
        UNION ALL
        -- Acceso a opción Seguimiento de Facturas Electronicas (Facturas de Empleados por ELP)
        select 13 as idu_sistema, 3 as idu_modulo, 6 as idu_opcion, 0 as idu_empleado, 103 as idu_puesto, 0 as idu_centro, 0 as idu_ciudad, 0 as idu_region, 0 as idu_area, 0 as idu_seccion, 0 as opc_acceso_jefe, 0 as opc_acceso_gerente, 0 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado, 1 as tipo_acceso, 95194185 as idu_usuario
        UNION ALL
        select 13 as idu_sistema, 3 as idu_modulo, 6 as idu_opcion, 0 as idu_empleado, 104 as idu_puesto, 0 as idu_centro, 0 as idu_ciudad, 0 as idu_region, 0 as idu_area, 0 as idu_seccion, 0 as opc_acceso_jefe, 0 as opc_acceso_gerente, 0 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado, 1 as tipo_acceso, 95194185 as idu_usuario
        UNION ALL
        -- Acceso a opción Seguimiento de Facturas Electronicas (Facturas Electr&oacute;nicas Colegiaturas por Personal)
        select 13 as idu_sistema, 3 as idu_modulo, 7 as idu_opcion, 0 as idu_empleado, 0 as idu_puesto, 230508 as idu_centro, 0 as idu_ciudad, 0 as idu_region, 0 as idu_area, 0 as idu_seccion, 0 as opc_acceso_jefe, 0 as opc_acceso_gerente, 0 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado, 1 as tipo_acceso, 95194185 as idu_usuario
        UNION ALL
        -- Acceso a opción Seguimiento de Facturas Electronicas (Facturas Electr&oacute;nicas Colegiaturas por Personal)
        select 13 as idu_sistema, 3 as idu_modulo, 9 as idu_opcion, 0 as idu_empleado, 0 as idu_puesto, 0 as idu_centro, 0 as idu_ciudad, 0 as idu_region, 0 as idu_area, 0 as idu_seccion, 0 as opc_acceso_jefe, 0 as opc_acceso_gerente, 1 as opc_acceso_general
            , '19000101'::DATE as fec_inicial, '19000101'::DATE as fec_final, 1 as opc_indefinido, 0 as opc_acceso_cancelado, 1 as tipo_acceso, 95194185 as idu_usuario;
    --cat_modulos_sistemas
    --cat_opciones_sistemas
    --cat_puestos_gerenciales
    --cat_puestos_jefaturas