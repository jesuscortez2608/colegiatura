DROP FUNCTION IF EXISTS fun_obtener_bitacora_suplentes_historial(integer, integer, integer,date,date);
DROP TYPE IF EXISTS type_bitacora_suplentes_historial;

CREATE TYPE type_bitacora_suplentes_historial AS
   (
    idu_empleado integer,
    nom_empleado character varying(150),
    idu_puesto integer,
    nom_puesto character varying(50),
    idu_centro integer,
    nom_centro character varying(50),
    idu_suplente integer,
    nom_suplente character varying(150),
    idu_puesto_suplente integer,
    nom_puesto_suplente character varying(50),
    idu_centro_suplenete integer,
    nom_centro_suplente character varying(50),
    idu_empleado_registro integer,
    nom_empleado_registro character varying(150),
    fec_registro character varying(10),
    fec_inicial character varying(10),
    fec_final character varying(10),
    opc_indefinido varchar (2),
    opc_expirado integer,
    opc_cancelado integer,
    idu_empleado_cancelo integer,
    nom_empleado_cancelo character varying(150));

CREATE OR REPLACE FUNCTION fun_obtener_bitacora_suplentes_historial(integer, integer, integer,date,date)
 RETURNS SETOF 	type_bitacora_suplentes_historial AS
$BODY$

DECLARE
	iEmpleado ALIAS FOR $1;
	iEmpleadoSuplente ALIAS FOR $2;
	iIndefinido ALIAS FOR $3;
	cFechaInicial ALIAS FOR $4;
	cFechaFinal ALIAS FOR $5;
	registros type_bitacora_suplentes_historial;
	sSql VARCHAR;
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 06/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Regresa los registros de la tabla  mov_bitacora_suplentes.
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Suplentes
	     Ejemplo                        : 
		 SELECT * FROM fun_obtener_bitacora_suplentes_historial(93902761,93902727,0,CAST('19000101' AS DATE),CAST('19000101' AS date));	
		 SELECT * FROM fun_obtener_bitacora_suplentes_historial(0,0,2,cast('20160915' as date),cast('20160930'as date))

		 
	*/
BEGIN
	CREATE TEMPORARY TABLE tmp_Bitacora_Suplentes(
		idu_empleado INTEGER, 
		nom_empleado VARCHAR(150), 
		idu_puesto INTEGER, 
		nom_puesto VARCHAR(50),
		idu_centro INTEGER, 
		nom_centro VARCHAR(50),
		idu_suplente INTEGER,
		nom_suplente VARCHAR(150),
		idu_puesto_suplente INTEGER,
		nom_puesto_suplente VARCHAR(50),
		idu_centro_suplente INTEGER,
		nom_centro_suplente VARCHAR(50),
		idu_empleado_registro INTEGER,
		nom_empleado_registro VARCHAR(150),
		fec_registro VARCHAR(10), 
		fec_inicial  VARCHAR(10), 
		fec_final  VARCHAR(10), 
		opc_indefinido integer, 
		opc_expirado INTEGER, 
		opc_cancelado INTEGER,
		idu_empleado_cancelo INTEGER, 
		nom_empleado_cancelo VARCHAR(150)
	)on commit drop;

	sSql := ('INSERT INTO tmp_Bitacora_Suplentes (idu_empleado, idu_suplente, idu_empleado_registro, fec_registro, fec_inicial, 
	fec_final, opc_indefinido, opc_expirado, opc_cancelado,  idu_empleado_cancelo)
	SELECT idu_empleado, idu_suplente, idu_empleado_registro ,to_char(fec_registro,'''||'dd/MM/yyyy'||'''),to_char(fec_inicial,'''||'dd/MM/yyyy'||'''),to_char(fec_final,'''||'dd/MM/yyyy'||'''),
	opc_indefinido, opc_expirado, opc_cancelado, idu_empleado_cancelo FROM mov_bitacora_suplentes WHERE 1=1 ');

	IF (iEmpleado!=0) THEN
		sSql :=sSql||' AND idu_empleado='||iEmpleado;
	END IF;
	IF (iEmpleadoSuplente!=0) THEN
		sSql :=sSql||' AND idu_suplente='||iEmpleadoSuplente;
	END IF;

	IF (iIndefinido!=2) THEN
		sSql :=sSql||' AND opc_indefinido='||iIndefinido;
	END IF;

	IF(cFechaInicial!='19000101') THEN
		sSql :=sSql||' AND CAST(fec_inicial AS DATE)>= '''||cFechaInicial||''' AND fec_final<='''||cFechaFinal||''' ';
	END IF;

	
	EXECUTE sSql;

	UPDATE tmp_Bitacora_Suplentes SET nom_empleado=TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)||' '||TRIM(a.apellidomaterno)
	,idu_puesto=a.pueston, idu_centro=a.centron FROM sapcatalogoempleados a WHERE tmp_Bitacora_Suplentes.idu_empleado=a.numempn;

	UPDATE tmp_Bitacora_Suplentes SET nom_suplente=TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)||' '||TRIM(a.apellidomaterno), idu_puesto_suplente=a.pueston,
	idu_centro_suplente=a.centron FROM sapcatalogoempleados a WHERE tmp_Bitacora_Suplentes.idu_suplente=a.numempn;

	UPDATE tmp_Bitacora_Suplentes SET nom_empleado_registro=TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)||' '||TRIM(a.apellidomaterno)
	FROM sapcatalogoempleados a WHERE tmp_Bitacora_Suplentes.idu_empleado_registro=a.numempn;

	UPDATE tmp_Bitacora_Suplentes SET nom_empleado_cancelo=TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)||' '||TRIM(a.apellidomaterno)
	FROM sapcatalogoempleados a WHERE tmp_Bitacora_Suplentes.idu_empleado_cancelo=a.numempn;

	UPDATE tmp_Bitacora_Suplentes SET nom_puesto=TRIM(a.nombre) FROM sapcatalogopuestos a WHERE tmp_Bitacora_Suplentes.idu_puesto=a.numero::integer;

	UPDATE tmp_Bitacora_Suplentes SET nom_puesto_suplente=TRIM(a.nombre) FROM sapcatalogopuestos a WHERE tmp_Bitacora_Suplentes.idu_puesto_suplente=a.numero::integer;

	UPDATE tmp_Bitacora_Suplentes SET nom_centro=TRIM(a.nombrecentro) FROM sapcatalogocentros a WHERE tmp_Bitacora_Suplentes.idu_centro=a.centron;

	UPDATE tmp_Bitacora_Suplentes SET nom_centro_suplente=TRIM(a.nombrecentro) FROM sapcatalogocentros a WHERE tmp_Bitacora_Suplentes.idu_centro_suplente=a.centron;
	
	FOR registros IN 
		SELECT idu_empleado, nom_empleado, idu_puesto, nom_puesto, idu_centro, nom_centro, idu_suplente,
		nom_suplente, idu_puesto_suplente, nom_puesto_suplente, idu_centro_suplente, nom_centro_suplente, 
		idu_empleado_registro, nom_empleado_registro, fec_registro,fec_inicial, 
		fec_final, CASE WHEN opc_indefinido=1 THEN 'SI' ELSE 'NO' END, opc_expirado, opc_cancelado, idu_empleado_cancelo, 
		nom_empleado_cancelo FROM tmp_Bitacora_Suplentes ORDER BY fec_inicial
	LOOP
		RETURN NEXT registros;
	END LOOP;


END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_suplentes_historial(integer, integer, integer,date,date) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_suplentes_historial(integer, integer, integer,date,date) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_suplentes_historial(integer, integer, integer,date,date) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_suplentes_historial(integer, integer, integer,date,date) TO postgres;