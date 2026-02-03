drop function if exists fun_obtener_permisos_sistema(IN iUsuario integer, IN iSistema INTEGER);
drop function if exists fun_obtener_permisos_sistema(IN iUsuario integer, IN iSistema INTEGER, IN iSuplente INTEGER);

CREATE OR REPLACE FUNCTION fun_obtener_permisos_sistema(IN iUsuario integer
    , IN iSistema INTEGER
    , IN iSuplente INTEGER
    , OUT iEstatus integer
    , OUT sMensaje character varying(150)
    , OUT sSistema character varying(150)
    , OUT iModulo integer
    , OUT sModulo character varying(150)
    , OUT iOpcion integer
    , OUT sNomOpcion varchar(150)
    , OUT sOnSelect TEXT
    , OUT iUsuarioRegistro INTEGER
    , OUT dFecRegistro DATE) RETURNS SETOF record AS
$BODY$
DECLARE 
    /*
        No. peticion APS               : 16995 - Colegiaturas
        Fecha                          : 08/10/2014
        Numero empleado                : 95194185
        Nombre del empleado            : Paimi Arizmendi Lopez
        Base de datos                  : personal
        Usuario de BD                  : syspersonal
        Servidor de pruebas            : 10.28.114.75
        Servidor de produccion         : 10.44.2.183
        Descripcion del funcionamiento : La funcion obtiene los datos del usuario y valida el acceso al sistema solicitado
        Descripcion del cambio         : NA
        Sistema                        : Colegiaturas
        Modulo                         : Intranet, Sistemas Coppel
        Repositorio del proyecto       : svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts/fun_obtener_permisos_sistema.sql
        Ejemplos                       : 
            select * from fun_obtener_permisos_sistema(90025628, 13, 0)
            select * from fun_obtener_permisos_sistema(95194185, 13, 0)
            select * from fun_obtener_permisos_sistema(94827443, 13, 0)
            select * from fun_obtener_permisos_sistema(90062132, 13, 0)
            select * from fun_obtener_permisos_sistema(92710671, 13, 0)
            select * from fun_obtener_permisos_sistema(96799251, 13, 1)
            select * from fun_obtener_permisos_sistema(97643319, 13, 1)
            select * from fun_obtener_permisos_sistema(95141502, 13, 1)
            cat_opciones_sistemas
            select * from ctl_permisos_sistemas where idu_sistema = 13 and idu_empleado = 95194185
    ------------------------------------------------------------------------------------------------------ */
    sNomSistema varchar(150);
	rec record;
BEGIN
    iEstatus := 0;
    sMensaje := '';
    
    sNomSistema := (select desc_sistema from cat_sistemas where id_sistema = iSistema limit 1);
    sNomSistema := COALESCE(sNomSistema, '(No existe el sistema ' || iSistema::VARCHAR || ')');
    
	--drop table if exists tmp_usuario;
	--CREATE TABLE tmp_usuario (idu_usuario integer not null default 0
	CREATE TEMP TABLE tmp_usuario (idu_usuario integer not null default 0
        , idu_sistema integer not null default(0)
		, idu_puesto integer not null default(0)
		, idu_centro integer not null default(0)
		, idu_ciudad integer not null default(0)
		, idu_region integer not null default(0)
		, idu_area integer not null default(0)
		, idu_seccion integer not null default(0)
		, cancelado INTEGER not null default(0)
	) ON COMMIT DROP;
	--);
	
	--drop table if exists tmp_permisos_sistemas;
	--CREATE TABLE tmp_permisos_sistemas (idu_sistema INTEGER NOT NULL DEFAULT(0)
	CREATE TEMP TABLE tmp_permisos_sistemas (idu_sistema INTEGER NOT NULL DEFAULT(0)
        , idu_modulo INTEGER NOT NULL DEFAULT(0)
        , idu_opcion INTEGER NOT NULL DEFAULT(0)
        , idu_empleado integer not null default(0)
        , idu_puesto integer not null default(0)
        , idu_centro integer not null default(0)
        , idu_ciudad integer not null default(0)
        , idu_region integer not null default(0)
        , idu_area integer not null default(0)
        , idu_seccion integer not null default(0)
        , opc_acceso_jefatura smallint not null default(0)
        , opc_acceso_gerencial smallint not null default(0)
        , opc_acceso_general smallint not null default(0)
        , fec_inicial date not null default('19000101')
        , fec_final date not null default('19000101')
        , opc_indefinido smallint not null default(0)
        , opc_acceso_cancelado smallint not null default(0)
        , tipo_acceso smallint not null default(0)
        , idu_usuario integer not null default(0)
        , fec_registro timestamp without time zone not null default(now())
	) ON COMMIT DROP;
	--);
    
    --drop table if exists tmp_permisos_negados;
	--CREATE TABLE tmp_permisos_negados (idu_sistema INTEGER NOT NULL DEFAULT(0)
	CREATE TEMP TABLE tmp_permisos_negados (idu_sistema INTEGER NOT NULL DEFAULT(0)
        , idu_modulo INTEGER NOT NULL DEFAULT(0)
        , idu_opcion INTEGER NOT NULL DEFAULT(0)
        , idu_empleado integer not null default(0)
        , idu_puesto integer not null default(0)
        , idu_centro integer not null default(0)
        , idu_ciudad integer not null default(0)
        , idu_region integer not null default(0)
        , idu_area integer not null default(0)
        , idu_seccion integer not null default(0)
        , opc_acceso_jefatura smallint not null default(0)
        , opc_acceso_gerencial smallint not null default(0)
        , opc_acceso_general smallint not null default(0)
        , fec_inicial date not null default('19000101')
        , fec_final date not null default('19000101')
        , opc_indefinido smallint not null default(0)
        , opc_acceso_cancelado smallint not null default(0)
        , tipo_acceso smallint not null default(0)
        , idu_usuario integer not null default(0)
        , fec_registro timestamp without time zone not null default(now())
	) ON COMMIT DROP;
	--);
	
	-- Recopilar datos del usuario
	insert into tmp_usuario (idu_usuario, idu_sistema, idu_puesto, idu_centro, cancelado)
        select iUsuario
            , iSistema
            , (case when trim(emp.numeropuesto) != '' then emp.numeropuesto else '0' end)::integer
            , (case when trim(emp.centro) != '' then emp.centro else '0' end)::integer
            , (case when trim(emp.cancelado) = '1' then 1 else 0 end)::integer
        from sapcatalogoempleados emp
        where emp.numempn = iUsuario;
	
	update tmp_usuario set idu_ciudad = cen.ciudadadjunta
        , idu_seccion = (case when trim(cen.seccion) != '' then cen.seccion else '0' end)::integer
	from sapcatalogocentros as cen
	where cen.centron = idu_centro;
	
	update tmp_usuario set idu_region = (case when trim(ciu.regionzona) != '' then ciu.regionzona else '0' end)::integer
	from sapcatalogociudades ciu
	where ciu.ciudadn = idu_ciudad;
	
	update tmp_usuario set idu_area = coalesce(sec.idu_area, 0)
	from cat_area_seccion sec
	where sec.idu_seccion = tmp_usuario.idu_seccion;
	
	-- Recopilar accesos
	-- Por acceso general
	insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion, opc_acceso_general
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.opc_acceso_general
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_sistema = usr.idu_sistema)
        where acl.opc_acceso_general = 1
            and (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
    
    -- Por acceso jefatura
	insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion, opc_acceso_jefatura
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.opc_acceso_jefe
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_sistema = usr.idu_sistema)
            inner join cat_puestos_jefaturas as pst on (pst.idu_puesto = usr.idu_puesto)
        where acl.opc_acceso_jefe = 1
            and (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
    
    -- Por acceso gerencial
	insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion, opc_acceso_gerencial
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.opc_acceso_gerente
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_sistema = usr.idu_sistema)
            inner join cat_puestos_gerenciales as pst on (pst.idu_puesto = usr.idu_puesto OR iSuplente = 1)
        where acl.opc_acceso_gerente = 1
            and (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
    
	-- Por area-seccion
	insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion
                , idu_area, idu_seccion
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion
                , acl.idu_area, acl.idu_seccion
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_area = usr.idu_area and acl.idu_seccion = usr.idu_seccion and acl.idu_sistema = usr.idu_sistema)
        where (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
    
    -- Por region
    insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion, idu_region
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_region
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_region = usr.idu_region and acl.idu_sistema = usr.idu_sistema)
        where (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
        
    -- Por ciudad
    insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion, idu_ciudad
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_ciudad
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_ciudad = usr.idu_ciudad and acl.idu_sistema = usr.idu_sistema)
        where (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
        
    -- Por centro
    insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion, idu_centro
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_centro
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_centro = usr.idu_centro and acl.idu_sistema = usr.idu_sistema)
        where (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
        
    -- Por puesto
    insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion, idu_puesto
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_puesto
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_puesto = usr.idu_puesto and acl.idu_sistema = usr.idu_sistema)
        where (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
    
    -- Por numero de empleado
    insert into tmp_permisos_sistemas (idu_sistema, idu_modulo, idu_opcion, idu_empleado
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_empleado
                , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr on (acl.idu_empleado = usr.idu_usuario and acl.idu_sistema = usr.idu_sistema)
        where (now()::DATE between acl.fec_inicial and acl.fec_final or acl.opc_indefinido = 1)
            and (usr.cancelado = 0 or acl.opc_acceso_cancelado = 1);
    
    -- Denegar accesos
    -- Los permisos negados tienen prioridad sobre los permisos asignados
    insert into tmp_permisos_negados (idu_sistema, idu_modulo, idu_opcion
                , idu_empleado, idu_puesto, idu_centro
                , idu_ciudad, idu_region, idu_area, idu_seccion
                , opc_acceso_jefatura, opc_acceso_gerencial, opc_acceso_general
                , fec_inicial, fec_final, opc_indefinido, opc_acceso_cancelado, tipo_acceso, idu_usuario, fec_registro)
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_empleado, acl.idu_puesto, acl.idu_centro
            , acl.idu_ciudad, acl.idu_region, acl.idu_area, acl.idu_seccion, acl.opc_acceso_jefe, acl.opc_acceso_gerente, acl.opc_acceso_general
            , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr1 on (acl.idu_sistema = usr1.idu_sistema and usr1.idu_usuario = acl.idu_empleado)
        where acl.tipo_acceso = 0
        union all
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_empleado, acl.idu_puesto, acl.idu_centro
            , acl.idu_ciudad, acl.idu_region, acl.idu_area, acl.idu_seccion, acl.opc_acceso_jefe, acl.opc_acceso_gerente, acl.opc_acceso_general
            , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr2 on (acl.idu_sistema = usr2.idu_sistema and usr2.idu_puesto = acl.idu_puesto)
        where acl.tipo_acceso = 0
        union all
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_empleado, acl.idu_puesto, acl.idu_centro
            , acl.idu_ciudad, acl.idu_region, acl.idu_area, acl.idu_seccion, acl.opc_acceso_jefe, acl.opc_acceso_gerente, acl.opc_acceso_general
            , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr3 on (acl.idu_sistema = usr3.idu_sistema and usr3.idu_centro = acl.idu_centro)
        where acl.tipo_acceso = 0
        union all
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_empleado, acl.idu_puesto, acl.idu_centro
            , acl.idu_ciudad, acl.idu_region, acl.idu_area, acl.idu_seccion, acl.opc_acceso_jefe, acl.opc_acceso_gerente, acl.opc_acceso_general
            , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr4 on (acl.idu_sistema = usr4.idu_sistema and usr4.idu_ciudad = acl.idu_ciudad)
        where acl.tipo_acceso = 0
        union all
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_empleado, acl.idu_puesto, acl.idu_centro
            , acl.idu_ciudad, acl.idu_region, acl.idu_area, acl.idu_seccion, acl.opc_acceso_jefe, acl.opc_acceso_gerente, acl.opc_acceso_general
            , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr5 on (acl.idu_sistema = usr5.idu_sistema and usr5.idu_region = acl.idu_region)
        where acl.tipo_acceso = 0
        union all
        select acl.idu_sistema, acl.idu_modulo, acl.idu_opcion, acl.idu_empleado, acl.idu_puesto, acl.idu_centro
            , acl.idu_ciudad, acl.idu_region, acl.idu_area, acl.idu_seccion, acl.opc_acceso_jefe, acl.opc_acceso_gerente, acl.opc_acceso_general
            , acl.fec_inicial, acl.fec_final, acl.opc_indefinido, acl.opc_acceso_cancelado, acl.tipo_acceso, acl.idu_usuario, acl.fec_registro
        from ctl_permisos_sistemas as acl
            inner join tmp_usuario as usr6 on (acl.idu_sistema = usr6.idu_sistema and usr6.idu_area = acl.idu_area and usr6.idu_seccion = acl.idu_seccion)
        where acl.tipo_acceso = 0;
    
    update tmp_permisos_sistemas set tipo_acceso = 0
    from tmp_permisos_negados as neg
    where tmp_permisos_sistemas.idu_sistema = neg.idu_sistema
        and tmp_permisos_sistemas.idu_modulo = neg.idu_modulo
        and tmp_permisos_sistemas.idu_opcion = neg.idu_opcion
        and neg.fec_registro > tmp_permisos_sistemas.fec_registro;
    
    if not exists (select * from tmp_permisos_sistemas) then
        iEstatus := -1;
        sMensaje := 'Sin acceso a sistema, ' || iSistema::varchar || ', ' || sNomSistema;
        iModulo := 0;
        iOpcion := 0;
        sNomOpcion := '';
        sOnSelect := '';
        iUsuarioRegistro := 0;
        dFecRegistro := '1900-01-01'::DATE;
        return NEXT;
    end if;
    
    iEstatus := 0;
	FOR rec IN(
        select distinct tmp.idu_sistema
            , sNomSistema as nom_sistema
            , tmp.idu_modulo
            , mod.nom_modulo
            , tmp.idu_opcion
            , opc.nom_opcion
            , opc.on_select
            , tmp.idu_empleado
            , tmp.idu_puesto
            , tmp.idu_centro
            , tmp.idu_ciudad
            , tmp.idu_region
            , tmp.idu_area
            , tmp.idu_seccion
            , tmp.opc_acceso_jefatura
            , tmp.opc_acceso_gerencial
            , tmp.opc_acceso_general
            , tmp.idu_usuario
            , tmp.fec_registro
        from tmp_permisos_sistemas as tmp
            inner join cat_modulos_sistemas as mod on (tmp.idu_sistema = mod.idu_sistema and tmp.idu_modulo = mod.idu_modulo)
            inner join cat_opciones_sistemas as opc on (tmp.idu_sistema = opc.idu_sistema and tmp.idu_modulo = opc.idu_modulo and tmp.idu_opcion = opc.idu_opcion)
        where tmp.tipo_acceso = 1 -- solo los tipo acceso activos
        order by tmp.idu_sistema, tmp.idu_modulo, opc.nom_opcion
        )
	LOOP
        sSistema := rec.nom_sistema;
        iModulo := rec.idu_modulo;
        sModulo := rec.nom_modulo;
        iOpcion := rec.idu_opcion;
        sNomOpcion := rec.nom_opcion;
        sOnSelect := rec.on_select;
        iUsuarioRegistro := rec.idu_usuario;
        dFecRegistro := rec.fec_registro::DATE;
        
        -- Validar accesos
        if (rec.opc_acceso_general > 0) then
            iEstatus := 1;
            sMensaje := 'Acceso general';
        elsif (rec.opc_acceso_jefatura > 0) then
            iEstatus := 1;
            sMensaje := 'Acceso por jefatura';
        elsif (rec.opc_acceso_gerencial > 0) then
            iEstatus := 1;
            sMensaje := 'Acceso gerencial';
        elsif (rec.idu_area > 0 or rec.idu_seccion > 0) then
            iEstatus := 1;
            sMensaje := 'Acceso por Area-Seccion, ' || rec.idu_area::varchar || '-' || rec.idu_seccion::varchar;
        elsif rec.idu_region > 0 then
            iEstatus := 1;
            sMensaje := 'Acceso por region, ' || rec.idu_region::varchar;
        elsif rec.idu_ciudad > 0 then
            iEstatus := 1;
            sMensaje := 'Acceso por ciudad, ' || rec.idu_ciudad::varchar;
        elsif rec.idu_centro > 0 then
            iEstatus := 1;
            sMensaje := 'Acceso por centro, ' || rec.idu_centro::varchar;
        elsif rec.idu_puesto > 0 then
            iEstatus := 1;
            sMensaje := 'Acceso por puesto, ' || rec.idu_puesto::varchar;
        elsif rec.idu_empleado > 0 then
            iEstatus := 1;
            sMensaje := 'Acceso por colaborador, ' || rec.idu_empleado::varchar;
        else
            iEstatus := 1;
            sMensaje := 'Otro medio';
        end if;
        
		RETURN NEXT;
	END LOOP;
	
END; 
$BODY$
LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_permisos_sistema(IN iUsuario integer, IN iSistema INTEGER, IN iSuplente INTEGER) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_permisos_sistema(IN iUsuario integer, IN iSistema INTEGER, IN iSuplente INTEGER) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_permisos_sistema(IN iUsuario integer, IN iSistema INTEGER, IN iSuplente INTEGER) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_permisos_sistema(IN iUsuario integer, IN iSistema INTEGER, IN iSuplente INTEGER) TO postgres;
COMMENT ON FUNCTION fun_obtener_permisos_sistema(IN iUsuario integer, IN iSistema INTEGER, IN iSuplente INTEGER) IS 'La funcion verifica si el usuario tiene acceso al sistema por algun medio (Area-Seccion, Region, Ciudad, Centro, Puesto, No. empleado)';