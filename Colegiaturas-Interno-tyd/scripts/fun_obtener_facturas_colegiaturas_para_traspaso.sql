CREATE OR REPLACE FUNCTION public.fun_obtener_facturas_colegiaturas_para_traspaso(ipage integer, ilimit integer, iconexion integer, corder character, cordertype character, scolumns character, iopcion integer, inum_empleado integer, ifiltro integer, cbusqueda character, itipomov integer, iquincena integer, itiponomina integer, xml_data xml, OUT records integer, OUT page integer, OUT pages integer, OUT id integer, OUT iottp integer, OUT iempleado integer, OUT snomempleado character varying, OUT iclv_tipo_registro integer, OUT sdes_tipo_registro character varying, OUT ibeneficiario_hoja_azul integer, OUT ibeneficiario integer, OUT snombeneficiario character varying, OUT sfacturafiscal character varying, OUT dfechafactura date, OUT iidciclo integer, OUT snomciclo character varying, OUT dfechacaptura date, OUT iidtipopago integer, OUT stipopago character varying, OUT speriodo character varying, OUT sdes_periodo character varying, OUT nimporte_fac numeric, OUT nimporte_pago numeric, OUT iidestudio integer, OUT sestudio character varying, OUT iidescuela integer, OUT sescuela character varying, OUT srfc character varying, OUT idescuento integer, OUT iiddeduccion integer, OUT sdeduccion character varying, OUT sobservaciones text, OUT iidrutapago integer, OUT srutapago character varying, OUT snumtarjeta character varying, OUT iidfactura integer, OUT imarcado integer, OUT iusuario integer, OUT nisr numeric, OUT nimporte_a_pagar numeric)
 RETURNS SETOF record
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
/** ====================================================================================================
-- Peticion: 
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 15-05-2018
-- DescripciÃ³n General: Obtiene las facturas para traspaso
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas 
-- Servidor Productivo: 10.44.2.183
-- Servidor Desarrollo: 10.28.114.75 
-- Ejemplo: 
	SELECT 	* 
	FROM 	fun_obtener_facturas_colegiaturas_para_traspaso_monge (1,4,94827443,'empleado','asc','ottp,empleado,nomempleado,conexion',1,94827443,2,'', 0)
	SELECT * 
	FROM    fun_obtener_facturas_colegiaturas_para_traspaso_monge(1,20,95194185,'nombeneficiario','asc','*',1,95194185,2,'',0)
	SELECT * 
	FROM    fun_obtener_facturas_colegiaturas_para_traspaso_monge(1,10,95194185,'nombeneficiario','asc','clv_tipo_registro,des_tipo_registro,ottp,empleado,nomempleado,beneficiario_hoja_azul,beneficiario,nombeneficiario,facturafiscal,fechafactura,idciclo,nomciclo,fechacaptura,idtipopago,tipopago,periodo,des_periodo,importe_fac,importe_pago,idestudio,estudio,idescuela,escuela,rfc,descuento,iddeduccion,deduccion,observaciones,idrutapago,rutapago,numtarjeta,idfactura,marcado,usuario,conexion',1,95194185,0,'',0, 2, 1)
	SELECT * FROM fun_obtener_facturas_colegiaturas_para_traspaso_monge(1,10,98439677,'nombeneficiario','asc','clv_tipo_registro,des_tipo_registro,ottp,empleado,nomempleado,beneficiario_hoja_azul,beneficiario,nombeneficiario,facturafiscal,fechafactura,idciclo,nomciclo,fechacaptura,idtipopago,tipopago,periodo,des_periodo,importe_fac,importe_pago,idestudio,estudio,idescuela,escuela,rfc,descuento,iddeduccion,deduccion,observaciones,idrutapago,rutapago,numtarjeta,idfactura,marcado,usuario,conexion',1,95194185,0,'',0, 2, 1)
	SELECT * FROM stmp_traspaso_colegiaturas
	select * from mensajes
	
-- ====================================================================================================
-- Peticion:			16559
-- Autor:			Rafael Ramos Gutierrez 98439677
-- Fecha:			06/07/2018
-- Descripcion del cambio:	Se agregan 2 filtros de busqueda, iquincena e itiponomina

-- ====================================================================================================
-- Peticion:			39116
-- Autor:			Luis Antonio Monge Padilla 97270661
-- Fecha:			04/04/2024
-- Descripcion del cambio:	Se agrega isr y otros calculos, solo para la generacion de jasper.

-- ====================================================================================================
-- Peticion:			39116
-- Autor:			Raul Antonio Chavez Aguirre
-- Fecha:			09/04/2024
-- Descripcion del cambio:	Se validacion para traer solo las facturas marcadas de la tabla """"stmp_traspaso_colegiaturas"""" despues de llenarla, 
				solo para la generacion de jasper.

-- ====================================================================================================
 */ 	
	sQuery TEXT;	
	valor record;
	iStart integer;
	iRecords integer;
	iTotalPages INTEGER; 
	rec RECORD;

BEGIN
	--TABLA TEMPORAL	
	CREATE TEMP TABLE temp_obtener_facturas_colegiaturas_para_traspaso(
		clv_tipo_registro INTEGER,
		des_tipo_registro VARCHAR(20),
		ottp integer,
		empleado integer,
		nomempleado character varying(150),
		beneficiario_hoja_azul integer,
		beneficiario integer,
		nombeneficiario character varying(150),
		facturafiscal character varying(100),
		fechafactura date,
		idciclo integer,
		nomciclo character varying(30),
		fechacaptura date,
		idtipopago integer,
		tipopago character varying(20),
		periodo VARCHAR(150),
		des_periodo TEXT,
		importe_fac numeric(12,2),
		importe_pago numeric(12,2),
		idestudio integer,
		estudio character varying(30),
		idescuela integer,
		escuela character varying(100),
		rfc character varying(20),
		descuento integer,
		iddeduccion integer,
		deduccion character varying(30),
		observaciones text,
		idrutapago integer,
		rutapago character varying,
		numtarjeta character varying(16),
		idfactura integer,
		marcado integer,
		usuario integer,
		conexion integer,
		tiponomina integer,
		isr numeric(12,2),
		importe_a_pagar numeric(12,2)
	--);
	)ON COMMIT DROP;

	--DROP TABLE tmp_Conceptos
	CREATE TEMP TABLE tmp_Conceptos(
		importe numeric (12,2),
		iFactura integer
	)ON COMMIT DROP;

	CREATE TEMP TABLE temp_xml (
		e bigint,
		i bigint
	 )ON COMMIT DROP;

	IF (ipage = -1) THEN
	-- Insertar datos XML en la tabla temporal
	    FOR rec IN (
		SELECT (xpath('/r/@e', x))[1]::text::bigint AS e,
		       (xpath('/r/@i', x))[1]::text::bigint AS i
		FROM   unnest(xpath('/Root/r', xml_data)) x
	    )
	    LOOP
		INSERT INTO temp_xml (e, i) VALUES (rec.e, rec.i);
	    END LOOP;
	END IF;
	

	
	IF (iOpcion = 1) THEN
		DELETE FROM stmp_traspaso_colegiaturas WHERE usuario = inum_empleado;
	
		--INSERTAR LAS FACTURAS CON ESTATUS PAGADAS.

		IF (iTipoMov=0 or iTipoMov=1) THEN
			INSERT 	INTO stmp_traspaso_colegiaturas(clv_tipo_registro, des_tipo_registro, empleado, fechaFactura, importe_fac, importe_pago, rfc, idDeduccion, observaciones, idfactura, usuario)
			SELECT 	1, 'FACTURA',idu_empleado, fec_factura, importe_factura, importe_pagado, rfc_clave, idu_tipo_deduccion, des_observaciones, idfactura, inum_empleado
		FROM 	mov_facturas_colegiaturas  
			WHERE 	idu_estatus = 2 
				AND to_char(fec_movimiento_traspaso,'dd/MM/yyyy')='01/01/1900'
				AND idu_beneficiario_externo=0;
		END IF;

		IF (iTipoMov=0 or iTipoMov=2) THEN
			INSERT 	INTO stmp_traspaso_colegiaturas(clv_tipo_registro, des_tipo_registro, empleado, fechaFactura, importe_fac, importe_pago, rfc, idDeduccion, observaciones, idfactura, descuento, usuario)
			SELECT 	2,'AJUSTE', B.idu_empleado, B.fec_factura, B.importe_factura, A.importe_ajuste, B.rfc_clave, B.idu_tipo_deduccion, B.des_observaciones, A.idfactura, A.pct_ajuste,inum_empleado
			FROM 	MOV_AJUSTES_FACTURAS_COLEGIATURAS A
            INNER 	JOIN his_facturas_colegiaturas B ON A.idfactura=B.idfactura
            WHERE   A.idu_usuario_traspaso = 0;
            
            UPDATE 	stmp_traspaso_colegiaturas SET beneficiario_hoja_azul = FD.beneficiario_hoja_azul,
                beneficiario = FD.idu_beneficiario,
                facturaFiscal = FD.fol_fiscal,
                idCiclo = FD.idu_ciclo_escolar,
                fechaCaptura = FD.fec_registro,
                idTipoPago = FD.idu_tipopago,
                periodo = FD.periodo,
                idEstudio = FD.idu_escolaridad,
                idEscuela = FD.idu_escuela
            FROM 	his_detalle_facturas_colegiaturas FD
            WHERE 	stmp_traspaso_colegiaturas.clv_tipo_registro = 2
                AND FD.idFactura = stmp_traspaso_colegiaturas.idFactura
                AND stmp_traspaso_colegiaturas.usuario = inum_empleado;
		END IF;
		
		UPDATE 	stmp_traspaso_colegiaturas SET beneficiario_hoja_azul = FD.beneficiario_hoja_azul,
			beneficiario = FD.idu_beneficiario,
			facturaFiscal = FD.fol_fiscal,
			idCiclo = FD.idu_ciclo_escolar,
			fechaCaptura = FD.fec_registro,
			idTipoPago = FD.idu_tipopago,
			periodo = FD.periodo,
			idEstudio = FD.idu_escolaridad,
			idEscuela = FD.idu_escuela,
			descuento = FD.prc_descuento			
		FROM 	mov_detalle_facturas_colegiaturas FD
		WHERE 	FD.idFactura = stmp_traspaso_colegiaturas.idFactura
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;
		
		INSERT INTO tmp_Conceptos(importe, iFactura)
		SELECT 	COUNT(idu_tipopago), idfactura
		FROM 	mov_detalle_facturas_colegiaturas		
		GROUP 	BY idfactura;

		UPDATE 	stmp_traspaso_colegiaturas SET ottp = CASE WHEN C.importe = 1 THEN 0 ELSE 1 END
		FROM 	tmp_Conceptos C
		WHERE 	C.iFactura = stmp_traspaso_colegiaturas.idFactura
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;

		-- Datos del Empleado.
		UPDATE 	stmp_traspaso_colegiaturas SET nomempleado = TRIM(C.nombre)||' '||TRIM(C.apellidopaterno)||' '||TRIM(C.apellidomaterno),
			numTarjeta = C.numerotarjeta, idrutaPago = (CASE WHEN C.controlpago = '' THEN '0' ELSE C.controlpago END)::INTEGER
		FROM 	sapcatalogoempleados C
		WHERE 	stmp_traspaso_colegiaturas.empleado = C.numempn
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;
		
		-- Obtener los datos del beneficiario de Hoja Azul.
		UPDATE 	stmp_traspaso_colegiaturas SET nombeneficiario = TRIM(h.nombre)||' '|| COALESCE(TRIM(h.apellidopaterno),'')||' '|| COALESCE(TRIM(h.apellidomaterno),'')
		FROM 	sapfamiliarhojas h
		WHERE 	stmp_traspaso_colegiaturas.beneficiario_hoja_azul = 1
			AND stmp_traspaso_colegiaturas.beneficiario != 0
			AND h.numemp = stmp_traspaso_colegiaturas.empleado
			AND (h.keyx = stmp_traspaso_colegiaturas.beneficiario
			OR  h.idhoja_azul = stmp_traspaso_colegiaturas.beneficiario)
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;

		-- Obtener los datos del """"beneficiario regular"""" (NO hoja azul).
		UPDATE 	stmp_traspaso_colegiaturas SET nombeneficiario = TRIM(b.nom_beneficiario)||' '|| COALESCE(TRIM(b.ape_paterno),'') ||' '|| COALESCE(TRIM(b.ape_materno),'')
		FROM 	cat_beneficiarios_colegiaturas b
		WHERE 	stmp_traspaso_colegiaturas.beneficiario_hoja_azul = 0
			AND stmp_traspaso_colegiaturas.beneficiario != 0
			AND b.idu_empleado = stmp_traspaso_colegiaturas.empleado
			AND b.idu_beneficiario = stmp_traspaso_colegiaturas.beneficiario
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;

		-- Obtener cicles escolares
		UPDATE 	stmp_traspaso_colegiaturas SET nomCiclo = C.des_ciclo_escolar
		FROM 	cat_ciclos_escolares C 
		WHERE 	stmp_traspaso_colegiaturas.idciclo = C.idu_ciclo_escolar
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;

		-- Obtener tipo de pago
		UPDATE 	stmp_traspaso_colegiaturas SET tipopago = t.des_tipo_pago
		FROM 	cat_tipos_pagos t
		WHERE 	stmp_traspaso_colegiaturas.idtipopago = t.idu_tipo_pago
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;

		-- Obtener la escolaridad(Estudios)
		UPDATE 	stmp_traspaso_colegiaturas SET estudio = e.nom_escolaridad
		FROM 	cat_escolaridades e
		WHERE 	stmp_traspaso_colegiaturas.idestudio = e.idu_escolaridad
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;

		-- Obtener la Escuela
		UPDATE 	stmp_traspaso_colegiaturas SET escuela = e.nom_escuela
		FROM 	cat_escuelas_colegiaturas e
		WHERE 	stmp_traspaso_colegiaturas.idescuela = e.idu_escuela
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;
		
		-- Obtener los campos de deducciones
		UPDATE 	stmp_traspaso_colegiaturas SET deduccion = nom_deduccion
		FROM 	cat_tipos_deduccion d
		WHERE 	stmp_traspaso_colegiaturas.iddeduccion = d.idu_tipo
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;

		-- Obtener las rutas de pago
		UPDATE 	stmp_traspaso_colegiaturas SET rutaPago = R.nom_rutapago
		FROM 	cat_rutaspagos R
		WHERE 	stmp_traspaso_colegiaturas.idRutaPago = R.idu_rutapago
			AND stmp_traspaso_colegiaturas.usuario = inum_empleado;

		-- Obtener el tipo de nomina
		update	stmp_traspaso_colegiaturas
		set	tiponomina = cast(emp.tiponomina as integer)
		from	sapcatalogoempleados emp
		where	stmp_traspaso_colegiaturas.empleado = emp.numempn;
		
	--ELSE
	END IF;
	
	sQuery := ' INSERT INTO temp_obtener_facturas_colegiaturas_para_traspaso(clv_tipo_registro, des_tipo_registro,ottp, empleado, nomEmpleado, beneficiario_hoja_azul, beneficiario, nomBeneficiario, facturaFiscal, ';
	sQuery := sQuery || ' fechaFactura, idCiclo, nomCiclo,fechaCaptura,idTipoPago,tipoPago,periodo,des_periodo, ';
	sQuery := sQuery || ' importe_fac,importe_pago, idEstudio, estudio,idEscuela,escuela,rfc,descuento,idDeduccion, deduccion,observaciones, idRutaPago,rutaPago, numTarjeta, ';
	sQuery := sQuery || ' idFactura,marcado,usuario,tiponomina, conexion) ';
	sQuery := sQuery || ' SELECT clv_tipo_registro, des_tipo_registro,ottp,empleado, nomEmpleado, beneficiario_hoja_azul, beneficiario, nomBeneficiario, facturaFiscal, ';
	sQuery := sQuery || ' fechaFactura, idCiclo, nomCiclo,fechaCaptura,idTipoPago,tipoPago,periodo,des_periodo, ';
	sQuery := sQuery || ' importe_fac, importe_pago, idEstudio, estudio,idEscuela,escuela, rfc,descuento,idDeduccion, deduccion,observaciones, idRutaPago,rutaPago, numTarjeta, ';
	sQuery := sQuery || ' idFactura,marcado,usuario, tiponomina,' || iconexion ;
	--sQuery := sQuery || ' ' || iconexion::varchar || ' ';
	sQuery := sQuery || ' FROM stmp_traspaso_colegiaturas ';
	--ValidaciÃ³n para agregar solo facturas seleccionadas
	IF (ipage = -1) THEN
		sQuery := sQuery || ' WHERE stmp_traspaso_colegiaturas.marcado = 1'; -- Se agregan solos los seleccionados
	ELSE
		sQuery := sQuery || ' WHERE stmp_traspaso_colegiaturas.usuario = ' || inum_empleado;
	END IF;	
	raise notice '%s', sQuery;
	
	IF ifiltro = 1 THEN -- (1)Busqueda por Factura.
		sQuery := sQuery || ' and facturafiscal LIKE ''%' || cbusqueda || '%'''; 
	ELSE
		sQuery := sQuery || ' and (nomempleado LIKE ''%' || cbusqueda || '%'' or trim(cast(empleado as varchar)) like ''%' || trim(cbusqueda) || '%'')'; 
	END IF;	

	if (iquincena = 1) then
		if (itiponomina != 0) then
			sQuery := sQuery || ' AND tiponomina =' || itiponomina || '';
		end if;
	else
		sQuery := sQuery || 'AND tiponomina = ' || itiponomina || '';
	end if;

	sQuery := sQuery || ' GROUP BY clv_tipo_registro, des_tipo_registro,ottp, empleado, nomEmpleado, beneficiario_hoja_azul, beneficiario, nomBeneficiario, facturaFiscal, ';
	sQuery := sQuery || ' fechaFactura, idCiclo, nomCiclo,fechaCaptura,idTipoPago,tipoPago,periodo,des_periodo,importe_fac,importe_pago,idEstudio, estudio,';
	sQuery := sQuery || ' idEscuela,escuela,rfc,descuento,idDeduccion, deduccion,observaciones, idRutaPago,rutaPago, numTarjeta,idFactura,marcado,usuario, tiponomina ' ;
	
	--raise notice '%s', sQuery;
	
	execute sQuery;

	-- Validacion para que solo realice los calculos para el jasper
	IF (ipage = -1) THEN
		insert into temp_obtener_facturas_colegiaturas_para_traspaso(empleado,conexion,idfactura,importe_fac,importe_pago)
		select distinct empleado,iConexion,0,SUM(importe_fac) AS importe_fac,SUM(importe_pago) AS importe_pago from temp_obtener_facturas_colegiaturas_para_traspaso WHERE marcado = 1
		GROUP BY empleado;
		
		UPDATE temp_obtener_facturas_colegiaturas_para_traspaso SET isr = (temp_xml.i/100), importe_a_pagar = (importe_pago + (temp_xml.i/100))
		FROM temp_xml 
		where temp_xml.e = temp_obtener_facturas_colegiaturas_para_traspaso.empleado and temp_obtener_facturas_colegiaturas_para_traspaso.idfactura = 0;
	END IF;
	
	
	iRecords := (SELECT COUNT(*) FROM temp_obtener_facturas_colegiaturas_para_traspaso);
	if ipage > 0 then
		iStart := (iLimit * iPage) - iLimit + 1;
		iTotalPages := ceiling(iRecords / (iLimit * 1.0));
		
		--sQuery := sQuery || '
		sQuery := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		, ' || CAST(iPage AS VARCHAR) || ' AS page
		, ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
		, id
		, ' || sColumns || '
		from (
		SELECT ROW_NUMBER() OVER (ORDER BY ' || corder || ' ' || cordertype || ') AS id, ' || sColumns || '
		FROM temp_obtener_facturas_colegiaturas_para_traspaso
		) AS t
		WHERE  t.conexion= ' || iConexion || ' and t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iLimit) - 1) AS VARCHAR) || ' ';
	else
		sQuery := '
		select ' || CAST(iRecords AS VARCHAR) || ' AS records
		, 1 AS page
		, 1 AS pages
		, id
		, ' || sColumns || '
		from (
		SELECT ROW_NUMBER() OVER (ORDER BY ' || corder || ' ' || cordertype || ') AS id, ' || sColumns || '
		FROM temp_obtener_facturas_colegiaturas_para_traspaso
		) AS t
		WHERE  t.conexion= ' || iConexion || ' ';

	end if;

	--raise notice '%s', sQuery;
	--RETORNA VALOR DE UNA CADENA DE CONSULTA
	FOR valor IN EXECUTE (sQuery)
		LOOP 
			records:=valor.records;
			page:=valor.page;
			pages:=valor.pages;
			id:=valor.id;
			iottp:=valor.ottp;
			iempleado:=valor.empleado;
			snomempleado:=valor.nomempleado;
			iclv_tipo_registro:=valor.clv_tipo_registro;
			sdes_tipo_registro:=valor.des_tipo_registro;
			ibeneficiario_hoja_azul:=valor.beneficiario_hoja_azul;
			ibeneficiario:=valor.beneficiario;
			snombeneficiario:=valor.nombeneficiario;
			sfacturafiscal:=valor.facturafiscal;
			dfechafactura:=valor.fechafactura;
			iidciclo:=valor.idciclo;
			snomciclo:=valor.nomciclo;
			dfechacaptura:=valor.fechacaptura;
			iidtipopago:=valor.idtipopago;
			stipopago:=valor.tipopago;
			speriodo:=valor.periodo;
			sdes_periodo:='';
			nimporte_fac:=valor.importe_fac;
			nimporte_pago:=valor.importe_pago;
			iidestudio:=valor.idestudio;
			sestudio:=valor.estudio;
			iidescuela:=valor.idescuela;
			sescuela:=valor.escuela;
			srfc:=valor.rfc;
			idescuento:=valor.descuento;
			iiddeduccion:=valor.iddeduccion;
			sdeduccion:=valor.deduccion;
			sobservaciones:=valor.observaciones;
			iidrutapago:=valor.idrutapago;
			srutapago:=valor.rutapago;
			snumtarjeta:=valor.numtarjeta;
			iidfactura:=valor.idfactura;
			imarcado:=valor.marcado;
			iusuario:= valor.usuario;
			nisr:= valor.isr;
			nimporte_a_pagar:= valor.importe_a_pagar;
		RETURN NEXT;
		END LOOP;	
END;
$function$