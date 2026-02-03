DROP FUNCTION IF EXISTS fun_indicadores_actualizacion_por_motivo(integer, date, date);

CREATE OR REPLACE FUNCTION fun_indicadores_actualizacion_por_motivo(IN idmotivo integer, IN dfechainicial date, IN dfechafinal date, OUT imotivo integer, OUT smotivo character varying, OUT irevisiones integer, OUT iconcluyorevision integer)
  RETURNS SETOF record AS
$BODY$
declare
/*------------------------------------------------------------------------------------
	No. Peticion :		16559.1
	Colaborador:		98439677 Rafael Ramos
	Sistema : 		Colegiaturas
	Modulo:			Reporte Indicadores
	Ejemplo:
		
		SELECT imotivo
			, smotivo
			, irevisiones
			, iconcluyorevision
		FROM fun_indicadores_actualizacion_por_motivo(9
			, '20180701'
			, '20180815')

SELECT imotivo
						, smotivo
						, irevisiones
						, iconcluyorevision
					FROM fun_indicadores_actualizacion_por_motivo(
						0
						, '20180901'
						, '20181002')
------------------------------------------------------------------------------------*/
	valor record;
	sQuery text;
begin
	create temporary table tmp_consulta(
		iMotivo integer
		, sMotivo character varying
		, iRevisiones integer
		, iConcluyoRevision integer default 0
	)on commit drop;

	create temporary table tmp_revision(
		idu_motivo integer
		, cantidad integer
	)on commit drop;

	create temporary table tmp_conclusion(
		idu_motivo integer
		, cantidad integer default 0
	)on commit drop;

	sQuery := 'INSERT INTO tmp_consulta(iMotivo)
			SELECT	A.idu_motivo_revision
			FROM	mov_bitacora_costos A
			WHERE	A.fec_revision::DATE > ''1900-01-01''
				AND A.fec_pendiente::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
	if(idMotivo > 0)then
		sQuery := sQuery || ' AND A.idu_motivo_revision = ' || idMotivo || '';
	end if;

	sQuery := sQuery || ' GROUP BY A.idu_motivo_revision';
	sQuery := sQuery || ' ORDER BY A.idu_motivo_revision';
	
	execute sQuery;

	sQuery := 'INSERT INTO tmp_revision(
				idu_motivo
				, cantidad)
			SELECT	A.idu_motivo_revision
				, COUNT(DISTINCT A.rfc)
			FROM	mov_bitacora_costos A
			WHERE	A.fec_revision::DATE > ''1900-01-01''
				AND A.fec_pendiente::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
	if(idMotivo != 0)then
		sQuery := sQuery || ' AND idu_motivo_revision = ' || idMotivo || '';
	end if;
	sQuery := sQuery || ' GROUP BY A.idu_motivo_revision';
	sQuery := sQuery || ' ORDER BY A.idu_motivo_revision';

	execute sQuery;

	sQuery := 'INSERT INTO tmp_conclusion(
				idu_motivo
				, cantidad)
			SELECT	A.idu_motivo_revision
				, COUNT(DISTINCT A.rfc)
			FROM	mov_bitacora_costos A
			WHERE	A.fec_conclusion::DATE > ''1900-01-01''
				AND A.fec_pendiente::DATE BETWEEN ''' || dFechaInicial || ''' AND ''' || dFechaFinal || ''' ';
	if(idMotivo != 0)then
		sQuery := sQuery || ' AND idu_motivo_revision = ' || idMotivo || '';
	end if;
	sQuery := sQuery || ' GROUP BY A.idu_motivo_revision';
	sQuery := sQuery || ' ORDER BY A.idu_motivo_revision';

	Execute sQuery;
	
	update	tmp_consulta
	set	sMotivo = trim(UPPER(A.des_motivo))
	from	cat_motivos_colegiaturas A
	where	tmp_consulta.iMotivo = A.idu_motivo
		and A.idu_tipo_motivo = 4;

	update	tmp_consulta
	set	iRevisiones = tmp.cantidad
	from	tmp_revision as tmp
	where	tmp_consulta.iMotivo = tmp.idu_motivo;

	update	tmp_consulta
	set	iConcluyoRevision = tmp.cantidad
	from	tmp_conclusion as tmp
	where	tmp_consulta.iMotivo = tmp.idu_motivo;

	if((select COUNT(*) from tmp_consulta) > 0)then
		sQuery := 'INSERT INTO tmp_consulta(iMotivo, sMotivo,iRevisiones, iConcluyoRevision)
			SELECT	0,''TOTALES:'', SUM(iRevisiones), SUM(iConcluyoRevision)
			FROM	tmp_consulta';

		execute sQuery;
	end if;

	for valor in (select A.iMotivo
			, A.sMotivo
			, A.iRevisiones
			, A.iConcluyoRevision
			from tmp_consulta as A)
	loop
		iMotivo		:= valor.iMotivo;
		sMotivo		:= valor.sMotivo;
		iRevisiones	:= valor.iRevisiones;
		iConcluyoRevision:=valor.iConcluyoRevision;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_indicadores_actualizacion_por_motivo(integer, date, date) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_indicadores_actualizacion_por_motivo(integer, date, date) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_indicadores_actualizacion_por_motivo(integer, date, date) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_indicadores_actualizacion_por_motivo(integer, date, date) TO postgres;
COMMENT ON FUNCTION fun_indicadores_actualizacion_por_motivo(integer, date, date) IS 'La función obtiene un listado totalizado por motivo.';