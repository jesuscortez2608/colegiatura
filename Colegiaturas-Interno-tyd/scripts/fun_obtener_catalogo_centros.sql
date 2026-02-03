CREATE OR REPLACE FUNCTION fun_obtener_catalogo_centros(IN icentro integer, IN scentro character varying, IN iseccion integer, OUT idu_centro integer, OUT nom_centro character varying, OUT idu_estado integer, OUT idu_ciudad integer, OUT idu_seccion integer, OUT idu_gerente integer)
  RETURNS SETOF record AS
$BODY$
declare
	rec record;
	sQuery VARCHAR(3000);
begin
-- ===================================================
-- Peticion				: 16559.1
-- Autor				: Rafael Ramos Gutiérrez 98439677
-- Fecha				: 02/04/2018
-- Descripción General	: La función obtiene un listado de los centros de la tabla sapcatalogocentros.
-- Sistema				: Colegiaturas
-- Servidor Productivo	: 10.44.2.183
-- Servidor Desarrollo	: 10.44.114.75
-- Base de Datos		: personal
-- Ejemplo			: SELECT * FROM fun_obtener_catalogo_centros(0, 'DESARROLLO', 52)
-- ===================================================
    sQuery := 'SELECT centron AS idu_centro
        , nombrecentro AS nom_centro
        , CASE WHEN TRIM(estado) != '''' THEN estado::INTEGER ELSE ''0''::INTEGER END AS idu_estado
        , ciudadn AS idu_ciudad
        , seccion::INTEGER AS idu_seccion
        , CASE WHEN TRIM(numerogerente) != '''' THEN numerogerente::INTEGER ELSE ''0''::INTEGER END AS idu_gerente
    FROM sapcatalogocentros 
    WHERE 1 = 1 ';
    
    IF iSeccion != 0 THEN
        sQuery := sQuery || 'AND seccion::INTEGER = ' || iSeccion::VARCHAR || ' ';
    END IF;
    
    IF iCentro != 0 THEN
        sQuery := sQuery || 'AND centron = ' || iCentro::VARCHAR || ' ';
    END IF;
    
    IF TRIM(sCentro) != '' THEN
        sQuery := sQuery || 'AND nombrecentro LIKE ''%' || sCentro::VARCHAR || '%'' ';
    END IF;
    
    sQuery := sQuery || 'ORDER BY nombrecentro ';
    
	for rec IN EXECUTE(sQuery) loop
        idu_centro := rec.idu_centro;
        nom_centro := rec.nom_centro;
        idu_estado := rec.idu_estado;
        idu_ciudad := rec.idu_ciudad;
        idu_seccion := rec.idu_seccion;
        idu_gerente := rec.idu_gerente;
        return next;
    end loop;				
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_catalogo_centros(integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_catalogo_centros(integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_catalogo_centros(integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_catalogo_centros(integer, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_catalogo_centros(integer, character varying, integer) IS 'La función obtiene un listado de los centros de la tabla sapcatalogocentros.';
