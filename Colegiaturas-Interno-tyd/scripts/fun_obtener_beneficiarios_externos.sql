CREATE OR REPLACE FUNCTION fun_obtener_beneficiarios_externos(IN iiduempleado integer, IN irowsperpage integer, IN icurrentpage integer, IN sordercolumn character varying, IN sordertype character varying, IN scolumns character varying, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT idu_beneficiario integer, OUT idu_empleado integer, OUT nom_empleado character varying, OUT prc_descuento smallint, OUT opc_beneficiario_bloqueado smallint, OUT fec_registro character varying, OUT idu_empleado_registro integer, OUT nom_empleado_registro character varying)
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
	Modulo: 			Captura de Externos
	
	Ejemplo:		
			// MUESTRA TODOS LOS BENEFICIARIOS EXTERNOS CONFIGURADOS
				SELECT records
					, page
					, pages
					, id
					, idu_beneficiario
					, idu_empleado
					, nom_empleado
					, prc_descuento
					, opc_beneficiario_bloqueado
					, fec_registro
					, idu_empleado_registro
					, nom_empleado_registro
				FROM fun_obtener_beneficiarios_externos(
				94827443
				, 10
				, 1
				, 'fec_registro'
				, 'asc'
				, 'idu_beneficiario, idu_empleado, nom_empleado, prc_descuento, opc_beneficiario_bloqueado, fec_registro, idu_empleado_registro, nom_empleado_registro')
			// PARA MOSTRAR LOS QUE TIENE CONFIGURADOS UN COLABORADOR EN ESPECIFICO, CAMBIAR LA LINEA DEL CERO(0), POR EL NUMERO DE EMPLEADO
				Esta opcion se utiliza en la pantalla de subir factura de externos, para llenar el combo de los beneficiarios
			
-----------------------------------------*/
	/*VARIABLES DE PAGINADO*/
	iStart integer;
	iRecords integer;
	iTotalPages integer;
	
	valor record;
	iColaborador integer;
	sNombreColaborador character varying(150);

	sConsulta varchar(3000);
begin
	/*Control de las variables de paginado*/
	if iRowsPerPage = -1 then
		iRowsPerPage := NULL;
	end if;
	if iCurrentPage = -1 then
		iCurrentPage := null;
	end if;
	
	create temporary table tmp_Beneficiarios(
	records			integer
	, page			integer
	, pages			integer
	, id			integer
	, idu_beneficiario	integer 
	, idu_empleado		integer 
	, nom_empleado		character varying(150)
	, prc_descuento		integer not null
	, opc_beneficiario_bloqueado	smallint
	, fec_registro		character varying(10)
	, idu_empleado_registro	integer
	, nom_empleado_registro	character varying(150)
	) on commit drop;

	
	IF iIduEmpleado = 0 THEN
        insert into	tmp_Beneficiarios(idu_beneficiario, idu_empleado, nom_empleado, prc_descuento, opc_beneficiario_bloqueado, fec_registro, idu_empleado_registro)
        select		BE.idu_beneficiario, BE.idu_empleado, BE.nom_empleado, BE.prc_descuento, BE.opc_beneficiario_bloqueado, to_char(BE.fec_registro, 'dd/mm/yyyy'), BE.idu_empleado_registro 
        from		cat_beneficiarios_externos BE;
    ELSE
        -- Obtiene los beneficiarios asignados a iIduEmpleado
        insert into	tmp_Beneficiarios(idu_beneficiario, idu_empleado, nom_empleado, prc_descuento, opc_beneficiario_bloqueado, fec_registro, idu_empleado_registro)
        select mov.idu_beneficiario
            , iIduEmpleado as empleado
            , BE.nom_empleado
            , BE.prc_descuento
            , BE.opc_beneficiario_bloqueado
            , to_char(BE.fec_registro, 'dd/mm/yyyy')
            , BE.idu_empleado_registro 
        from mov_beneficiarios_asignados mov
            INNER JOIN cat_beneficiarios_externos BE ON (BE.idu_beneficiario = mov.idu_beneficiario)
        WHERE mov.idu_empleado = iIduEmpleado
            AND BE.opc_beneficiario_bloqueado != 1;
    END IF;
    
	update	tmp_Beneficiarios
	set	nom_empleado_registro = a.nombre || '  ' || a.apellidopaterno || '  ' || a.apellidomaterno
	from	sapcatalogoempleados a
	where	tmp_Beneficiarios.idu_empleado_registro = a.numempn;
    
    iRecords := (select COUNT(*) from tmp_Beneficiarios);
	if(iRowsPerPage is not null and iCurrentPage is not null) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage +1;
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));

		sConsulta := '
			SELECT ' || cast(iRecords as varchar) || ' AS records
			     , ' || cast(iCurrentPage as varchar) || ' AS page
			     , ' || cast(iTotalPages as varchar) || ' AS pages
			     , id
			     , ' || sColumns || '
			FROM (
					SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
					FROM tmp_Beneficiarios
					) as t
			WHERE t.id BETWEEN ' || cast(iStart as varchar) || ' AND ' || cast(((iStart + iRowsPerPage) - 1) as varchar) || ' ';
	else
		sConsulta := 'SELECT ' || iRecords::varchar || ' AS records, 0 as page, 0 as pages, 0 as id,' || sColumns || ' FROM tmp_Beneficiarios ';
	end if;

	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;

	for valor in execute (sConsulta)
	Loop
		records := valor.records;
		page	:= valor.page;
		pages	:= valor.pages;
		id	:= valor.id;
		idu_beneficiario	:= valor.idu_beneficiario;
		idu_empleado	:= valor.idu_empleado;
		nom_empleado	:= valor.nom_empleado;
		prc_descuento	:= valor.prc_descuento;
		opc_beneficiario_bloqueado	:= valor.opc_beneficiario_bloqueado;
		fec_registro	:= valor.fec_registro;
		idu_empleado_registro	:= valor.idu_empleado_registro;
		nom_empleado_registro	:= valor.nom_empleado_registro;
		return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_externos(integer, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_externos(integer, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_externos(integer, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_externos(integer, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_beneficiarios_externos(integer, integer, integer, character varying, character varying, character varying) IS 'La función obtiene un listado con los beneficiarios externos capturados por Personal Administracion.';