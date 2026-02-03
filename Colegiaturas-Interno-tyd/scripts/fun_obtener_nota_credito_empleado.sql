CREATE OR REPLACE FUNCTION fun_obtener_nota_credito_empleado(
IN sfecini character, 
IN sfecfin character, 
IN iempleado integer, 
OUT nempleado integer, 
OUT sempleado character, 
OUT sfolionota character, 
OUT iimportenota numeric, 
OUT iimporteaplicado numeric, 
OUT iimporteporaplicar numeric, 
OUT cdoctorelacionado character varying, 
OUT iidfactura integer)
  RETURNS SETOF record AS
$BODY$
DECLARE     
	--cFactura Varchar(100);
	--iFolioFactura integer DEFAULT 1;
	sQuery TEXT;
	valor record;	
	
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 17-08-2018
-- Descripción General:
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.
-- Servidor Desarrollo: 10.28.114.75
-- Ejemplo: 
-- ====================================================================================================
BEGIN 
	--temporal
	CREATE TEMP TABLE tmp_Notas
	(
		numemp integer,
		nomemp varchar(100),
		fol_fiscal varchar(100),
		importe_factura numeric(12,2), 
		importe_aplicado numeric(12,2), 
		importe_por_aplicar numeric(12,2),		
		fol_relacionado varchar(100),  
		idfactura integer		
	)on commit drop;

	--Importe de las notas de credito
	CREATE TEMP TABLE tmp_importes
	(
		idnota integer,
		importe numeric		
	)on commit drop;	
	--
	sQuery := 'INSERT INTO tmp_Notas (numemp, fol_fiscal,importe_factura,importe_aplicado,importe_por_aplicar,fol_relacionado,idfactura)
	select idu_empleado, fol_fiscal, importe_factura, 0.00, importe_factura-importe_pagado, fol_relacionado, idfactura		
	from 	MOV_FACTURAS_COLEGIATURAS 
	where 	idu_tipo_documento=2';

	if (iEmpleado>0) then
		sQuery := sQuery || ' and idu_empleado=' || iEmpleado;
	end if;

	if (sFecIni!='19000101') then
		sQuery := sQuery || ' and fec_registro>= ''' || sFecIni || ''' and fec_registro<= '''|| sFecFin || '''';
	end if;

	raise notice '%', sQuery;
	execute sQuery;
	--
	sQuery := 'INSERT INTO tmp_Notas (numemp, fol_fiscal,importe_factura,importe_por_aplicar,fol_relacionado,idfactura)
	select idu_empleado, fol_fiscal, importe_factura,importe_factura-importe_pagado, fol_relacionado, idfactura 
	from	HIS_facturas_colegiaturas
	where 	idu_tipo_documento=2 '; 

	if (iEmpleado>0) then
		sQuery := sQuery || ' and idu_empleado=' || iEmpleado;
	end if;

	if (sFecIni!='19000101') then
		sQuery := sQuery || ' and fec_registro>= ''' || sFecIni || ''' and fec_registro<= '''|| sFecFin || '''';
	end if;

	raise notice '%', sQuery;
	execute sQuery;

	--INSERTAR LOS IMPORTES DE LAS DIFERENTES NOTAS
	INSERT 	INTO tmp_importes (idnota, importe)
	select 	idnotacredito, sum(importe_aplicado)
	from	MOV_APLICACION_NOTAS_CREDITO
	WHERE	idnotacredito IN (SELECT distinct idfactura from Tmp_Notas)
	group 	by idnotacredito;
	
	--ACTUALIZAR EL IMPORTE APLICADO DE LAS NOTAS
	UPDATE 	tmp_Notas SET importe_aplicado =B.importe
	from 	tmp_importes B
	where	tmp_Notas.idfactura=B.idnota;

	--IMPORTE POR APLICAR
	UPDATE 	tmp_Notas SET importe_por_aplicar=importe_factura-importe_aplicado;

	--NOMBRE EMPLEADO
	UPDATE 	tmp_Notas SET nomemp=B.numemp || ' ' || B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno
	from	SAPCATALOGOEMPLEADOS B
	where 	tmp_Notas.numemp=B.numemp::int;	
	
	--
	FOR valor IN (SELECT numemp, nomemp, fol_fiscal,importe_factura,importe_aplicado, importe_por_aplicar, fol_relacionado, idfactura FROM tmp_Notas WHERE importe_por_aplicar>0) 
	loop
		nEmpleado:=valor.numemp;
		sEmpleado:=valor.nomemp; 
		sFolioNota:=valor.fol_fiscal;
		iImporteNota:=valor.importe_factura;
		iImporteAplicado:=valor.importe_aplicado;
		iImporteporAplicar:=valor.importe_por_aplicar;
		cDoctoRelacionado:=valor.fol_relacionado;
		iIdfactura:=valor.idfactura;
		return next;
	end loop;
	return;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_obtener_nota_credito_empleado(IN sfecini character, IN sfecfin character, IN iempleado integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_nota_credito_empleado(IN sfecini character, IN sfecfin character, IN iempleado integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_nota_credito_empleado(IN sfecini character, IN sfecfin character, IN iempleado integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_nota_credito_empleado(IN sfecini character, IN sfecfin character, IN iempleado integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_nota_credito_empleado(IN sfecini character, IN sfecfin character, IN iempleado integer)  IS 'La función obtiene las facturas a las que se les aplicó esa nota de crédito';
