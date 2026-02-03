CREATE OR REPLACE FUNCTION public.fun_obtener_parametros_colegiaturas(
    IN snombreparametro character varying,
    OUT idparametro integer,
    OUT stipoparametro character varying,
    OUT svalorparametro character varying,
    OUT snomparametro character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
     /*
     No. petición APS               : 8613.1
     Fecha                          : 26/10/2016
     Número empleado                : 96753269
     Nombre del empleado            : Nallely Machado
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : consulta los parametos de colegiaturas de la tabla ctl_parametros_colegiaturas
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Autorizar o rechazar facturas
     Ejemplo                        :
		
--------------------------------------------------------------------------------------
	No.Peticion			:16559.1
	Fecha				:06/06/2018
	Número Empleado			:98439677
	Nombre Empleado			:Rafael Ramos Gutiérrez
	Descripcion del cambio		:Se modifica para control de parametros necesarios para el sistema de colegiaturas
	Ejemplo				: SELECT * FROM fun_obtener_parametros_colegiaturas('URL_SERVICIO_COLEGIATURAS');
------------------------------------------------------------------------------------------------------ */
     valor record;
     
BEGIN
     create temporary table tmp_parametros(
     idu_Parametro integer
     , sTipoParam character varying
     , sValorParam character varying
     , sNomParam character varying
     )on commit drop;
     
     IF TRIM(sNombreParametro) != '' THEN
         insert into	tmp_parametros(idu_Parametro, sTipoParam, sValorParam, sNomParam)
         select		P.id, P.tipo_parametro, P.valor_parametro,
                    P.nom_parametro
         from		ctl_parametros_colegiaturas P
         where		P.nom_parametro = sNombreParametro;
     ELSE
         insert into	tmp_parametros(idu_Parametro, sTipoParam, sValorParam, sNomParam)
         select		P.id, P.tipo_parametro, P.valor_parametro,
                    P.nom_parametro
         from		ctl_parametros_colegiaturas P;
     END IF;

     for valor in(select tmp.idu_Parametro
			, tmp.sTipoParam
			, tmp.sValorParam
			, tmp.sNomParam
			from tmp_parametros tmp
			order by tmp.idu_Parametro)
			Loop
				idParametro := valor.idu_Parametro;
				sTipoParametro := valor.sTipoParam;
				sValorParametro := valor.sValorParam;
				sNomParametro := valor.sNomParam;
			return next;
			end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_parametros_colegiaturas(character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_parametros_colegiaturas(character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_parametros_colegiaturas(character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_parametros_colegiaturas(character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_parametros_colegiaturas(character varying) IS 'La función consulta los parametos de colegiaturas de la tabla ctl_parametros_colegiaturas.';