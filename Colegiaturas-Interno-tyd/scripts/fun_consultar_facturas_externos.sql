CREATE OR REPLACE FUNCTION fun_consultar_facturas_externos(
IN irowsperpage integer
, IN icurrentpage integer
, IN sordercolumn character varying
, IN sordertype character varying
, IN scolumns character varying
, IN cfoliofiscal character varying
, IN iusuarioexterno integer
, IN iopcrangofechas integer
, IN dfechainicial date
, IN dfechafinal date
, IN iestatus integer
, OUT records integer
, OUT page integer
, OUT pages integer
, OUT id integer
, OUT dfechafactura character varying
, OUT cfolfiscal character varying
, OUT nimportefactura numeric
, OUT iprcdescuento integer
, OUT nimportecalculado numeric
, OUT ibeneficiarioexterno integer
, OUT cnombeneficiarioexterno character varying
, OUT iempleadocaptura integer
, OUT cnombrecaptura character varying
, OUT dfecharegistro character varying)
  RETURNS SETOF record AS
$BODY$
 DECLARE
 /*
-- ===================================================
-- Peticion			: 16559.1
-- Autor			: Rafael Ramos Gutiérrez 98439677
-- Fecha			: 09/05/2018
-- Descripción General		: Obtiene el listado de facturas de externos registradas por el numero de usuario
-- Ruta Tortoise		:
-- Sistema			: Colegiaturas
-- Servidor Productivo		: 10.44.2.183
-- Servidor Desarrollo		: 10.44.114.75
-- Base de Datos		: personal
-- Tablas Utilizadas		: 
					mov_facturas_colegiaturas
					his_facturas_colegiaturas
					cat_beneficiarios_externos
					sapcatalogoempleados
-- Ejemplo			: 
				SELECT records
				, page
				, pages
				, id
				, dFechaFactura
				, cFolFiscal
				, nImporteFactura
				, iPrcDescuento
				, nImporteCalculado
				, iBeneficiarioExterno
				, cNomBeneficiarioExterno
				, iEmpleadoCaptura
				, cNombreCaptura
				, dFechaRegistro
				FROM fun_consultar_facturas_externos(
					10
					, 1
					, 'dfechafactura'
					, 'desc'
					, 'dfechafactura, cfolfiscal, nimportefactura, iprcdescuento, nimportecalculado, ibeneficiarioexterno, cnombeneficiarioexterno, iempleadocaptura, cnombrecaptura, dfecharegistro'
					, ''
					, 95194185
					, 0
					, '19000101'::DATE
					, '19000101'::DATE
					, 0)
-- ===================================================
*/
	/* VARIABLES DE PAGINADO */
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;

	valor record;
	sQuery text;
	sConsulta VARCHAR(3000);
begin
	/* Control de las variables de paginado */
	IF iRowsPerPage = -1 THEN
        iRowsPerPage := NULL;
	END IF;
	if iCurrentPage = -1 THEN
        iCurrentPage := NULL;
	END IF;

	create local temp table tmp_facturas_externos(
		records integer
		, page integer
		, pages integer
		, id integer
		, dFechaFactura character varying(10)			
		, cFolFiscal character varying(100)			
		, nImporteFactura numeric(12,2)				
		, iPrcDescuento integer					
		, nImporteCalculado numeric(12,2)			
		, iBeneficiarioExterno integer				
		, cNomBeneficiarioExterno character varying		
		, iEmpleadoCaptura integer				
		, cNombreCaptura character varying
		, dFechaRegistro character varying
	) on commit drop;

	if (iestatus = 0) then
		sQuery := ('INSERT INTO tmp_facturas_externos (dFechaFactura, cFolFiscal
				, nImporteFactura, nImporteCalculado, iBeneficiarioExterno, iEmpleadoCaptura, dFechaRegistro)
			SELECT to_char(fec_factura,''dd-mm-yyyy''), fol_fiscal, importe_factura, importe_calculado, idu_beneficiario_externo
				,idu_empleado_registro, to_char(fec_registro, ''dd-mm-yyyy'')
			FROM	mov_facturas_colegiaturas
			WHERE	idu_beneficiario_externo != 0');
		IF (iUsuarioExterno = 0 and cFolioFiscal != '') then
			sQuery:= sQuery ||' AND fol_fiscal = '''|| cFolioFiscal || '''';
		else
			sQuery:= sQuery ||' AND idu_empleado= ' || iUsuarioExterno;
		end if;
		if iEstatus != -1 then
			sQuery := sQuery ||' AND idu_estatus='||iEstatus;
		end if;
		
		if iOpcRangoFechas = 1 then
			sQuery := sQuery ||' AND fec_registro::DATE BETWEEN '''|| dFechaInicial ||'''::DATE AND ''' || dFechaFinal || '''::DATE ';
		end if;

		 raise notice '%', sQuery;
		execute sQuery;
	elsif (iestatus = 3) then
		sQuery := ('INSERT INTO tmp_facturas_externos (dFechaFactura, cFolFiscal
				, nImporteFactura, nImporteCalculado, iBeneficiarioExterno, iEmpleadoCaptura, dFechaRegistro)
			SELECT to_char(fec_factura,''dd-mm-yyyy''), fol_fiscal, importe_factura, importe_calculado, idu_beneficiario_externo
				,idu_empleado_registro, to_char(fec_registro, ''dd-mm-yyyy'')
			FROM	mov_facturas_colegiaturas
			WHERE	idu_beneficiario_externo != 0');
		IF (iUsuarioExterno = 0 and cFolioFiscal != '') then
			sQuery:= sQuery ||' AND fol_fiscal = '''|| cFolioFiscal || '''';
		else
			sQuery:= sQuery ||' AND idu_empleado= ' || iUsuarioExterno;
		end if;
		if iEstatus != -1 then
			sQuery := sQuery ||' AND idu_estatus='||iEstatus;
		end if;
		
		if iOpcRangoFechas = 1 then
			sQuery := sQuery ||' AND fec_registro::DATE BETWEEN '''|| dFechaInicial ||'''::DATE AND ''' || dFechaFinal || '''::DATE ';
		end if;

		 raise notice '%', sQuery;
		execute sQuery;
		
		sQuery := ('INSERT INTO tmp_facturas_externos (dFechaFactura, cFolFiscal
				, nImporteFactura, nImporteCalculado, iBeneficiarioExterno, iEmpleadoCaptura, dFechaRegistro)
			SELECT to_char(fec_factura,''dd-mm-yyyy''), fol_fiscal, importe_factura, importe_calculado, idu_beneficiario_externo
				,idu_empleado_registro, to_char(fec_registro, ''dd-mm-yyyy'')
			FROM	his_facturas_colegiaturas
			WHERE	idu_beneficiario_externo != 0');
		if (iUsuarioExterno = 0 and cFolioFiscal != '') then
			sQuery:= sQuery || ' AND fol_fiscal = ''' || cFolioFiscal || '''';
		else
			sQuery:= sQuery || ' AND idu_empleado = ' || iUsuarioExterno;
		end if;
		if iEstatus != -1 then
			sQuery := sQuery ||' AND idu_estatus='||iEstatus;
		end if;
		
		if iOpcRangoFechas = 1 then
			sQuery := sQuery ||' AND fec_registro::DATE BETWEEN '''|| dFechaInicial ||'''::DATE AND ''' || dFechaFinal || '''::DATE ';
		end if;
		execute sQuery;
	elsif (iestatus = 6) then
		sQuery := ('INSERT INTO tmp_facturas_externos (dFechaFactura, cFolFiscal
				, nImporteFactura, nImporteCalculado, iBeneficiarioExterno, iEmpleadoCaptura, dFechaRegistro)
			SELECT to_char(fec_factura,''dd-mm-yyyy''), fol_fiscal, importe_factura, importe_calculado, idu_beneficiario_externo
				,idu_empleado_registro, to_char(fec_registro, ''dd-mm-yyyy'')
			FROM	his_facturas_colegiaturas
			WHERE	idu_beneficiario_externo != 0');
		if (iUsuarioExterno = 0 and cFolioFiscal != '') then
			sQuery:= sQuery || ' AND fol_fiscal = ''' || cFolioFiscal || '''';
		else
			sQuery:= sQuery || ' AND idu_empleado = ' || iUsuarioExterno;
		end if;
		if iEstatus != -1 then
			sQuery := sQuery ||' AND idu_estatus='||iEstatus;
		end if;
		
		if iOpcRangoFechas = 1 then
			sQuery := sQuery ||' AND fec_registro::DATE BETWEEN '''|| dFechaInicial ||'''::DATE AND ''' || dFechaFinal || '''::DATE ';
		end if;
		execute sQuery;	
	end if;

	update	tmp_facturas_externos
	set	iPrcDescuento = a.prc_descuento
		, cNomBeneficiarioExterno = a.nom_empleado
	from	cat_beneficiarios_externos a
	where	tmp_facturas_externos.iBeneficiarioExterno = a.idu_beneficiario;

	update	tmp_facturas_externos
	set	cNombreCaptura = a.nombre || ' ' || a.apellidopaterno || ' ' || a.apellidomaterno
	from	sapcatalogoempleados a
	where	tmp_facturas_externos.iEmpleadoCaptura = a.numempn;


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

	for valor in execute (sConsulta)
	loop
		records := valor.records;
		page	:= valor.page;
		pages	:= valor.pages;
		id	:= valor.id;
		dFechaFactura	:= valor.dFechaFactura;
		cFolFiscal	:= valor.cFolFiscal;
		nImporteFactura	:= valor.nImporteFactura;
		iPrcDescuento	:= valor.iPrcDescuento;
		nImporteCalculado	:= valor.nImporteCalculado;
		iBeneficiarioExterno	:= valor.iBeneficiarioExterno;
		cNomBeneficiarioExterno	:= valor.cNomBeneficiarioExterno;
		iEmpleadoCaptura	:= valor.iEmpleadoCaptura;
		cNombreCaptura	:= valor.cNombreCaptura;
		dFechaRegistro	:= valor.dFechaRegistro;
		return next;
	end loop;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_consultar_facturas_externos(integer, integer, character varying, character varying, character varying, character varying, integer, integer, date, date, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consultar_facturas_externos(integer, integer, character varying, character varying, character varying, character varying, integer, integer, date, date, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_consultar_facturas_externos(integer, integer, character varying, character varying, character varying, character varying, integer, integer, date, date, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_consultar_facturas_externos(integer, integer, character varying, character varying, character varying, character varying, integer, integer, date, date, integer) TO postgres;
COMMENT ON FUNCTION fun_consultar_facturas_externos(integer, integer, character varying, character varying, character varying, character varying, integer, integer, date, date, integer) IS 'La función obtiene un listado de las facturas de externos, subidas por un colaborador o usuario autorizado para externos.'; 