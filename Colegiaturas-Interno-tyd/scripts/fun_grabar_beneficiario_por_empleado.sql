DROP FUNCTION IF EXISTS fun_grabar_beneficiario_por_empleado(integer, character varying, character varying, character varying, integer, integer, integer, character varying, integer);

CREATE OR REPLACE FUNCTION fun_grabar_beneficiario_por_empleado(integer, character varying, character varying, character varying, integer, integer, integer, character varying, integer)
  RETURNS integer AS
$BODY$
/*
	No. petición APS               : 8613.1
	Fecha                          : 13/09/2016
	Número empleado                : 93902761
	Nombre del empleado            : Nallely Machado
	Base de datos                  : administracion
	Servidor de pruebas            : 10.44.15.182
	Servidor de produccion         : 10.44.2.29
	Descripción del funcionamiento : Inserta un beneficiario en la tabla cat_beneficiarios_colegiaturas
	===================================================================================================
	Descripción del cambio         : Se registra movimiento en la bitacora 'mov_bitacora_movimientos_colegiaturas' cuando se cambia el indicador de 'Especial' o la Observacion del beneficiario.
	Número empleado modifico       : 97695068
	Nombre del empleado modifico   : Hector Medina Escareño
	===================================================================================================
	Descripción del cambio	       : Se quita la creación de registro en bitacora al marcar o desmarcar un beneficiario como especial
	Sistema                        : Colegiaturas
	Módulo                         : Configuración de Empleados con Colegiatuta
	Ejemplo                        : 
				SELECT fun_grabar_beneficiario_por_empleado(93902761, 'ANA MARIA', 'MACHADO', 'JUAREZ', 10,  93902761, 1, 'TEST 1', 2)

		-- SELECT * FROM cat_beneficiarios_colegiaturas WHERE idu_empleado = 93902761;
		-- SELECT * FROM cat_tipos_movimientos_bitacora;  //-- Tabla catalogo de Movimientos.
		-- SELECT * FROM mov_bitacora_movimientos_colegiaturas; //-- Registro de movimientos. -- BITACORA
*/
DECLARE 
	iEmpleado alias for $1;
	cNombre alias for $2;
	cApePaterno alias for $3;
	cApeMaterno alias for $4;
	iParentesco alias for $5;
	iCapturo alias for $6;
	iEspecial alias for $7;
	cObservacion alias for $8;
	iBeneficiario alias for $9;

	resultado int;
BEGIN
	--iBeneficiario:=(SELECT COUNT(*)+1 FROM cat_beneficiarios_colegiaturas WHERE idu_empleado=iEmpleado);

	-- ACTUALIZA EL BENEFICIARIO
	IF EXISTS(SELECT IDU_BENEFICIARIO FROM cat_beneficiarios_colegiaturas WHERE idu_empleado = iEmpleado AND IDU_BENEFICIARIO = iBeneficiario) THEN
	
		IF EXISTS(
			SELECT idu_empleado
			FROM cat_beneficiarios_colegiaturas
			WHERE idu_empleado = iEmpleado
				AND TRIM(UPPER(nom_beneficiario)) = TRIM(UPPER(cNombre))
				AND TRIM(UPPER(ape_paterno)) = TRIM(UPPER(cApePaterno))
				AND TRIM(UPPER(ape_materno)) = TRIM(UPPER(cApeMaterno))
				AND idu_parentesco = iParentesco
				AND IDU_BENEFICIARIO != iBeneficiario)THEN --YA EXISTE ESE BENEFICIARIO
			resultado:= 0;
		ELSE
			-- Antes de actualizar. Verificar si se esta actualizando el campo 'opc_becado_especial' o 'des_observaciones'. para determinar si se debe de hacer el registro en la bitacora.
			/*RRG
			IF NOT EXISTS(SELECT idu_empleado
					FROM cat_beneficiarios_colegiaturas
					WHERE idu_empleado = iEmpleado
						AND idu_beneficiario = iBeneficiario
						AND opc_becado_especial = iEspecial
						AND TRIM(UPPER(des_observaciones)) = TRIM(UPPER(cObservacion))
				)THEN
				-- Registrar el movimiento en la bitacora.
				INSERT INTO mov_bitacora_movimientos_colegiaturas(idu_tipo_movimiento, idu_factura, idu_empleado_especial, idu_beneficiario_especial, idu_empleado_registro, des_justificacion, opc_beneficiario_especial)
				VALUES(4, 0, iEmpleado, iBeneficiario, iCapturo, TRIM(UPPER(cObservacion)), iEspecial);
			END IF;
			*/

			-- ACTUALIZAR --
			UPDATE cat_beneficiarios_colegiaturas
			SET nom_beneficiario = TRIM(UPPER(cNombre)),
				ape_paterno = TRIM(UPPER(cApePaterno)),
				ape_materno = TRIM(UPPER(cApeMaterno)),
				idu_parentesco = iParentesco,
				opc_becado_especial = iEspecial,
				des_observaciones = TRIM(UPPER(cObservacion)),
				fec_registro = now(),
				idu_empleado_registro = iCapturo
			WHERE idu_empleado = iEmpleado
				AND idu_beneficiario=iBeneficiario;
			resultado:=1;
		END IF;	
	
	ELSE -- INSERTA
		IF EXISTS (select idu_empleado FROM cat_beneficiarios_colegiaturas WHERE idu_empleado=iEmpleado AND TRIM(UPPER(nom_beneficiario))=TRIM(UPPER(cNombre) )
		AND TRIM(UPPER(ape_paterno))=TRIM(UPPER(cApePaterno)) AND TRIM(UPPER(ape_materno))=TRIM(UPPER(cApeMaterno)) AND idu_parentesco=iParentesco ) THEN --YA EXISTE ESE BENEFICIARIO 
			resultado:=0;
		ELSE
			
			INSERT INTO cat_beneficiarios_colegiaturas (idu_empleado,idu_beneficiario, nom_beneficiario, ape_paterno, ape_materno, idu_parentesco, opc_becado_especial, des_observaciones, fec_registro, idu_empleado_registro)
			VALUES (iEmpleado, iBeneficiario, TRIM(UPPER(cNombre)),TRIM(UPPER(cApePaterno)),TRIM(UPPER(cApeMaterno)), iParentesco, iEspecial, TRIM(UPPER(cObservacion)),now(), iCapturo );
			resultado:=1;
			IF NOT EXISTS (SELECT IDU_EMPLEADO FROM cat_estudios_beneficiarios WHERE IDU_EMPLEADO=iEmpleado) THEN -- SI NO EXISTE EL EMPLEADO EN LA CAT_ESTUDIOS_BENEFICIARIOS
				resultado:=2;
			END IF;
		END IF;
				
	END IF;

	RETURN resultado;
END; 
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_por_empleado(integer, character varying, character varying, character varying, integer, integer, integer, character varying, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_por_empleado(integer, character varying, character varying, character varying, integer, integer, integer, character varying, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_por_empleado(integer, character varying, character varying, character varying, integer, integer, integer, character varying, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_grabar_beneficiario_por_empleado(integer, character varying, character varying, character varying, integer, integer, integer, character varying, integer) TO postgres;
COMMENT ON FUNCTION fun_grabar_beneficiario_por_empleado(integer, character varying, character varying, character varying, integer, integer, integer, character varying, integer) IS 'La función graba un beneficiario para un colaborador.';