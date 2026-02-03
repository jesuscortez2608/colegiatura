DROP FUNCTION IF EXISTS fun_obtener_listado_configuraciones_descuentos(integer, integer, integer, integer, integer, character varying, character varying, character varying);
DROP TYPE IF EXISTS type_obtener_listado_configuraciones_descuentos;


CREATE TYPE type_obtener_listado_configuraciones_descuentos AS
   (records integer,
    page integer,
    pages integer,
    id integer,
    numemp integer,
    nomempleado character varying(150),
    centro integer,
    nomcentro character varying(30),
    puesto integer,
    nompuesto character varying(60),
    seccion integer,
    nomseccion character varying(30),
    idu_parentesco integer,
    parentesco character varying(30),
    idu_estudio integer,
    estudio character varying(30),
    por_descuento integer,
    des_comentario character varying(300));

CREATE OR REPLACE FUNCTION fun_obtener_listado_configuraciones_descuentos(integer, integer, integer, integer, integer, character varying, character varying, character varying)
  RETURNS SETOF type_obtener_listado_configuraciones_descuentos AS
$BODY$
DECLARE
     /*
     No. petición APS               : 8613.1
     Fecha                          : 28/09/2016
     Número empleado                : 96753269
     Nombre del empleado            : Jesús Ramón Vega Taboada
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento :
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de Colegiaturas
     Ejemplo        :
		POR COLABORADOR
			SELECT * FROM fun_obtener_listado_configuraciones_descuentos(1::integer, 0::integer, 0::integer,10::integer, 1::integer, 'numemp,idu_parentesco ', 'asc', 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento, numempregistro, nomempleadoregistro, des_comentario')
				--DETALLE
					SELECT * FROM fun_obtener_listado_configuraciones_descuentos(4::integer, 93902761::integer, 0::integer,10::integer, 1::integer, 'numemp', 'asc', 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento, numempregistro, nomempleadoregistro, des_comentario')
		POR PUESTO
			SELECT * FROM fun_obtener_listado_configuraciones_descuentos(3::integer, 0::integer, 0::integer,10::integer, 1::integer, 'puesto,idu_parentesco ', 'asc', 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento, numempregistro, nomempleadoregistro, des_comentario')
				--DETALLE
					SELECT * FROM fun_obtener_listado_configuraciones_descuentos(6::integer, 103::integer, 23::integer,10::integer, 1::integer, 'numemp', 'asc', 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento, numempregistro, nomempleadoregistro, des_comentario')
		POR CENTRO
			SELECT * FROM fun_obtener_listado_configuraciones_descuentos(2::integer, 0::integer, 0::integer,10::integer, 1::integer, 'centro,puesto,idu_parentesco', 'asc', 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento, numempregistro, nomempleadoregistro, des_comentario')
				--DETALLE
					SELECT * FROM fun_obtener_listado_configuraciones_descuentos(5::integer, 118280::integer, 253::integer,10::integer, 1::integer, 'numemp', 'asc', 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento, numempregistro, nomempleadoregistro, des_comentario')
  ------------------------------------------------------------------------------------------------------ */

	opc_busqueda ALIAS FOR $1;
	nBusqueda ALIAS FOR $2;
	nFiltro ALIAS FOR $3;
	iRowsPerPage ALIAS FOR $4;
	iCurrentPage ALIAS FOR $5;
	sOrderColumn ALIAS FOR $6;
	sOrderType ALIAS FOR $7;
	sColumns ALIAS FOR $8;
	iStart INTEGER;
	iRecords INTEGER;
	iTotalPages INTEGER;
	sConsulta VARCHAR(3000);
	col RECORD;
     
 
	returnrec type_obtener_listado_configuraciones_descuentos;
BEGIN
    IF iRowsPerPage = -1 then
        iRowsPerPage := NULL;
    end if;
    if iCurrentPage = -1 then
        iCurrentPage := NULL;
    end if;
    
    create local temp table tmp_obtener_concentrado_configuraciones_descuentos  
    (   
	    NumEmp integer,
	    NomEmpleado varchar(150),
	    Centro integer,
	    NomCentro varchar(30),
	    Puesto integer,
	    NomPuesto varchar(60),
	    Seccion integer,
	    nomSeccion varchar(30),
	    idu_parentesco integer,
	    parentesco varchar(30),
	    idu_estudio integer,
	    estudio varchar(30),
	    por_descuento integer,
	    NumEmpRegistro integer,
	    NomEmpleadoRegistro character varying(150),
	    des_comentario varchar(300)
    ) on commit drop;  

	if opc_busqueda = 1 then --CONCENTRADO POR COLABORADOR
		sConsulta:='insert into tmp_obtener_concentrado_configuraciones_descuentos (NumEmp)
			select distinct idu_empleado from CTL_CONFIGURACION_DESCUENTOS
			where idu_empleado >0 ';
		if nBusqueda!=0 then
			sConsulta:=sConsulta||' and idu_empleado='||nBusqueda;
		end if;	
	elsif opc_busqueda = 2 then  --CONCENTRADO POR CENTRO
		sConsulta:='insert into tmp_obtener_concentrado_configuraciones_descuentos (Centro,Puesto)
		select  distinct idu_Centro, idu_Puesto from CTL_CONFIGURACION_DESCUENTOS
		where idu_Centro >0 ';
		if nBusqueda!=0 then
			sConsulta:=sConsulta||' and idu_Centro='||nBusqueda;
		end if;
		if nFiltro!=0 then 
			sConsulta:=sConsulta||' and idu_Puesto='||nFiltro;
		else	
			sConsulta:=sConsulta||' and idu_Puesto>=0';
		end if;	
		
	elsif opc_busqueda = 3 then  --CONCENTRADO POR PUESTO
		sConsulta:='insert into tmp_obtener_concentrado_configuraciones_descuentos (Puesto,Seccion)
		select  distinct idu_Puesto, idu_Seccion from CTL_CONFIGURACION_DESCUENTOS
		where idu_Puesto > 0 ';
		if nBusqueda!=0 then
			sConsulta:=sConsulta||' and idu_Puesto='||nBusqueda;
		end if;
		if nFiltro!=0 then
			sConsulta:=sConsulta||' and idu_Seccion='||nFiltro;
		else
			sConsulta:=sConsulta||' and idu_Seccion >=0'; 
		end if;
	elsif opc_busqueda = 4 then  --DETALLE POR COLABORADOR
		
		sConsulta:='insert into tmp_obtener_concentrado_configuraciones_descuentos (NumEmp, idu_parentesco, idu_estudio,por_descuento, des_comentario )
			select  idu_empleado, idu_parentesco, idu_escolaridad, por_porcentaje, des_comentario from CTL_CONFIGURACION_DESCUENTOS
			where idu_empleado >0 ';
		if nBusqueda!=0 then
			sConsulta:=sConsulta||' and idu_empleado='||nBusqueda;
		end if;	
		

	elsif opc_busqueda = 5 then  --DETALLE POR CENTRO
		sConsulta:=
		'insert into tmp_obtener_concentrado_configuraciones_descuentos (Centro,Puesto, idu_parentesco, idu_estudio,por_descuento, des_comentario)
		select   idu_Centro, idu_Puesto,idu_parentesco, idu_escolaridad, por_porcentaje, des_comentario from CTL_CONFIGURACION_DESCUENTOS
		where idu_Centro >0 and idu_Puesto>=0';
		if nBusqueda!=0 then
			sConsulta:=sConsulta||' and idu_Centro='||nBusqueda;
		end if;
		if( nFiltro!= -1) then
			sConsulta:=sConsulta||' and idu_Puesto='||nFiltro;
			
		end if;	
		
		
	elsif opc_busqueda = 6 then  --DETALLE POR PUESTO
		sConsulta:='insert into tmp_obtener_concentrado_configuraciones_descuentos (Puesto,Seccion , idu_parentesco, idu_estudio,por_descuento, des_comentario)
		select   idu_Puesto, idu_Seccion, idu_parentesco, idu_escolaridad, por_porcentaje, des_comentario from CTL_CONFIGURACION_DESCUENTOS
		where idu_Puesto > 0 and idu_Seccion>=0 ';
		if nBusqueda!=0 then
			sConsulta:=sConsulta||' and idu_Puesto='||nBusqueda;
		end if;
		if( nFiltro!= -1) then
			sConsulta:=sConsulta||' and idu_Seccion='||nFiltro;
		end if;	
		
	end if;

	RAISE NOTICE 'notice %', sConsulta;
	execute sConsulta;

	if opc_busqueda>3 then --detallado actualizar nombre de  parentesco y estudio	
	    UPDATE tmp_obtener_concentrado_configuraciones_descuentos SET parentesco = trim(UPPER(e.des_parentesco))
	    /*case when e.idu_parentesco=11 then 'EL(ELLA) MISMO(A)' ELSE e.des_parentesco END*/
	    FROM cat_parentescos e
	    WHERE e.idu_parentesco = tmp_obtener_concentrado_configuraciones_descuentos.idu_parentesco;
	  
	    UPDATE tmp_obtener_concentrado_configuraciones_descuentos SET estudio = f.nom_escolaridad
	    FROM cat_escolaridades f
	    WHERE f.idu_escolaridad = tmp_obtener_concentrado_configuraciones_descuentos.idu_estudio;
		
	end if;

	UPDATE tmp_obtener_concentrado_configuraciones_descuentos SET NomEmpleado = TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)
	||' '||TRIM(a.apellidomaterno), Centro = a.centron , Puesto = a.pueston
	FROM sapcatalogoempleados a
	WHERE a.numempn = tmp_obtener_concentrado_configuraciones_descuentos.NumEmp;

	/*
	update 	tmp_obtener_concentrado_configuraciones_descuentos set NomEmpleadoRegistro = trim(a.nombre) || ' ' || trim(a.apellidopaterno) || ' ' || trim(a.apellidomaterno)
	from	sapcatalogoempleados a
	where	a.numempn = tmp_obtener_concentrado_configuraciones_descuentos.NumEmpRegistro;
	*/

	UPDATE tmp_obtener_concentrado_configuraciones_descuentos SET nomcentro = c.nombrecentro
	FROM sapcatalogocentros c
	WHERE c.centron = tmp_obtener_concentrado_configuraciones_descuentos.Centro;

	UPDATE tmp_obtener_concentrado_configuraciones_descuentos SET NomPuesto = b.nombre
	FROM sapcatalogopuestos b
	WHERE b.numero::integer = tmp_obtener_concentrado_configuraciones_descuentos.Puesto;

	UPDATE tmp_obtener_concentrado_configuraciones_descuentos SET nomSeccion = d.nom_seccion
	from cat_area_seccion d
	WHERE d.idu_seccion = tmp_obtener_concentrado_configuraciones_descuentos.Seccion;

	
	UPDATE tmp_obtener_concentrado_configuraciones_descuentos SET NomPuesto='TODOS LOS PUESTOS'
	WHERE tmp_obtener_concentrado_configuraciones_descuentos.Puesto=0;

	UPDATE tmp_obtener_concentrado_configuraciones_descuentos SET nomSeccion='TODAS LAS SECCIONES'
	WHERE tmp_obtener_concentrado_configuraciones_descuentos.Seccion=0;

	iRecords := (SELECT COUNT(*) FROM tmp_obtener_concentrado_configuraciones_descuentos);	
	  
	IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then

		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iRecords := (SELECT COUNT(*) FROM tmp_obtener_concentrado_configuraciones_descuentos);
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));

		sConsulta := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
		    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		    , id
		    , ' || sColumns || '
		from (
			SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
			FROM tmp_obtener_concentrado_configuraciones_descuentos
			) AS t
		where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';

		sConsulta := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
		    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		    , id
		    , ' || sColumns || '
		from (
			SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
			FROM tmp_obtener_concentrado_configuraciones_descuentos
			) AS t
		where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';	
	       
	ELSE
		sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM tmp_obtener_concentrado_configuraciones_descuentos ';
	END if;

	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;

	--RAISE NOTICE 'notice %', sConsulta;
	for returnrec in execute sConsulta loop
		RETURN NEXT returnrec;
	end loop;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_configuraciones_descuentos(integer, integer, integer, integer, integer, character varying, character varying, character varying) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_configuraciones_descuentos(integer, integer, integer, integer, integer, character varying, character varying, character varying) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_configuraciones_descuentos(integer, integer, integer, integer, integer, character varying, character varying, character varying) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_listado_configuraciones_descuentos(integer, integer, integer, integer, integer, character varying, character varying, character varying) TO postgres;
COMMENT ON FUNCTION fun_obtener_listado_configuraciones_descuentos(integer, integer, integer, integer, integer, character varying, character varying, character varying) IS 'FUNCION PARA OBTENER EL LISTADO DE CONFIGURACIONES DESCUENTOS';