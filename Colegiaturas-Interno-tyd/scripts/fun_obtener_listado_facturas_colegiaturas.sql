DROP FUNCTION if exists fun_obtener_listado_facturas_colegiaturas(integer, timestamp without time zone, timestamp without time zone, integer, character varying, integer, integer, character varying, character varying, character varying);
drop type if exists type_fun_obtener_listado_facturas_colegiaturas;


CREATE TYPE type_fun_obtener_listado_facturas_colegiaturas AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    idfactura integer,
    fec_factura timestamp without time zone,
    fol_factura character varying(100),
    serie character varying(20),
    id_empleado integer,
    nom_empleado character varying(150),
    id_centro character(6),
    nom_centro character varying(100),
    ottp integer,
    fec_captura timestamp without time zone,
    id_escuela integer,
    nom_escuela character varying(100),
    imp_factura numeric(12,2),
    fec_pago timestamp without time zone,
    id_rutapago character(2),
    nom_rutapago character varying(20),
    imp_a_pagar numeric(12,2),
    id_ciclo_escolar integer,
    ciclo_escolar character varying(30),
    id_estatus integer,
    nom_estatus character varying(50),
    fec_estatus timestamp without time zone,
    num_modifico_estatus integer,
    nom_modifico_estatus character varying(150),
    num_tarjeta character(16),
    fec_baja timestamp without time zone,
    des_observaciones text,
    id_tipodocumento integer,
    nom_tipodocumento character varying(50));


CREATE OR REPLACE FUNCTION fun_obtener_listado_facturas_colegiaturas(integer, timestamp without time zone, timestamp without time zone, integer, character varying, integer, integer, character varying, character varying, character varying)
  RETURNS SETOF type_fun_obtener_listado_facturas_colegiaturas AS
$BODY$
DECLARE

     /*
     No. petición APS               : 8613.1
     Fecha                          : 19/09/2016
     Número empleado                : 97060151
     Nombre del empleado            : Eva Margarita Moreno Chávez
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento :
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de Colegiaturas
     Ejemplo                        : 
	
SELECT records
	, page
	, pages
	, id
	, idfactura
	, fec_factura
	, fol_factura
	, serie
	, id_empleado
	, nom_empleado
	, id_centro
	, nom_centro
	, ottp
	, fec_captura
	, id_escuela
	, nom_escuela
	, imp_factura
	, fec_pago
	, id_rutapago
	, nom_rutapago
	, imp_a_pagar
	, id_ciclo_escolar
	, ciclo_escolar
	, id_estatus
	, nom_estatus
	, fec_estatus
	, num_modifico_estatus
	, nom_modifico_estatus
	, num_tarjeta
	, fec_baja
	, des_observaciones
	, id_tipodocumento
	, nom_tipodocumento
FROM fun_obtener_listado_facturas_colegiaturas (1
		, '20180801'
		, '20180910'
		, 1
		, ''
		, 10
		, 1
		, 'fec_captura'
		, 'asc'
		, 'idfactura,fec_factura,fol_factura,serie,id_empleado,nom_empleado,id_centro, nom_centro,ottp,fec_captura,id_escuela,nom_escuela,imp_factura
			,fec_pago,id_rutapago,nom_rutapago,imp_a_pagar,id_ciclo_escolar,ciclo_escolar,id_estatus,nom_estatus,fec_estatus,num_modifico_estatus
			, nom_modifico_estatus,num_tarjeta,fec_baja,des_observaciones, id_tipodocumento, nom_tipodocumento')
	

  ------------------------------------------------------------------------------------------------------ */
     iEstatus ALIAS FOR $1;
     dFec_ini ALIAS FOR $2; 
     dFec_fin ALIAS FOR $3; 
     iCheckFecha ALIAS FOR $4;
     FolioFactura ALIAS FOR $5;
     iRowsPerPage ALIAS FOR $6;
     iCurrentPage ALIAS FOR $7;
     sOrderColumn ALIAS FOR $8;
     sOrderType ALIAS FOR $9;
     sColumns ALIAS FOR $10; 
     iStart INTEGER;
     iRecords INTEGER;
     iTotalPages INTEGER;
     sConsulta VARCHAR(3000);
     col RECORD;
     sSQL text;
    
     returnrec type_fun_obtener_listado_facturas_colegiaturas;
     
BEGIN
	
    create local temp table tmp_consulta_facturas
    (   
        records integer not null default 0
	,page integer not null default 0
	,pages integer not null default 0
	,id integer not null default 0
	,idfactura integer not null default 0
	,fec_factura TIMESTAMP not null default '19000101'
	,fol_factura VARCHAR(100) default ''
	,serie VARCHAR(20) default ''
	,id_empleado INTEGER not null default 0
	,nom_empleado VARCHAR(150) not null default ''
        ,id_centro CHARACTER(6) not null default ''
        ,nom_centro VARCHAR(100) not null default ''
        ,ottp INTEGER not null default 0
        ,fec_captura TIMESTAMP without time zone not null default '19000101'
        ,id_escuela INTEGER not null default 0
        ,nom_escuela VARCHAR(100) not null default ''
        ,imp_factura NUMERIC (12,2) not null default 0
        ,fec_pago TIMESTAMP not null default '19000101'
        ,id_rutapago integer not null default 0
        ,nom_rutapago VARCHAR(20) not null default ''
        ,imp_a_pagar NUMERIC (12,2) not null default 0
        ,id_ciclo_escolar INTEGER not null default 0
        ,ciclo_escolar VARCHAR(30) not null default ''
        ,id_estatus INTEGER not null default 0
        ,nom_estatus VARCHAR(50) not null default ''
	,fec_estatus TIMESTAMP not null default '19000101'
        ,num_modifico_estatus integer not null default 0
        ,nom_modifico_estatus VARCHAR(150) not null default ''
        ,num_tarjeta CHARACTER(16) not null default ''
        ,fec_baja TIMESTAMP not null default '19000101'
        ,des_observaciones TEXT not null default ''
        ,id_tipodocumento integer not null default 0
        ,nom_tipodocumento character varying(50) not null default ''        
    ) on commit drop;    

	IF iRowsPerPage = -1 then
		iRowsPerPage := NULL;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := NULL;
	end if;
	
	--Inserta datos de mov_facturas_colegiaturas a temporal
	if (iEstatus = 0 or iEstatus = 1 or iEstatus = 2 or iEstatus = 3 or iEstatus = 4 or iEstatus = 5) then
		sSQL := ('INSERT INTO tmp_consulta_facturas (
				idfactura
				,fec_factura
				,fol_factura
				,serie
				,id_empleado
				,fec_captura
				, id_escuela
				, imp_factura
				, imp_a_pagar
				, id_estatus
				, fec_estatus
				,num_modifico_estatus
				, des_observaciones
				, id_tipodocumento)	
			SELECT	idfactura
				, fec_factura
				, fol_fiscal
				, serie
				, idu_empleado
				, fec_registro
				, idu_escuela
				, importe_factura
				, 0
				, CASE WHEN idu_estatus = 6 THEN 2 ELSE idu_estatus END
				, fec_marco_estatus
				, emp_marco_estatus
				, des_observaciones
				, idu_tipo_documento
			FROM	mov_facturas_colegiaturas
			WHERE	fec_registro::DATE BETWEEN '''||dFec_ini||''' and '''||dFec_fin||'''
				AND 0 = 0
				AND idu_beneficiario_externo = 0');
		IF (iEstatus = 2 ) THEN --POR ESTATUS
			sSQL :=sSQL||' AND idu_estatus  in (2,6) ';
		else
			sSQL :=sSQL||' AND idu_estatus  = '||iEstatus|| ' ';
		end if;

		IF (FolioFactura != '') THEN
			sSQL :=sSQL||' AND fol_fiscal LIKE '''||FolioFactura||'%''';
		END IF;
	
		EXECUTE sSQL;
	END IF;

	if (iEstatus = 6) then
		--Inserta datos de his_facturas_colegiaturas a temporal
		sSQL := ('INSERT INTO tmp_consulta_facturas (idfactura
				, fec_factura
				, fol_factura
				, serie
				, id_empleado
				, fec_captura
				, id_escuela
				, imp_factura
				, imp_a_pagar
				, id_estatus
				, fec_estatus
				, num_modifico_estatus
				, des_observaciones
				, id_tipodocumento)	
			SELECT	idfactura
				, fec_factura
				, fol_fiscal
				, serie
				, idu_empleado
				, fec_registro
				, idu_escuela
				, importe_factura
				, CASE WHEN idu_estatus = 6 THEN importe_pagado ELSE 0 END
				, idu_estatus
				, fec_marco_estatus
				, emp_marco_estatus
				, des_observaciones
				, idu_tipo_documento
			FROM	his_facturas_colegiaturas
			WHERE	fec_registro::DATE between '''||dFec_ini||''' and '''||dFec_fin||'''
				AND idu_estatus = ' || iEstatus || '
				AND 0 = 0
				AND idu_beneficiario_externo = 0');
		IF (FolioFactura != '') THEN
			sSQL :=sSQL||' AND fol_fiscal LIKE '''||FolioFactura||'%''';
		END IF;	
		
		EXECUTE sSQL;
	end if;


	--actualiza la ruta de pago

	--INSERTA DATOS DE SAPCATALOGOEMPLEADOS A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET 	nom_empleado = (b.nombre || ' ' || b.apellidopaterno || ' ' || b.apellidomaterno)
		, id_centro = b.centro
		, fec_baja = b.fechabaja
	FROM sapcatalogoempleados b 
	WHERE tmp_consulta_facturas.id_empleado = b.numempn;

	--INSERTA DATOS DE SAPCATALOGOEMPLEADOS A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET fec_baja = b.fechabaja
	FROM sapcatalogoempleados b 
	WHERE tmp_consulta_facturas.id_empleado = b.numempn
	and b.cancelado = '1';

	--INSERTA DATOS DE SAPCATALOGOEMPLEADOS A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET id_rutapago = b.controlpago::INTEGER, num_tarjeta = b.numerotarjeta
	FROM sapcatalogoempleados b 
	WHERE tmp_consulta_facturas.id_empleado = b.numempn	
	and tmp_consulta_facturas.id_estatus = 6 ;


-- 	UPDATE tmp_consulta_facturas 
-- 	SET id_rutapago = cast(b.clv_rutapago as varchar(2)), num_tarjeta = b.num_cuenta
-- 	FROM view_his_rutas_pagos b 
-- 	WHERE tmp_consulta_facturas.id_empleado = b.idu_empleado
-- 	and tmp_consulta_facturas.opcion = 0 
-- 	and tmp_consulta_facturas.id_estatus = 5 ;

	--CON ESTE BLOQUE COMENTADO QUEDA SOLUCIONADO
	--COMENTAR EL UPDATE SUPERIOR
-- 	update	tmp_consulta_facturas
-- 	set	id_rutapago = a.controlpago, num_tarjeta = a.numerotarjeta
-- 	from	sapcatalogoempleados a
-- 	where	a.numempn = tmp_consulta_facturas.id_empleado;

	--INSERTA DATOS DE SAPCATALOGOCENTROS A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET nom_centro = b.nombrecentro
	FROM sapcatalogocentros b 
	WHERE tmp_consulta_facturas.id_centro = b.numerocentro;	

	--INSERTA DATOS DE ESCUELA A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET nom_escuela= b.nom_escuela
	FROM cat_escuelas_colegiaturas b 
	WHERE tmp_consulta_facturas.id_escuela = b.idu_escuela;

	--INSERTA DATOS DE ESTATUS A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET nom_estatus= b.nom_estatus
	FROM cat_estatus_facturas b 
	WHERE tmp_consulta_facturas.id_estatus = b.idu_estatus;

	--INSERTA DATOS DE RUTA PAGO A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET nom_rutapago= b.nom_rutapago
	FROM cat_rutaspagos b 
	WHERE tmp_consulta_facturas.id_rutapago <> 0 
	and tmp_consulta_facturas.id_rutapago = b.idu_rutapago;

	--INSERTA DATOS DE MOV_DETALLE_FACTURAS_COLEGIATURAS A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET id_ciclo_escolar = b.idu_ciclo_escolar
	FROM mov_detalle_facturas_colegiaturas b 
	WHERE tmp_consulta_facturas.idfactura = b.idfactura;

	--INSERTA DATOS DE HIS_DETALLE_FACTURAS_COLEGIATURAS A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET id_ciclo_escolar = b.idu_ciclo_escolar
	FROM his_detalle_facturas_colegiaturas b 
	WHERE tmp_consulta_facturas.idfactura = b.idfactura;

	--INSERTA DATOS DE cat_ciclo_escolar A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET ciclo_escolar = b.des_ciclo_escolar
	FROM cat_ciclos_escolares b 
	WHERE tmp_consulta_facturas.id_ciclo_escolar = b.idu_ciclo_escolar;

	--INSERTA DATOS DE SAPCATALOGOEMPLEADOS A TEMPORAL
	UPDATE tmp_consulta_facturas 
	SET nom_modifico_estatus = (b.nombre || ' ' || b.apellidopaterno || ' ' || b.apellidomaterno) 
	FROM sapcatalogoempleados b 
	WHERE tmp_consulta_facturas.num_modifico_estatus = b.numempn;

	UPDATE tmp_consulta_facturas 
	SET Ottp = (select count(distinct det.idu_tipopago) from mov_detalle_facturas_colegiaturas det
	where det.idfactura = tmp_consulta_facturas.idfactura);

	--Actualiza dato de fecha de pago de la temporal
	update	tmp_consulta_facturas
	set	fec_pago = his.fec_cierre::date
	from	his_facturas_colegiaturas his
	where	tmp_consulta_facturas.idfactura = his.idfactura
		AND tmp_consulta_facturas.id_estatus = 6;

	--Actualiza el dato del tipo de documento de la temporal
	update	tmp_consulta_facturas
	set	nom_tipodocumento = b.nom_tipo_documento
	from	cat_tipo_documento b
	where	tmp_consulta_facturas.id_tipodocumento = b.idu_tipo_documento;

	--
	update	tmp_consulta_facturas
	set	nom_modifico_estatus = 'AUTORIZADA POR SISTEMA'
	where	tmp_consulta_facturas.num_modifico_estatus = 0
		and tmp_consulta_facturas.fec_estatus != '19000101'
		and tmp_consulta_facturas.id_estatus = 1;

	iRecords := (SELECT COUNT(*) FROM tmp_consulta_facturas);
    IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
	    iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
	    iRecords := (SELECT COUNT(*) FROM tmp_consulta_facturas);
	    iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));
    
		sConsulta := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
		    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		    , id
		    , ' || sColumns || '
		from (
			SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
			FROM tmp_consulta_facturas
			) AS t
		where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
               
       ELSE
		sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM tmp_consulta_facturas ';
      END if;
        sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
  RAISE NOTICE 'notice %', sConsulta;
    for returnrec in execute sConsulta loop
        RETURN NEXT returnrec;
    end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_facturas_colegiaturas(integer, timestamp without time zone, timestamp without time zone, integer, character varying, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_facturas_colegiaturas(integer, timestamp without time zone, timestamp without time zone, integer, character varying, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_facturas_colegiaturas(integer, timestamp without time zone, timestamp without time zone, integer, character varying, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_facturas_colegiaturas(integer, timestamp without time zone, timestamp without time zone, integer, character varying, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_facturas_colegiaturas(integer, timestamp without time zone, timestamp without time zone, integer, character varying, integer, integer, character varying, character varying, character varying) IS 'La función obtiene un listado de las facturas que se han subido al sistema de Colegiaturas.';