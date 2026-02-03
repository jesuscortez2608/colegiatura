DROP FUNCTION if exists fun_existe_folio_fiscal_colegiaturas(character varying);

CREATE OR REPLACE FUNCTION fun_existe_folio_fiscal_colegiaturas(
IN sfolio character varying
, OUT iestado integer
, OUT smensaje text
, OUT scontenedor character varying
, OUT iestatus integer
, OUT snomestatus character varying)
  RETURNS record AS
$BODY$
	DECLARE
	/*
	No. petición APS               : 16559.1 Colegiaturas
	Fecha                          : 31/07/2018
	Número empleado                : 95194185
	Nombre del empleado            : Paimi Arizmendi Lopez
	Base de datos                  : Personal
	Usuario de BD                  : syspersonal
	Servidor de pruebas            : 10.28.114.75
	Servidor de produccion         : 10.44.2.183
	Descripción del funcionamiento : Busca en tablas de trabajo e históricas si existe el folio recibido como parámetro
	Sistema                        : Colegiaturas Web
	Módulo                         : Captura de facturas especiales
	Repositorio del proyecto       : svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
	Ejemplo                        : 
        select * from fun_existe_folio_fiscal_colegiaturas('E5F151RT-G1GR-R1H1-T8W1-D1WERRGB1R98');
        select * from fun_existe_folio_fiscal_colegiaturas('E5F151RT-G1GR-R1H1-T8W1-D1WERRGB1R98');
    ------------------------------------------------------------------------------------------------------ */
	BEGIN
		if exists(select 1 from mov_facturas_colegiaturas where fol_fiscal = sfolio) then
			iEstado := -1;
			sMensaje := 'La factura fue registrada anteriormente.';
			sContenedor := 'M';
			iEstatus := (select idu_estatus from mov_facturas_colegiaturas where fol_fiscal = sfolio LIMIT 1);
			sNomEstatus := (select nom_estatus from cat_estatus_facturas where idu_estatus = iEstatus limit 1);
		elsif exists(select 1 from his_facturas_colegiaturas where fol_fiscal = sfolio) then
			iEstado := -2;
			sMensaje := 'La factura fue registrada anteriormente.';
			sContenedor := 'H';
			iEstatus := (select idu_estatus from his_facturas_colegiaturas where fol_fiscal = sfolio LIMIT 1);
			sNomEstatus := (select nom_estatus from cat_estatus_facturas where idu_estatus = iEstatus limit 1);
        ELSE
            iEstado := 0;
			sMensaje := 'No existe el folio en la BD';
			sContenedor := '';
			iEstatus := 0;
			sNomEstatus := '';
		end if;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_existe_folio_fiscal_colegiaturas(character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_existe_folio_fiscal_colegiaturas(character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_existe_folio_fiscal_colegiaturas(character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_existe_folio_fiscal_colegiaturas(character varying) TO postgres;
COMMENT ON FUNCTION fun_existe_folio_fiscal_colegiaturas(character varying) IS 'La función busca un folio fiscal en las tablas de colegiaturas.';