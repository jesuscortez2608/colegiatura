-- Function: public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer)

-- DROP FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_obtener_datos_por_escuela_empleado(IN iopcion integer, IN crfc character, IN iempleado integer, IN ibeneficiario integer, IN itipobeneficiario integer, IN iescolaridad integer, OUT iid integer, OUT snombre character, OUT itipo integer, OUT ivalor integer, OUT ibloqueado integer)
  RETURNS SETOF record AS
$BODY$
DECLARE	
	valor record;	
BEGIN
	
	/**
	--PARAMETROS DE ENTRADA
	iOpcion:
	crfc:
	iempleado:
	ibeneficiario:
	iescolaridad:
	
	ejemplo:
	SELECT * FROM FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO(1,'E5CU3L4NU3V4X',94827443,0,0, 0) --Beneficiarios
	SELECT * FROM FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO(2,'E5CU3L4NU3V4X',94827443,2,0, 0) --Escolaridades
	SELECT * FROM FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO(2,'E5CU3L4NU3V4X',94827443,1,1, 0) --Escolaridades
	SELECT * FROM FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO(3,'E5CU3L4NU3V4X',94827443,2,0, 5) --Grados Escolares
	SELECT * FROM FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO(4,'E5CU3L4NU3V4X',94827443,1,0, 0) --Carrera
	SELECT * FROM FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO(5,'E5CU3L4NU3V4X',94827443,1,0, 0) --Ciclo Escolar
	select * from FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO(5,'E5CU3L4NU3V4X',94827443,2, 0, 0)
	*/

	--TABLA TEMPORAL
	CREATE TEMP TABLE tmp(
		clave integer not null default 0,
		nombre varchar(100) not null default '',
		tipo integer not null default 0,
		numero integer not null default 0,		
		bloqueado integer not null default 0
	) ON COMMIT DROP;

	
	if (iopcion=1) then 
	--OBTENER BENEFICIARIOS POR ESCUELA-EMPLEADO
		/**
		CLAVE=	idBeneficiario
		NOMBRE=	nombre beneficiario
		TIPO=	indica si viene de la hoja azul o del catalogo
		NUMERO=	Nos da el valor del parentesco que tenga el beneficiario
		*/
		--ESTUDIOS BENEFICIARIOS
		INSERT 	INTO tmp(clave,tipo)
		SELECT 	distinct idu_beneficiario, opc_tipo_beneficiario
		FROM 	CAT_ESCUELAS_COLEGIATURAS A 
		INNER 	JOIN CAT_ESTUDIOS_BENEFICIARIOS B ON A.idu_escuela=B.idu_escuela
		WHERE 	A.rfc_clave_sep=crfc
			AND B.idu_empleado=iempleado;

		--HOJA AZUL
		UPDATE 	tmp SET nombre=B.nombre || ' ' || B.apellidopaterno || ' ' || B.apellidomaterno, numero=B.parentesco
		FROM	SAPFAMILIARHOJAS B
		WHERE	tmp.clave=B.keyx 
				AND B.numemp=iempleado
				AND tmp.tipo=0
				AND B.beneficiarioactivo= 1;

		--CAT BENEFICIARIOS
		UPDATE 	tmp SET nombre=B.nom_beneficiario || ' ' || B.ape_paterno || ' ' || B.ape_materno, numero=B.idu_parentesco
		FROM	CAT_BENEFICIARIOS_COLEGIATURAS B
		WHERE	tmp.clave=B.idu_beneficiario 
				AND B.idu_empleado=iempleado
				AND tmp.tipo=1;	
	elsif (iopcion=2) then 
	--OBTENER ESCOLARIDADES POR ESCUELA-EMPLEADO
		/**
		CLAVE=	idEscolaridad
		NOMBRE=	nombre escolaridad
		TIPO=	opc_carrera
		NUMERO=	id de la escuela
		*/
		INSERT 	INTO tmp(clave, numero, bloqueado)
		SELECT 	distinct B.idu_escolaridad
			, A.idu_escuela, A.opc_escuela_bloqueada
		FROM  	CAT_ESCUELAS_COLEGIATURAS A 
		INNER 	JOIN CAT_ESTUDIOS_BENEFICIARIOS B ON A.idu_escuela=B.idu_escuela
		WHERE 	A.rfc_clave_sep=crfc
			AND B.idu_empleado=iempleado
			AND B.idu_beneficiario=ibeneficiario
			and opc_tipo_beneficiario=itipobeneficiario;

		--ESCOLARIDADES 
		update	tmp set nombre=B.nom_escolaridad, tipo=B.opc_carrera
		from	CAT_ESCOLARIDADES B
		where	tmp.clave=B.idu_escolaridad;
	elsif (iopcion=3) then
	--OBTENER GRADO ESCOLAR
		/**
		CLAVE=	id Grado escolar
		NOMBRE=	nombre grado escolar
		TIPO=	0
		NUMERO=	0
		*/
		--
		insert 	into tmp (clave)
		select 	--A.idu_escolaridad, 
			distinct A.idu_grado_escolar 
		from 	CAT_ESTUDIOS_BENEFICIARIOS A
		inner	join CAT_ESCUELAS_COLEGIATURAS B on A.idu_escuela=B.idu_escuela
		where	A.idu_empleado=iempleado
			AND A.idu_beneficiario=ibeneficiario
			and A.opc_tipo_beneficiario=itipobeneficiario
			and A.idu_escolaridad=iescolaridad;	

		--
		update 	tmp set nombre=B.nom_grado_escolar
		from	CAT_GRADOS_ESCOLARES B
		where	idu_escolaridad=iescolaridad
			and tmp.clave=B.idu_grado_escolar;
		
	elsif (iopcion=4) then		
	--OBTENER CARRERAS POR ESCUELA-EMPLEADO
		/**
		CLAVE=	idCarrera
		NOMBRE=	nombre carrera
		TIPO=	0
		NUMERO=	0
		*/
		insert 	into tmp (clave)
		select 	DISTINCT A.idu_carrera
		from 	CAT_ESTUDIOS_BENEFICIARIOS A
		inner	join CAT_ESCUELAS_COLEGIATURAS B on A.idu_escuela=B.idu_escuela
		where	B.rfc_clave_sep=crfc
			AND A.idu_empleado=iempleado
			AND A.idu_beneficiario=ibeneficiario
			--and A.opc_tipo_beneficiario=itipobeneficiario
			and A.idu_carrera>0;

		UPDATE 	tmp set nombre=B.nom_carrera
		from	CAT_CARRERAS B 
		where	tmp.clave=B.idu_carrera;
	else
	--OBTENER CICLOS ESCOLARES
		/**
		CLAVE=	idCarrera
		NOMBRE=	nombre carrera
		TIPO=	0
		NUMERO=	0
		*/
		insert 	into tmp (clave)
		select 	DISTINCT A.idu_ciclo_escolar
		from 	CAT_ESTUDIOS_BENEFICIARIOS A
		inner	join CAT_ESCUELAS_COLEGIATURAS B on A.idu_escuela=B.idu_escuela
		where	B.rfc_clave_sep=crfc
			AND A.idu_empleado=iempleado
			AND A.idu_beneficiario=ibeneficiario
			and A.opc_tipo_beneficiario=itipobeneficiario;	

		UPDATE 	tmp set nombre=B.des_ciclo_escolar
		from	CAT_CICLOS_ESCOLARES B 
 		where	tmp.clave=B.idu_ciclo_escolar;

		--select * from CAT_CICLOS_ESCOLARES limit 1
			
	end if;

			
	--RETORNA VALOR DE UNA CADENA DE CONSULTA
	FOR valor IN (SELECT clave, nombre, tipo, numero, bloqueado FROM tmp ORDER BY nombre)
	LOOP
		iid:=valor.clave;
		snombre:=valor.nombre;
		itipo:=valor.tipo;
		ivalor:=valor.numero;	
		ibloqueado:=valor.bloqueado;			
	RETURN NEXT;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
ALTER FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer)
  OWNER TO postgres;
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO postgres;
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO "94804851";
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO "93917295";
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO "97231843";
GRANT EXECUTE ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) TO "98450221";
COMMENT ON FUNCTION public.fun_obtener_datos_por_escuela_empleado(integer, character, integer, integer, integer, integer) IS 'La función obtiene datos de acuerdo a la escuela y el numero de empleado.';
