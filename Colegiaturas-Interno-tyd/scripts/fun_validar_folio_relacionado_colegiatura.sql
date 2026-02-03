DROP FUNCTION IF EXISTS fun_validar_folio_relacionado_colegiatura(character varying, character varying);

CREATE OR REPLACE FUNCTION fun_validar_folio_relacionado_colegiatura(
in sfoliofac character varying
, IN rfcemisor character varying
, OUT existeFolio INTEGER
, OUT EstatusFolio INTEGER
, OUT iCTL_FACTURA INTEGER
)
  RETURNS SETOF RECORD AS
$BODY$
DECLARE 
    valor record;
    iEncontrado SMALLINT = 0;
    iStatus SMALLINT = -1;
    iTablaANT SMALLINT = 0;
 /*
	     No. petición APS               : 18292
	     Fecha                          : 28/02/2018
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.28.114.75
	     Servidor de produccion         : 10.44.2.183 
	     Descripción del funcionamiento : 
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura 
	     Ejemplo                        : 
		select * from fun_validar_folio_relacionado_colegiatura('56E51210-FF37-70D8-A29M-0903L90C6B59', 'CLE810525EA1'); 
		select * from fun_validar_folio_relacionado_colegiatura('135579F1-C715-4703-A52D-04868D65E189', 'EIS430714ER6'); 
		select * from fun_validar_folio_relacionado_colegiatura('BB1490E5-6E73-451D-A6EC-2D8600455EEE', 'CVC920220E23'); 
	*/
BEGIN
	CREATE TEMPORARY TABLE tmp_Resultado 
	(
		iExiste INTEGER NOT NULL DEFAULT 0
		, iEstatus INTEGER NOT NULL DEFAULT -1
		, iCtl INTEGER NOT NULL DEFAULT 0
	) ON COMMIT DROP;
	
	if exists(select 1 from CTL_FACTURAS_EMPLEADOS where nom_rfc_empresa = rfcemisor and UPPER(TRIM(idu_foliofiscal))=UPPER(TRIM(sFolioFac)) ) then
		iEncontrado := 1;
		iStatus := (SELECT idu_estatus_factura FROM CTL_FACTURAS_EMPLEADOS where UPPER(TRIM(idu_foliofiscal))=UPPER(TRIM(sFolioFac)) AND UPPER(TRIM(nom_rfc_empresa)) = UPPER(TRIM(rfcemisor)) );
		iTablaANT := 1;
	else 
		iEncontrado := 0;
		
	end if;
	if(iEncontrado=0) then
		if exists (select 1 from mov_facturas_colegiaturas where rfc_clave = rfcemisor and UPPER(TRIM(fol_fiscal))=UPPER(TRIM(sFolioFac))) then
			iEncontrado := 1;
			iStatus := ( SELECT idu_estatus FROM mov_facturas_colegiaturas WHERE UPPER(TRIM(fol_fiscal)) = UPPER(TRIM(sFolioFac)) AND UPPER(TRIM(rfc_clave)) = UPPER(TRIM(rfcemisor)) );
		else
			iEncontrado := 0;
		end if;
	END IF;
	if(iEncontrado=0) then
		IF EXISTS (SELECT 1 from his_facturas_colegiaturas where rfc_clave = rfcemisor and UPPER(TRIM(fol_fiscal))=UPPER(TRIM(sFolioFac))) then
			iEncontrado := 1;
			iStatus := ( SELECT idu_estatus FROM his_facturas_colegiaturas WHERE UPPER(TRIM(fol_fiscal)) = UPPER(TRIM(sFolioFac)) AND UPPER(TRIM(rfc_clave)) = UPPER(TRIM(rfcemisor)) );
		else
			iEncontrado := 0;
			--existeFolio:=(SELECT count(idu_empleado) FROM his_facturas_colegiaturas WHERE UPPER(TRIM(fol_fiscal))=UPPER(TRIM(sFolioFac)));
		END IF;
	end if;

	INSERT INTO tmp_Resultado (iExiste, iEstatus, iCtl) VALUES(iEncontrado, iStatus, iTablaANT);

	For valor IN(
		SELECT	iExiste
			, iEstatus
			, iCtl
		FROM	tmp_Resultado)
		LOOP
			existeFolio	:= valor.iExiste;
			EstatusFolio	:= valor.iEstatus;
			iCTL_FACTURA	:= valor.iCtl;
		RETURN NEXT;
		END LOOP;
	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_validar_folio_relacionado_colegiatura(character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_validar_folio_relacionado_colegiatura(character varying, character varying) TO syspersonal;
COMMENT ON FUNCTION fun_validar_folio_relacionado_colegiatura(character varying, character varying) IS 'La función valida si existe el folio de una factura original para poder subir una factura tipo ppd';