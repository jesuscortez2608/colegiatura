CREATE OR REPLACE FUNCTION fun_obtener_facturas_para_ajustes(IN ipage integer, IN ilimit integer, IN iconexion integer, IN numempleado integer, IN cfoliofiscal character, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT dfechafactura character varying, OUT sfoliofiscal character varying, OUT iempleado integer, OUT snomempleado character varying, OUT dfecharegistro character varying, OUT nimportefactura numeric, OUT nimportepagado numeric, OUT dfechapago character varying, OUT iporcentajepagado integer, OUT ibecado integer, OUT snombecado character varying, OUT iparentesco integer, OUT snombreparentesco character varying, OUT ifactura integer, OUT iestatusfactura integer, OUT cestatusfactura character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	--DECLARACION DE VARIABLES	
	sQuery TEXT;	
	valor record;	
	sColumns VARCHAR(3000);
	iStart integer;
	iRecords integer;
	iTotalPages INTEGER; 

BEGIN
/**-- ====================================================================================================
-- Peticion: 
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: 
-- Servidor Productivo: 
-- Servidor Desarrollo: 
-- Ejemplo: SELECT * FROM FUN_OBTENER_FACTURAS_PARA_AJUSTES (1, 10, 94827443, 95194185, 'F23626F2-CADE-46D2-ACD2-80C333D775A6')
-- Ejemplo: SELECT * FROM FUN_OBTENER_FACTURAS_PARA_AJUSTES (1, 10, 94827443, 95194185, '')
-- SELECT * FROM CAT_BENEFICIARIOS_COLEGIATURAS LIMIT 10 WHERE 
-- ====================================================================================================*/
	CREATE TEMP TABLE tmp(
		FechaFactura VARCHAR,
		FolioFiscal VARCHAR(100),
		Empleado INTEGER,
		NomEmpleado VARCHAR,
		FechaRegistro VARCHAR,
		ImporteFactura NUMERIC(12,2),
		ImportePagado NUMERIC(12,2),
		FechaPago VARCHAR,
		PorcentajePagado INTEGER,
		Becado INTEGER,
		BeneficiarioExterno integer,
		NomBecado VARCHAR,
		Parentesco INTEGER,
		NombreParentesco VARCHAR,
		Factura INTEGER,
		idEstatusFactura INTEGER,
		EstatusFactura VARCHAR
	) ON COMMIT DROP;

	--TEMPORAL DE PORCENTAJES
	CREATE TEMP TABLE tmp_porcentajes(
		idfactura integer,
		porcentaje integer
	) ON COMMIT DROP;	
	
	
	--
	sQuery := 'INSERT INTO tmp (FechaFactura,FolioFiscal,Empleado,FechaRegistro,ImporteFactura,ImportePagado,FechaPago,PorcentajePagado,BeneficiarioExterno,Factura,idEstatusFactura) ';	
	sQuery := sQuery || ' SELECT to_char(fec_factura,' || ''' dd-mm-yyyy  ''),fol_fiscal,idu_empleado,to_char(fec_registro,' || ''' dd-mm-yyyy  ''),importe_factura
				,importe_pagado,to_char(fec_cierre,' || ''' dd-mm-yyyy  ''),(importe_pagado::int*100)/importe_factura::int,idu_beneficiario_externo,idfactura,idu_estatus ';
	sQuery := sQuery || ' FROM his_facturas_colegiaturas ';
	sQuery := sQuery || ' WHERE idu_estatus = 6 AND idu_beneficiario_externo = 0 AND idu_tipo_documento in (1,3) ';
	
	IF (NumEmpleado>0) THEN
		sQuery := sQuery || ' AND idu_empleado=' || numempleado;
	END IF;

	IF (cFolioFiscal!='') THEN
		sQuery := sQuery || ' AND fol_fiscal=''' || cFolioFiscal || '''';
	END IF;

	raise notice '%', sQuery;
	execute (sQuery);

	--TMP PORCENTAJE
	insert 	into tmp_porcentajes (idfactura, porcentaje)
	select 	DISTINCT idfactura, prc_descuento
	FROM 	his_detalle_facturas_colegiaturas
	WHERE 	idfactura in (select Factura from tmp);

	--PORCENTAJE PAGADO
	UPDATE	tmp set PorcentajePagado=B.porcentaje
	FROM 	tmp_porcentajes B
	where	tmp.Factura=B.idfactura;	
	
	--NOMBRE EMPLEADO
	UPDATE	tmp SET NomEmpleado=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno
	FROM	sapcatalogoempleados B
	WHERE	tmp.Empleado=B.numempn;

	--BECADO
	UPDATE 	tmp SET Becado=B.idu_beneficiario, Parentesco=B.idu_parentesco --, NomBecado='OMAR'
	FROM	his_detalle_facturas_colegiaturas B
	WHERE	tmp.Empleado=B.idu_empleado;

	--PARENTESCO
	UPDATE	tmp SET NombreParentesco=B.des_parentesco
	FROM	CAT_PARENTESCOS B
	WHERE	tmp.Parentesco=B.idu_parentesco;

	--ESTATUS FACTURA
	UPDATE	tmp SET EstatusFactura=B.nom_estatus
	FROM	CAT_ESTATUS_FACTURAS B
	WHERE	tmp.idEstatusFactura=B.idu_estatus;

	--NOMBRE BENEFICIARIO
	UPDATE 	tmp SET NomBecado=B.nom_beneficiario || ' ' || B.ape_paterno || ' ' || B.ape_materno
	FROM	CAT_BENEFICIARIOS_COLEGIATURAS B
	WHERE	tmp.Empleado = B.idu_empleado
		AND tmp.Becado=B.idu_beneficiario; 

	--SELECT * FROM CAT_BENEFICIARIOS_COLEGIATURAS WHERE idu_empleado=94827443
    
	--NOMBRE BENEFICIARIO HOJA FAMILIAR
	UPDATE	tmp SET NomBecado=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno  
	FROM	sapfamiliarhojas B
	WHERE	tmp.Empleado=B.numemp 
			AND tmp.Becado=B.keyx;	
	
	--CAMPOS QUE MOSTRARA LA CONSULTA
	sColumns := 'FechaFactura,FolioFiscal,Empleado,NomEmpleado,FechaRegistro,ImporteFactura,ImportePagado,FechaPago,PorcentajePagado,Becado,NomBecado,Parentesco,NombreParentesco,Factura,idEstatusFactura,EstatusFactura';
			
	--VARIABLES PARA PAGINADO
	iStart := (iLimit * iPage) - iLimit + 1;
	iRecords := (SELECT COUNT(*) FROM tmp);
	iTotalPages := ceiling(iRecords / (iLimit * 1.0));

	--t.conexion= ' || iConexion || ' and 
	sQuery := '
	select ' || CAST(iRecords AS VARCHAR) || ' AS records
	, ' || CAST(iPage AS VARCHAR) || ' AS page
	, ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
	, id
	, ' || sColumns || '
	from (
	SELECT ROW_NUMBER() OVER (ORDER BY FechaRegistro DESC) AS id, ' || sColumns || '
	FROM tmp
	) AS t
	WHERE t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iLimit) - 1) AS VARCHAR) || ' ';
		
	--RETORNA VALOR DE UNA CADENA DE CONSULTA
	FOR valor IN EXECUTE (sQuery)
		LOOP
			records:=valor.records;
			page:=valor.page;
			pages:=valor.pages;
			id:=valor.id;
			dFechaFactura:=valor.FechaFactura;
			sFolioFiscal:=valor.FolioFiscal;
			iEmpleado:=valor.Empleado;
			sNomEmpleado:=valor.NomEmpleado;
			dFechaRegistro:=valor.FechaRegistro;
			nimportefactura:=valor.ImporteFactura;
			nImportePagado:=valor.ImportePagado;
			dFechaPago:=valor.FechaPago;
			iPorcentajePagado:=valor.PorcentajePagado;
			iBecado:=valor.Becado;
			sNomBecado:=valor.NomBecado;
			iParentesco:=valor.Parentesco;
			sNombreParentesco:=valor.NombreParentesco;
			iFactura:=valor.Factura;
			iEstatusFactura:=valor.idEstatusFactura;
			cEstatusFactura:=valor.EstatusFactura;
		RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_para_ajustes(IN ipage integer, IN ilimit integer, IN iconexion integer, IN numempleado integer, IN cfoliofiscal character) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_para_ajustes(IN ipage integer, IN ilimit integer, IN iconexion integer, IN numempleado integer, IN cfoliofiscal character) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_para_ajustes(IN ipage integer, IN ilimit integer, IN iconexion integer, IN numempleado integer, IN cfoliofiscal character) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_para_ajustes(IN ipage integer, IN ilimit integer, IN iconexion integer, IN numempleado integer, IN cfoliofiscal character) TO postgres;
COMMENT ON FUNCTION fun_obtener_facturas_para_ajustes(IN ipage integer, IN ilimit integer, IN iconexion integer, IN numempleado integer, IN cfoliofiscal character) IS 'La función obtiene facturas para realizar ajustes.';