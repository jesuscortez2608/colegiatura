DROP FUNCTION IF EXISTS fun_obtener_gerentes_facturas_pendientes();

CREATE OR REPLACE FUNCTION fun_obtener_gerentes_facturas_pendientes(OUT idu_gerente integer
    , OUT nom_gerente character varying
    , OUT idu_puesto_gerente INTEGER
    , OUT idu_centro_gerente INTEGER
    , OUT nom_centro_gerente VARCHAR 
    , OUT mail_gerente character varying
    , OUT idu_colaborador integer
    , OUT nom_colaborador character varying
    , OUT idu_centro integer
    , OUT nom_centro character varying
    , OUT cantidad_facturas integer)
  RETURNS SETOF record AS
$BODY$
DECLARE
    /*
        Peticion: 18292
        Autor: Paimi 95194185
        Fecha: 22/12/2018
        Descripción General: Función para obtener los correos de los gerentes que tienen facturas pendientes de autorizar
        Servidor Productivo: 10.44.2.183
        Servidor Desarrollo: 10.27.114.75
        Ejemplo: 
            SELECT idu_gerente,
                nom_gerente,
                idu_puesto_gerente,
                idu_centro_gerente,
                nom_centro_gerente,
                mail_gerente,
                idu_colaborador,
                nom_colaborador,
                idu_centro, 
                nom_centro,
                cantidad_facturas
            FROM fun_obtener_gerentes_facturas_pendientes()
    ---------------------------------------------------------------- */
    rec record;
BEGIN
    --DROP TABLE IF EXISTS tmp_colaboradores;
    --CREATE TABLE tmp_colaboradores (
    CREATE TEMPORARY TABLE tmp_colaboradores (
        idu_gerente int,
        nom_gerente varchar,
        idu_puesto_gerente INT,
        idu_centro_gerente INT,
        nom_centro_gerente VARCHAR,
        mail_gerente varchar,
        idu_colaborador INT,
        nom_colaborador VARCHAR,
        idu_centro INT,
        nom_centro varchar,
        cantidad_facturas INT
    ) ON COMMIT DROP;
    --);
    
    insert into tmp_colaboradores (idu_centro, idu_colaborador, cantidad_facturas)
        select mov.idu_centro
            , mov.idu_empleado
            , count(*)
        from mov_facturas_colegiaturas mov
        where mov.idu_estatus = 0
            and mov.idu_tipo_documento in (1, 3)
        group by mov.idu_centro, mov.idu_empleado
        ORDER BY mov.idu_centro, mov.idu_empleado;
    
    update tmp_colaboradores set idu_gerente = cen.numerogerente::int
    from sapcatalogocentros cen
    where cen.centron = tmp_colaboradores.idu_centro;
    
    -- Actualizar suplente
    update tmp_colaboradores set idu_gerente = sup.idu_suplente
    from mov_suplentes_colegiaturas as sup
    where sup.idu_empleado = tmp_colaboradores.idu_gerente
        and (sup.opc_indefinido = 1 OR now()::date between sup.fec_inicial and sup.fec_final);
    
    -- Actualizar nombres de gerentes y colaboradores
    update tmp_colaboradores set nom_gerente = trim(emp.nombre) || ' ' || trim(emp.apellidopaterno) || ' ' || trim(emp.apellidomaterno)
        , idu_centro_gerente = emp.centron
        , idu_puesto_gerente = emp.pueston
    from sapcatalogoempleados as emp
    where emp.numempn = tmp_colaboradores.idu_gerente;
    
    update tmp_colaboradores set nom_colaborador = trim(emp.nombre) || ' ' || trim(emp.apellidopaterno) || ' ' || trim(emp.apellidomaterno)
    from sapcatalogoempleados as emp
    where emp.numempn = tmp_colaboradores.idu_colaborador;
    
    -- Actualizar correos
    update tmp_colaboradores set mail_gerente = trim(mail.des_correoe)
    from ctl_correoselectronicospersonalesempleados as mail
    where mail.num_empleado = tmp_colaboradores.idu_gerente;
    
    -- Actualizar nombres de centro
    update tmp_colaboradores set nom_centro_gerente = cen.nombrecentro
    from sapcatalogocentros as cen
    where cen.centron = tmp_colaboradores.idu_centro_gerente;
    
    update tmp_colaboradores set nom_centro = cen.nombrecentro
    from sapcatalogocentros as cen
    where cen.centron = tmp_colaboradores.idu_centro;
    
    FOR rec IN (
        SELECT tmp.idu_gerente
            , tmp.nom_gerente
            , tmp.idu_puesto_gerente
            , tmp.idu_centro_gerente
            , tmp.nom_centro_gerente
            , tmp.mail_gerente
            , tmp.idu_colaborador
            , tmp.nom_colaborador
            , tmp.idu_centro
            , tmp.nom_centro
            , tmp.cantidad_facturas
        FROM tmp_colaboradores as tmp
        order by tmp.idu_gerente, tmp.idu_centro, tmp.idu_colaborador
        ) LOOP
        
        idu_gerente := rec.idu_gerente;
        nom_gerente := fun_caracteres_especiales_html(rec.nom_gerente);
        mail_gerente := rec.mail_gerente;
        idu_puesto_gerente := rec.idu_puesto_gerente;
        idu_centro_gerente := rec.idu_centro_gerente;
        nom_centro_gerente := fun_caracteres_especiales_html(rec.nom_centro_gerente);
        idu_colaborador := rec.idu_colaborador;
        nom_colaborador := fun_caracteres_especiales_html(rec.nom_colaborador);
        idu_centro := rec.idu_centro;
        nom_centro := fun_caracteres_especiales_html(rec.nom_centro);
        cantidad_facturas := rec.cantidad_facturas;
        
        RETURN NEXT;
    END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_gerentes_facturas_pendientes() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_gerentes_facturas_pendientes() TO sysinternet;
COMMENT ON FUNCTION fun_obtener_gerentes_facturas_pendientes() IS 'Función para obtener los correos de los gerentes que tienen facturas pendientes de autorizar';