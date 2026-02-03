DROP FUNCTION if exists fun_obtener_listado_carreras(integer, integer, character varying, character varying, character varying);

CREATE OR REPLACE FUNCTION fun_obtener_listado_carreras(
IN irowsperpage integer
, IN icurrentpage integer
, IN sordercolumn character varying
, IN sordertype character varying
, IN scolumns character varying
, OUT records integer
, OUT page integer
, OUT pages integer
, OUT id integer
, OUT idu_carrera integer
, OUT nom_carrera character varying
, OUT fec_registro character varying
, OUT idu_empleado_registro integer
, OUT nom_empleado_registro character varying)
  RETURNS SETOF record AS
$BODY$
declare
/***
	No.Petición:			16559.1
	Fecha:				30/05/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:				PERSONAL    
	Servidor:			10.44.2.183
	Sistema:			Colegiaturas
	Modulo: 			Catalogo de Carreras
	Ejemplo:
		SELECT records
			, page
			, pages
			, id
			, idu_carrera
			, nom_carrera
			, fec_registro
			, idu_empleado_registro
			, nom_empleado_registro
		FROM fun_obtener_listado_carreras(
			10
			, 1
			, 'fec_registro'
			, 'asc'
			,'idu_carrera, nom_carrera, fec_registro, idu_empleado_registro, nom_empleado_registro')

---------------------------------------------------------------------------------------------------------------*/
	/**Variables de Paginado*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;

	valor record;
	sConsulta varchar(3000);
begin

	/**Control de variables de paginado*/
	if irowsperpage = -1 then
		irowsperpage := null;
	end if;
	if icurrentpage = -1 then
		icurrentpage := null;
	end if;

	create temporary table tmp_carreras(
	records	integer
	, page	integer
	, pages	integer
	, id	integer
	, idu_carrera integer
	, nom_carrera character varying(150)
	, fec_registro character varying
	, idu_empleado_registro integer
	, nom_empleado_registro character varying(150)
	)on commit drop;

	insert into	tmp_carreras(idu_carrera, nom_carrera, fec_registro, idu_empleado_registro)
	select		C.idu_carrera, C.nom_carrera, to_char(C.fec_registro, 'dd-mm-yyyy'), C.idu_empleado_registro
	from		cat_carreras as C
	order by C.idu_carrera;

	update	tmp_carreras	set	nom_empleado_registro = E.nombre || ' ' || E.apellidopaterno || ' ' || E.apellidomaterno 
	from	sapcatalogoempleados as E
	where	tmp_carreras.idu_empleado_registro = E.numempn;

	iRecords := (select COUNT(*) from tmp_carreras);
	if(irowsperpage is not null and icurrentpage is not null) then
		iStart := (irowsperpage * icurrentpage) - irowsperpage +1;
		iTotalPages := CEILING(iRecords / (irowsperpage * 1.0));

		sConsulta := '
			SELECT ' || cast(iRecords as varchar) || ' AS records
			     , ' || cast(icurrentpage as  varchar) || ' AS page
			     , ' || cast(itotalpages as varchar) || ' AS pages
			     , id
			     , ' || sColumns || '
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY ' ||sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM tmp_carreras
				) as t
			WHERE t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + irowsperpage) - 1) as varchar) || ' ';
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_carreras ';
	end if;

	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;

	for valor in execute(sConsulta)
	loop
		records := valor.records;
		page	:= valor.page;
		pages	:= valor.pages;
		id	:= valor.id;
		idu_carrera	:= valor.idu_carrera;
		nom_carrera	:= valor.nom_carrera;
		fec_registro	:= valor.fec_registro;
		idu_empleado_registro := valor.idu_empleado_registro;
		nom_empleado_registro := valor.nom_empleado_registro;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_carreras(integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_carreras(integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_carreras(integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_carreras(integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_carreras(integer, integer, character varying, character varying, character varying) IS 'La función obtiene las diferentes carreras capturadas en el catálogo (cat_carreras).';