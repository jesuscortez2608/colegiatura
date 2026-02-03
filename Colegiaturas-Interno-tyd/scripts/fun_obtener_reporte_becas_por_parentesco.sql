DROP FUNCTION IF EXISTS fun_obtener_reporte_becas_por_parentesco(integer, integer, integer, integer, date, date, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_obtener_reporte_becas_por_parentesco(IN irutapago integer, IN iregion integer, IN iciudad integer, IN itipodeduccion integer, IN dfechainicial date, IN dfechafinal date, IN iescolaridad integer, IN iparentesco integer, IN iempresa integer, OUT tipo integer, OUT idu_empresa integer, OUT nom_empresa character varying, OUT nom_parentesco character varying, OUT total_beneficiarios integer, OUT total_facturas integer, OUT prc_beneficiarios numeric, OUT prc_facturas numeric)
  RETURNS SETOF record AS
$BODY$
DECLARE
     /*--------------------------------------------------------------------------
     No. petición APS               : 16559.1
     Fecha                          : 26/09/2018
     Número empleado                : 98439677
     Nombre del empleado            : Rafael Ramos Gutiérrez
     Base de datos                  : Personal
     Servidor de produccion         : 
     Descripción del funcionamiento :
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Reportes / Becas Por Tipo Beneficiario (Parentesco)
     Ejemplo                        : Genera el reporte de becas por por el tipo de beneficiario(parentesco)
     
	select * from fun_obtener_reporte_becas_por_parentesco(-1,0,0,0,'20160101','20170331',0,0,0)
	SELECT * 
		FROM fun_obtener_reporte_becas_por_parentesco(
			-1
			,0
			,0
			,0
			,'20180901'
			,'20180927'
			,0
			,0
			,0)
     ---------------------------------------------------------------------------*/
	
	totalbeneficiarios integer;
	totalfacturas integer;
	totalRegistros integer;
	sQuery varchar(3000);
	valor record;
begin
	--drop table if exists tmp_BecasParentesco;
	--create table tmp_BecasParentesco(
	--create table tmp_BecasParentesco(
	create temporary table tmp_BecasParentesco(
		id_empresa integer
		, nom_empresa character varying (30)
		, id_parentesco integer not null default 0--
		, nom_parentesco character varying(15) not null default ''--
		, rutaPago integer not null default 0--
		, region integer not null default 0--
		, ciudad integer not null default 0--
		, tipo_deduccion integer not null default 0--
		, fecha_cierre date not null default '19000101'--
		, id_escolaridad integer not null default 0--
		, id_empleado integer not null default 0--
		, id_centro integer not null default 0--
		, idfactura integer not null default 0--
		, id_beneficiario integer not null default 0--
		, prc_beneficiarios numeric(12,4)
		, prc_facturas numeric(12,4)
    )on commit drop;
	--);
	
	--drop table if exists tmp_totales;
	--create table tmp_totales(
	create temporary table tmp_totales(
		tipo integer
		, id_empresa integer
		, nom_empresa character varying(30)
		, id_parentesco integer
		, nom_parentesco character varying(15) 
		, total_beneficiarios integer
		, total_facturas integer
		, prc_beneficiarios numeric(12,4)
		, prc_facturas numeric(12,4)
	)on commit drop;
	--);
	
	--drop table if exists tmp_beneficiarios;
	--create table tmp_beneficiarios(
	create temporary table tmp_beneficiarios(
		tipo integer
		, beneficiario integer
	)on commit drop;
	--);
	
	 INSERT INTO tmp_BecasParentesco(
			id_empleado
			, id_empresa
			, tipo_deduccion
			, fecha_cierre
			, idfactura
			, id_centro
			, id_beneficiario
			, id_parentesco
			, id_escolaridad)
		SELECT 	DISTINCT his.idu_empleado
			, his.idu_empresa
			, his.idu_tipo_deduccion
			, his.fec_cierre::DATE
			, his.idfactura
			, his.idu_centro
			, det.idu_beneficiario
			, det.idu_parentesco
			, det.idu_escolaridad
		FROM	his_facturas_colegiaturas AS his
		INNER 	JOIN his_detalle_facturas_colegiaturas AS det ON (his.idfactura = det.idfactura)
		WHERE	fec_cierre::DATE BETWEEN dFechaInicial AND dFechaFinal 
			AND his.idu_empleado = det.idu_empleado
			AND his.idfactura = det.idfactura
			AND his.idu_estatus = 6;

	update	tmp_BecasParentesco
	set	nom_parentesco = trim(UPPER(P.des_parentesco))
	from	cat_parentescos P
	where	tmp_BecasParentesco.id_parentesco = P.idu_parentesco;

	update	tmp_BecasParentesco
	set	rutaPago = (case when E.controlpago = '' then 0 else E.controlpago::integer end)
	--set	rutaPago = E.controlpago::integer
	from	sapcatalogoempleados E
	where	tmp_BecasParentesco.id_empleado = E.numempn;

	update	tmp_BecasParentesco
	set	ciudad = CN.ciudadn
	from	sapcatalogocentros CN
	where	tmp_BecasParentesco.id_centro = CN.centron;

	update	tmp_BecasParentesco
	set	region = regionzona::INTEGER
	from	sapcatalogociudades C
	where	tmp_BecasParentesco.ciudad = C.ciudadn;
/*
	update	tmp_BecasParentesco
	set	nom_empresa = trim(UPPER(E.nombre))
	from	sapempresas E
	where	tmp_BecasParentesco.id_empresa = E.clave;
*/
	if (iRutaPago != -1) then
		delete from tmp_BecasParentesco where rutaPago not in (iRutaPago);
	end if;
	if (iRegion != 0) then
		delete from tmp_BecasParentesco where region not in (iRegion);
	end if;
	if (iCiudad != 0) then
		delete from tmp_BecasParentesco where ciudad not in (iCiudad);
	end if;
	if (iTipoDeduccion != 0) then
		delete from tmp_BecasParentesco where tipo_deduccion not in (iTipoDeduccion);
	end if;
	if (iEscolaridad != 0) then
		delete from tmp_BecasParentesco where id_escolaridad not in (iEscolaridad);
	end if;
	if (iParentesco != 0) then
		delete from tmp_BecasParentesco where id_parentesco not in (iParentesco);
	end if;
	if (iEmpresa != 0) then
		DElete from tmp_BecasParentesco where id_empresa not in (iEmpresa);
	end if;
    
	--inserta registros de totales por parentesco
	insert into tmp_totales(
			tipo
			, id_empresa
			, id_parentesco
			, total_beneficiarios
			, total_facturas)
	SELECT	1
		, A.id_empresa
		, A.id_parentesco
		, COUNT(DISTINCT (A.id_empleado, A.id_beneficiario) )
		, COUNT(DISTINCT A.idfactura)
	from	tmp_BecasParentesco as A
	GROUP	BY  A.id_empresa, A.id_parentesco;
    
	totalbeneficiarios := (select SUM(a.total_beneficiarios) from tmp_totales as a);
	totalfacturas := (select SUM(a.total_facturas) from tmp_totales as a);

	--Calcular Porcentajes
	update	tmp_totales as a
	set	prc_beneficiarios = (case when totalbeneficiarios = 0 then 0 else (a.total_beneficiarios * (100.00 / totalbeneficiarios)) end);
    
	update	tmp_totales as a
	set	prc_facturas = (case when totalfacturas = 0 then 0 else (a.total_facturas * (100.00 / totalfacturas))end);
    
	--Actualiza el campo nombre de parentesco
	update	tmp_totales
	set	nom_parentesco = a.nom_parentesco
	from	tmp_BecasParentesco a
	where	tmp_totales.id_parentesco = a.id_parentesco
		and tmp_totales.tipo = 1;

	update	tmp_totales
	set	nom_empresa = trim(UPPER(a.nombre))
	from	sapempresas a
	where	tmp_totales.id_empresa = a.clave
		and tmp_totales.tipo = 1;
    
	TotalRegistros := (select COUNT(*) from tmp_totales);
    
    --Calcular totales por empresa
    if (TotalRegistros > 0) then
		insert into tmp_totales(
			tipo
			, id_empresa
			, total_facturas
			, total_beneficiarios
			, prc_beneficiarios
			, prc_facturas)
		select	2
			, id_empresa
			, SUM(a.total_facturas)
			, SUM(a.total_beneficiarios)
			, SUM(a.prc_beneficiarios)
			, SUM(a.prc_facturas)
		from	tmp_totales as a
		where	a.tipo = 1
		group	by a.id_empresa;
	end if;
    
	--Calcular total General
	if (TotalRegistros > 0) then
		insert into tmp_totales(
			tipo
			, total_facturas
			, total_beneficiarios
			, prc_beneficiarios
			, prc_facturas)
		select	3
			, SUM(a.total_facturas)
			, SUM(a.total_beneficiarios)
			, SUM(a.prc_beneficiarios)
			, SUM(a.prc_facturas)
		from	tmp_totales as a
		where	a.tipo = 1;
	end if;
    
	for valor in (SELECT tmp.tipo
                , tmp.id_empresa
				, tmp.nom_empresa
				, tmp.nom_parentesco
				, tmp.total_beneficiarios
				, tmp.total_facturas
				, tmp.prc_beneficiarios
				, tmp.prc_facturas
			FROM	tmp_totales as tmp
			group by tmp.id_empresa, tmp.tipo,tmp.nom_empresa, tmp.nom_parentesco, tmp.total_beneficiarios
				, tmp.total_facturas, tmp.prc_beneficiarios, tmp.prc_facturas
			order by tmp.id_empresa, tmp.tipo, tmp.nom_parentesco asc)
	loop
		tipo			:=	valor.tipo;
		idu_empresa		:=	valor.id_empresa;
		nom_empresa		:=	valor.nom_empresa;
		nom_parentesco		:=	valor.nom_parentesco;
		total_beneficiarios	:=	valor.total_beneficiarios;
		total_facturas		:=	valor.total_facturas;
		prc_beneficiarios	:=	valor.prc_beneficiarios;
		prc_facturas		:=	valor.prc_facturas;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_becas_por_parentesco(integer, integer, integer, integer, date, date, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_becas_por_parentesco(integer, integer, integer, integer, date, date, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_becas_por_parentesco(integer, integer, integer, integer, date, date, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_reporte_becas_por_parentesco(integer, integer, integer, integer, date, date, integer, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_reporte_becas_por_parentesco(integer, integer, integer, integer, date, date, integer, integer, integer) IS 'La función obtiene el reporte de becas pagadas por tipo de beneficiario.';