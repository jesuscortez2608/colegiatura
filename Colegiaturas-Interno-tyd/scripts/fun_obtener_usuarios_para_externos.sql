CREATE OR REPLACE FUNCTION fun_obtener_usuarios_para_externos(IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT iempleado integer, OUT snombre character varying, OUT icentro integer, OUT snombrecentro character varying, OUT ipuesto integer, OUT snombrepuesto character varying, OUT iindefinido integer, OUT ibloqueado integer, OUT dfechainicial character varying, OUT dfechafinal character varying, OUT dfecharegistro character varying, OUT icolaboradorasignopermiso integer, OUT scolaboradorasignopermiso character varying)
  RETURNS SETOF record AS
$BODY$
declare
/*----------------------------------------
	No.Petición:			16559.1
	Fecha:				23/04/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:				PERSONAL    
	Servidor:			10.44.2.183
	Sistema:			Colegiaturas
	Modulo: 			Asignar Permisos a Colaborador
	
	Ejemplo:			select * from fun_obtener_usuarios_para_externos()	--> Regresa el listado de los empleados dados de alta para capturar facturas de empleados externos
-----------------------------------------*/

	/*VARIABLES DE PAGINADO*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;

	
	valor record;
	iColaborador integer;
	sNombreColaborador character varying (150);
	sConsulta varchar(3000);
begin
	/*CONTROL DE LAS VARIABLES DE PAGINADO*/
	if iRowsPerPage = -1 then
		iRowsPerPage := null;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := null;
	end if;

	
	create temp table tmp_Externos(
	records 	integer
	, page		integer
	, pages		integer
	, id		integer	
	, iempleado	integer not null default 0
	, snombre	character varying not null default ''
	, icentro	integer not null default 0
	, snombrecentro	character varying not null default ''
	, ipuesto	integer not null default 0
	, snombrepuesto	character varying not null default ''
	, iindefinido integer not null default 0
	, ibloqueado	integer not null default 0
	, dfechainicial	character varying(10) not null default '1900-01-01'
	, dfechafinal	character varying(10) not null default '1900-01-01'
	, dfecharegistro	character varying(10) not null default '1900-01-01'
	, icolaboradorasignopermiso	integer not null default 0
	, scolaboradorasignopermiso	character varying not null default ''
	) on commit drop;

	insert into	tmp_Externos(iempleado, ibloqueado, iindefinido, dfechainicial, dfechafinal, dfecharegistro, icolaboradorasignopermiso)
	select		UE.idu_empleado, UE.opc_empleado_bloqueado, UE.opc_indefinido, to_char(UE.fec_inicial,'dd-mm-yyyy'), to_char(UE.fec_final, 'dd-mm-yyyy'), to_char(UE.fec_registro, 'dd-mm-yyyy'), UE.idu_empleado_registro
	from		cat_usuarios_externos UE;

	update	tmp_Externos
	set	snombre = a.nombre || ' ' || a.apellidopaterno || ' ' || a.apellidomaterno
		,icentro = a.centron
		,ipuesto = a.pueston
	from	sapcatalogoempleados a
	where	tmp_Externos.iempleado = a.numempn;

	update	tmp_Externos
	set	snombrecentro = a.nombrecentro
	from	sapcatalogocentros a
	where	tmp_Externos.icentro = a.centron;

	update	tmp_Externos
	set	snombrepuesto =  a.nombre
	from	sapcatalogopuestos a
	where	tmp_Externos.ipuesto = a.numero::int;

	update	tmp_Externos
	set	scolaboradorasignopermiso = a.nombre || ' ' || a.apellidopaterno || ' ' || a.apellidomaterno
	from 	sapcatalogoempleados a
	where	tmp_Externos.icolaboradorasignopermiso = a.numempn;

	iRecords := (select COUNT(*) from tmp_Externos);
	if(iRowsPerPage is not null and iCurrentPage is not null) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage +1;
		iRecords := (select COUNT(*) from tmp_Externos);
		iTotalPages := ceiling(iRecords/(iRowsPerPage*1.0));

		sConsulta := '
			SELECT ' || cast(iRecords as varchar) || ' AS records
			     , ' || cast(iCurrentPage as varchar) || ' AS page
			     , ' || cast(iTotalPages as varchar) || ' AS pages
			     , id
			     , ' || sColumns || '
			FROM (
				SELECT ROW_NUMBER() OVER(ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') as id, ' || sColumns || '
				FROM tmp_Externos
				) as t
			WHERE t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' ';
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' as records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_Externos';
	end if;

	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;

	for valor in execute(sConsulta)
	loop
		records	:= valor.records;
		page	:= valor.page;
		pages	:= valor.pages;
		id	:= valor.id;
		iempleado	:= valor.iempleado;
		snombre	:= valor.snombre;
		icentro	:= valor.icentro;
		snombrecentro	:= valor.snombrecentro;
		ipuesto	:= valor.ipuesto;
		snombrepuesto	:= valor.snombrepuesto;
		iindefinido	:= valor.iindefinido;
		ibloqueado	:= valor.ibloqueado;
		dfechainicial		:= valor.dfechainicial;
		dfechafinal		:= valor.dfechafinal;
		dfecharegistro		:= valor.dfecharegistro;
		icolaboradorasignopermiso	:= valor.icolaboradorasignopermiso;
		scolaboradorasignopermiso	:= valor.scolaboradorasignopermiso;
		return next;
	end loop;
	/*for valor in(select
			idu_empleado
			,sNom_empleado
			,idu_centro
			,sNom_centro
			,idu_puesto
			,sNom_puesto
			,idu_indefinido
			,idu_bloqueado
			,dFecIni
			,dFecFin
			,dFecReg
			,idu_colAsigno
			,sColAsigno
			from tmp_Externos)
			loop
				iEmpleado	:= valor.idu_empleado;
				sNombre		:= valor.sNom_empleado;
				iCentro		:= valor.idu_centro;
				sNombreCentro	:= valor.sNom_centro;
				iPuesto		:= valor.idu_puesto;
				sNombrePuesto	:= valor.sNom_puesto;
				iIndefinido	:= valor.idu_indefinido;
				iBloqueado	:= valor.idu_bloqueado;
				dFechaInicial	:= valor.dFecIni;
				dFechaFinal	:= valor.dFecFin;
				dFechaRegistro	:= valor.dFecReg;
				iColaboradorAsignoPermiso := valor.idu_colAsigno;
				sColaboradorAsignoPermiso := valor.sColAsigno;
			return next;
			end loop;*/
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_usuarios_para_externos(integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_usuarios_para_externos(integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_usuarios_para_externos(integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_usuarios_para_externos(integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_usuarios_para_externos(integer, integer, character varying, character varying, character varying) IS 'La función obtiene un listado con los colaboradores que han sido agregados para capturar facturas de empleados externos.';    