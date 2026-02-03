CREATE OR REPLACE FUNCTION fun_eliminar_descuentos_revision(iusuario integer, ikeyx integer, itiporegistro integer)
  RETURNS void AS
$BODY$
DECLARE
	
BEGIN

      DELETE FROM STMP_DETALLE_REVISION_COLEGIATURAS WHERE KEYX=iKeyx AND IDU_USUARIO=iUsuario and idu_tipo_registro=iTipoRegistro;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER;
  
GRANT EXECUTE ON FUNCTION fun_eliminar_descuentos_revision(iusuario integer, ikeyx integer, itiporegistro integer) TO sysinternet;
GRANT EXECUTE ON FUNCTION fun_eliminar_descuentos_revision(iusuario integer, ikeyx integer, itiporegistro integer) TO syspersonal;
GRANT EXECUTE ON FUNCTION fun_eliminar_descuentos_revision(iusuario integer, ikeyx integer, itiporegistro integer) TO sysetl;
GRANT EXECUTE ON FUNCTION fun_eliminar_descuentos_revision(iusuario integer, ikeyx integer, itiporegistro integer) TO postgres;
COMMENT ON FUNCTION fun_eliminar_descuentos_revision(iusuario integer, ikeyx integer, itiporegistro integer)   IS 'La función elimina los descuentos de la escuela que se encuentra en revisión';

  
  