DROP FUNCTION IF EXISTS fun_indicadores_tiempo_promedio_respuesta(integer, date, date);

CREATE OR REPLACE FUNCTION fun_indicadores_tiempo_promedio_respuesta(IN idusuario integer, IN dfechainicial date, IN dfechafinal date, OUT iusuario integer, OUT snombreusuario character varying, OUT icantrevisiones integer, OUT icantdias integer, OUT icantidaddias character varying)
  RETURNS SETOF record AS
$BODY$

declare
	/**-----------------------------------------------------------------
		No. Peticion:		16559.1
		Fecha:			15/08/2018
		Colaborador:		98439677 Rafael Ramos
		BD:			Personal
		Sistema:		Colegiaturas
		Modulo:			Reporte de Indicadores
		Ejemplo:

				select * from fun_indicadores_tiempo_promedio_respuesta(95194185,'20180101','20180815')
				select * from fun_indicadores_tiempo_promedio_respuesta(0,'20180101','20180815')

		Ejemplo Pantalla:
			SELECT iusuario
				, snombreusuario
				, icantidaddias
			FROM fun_indicadores_tiempo_promedio_respuesta(
			95194185
			, '20180701'
			, '20180815')
	------------------------------------------------------------------*/
	valor record;
	sQuery text;
	iNumCantidad character varying;
begin
    create temporary table tmp_consulta(iUsuario integer
		, sNombreUsuario character varying
		, iRevisiones INTEGER
		, iDias INTEGER
		, iPromedio NUMERIC(5,2)
	)on commit drop;

    -- DROP TABLE IF EXISTS tmp_revisiones
	create temporary table tmp_revisiones(idu_usuario integer
	--create table tmp_revisiones(idu_usuario integer
		, idu_revision INTEGER
		, fec_pendiente TIMESTAMP WITHOUT TIME ZONE
		, fec_conclusion TIMESTAMP WITHOUT TIME ZONE
		, dias INTEGER
	--);
	)on commit drop;
    
    if (idUsuario > 0) then
        insert into tmp_revisiones(idu_usuario, idu_revision, fec_pendiente, fec_conclusion, dias)
            SELECT idu_usuario
                , idu_revision
                , min(fec_pendiente)
                , max(fec_conclusion)
                , 0 as dias
            FROM mov_bitacora_costos
            where fec_pendiente::DATE between dfechainicial::DATE and dfechafinal::DATE
		and idu_usuario = idUsuario
                and fec_pendiente > '1900-01-01'::date
                and fec_conclusion > '1900-01-01'::date
            group by idu_usuario, idu_revision;
    else
        insert into tmp_revisiones(idu_usuario, idu_revision, fec_pendiente, fec_conclusion, dias)
            SELECT idu_usuario
                , idu_revision
                , min(fec_pendiente)
                , max(fec_conclusion)
                , 0 as dias
            FROM mov_bitacora_costos
            where fec_pendiente::DATE between dfechainicial::DATE and dfechafinal::DATE
		and fec_pendiente > '1900-01-01'::date
                and fec_conclusion > '1900-01-01'::date
            group by idu_usuario, idu_revision;
    end if;
    
    update tmp_revisiones set dias = DATE_PART('day', fec_conclusion::timestamp - fec_pendiente::timestamp);
    
    INSERT INTO tmp_consulta (iUsuario, iDias, iRevisiones)
        SELECT idu_usuario
            , sum(dias)
            , count(DISTINCT idu_revision)
        from tmp_revisiones
        group by idu_usuario;
    
    update	tmp_consulta set iPromedio = case when iRevisiones > 0 then (iDias::float / iRevisiones::float) else 0.00 end;
    
    update	tmp_consulta
        set	sNombreUsuario = trim(UPPER(A.nombre)) || ' ' || trim(UPPER(A.apellidopaterno)) || ' ' || trim(UPPER(A.apellidomaterno))
	from	sapcatalogoempleados A
	where	tmp_consulta.iUsuario = A.numempn;	
    
	for valor in (select A.iUsuario
				, A.sNombreUsuario
				, A.iPromedio
				, A.iRevisiones
				, A.iDias
			from tmp_consulta as A)
	loop
		iUsuario	:= valor.iUsuario;
		sNombreUsuario	:= valor.sNombreUsuario;
		iCantRevisiones := valor.iRevisiones;
		iCantDias := valor.iDias;
		iCantidadDias	:= '' || valor.iPromedio::varchar || ' DÍAS POR PETICIÓN';
		return next;
	end loop;
end;

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_indicadores_tiempo_promedio_respuesta(integer, date, date) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_indicadores_tiempo_promedio_respuesta(integer, date, date) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_indicadores_tiempo_promedio_respuesta(integer, date, date) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_indicadores_tiempo_promedio_respuesta(integer, date, date) TO postgres;
COMMENT ON FUNCTION fun_indicadores_tiempo_promedio_respuesta(integer, date, date) IS 'La función obtiene un listado de los promedios de actualización por usuario, es decir, cuánto tarda en promedio un usuario en realizar una revisión.';