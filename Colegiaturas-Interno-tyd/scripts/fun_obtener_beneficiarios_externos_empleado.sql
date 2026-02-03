CREATE OR REPLACE FUNCTION fun_obtener_beneficiarios_externos_empleado(
IN iempleado integer
, OUT opc_seleccionado integer
, OUT idu_beneficiario integer
, OUT idu_empleado integer
, OUT nom_beneficiario character varying
, OUT fec_registro character varying
, OUT idu_empleado_registro integer
, OUT nom_empleado_registro character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE
	/*
	No.Petición:			16559.1
	Fecha:					30/04/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:						PERSONAL    
	Servidor:				10.44.2.183
	Sistema:				Colegiaturas
	Modulo: 				Asignar Externos a Colaborador
	Ejemplo: 
		SELECT * FROM fun_obtener_beneficiarios_externos_empleado(95194185)	--> Regresa el listado de los beneficiarios externos, y cuales de ellos estan asignados con el Empleado(opc_seleccionado = 1)
		SELECT * FROM fun_obtener_beneficiarios_externos_empleado(0)		--> Regresa el listado general de los beneficiarios externos
	------------------------------------------------------------------------------------------------------ */
	rec record;
	sQuery TEXT;
BEGIN
        
	create temp table tmp_beneficiarios_externos (opc_seleccionado INTEGER
        , idu_beneficiario INTEGER
	, idu_empleado integer
        , nom_beneficiario VARCHAR
        , fec_registro character varying(20)
        , idu_empleado_registro INTEGER
        , nom_empleado_registro VARCHAR
	) on commit drop;
    
	INSERT INTO tmp_beneficiarios_externos (opc_seleccionado, idu_beneficiario, idu_empleado, nom_beneficiario, fec_registro, nom_empleado_registro)
        SELECT 0 AS opc_seleccionado
            , ext.idu_beneficiario
	    , ext.idu_empleado
            , ext.nom_empleado
            , '1900-01-01'::character varying
            , ''
        FROM cat_beneficiarios_externos AS ext;
    
    UPDATE	tmp_beneficiarios_externos
		SET opc_seleccionado = 1
		, fec_registro = to_char(mov.fec_registro, 'dd/mm/yyyy')
		, idu_empleado_registro = mov.idu_empleado_registro
    FROM	mov_beneficiarios_asignados AS mov
    WHERE	mov.idu_beneficiario = tmp_beneficiarios_externos.idu_beneficiario
		AND mov.idu_empleado = iEmpleado;
    
    UPDATE	tmp_beneficiarios_externos
		SET nom_empleado_registro = trim(emp.nombre) || ' ' || trim(emp.apellidopaterno) || ' ' || trim(emp.apellidomaterno)
    FROM	sapcatalogoempleados as emp
    WHERE 	emp.numempn = tmp_beneficiarios_externos.idu_empleado_registro;
    
    FOR rec IN (SELECT tmp.opc_seleccionado
            , tmp.idu_beneficiario
            , tmp.idu_empleado
            , tmp.nom_beneficiario
            , tmp.fec_registro
            , tmp.idu_empleado_registro
            , tmp.nom_empleado_registro
        FROM tmp_beneficiarios_externos as tmp
        ORDER BY tmp.opc_seleccionado DESC) 
        LOOP
		opc_seleccionado	:=	rec.opc_seleccionado;
		idu_beneficiario	:=	rec.idu_beneficiario;
		idu_empleado		:=	rec.idu_empleado;
		nom_beneficiario	:=	rec.nom_beneficiario;
		fec_registro		:=	rec.fec_registro;
		idu_empleado_registro	:=	rec.idu_empleado_registro;
		nom_empleado_registro	:=	rec.nom_empleado_registro;
        RETURN NEXT;
    END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_externos_empleado(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_externos_empleado(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_externos_empleado(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_beneficiarios_externos_empleado(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_beneficiarios_externos_empleado(integer) IS 'La función obtiene un listado con los externos asignados a un colaborador, más los externos que están por asignarse.';