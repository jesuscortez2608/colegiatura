DROP FUNCTION IF EXISTS fun_obtener_movimientos_colegiaturas(integer, integer, integer, integer, date, date, text, text, integer, integer, integer, character varying, character varying, text);
drop type if exists type_fun_obtener_movimientos_colegiaturas;

CREATE TYPE type_fun_obtener_movimientos_colegiaturas AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    idestatus integer,
    estatus character varying(30),
    fechaestatus character varying(10),
    empestatus integer,
    empestatusnombre character varying(150),
    fechabaja character varying(10),
    facturafiscal character varying(100),
    fechafactura character varying(10),
    fechacaptura character varying(10),
    idcicloescolar integer,
    cicloescolar character varying(30),
    importefactura numeric(12,2),
    importepagado numeric(12,2),
    importetope numeric(12,2),
    rfc character varying(20),
    nombreescuela character varying(100),
    idtipodeduccion integer,
    tipodeduccion character varying(30),
    motivorechazo text,
    idfactura integer,
    empleado integer,
    nombreempleado character varying(150),
    fecha timestamp without time zone,
    id_tipodocumento integer,
    nom_tipodocumento character varying(50));

CREATE OR REPLACE FUNCTION fun_obtener_movimientos_colegiaturas(integer, integer, integer, integer, date, date, text, text, integer, integer, integer, character varying, character varying, text)
  RETURNS SETOF type_fun_obtener_movimientos_colegiaturas AS
$BODY$
DECLARE
	nEmpleado ALIAS FOR $1;
	nEstatus ALIAS FOR $2;
	nCicloEscolar ALIAS FOR $3;
	nTipoDeduccion ALIAS FOR $4;
	dFechaIni ALIAS FOR $5;
	dFechaFin ALIAS FOR $6;
	sRegion ALIAS FOR $7;
	sCiudad ALIAS FOR $8;
	nCentro ALIAS FOR $9;
	iRowsPerPage ALIAS FOR $10;
	iCurrentPage ALIAS FOR $11;
	sOrderColumn ALIAS FOR $12;
	sOrderType ALIAS FOR $13;
	sColumns ALIAS FOR $14;
	sSQL text;
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;
	registros type_fun_obtener_movimientos_colegiaturas;
/*
	     No. petición APS               : 8613.1
	     Fecha                          : 16/11/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.2.89
	     Servidor de produccion         : 
	     Descripción del funcionamiento : Regresa las facturas que correspondientes a los filtros seleccionados
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Consulta de factura de personal administracion
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_movimientos_colegiaturas(0,-1,0,0,'20160110'::date,'20161130'::date,0,0,0,-1,-1,'fecha','asc',
		 'idEstatus,estatus,fechaEstatus,empEstatus,empEstatusNombre,fechaBaja,facturaFiscal,fechaFactura,fechaCaptura,idCicloEscolar,cicloEscolar,importeFactura,importePagado, importeTope, rfc, nombreEscuela, idTipoDeduccion, TipoDeduccion, motivoRechazo, idfactura, empleado, nombreempleado, fecha')


		 SELECT * FROM fun_obtener_movimientos_colegiaturas(0,-1,0,0,'20160110'::date,'20161130'::date,1,4,0,-1,-1,'fecha','asc',
		 'idEstatus,estatus,fechaEstatus,empEstatus,empEstatusNombre,fechaBaja,facturaFiscal,fechaFactura,fechaCaptura,idCicloEscolar,
		 cicloEscolar,importeFactura,importePagado, importeTope, rfc, nombreEscuela, idTipoDeduccion, TipoDeduccion, motivoRechazo, idfactura, 
		 empleado, nombreempleado, fecha, id_tipodocumento, nom_tipodocumento')

		 SELECT * FROM fun_obtener_movimientos_colegiaturas(93902761, -1,2016,0,'20160208','20161117',1,006,0, 10, 1, 'fecha', 'asc', 'idEstatus,estatus,fechaEstatus,empEstatus,empEstatusNombre,fechaBaja,
		 facturaFiscal,fechaFactura,fechaCaptura,idCicloEscolar,cicloEscolar,importeFactura,importePagado, importeTope, rfc, nombreEscuela, idTipoDeduccion, TipoDeduccion, motivoRechazo,idfactura, empleado, nombreempleado, fecha')



SELECT records
	, page
	, pages
	, id
	, idestatus
	, estatus
	, fechaestatus
	, empestatus
	, empestatusnombre
	, fechabaja
	, facturafiscal
	, fechafactura
	, fechacaptura
	, idcicloescolar
	, cicloescolar
	, importefactura
	, importepagado
	, importetope
	, rfc
	, nombreescuela
	, idtipodeduccion
	, tipodeduccion
	, motivorechazo
	, idfactura
	, empleado
	, nombreempleado
	, fecha
	, id_tipodocumento
	, nom_tipodocumento
FROM fun_obtener_movimientos_colegiaturas(95194185, -1,2018,0,'20180701','20180808','0','0'
										,0, 10, 1, 'fecha', 'asc', 'idEstatus,estatus,fechaEstatus,empEstatus,empEstatusNombre,fechaBaja,
facturaFiscal,fechaFactura,fechaCaptura,idCicloEscolar,cicloEscolar,importeFactura,importePagado, importeTope, rfc, nombreEscuela, 
idTipoDeduccion, TipoDeduccion, motivoRechazo,idfactura, empleado, nombreempleado, fecha, id_tipodocumento, nom_tipodocumento')
	*/
BEGIN
	IF iRowsPerPage = -1 then
		iRowsPerPage := NULL;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := NULL;
	end if;
	
	CREATE TEMPORARY TABLE tmp_Facturas
	(
		 idFactura integer
		, idEstatus integer
		, estatus varchar(30)
		, fechaEstatus varchar(10) not null default ''
		, empEstatus integer 
		, empEstatusNombre varchar(150)  not null default ''
		, fechaBaja varchar(10)  not null default ''
		, facturaFiscal varchar(100)  not null default ''
		, fecha timestamp without time zone
		, fechaFactura varchar(10) 
		, fechaCaptura varchar(10)
		, idCicloEscolar integer
		, cicloEscolar varchar(30)  not null default ''
		, importeFactura numeric(12,2)
		, importePagado numeric(12,2)
		, importeTope  numeric(12,2)
		, idEscuela integer
		, rfc varchar(20)  not null default ''
		, nombreEscuela varchar(100)  not null default ''
		, idTipoDeduccion integer
		, TipoDeduccion varchar(30)  not null default 'NO DEFINIDO'
		, motivoRechazo text
		, empleado integer
		, nombreEmpleado varchar(150)
		, centro integer
		, ciudad integer
		, region integer
		, id_tipodocumento integer
		, nom_tipodocumento character varying(50)
	)on commit drop;
    
	if (nEstatus<>6) then
		sSQL:=' INSERT INTO tmp_Facturas (idFactura
						, idEstatus
						, fechaEstatus
						, empEstatus
						, facturaFiscal
						, fecha
						, fechaFactura
						, fechaCaptura
						, importeFactura
						, importePagado
						, idEscuela
						, rfc
						, idTipoDeduccion
						, motivoRechazo
						, empleado
						, id_tipodocumento)
			SELECT idFactura
				, case when idu_estatus=6 then 2 else idu_estatus end
				, case when to_char(fec_marco_estatus,''dd/MM/yyyy'')=''01/01/1900'' then to_char(fec_registro,''dd/MM/yyyy'') else to_char(fec_marco_estatus,''dd/MM/yyyy'') end 
				, emp_marco_estatus
				, fol_fiscal
				, fec_factura
				, to_char(fec_factura,''dd/MM/yyyy'')
				, to_char(fec_registro,''dd/MM/yyyy'')
				, importe_factura
				, importe_pagado
				, idu_escuela
				, rfc_clave
				, idu_tipo_deduccion
				, des_observaciones
				, idu_empleado
				, idu_tipo_documento
			FROM	mov_facturas_colegiaturas
			WHERE	idu_beneficiario_externo = 0
				AND fec_registro::DATE BETWEEN '''|| dFechaIni||''' AND '''||dFechaFin||''' ';
		IF nEstatus <> -1 THEN --TODOS LOS ESTATUS
			IF nEstatus = 2 then
				sSQL :=sSQL||'  AND idu_estatus in (2,6)';
			else 
				sSQL :=sSQL||'  AND idu_estatus ='||nEstatus;
			end if;
		END IF;
		
		IF nTipoDeduccion <> 0 THEN --TODAS LAS DEDUCCIONES
			sSQL :=sSQL||'  AND idu_tipo_deduccion='||nTipoDeduccion;
		END IF;

		IF nEmpleado <> 0 THEN
			sSQL :=sSQL||'  AND idu_empleado='||nEmpleado;
		END IF;	
		EXECUTE sSQL;
	end if;
-- 	if (nEstatus = 6) then
		sSQL:='INSERT INTO tmp_Facturas (idFactura
						, idEstatus
						, fechaEstatus
						, empEstatus
						, facturaFiscal
						, fecha
						, fechaFactura
						, fechaCaptura
						, importeFactura
						, importePagado
						, idEscuela
						, rfc
						, idTipoDeduccion
						, motivoRechazo
						, empleado
						, id_tipodocumento)
			SELECT idFactura
				, idu_estatus
				, case when to_char(fec_marco_estatus,''dd/MM/yyyy'')=''01/01/1900'' then to_char(fec_registro,''dd/MM/yyyy'') else to_char(fec_marco_estatus,''dd/MM/yyyy'') end 
				, emp_marco_estatus
				, fol_fiscal
				, fec_factura
				, to_char(fec_factura,''dd/MM/yyyy'')
				, to_char(fec_registro,''dd/MM/yyyy'')
				, importe_factura
				, importe_pagado
				, idu_escuela
				, rfc_clave
				, idu_tipo_deduccion
				, des_observaciones
				, idu_empleado
				, idu_tipo_documento
			FROM	his_facturas_colegiaturas
			WHERE   idu_beneficiario_externo = 0
				AND fec_registro::DATE  between '''|| dFechaIni||''' and '''||dFechaFin||''' ';
		IF nEstatus<>-1 THEN --TODOS LOS ESTATUS
			sSQL :=sSQL||'  AND idu_estatus='||nEstatus;
		END IF;		
		IF nTipoDeduccion<>0 THEN --TODAS LAS DEDUCCIONES
			sSQL :=sSQL||'  AND idu_tipo_deduccion='||nTipoDeduccion;
		END IF;

		IF nEmpleado<>0 THEN
			sSQL :=sSQL||'  AND idu_empleado='||nEmpleado;
		END IF;	
		EXECUTE sSQL;
-- 	end if;
	
	--RAISE NOTICE 'notice %', sSQL;
	
	IF (nCentro <> 0 OR trim(sCiudad) != '0' OR trim(sRegion) != '0') THEN 
	--Actualizar el centro del empleados en la temporal
		UPDATE	tmp_Facturas	
		SET	centro=a.centro::integer 
		from 	SAPCATALOGOEMPLEADOS a 
		where 	a.numemp::integer=tmp_Facturas.empleado 
			or a.numempn = tmp_Facturas.empleado;
	--Actualizar la ciudad del empleado en la temporal
		UPDATE	tmp_Facturas
		SET 	ciudad=a.numerociudad::integer 
		from 	SAPCATALOGOCENTROS a 
		where 	a.numerocentro::integer=tmp_Facturas.centro;
	--Actualizar la region del empleado en la temporal
		UPDATE	tmp_Facturas 
		SET	region=a.regionzona::integer 
		from 	sapcatalogociudades a 
		where 	a.numero::integer=tmp_Facturas.ciudad;
		
		IF nCentro <> 0 THEN --Filtrado X CENTRO
			DELETE FROM tmp_Facturas WHERE centro NOT IN (nCentro);
		end if;
		IF trim(sCiudad) != '0' THEN --Filtrado X CIUDAD
			sSQL := ' DELETE FROM tmp_Facturas WHERE ciudad NOT IN ('||sCiudad||');';
			EXECUTE sSQL;
		end if;
		if trim(sRegion) != '0' then
			sSQL := ' DELETE FROM tmp_Facturas WHERE region  NOT IN ('||sRegion||');';
			EXECUTE sSQL;
		END IF;

	END IF;
	
	-- ACTUALIZAR CAMPOS
	--Actualizar el nombre del colaborador que asigno el estatus de la factura
	UPDATE	tmp_Facturas 
	SET 	empEstatusNombre=TRIM(a.nombre)||' '||trim(a.apellidopaterno)||' '||trim(a.apellidomaterno)
	from 	SAPCATALOGOEMPLEADOS a 
	where 	a.numemp=tmp_Facturas.empEstatus::VARCHAR;
    
	--Actualizar el nombre del colaborador de la factura, la fecha baja y el importe tope del colaborador
	UPDATE	tmp_Facturas 
	SET 	nombreEmpleado=TRIM(a.nombre)||' '||trim(a.apellidopaterno)||' '||trim(a.apellidomaterno)
		, fechaBaja=case when a.cancelado!='1'  then '' else to_char(a.fechabaja,'dd/MM/yyyy') end
		, importeTope=(cast(a.sueldo/2 as numeric(12,2))/100)
	from 	SAPCATALOGOEMPLEADOS a 
	where 	a.numemp=tmp_Facturas.empleado::VARCHAR;
	
	--Acualiza el nombre de la escuela
	UPDATE 	tmp_Facturas 
	SET 	nombreEscuela=TRIM(a.nom_escuela)
	from 	cat_escuelas_colegiaturas a 
	where 	a.idu_escuela=tmp_Facturas.idEscuela;
	
	--Actualiza el tipo de deduccion
	UPDATE 	tmp_Facturas 
	SET 	TipoDeduccion=TRIM(a.nom_deduccion)
	from 	cat_tipos_deduccion a 
	where 	a.idu_tipo=tmp_Facturas.idTipoDeduccion;
	
	--Actualiza el estatus de las facturas
	update 	tmp_Facturas 
	set 	estatus=trim(a.nom_estatus)
	from 	cat_estatus_facturas a 
	where 	idu_estatus=tmp_Facturas.idEstatus;
	
	--Actualiza el ciclo escolar
	update 	tmp_Facturas 
	set 	idCicloEscolar=a.idu_ciclo_escolar 
	from 	mov_detalle_facturas_colegiaturas a 
	where 	a.idfactura=tmp_Facturas.idFactura;
	
	--Actualiza el ciclo escolar(HISTORICO)
	update 	tmp_Facturas 
	set 	idCicloEscolar=a.idu_ciclo_escolar 
	from 	his_detalle_facturas_colegiaturas a 
	where 	a.idfactura=tmp_Facturas.idFactura;
	
	--Actualiza el nombre del ciclo escolar
	update 	tmp_Facturas 
	set 	cicloEscolar=trim(a.des_ciclo_escolar) 
	from 	cat_ciclos_escolares a 
	where 	a.idu_ciclo_escolar=tmp_Facturas.idCicloEscolar;
	--Actualiza el nombre del documento
	update	tmp_Facturas
	set	nom_tipodocumento = b.nom_tipo_documento
	from	cat_tipo_documento b
	where	tmp_Facturas.id_tipodocumento = b.idu_tipo_documento;
 
	IF nCicloEscolar <> 0 THEN
		DELETE FROM tmp_Facturas WHERE idCicloEscolar NOT IN (nCicloEscolar);
	END IF;

	iRecords := (SELECT COUNT(*) FROM tmp_Facturas);	
	IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iRecords := (SELECT COUNT(*) FROM tmp_facturas);
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));

		sSQL := '
			select ' || CAST(iRecords AS VARCHAR) || ' AS records
			    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
			    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
			    , id
			    , ' || sColumns || '
			from (
				SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM tmp_Facturas
				) AS t
			where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
       ELSE
		sSQL := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM tmp_facturas ';
		
      END if;
        sSQL := sSQL || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
        
        RAISE NOTICE 'notice %', sSQL;


    for registros in execute sSQL loop
        RETURN NEXT registros;
    end loop;

	/*FOR registros IN 
		SELECT idEstatus, estatus, fechaEstatus, empEstatus, empEstatusNombre, fechaBaja, facturaFiscal, fechaFactura, fechaCaptura, 
		idClicloEscolar, cicloEscolar,importeFactura, importePagado, importeTope, rfc, nombreEscuela, idTipoDeduccion, TipoDeduccion, motivoRechazo 
		FROM tmp_Facturas order by fecha ASC
	LOOP
		RETURN NEXT registros;
	END LOOP;*/
 END;
 $BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_movimientos_colegiaturas(integer, integer, integer, integer, date, date, text, text, integer, integer, integer, character varying, character varying, text) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_movimientos_colegiaturas(integer, integer, integer, integer, date, date, text, text, integer, integer, integer, character varying, character varying, text) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_movimientos_colegiaturas(integer, integer, integer, integer, date, date, text, text, integer, integer, integer, character varying, character varying, text) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_movimientos_colegiaturas(integer, integer, integer, integer, date, date, text, text, integer, integer, integer, character varying, character varying, text) TO postgres;
COMMENT ON FUNCTION fun_obtener_movimientos_colegiaturas(integer, integer, integer, integer, date, date, text, text, integer, integer, integer, character varying, character varying, text) IS 'La función obtiene los movimientos de facturas aplicando ciertos filtros.';
