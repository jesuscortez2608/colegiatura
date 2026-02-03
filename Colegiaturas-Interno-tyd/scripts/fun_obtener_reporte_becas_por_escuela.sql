DROP FUNCTION IF EXISTS fun_obtener_reporte_becas_por_escuela(integer, integer, integer, integer, integer, integer, date, date, integer, integer);

CREATE OR REPLACE FUNCTION fun_obtener_reporte_becas_por_escuela(idrutapago integer, idestatus integer, idregion integer, idciudad integer, idempresa integer, idtipodeduccion integer, dfechainicial date, dfechafinal date, idescolaridad integer, idescuela integer, OUT tipo integer, OUT rfc character varying, OUT idu_empresa integer, OUT nom_empresa character varying, OUT idu_escuela integer, OUT nom_escuela character varying, OUT nom_tipoescuela character varying, OUT total_facturas integer, OUT total_importefacturas numeric, OUT total_importepagado numeric, OUT idu_escolaridad integer, OUT nom_escolaridad character varying, OUT total_beneficiarios integer)
 RETURNS SETOF record
AS $function$
declare
	/*=================================================================================

		No. Peticion:		16559.1
		Fecha:			30/08/2018
		Colaborador:		Rafael Ramos 98439677
		Sistema:		Colegiaturas
		Modulo:			Reporte de Becas por Escuela
		EJEMPLO:
			SELECT * FROM fun_obtener_reporte_becas_por_escuela(
				-1
				, 0
				, 1
				, 004
				, 1
				, 0
				, '20180801'
				, '20180905'
				, 3
				, 0)	
	=====================================================================================*/
	/*VARIABLES DE PAGINADO*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;

	sQuery text;
	sConsulta varchar(3000);
	valor record;

	TotalRegistros integer;
begin

	create temporary table tmp_BecasEscuelas(
		tipo integer
		, rfc character varying(20)--
		, idu_empleado integer--
		, idu_empresa integer--
		, nom_empresa character varying(50)
		, idu_escuela integer--
		, nom_escuela character varying(100)
		, idu_tipoescuela integer
		, nom_tipoescuela character varying(20)
		, idu_escolaridad integer
		, nom_escolaridad character varying(30)
		, idu_beneficiario integer
		, idu_centro integer--
		, clv_rutapago integer
		, idu_region integer
		, idu_ciudad integer
		, idu_tipodeduccion integer--
		, fec_registro date--
		, idfactura integer--
		, idu_estatus integer--
		, importe_factura numeric(12,2)--
		, importe_pagado numeric(12,2)--
	)on commit drop;

	create temporary table tmp_importes(
		tipo integer
		, idu_escuela integer
		, idu_empresa integer
		, total_facturas integer
		, total_importefactura numeric(12,2)
		, total_importepagado numeric(12,2)
		, total_beneficiarios integer
		, idu_escolaridad integer
	)on commit drop;

	create temporary table tmp_totales(
		tipo integer
		, idu_empresa integer
		, nom_empresa character varying(50)
		, rfc character varying(20)
		, idu_escuela integer
		, nom_escuela character varying(100)
		, nom_tipoescuela character varying(10)
		, total_facturas integer
		, total_importefactura numeric(12,2)
		, total_importepagado numeric(12,2)
		, idu_escolaridad integer
		, nom_escolaridad character varying(100)
		, total_beneficiarios integer
	)on commit drop;

	create temporary table tmp_beneficiarios(
		escolaridad integer
		, beneficiario integer
	)on commit drop;
	--ESTATUS = PENDIENTE, PROCESO, ACEPTADA(POR PAGAR), ACLARACION , REVISION
	if(idEstatus = 0 or idEstatus = 1 or idEstatus = 2 or idEstatus = 4 or idEstatus = 5)then
		sQuery := 'INSERT INTO tmp_BecasEscuelas(
					idu_escuela
					, idu_escolaridad
					, idu_tipodeduccion
					, fec_registro
					, idu_empleado
					, idu_empresa
					, idu_centro
					, idfactura
					, importe_factura
					, importe_pagado
					, idu_beneficiario
					)
			SELECT	mov.idu_escuela
				, det.idu_escolaridad
				, mov.idu_tipo_deduccion
				, mov.fec_registro::DATE
				, mov.idu_empleado
				, mov.idu_empresa
				, mov.idu_centro
				, mov.idfactura
				, det.importe_concepto
				, det.importe_pagado
				, det.idu_beneficiario
			FROM    mov_facturas_colegiaturas AS mov
			INNER JOIN mov_detalle_facturas_colegiaturas AS det ON (mov.idfactura = det.idfactura)
			WHERE	mov.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' 
				AND mov.idu_estatus = ' || idEstatus || '
                AND mov.idu_beneficiario_externo = 0
				AND mov.idu_tipo_documento IN (1,3,4) ';
		execute (sQuery);

	end if;

	if(idEstatus = 3)then--ESTATUS = RECHAZADA
		--INSERTAR DATOS DEL HISTORICO DONDE EL ESTATUS SEA RECHAZADO A TEMP
		sQuery := 'INSERT INTO tmp_BecasEscuelas(
					idu_escuela
					, idu_escolaridad
					, idu_tipodeduccion
					, fec_registro
					, idu_empleado
					, idu_empresa
					, idu_centro
					, idfactura
					, importe_factura
					, importe_pagado
					, idu_beneficiario
					)
			SELECT	his.idu_escuela
				, det.idu_escolaridad
				, his.idu_tipo_deduccion
				, his.fec_cierre::DATE
				, his.idu_empleado
				, his.idu_empresa
				, his.idu_centro
				, his.idfactura
				, det.importe_concepto
				, det.importe_pagado
				, det.idu_beneficiario
			FROM	his_facturas_colegiaturas AS his
            INNER JOIN his_detalle_facturas_colegiaturas AS det ON (his.idfactura = det.idfactura)
			WHERE	his.fec_cierre::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' 
				AND his.idu_estatus = ' || idEstatus || '
                AND his.idu_tipo_documento IN (1,3,4)
                AND his.idu_beneficiario_externo = 0';
		execute (sQuery);
		
		--INSERTAR DATOS DE LA MOV_FACTURAS_COLEGIATURAS DONDE EL ESTATUS SEA RECHAZADAS
		sQuery := 'INSERT INTO tmp_BecasEscuelas(
					idu_escuela
					, idu_escolaridad
					, idu_tipodeduccion
					, fec_registro
					, idu_empleado
					, idu_empresa
					, idu_centro
					, idfactura
					, importe_factura
					, importe_pagado
					, idu_beneficiario
					)
			SELECT	mov.idu_escuela
				, det.idu_escolaridad
				, mov.idu_tipo_deduccion
				, mov.fec_registro::DATE
				, mov.idu_empleado
				, mov.idu_empresa
				, mov.idu_centro
				, mov.idfactura
				, det.importe_concepto
				, det.importe_pagado
				, det.idu_beneficiario
			FROM	mov_facturas_colegiaturas AS mov
			INNER JOIN mov_detalle_facturas_colegiaturas AS det ON (mov.idfactura = det.idfactura)
			WHERE	mov.fec_registro::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' 
				AND mov.idu_estatus = ' || idEstatus || '
                AND mov.idu_tipo_documento in (1,3,4)
                AND mov.idu_beneficiario_externo = 0';
		execute (sQuery);

	end if;
	if (idEstatus = 6)then--ESTATUS= PAGADAS
		sQuery := 'INSERT INTO tmp_BecasEscuelas(
					idu_escuela
					, idu_escolaridad
					, idu_tipodeduccion
					, fec_registro
					, idu_empleado
					, idu_empresa
					, idu_centro
					, idfactura
					, importe_factura
					, importe_pagado
					, idu_beneficiario
					)
			SELECT	his.idu_escuela
				, det.idu_escolaridad
				, his.idu_tipo_deduccion
				, his.fec_cierre::DATE
				, his.idu_empleado
				, his.idu_empresa
				, his.idu_centro
				, his.idfactura
				, det.importe_concepto
				, det.importe_pagado
				, det.idu_beneficiario
			FROM	his_facturas_colegiaturas AS his
			INNER JOIN his_detalle_facturas_colegiaturas AS det ON (his.idfactura = det.idfactura)
			WHERE	his.fec_cierre::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' 
				AND his.idu_estatus = ' || idEstatus || ' ';
		execute (sQuery);

		
	end if;

        --ACTUALIZAR EL RFC, NOMBRE Y TIPO DE ESCUELA DE LA TABLA CAT_ESCUELAS_COLEGIATURAS A TMP
		update	tmp_BecasEscuelas
		set	rfc = (CASE When A.rfc_clave_sep = '' then A.clave_sep ELSE A.rfc_clave_sep end)
			, nom_escuela = trim(UPPER(A.nom_escuela))
			, idu_tipoescuela = A.opc_tipo_escuela
		from	cat_escuelas_colegiaturas A
		where	tmp_BecasEscuelas.idu_escuela = A.idu_escuela
			AND tmp_BecasEscuelas.idu_escolaridad = A.idu_escolaridad;

		-- ACTUALIZAR EL NOMBRE DE LA ESCOLARIDAD DE LA TMP
		update	tmp_BecasEscuelas
		set	nom_escolaridad = trim(UPPER(A.nom_escolaridad))
		from	cat_escolaridades A
		WHERE	tmp_BecasEscuelas.idu_escolaridad = A.idu_escolaridad;

		--ACTUALIZAR EL NOMBRE DEL TIPO DE ESCUELA DE TMP
		update	tmp_BecasEscuelas a
		set	nom_tipoescuela = (case when a.idu_tipoescuela = 1 then 'PÚBLICA' else 'PRIVADA' end);

		--ACTUALIZAR EL NOMBRE DE LA EMPRESA
		update	tmp_BecasEscuelas
		set	nom_empresa = trim(UPPER(A.nom_empresa))
		from	view_empresas_colegiaturas A
		where	tmp_BecasEscuelas.idu_empresa = A.idu_empresa;

		--ACTUALIZAR RUTA DE PAGO
		update	tmp_BecasEscuelas
		set	clv_rutapago = emp.controlpago::INTEGER
		from	sapcatalogoempleados emp
		where	tmp_BecasEscuelas.idu_empleado = emp.numempn;
		
		--ACTUALIZAR CIUDAD DE TMP
		update	tmp_BecasEscuelas
		set	idu_ciudad = cen.ciudadn
		from	sapcatalogocentros cen
		where	tmp_BecasEscuelas.idu_centro = cen.centron;

		--ACTUALIZAR REGION DE TMP
		UPDATE	tmp_BecasEscuelas
		set	idu_region = cd.regionzona::INTEGER
		from	sapcatalogociudades cd
		where	tmp_BecasEscuelas.idu_ciudad = cd.ciudadn;

		
		--APLICAR FILTROS DE CONSULTA(PARAMS ENTRADA)
		if(idRutaPago != -1)then--RUTAPAGO
			delete from tmp_BecasEscuelas as a where a.clv_rutapago NOT IN(idRutaPago);
		end if;

		if(idRegion != 0)then--POR REGION
			delete from tmp_BecasEscuelas as a where a.idu_region not in(idRegion);
		end if;

		if(idCiudad != 0)then--POR CIUDAD
			delete from tmp_BecasEscuelas as a where a.idu_ciudad not in (idCiudad);
		end if;

		if(idTipoDeduccion != 0)then--POR TIPO DEDUCCION
			delete from tmp_BecasEscuelas as a where a.idu_tipodeduccion not in (idTipoDeduccion);
		end if;

		if(idEscolaridad != 0)then--POR ESCOLARIDAD
			delete from tmp_BecasEscuelas as a where a.idu_escolaridad not in (idEscolaridad);
		end if;

		if(idEscuela != 0)then--POR ESCUELA
			delete from tmp_BecasEscuelas as a where a.idu_escuela not in (idEscuela);
		end if;

		if(idEmpresa != 0)then--POR EMPRESA
			delete from tmp_BecasEscuelas as a where a.idu_empresa not in (idEmpresa);
		end if;
	--========================================================================================
	--CALCULAR TOTALES POR CENTRO
	insert into tmp_importes(
			tipo
			, idu_escuela
			, idu_empresa
			, total_facturas
			, total_importefactura
			, total_importepagado
			, total_beneficiarios
			, idu_escolaridad)
	select	1
		, A.idu_escuela
		, A.idu_empresa
		, COUNT(distinct (A.idfactura))
		, SUM(A.importe_factura)
		, SUM(A.importe_pagado)
		, COUNT(A.idu_beneficiario)
		, A.idu_escolaridad
	from	tmp_BecasEscuelas AS A
	group	by A.idu_escuela,A.idu_empresa, A.idu_escolaridad;

	insert into tmp_beneficiarios(
			escolaridad
			, beneficiario)
	SELECT	A.idu_escuela
		, COUNT(DISTINCT(A.idu_beneficiario,A.idu_empleado)) 
	FROM	tmp_BecasEscuelas A
	group	by A.idu_escuela, A.idu_beneficiario, A.idu_empleado;

	--ACTUALIZAR TOTALES DE BENEFICIARIOS A TMP_IMPORTES
	update	tmp_importes 
	set	total_beneficiarios = (SELECT SUM(A.beneficiario) FROM tmp_beneficiarios  A WHERE A.escolaridad = tmp_importes.idu_escuela)
	where	tmp_importes.tipo = 1;

	--CALCULAR TOTALES ESCUELAS
	INSERT INTO tmp_totales(tipo
		, idu_escuela
		, idu_empresa
		, total_facturas
		, total_importefactura
		, total_importepagado
		, total_beneficiarios
		, idu_escolaridad)
	SELECT	1
		, A.idu_escuela
		, A.idu_empresa
		, A.total_facturas
		, A.total_importefactura
		, A.total_importepagado
		, A.total_beneficiarios
		, A.idu_escolaridad
	FROM	tmp_importes as A;

	--ACTUALIZAR CAMPOS DE RFC Y EMPRESA A TMP_TOTALES
	update	tmp_totales
	set	rfc = B.rfc
	from	tmp_BecasEscuelas B
	where	tmp_totales.idu_escuela = B.idu_escuela;

	update	tmp_totales
	set	nom_escuela = B.nom_escuela
		, idu_escuela = B.idu_escuela
		, nom_tipoescuela = (case when B.opc_tipo_escuela = 1 then 'PÚBLICA' else 'PRIVADA' end)
	from	cat_escuelas_colegiaturas B
	where	trim(tmp_totales.rfc) = (case when B.rfc_clave_sep = '' then clave_sep else rfc_clave_sep end)
		and tmp_totales.idu_escolaridad = B.idu_escolaridad;

	update	tmp_totales
	set	nom_escolaridad = B.nom_escolaridad
	from	cat_escolaridades B
	where	tmp_totales.idu_escolaridad = B.idu_escolaridad;

	update 	tmp_totales
	set	nom_empresa = trim(UPPER(A.nom_empresa))
	from	view_empresas_colegiaturas A
	where	tmp_totales.idu_empresa = A.idu_empresa;
    
	TotalRegistros := (select COUNT(*) from tmp_totales);
    
	--CALCULAR TOTAL GENERAL
	if(TotalRegistros != 0) then
		insert into tmp_totales(
				tipo
				, total_facturas
				, total_importefactura
				, total_importepagado
				, total_beneficiarios)
		SELECT	2
			, SUM(A.total_facturas)
			, SUM(A.total_importefactura)
			, SUM(A.total_importepagado)
			, SUM(A.total_beneficiarios)
		from	tmp_totales as A
		where	A.tipo = 1;

		truncate tmp_beneficiarios;
		insert into tmp_beneficiarios(
				escolaridad
				, beneficiario)
		SELECt	1
			, COUNT(distinct(idu_beneficiario,idu_empleado)) from tmp_BecasEscuelas
		group 	by idu_beneficiario, idu_empleado;

		update	tmp_totales
		set	total_facturas = (SELECT COUNT(distinct (idfactura)) FROm tmp_BecasEscuelas) 
		where	tmp_totales.tipo = 2;

		update	tmp_totales
		set	total_beneficiarios = (SELECT SUM(beneficiario) from tmp_beneficiarios)
		where 	tmp_totales.tipo = 2;
	end if;
    
	for valor in (SELECT
                    tmp.tipo
                    , tmp.idu_empresa
                    , tmp.nom_empresa
                    , tmp.rfc
                    , tmp.idu_escuela
                    , tmp.nom_escuela
                    , tmp.nom_tipoescuela
                    , tmp.total_facturas
                    , tmp.total_importefactura
                    , tmp.total_importepagado
                    , tmp.idu_escolaridad
                    , tmp.nom_escolaridad
                    , tmp.total_beneficiarios
                FROm tmp_totales as tmp
                ORDER BY tmp.idu_empresa, tmp.rfc)
                loop
                    tipo			:=	valor.tipo;
                    rfc 			:=	valor.rfc;
                    idu_empresa 		:=	valor.idu_empresa;
                    nom_empresa 		:=	valor.nom_empresa;
                    idu_escuela 		:=	valor.idu_escuela;
                    nom_escuela 		:=	valor.nom_escuela;
                    --idu_tipoescuela 	:=	valor.idu_tipoescuela;
                    nom_tipoescuela 	:=	valor.nom_tipoescuela;
                    total_facturas 		:=	valor.total_facturas;
                    total_importefacturas 	:=	valor.total_importefactura;
                    total_importepagado 	:=	valor.total_importepagado;
                    idu_escolaridad 	:=	valor.idu_escolaridad;
                    nom_escolaridad 	:=	valor.nom_escolaridad;
                    total_beneficiarios	:=	valor.total_beneficiarios;
                    return next;
                    
                end loop;
	
end;
$function$
LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_reporte_becas_por_escuela(integer, integer, integer, integer, integer, integer, date, date, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_becas_por_escuela(integer, integer, integer, integer, integer, integer, date, date, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_becas_por_escuela(integer, integer, integer, integer, integer, integer, date, date, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_becas_por_escuela(integer, integer, integer, integer, integer, integer, date, date, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_becas_por_escuela(integer, integer, integer, integer, integer, integer, date, date, integer, integer) IS 'La función obtiene el reporte de pagos de colegiaturas por escuela.';  