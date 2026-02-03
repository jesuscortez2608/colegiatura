DROP FUNCTION IF EXISTS fun_validar_tipo_relacion_cfdi_colegiaturas(integer);

CREATE OR REPLACE FUNCTION fun_validar_tipo_relacion_cfdi_colegiaturas(IN itiporelacion integer, OUT istatus integer, OUT smensaje character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	resultado RECORD;
	iExiste INTEGER = 0;
	cMsj CHARACTER VARYING(150) = '';

BEGIN
-- ===================================================
-- Peticion			: .1
-- Autor			: Rafael Ramos Gutiérrez 98439677
-- Fecha			: 30 / 08 / 2019
-- Descripción General		: La funcion valida que el tipo de relacion del XML de la factura exista dentro de los tipos validados para colegiaturas
-- Ruta Tortoise		:
-- Sistema			: Colegiaturas
-- Servidor Productivo		: 10.44.2.183
-- Servidor Desarrollo		: 10.44.114.75
-- Base de Datos		: personal
-- Ejemplo			: SELECT * FROM fun_validar_tipo_relacion_cfdi_colegiaturas(07);
-- ===================================================

CREATE TEMPORARY TABLE tmp_Resultado
(
	iEstatus integer not null default 0
	, sMnsj character varying not null default ''
) on commit drop;

	IF EXISTS(SELECT 1 FROM CTL_TIPORELACIONCFDI_COLEGIATURAS WHERE id_tiporelacion = iTipoRelacion) THEN
		iExiste = 1;
		cMsj := 'El tipo de relacion es: ' || (SELECT nom_tiporelacion FROM CTL_TIPORELACIONCFDI_COLEGIATURAS WHERE id_tiporelacion = iTipoRelacion);
	ELSE
		iExiste = 0;
		cMsj := 'El tipo de relacion del CFDIRelacionado no esta permitido';
	END IF;

	INSERT INTO tmp_Resultado (iEstatus, sMnsj) VALUES (iExiste, cMsj);

	FOR resultado IN (
	SELECT	iEstatus
		, sMnsj 
	FROM	tmp_Resultado) 
	LOOP
		iStatus:= resultado.iEstatus;
		sMensaje:= resultado.sMnsj;
	RETURN NEXT;
	END LOOP;	
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_validar_tipo_relacion_cfdi_colegiaturas(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_validar_tipo_relacion_cfdi_colegiaturas(integer) TO syspersonal;
COMMENT ON FUNCTION fun_validar_tipo_relacion_cfdi_colegiaturas(integer) IS 'Valida si el tipo de relacion del XML esta dentro de los permitidos';