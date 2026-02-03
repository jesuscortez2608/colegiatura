CREATE OR REPLACE FUNCTION fun_precargar_captura_empleado_beneficiarios(integer, integer, integer, integer, integer)
  RETURNS SETOF type_precargar_captura_empleado_beneficiarios AS
$BODY$
   DECLARE

        iEmpleado     	ALIAS FOR $1;
        iBeneficiario 	ALIAS FOR $2;
        iEscuela   	ALIAS FOR $3;
        iEscolaridad   	ALIAS FOR $4;
        iGrado   	ALIAS FOR $5;
        registro	type_precargar_captura_empleado_beneficiarios;
        nombre varchar(100);
        rfc varchar(20);
        
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 29/11/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : personal
	     Servidor de pruebas            : 10.44.64.190
	     Servidor de produccion         : 10.44.1.14
	     Descripción del funcionamiento : 
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Subir factura 
	     Ejemplo                        : 

	select * from mov_configuracion_costos
	select * from his_configuracion_costos
		 SELECT * FROM fun_precargar_captura_empleado_beneficiarios(97060151,8749919,1,3,1); 
		--  SELECT * FROM fun_precargar_captura_empleado_beneficiarios(95194185,1,6,1,1); 
		SELECT * FROM fun_precargar_captura_empleado_beneficiarios(95194185,1,12,1,1); 

	select * from mov_detalle_facturas_colegiaturas

		 SELECT * FROM fun_precargar_captura_empleado_beneficiarios(96799251,1,9,0,0); 


select idu_tipopago, periodo, idu_escolaridad, idu_grado_escolar,idu_ciclo_escolar, importe_concepto,2 from mov_detalle_facturas_colegiaturas
	WHERE idu_empleado=96799251 and idu_beneficiario=1 and idu_escuela=9

		 
	*/
	
BEGIN
	create local temp table tmp_detalles_facturas  
	(
		
		idu_tipo_pago  integer  not null default 0,
		nom_periodo varchar(150)  not null default '',
		idu_escolaridad integer  not null default 0,
		idu_grado integer  not null default 0,
		idu_ciclo integer not null default 0,
		idu_costo_conf integer not null default 0,
		imp_importe numeric(12,2)

	) on commit drop; 


	create local temp table tmp_escuelas
	(
		idu_escuela integer  not null default 0
	) on commit drop; 


	nombre:= nom_escuela from cat_escuelas_colegiaturas where idu_escuela=iEscuela;
	rfc:= rfc_clave_sep from cat_escuelas_colegiaturas where idu_escuela=iEscuela;

	insert into tmp_escuelas (idu_escuela)
	select idu_escuela from cat_escuelas_colegiaturas where trim(nom_escuela)=trim(nombre) and  trim(rfc_clave_sep)= trim(rfc);

	
	
	INSERT INTO tmp_detalles_facturas(idu_tipo_pago, nom_periodo, idu_escolaridad, idu_grado,idu_ciclo, imp_importe,idu_costo_conf)
	select idu_tipopago, periodo, idu_escolaridad, idu_grado_escolar,idu_ciclo_escolar, importe_concepto,0 from mov_detalle_facturas_colegiaturas
	WHERE idu_empleado=iEmpleado and idu_beneficiario=iBeneficiario and idu_escuela=iEscuela
	order by fec_registro desc limit 1;
	
	IF EXISTS (select idu_empleado from cat_empleados_colegiaturas where  opc_validar_costos=0 and idu_empleado=iEmpleado) THEN -- Novalidar costo

		update tmp_detalles_facturas set idu_costo_conf=0;

		if (select count(*) from tmp_detalles_facturas )=0 then

			insert into tmp_detalles_facturas (idu_costo_conf, imp_importe)
			select 0,0 ;
		end if;	
	else
	
		-- select * from mov_detalle_facturas_colegiaturas
		update tmp_detalles_facturas set idu_costo_conf=0, imp_importe=a.imp_colegiatura
		from his_configuracion_costos a 
		where a.idu_empleado=iEmpleado 
			and a.idu_beneficiario=iBeneficiario
			and a.idu_escuela=iEscuela
			and a.estatus_configuracion = 1;
		--select * from mov_configuracion_costos
		if (select count(*) from tmp_detalles_facturas )=0 then

			insert into tmp_detalles_facturas (idu_costo_conf, imp_importe)
			select 0, imp_colegiatura from his_configuracion_costos
			where idu_empleado=iEmpleado 
				and idu_beneficiario=iBeneficiario 
				and idu_escuela in (select idu_escuela from  tmp_escuelas)   --iEscuela 
				--and idu_escolaridad=iEscolaridad 
				and estatus_configuracion = 1;
			if (select count(*) from tmp_detalles_facturas )=0 then

				insert into tmp_detalles_facturas (idu_costo_conf, imp_importe)
				select 2, imp_colegiatura from mov_configuracion_costos
				where idu_empleado=iEmpleado 
				and idu_beneficiario=iBeneficiario 
				and idu_escuela in (select idu_escuela from  tmp_escuelas);   --iEscuela 
				if (select count(*) from tmp_detalles_facturas )=0 then
					insert into tmp_detalles_facturas (idu_costo_conf, imp_importe)
					select 1, 0 ;
				end if;	
			end if;
		end if;
	end if;
	FOR registro IN ( SELECT idu_tipo_pago, nom_periodo, idu_escolaridad, idu_grado, idu_ciclo, idu_costo_conf, imp_importe from tmp_detalles_facturas ) 
	LOOP
		RETURN NEXT registro;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_precargar_captura_empleado_beneficiarios(integer, integer, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_precargar_captura_empleado_beneficiarios(integer, integer, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_precargar_captura_empleado_beneficiarios(integer, integer, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_precargar_captura_empleado_beneficiarios(integer, integer, integer, integer, integer) TO postgres;