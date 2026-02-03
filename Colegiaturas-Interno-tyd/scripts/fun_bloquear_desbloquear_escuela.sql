DROP FUNCTION if exists fun_bloquear_desbloquear_escuela(integer, character varying, integer);

CREATE OR REPLACE FUNCTION fun_bloquear_desbloquear_escuela(integer, character varying, integer)
  RETURNS character varying AS
$BODY$
declare 
	iEscuela ALIAS FOR $1;
	cObservaciones ALIAS FOR $2;
	iCapturo ALIAS FOR $3;
	iOpcEscuelaBloqueada integer;
	iEstado integer;
	mensaje varchar(50);
    /*
     No. petición APS               : 8613.1
     Fecha                          : 15/09/2016
     Número empleado                : 96753269
     Nombre del empleado            : Jesús Ramón Vega Taboada
     Base de datos                  : administracion
     Servidor de produccion         : 10.44.2.29
     Descripción del funcionamiento : 
     Descripción del cambio         : NA
     Sistema                        : Colegiaturas
     Módulo                         : Configuración de escuelas
     Ejemplo                        : Bloquea o desbloquea las escuelas
				       select fun_bloquear_desbloquear_escuela(7,'prueba', 95194185);
    ------------------------------------------------------------------------------------------------------ 
     No. Peticion		    : 16559.1
     Fecha			    : 03/08/2018
     Colaborador		    : 98439677 Rafael Ramos
     Descripcion del cambio	    : Se agregan las observaciones al bloquear la escuela
    ----------------------------------------------------------------------------------------------------------*/
begin
	iEstado := 0;
	if exists (select opc_escuela_bloqueada from cat_escuelas_colegiaturas where idu_escuela=iEscuela) then
		iOpcEscuelaBloqueada:=(select opc_escuela_bloqueada from cat_escuelas_colegiaturas where idu_escuela=iEscuela );
		iEstado := (SELECT idu_estado FROM cat_escuelas_colegiaturas where idu_escuela = iEscuela);

		UPDATE	cat_escuelas_colegiaturas 
		SET 	opc_escuela_bloqueada = CASE WHEN iOpcEscuelaBloqueada=0  THEN  1 ELSE 0 END
			, observaciones=upper(cObservaciones) 
			, fec_captura = now()
			, id_empleado_registro = iCapturo
		WHERE 	idu_escuela=iEscuela;
        
		if(iOpcEscuelaBloqueada = 0) then
			mensaje:='La escuela se bloqueo';
            
			update	mov_facturas_colegiaturas 
			set 	idu_estatus = 3 -- Rechazada
				, emp_marco_estatus = iCapturo
				, fec_marco_estatus = now()
				, des_observaciones = 'RECHAZADA POR SISTEMA AL BLOQUEAR LA ESCUELA: "' || cObservaciones || '"'
			WHERE 	idu_estatus in (0,1,2,4,5) 
				and idu_escuela=iEscuela ;
		else
            -- Deben recuperarse las facturas cuando se desbloquea la escuela
            --cat_estatus_facturas
			if (iEstado = 0) then -- Cuando se trata de escuelas EXTRANJERAS/EN LINEA ( idu_Estado = 0)
				mensaje	:= 'La escuela se desbloqueo';
				UPDATE	mov_facturas_colegiaturas
				set	idu_estatus = 1
					, emp_marco_estatus = iCapturo
					, fec_marco_estatus = now()
					, des_observaciones = 'EN ESTATUS EN PROCESO AL DESBLOQUEAR LA ESCUELA'
				WHERE	idu_estatus IN (1,2,3,4,5)
					AND idu_escuela = iEscuela;

			else
			
				mensaje:='La escuela se desbloqueo';
				update	mov_facturas_colegiaturas 
				set 	idu_estatus = 0 -- Pendiente
					, emp_marco_estatus = iCapturo
					, fec_marco_estatus = now()
					, des_observaciones = 'EN ESTATUS PENDIENTE AL DESBLOQUEAR LA ESCUELA'
				WHERE 	idu_estatus in (1,2,3,4,5) 
					and idu_escuela=iEscuela;
			end if;
		end if;
	end if;
	
	return mensaje as mensaje;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_bloquear_desbloquear_escuela(integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_bloquear_desbloquear_escuela(integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_bloquear_desbloquear_escuela(integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_bloquear_desbloquear_escuela(integer, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_bloquear_desbloquear_escuela(integer, character varying, integer) IS 'La función guarda las claves de uso permitidas en las facturas de colegiaturas.';