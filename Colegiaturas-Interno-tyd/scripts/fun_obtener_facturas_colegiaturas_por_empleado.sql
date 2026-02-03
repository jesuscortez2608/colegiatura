CREATE OR REPLACE FUNCTION public.fun_obtener_facturas_colegiaturas_por_empleado(text, integer, integer, integer, character varying, character varying, character varying, date, date, integer, integer)
 RETURNS SETOF type_obtener_facturas_colegiaturas_por_empleado
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
     /*
     No. peticion APS               : 8613.1
     Fecha                          : 24/10/2016
     Numero empleado                : 96753269
     Nombre del empleado            : Nallely Machado
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripcion del funcionamiento :
     Descripcion del cambio         : NA
     Sistema                        : Colegiaturas
     Modulo                         : Autorizar o rechazar facturas
-----------------------------------------------------------------------------------------------------
	No. peticion APS	: 16559.1
	Fecha			: 20/03/2018
	Numero de empleado	: 98439677
	Nombre del empleado	: Rafael Ramos GutiÃÂ©rrez
	Descripcion del cambio	: * 
				    se agrego informacion para saber que tipo de documento es la factura (cat_tipo_documento)
				    se realiza busqueda de facturas por empleado o por grupo de empleados que tengan facturas pendientes(requerimiento)
				    se agrego el campo del nombre del empleado de la factura
------------------------------------------------------------------------------------------------------
	Descripcion del cambio:		Se agregan lineas de validacion por si tiene fecha revision y conclusion
	Fecha:				05/09/2018
	Colaborador:			94827443 Omar Alejandro Lizarraga Hernandez
	Sistema:			Colegiaturas
------------------------------------------------------------------------------------------------------	
No. peticion APS	: 39116
	Fecha			: 21/03/2024
	Numero de empleado	: 90244610
	Nombre del empleado	: Luis Eduardo Hernandez Jimenez
	Descripcion del cambio	: Se agrego condicion para verificar si las facturas tienen moneda nacional o extranjera
				: Verifica si la fecha pertenece a la primer quincena y coloca el dia primero del mes, si la fecha corresponde a la segunda quincena, es decir, despÃÂºes del 15, pone el ÃÂºltimo dÃÂ­a del mes.
------------------------------------------------------------------------------------------------------	
	Descripcion del cambio: Se agrega validacion para que en caso de que no se cuente con appelidos ya sea materno o paterno, ponga vacio.
	Fecha:				14/06/2024
	Colaborador:		90243545 Raul Antonio Chavez Aguirre
	Sistema:			Colegiaturas
------------------------------------------------------------------------------------------------------	

SELECT 	records, page, pages, id
	, otpp,idBeneficiario, nombreBecado, factura, fechaFactura , fechaCaptura
	, importeRealFact, importeConcepto, marcaTope, topeFactura, importeCal, importePagar
	, rfc, idEscuela, nombreEscuela,idciclo,ciclo, idTipoEscuela, tipoEscuela,iFactura, empleado, nom_empleado
	, comentario,aclaracion, observaciones
	, estatus,nom_estatus,emp_estatus,nom_empleado_estatus,fecha_estatus
	, rutapago, nom_rutapago, archivo1, archivo2, fecestatus,prc_descuento, tipo_deduccion
	, idtipodocumento, nombretipodocumento, opc_blog
FROM 	fun_obtener_facturas_colegiaturas_por_empleado('93902761,95625721,94844798,97265144,96274379,96254742,95660801,91982022,93917295,95485619,97271756,90423127,92095429,90058781,92225993,96924985,96843268,92355218,97277525,94156883,96753269,97232432,95969888,94804851,97270301,96157186,94824762,95720601,97270661,94989851,94827443,97231843,97524735,95194185,97268259,92137211,97293628,94226652,91047781', 0
	, 10
	, 1
	, 'fechaFac'
	, 'asc'
	, 'otpp,idBeneficiario, nombreBecado, factura, fechaFactura , fechaCaptura
	, importeRealFact, importeConcepto, marcaTope, topeFactura, importeCal, importePagar
	, rfc, idEscuela, nombreEscuela,idciclo,ciclo, idTipoEscuela, tipoEscuela, iFactura,empleado, nom_empleado, comentario,aclaracion, observaciones
	, estatus,nom_estatus,emp_estatus,nom_empleado_estatus,fecha_estatus, rutapago, nom_rutapago, archivo1, archivo2, fechaFac, fecestatus,prc_descuento,tipo_deduccion
	, idtipodocumento, nombretipodocumento, opc_blog'
	, '19000101'
	, '19000101'
	,0
	,2)

  ------------------------------------------------------------------------------------------------------ */
     sEmpleados ALIAS FOR $1;
     iOpcion ALIAS FOR $2; --0 En proceso  
     iRowsPerPage ALIAS FOR $3;
     iCurrentPage ALIAS FOR $4;
     sOrderColumn ALIAS FOR $5;
     sOrderType ALIAS FOR $6;
     sColumns ALIAS FOR $7;
     dFechaIni ALIAS FOR $8;
     dFechaFin ALIAS FOR $9;
     iCicloEscolar ALIAS FOR $10;
     iTipoConsulta ALIAS FOR $11;
     --iEmpleado ALIAS FOR $12;
     iStart INTEGER;
     iRecords INTEGER;
     iTotalPages INTEGER;
     nTopeMensual numeric(9,2);
     sConsulta VARCHAR(3000);
     iPuesto INTEGER;
     iCentro INTEGER;
     iSeccion INTEGER;
     col RECORD;
     sSQL text;
     nImporteConcepto numeric (12,2); 
     nImporteCalculado numeric (12,2);
     cmoneda VARCHAR(3);
     
     returnrec type_obtener_facturas_colegiaturas_por_empleado;
BEGIN
	IF iRowsPerPage = -1 then
		iRowsPerPage := NULL;
	end if;

	if iCurrentPage = -1 then
		iCurrentPage := NULL;
	end if;
	
	create local temp table tmp_facturas  
	(
		records integer,
		page integer,
		pages integer,
		id integer,
		fechaasignacion character varying(10),
		fechaconcluyo character varying(10),
		fec_orden date,--
		estatusrevision integer,
		nom_estatusrevision character varying(30),
		otpp integer not null default 0,
		hoja_azul integer,
		idBeneficiario integer,
		idEscolaridad integer,
		nombreBecado character varying(150) not null default '',
		factura character varying(100) not null default '',
		fechaFac date,
		fechaFactura character varying(10) not null default '',
		fechaCaptura character varying(10) not null default '',
		importeRealFact numeric (12,2),
		importeConcepto numeric (12,2),
		marcaTope integer,
		topeFactura numeric (12,2),
		importeCal numeric (12,2),
		importePagar numeric (12,2),
		rfc character varying(20) not null default '',
		idEscuela integer,
		nombreEscuela character varying(100) not null default '',
		idciclo integer,
		ciclo character varying(30) not null default '',
		idTipoEscuela integer,
		tipoEscuela character varying(30) not null default '',
		iFactura integer, 
		empleado integer,
		nom_empleado character varying(150) not null default '',
		puesto INTEGER,
		centro INTEGER,
		seccion INTEGER,
		comentario text  not null default '',
		aclaracion text not null default '',
		observaciones text not null default '',
		estatus integer,
		nom_estatus character varying (30),
		emp_estatus integer,
		nom_empleado_estatus character varying (150) not null default '',
		fecha_estatus character varying(10) not null default '',
		fecestatus date,
		rutapago integer,
		nom_rutapago varchar (20) not null default '',
		archivo1 character varying(60),
		archivo2 character varying(60),
		prc_descuento INTEGER,
		tipo_deduccion integer not null default 0,
		idtipodocumento integer not null default 0,
		nombretipodocumento character varying (50) not null default '',
		opc_blog integer, --Blog de Servicios Compartidos
		opc_blog_colaborador integer,
		idNotaCredito integer not null default 0, --factura de nota de credito
		folionota character varying(100),
		importeaplicado numeric,
		idu_motivo_revision integer,
		des_motivo_revision character varying(100),
		opc_modifico_pago integer,
		des_metodo_pago character varying(20), 
		fol_relacionado	character varying(100),
		idu_tipo_pago integer,
		mes_tipo_pago integer,
		imotivo_rechazo integer
	) on commit drop;   
    
	create local temp table tmp_Conceptos 
	( 	
		iFactura integer, 
		importe numeric (12,2),
		periodo integer,
		prc_descuento INTEGER
	)on commit drop; 

	create local temp table tmp_Fechas
	(  
		iEscuela integer, 
		FechaAsignacion varchar(10),
		FechaConcluyo varchar(10)		
	)on commit drop; 

	create local temp table tmp_Importes_Calculados
	( 	
		iFactura integer, 
		-- importeReal numeric (12,2),
		-- importe_mes numeric (12,2),
		-- importe_semana numeric (12,2),
		-- importe_tomar numeric (12,2),
		importe_concepto numeric (12,2), --importe modificado
		--tope_mensual numeric (12,2),
		importe_calculado numeric (12,2)
		-- tipo_periodo integer,
		-- periodo_meses numeric (12,2),
		-- prc_descuento INTEGER
	)on commit drop; 
	--Importe de las notas de credito
	/*CREATE TEMP TABLE tmp_importes
	(
		idnota integer,
		importe numeric		
	)on commit drop;*/ 

	create local temp table tmp_EmpleadosCancelados
	(
		numemp integer
	)on commit drop; 

	insert	into tmp_EmpleadosCancelados (numemp)
	select 	A.numempn 
	from 	SAPCATALOGOEMPLEADOS A
	inner	join MOV_FACTURAS_COLEGIATURAS B on A.numempn=B.idu_empleado
	where 	A.cancelado='1' and B.idu_estatus!=3;

	--RECHAZADO POR SISTEMA
	update	MOV_FACTURAS_COLEGIATURAS set idu_estatus=3, des_observaciones='RECHAZADO POR SISTEMA POR BAJA DE COLABORADOR', emp_marco_estatus = 0, fec_marco_estatus = now()
	from	tmp_EmpleadosCancelados B
	where	MOV_FACTURAS_COLEGIATURAS.idu_empleado=B.numemp;

	sSQL := ('INSERT INTO tmp_facturas ( factura,fec_orden ,fechaFactura, fechaCaptura, importeRealFact,  idEscuela, iFactura, empleado, importeCal, importePagar, comentario, aclaracion, observaciones, estatus, emp_estatus, 
	fecha_estatus, archivo1, archivo2, fechaFac, fecestatus, idtipodocumento, opc_blog,opc_blog_colaborador, idu_motivo_revision, opc_modifico_pago, des_metodo_pago, fol_relacionado, imotivo_rechazo)
			SELECT  fol_fiscal, fec_factura , to_char(fec_factura,''dd/MM/yyyy'') , to_char(fec_registro,''dd/MM/yyyy''), importe_factura, idu_escuela, idfactura, idu_empleado, importe_calculado, 
				importe_pagado, des_comentario_especial, des_aclaracion_costos, des_observaciones,
				CASE idu_estatus WHEN 6 THEN 2 ELSE idu_estatus END, emp_marco_estatus, 
				to_char(
				CASE 
				    WHEN EXTRACT(DAY FROM fec_marco_estatus) <= 15 THEN (DATE_TRUNC(''month'', fec_marco_estatus) + INTERVAL ''14 days'')::DATE
				    ELSE 
					CASE 
					    WHEN EXTRACT(DAY FROM (DATE_TRUNC(''month'', fec_marco_estatus + INTERVAL ''1 month'') - INTERVAL ''1 day'')::DATE) = 31 
					    THEN (DATE_TRUNC(''month'', fec_marco_estatus + INTERVAL ''1 month'') - INTERVAL ''2 day'')::DATE 
					    ELSE (DATE_TRUNC(''month'', fec_marco_estatus + INTERVAL ''1 month'') - INTERVAL ''1 day'')::DATE 
					END
				END ,''dd/MM/yyyy'')
				, nom_xml_recibo, nom_pdf_carta, fec_factura,fec_marco_estatus, idu_tipo_documento, 0,0, 
				idu_motivo_revision, opc_modifico_pago, des_metodo_pago, fol_relacionado, idu_motivo_rechazo
			FROM 	MOV_FACTURAS_COLEGIATURAS WHERE idu_beneficiario_externo = 0 AND idu_empleado IN ('||sEmpleados || ') ' );

			
    IF iOpcion<>-1 THEN --POR ESTATUS
        if iOpcion=2 then--por pagar
            sSQL :=sSQL||' AND  idu_estatus in (2,6) ';
        else
	    --sSQL :=sSQL||' AND  idu_estatus != 6  and idu_estatus='||iOpcion;
	    if (iTipoConsulta=0) then
		if (iOpcion=1)then
			sSQL :=sSQL||' AND idu_estatus != 6 and idu_tipo_documento!=2 and idu_estatus=' || iOpcion;	
		elsif (iOpcion=6) then
			sSQL :=sSQL||' AND idu_estatus != 6 and idu_tipo_documento=2';  --and idu_estatus=' || iOpcion;	
		else
			sSQL :=sSQL||' AND idu_estatus != 6  and idu_estatus='||iOpcion;	
		end if;
	   else
		sSQL :=sSQL||' AND idu_estatus != 6  and idu_estatus='||iOpcion;	
	   end if;
        end if;
    END IF;
    	
    IF dFechaIni!='19000101' THEN
    	sSQL :=sSQL||'  and fec_registro::DATE  between '''||dFechaIni||''' and '''||dFechaFin||'''';
    END IF;
    raise notice '%', sSQL;
    EXECUTE sSQL;
    
    /*if iTipoConsulta<>0 then-- 0 aceptar o rechazar facturas
        update tmp_facturas set importePagar=0;
    end if;*/
    
	sSQL := ('
		INSERT 	INTO TMP_FACTURAS ( factura, fec_orden, fechaFactura, fechaCaptura, importeRealFact,  idEscuela, iFactura, empleado, importeCal, importePagar, comentario, aclaracion, observaciones,estatus, emp_estatus,fecha_estatus, archivo1, archivo2, fechaFac, 
		fecestatus, idtipodocumento, opc_blog, opc_blog_colaborador, opc_modifico_pago, des_metodo_pago, fol_relacionado, imotivo_rechazo)
		SELECT  fol_fiscal, fec_factura, to_char(fec_factura,''dd/MM/yyyy''), to_char(fec_registro,''dd/MM/yyyy''), importe_factura, idu_escuela, idfactura, idu_empleado, importe_calculado, importe_pagado, des_comentario_especial, des_aclaracion_costos, des_observaciones,
			idu_estatus, emp_marco_estatus, 
			to_char(
				CASE 
				    WHEN EXTRACT(DAY FROM fec_marco_estatus) <= 15 THEN (DATE_TRUNC(''month'', fec_marco_estatus) + INTERVAL ''14 days'')::DATE
				    ELSE 
					CASE 
					    WHEN EXTRACT(DAY FROM (DATE_TRUNC(''month'', fec_marco_estatus + INTERVAL ''1 month'') - INTERVAL ''1 day'')::DATE) = 31 
					    THEN (DATE_TRUNC(''month'', fec_marco_estatus + INTERVAL ''1 month'') - INTERVAL ''2 day'')::DATE 
					    ELSE (DATE_TRUNC(''month'', fec_marco_estatus + INTERVAL ''1 month'') - INTERVAL ''1 day'')::DATE 
					END
				END ,''dd/MM/yyyy''), 
		nom_xml_recibo, nom_pdf_carta, fec_factura, fec_marco_estatus, idu_tipo_documento, 0, 0, opc_modifico_pago, des_metodo_pago, fol_relacionado, idu_motivo_rechazo
		FROM 	HIS_FACTURAS_COLEGIATURAS 
		WHERE 	idu_beneficiario_externo = 0  AND idu_empleado IN ('|| sEmpleados || ') ' );

	IF iOpcion<>-1 THEN	
		sSQL :=sSQL||'  and idu_estatus=' || iOpcion;
		if (iOpcion=6 and iTipoConsulta=0) then  --nota de credito
			sSQL :=sSQL||' and idu_tipo_documento=2';
		end if;
	END IF;

	IF dFechaIni!='19000101' THEN
		sSQL :=sSQL||'  and fec_registro::DATE  between '''|| dFechaIni||''' and '''||dFechaFin||'''';
	END IF;
		
	raise notice '%', sSQL;
	EXECUTE sSQL;

	--ESTATUS REVISION
	update	tmp_facturas SET estatusrevision=B.idu_estatus_revision
	from 	MOV_REVISION_COLEGIATURAS B
	where	tmp_facturas.idEscuela=B.idu_escuela;

	--NOMBRE ESTATUS REVISION
	update	tmp_facturas SET nom_estatusrevision=B.des_estatus_revision
	from	CAT_ESTATUS_REVISION B
	where	tmp_facturas.estatusrevision=B.idu_estatus_revision;
	
	
	UPDATE tmp_facturas SET puesto = emp.pueston, centro = emp.centron
	from   sapcatalogoempleados as emp
	where  emp.numempn = tmp_facturas.empleado;

	update tmp_facturas set seccion = cen.seccion::integer
	from   sapcatalogocentros as cen 
	where  centron=tmp_facturas.centro;

	update tmp_facturas set rutapago=a.controlpago::integer 
	from   sapcatalogoempleados a 
	where  a.numempn= tmp_facturas.empleado;

	--TIPO PAGO, MES TIPO PAGO MOV_DETALLE
	UPDATE 	tmp_facturas SET idu_tipo_pago=B.idu_tipopago
	FROM	MOV_DETALLE_FACTURAS_COLEGIATURAS B
	WHERE	tmp_facturas.iFactura=B.idfactura;

	--TIPO PAGO, MES TIPO PAGO HIS_DETALLE
	UPDATE 	tmp_facturas SET idu_tipo_pago=B.idu_tipopago
	FROM	HIS_DETALLE_FACTURAS_COLEGIATURAS B
	WHERE	tmp_facturas.iFactura=B.idfactura;

	--MES TIPO PAGO
	UPDATE 	tmp_facturas SET mes_tipo_pago=B.mes_tipo_pago
	FROM	CAT_TIPOS_PAGOS B
	where 	tmp_facturas.idu_tipo_pago=B.idu_tipo_pago;
		
	--
	update 	tmp_facturas set nom_rutapago=a.nom_rutapago 
	from 	cat_rutaspagos a 
	where 	a.idu_rutapago=tmp_facturas.rutapago AND tmp_facturas.importePagar>0;

	--
	update 	tmp_facturas set nombretipodocumento = a.nom_tipo_documento 
	from 	cat_tipo_documento a 
	where 	a.idu_tipo_documento = tmp_facturas.idtipodocumento;

	--
	update 	tmp_facturas set nom_empleado = COALESCE(trim(a.nombre),'') || ' ' || COALESCE(trim(a.apellidopaterno),'') || ' ' || COALESCE(trim(a.apellidomaterno),'') 
	from 	sapcatalogoempleados a where a.numempn = tmp_facturas.empleado;

	if iOpcion=2 then--por pagar
		update 	tmp_facturas set nom_estatus=a.nom_estatus 
		from 	cat_estatus_facturas a 
		where 	a.idu_estatus=iOpcion;
	else
		update 	tmp_facturas set nom_estatus=a.nom_estatus 
		from 	cat_estatus_facturas a 
		where 	a.idu_estatus=tmp_facturas.estatus;
	end if;

	--
	update 	tmp_facturas set nom_empleado_estatus=COALESCE(trim(a.nombre),'') || ' ' || COALESCE(trim(a.apellidopaterno),'') || ' ' || COALESCE(trim(a.apellidomaterno),'') 
	from 	sapcatalogoempleados a 
	where 	a.numempn=tmp_facturas.emp_estatus;

	--ACTUALIZAR LOS DESCUENTOS POR BENEFICIARIO
	update 	tmp_facturas set nom_empleado_estatus='AUTORIZADA POR SISTEMA'
	where 	tmp_facturas.emp_estatus=0 AND tmp_facturas.fecha_estatus!='19000101' AND tmp_facturas.estatus=1;
	
	--
	UPDATE 	mov_detalle_facturas_colegiaturas SET prc_descuento=0
	FROM 	tmp_facturas as tmp
	Where 	mov_detalle_facturas_colegiaturas.idfactura = tmp.iFactura
		AND mov_detalle_facturas_colegiaturas.idu_empleado= tmp.empleado;

	--descuento por empleado/parentesco/estudio
	RAISE 	NOTICE '%', 'descuento por empleado/parentesco/estudio';
	UPDATE 	MOV_DETALLE_FACTURAS_COLEGIATURAS SET prc_descuento=a.por_porcentaje
	from 	CTL_CONFIGURACION_DESCUENTOS a
	INNER 	JOIN tmp_facturas as tmp on (a.idu_empleado=tmp.empleado)
	where 	mov_detalle_facturas_colegiaturas.idfactura = tmp.iFactura
		AND mov_detalle_facturas_colegiaturas.idu_parentesco = a.idu_parentesco
		and mov_detalle_facturas_colegiaturas.idu_escolaridad = a.idu_escolaridad
		and mov_detalle_facturas_colegiaturas.prc_descuento=0;

	--descuento por puesto/seccion/parentesco/estudio
	RAISE 	NOTICE '%', 'descuento por puesto/seccion/parentesco/estudio';
	UPDATE 	MOV_DETALLE_FACTURAS_COLEGIATURAS SET prc_descuento=a.por_porcentaje 
	from 	CTL_CONFIGURACION_DESCUENTOS a
	INNER 	JOIN tmp_facturas as tmp on (a.idu_puesto=tmp.puesto and a.idu_seccion=tmp.seccion)
	where 	mov_detalle_facturas_colegiaturas.idfactura = tmp.iFactura
		AND mov_detalle_facturas_colegiaturas.idu_parentesco = a.idu_parentesco
		and mov_detalle_facturas_colegiaturas.idu_escolaridad = a.idu_escolaridad
		and mov_detalle_facturas_colegiaturas.prc_descuento=0;

	--descuento por puesto/seccion 0/parentesco/estudio
	RAISE NOTICE '%', 'descuento por puesto/seccion 0/parentesco/estudio';
	UPDATE 	MOV_DETALLE_FACTURAS_COLEGIATURAS SET prc_descuento=a.por_porcentaje
	from 	CTL_CONFIGURACION_DESCUENTOS a
	INNER 	JOIN tmp_facturas as tmp on (a.idu_puesto=tmp.puesto)
	where 	a.idu_seccion=0
		and mov_detalle_facturas_colegiaturas.idfactura = tmp.iFactura
		AND mov_detalle_facturas_colegiaturas.idu_parentesco  = a.idu_parentesco
		and mov_detalle_facturas_colegiaturas.idu_escolaridad = a.idu_escolaridad
		and mov_detalle_facturas_colegiaturas.prc_descuento=0;

	--descuento por centro/puesto/parentesco/estudio
	RAISE NOTICE '%', 'descuento por centro/puesto/parentesco/estudio';
	UPDATE 	MOV_DETALLE_FACTURAS_COLEGIATURAS SET prc_descuento=a.por_porcentaje 
	from 	CTL_CONFIGURACION_DESCUENTOS a
	INNER 	JOIN tmp_facturas as tmp on (a.idu_centro=tmp.centro AND a.idu_puesto=tmp.puesto)
	where 	mov_detalle_facturas_colegiaturas.idfactura = tmp.iFactura
		AND a.idu_parentesco=mov_detalle_facturas_colegiaturas.idu_parentesco 
		and a.idu_escolaridad=mov_detalle_facturas_colegiaturas.idu_escolaridad
		and mov_detalle_facturas_colegiaturas.prc_descuento=0;

	--descuento por centro/puesto 0/parentesco/estudio
	RAISE NOTICE '%', 'descuento por centro/puesto 0/parentesco/estudio';
	UPDATE 	MOV_DETALLE_FACTURAS_COLEGIATURAS SET prc_descuento=a.por_porcentaje 
	from 	CTL_CONFIGURACION_DESCUENTOS a
	INNER 	JOIN tmp_facturas as tmp on (a.idu_centro=tmp.centro)
	where 	a.idu_puesto=0 
		AND mov_detalle_facturas_colegiaturas.idfactura = tmp.iFactura
		AND a.idu_parentesco=mov_detalle_facturas_colegiaturas.idu_parentesco 
		and a.idu_escolaridad=mov_detalle_facturas_colegiaturas.idu_escolaridad
		and mov_detalle_facturas_colegiaturas.prc_descuento=0;

	--actualizacion po default 50%
	UPDATE 	MOV_DETALLE_FACTURAS_COLEGIATURAS SET prc_descuento=50 
	where 	prc_descuento=0 ;---and idfactura in (select iFactura from tmp_facturas);

	INSERT 	INTO tmp_Conceptos (importe,iFactura)
	select 	sum((mov.importe_concepto * mov.prc_descuento)/100), mov.idfactura
	from 	MOV_DETALLE_FACTURAS_COLEGIATURAS as mov
	INNER 	JOIN tmp_facturas as tmp on (mov.idfactura = tmp.iFactura)
	group 	by mov.idfactura, mov.prc_descuento;
	
	--UPDATE tmp_facturas SET importePagar=0 where estatus<>5;
	UPDATE 	tmp_facturas SET rfc = TRIM(a.rfc_clave_sep), nombreEscuela=TRIM(a.nom_escuela),idTipoEscuela=a.opc_tipo_escuela, 
		tipoEscuela= case when a.opc_tipo_escuela=1 then 'PÃBLICA' ELSE 'PRIVADA' END, tipo_deduccion=case when a.opc_tipo_escuela=1 then 2 ELSE 1 END
	FROM 	CAT_ESCUELAS_COLEGIATURAS a
	WHERE 	a.idu_escuela = tmp_facturas.idEscuela;

	--MOV_DETALLE_FACTURAS_COLEGIATURAS
	UPDATE 	tmp_facturas SET idCiclo= a.idu_ciclo_escolar, idBeneficiario=a.idu_beneficiario, hoja_azul=a.beneficiario_hoja_azul, idEscolaridad=a.idu_escolaridad
	FROM 	MOV_DETALLE_FACTURAS_COLEGIATURAS a  
	where 	a.idu_empleado=tmp_facturas.empleado and  a.idfactura=tmp_facturas.iFactura;

	UPDATE 	tmp_facturas SET idCiclo= a.idu_ciclo_escolar, idBeneficiario=a.idu_beneficiario, hoja_azul=a.beneficiario_hoja_azul, idEscolaridad=a.idu_escolaridad
	FROM 	HIS_DETALLE_FACTURAS_COLEGIATURAS a  
	where 	a.idu_empleado=tmp_facturas.empleado and  a.idfactura=tmp_facturas.iFactura;

	UPDATE 	tmp_facturas SET nombreBecado=trim(a.nom_beneficiario)||' '|| COALESCE(trim(a.ape_paterno),'') ||' '|| COALESCE(trim(a.ape_materno),'')
	from 	CAT_BENEFICIARIOS_COLEGIATURAS a 
	where 	tmp_facturas.empleado=a.idu_empleado and tmp_facturas.idBeneficiario= a.idu_beneficiario and tmp_facturas.hoja_azul=0;

	UPDATE 	tmp_facturas SET nombreBecado=trim(a.nombre)||' '|| COALESCE(trim(a.apellidopaterno), '') ||' '|| COALESCE(trim(a.apellidomaterno), '')
	from 	SAPFAMILIARHOJAS a 
	where 	tmp_facturas.empleado=a.numemp and (tmp_facturas.idBeneficiario=a.keyx OR tmp_facturas.idBeneficiario=a.idhoja_azul) and tmp_facturas.hoja_azul=1;

	IF iCicloEscolar<>0 THEN --BORRA LOS REGISTROS QUE SON DE DIFERENTE CICLO ESCOLAR
		DELETE FROM tmp_facturas WHERE idCiclo NOT IN (iCicloEscolar);
	END IF;

	--select * from mov_detalle_facturas_colegiaturas where idu_empleado=93902761 limit 1
	--select * from CAT_CICLOS_ESCOLARES
	UPDATE 	tmp_facturas SET ciclo =trim(a.des_ciclo_escolar )
	FROM 	CAT_CICLOS_ESCOLARES a 
	WHERE  	tmp_facturas.idCiclo =a.idu_ciclo_escolar; 

	delete from tmp_Conceptos;

	RAISE NOTICE '%', 'tmp_conceptos 1';
	
	INSERT 	INTO  tmp_Conceptos( importe, iFactura)	
	select 	sum(importe_concepto), idfactura 
	from 	MOV_DETALLE_FACTURAS_COLEGIATURAS 
	INNER 	JOIN tmp_facturas as tmp on (mov_detalle_facturas_colegiaturas.idfactura = tmp.iFactura)
	where 	idu_empleado=tmp.empleado
	group 	by mov_detalle_facturas_colegiaturas.idfactura, mov_detalle_facturas_colegiaturas.prc_descuento;
	
	--if (iEmpleado>0) then
	if (iTipoConsulta=0) then
		--CALCULO IMPORTES	
		--insert 	into tmp_Importes_Calculados (iFactura, importe_calculado) 
		--SELECT 	ifactura, nimporte_calculado 
		--FROM	fun_realizar_calculos_escenarios (sEmpleados::int, 0);  

		SELECT 	nimporte_concepto, nimporte_calculado 
		FROM 	fun_realizar_calculos_escenarios (sEmpleados::int, 0) as fun 
		into 	nImporteConcepto, nImporteCalculado;
	end if;

	--
	update 	tmp_facturas SET importeConcepto=a.importe		
	from 	tmp_Conceptos a
	where 	a.iFactura=tmp_facturas.iFactura;

	--
	update 	tmp_facturas SET --importeConcepto=a.importe_concepto
		importeCal=a.importe_calculado
		,importePagar=a.importe_pagado
	from 	MOV_FACTURAS_COLEGIATURAS a
	where 	a.idfactura=tmp_facturas.iFactura;


	
	DELETE FROM tmp_Conceptos;

	RAISE 	NOTICE '%', 'tmp_conceptos 2';
	INSERT 	INTO  tmp_Conceptos( periodo, iFactura)	
	select 	count( DISTINCT a.idu_tipopago ),a.idfactura  
	from 	MOV_DETALLE_FACTURAS_COLEGIATURAS a
	INNER 	JOIN mov_facturas_colegiaturas b on a.idFactura=b.idFactura
	INNER 	JOIN tmp_facturas as tmp on (a.idfactura = tmp.iFactura)
	where 	a.idu_empleado=tmp.empleado and b.idu_estatus=iOpcion 
	group 	by a.idfactura;

	--OTPP
	UPDATE 	TMP_FACTURAS SET otpp= CASE WHEN a.periodo=1 THEN 0 ELSE 1 END
	from 	TMP_CONCEPTOS a
	where 	a.iFactura=tmp_facturas.iFactura;

	--TOPE FACTURA
	UPDATE 	tmp_facturas set topeFactura=(SAPCATALOGOEMPLEADOS.sueldo/2)/100
		,marcaTope= case when tmp_facturas.importeRealFact>((SAPCATALOGOEMPLEADOS.sueldo/2)/100) then 1 else 0 end
	FROM 	SAPCATALOGOEMPLEADOS 
	where 	numempn=tmp_facturas.empleado ;

	--PORCENTAJE DESCUENTO
	UPDATE 	tmp_facturas set prc_descuento = det.prc_descuento
	from 	mov_detalle_facturas_colegiaturas as det
	where 	tmp_facturas.iFactura = det.idfactura;

	--IMPORTE CALCULADO IMPORTE PAGAR
	UPDATE 	tmp_facturas set importeCal=a.importe_calculado, importePagar=a.importe_pagado
	from 	MOV_FACTURAS_COLEGIATURAS a
	where 	a.idfactura =tmp_facturas.iFactura;
	
	--BLOG CSC
	UPDATE	tmp_facturas SET opc_blog=1
	FROM 	MOV_BLOG_REVISION B
	WHERE	tmp_facturas.ifactura=B.id_factura;

	--BLOG COLABORADOR
	UPDATE	tmp_facturas SET opc_blog_colaborador=1
	FROM 	MOV_BLOG_ACLARACIONES B
	WHERE	tmp_facturas.ifactura=B.id_factura;
	
	--NOTA DE CREDITO
	update 	tmp_facturas set idNotaCredito= B.idnotacredito  
	from	MOV_APLICACION_NOTAS_CREDITO B
	where	tmp_facturas.ifactura=B.idfactura;

	--FOLIO NOTA CREDITO	
	UPDATE 	TMP_FACTURAS set folionota = B.fol_fiscal
	from	MOV_FACTURAS_COLEGIATURAS B
	where 	tmp_facturas.idnotacredito=B.idfactura;
	
	--IMPORTE APLICADO 
	UPDATE 	TMP_FACTURAS SET importeaplicado=B.importe_aplicado, importePagar=(importePagar-B.importe_aplicado)
	from 	MOV_APLICACION_NOTAS_CREDITO B
	where	TMP_FACTURAS.ifactura=B.idfactura;

	--MOTIVO
	update 	TMP_FACTURAS set des_motivo_revision=B.des_motivo
	from	CAT_MOTIVOS_COLEGIATURAS B	
	where 	idu_tipo_motivo=4
		and TMP_FACTURAS.idu_motivo_revision=B.idu_motivo;	
-- SE AGREGO LA CONDICIÃâN PARA VERIFICAR SI LA FACTURA TIENE MONEDA NACIONAL O EXTRANJERA.
-- MODIFICAR IMPORTE CONCEPTO CUANDO EXCEDA EL IMPORTE REAL (CENTAVOS DE MAS)
update 	tmp_facturas set importeConcepto=importeRealFact, importeCal=importeRealFact*(prc_descuento/100.00),importePagar=importeRealFact*(prc_descuento/100.00)
where	(importeConcepto>importeRealFact) AND (select ctipomoneda from tipo_moneda_colegiaturas where idfactura = tmp_facturas.ifactura) = 'MXN';

	
	if (exists (select idu_escuela from MOV_REVISION_COLEGIATURAS where idu_escuela in (select idEscuela from TMP_FACTURAS))) then

		--MOV_REVISION_COLEGIATURAS where idu_usuario_captura=95194185
		--
		/*insert into tmp_Fechas (iEscuela, FechaAsignacion, FechaConcluyo)
		select 	distinct idu_escuela, to_char(fec_captura,'dd/mm/yyyy'), to_char(fec_conclusion,'dd/mm/yyyy') 
		from 	MOV_REVISION_COLEGIATURAS
		where	idu_escuela= (select distinct idEscuela from TMP_FACTURAS limit 1);*/

		/*insert 	into tmp_Fechas (iEscuela, FechaAsignacion, FechaConcluyo)
		select 	idu_escuela, to_char(fec_captura,'dd/mm/yyyy'), to_char(fec_conclusion,'dd/mm/yyyy') 
		from 	MOV_REVISION_COLEGIATURAS
		where	idu_escuela=*/

		--
		/*
		UPDATE  TMP_FACTURAS SET fechaasignacion=B.FechaAsignacion, fechaconcluyo=B.FechaConcluyo
		FROM    tmp_Fechas B
		WHERE   TMP_FACTURAS.idEscuela=B.iEscuela;
		*/

		UPDATE  TMP_FACTURAS SET fechaasignacion=to_char(B.fec_captura,'dd/mm/yyyy'), fechaconcluyo=to_char(B.fec_conclusion,'dd/mm/yyyy')
		FROM    MOV_REVISION_COLEGIATURAS B
		WHERE   TMP_FACTURAS.idEscuela=B.idu_escuela;
		
	end if;

	DELETE FROM tmp_Conceptos;

	if (((select count(*) from tmp_facturas )>0) and (iTipoConsulta <>0))  then
		sSQL :=  ('	INSERT 	INTO tmp_facturas ( factura, importeRealFact)
				SELECT 	''0'', sum(importeRealFact)
				FROM 	tmp_facturas ');
		update 	tmp_facturas set importePagar=(select sum(importeRealFact) FROM tmp_facturas  where estatus=6)
		where 	factura='0';

		EXECUTE sSQL;
		--update 	tmp_facturas set fechaFactura= '01/01/1900' where  factura='0';		
		update 	tmp_facturas set fec_orden= '19000101'::DATE where  factura='0';		

		if iTipoConsulta=1 then
			update tmp_facturas set fecha_estatus= (select fecha_estatus from tmp_facturas order by fecha_estatus desc limit 1) where  factura='0';	
		end if;		
	end if;	

	--select  max(fec_factura) from mov_facturas_colegiaturas  
	UPDATE tmp_facturas SET tipo_deduccion=case when idTipoEscuela=1 then 2 ELSE 1 END;

	iRecords := (SELECT COUNT(*) FROM tmp_facturas);	
	IF (iRowsPerPage IS NOT NULL AND iCurrentPage IS NOT NULL) then
		iStart := (iRowsPerPage * iCurrentPage) - iRowsPerPage + 1;
		iRecords := (SELECT COUNT(*) FROM tmp_facturas);
		iTotalPages := ceiling(iRecords / (iRowsPerPage * 1.0));

		sConsulta := '
			select ' || CAST(iRecords AS VARCHAR) || ' AS records
			    , ' || CAST(iCurrentPage AS VARCHAR) || ' AS page
			    , ' || CAST(iTotalPages AS VARCHAR) || ' AS pages
			    , id
			    , ' || sColumns || '
			from (
				SELECT ROW_NUMBER() OVER (ORDER BY ' || sOrderColumn || ' ' || sOrderType || ') AS id, ' || sColumns || '
				FROM tmp_facturas
				) AS t
			where  t.id between ' || CAST(iStart AS VARCHAR) || ' and ' || CAST(((iStart + iRowsPerPage) - 1) AS VARCHAR) || ' ';
	ELSE
		sConsulta := ' SELECT ' || iRecords::VARCHAR || ',0,0,0,' || sColumns || ' FROM tmp_facturas ';
		
	END if;
	sConsulta := sConsulta || 'ORDER BY ' || sOrderColumn || ' ' || sOrderType;

	RAISE NOTICE 'notice %', sConsulta;

    for returnrec in execute sConsulta loop
        RETURN NEXT returnrec;
    end loop;
END;
$function$