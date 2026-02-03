CREATE OR REPLACE FUNCTION fun_obtener_facturas_externos_seguimiento(IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, IN iusuarioexterno integer, IN iiduempleadoexterno integer, IN snombeneficiarioexterno character varying, IN cfoliofiscal character varying, IN iopcrangofechas integer, IN dfechainicial date, IN dfechafinal date, IN iduestatus integer, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT dfechafactura character varying, OUT cfolfiscal character varying, OUT nimportefactura numeric, OUT iprcdescuento integer, OUT nimportecalculado numeric, OUT ibeneficiarioexterno integer, OUT cnombeneficiarioexterno character varying, OUT dfecharegistro character varying, OUT iestatus integer, OUT snomestatus character varying, OUT dfechamarcoestatus character varying, OUT ifactura integer, OUT sobservaciones text)
  RETURNS SETOF record AS
$BODY$
 DECLARE
 /*
-- ===================================================
-- Peticion				: 16559.1
-- Autor				: Rafael Ramos Gutiérrez 98439677
-- Fecha				: 09/05/2018
-- Descripción General	: Obtiene el listado de facturas de externos registradas por el numero de usuario
-- Ruta Tortoise		:
-- Sistema				: Colegiaturas
-- Servidor Productivo	: 10.44.2.183
-- Servidor Desarrollo	: 10.44.114.75
-- Base de Datos		: personal
-- Tablas Utilizadas	: 
					mov_facturas_colegiaturas
					his_facturas_colegiaturas
					cat_beneficiarios_externos
					sapcatalogoempleados
-- Ejemplo			: 
				SELECT *
					FROM fun_obtener_facturas_externos_seguimiento(10::integer
					    , 1::integer
					    , 'dfecharegistro'::character varying
					    , 'asc'::character varying
					    , 'dfechafactura,cfolfiscal,nimportefactura,iprcdescuento,nimportecalculado,ibeneficiarioexterno,cnombeneficiarioexterno,dfecharegistro,iestatus,snomestatus,dfechamarcoestatus,ifactura,sobservaciones'::character varying
					    , 95194185::integer
					    , 0::integer
					    , 'FER'::character varying
					    , ''::character varying
					    , 0::integer
					    , '2018-01-01'::date
					    , '2018-05-18'::date
					    , 3::integer)
-- ===================================================


*/    
	/* VARIABLES DE PAGINADO */
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;

	valor record;
	sQuery text;
	sConsulta VARCHAR(3000);
	iIduBeneficiario INT DEFAULT(0);
begin
	/* Control de las variables de paginado */
	IF iRowsPerPage = -1 THEN
        iRowsPerPage := NULL;
	END IF;
	if iCurrentPage = -1 THEN
        iCurrentPage := NULL;
	END IF;

	IF iiduempleadoexterno > 0 THEN
        iIduBeneficiario := (SELECT idu_beneficiario FROM cat_beneficiarios_externos WHERE idu_empleado = iiduempleadoexterno LIMIT 1);
	END IF;

	create local temp table tmp_facturas_externos(
		records integer
		, page integer
		, pages integer
		, id integer
		, dFechaFactura character varying(10)
		--, dFechaFactura date
		, cFolFiscal character varying(100)
		, nImporteFactura numeric(12,2)
		, iPrcDescuento integer
		, nImporteCalculado numeric(12,2)
		, iBeneficiarioExterno integer
		, iEmpleadoExterno integer
		, cNomBeneficiarioExterno character varying(100)
		, dFechaRegistro character varying(10)
		, iEstatus integer
		, sNomEstatus character varying(50)
		, dFechaMarcoEstatus character varying(10)
		, ifactura integer
		, sObservaciones text
	) on commit drop;

	--Tabla mov_facturas_colegiaturas
	sQuery := '
	insert into	tmp_facturas_externos(
				dFechaFactura
				, cFolFiscal
				, nImporteFactura
				, iPrcDescuento
				, nImporteCalculado
				, iBeneficiarioExterno
				, iEmpleadoExterno
				, cNomBeneficiarioExterno
				, dFechaRegistro
				, iEstatus
				, dFechaMarcoEstatus
				, ifactura
				, sObservaciones)
	select	
			  to_char(F.fec_factura, ''dd-mm-yyyy'')
			, F.fol_fiscal
			, F.importe_factura
			, E.prc_descuento
			, F.importe_calculado
			, F.idu_beneficiario_externo
			, E.idu_empleado
			, E.nom_empleado
			, to_char(F.fec_registro, ''dd-mm-yyyy'')
			, F.idu_estatus
			, to_char(F.fec_marco_estatus, ''dd-mm-yyyy'')
			, F.idfactura
			, F.des_observaciones
			
	from		mov_facturas_colegiaturas F inner join cat_beneficiarios_externos E 
			on F.idu_beneficiario_externo = E.idu_beneficiario
	where		F.idu_beneficiario_externo != 0 and F.idu_empleado = ' || CAST(iUsuarioExterno AS VARCHAR) || ' ';

    if cfoliofiscal != '' then
	sQuery := sQuery || 'and F.fol_fiscal LIKE ''%' || trim(cfoliofiscal) || '%'' ';
    end if;
    IF iIduBeneficiario > 0 THEN
        sQuery := sQuery || ' and F.idu_beneficiario_externo = ' || CAST(iIduBeneficiario AS VARCHAR) || ' ';
    END IF;
    
    IF iduestatus > -1 THEN
        sQuery := sQuery || ' and F.idu_estatus = ' || CAST(iduestatus AS VARCHAR) || ' ';
    END IF;
    
    if sNomBeneficiarioExterno != '' then
        sQuery := sQuery || ' and E.nom_empleado LIKE ''%' || TRIM(sNomBeneficiarioExterno) || '%'' ';
    end if;

    if iOpcRangoFechas = 1 then
        sQuery := sQuery || ' and F.fec_registro::DATE BETWEEN ''' || CAST(dfechainicial AS VARCHAR) || '''::DATE AND ''' || CAST(dfechafinal AS VARCHAR) || '''::DATE ';
    END IF;
    
    --RAISE NOTICE '%', sQuery;
    EXECUTE (sQuery);
    
	--Tabla His_facturas_colegiaturas
	sQuery := '
	insert into	tmp_facturas_externos(
				dFechaFactura
				, cFolFiscal
				, nImporteFactura
				, iPrcDescuento
				, nImporteCalculado
				, iBeneficiarioExterno
				, iEmpleadoExterno
				, cNomBeneficiarioExterno
				, dFechaRegistro
				, iEstatus
				, dFechaMarcoEstatus
				, ifactura
				, sObservaciones)
				
	select		
   			  to_char(F.fec_factura, ''dd-mm-yyyy'')
			, F.fol_fiscal
			, F.importe_factura
			, E.prc_descuento
			, F.importe_calculado
			, F.idu_beneficiario_externo
			, E.idu_empleado
			, E.nom_empleado
			, to_char(F.fec_registro, ''dd-mm-yyyy'')
			, F.idu_estatus
			, to_char(F.fec_marco_estatus, ''dd-mm-yyyy'')
			, F.idfactura
			, F.des_observaciones

	from		his_facturas_colegiaturas F inner join cat_beneficiarios_externos E
			on F.idu_beneficiario_externo = E.idu_beneficiario
	where		F.idu_beneficiario_externo != 0 and F.idu_empleado = ' || CAST(iUsuarioExterno AS VARCHAR) || ' ';
    
    if cfoliofiscal != '' then
	sQuery := sQuery || 'and F.fol_fiscal LIKE ''%' || trim(cfoliofiscal) || '%'' ';
    end if;
    
    IF iIduBeneficiario > 0 THEN
        sQuery := sQuery || ' and F.idu_beneficiario_externo = ' || CAST(iIduBeneficiario AS VARCHAR) || ' ';
    END IF;
    
    IF iduestatus > -1 THEN
        sQuery := sQuery || ' and F.idu_estatus = ' || CAST(iduestatus AS VARCHAR) || ' ';
    END IF;
    
    if sNomBeneficiarioExterno != '' then
        sQuery := sQuery || ' and E.nom_empleado LIKE ''%' || TRIM(sNomBeneficiarioExterno) || '%'' ';
    end if;
    
    if iOpcRangoFechas = 1 then
        sQuery := sQuery || ' and F.fec_registro::DATE BETWEEN ''' || CAST(dfechainicial AS VARCHAR) || '''::DATE AND ''' || CAST(dfechafinal AS VARCHAR) || '''::DATE ';
    END IF;
    
    EXECUTE (sQuery);
    
	--Actualizar el nombre del estatus de la factura de la tabla temporal
	update	tmp_facturas_externos 
	set	sNomEstatus = A.nom_estatus
	from	cat_estatus_facturas A
	where	tmp_facturas_externos.iEstatus = A.idu_estatus;
    
	iRecords := (select COUNT(*) from tmp_facturas_externos);
	if(iRowsPerPage is not null and iCurrentPage is not null) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage +1;
		iRecords := (select COUNT(*) from tmp_facturas_externos);
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));

		sConsulta := '
			SELECT ' || cast(iRecords as varchar) || ' AS records
			     , ' || cast(iCurrentPage as varchar) || ' AS page
			     , ' || cast(iTotalPages as varchar) || ' AS pages
			     , id
			     , ' || sColumns || '
			FROM (
				SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM tmp_facturas_externos
				) AS t
			WHERE t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' ';
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' as records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_facturas_externos ';
	end if;

	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;
    
    --RAISE NOTICE '%', sConsulta;
    
	for valor in execute (sConsulta)
	loop
		records 	:= valor.records;
		page		:= valor.page;
		pages		:= valor.pages;
		id			:= valor.id;
		dFechaFactura	:= valor.dFechaFactura;
		cFolFiscal	:= valor.cFolFiscal;
		nImporteFactura	:= valor.nImporteFactura;
		iPrcDescuento	:= valor.iPrcDescuento;
		nImporteCalculado	:= valor.nImporteCalculado;
		iBeneficiarioExterno	:= valor.iBeneficiarioExterno;
		cNomBeneficiarioExterno	:= valor.cNomBeneficiarioExterno;
		dFechaRegistro	:= valor.dFechaRegistro;
		iEstatus	:= valor.iEstatus;
		sNomEstatus	:= valor.sNomEstatus;
		dFechaMarcoEstatus	:= valor.dFechaMarcoEstatus;
		ifactura	:= valor.ifactura;
		sObservaciones	:= valor.sObservaciones;
		return next;
	end loop;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_externos_seguimiento(integer, integer, character varying, character varying, character varying, integer, integer, character varying, character varying, integer, date, date, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_externos_seguimiento(integer, integer, character varying, character varying, character varying, integer, integer, character varying, character varying, integer, date, date, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_externos_seguimiento(integer, integer, character varying, character varying, character varying, integer, integer, character varying, character varying, integer, date, date, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_externos_seguimiento(integer, integer, character varying, character varying, character varying, integer, integer, character varying, character varying, integer, date, date, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_facturas_externos_seguimiento(integer, integer, character varying, character varying, character varying, integer, integer, character varying, character varying, integer, date, date, integer) IS 'La función obtiene un listado de las facturas de externos, subidas por un colaborador o usuario autorizado para externos.';

  