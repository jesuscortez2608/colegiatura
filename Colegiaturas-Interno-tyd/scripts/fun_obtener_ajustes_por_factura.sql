CREATE OR REPLACE FUNCTION fun_obtener_ajustes_por_factura(IN ifactura integer, OUT iidajuste integer, OUT iidfactura integer, OUT nimportefactura numeric, OUT nimportepagado numeric, OUT ipctajuste integer, OUT nimporteajuste numeric, OUT sobservaciones text, OUT iusuariotraspaso integer, OUT snomusuariotraspaso character varying, OUT dfechatraspaso character varying, OUT iusuarioregistro integer, OUT snomusuarioregistro character varying, OUT dfecharegistro character varying, OUT iusuariocierre integer, OUT snomusuariocierre character varying, OUT dfechacierre character varying)
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
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 23/05/2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: SELECT * FROM fun_obtener_ajustes_por_factura (22)
-- ====================================================================================================*/
	
	CREATE TEMP TABLE tmp(
		 IdAjuste INTEGER,
		 IdFactura INTEGER,
		 ImporteFactura NUMERIC(12,2),
		 ImportePagado NUMERIC(12,2),
		 PctAjuste INTEGER,
		 ImporteAjuste NUMERIC(12,2),
		 Observaciones TEXT,
		 UsuarioTraspaso INTEGER,
		 NomUsuarioTraspaso VARCHAR,
		 FechaTraspaso VARCHAR,
		 UsuarioRegistro INTEGER,
		 NomUsuarioRegistro VARCHAR,
		 FechaRegistro VARCHAR, 
		 UsuarioCierre INTEGER,
		 NomUsuarioCierre VARCHAR,
		 FechaCierre VARCHAR
	) ON COMMIT DROP;

	--
	--SELECT * FROM mov_ajustes_facturas_colegiaturas LIMIT 1
	--SELECT * FROM his_ajustes_facturas_colegiaturas LIMIT 1
	--DELETE FROM his_ajustes_facturas_colegiaturas WHERE idu_ajuste=42

	--HISTORICO 
	INSERT 	INTO tmp (IdAjuste,IdFactura,ImporteFactura,ImportePagado,PctAjuste,ImporteAjuste,Observaciones,UsuarioTraspaso,FechaTraspaso,UsuarioRegistro,FechaRegistro,UsuarioCierre, FechaCierre)
	SELECT 	idu_ajuste,idfactura,importe_factura,importe_pagado,pct_ajuste,(importe_factura/100)*pct_ajuste,des_observaciones,idu_usuario_traspaso,to_char(fec_traspaso,'dd-mm-yyyy'),idu_usuario_registro,to_char(fec_registro,'dd-mm-yyyy'),idu_usuario_cierre,to_char(fec_cierre,'dd-mm-yyyy')
	FROM	HIS_AJUSTES_FACTURAS_COLEGIATURAS
	WHERE	idfactura=ifactura;

	--AJUSTE 
	INSERT 	INTO tmp (IdAjuste,IdFactura,ImporteFactura,ImportePagado,PctAjuste,ImporteAjuste,Observaciones,UsuarioTraspaso,FechaTraspaso,UsuarioRegistro,FechaRegistro,UsuarioCierre)
	SELECT 	idu_ajuste,idfactura,importe_factura,importe_pagado,pct_ajuste,(importe_factura/100)*pct_ajuste,des_observaciones,idu_usuario_traspaso,to_char(fec_traspaso,'dd-mm-yyyy'),idu_usuario_registro,to_char(fec_registro,'dd-mm-yyyy'),0
	FROM	MOV_AJUSTES_FACTURAS_COLEGIATURAS
	WHERE	idfactura=ifactura;
	
	--CIERRE
	/*
	UPDATE	tmp SET UsuarioCierre=idu_usuario_cierre, FechaCierre=fec_cierre
	FROM	his_ajustes_facturas_colegiaturas B
	WHERE	tmp.IdFactura=B.idfactura;
	*/

	--NOMBRE USUARIO TRASPASO
	UPDATE 	tmp SET NomUsuarioTraspaso=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno
	FROM 	sapcatalogoempleados B
	WHERE	tmp.UsuarioTraspaso=B.numempn;

	--NOMBRE USUARIO TRASPASO
	UPDATE 	tmp SET NomUsuarioRegistro=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno
	FROM 	sapcatalogoempleados B
	WHERE	tmp.UsuarioRegistro=B.numempn;

	--NOMBRE USUARIO CIERRE
	UPDATE 	tmp SET NomUsuarioCierre=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno
	FROM 	sapcatalogoempleados B
	WHERE	tmp.UsuarioCierre=B.numempn;
			
			
	--RETORNA VALOR DE UNA CADENA DE CONSULTA
	FOR valor IN (	SELECT 	IdAjuste,IdFactura,ImporteFactura,ImportePagado,PctAjuste,ImporteAjuste,Observaciones,UsuarioTraspaso,NomUsuarioTraspaso,FechaTraspaso,UsuarioRegistro,
				NomUsuarioRegistro,FechaRegistro,UsuarioCierre,NomUsuarioCierre,FechaCierre 
			FROM 	tmp ORDER BY IdAjuste)
		LOOP
			 iIDAjuste:=valor.IdAjuste;
			 iIDFactura:=valor.IdFactura;
			 nImporteFactura:=valor.ImporteFactura;
			 nImportePagado:=valor.ImportePagado;
			 iPctAjuste:=valor.PctAjuste;
			 nImporteAjuste:=valor.ImporteAjuste;
			 sObservaciones:=valor.Observaciones;
			 iUsuarioTraspaso:=valor.UsuarioTraspaso;
			 snomusuariotraspaso:=valor.NomUsuarioTraspaso;
			 dFechaTraspaso:=valor.FechaTraspaso;
			 iUsuarioRegistro:=valor.UsuarioRegistro;
			 snomusuarioregistro:=valor.NomUsuarioRegistro;
			 dFechaRegistro:=valor.FechaRegistro;
			 iUsuarioCierre:=valor.UsuarioCierre;
			 snomusuariocierre:=valor.NomUsuarioCierre;
			 dFechaCierre:=valor.FechaCierre;
		RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_ajustes_por_factura(IN ifactura integer)   TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_ajustes_por_factura(IN ifactura integer)   TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_ajustes_por_factura(IN ifactura integer)   TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_ajustes_por_factura(IN ifactura integer)   TO postgres;
COMMENT ON FUNCTION fun_obtener_ajustes_por_factura(IN ifactura integer)  IS 'La función obtiene los ajustes que se la han hecho a una factura pagada';  
