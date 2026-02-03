DROP FUNCTION if exists fun_obtener_totales_traspaso(integer);

CREATE OR REPLACE FUNCTION fun_obtener_totales_traspaso(IN iusuario integer
, OUT icolaborador integer
, OUT nimportepagado integer)
  RETURNS SETOF record AS
$BODY$
declare
/*----------------------------------------------------------------------------
	No.Petición:			16559.1
	Fecha:				04/07/2018
	Numero Empleado: 		98439677
	Nombre Empleado: 		Rafael Ramos Gutiérrez
	BD:				PERSONAL    
	Servidor:			10.44.2.183
	Sistema:			Colegiaturas
	Modulo: 			Traspaso de movimientos
	Ejemplo:		
		SELECT * FROM fun_obtener_totales_traspaso(95194185);

		select * from mov_facturas_colegiaturas where idu_empleado = 91924162
----------------------------------------------------------------------------*/
	valor record;
begin
	create temporary table tmp_traspaso(
	iColaborador integer not null default 0
	, nImportePagado integer not null default 0
	)on commit drop;

	insert into	tmp_traspaso(iColaborador, nImportePagado)
	select		T.empleado, (T.importe_pago*100) as nImporte_pagado
	from		stmp_traspaso_colegiaturas T
	where		T.usuario = iUsuario
			AND	T.marcado = 1;

	for valor in (
        select T.iColaborador as iColaborador
			, SUM(T.nImportePagado) as nImportePagado
		from tmp_traspaso T
		group by T.iColaborador) loop
				iColaborador 	:= valor.iColaborador::INTEGER;
				nImportePagado	:= valor.nImportePagado::integer;
        return next;
	end loop;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
GRANT EXECUTE ON FUNCTION fun_obtener_totales_traspaso(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_obtener_totales_traspaso(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_obtener_totales_traspaso(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_obtener_totales_traspaso(integer) TO postgres;
COMMENT ON FUNCTION fun_obtener_totales_traspaso(integer) IS 'La función obtiene un listado de colaboradores y el total del importe pagado para el cálculo del ISR.';