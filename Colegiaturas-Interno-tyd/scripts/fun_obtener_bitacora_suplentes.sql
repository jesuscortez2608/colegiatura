CREATE OR REPLACE FUNCTION fun_obtener_bitacora_suplentes(
	IN iempleado integer, 
	IN iempleadosuplente integer, 
	IN iindefinido integer, 
	IN cfechainicial date, 
	IN cfechafinal date, 
	OUT idu_id integer, 
	OUT idu_empleado integer, 
	OUT nom_empleado character, 
	OUT idu_puesto integer, 
	OUT nom_puesto character, 
	OUT idu_centro integer, 
	OUT nom_centro character, 
	OUT idu_suplente integer, 
	OUT nom_suplente character, 
	OUT idu_puesto_suplente integer, 
	OUT nom_puesto_suplente character, 
	OUT idu_centro_suplente integer, 
	OUT nom_centro_suplente character, 
	OUT idu_empleado_registro integer, 
	OUT nom_empleado_registro character, 
	OUT fec_registro character, 
	OUT fec_inicial character, 
	OUT fec_final character, 
	OUT opc_indefinido integer, 
	OUT nom_indefinido character, 
	OUT opc_expirado integer, 
	OUT fecha_baja character, 
	OUT opc_cancelado character, 
	OUT idu_empleado_cancelo integer, 
	OUT nom_empleado_cancelo character)
  RETURNS SETOF record AS
$BODY$

DECLARE
	
	valor record;	
	sSql TEXT;
/*
	No. petición APS               : 8613.1
	Fecha                          : 06/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento : Regresa los registros de la tabla  mov_bitacora_suplentes.
	Descripción del cambio         : NA
	Sistema                        : Colegiaturas
	Módulo                         : Configuración de Suplentes
	Modifica 		       : Omar Alejandro Lizárrga Hernández 94827443
	Petición		       : 16559
	Ejemplo                        : 
	SELECT * FROM fun_obtener_bitacora_suplentes(93902761,93902727,2,CAST('19000101' AS DATE),CAST('19000101' AS date));	
	SELECT * FROM fun_obtener_bitacora_suplentes(0,0,2,CAST('19000101' AS DATE),CAST('19000101' AS date))		 
*/
BEGIN

	CREATE TEMP TABLE tmp_Suplentes(
		id_id INTEGER NOT NULL DEFAULT 0,
		id_empleado INTEGER, 
		nombre_empleado VARCHAR(150), 
		id_puesto INTEGER, 
		nombre_puesto VARCHAR(50),
		id_centro INTEGER, 
		nombre_centro VARCHAR(50),
		id_suplente INTEGER,
		nombre_suplente VARCHAR(150),
		id_puesto_suplente INTEGER,
		nombre_puesto_suplente VARCHAR(50),
		id_centro_suplente INTEGER,
		nombre_centro_suplente VARCHAR(50),
		id_empleado_registro INTEGER,
		nombre_empleado_registro VARCHAR(150),
		fecha_registro VARCHAR(10), 
		fecha_reg date,
		fecha_inicial  VARCHAR(10), 
		fecha_final  VARCHAR(10), 
		indefinido INTEGER,
		nombre_indefinido VARCHAR(50) DEFAULT '',
		expirado integer,
		fechabaja varchar(10),
		cancelado_sup char(1),
		id_empleado_cancelo integer,
		nombre_empleado_cancelo character
		
	)on commit drop;

	sSql := ('INSERT INTO tmp_Suplentes (id_id ,id_empleado, id_suplente, id_empleado_registro, fecha_registro, fecha_reg, fecha_inicial, fecha_final, indefinido)
	SELECT id,idu_empleado, idu_suplente, idu_empleado_registro ,to_char(fec_registro,'''||'dd/MM/yyyy'||'''),fec_registro,to_char(fec_inicial,'''||'dd/MM/yyyy'||'''),
	to_char(fec_final,'''||'dd/MM/yyyy'||'''), opc_indefinido FROM mov_suplentes_colegiaturas WHERE 1=1 ');

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

	RAISE NOTICE '%',sSql;
	EXECUTE sSql;

	--EMPLEADOS
	UPDATE 	tmp_Suplentes SET nombre_empleado=TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)||' '||TRIM(a.apellidomaterno) ,id_puesto=a.pueston, id_centro=a.centron 
	FROM 	sapcatalogoempleados a 
	WHERE 	tmp_Suplentes.id_empleado=a.numempn;

	--SUPLENTE
	UPDATE 	tmp_Suplentes SET nombre_suplente=TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)||' '||TRIM(a.apellidomaterno), id_puesto_suplente=a.pueston, id_centro_suplente=a.centron, 
		 fechabaja='19000101',cancelado_sup=a.cancelado,
		expirado=0, id_empleado_cancelo=0, nombre_empleado_cancelo=''
	FROM 	sapcatalogoempleados a 
	WHERE 	tmp_Suplentes.id_suplente=a.numempn;

	--
	UPDATE 	tmp_Suplentes SET fechabaja=to_char(a.fechabaja,'dd/MM/yyyy')
	FROM 	sapcatalogoempleados a
	WHERE 	tmp_Suplentes.id_suplente=a.numempn AND tmp_Suplentes.cancelado_sup='1'; 
		

	--EMPLEADO REGISTRO
	UPDATE 	tmp_Suplentes SET nombre_empleado_registro=TRIM(a.nombre)||' '||TRIM(a.apellidopaterno)||' '||TRIM(a.apellidomaterno)
	FROM 	sapcatalogoempleados a 
	WHERE 	tmp_Suplentes.id_empleado_registro=a.numempn;

	--PUESTO EMPLEADO
	UPDATE 	tmp_Suplentes SET nombre_puesto=TRIM(a.nombre) 
	FROM 	sapcatalogopuestos a 
	WHERE 	tmp_Suplentes.id_puesto=a.numero::integer;

	--PUESTO SUPLENTE
	UPDATE 	tmp_Suplentes SET nombre_puesto_suplente=TRIM(a.nombre) 
	FROM 	sapcatalogopuestos a 
	WHERE 	tmp_Suplentes.id_puesto_suplente=a.numero::integer;
	
	--NOMBRE CENTRO
	UPDATE 	tmp_Suplentes SET nombre_centro=TRIM(a.nombrecentro) 
	FROM 	sapcatalogocentros a 
	WHERE 	tmp_Suplentes.id_centro=a.centron;

	--CENTRO SUPLENTE
	UPDATE 	tmp_Suplentes SET nombre_centro_suplente=TRIM(a.nombrecentro) 
	FROM 	sapcatalogocentros a 
	WHERE 	tmp_Suplentes.id_centro_suplente=a.centron;
		
	FOR valor IN (SELECT 	id_id, id_empleado, nombre_empleado, id_puesto, nombre_puesto, id_centro, nombre_centro, id_suplente,
				nombre_suplente, id_puesto_suplente, nombre_puesto_suplente, id_centro_suplente, nombre_centro_suplente, 
				id_empleado_registro, nombre_empleado_registro, fecha_registro,
				CASE WHEN fecha_inicial='01/01/1900' THEN '' ELSE fecha_inicial END as fecha_inicial,
				CASE WHEN fecha_final='01/01/1900' THEN '' ELSE fecha_final END as fecha_final, indefinido, 
				CASE WHEN indefinido=1 THEN 'SI' ELSE '' END AS nombre_indefinido, expirado, fechabaja,cancelado_sup, id_empleado_cancelo, nombre_empleado_cancelo
			FROM 	tmp_Suplentes 
			ORDER 	BY fec_registro asc)			
	LOOP
		idu_id := valor.id_id;
		idu_empleado :=valor.id_empleado; 
		nom_empleado :=valor.nombre_empleado;
		idu_puesto :=valor.id_puesto; 
		nom_puesto :=valor.nombre_puesto;
		idu_centro :=valor.id_centro; 
		nom_centro :=valor.nombre_centro;
		idu_suplente :=valor.id_suplente;
		nom_suplente :=valor.nombre_suplente;
		idu_puesto_suplente :=valor.id_puesto_suplente;
		nom_puesto_suplente :=valor.nombre_puesto_suplente;
		idu_centro_suplente :=valor.id_centro_suplente;
		nom_centro_suplente :=valor.nombre_centro_suplente;
		idu_empleado_registro:=valor.id_empleado_registro;
		nom_empleado_registro:=valor.nombre_empleado_registro;
		fec_registro :=valor.fecha_registro; 
		--fechaRegistro:=valor.fecha_reg;
		fec_inicial:=valor.fecha_inicial; 
		fec_final:=valor.fecha_final; 
		opc_indefinido:=valor.indefinido;
		nom_indefinido :=valor.nombre_indefinido;
		opc_expirado :=valor.expirado;
		fecha_baja:=valor.fechabaja;
		opc_cancelado :=valor.cancelado_sup;
		idu_empleado_cancelo :=valor.id_empleado_cancelo;
		nom_empleado_cancelo :=valor.nombre_empleado_cancelo;
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_suplentes(integer, integer, integer, date, date) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_suplentes(integer, integer, integer, date, date) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_suplentes(integer, integer, integer, date, date) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_bitacora_suplentes(integer, integer, integer, date, date) TO postgres;
