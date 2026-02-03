drop function if exists fun_datos_salidas_dinero_bancos(integer, date, integer);
drop type if exists type_datos_salidas_dinero_bancos;

CREATE TYPE type_datos_salidas_dinero_bancos AS (clv_cuenta_origen character varying(50)
    , clv_banco_origen character varying(10)
    , clv_sucursal_origen character varying(10)
    , imp_monto character varying(20)
    , clv_cuenta_destino character varying(50)
    , clv_banco_destino character varying(10)
    , clv_sucursal_destino character varying(10)
    , fec_transferencia character varying(10)
    , num_empleado character varying(10)
    , nom_empleado character varying(150)
    , clv_rfc_empleado character varying(13)
    , clv_salida integer
    , num_empleado_capturo integer
    , fec_capturo date);

CREATE OR REPLACE FUNCTION fun_datos_salidas_dinero_bancos(integer, date, integer)
 RETURNS SETOF type_datos_salidas_dinero_bancos
AS $function$
DECLARE
    iClaveBancoOrigen      ALIAS FOR $1;
    FechaTransferencia     ALIAS FOR $2;
    iClaveSalida           ALIAS FOR $3;
    registro   type_datos_salidas_dinero_bancos;
BEGIN
/*
	NOMBRE: Verdugo Ahumada Jose Raul 95669752
	BD: Administracion PostgreSQL
	FECHA: 26/12/2014
	SERVIDOR PRUEBAS: 10.28.114.75
	SERVIDOR PRODUCCION: 10.44.2.29
	DESCRIPCION: Funcion que regresa los datos para insertarlos en ContabilidadNueva
	MODULO: Colegiaturas WEB
*/
	FOR registro IN SELECT clv_cuenta_origen, clv_banco_origen, clv_sucursal_origen, imp_monto, clv_cuenta_destino, clv_banco_destino, clv_sucursal_destino, 
				fec_transferencia, num_empleado, nom_empleado, clv_rfc_empleado, clv_salida, num_empleado_capturo, fec_capturo
			FROM mov_datos_envio_sat 
			WHERE cast(CLV_BANCO_ORIGEN as int) = iClaveBancoOrigen
			AND date(fec_transferencia) = FechaTransferencia
			AND CLV_SALIDA = iClaveSalida
	LOOP
		RETURN NEXT registro;
	END LOOP;
END
$function$
LANGUAGE plpgsql volatile;