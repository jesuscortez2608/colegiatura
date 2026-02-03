<?php	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	//-------------------------------------------------------------------------
	$json = new stdClass();
	$Opcion = isset($_POST['Opcion']) ? $_POST['Opcion'] : 0;
	$Empleado= isset($_POST['Empleado']) ? $_POST['Empleado'] : 0;
	$Centro= isset($_POST['Centro']) ? $_POST['Centro'] : 0;
	$puesto= isset($_POST['puesto']) ? $_POST['puesto'] : 0;
	$seccion= isset($_POST['seccion']) ? $_POST['seccion'] : 0;
	$escolaridad= isset($_POST['escolaridad']) ? $_POST['escolaridad'] : 0;	
	$parentesco= isset($_POST['parentesco']) ? $_POST['parentesco'] : 0;
	$porcentaje= isset($_POST['porcentaje']) ? $_POST['porcentaje'] : 0;
	$comentario= isset($_POST['comentario']) ? $_POST['comentario'] : '';
	$Numusuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';

	$comentario = $comentario;
	
	$estado=0;
	$mensaje='OK';
	try
	{
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];	
			
		if($estado != 0) {
			throw new Exception($mensaje);
		}

		$ds=""; //guardo los datos en la consulta del procedimiento
			
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		
		// echo ("{CALL fun_grabar_configuracion_de_descuentos($Opcion, $Empleado, $Centro, $puesto,$seccion, $escolaridad, $parentesco, $porcentaje, '$comentario', $Numusuario)}");
		// exit();
		
		$cmd->setCommandText("{CALL fun_grabar_configuracion_de_descuentos($Opcion,$Empleado, $Centro,$puesto,$seccion, $escolaridad, $parentesco, $porcentaje, '$comentario', $Numusuario)}");
		
							
		$ds = $cmd->executeDataSet();
		$estado = $ds[0]['estado'];
		$mensaje = $ds[0]['msj'];
		$con->close();
	}
	catch(exception $ex)
	{
	    $mensaje = "Ocurrió un error al intentar conectarse a la base de datos";
		$estado = -1;
	}
	
	try {
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo (json_encode($json));	
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>