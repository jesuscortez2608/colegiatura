DROP FUNCTION IF EXISTS fun_grabar_stmp_detalle_facturas_colegiaturas(integer, integer, character varying, integer, integer, integer, character varying, integer, integer, integer, integer, numeric, integer, integer, integer);
DROP TYPE IF EXISTS type_guarda_stmpdetalle_factura_co;

CREATE TYPE type_guarda_stmpdetalle_factura_co AS
   (estado integer,
    mensaje character varying(150));

CREATE OR REPLACE FUNCTION fun_grabar_stmp_detalle_facturas_colegiaturas(integer, integer, character varying, integer, integer, integer, character varying, integer, integer, integer, integer, numeric, integer, integer, integer)
  RETURNS SETOF type_guarda_stmpdetalle_factura_co AS
$BODY$
DECLARE
	iKeyx	       		 ALIAS FOR $1;
	iEmpleado	 	 ALIAS FOR $2;
	cFolioFiscal		 ALIAS FOR $3;
	iBeneficiario	 	 ALIAS FOR $4; 
	iParentesco	 	 ALIAS FOR $5; 
	iTipoPago 		 ALIAS FOR $6;
	cPeriodo		 ALIAS FOR $7;
	iEscuela	     	 ALIAS FOR $8;
	iEscolaridad	  	 ALIAS FOR $9;
	iGrado		  	 ALIAS FOR $10;
	iCiclo		  	 ALIAS FOR $11;
	nImporte		 ALIAS FOR $12;
	iFactura		 ALIAS FOR $13;
	iConDesc		 ALIAS FOR $14;
	iCarrera		 ALIAS FOR $15;
	iHojaAzul		 SMALLINT DEFAULT 0; 	
	iRegresa 		 SMALLINT DEFAULT 0;
	iDescuento 		 SMALLINT DEFAULT 0; 
	iPuesto			 INTEGER;	
	iSeccion  		 INTEGER;
	iCentro                  INTEGER;  
	registros type_guarda_stmpdetalle_factura_co;
	  /*
	     No. petición APS               : 8613.1
	     Fecha                          : 11/10/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.29
	     Descripción del funcionamiento : Guarda los datos de la factura en la tabla tenporal 
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Suplentes
	     Ejemplo                        : 
		SELECT fun_grabar_stmp_detalle_facturas_colegiaturas(0, 93902761, 'B0BDB98B-9641-4837-A7D4-27F43739D55C', 7425080, 11, 1, '1', 24, 1, 0, 2016, 1000,7,0)	
		 
	*/
	
BEGIN
	iDescuento:=50;
	if not exists(select idu_beneficiario from cat_beneficiarios_colegiaturas where idu_empleado=iEmpleado and  idu_beneficiario=iBeneficiario and idu_parentesco=iParentesco) then
		iHojaAzul:=1;
	end if;
	iPuesto:=pueston from sapcatalogoempleados where numempn=iEmpleado;
	iCentro:=centron from sapcatalogoempleados where numempn=iEmpleado;
	iSeccion:= seccion::integer from sapcatalogocentros where centron=iCentro;

	--OBTENER DESCUENTO
	IF EXISTS (SELECT idu_empleado from CTL_CONFIGURACION_DESCUENTOS where idu_empleado=iEmpleado AND IDU_PARENTESCO=iParentesco and idu_escolaridad=iEscolaridad) THEN -- EMPLEADO

		iDescuento:=por_porcentaje FROM CTL_CONFIGURACION_DESCUENTOS where idu_empleado=iEmpleado AND IDU_PARENTESCO=iParentesco and idu_escolaridad=iEscolaridad;
	END IF;
	IF iDescuento=0 THEN	
		IF EXISTS (SELECT idu_puesto from CTL_CONFIGURACION_DESCUENTOS where idu_puesto=iPuesto AND IDU_PARENTESCO=iParentesco and idu_escolaridad=iEscolaridad AND (idu_seccion=iSeccion OR idu_seccion=0)) THEN -- PUESTO - SECCION

			iDescuento:=por_porcentaje FROM CTL_CONFIGURACION_DESCUENTOS where idu_puesto=iPuesto AND IDU_PARENTESCO=iParentesco and idu_escolaridad=iEscolaridad AND (idu_seccion=iSeccion OR idu_seccion=0);
			IF iDescuento=0 THEN
				iDescuento:=por_porcentaje FROM CTL_CONFIGURACION_DESCUENTOS where idu_puesto=iPuesto AND idu_seccion=0 AND IDU_PARENTESCO=iParentesco and idu_escolaridad=iEscolaridad;
			END IF;
		END IF;
	END IF;
	IF iDescuento=0 THEN	
		IF EXISTS (SELECT idu_centro from CTL_CONFIGURACION_DESCUENTOS where idu_centro=iCentro AND IDU_PARENTESCO=iParentesco and idu_escolaridad=iEscolaridad AND (idu_puesto=iPuesto OR idu_puesto=0)) THEN -- POR CENTRO
			iDescuento:=por_porcentaje FROM CTL_CONFIGURACION_DESCUENTOS where idu_centro=iCentro AND idu_puesto=iPuesto AND IDU_PARENTESCO=iParentesco and idu_escolaridad=iEscolaridad;
			IF iDescuento=0 THEN
				iDescuento:=por_porcentaje FROM CTL_CONFIGURACION_DESCUENTOS where idu_centro=iCentro AND idu_puesto=0 AND IDU_PARENTESCO=iParentesco and idu_escolaridad=iEscolaridad;
			END IF;	
		ELSE
			iDescuento:=50; -- NO HAY CONFIGURACION
		END IF;
	END IF;	
	
	if iConDesc=0 then -- valida que los beneficiarios tengan el mismo descuento
		IF EXISTS (SELECT idFactura from stmp_detalle_facturas_colegiaturas where idfactura=iFactura) THEN -- COMPARAR CON LOS DESCUENTOS EXISTENTES
			IF iDescuento not in (SELECT prc_descuento from stmp_detalle_facturas_colegiaturas where idfactura=iFactura) THEN 
				iRegresa:=-1;
			END IF;
		END IF;	
	END IF;
	IF iRegresa=0 THEN
        -- Actualiza la escuela en el encabezado
        update stmp_facturas_colegiaturas set idu_escuela = iEscuela
        where idfactura = iFactura;
        
		IF iKeyx=0 THEN --INSERTA
			-- SI EXISTE EL REGISTRO
			IF EXISTS (	select 	idFactura 
					from 	stmp_detalle_facturas_colegiaturas 
					where 	idu_empleado=iEmpleado 
						and idFactura=iFactura 
						and idu_beneficiario=iBeneficiario 
						and idu_tipopago=iTipoPago
						and trim(periodo)=trim(cPeriodo) 
						and idu_escolaridad=iEscolaridad 
						and idu_carrera=iCarrera
						and idu_grado_escolar=iGrado 
						and idu_ciclo_escolar=iCiclo) THEN
				iRegresa:=2;
			ELSE	
				INSERT INTO stmp_detalle_facturas_colegiaturas(idu_empleado, fol_fiscal, beneficiario_hoja_azul, idu_beneficiario, idu_parentesco, idu_tipopago,prc_descuento, periodo, idu_escuela, idu_escolaridad, idu_carrera, idu_grado_escolar, idu_ciclo_escolar,importe_concepto, idFactura)
				SELECT 	iEmpleado, TRIM(cFolioFiscal), iHojaAzul, iBeneficiario, iParentesco, iTipoPago,iDescuento, cPeriodo, iEscuela, iEscolaridad, iCarrera, iGrado, iCiclo, nImporte, iFactura;
				iRegresa:=0;
			END IF;	
		
		ELSE --ACTUALIZA  
			IF EXISTS (select idFactura from stmp_detalle_facturas_colegiaturas where idu_empleado=iEmpleado and idFactura=iFactura and idu_beneficiario=iBeneficiario and idu_tipopago=iTipoPago
				and trim(periodo)=trim(cPeriodo) and idu_escolaridad=iEscolaridad and idu_grado_escolar=iGrado and idu_ciclo_escolar=iCiclo AND importe_concepto=nImporte) THEN
				iRegresa:=2;
			ELSE	
				UPDATE stmp_detalle_facturas_colegiaturas SET beneficiario_hoja_azul = iHojaAzul, idu_beneficiario=iBeneficiario, idu_parentesco = iParentesco, idu_tipopago=iTipoPago, periodo=trim(cPeriodo), 
				idu_escolaridad=iEscolaridad, idu_grado_escolar=iGrado, idu_ciclo_escolar=iCiclo, importe_concepto=nImporte, prc_descuento=iDescuento, idu_carrera=iCarrera 
				WHERE idu_empleado=iEmpleado and idFactura=iFactura and keyx=iKeyx;
				iRegresa:=1;
			END IF;
			
		END IF;
	END IF;	
	FOR registros IN 
		SELECT 	iRegresa, case when iRegresa=-1 then 'No se permite subir facturas con diferentes porcentajes de descuento, favor de facturar por separado' 
			when iRegresa=0 then 'Se agregó el detalle del beneficiario' when iRegresa=1 then 'Se actualizó el beneficiario' 
		else 'El beneficiario ya se agregó, favor de verificar' end as mensaje
	LOOP
		RETURN NEXT registros;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_stmp_detalle_facturas_colegiaturas(integer, integer, character varying, integer, integer, integer, character varying, integer, integer, integer, integer, numeric, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_stmp_detalle_facturas_colegiaturas(integer, integer, character varying, integer, integer, integer, character varying, integer, integer, integer, integer, numeric, integer, integer, integer) TO syspersonal;
COMMENT ON FUNCTION fun_grabar_stmp_detalle_facturas_colegiaturas(integer, integer, character varying, integer, integer, integer, character varying, integer, integer, integer, integer, numeric, integer, integer, integer) IS 'La función graba el detalle de la factura en una tabla temporal fija.';