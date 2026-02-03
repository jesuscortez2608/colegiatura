CREATE OR REPLACE FUNCTION fun_bloquear_desbloquear_motivo(integer)
  RETURNS void AS
$BODY$
declare 
	iMotivo ALIAS FOR $1;
	iEstatus integer;
	 /*
	     No. petición APS               : 8613.1
	     Fecha                          : 02/09/2016
	     Número empleado                : 93902761
	     Nombre del empleado            : Nallely Machado
	     Base de datos                  : administracion
	     Servidor de pruebas            : 10.44.15.182
	     Servidor de produccion         : 10.44.2.24
	     Descripción del funcionamiento : Actualiza el estatus de los motivos
	     Descripción del cambio         : NA
	     Sistema                        : Colegiaturas
	     Módulo                         : Configuración de Motivos
	     Ejemplo                        : 
		 select * from fun_bloquear_desbloquear_motivo (1);
		 DROP FUNCTION fun_bloquear_desbloquear_motivo(integer );
	*/
begin
	if exists (select estatus from cat_motivos_colegiaturas where idu_motivo=iMotivo) then

		iEstatus:=(select estatus from cat_motivos_colegiaturas where idu_motivo=iMotivo );
		UPDATE cat_motivos_colegiaturas SET estatus= CASE WHEN iEstatus=0 THEN 1 ELSE 0 END WHERE idu_motivo=iMotivo;
		
	end if;
end;

$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION fun_bloquear_desbloquear_motivo(integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_bloquear_desbloquear_motivo(integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_bloquear_desbloquear_motivo(integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_bloquear_desbloquear_motivo(integer) TO postgres;
COMMENT ON FUNCTION fun_bloquear_desbloquear_motivo(integer) IS 'FUNCION PARA BLOQUEAR DESBLOQUEAR MOTIVO';