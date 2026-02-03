CREATE OR REPLACE FUNCTION public.fun_obtener_beneficiarios_por_factura(icolaborador integer, ifactura integer, OUT idu_hoja_azul integer, OUT idu_beneficiario integer, OUT nom_beneficiario character varying, OUT idu_parentesco integer, OUT nom_parentesco character varying, OUT idu_tipo_pago integer, OUT des_tipo_pago character varying, OUT nom_periodo text, OUT idu_escolaridad integer, OUT nom_escolaridad character varying, OUT idu_carrera integer, OUT nom_carrera character varying, OUT idu_grado integer, OUT nom_grado character varying, OUT idu_ciclo integer, OUT nom_ciclo_escolar character varying, OUT imp_importe numeric, OUT descuento integer, OUT comentario text, OUT keyx integer, OUT fec_nac_beneficiario date, OUT edad_anio_beneficiario integer, OUT edad_mes_beneficiario integer)
 RETURNS SETOF record
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
	sQuery text;
	NumPeriodos integer = 0;
	Cnt integer = 0;
	TextoPeriodos text = '';

	rec record;
BEGIN

	create local temporary table tmp_detalles_facturas(
		idfactura integer not null default 0
		, idu_hoja_azul integer not null default 1
		, idu_beneficiario integer not null default 0
		, nom_beneficiario character varying(150) not null default ''
		, idu_parentesco integer not null default 0
		, nom_parentesco character varying(20) not null default ''
		, idu_tipo_pago integer not null default 0
		, des_tipo_pago character varying(20) not null default ''
		, idu_periodo text not null default ''
		, nom_periodo text not null default ''
		, idu_escolaridad integer not null default 0
		, nom_escolaridad character varying(30) not null default ''
		, idu_carrera integer not null default 0
		, nom_carrera character varying(100) not null default ''
		, idu_grado integer not null default 0
		, nom_grado character varying(50) not null default ''
		, idu_ciclo integer not null default 0
		, nom_ciclo_escolar character varying(30) not null default ''
		, imp_importe numeric(12,2)
		, descuento integer
		, comentario text not null default ''
		, keyx integer
		, fec_nac_beneficiario date
		, edad_anio_beneficiario integer
		, edad_mes_beneficiario integer
	) on commit drop;

	create local temporary table tmp_periodos_r(
		idfactura integer
		, idu_beneficiario integer
		, idu_tipopago integer
		, idu_periodo integer
		, nom_periodo character varying(50)
		, Cadena text default ''
		, keyx integer
	) on commit drop;

	create local temporary table tmp_cadena_periodos(
		idu_beneficiario integer
		, cadena text default ''
		, idu_tipopago integer
		, idu_periodo integer
		, keyx integer
	) on commit drop;

	insert into tmp_detalles_facturas(
		idfactura
		, idu_beneficiario
		, idu_parentesco
		, idu_tipo_pago
		, idu_periodo
		, idu_escolaridad
		, idu_carrera
		, idu_grado
		, idu_ciclo
		, imp_importe
		, descuento
		, keyx)
	SELECt	mov.idfactura
		, mov.idu_beneficiario
		, mov.idu_parentesco
		, mov.idu_tipopago
		, mov.periodo
		, mov.idu_escolaridad
		, mov.idu_carrera
		, mov.idu_grado_escolar
		, mov.idu_ciclo_escolar
		, mov.importe_concepto
		, mov.prc_descuento
		, mov.keyx
	FROM	MOV_DETALLE_FACTURAS_COLEGIATURAS AS mov
	WHERE	mov.idu_empleado = iColaborador
		AND mov.idFactura = iFactura;

	IF ((SELECT COUNT(*) FROM tmp_detalles_facturas) = 0 ) then --HISTORICO
		insert into tmp_detalles_facturas(
			idfactura
			, idu_beneficiario
			, idu_parentesco
			, idu_tipo_pago
			, idu_periodo
			, idu_escolaridad
			, idu_carrera
			, idu_grado
			, idu_ciclo
			, imp_importe
			, descuento
			, keyx)
		SELECt	his.idfactura
			, his.idu_beneficiario
			, his.idu_parentesco
			, his.idu_tipopago
			, his.periodo
			, his.idu_escolaridad
			, his.idu_carrera
			, his.idu_grado_escolar
			, his.idu_ciclo_escolar
			, his.importe_concepto
			, his.prc_descuento
			, his.keyx
		FROM	HIS_DETALLE_FACTURAS_COLEGIATURAS AS his
		WHERE	his.idu_empleado = iColaborador
			AND his.idFactura = iFactura;
	END IF;

	--Actualizar parentesco
	UPDATE	tmp_detalles_facturas
	set	nom_parentesco = TRIM(UPPER(a.des_parentesco))
	FROM	cat_parentescos AS a
	where	a.idu_parentesco = tmp_detalles_facturas.idu_parentesco;

	-- Actualizar Escolaridad
	UPDATE	tmp_detalles_facturas
	set	nom_escolaridad = TRIM(UPPER(a.nom_escolaridad))
	from	cat_escolaridades AS a
	WHERE	a.idu_escolaridad = tmp_detalles_facturas.idu_escolaridad;

	-- Actualizar Nombre de Carrera
	UPDATE	tmp_detalles_facturas
	set	nom_carrera = TRIM(UPPER(a.nom_carrera))
	FROM	cat_carreras AS a
	WHERE	a.idu_carrera = tmp_detalles_facturas.idu_carrera;

	-- Actualizar Grado Escolar
	UPDATE	tmp_detalles_facturas
	set	nom_grado = TRIM(UPPER(a.nom_grado_escolar))
	FROM	cat_grados_escolares AS a
	WHERE	A.idu_grado_escolar = tmp_detalles_facturas.idu_grado
		AND a.idu_escolaridad = tmp_detalles_facturas.idu_escolaridad;

	-- Actualizar Ciclo Escolar
	update	tmp_detalles_facturas
	set	nom_ciclo_escolar = a.des_ciclo_escolar
	from	cat_ciclos_escolares AS a
	where	a.idu_ciclo_escolar = tmp_detalles_facturas.idu_ciclo;

	-- Actualizar Tipo de Pago
	UPDATE	tmp_detalles_facturas
	set	des_tipo_pago = TRIM(UPPER(a.des_tipo_pago))
	FROM	cat_tipos_pagos AS a
	WHERE	a.idu_tipo_pago = tmp_detalles_facturas.idu_tipo_pago;

	-- Nombre de los beneficiarios especiales
	UPDATE	tmp_detalles_facturas
	set	nom_beneficiario = TRIM(UPPER(b.nom_beneficiario)) || ' ' || COALESCE(TRIM(UPPER(b.ape_paterno)),'') || ' ' || COALESCE(TRIM(UPPER(b.ape_materno)),'')
		, idu_hoja_azul = 0
		, comentario = CASE WHEN b.opc_becado_especial = 1 THEN b.des_observaciones ELSE '' END
	FROM	cat_beneficiarios_colegiaturas AS b
	where	b.idu_empleado = iColaborador
		AND b.idu_beneficiario = tmp_detalles_facturas.idu_beneficiario;

	-- Beneficiario Hoja Azul
	UPDATE	tmp_detalles_facturas
	set		nom_beneficiario = TRIM(UPPER(b.nombre)) || ' ' || COALESCE(TRIM(UPPER(b.apellidopaterno)),'') || ' ' || COALESCE(TRIM(UPPER(b.apellidomaterno)),''), 
			fec_nac_beneficiario = fechanacimiento, edad_anio_beneficiario = DATE_PART('year',age(now(), fechanacimiento)), edad_mes_beneficiario = DATE_PART('month',age(now(), fechanacimiento)) 
	FROM	sapfamiliarhojas AS b
	WHERE	numemp = iColaborador
			--AND b.keyx = tmp_detalles_facturas.idu_beneficiario and b.beneficiarioactivo=1;
			AND (b.keyx = tmp_detalles_facturas.idu_beneficiario OR b.idhoja_azul = tmp_detalles_facturas.idu_beneficiario) AND b.beneficiarioactivo=1;
	--------------------------------------------------------------------------------------------------------------------------

	-- Bloque para obtener los nombre de los periodos de pago de la factura
	INSERT INTO	tmp_periodos_r (idu_tipopago, idu_periodo, idfactura, idu_beneficiario, keyx)
	SELECT		mov.idu_tipopago
			, regexp_split_to_table(mov.periodo, ',')::INTEGER AS idu_periodo
			, mov.idfactura
			, mov.idu_beneficiario
			, mov.keyx
	FROM		MOV_DETALLE_FACTURAS_COLEGIATURAS AS mov
	WHERE		mov.idu_empleado = iColaborador
			AND mov.idfactura = iFactura;

	IF ((SELECT COUNT(*) FROM tmp_periodos_r) = 0 ) then --HISTORICO

		INSERT INTO	tmp_periodos_r (idu_tipopago, idu_periodo, idfactura, idu_beneficiario, keyx)
		SELECT		his.idu_tipopago
				, regexp_split_to_table(his.periodo, ',')::INTEGER AS idu_periodo
				, his.idfactura
				, his.idu_beneficiario
				, his.keyx
		FROM		HIS_DETALLE_FACTURAS_COLEGIATURAS AS his
		WHERE		his.idu_empleado = iColaborador
				AND his.idfactura = iFactura;

	END IF;

	update	tmp_periodos_r
	set	nom_periodo = TRIM(UPPER(p.des_periodo))
	FROM	cat_periodos_pagos AS p
	WHERE	tmp_periodos_r.idu_tipopago = p.idu_tipo_periodo
		AND tmp_periodos_r.idu_periodo = p.idu_periodo;

	INSERT INTO	tmp_cadena_periodos(cadena, keyx)
	SELECT		string_agg(tmp.nom_periodo, ', ')
			, tmp.keyx
	FROM		tmp_periodos_r AS tmp
	GROUP 	BY	tmp.keyx;

	update	tmp_detalles_facturas
	set	nom_periodo = B.cadena
	FROM	tmp_cadena_periodos AS B
	where	tmp_detalles_facturas.keyx = B.keyx;

	FOR rec IN ( SELECT tmp.idu_hoja_azul
			  , tmp.idu_beneficiario
			  , tmp.nom_beneficiario
			  , tmp.idu_parentesco
			  , tmp.nom_parentesco
			  , tmp.idu_tipo_pago
			  , tmp.des_tipo_pago
			  , tmp.nom_periodo
			  , tmp.idu_escolaridad
			  , tmp.nom_escolaridad
			  , tmp.idu_carrera
			  , tmp.nom_carrera
			  , tmp.idu_grado
			  , tmp.nom_grado
			  , tmp.idu_ciclo
			  , tmp.nom_ciclo_escolar
			  , tmp.imp_importe
			  , tmp.descuento
			  , tmp.comentario
			  , tmp.keyx
			  , tmp.fec_nac_beneficiario
			  , tmp.edad_anio_beneficiario
			  , tmp.edad_mes_beneficiario
			FROM tmp_detalles_facturas AS tmp ORDER BY keyx)
		LOOP
			idu_hoja_azul	 := rec.idu_hoja_azul;
			idu_beneficiario := rec.idu_beneficiario;
			nom_beneficiario := rec.nom_beneficiario;
			idu_parentesco   := rec.idu_parentesco;
			nom_parentesco   := rec.nom_parentesco;
			idu_tipo_pago    := rec.idu_tipo_pago;
			des_tipo_pago    := rec.des_tipo_pago;
			nom_periodo      := rec.nom_periodo;
			idu_escolaridad  := rec.idu_escolaridad;
			nom_escolaridad  := rec.nom_escolaridad;
			idu_carrera	 := rec.idu_carrera;
			nom_carrera	 := rec.nom_carrera;
			idu_grado        := rec.idu_grado;
			nom_grado        := rec.nom_grado;
			idu_ciclo        := rec.idu_ciclo;
			nom_ciclo_escolar:= rec.nom_ciclo_escolar;
			imp_importe      := rec.imp_importe;
			descuento        := rec.descuento;
			comentario       := rec.comentario;
			keyx             := rec.keyx;
			fec_nac_beneficiario := rec.fec_nac_beneficiario;
			edad_anio_beneficiario := rec.edad_anio_beneficiario;
			edad_mes_beneficiario := rec.edad_mes_beneficiario;
			RETURN NEXT;
		END LOOP;
END;
$function$
