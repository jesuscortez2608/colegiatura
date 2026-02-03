CREATE PROCEDURE PROC_OBTENER_INCENTIVO_DESARROLLO
AS
SET NOCOUNT ON
BEGIN
-- ====================================================================================================
-- Peticion: 16559
-- Autor: Omar Alejandro Lizarraga Hernandez 94827443
-- Fecha: 09-08-2018
-- Descripción General: Obtiene el incentivo que le corresponde al rubro de desarrollo (colegiaturas)
-- Ruta Tortoise: svn://10.44.15.239/sysx/administracion/personalelp/PROYECTOSWEB/Colegiaturas/scripts
-- Sistema: Colegiaturas
-- Servidor Productivo: 10.44.1.13
-- Servidor Desarrollo: 10.44.1.135
-- Ejemplo: PROC_OBTENER_INCENTIVO_DESARROLLO()
-- ====================================================================================================
	SELECT	num_clavepersonal 
	FROM	cat_incentivos (NOLOCK) 
	WHERE	num_clavepersonal = 351

END
SET NOCOUNT OFF