drop function if exists fun_obtener_listado_pagos_por_fecha(timestamp without time zone, integer);
drop type if exists type_listado_pagos_por_fecha;

CREATE TYPE type_listado_pagos_por_fecha AS
   (idu_empleado integer,
    nom_empleado character varying(150),
    idu_centro integer,
    nom_centro character varying(50),
    idu_puesto integer,
    nom_puesto character varying(50),
    num_cuenta character varying(20),
    num_sucursal integer,
    importe_pagado numeric(14,2),
    idu_generacion integer,
    es_historico smallint,
    poliza_cancelacion character varying(20),
    poliza_clave character varying(20),
    poliza_fecha timestamp without time zone,
    fec_cancelacion timestamp without time zone,
    emp_cancelacion integer,
    nom_emp_cancelacion character varying(150),
    des_justificacion text);
    
CREATE OR REPLACE FUNCTION fun_obtener_listado_pagos_por_fecha(timestamp without time zone, integer)
  RETURNS SETOF type_listado_pagos_por_fecha AS
$BODY$
DECLARE
	/*
	No. petición APS               : 8613 - Colegiaturas
	Fecha                          : 12/01/2017
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Usuario de BD                  : syspersonal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 
	Descripción del funcionamiento : Obtiene un listado de los pagos
	Descripción del cambio         : 
	Sistema                        : Colegiaturas
	Módulo                         : Generación de archivos para bancos
	Repositorio del proyecto       : svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas
	Ejemplo                        : 
		select * from fun_obtener_listado_pagos_por_fecha('20170124', 6)
		select * from fun_obtener_listado_pagos_por_fecha('20161222', 2)
	------------------------------------------------------------------------------------------------------ */
	iRutaPago alias for $2;
	returnrec type_listado_pagos_por_fecha;
	dFechaGeneracion DATE;
BEGIN
    dFechaGeneracion := $1::DATE;
    --his_generacion_pagos_colegiaturas
    --mov_generacion_pagos_colegiaturas
    
    create local temp table tmp_listado_pagos (idu_empleado integer
        , nom_empleado varchar(150) NOT NULL DEFAULT('')
        , idu_centro integer NOT NULL DEFAULT(0)
        , nom_centro varchar(50) NOT NULL DEFAULT('')
        , idu_puesto integer NOT NULL DEFAULT(0)
        , nom_puesto varchar(50) NOT NULL DEFAULT('')
        , num_cuenta varchar(20) NOT NULL DEFAULT('')
        , num_sucursal integer NOT NULL DEFAULT(0)
        , importe_pagado numeric(14,2) NOT NULL DEFAULT(0)
        , idu_generacion integer NOT NULL DEFAULT(0)
        , es_historico smallint NOT NULL DEFAULT(0)
        , poliza_cancelacion VARCHAR(20) NOT NULL DEFAULT('')
        , poliza_clave VARCHAR(20) NOT NULL DEFAULT('')
        , poliza_fecha timestamp without time zone NOT NULL DEFAULT '1900-01-01'
        , fec_cancelacion timestamp without time zone NOT NULL DEFAULT '1900-01-01'
        , emp_cancelacion integer NOT NULL DEFAULT (0)
        , des_justificacion text NOT NULL DEFAULT('')
        , nom_emp_cancelacion varchar(150) NOT NULL DEFAULT('')
	)on commit drop;
    
    if exists(select * from his_generacion_pagos_colegiaturas where fec_generacion::DATE = dFechaGeneracion::DATE and clv_rutapago = iRutaPago and opc_cheque = 0 limit 1) then
        insert into tmp_listado_pagos (idu_empleado, nom_empleado
                , idu_centro, idu_puesto
                , num_cuenta, num_sucursal, importe_pagado, idu_generacion, es_historico
                , poliza_cancelacion, poliza_clave, poliza_fecha, fec_cancelacion, emp_cancelacion, des_justificacion)
            SELECT idu_empleado, trim(ape_paterno) || ' ' || trim(ape_materno) || ' ' || trim(nom_empleado) as  nom_empleado
                , idu_centro, idu_puesto
                , num_cuenta, num_sucursal, importe_pagado, idu_generacion, 1::smallint as es_historico
                , poliza_cancelacion, poliza_clave, poliza_fecha, fec_cancelacion, emp_cancelacion, des_justificacion_poliza
            from his_generacion_pagos_colegiaturas
            where fec_generacion::DATE = dFechaGeneracion::DATE 
                and clv_rutapago = iRutaPago
                and opc_cheque = 0;
    ELSE
        insert into tmp_listado_pagos (idu_empleado,nom_empleado
                ,idu_centro,idu_puesto
                ,num_cuenta, num_sucursal,importe_pagado,idu_generacion,es_historico
                , poliza_cancelacion, poliza_clave, poliza_fecha, fec_cancelacion, emp_cancelacion, des_justificacion)
            SELECT idu_empleado, trim(ape_paterno) || ' ' || trim(ape_materno) || ' ' || trim(nom_empleado) as  nom_empleado
                , idu_centro, idu_puesto
                , num_cuenta, num_sucursal, importe_pagado, idu_generacion, 0::smallint as es_historico
                , poliza_cancelacion, poliza_clave, poliza_fecha, fec_cancelacion, emp_cancelacion, des_justificacion_poliza
            from mov_generacion_pagos_colegiaturas
            where fec_generacion::DATE = dFechaGeneracion::DATE
                and clv_rutapago = iRutaPago
                and opc_cheque = 0;
    END IF;
    
    update tmp_listado_pagos set nom_centro = trim(sapcatalogocentros.nombrecentro)
    from sapcatalogocentros
    where sapcatalogocentros.centron = tmp_listado_pagos.idu_centro;
    
    update tmp_listado_pagos set nom_puesto = trim(sapcatalogopuestos.nombre)
    from sapcatalogopuestos
    where sapcatalogopuestos.numero = lpad(tmp_listado_pagos.idu_puesto::varchar, 3, '0');
    
    update tmp_listado_pagos set nom_emp_cancelacion = trim(sapcatalogoempleados.nombre) || ' ' || trim(sapcatalogoempleados.apellidopaterno) || ' ' || trim(sapcatalogoempleados.apellidomaterno)
    from sapcatalogoempleados
    where sapcatalogoempleados.numempn = tmp_listado_pagos.idu_empleado;
    
	FOR returnrec IN (
        select idu_empleado
            , nom_empleado
            , idu_centro
            , nom_centro
            , idu_puesto
            , nom_puesto
            , num_cuenta
            , num_sucursal
            , importe_pagado
            , idu_generacion
            , es_historico
            , poliza_cancelacion
            , poliza_clave
            , poliza_fecha
            , fec_cancelacion
            , emp_cancelacion
            , nom_emp_cancelacion
            , des_justificacion
        from tmp_listado_pagos) LOOP
		RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_listado_pagos_por_fecha(timestamp without time zone, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_pagos_por_fecha(timestamp without time zone, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_pagos_por_fecha(timestamp without time zone, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_pagos_por_fecha(timestamp without time zone, integer) TO postgres;
