DROP FUNCTION IF EXISTS fun_obtener_facturas_externos(integer, integer, integer, character, character, character, integer, integer);

CREATE OR REPLACE FUNCTION fun_obtener_facturas_externos(IN ipage integer, IN ilimit integer, IN iconexion integer, IN corder character, IN cordertype character, IN scolumns character, IN ibeneficiarioexterno integer, IN iestatus integer, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT dfechafactura date, OUT cfolfiscal character, OUT nimportefactura numeric, OUT nporcentajedescuento integer, OUT nimportecalculado numeric, OUT iidubeneficiario integer, OUT cnombeneficiario character, OUT iidfactura integer)
  RETURNS SETOF record AS
$BODY$
DECLARE
/** ====================================================================================================
-- Peticion: 
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 15-05-2018
-- Descripción General: Autoriza facturas para Externos
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas 
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75 
-- Ejemplo: 
SELECT * 
FROM FUN_OBTENER_FACTURAS_EXTERNOS (1, 10, 94827443, 'FechaFactura', 'asc' , 'FechaFactura,FolFiscal,ImporteFactura,PorcentajeDescuento,ImporteCalculado,idu_beneficiario_externo,NomBeneficiario,IdFactura,Conexion', 0,0)
-- ====================================================================================================
 */    
	sQuery TEXT;	
	valor record;	
	sColumns VARCHAR(3000);
	iStart integer;
	iRecords integer;
	iTotalPages INTEGER; 

BEGIN
	--CODIGO
	
	--TABLA TEMPORAL
	--CREATE TEMP TABLE Datos(
	CREATE local temp table Datos(
		FechaFactura DATE,
		FolFiscal VARCHAR(100),		
		ImporteFactura NUMERIC(12,2),
		PorcentajeDescuento INTEGER,
		ImporteCalculado NUMERIC(12,2),
		idu_beneficiario_externo INTEGER, 
		NomBeneficiario VARCHAR(150),
		IdFactura INTEGER,
		Conexion INTEGER		
	) ON COMMIT DROP;

	sQuery := ' INSERT INTO Datos (FechaFactura, FolFiscal, ImporteFactura, idu_beneficiario_externo, IdFactura, Conexion) ';
	sQuery := sQuery || ' SELECT fec_factura, fol_fiscal, importe_factura, idu_beneficiario_externo, idFactura, ' || iconexion || '';
	sQuery := sQuery || ' FROM MOV_FACTURAS_COLEGIATURAS ';
	sQuery := sQuery || ' WHERE idu_estatus=' || iEstatus;	

	IF (ibeneficiarioexterno=0) THEN
		sQuery := sQuery || ' AND idu_beneficiario_externo>0';	
	END IF;
	raise notice '%', sQuery;

	EXECUTE (sQuery);
	
	--BENEFICIARIOS	
	UPDATE 	Datos SET PorcentajeDescuento=B.prc_descuento, NomBeneficiario=CASE WHEN B.idu_empleado>0 THEN B.idu_empleado || ' ' || B.nom_empleado ELSE B.nom_empleado END 
	FROM 	cat_beneficiarios_externos B
	WHERE 	Datos.idu_beneficiario_externo=B.idu_beneficiario;
		
	--PAGINADO
	iStart := (iLimit * iPage) - iLimit + 1;
	iRecords := (SELECT COUNT(*) FROM Datos);
	iTotalPages := ceiling(iRecords / (iLimit * 1.0));

	--COLUMNAS  
	sColumns := 'FechaFactura,FolFiscal,ImporteFactura,PorcentajeDescuento,ImporteCalculado,idu_beneficiario_externo,NomBeneficiario,IdFactura,Conexion';

	--
	sQuery := '
	    SELECT ' || CAST(iRecords AS VARCHAR) || ' AS records
		, ' || CAST(iPage AS VARCHAR) || ' AS page
		, ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		, id
		, ' || sColumns || '
	    FROM (
		    SELECT ROW_NUMBER() OVER (ORDER BY ' || cOrder  || ' ASC) AS id, ' || sColumns || '
		    FROM Datos
		    ) AS t
	    WHERE  t.Conexion= ' || iConexion || ' and t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iLimit) - 1) AS VARCHAR) || ' ';
	raise notice '%', sQuery;
	
	
	--RETORNA VALOR DE UNA CADENA DE CONSULTA
	FOR valor IN EXECUTE (sQuery)
		LOOP
			records:=valor.records;
			page:=valor.page;
			pages:=valor.pages;
			id:=valor.id;
			dFechaFactura:=valor.FechaFactura;			
			cFolFiscal:=valor.FolFiscal;
			nImporteFactura:=valor.ImporteFactura;
			nPorcentajeDescuento:=valor.PorcentajeDescuento;
			nImporteCalculado:=valor.ImporteCalculado;
			iIduBeneficiario:=valor.idu_beneficiario_externo;
			cNomBeneficiario:=valor.NomBeneficiario;
			iIdFactura:=valor.IdFactura;
		RETURN NEXT;
		END LOOP;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_externos(integer, integer, integer, character, character, character, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_externos(integer, integer, integer, character, character, character, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_externos(integer, integer, integer, character, character, character, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_facturas_externos(integer, integer, integer, character, character, character, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_facturas_externos(integer, integer, integer, character, character, character, integer, integer) IS 'La función busca un folio fiscal en las tablas de colegiaturas.';