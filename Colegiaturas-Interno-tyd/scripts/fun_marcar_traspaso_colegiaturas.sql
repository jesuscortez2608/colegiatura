DROP FUNCTION IF EXISTS fun_marcar_traspaso_colegiaturas(integer, integer, integer, integer, integer);

CREATE OR REPLACE FUNCTION fun_marcar_traspaso_colegiaturas(integer, integer, integer, integer, integer)
  RETURNS void AS
$BODY$
declare 
	iFactura 	ALIAS FOR $1;
	iMarca 		ALIAS FOR $2;
	iEmpleado 	ALIAS FOR $3;
	iQuincena	ALIAS FOR $4;
	iTipoNomina	ALIAS FOR $5;
	
	/*
	     No. petición APS               : 8613.1
	     Fecha                          : 22/11/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : PERSONAL
	     Servidor de pruebas            : 10.44.2.89
	     Servidor de produccion         : 
	     Descripción del funcionamiento : Marca o desmarca una factura para el traspaso de factutas
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Traspaso
	     Ejemplo                        : 
		 select * from fun_marcar_traspaso_colegiaturas (19,93902761);
	--------------------------------------------------------------------------------------------
	     No. peticion		: 16559.1
	     Colaborador		: Rafael Ramos 98439677
	     Fecha			: 12/09/2018
	     Descripcion del cambio	: Se valida para que al marcar todas las facturas, tome en cuenta los filtros
					  de quincena y tipo de nomina de los colaboradores involucrados
						- si la quincena es 1, y el tipo de nomina es 0, marca todas las facturas
						- si la quincena es 1, y el tipo de nomina es 1, marca todas las facturas de colaboradores
						- si la quincena es 1, y el tipo de nomina es 3, marca todas las facturas de directivos
						- si la quincena es 2, marca las facturas de colaboradores, excluyendo las de directivos
	     Ejemplo:
		 SELECT * from fun_marcar_traspaso_colegiaturas(
			-1 
			, 1 
			, 90025628 
			, 2 
			, 1)
		---------Forma en que se presentan los parametros---------------------
			--iFactura
			--iMarca
			--iEmpleado
			--iQuincena
			--iTipoNom
	======================================================================================================	
	*/
	begin
		if iFactura=0 then --desmarcar todos
			UPDATE stmp_traspaso_colegiaturas SET marcado= 0 WHERE usuario= iEmpleado;
		elsif  iFactura=-1 then --Marcar todos
			if (iQuincena = 1) then
				if (iTipoNomina = 0) then
					UPDATE stmp_traspaso_colegiaturas SET marcado= 1 WHERE usuario= iEmpleado
						and tiponomina in (1,3);
				elsif (iTipoNomina = 1) then
					update stmp_traspaso_colegiaturas set marcado = 1 where usuario = iEmpleado
						and tiponomina = 1;
				elsif (iTipoNomina = 3) then
					update stmp_traspaso_colegiaturas set marcado = 1 where usuario = iEmpleado
						and tiponomina = 3;
				end if;
			elsif (iQuincena = 2) then
				update stmp_traspaso_colegiaturas set marcado = 1 where usuario = iEmpleado
					and tiponomina = 1;
			end if;
			
		else
			
			UPDATE stmp_traspaso_colegiaturas SET marcado= iMarca  WHERE  idfactura=iFactura and usuario= iEmpleado;
		end if;	
	end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_marcar_traspaso_colegiaturas(integer, integer, integer, integer, integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_marcar_traspaso_colegiaturas(integer, integer, integer, integer, integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_marcar_traspaso_colegiaturas(integer, integer, integer, integer, integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_marcar_traspaso_colegiaturas(integer, integer, integer, integer, integer) TO postgres;
COMMENT ON FUNCTION fun_marcar_traspaso_colegiaturas(integer, integer, integer, integer, integer) IS 'La funcion marca las facturas que se van a traspasar';