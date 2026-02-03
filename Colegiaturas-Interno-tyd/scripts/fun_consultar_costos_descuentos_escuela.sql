-- ANTERIOR
DROP FUNCTION IF EXISTS fun_consultar_costos_descuentos_escuela(integer, integer, integer);
-- ACTUAL
DROP FUNCTION IF EXISTS fun_consultar_costos_descuentos_escuela(integer, integer, character varying, integer);

CREATE OR REPLACE FUNCTION fun_consultar_costos_descuentos_escuela(IN ifactura integer, IN icicloescolar integer, IN sescolaridad character varying, IN iopcion integer, OUT snom_escuela character varying, OUT iidcicloescolar integer, OUT sciclo_escolar character varying, OUT iidescolaridad integer, OUT snom_escolaridad character varying, OUT iidcarrera integer, OUT snom_carrera character varying, OUT iidtpp integer, OUT stpp character varying, OUT iprc_descuento integer, OUT iimporte numeric, OUT iidmotivo integer, OUT smotivo_descto character varying, OUT sfecha_rev character varying)
  RETURNS SETOF record AS
$BODY$
DECLARE		
	valor record;
	sQuery text;
	sWhere text;
-- 	sRFC character varying(20);
	idEsc integer;
	anioactual integer;
	
	/*--------------------------------------------------------------------------------     
	No.Petición: 16559
	Fecha: 04/06/2018
	Numero Empleado: 94827443
	Nombre Empleado: Omar Alejandro Lizarraga Hernandez
	BD: Personal
	Servidor: 10.28.114.75
	Modulo: Colegiaturas
	Repositorio: 
	Descripción: Consulta las escuelas que coincidan con el RFC que se manda como parametro,
	la escuela no debe ser en linea ó extranjero es decir, idu_estado>0 
	Ejemplo: SELECT * FROM fun_consultar_escuelas_por_rfc ('AEQWE13213FSD');
	--------------------------------------------------------------------------------*/	
	BEGIN	
		--
		CREATE LOCAL TEMP TABLE tmpDatos (
			--idescuela integer,
			idescuela integer,
			sescuela varchar(100),
			idcicloescolar integer,
			ciclo_escolar VARCHAR(100),			
			idescolaridad INTEGER, 
			nom_escolaridad varchar(30),			
			idcarrera integer,
			nom_carrera varchar(100),
			idtpp integer,
			tpp varchar(50),
			prc_descuento integer,
			importe numeric(12,2),	--costo/descuento
			idmotivo integer,
			motivo_descto varchar(100),
			fecha_rev varchar(10)
		)
		ON COMMIT DROP;

		create local temp table tmp_Escuelas(
			idu_escuela integer,
			nom_escuela varchar(100),
			idu_estado integer,
			nom_estado varchar(60),
			idu_municipio integer,
			nom_municipio varchar(150),
			idu_localidad integer,
			nom_localidad varchar(60),
			srfc varchar(20)	
		) on commit drop;

-- 		sRFC := (SELECT rfc_clave from mov_facturas_colegiaturas where idfactura = ifactura);
		idEsc := (SELECT idu_escuela from MOV_FACTURAS_COLEGIATURAS where idfactura = ifactura);
		--sRFC='AEQWE13213FSD'

		insert  into tmp_Escuelas (idu_escuela,idu_estado,idu_municipio,idu_localidad,nom_escuela,srfc)
		select	idu_escuela, idu_estado, idu_municipio, idu_localidad, nom_escuela, rfc_clave_Sep
		from	CAT_ESCUELAS_COLEGIATURAS
-- 		where	rfc_clave_sep = sRFC;
		where	idu_escuela = idEsc;

		--ESCUELA DE LA MISMA LOCALIDAD CON DIFERENTE ESCOLARIDAD
		insert 	into tmp_Escuelas (idu_escuela, idu_estado, idu_municipio, idu_localidad,nom_escuela,srfc)
		select 	idu_escuela, idu_estado, idu_municipio, idu_localidad, nom_escuela, rfc_clave_Sep
		from 	CAT_ESCUELAS_COLEGIATURAS
		where	rfc_clave_Sep=(SELECT srfc FROM tmp_Escuelas)
			and idu_estado= (select idu_estado from tmp_Escuelas)
			and idu_municipio= (select idu_municipio from tmp_Escuelas)
			and idu_localidad= (select idu_localidad from tmp_Escuelas)
			and idu_escuela!=idEsc;

		if date_part('year', NOW()) = iCicloEscolar then
			IF iOpcion=1 then
				--COSTOS
				sQuery := 'INSERT 	INTO tmpDatos (idescuela, idcicloescolar, idescolaridad, idcarrera, idtpp, prc_descuento, importe, idmotivo) 
					SELECT 	idu_escuela 
						,idu_ciclo_escolar 
						, idu_escolaridad 
						, idu_Carrera 
						, idu_tipo_pago 
						, prc_descuento 
						, importe_concepto 
						, idu_motivo 
					FROM 	MOV_DETALLE_REVISION_COLEGIATURAS
					WHERE 	idu_escuela IN (SELECT idu_escuela FROM tmp_Escuelas) 
						AND prc_descuento=0';
				if (sEscolaridad = '') then
					-- 
					sWhere := ';';
				else
					-- 2,5,3
					sWhere := ' AND idu_escolaridad IN (' || sEscolaridad || ') ;';
				end if;

				sQuery := sQuery || sWhere;

				raise notice '%',sQuery;
				EXECUTE sQuery;
			ELSE
				--DESCUENTOS
				sQuery := 'INSERT 	INTO tmpDatos (idescuela,idcicloescolar, idescolaridad, idcarrera, idtpp, prc_descuento, idmotivo)
						SELECT 	idu_escuela
							,idu_ciclo_escolar
							, idu_escolaridad
							, idu_Carrera
							, idu_tipo_pago
							, prc_descuento
							, idu_motivo
						FROM 	MOV_DETALLE_REVISION_COLEGIATURAS 
						WHERE 	idu_escuela IN (SELECT idu_escuela FROM tmp_Escuelas) 
							and prc_descuento>0';
				if (sEscolaridad = '') then
					-- 
					sWhere := ';';
				else
					-- 2,5,3
					sWhere := ' AND idu_escolaridad IN (' || sEscolaridad || ') ;';
				end if;

				sQuery := sQuery || sWhere;

				raise notice '%', sQuery;
				EXECUTE sQuery;

				update	tmpDatos set motivo_descto=B.des_motivo
				from	CAT_MOTIVOS_COLEGIATURAS B
				where 	tmpDatos.idmotivo= B.idu_motivo
					and B.idu_tipo_motivo=5;		
			END IF;
		else 
			if iOpcion=1 then
				--COSTOS
				sQuery := 'INSERT 	INTO tmpDatos (idescuela, idcicloescolar, idescolaridad, idcarrera, idtpp, prc_descuento, importe, idmotivo) 
					SELECT 	idu_escuela 
						,idu_ciclo_escolar 
						, idu_escolaridad 
						, idu_Carrera 
						, idu_tipo_pago 
						, prc_descuento 
						, importe_concepto 
						, idu_motivo 
					FROM 	HIS_DETALLE_REVISION_COLEGIATURAS
					WHERE 	idu_escuela IN (SELECT idu_escuela FROM tmp_Escuelas) 
						AND idu_ciclo_escolar = ' || iCicloEscolar || '
						AND prc_descuento=0';
				if (sEscolaridad = '') then
					-- 
					sWhere := ';';
				else
					-- 2,5,3
					sWhere := ' AND idu_escolaridad IN (' || sEscolaridad || ') ;';
				end if;

				sQuery := sQuery || sWhere;

				RAISE notice '%', sQuery;
				EXECUTE sQuery;


-- 			where 	idu_escuela in (select idu_escuela from tmp_Escuelas) 					
			ELSE
				--DESCUENTOS
				sQuery := 'INSERT 	INTO tmpDatos (idescuela,idcicloescolar, idescolaridad, idcarrera, idtpp, prc_descuento, idmotivo)
					SELECT 	idu_escuela
						,idu_ciclo_escolar
						, idu_escolaridad
						, idu_Carrera
						, idu_tipo_pago
						, prc_descuento
						, idu_motivo
					FROM 	HIS_DETALLE_REVISION_COLEGIATURAS 
					WHERE 	idu_escuela IN (SELECT idu_escuela FROM tmp_Escuelas) 
						AND idu_ciclo_escolar = ' || iCicloEscolar || '
						AND prc_descuento>0';
				if (sEscolaridad = '') then
					-- 
					sWhere := ';';
				else
					-- 2,5,3
					sWhere := ' AND idu_escolaridad IN (' || sEscolaridad || ') ;';
				end if;

				sQuery := sQuery || sWhere;

				RAISE notice '%', sQuery;
				EXECUTE sQuery;

				update	tmpDatos set motivo_descto=B.des_motivo
				from	CAT_MOTIVOS_COLEGIATURAS B
				where 	tmpDatos.idmotivo= B.idu_motivo
					and B.idu_tipo_motivo=5;		
			END IF;
		end if;

		--NOMBRE ESCUELA
		update 	tmpDatos set sescuela=B.nom_escuela
		from	CAT_ESCUELAS_COLEGIATURAS B
		where	tmpDatos.idescuela=B.idu_escuela;
		

		--FECHA REVISION
		update	tmpDatos set fecha_rev=to_char(B.fec_revision,'dd-mm-yyyy')
		from	MOV_REVISION_COLEGIATURAS B
		where	B.idu_escuela in (SELECT idu_escuela from tmp_Escuelas);--=B.idu_escuela;

		--CICLO ESCOLAR
		UPDATE 	tmpDatos set ciclo_escolar=B.des_ciclo_escolar
		FROM	CAT_CICLOS_ESCOLARES B
		where	tmpDatos.idcicloescolar=B.idu_ciclo_escolar;

		--ESCOLARIDAD	
		UPDATE	tmpDatos set nom_escolaridad=B.nom_escolaridad
		FROM	CAT_ESCOLARIDADES B
		where	tmpDatos.idescolaridad=B.idu_escolaridad;

		--CARRERA
		UPDATE 	tmpDatos set nom_carrera=B.nom_carrera
		FROM	CAT_CARRERAS B
		where	tmpDatos.idcarrera=B.idu_carrera;

		--TIPO PAGO
		UPDATE 	tmpDatos set tpp=B.des_tipo_pago
		FROM	CAT_TIPOS_PAGOS B
		where	tmpDatos.idtpp=B.idu_tipo_pago;

		--MOTIVO
		update	tmpDatos set motivo_descto=B.des_motivo
		from	CAT_MOTIVOS_COLEGIATURAS B
		where	B.idu_tipo_motivo=4
			and tmpDatos.idmotivo=B.idu_motivo;
		
		FOR valor IN (SELECT 	
				--idescuela,
				--idescuela integer,
				sescuela, 
				idcicloescolar,
				ciclo_escolar,
				idescolaridad,
				nom_escolaridad,
				idcarrera,
				nom_carrera,
				idtpp,
				tpp,
				prc_descuento,
				importe,
				idmotivo,
				motivo_descto,
				fecha_rev
			FROM tmpDatos 
			ORDER BY sescuela, iidcicloescolar, iidescolaridad)
		LOOP	
					
		--iidescuela:=valor.idescuela;
		snom_escuela:=valor.sescuela;
		iidcicloescolar:=valor.idcicloescolar;
		sciclo_escolar:=valor.ciclo_escolar;		
		iidescolaridad:=valor.idescolaridad;
		snom_escolaridad:=valor.nom_escolaridad; 
		iidcarrera:=valor.idcarrera;
		snom_carrera:=valor.nom_carrera;
		iidtpp:=valor.idtpp; 
		stpp:=valor.tpp;
		iprc_descuento:=valor.prc_descuento; 
		iimporte:=valor.importe;
		iidmotivo:=valor.idmotivo;
		smotivo_descto:=valor.motivo_descto;
		sfecha_rev:=valor.fecha_rev;			
			
		RETURN NEXT;
		END LOOP;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_consultar_costos_descuentos_escuela(integer, integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_consultar_costos_descuentos_escuela(integer, integer, character varying, integer) TO syspersonal;
COMMENT ON FUNCTION fun_consultar_costos_descuentos_escuela(integer, integer, character varying, integer) IS 'La función obtiene los costos y descuentos capturador para la escuela de la factura seleccionada';