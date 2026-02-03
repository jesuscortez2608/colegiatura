drop function if exists fun_actualizar_empleados_colegiaturas();
drop type if exists type_actualizar_empleados_colegiaturas;
CREATE TYPE type_actualizar_empleados_colegiaturas AS (empleados_agregados integer);

CREATE OR REPLACE FUNCTION fun_actualizar_empleados_colegiaturas()
  RETURNS SETOF type_actualizar_empleados_colegiaturas AS
$BODY$
DECLARE
    /*
    No. petición APS               : 
    Fecha                          : 01/01/1900
    Número empleado                : 95194185
    Nombre del empleado            : Paimi Arizmendi Lopez
    Base de datos                  : 
    Usuario de BD                  : 
    Servidor de pruebas            : 10.44.15.182
    Servidor de produccion         : 10.44.
    Descripción del funcionamiento : 
    Descripción del cambio         : 
    Sistema                        : 
    Módulo                         : 
    Repositorio del proyecto       : svn://10.44.
    Ejemplo                        : 
        select * from fun_actualizar_empleados_colegiaturas()
        update sapcatalogoempleados set cancelado = '' where numemp = '95194185'
        delete from cat_empleados_colegiaturas where idu_empleado_registro = 95194185;
        delete from cat_beneficiarios_colegiaturas where idu_empleado_registro = 95194185;
        select * from cat_beneficiarios_colegiaturas where idu_empleado = 92271308
    ------------------------------------------------------------------------------------------------------ */
    returnrec type_actualizar_empleados_colegiaturas;
    iEmpleadosAgregados integer;
    tIntervalo TIMESTAMP;
BEGIN
    iEmpleadosAgregados := 0;
    
    create local temp table tmp_empleados_colegiaturas (idu_empleado integer
    --create table tmp_empleados_colegiaturas (idu_empleado integer
        , nom_empleado varchar(50)
        , ape_paterno varchar(50)
        , ape_materno varchar(50)
        , fec_ingreso timestamp without time zone
        , ruta_pago integer
    ) on commit drop;
    --);
    
    -- Seleccionar los colaboradores que tienen más de un año de antigüedad, 
    -- y que no existan en la tabla cat_empleados_colegiaturas
    insert into tmp_empleados_colegiaturas (idu_empleado, nom_empleado, ape_paterno, ape_materno, fec_ingreso, ruta_pago)
    select emp.numemp::integer as idu_empleado
        , emp.nombre
        , emp.apellidopaterno
        , emp.apellidomaterno
        , emp.fechaalta
        , (case when trim(emp.controlpago) = '' then '0' else trim(emp.controlpago) end)::integer
    from sapcatalogoempleados as emp
        left join cat_empleados_colegiaturas as ec on (ec.idu_empleado = emp.numempn)
    where ec.idu_empleado is null
        and emp.cancelado != '1'
        and emp.numempn between 90000000 and 98999999
        and date_part('day',now() - emp.fechaalta) >= 365;
    
    iEmpleadosAgregados := (select count(*) from tmp_empleados_colegiaturas);
    
    insert into cat_empleados_colegiaturas(idu_empleado, opc_limitado, idu_rutapago, opc_empleado_bloqueado, fec_registro, idu_empleado_registro)
    select tmp.idu_empleado
        , 1 as opc_limitado
        , tmp.ruta_pago
        , 0 as opc_empleado_bloqueado
        , now() as fec_registro
        , 95194185 as idu_empleado_registro
    from tmp_empleados_colegiaturas    as tmp;
    
    update cat_empleados_colegiaturas set idu_rutapago = (case when trim(emp.controlpago) = '' then '0' else trim(emp.controlpago) end)::integer
    from sapcatalogoempleados emp
    where cat_empleados_colegiaturas.idu_empleado = emp.numempn;
    --PUESTOS QUE NO SE VALIDA COSTOS		
    update cat_empleados_colegiaturas set opc_validar_costos = case when sapcatalogoempleados.pueston in (SELECT idu_puesto FROM cat_puestosconautorizacion) then 0 else 1 end
    from sapcatalogoempleados
    where sapcatalogoempleados.numempn = cat_empleados_colegiaturas.idu_empleado;
    
    -- Tabla de beneficiarios (cat_beneficiarios_colegiaturas)
    -- Agregar a estos colaboradores con parentesco 11 (cat_parentescos.idu_parentesco = 11 - El mismo empleado)
    insert into cat_beneficiarios_colegiaturas (idu_empleado, idu_beneficiario, nom_beneficiario, ape_paterno, ape_materno
        , idu_parentesco
        , opc_becado_especial
        , des_observaciones
        , fec_registro
        , idu_empleado_registro)
    select tmp.idu_empleado, 1 as idu_beneficiario, tmp.nom_empleado, tmp.ape_paterno, tmp.ape_materno
        , 11 as idu_parentesco
        , 0 as opc_becado_especial
        , '' as des_observaciones
        , now() as fec_registro
        , 95194185 as idu_empleado_registro
    from tmp_empleados_colegiaturas as tmp;
    
    -- Corregir los beneficiarios de los empleados que no se tienen registrados a sí mismos con parentesco 11
    --create table tmp_beneficiarios_colegiaturas (idu_empleado integer
    create local temp table tmp_beneficiarios_colegiaturas (idu_empleado integer
        , nom_empleado varchar(50)
        , ape_paterno varchar(50)
        , ape_materno varchar(50)
        , idu_beneficiario integer
        , el_mismo integer
    ) on commit drop;
    --);
    
    insert into tmp_beneficiarios_colegiaturas (idu_empleado, el_mismo)
    SELECT ben.idu_empleado
        , sum(case when ben.idu_parentesco = 11 then 1 else 0 end)
    FROM cat_beneficiarios_colegiaturas ben
    group by ben.idu_empleado;
    
    delete from tmp_beneficiarios_colegiaturas where el_mismo > 0; -- excluye los que tienen beneficiario 11 (él mismo)
    
    update tmp_beneficiarios_colegiaturas set nom_empleado = COALESCE(sapcatalogoempleados.nombre, '')
        , ape_paterno = COALESCE(sapcatalogoempleados.apellidopaterno, '')
        , ape_materno = COALESCE(sapcatalogoempleados.apellidomaterno, '')
    from sapcatalogoempleados
    where sapcatalogoempleados.numempn = tmp_beneficiarios_colegiaturas.idu_empleado;
    
    create local temp table tmp_beneficiarios_claves (idu_empleado integer
        , idu_beneficiario integer
    ) on commit drop;
    
    update tmp_beneficiarios_colegiaturas set idu_beneficiario = beneficiarios.nextval
    from (
        select idu_empleado, ( coalesce(max(cat_beneficiarios_colegiaturas.idu_beneficiario),0) + 1) nextval
        from cat_beneficiarios_colegiaturas
        group by idu_empleado
        ) as beneficiarios
    where beneficiarios.idu_empleado = tmp_beneficiarios_colegiaturas.idu_empleado;
    
    insert into cat_beneficiarios_colegiaturas (idu_empleado, idu_beneficiario, nom_beneficiario, ape_paterno, ape_materno
        , idu_parentesco
        , opc_becado_especial
        , des_observaciones
        , fec_registro
        , idu_empleado_registro)
    select tmp.idu_empleado, tmp.idu_beneficiario
        , COALESCE(tmp.nom_empleado, ''), COALESCE(tmp.ape_paterno, ''), COALESCE(tmp.ape_materno, '')
        , 11 as idu_parentesco
        , 0 as opc_becado_especial
        , '' as des_observaciones
        , now() as fec_registro
        , 95194185 as idu_empleado_registro
    from tmp_beneficiarios_colegiaturas    as tmp;
    
    -- Mandar al histórico los movimientos rechazados con un intervalo de más de tres meses
    tIntervalo := (SELECT CURRENT_DATE - INTERVAL '2 MONTH');
    create local temp table tmp_facturas_rechazadas (idfactura integer) on commit drop;
    insert into tmp_facturas_rechazadas (idfactura)
        select idfactura
        from mov_facturas_colegiaturas
        where idu_estatus = 3
            and fec_registro < tIntervalo;
    
    insert into his_facturas_colegiaturas(fol_fiscal
			, fol_factura
			, serie
			, fec_factura
			, idu_empleado
			, idu_centro
			, opc_pdf
			, idu_escuela
			, rfc_clave
			, importe_factura
			, importe_calculado
			, importe_pagado
			, tope_mensual
			, idu_tipo_documento
			, idu_tipo_deduccion
			, idu_estatus
			, opc_modifico_pago
			, idu_motivo_rechazo
			, emp_marco_estatus
		        , fec_marco_estatus
		        , fec_cierre
		        , des_comentario_especial
		        , des_aclaracion_costos
		        , des_observaciones
		        , fec_registro
		        , idu_empleado_registro
		        , opc_movimiento_traspaso
		        , idu_empleado_traspaso
		        , fec_movimiento_traspaso
		        , xml_factura
		        , nom_xml_recibo
		        , nom_pdf_carta
		        , idfactura)
			select COALESCE(mov.fol_fiscal, '')
				, COALESCE(mov.fol_factura, '')
				, COALESCE(mov.serie, '')
				, mov.fec_factura
				, COALESCE(mov.idu_empleado, 0)
				, mov.idu_centro
				, COALESCE(mov.opc_pdf, 0)
				, COALESCE(mov.idu_escuela, 0)
				, COALESCE(mov.rfc_clave, '')
				, mov.importe_factura
				, mov.importe_calculado
				, mov.importe_pagado
				, 0 as tope_mensual
				, COALESCE(mov.idu_tipo_documento, 0)
				, mov.idu_tipo_deduccion
				, COALESCE(mov.idu_estatus, 0)
				, mov.opc_modifico_pago
				, mov.idu_motivo_rechazo
				, COALESCE(mov.emp_marco_estatus, 0)
				, now() as fec_marco_estatus
				, now() as fec_cierre
				, mov.des_comentario_especial
				, mov.des_aclaracion_costos
				, mov.des_observaciones
				, mov.fec_registro
				, COALESCE(mov.idu_empleado_registro, 0)
				, mov.opc_movimiento_traspaso
				, mov.idu_empleado_traspaso
				, mov.fec_movimiento_traspaso
				, COALESCE(mov.xml_factura, '')
				, mov.nom_xml_recibo
				, mov.nom_pdf_carta
				, mov.idfactura
			from mov_facturas_colegiaturas mov
                inner join tmp_facturas_rechazadas on (tmp_facturas_rechazadas.idfactura = mov.idfactura);
    
    insert into his_detalle_facturas_colegiaturas(idu_empleado
			, fol_fiscal
			, idu_beneficiario
			, beneficiario_hoja_azul
			, idu_parentesco
			, idu_tipopago
			, prc_descuento
			, periodo
			, idu_escuela
			, idu_escolaridad
			, idu_grado_escolar
			, idu_ciclo_escolar
			, importe_concepto
			, importe_pagado
			, fec_registro
			, idu_empleado_registro
			, idfactura
			, keyx
			, idu_carrera)
		select det.idu_empleado
			, det.fol_fiscal
			, det.idu_beneficiario
			, det.beneficiario_hoja_azul
			, det.idu_parentesco
			, det.idu_tipopago
			, det.prc_descuento
			, det.periodo
			, det.idu_escuela
			, det.idu_escolaridad
			, det.idu_grado_escolar
			, det.idu_ciclo_escolar
			, det.importe_concepto
			, det.importe_pagado
			, det.fec_registro
			, det.idu_empleado_registro
			, det.idfactura
			, det.keyx
			, det.idu_carrera
		from mov_detalle_facturas_colegiaturas det
			inner join tmp_facturas_rechazadas on (tmp_facturas_rechazadas.idfactura = det.idfactura);
    
	delete from mov_facturas_colegiaturas where idfactura in (select idfactura from tmp_facturas_rechazadas);
    
	delete from mov_detalle_facturas_colegiaturas where idfactura in (select idfactura from tmp_facturas_rechazadas);
    
    FOR returnrec IN (select iEmpleadosAgregados) LOOP
        RETURN NEXT returnrec;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_actualizar_empleados_colegiaturas() TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_actualizar_empleados_colegiaturas() TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_actualizar_empleados_colegiaturas() TO sysetl;
GRANT EXECUTE ON FUNCTION fun_actualizar_empleados_colegiaturas() TO postgres;
COMMENT ON FUNCTION fun_actualizar_empleados_colegiaturas() IS 'ESTA FUNCION DEBE TRABAJAR COMO UNA TAREA PROGRAMADA PARA ACTUALIZAR LOS EMPLEADOS DE COLEGIATURAS.';