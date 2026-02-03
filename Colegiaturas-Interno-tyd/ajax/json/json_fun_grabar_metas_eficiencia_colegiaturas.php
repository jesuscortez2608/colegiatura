<?php	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php'; 
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	//require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	//-------------------------------------------------------------------------
	$json = new stdClass();
	
	$iEmpleado= isset($_POST['num_empleado']) ? $_POST['num_empleado'] : 0;
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado']) ? $_SESSION[$Session]['USUARIO']['num_empleado'] : '';
	//$fecha_captura= isset($_POST['fecha_captura']) ? $_POST['fecha_captura'] : 0;
	$meta= isset($_POST['meta']) ? $_POST['meta'] : 0;
	$eficiencia= isset($_POST['eficiencia']) ? $_POST['eficiencia'] : 0;
	$anio= isset($_POST['anio']) ? $_POST['anio'] : 0;	
	$mes= isset($_POST['mes']) ? $_POST['mes'] : 0;
	
	if($eficiencia == ""){
		$eficiencia = 0;
	}
	
	// var_dump($eficiencia);
	// exit();
	
	
	$resultado=0;
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
		$cmd->setCommandText("{CALL FUN_GRABAR_METAS_EFICIENCIA_COLEGIATURAS($iUsuario, '19000101',$meta, $eficiencia, $anio, $mes)}");
		// echo ("{CALL FUN_GRABAR_METAS_EFICIENCIA_COLEGIATURAS($iUsuario, '19000101', $meta, $eficiencia, $anio, $mes)}");
		// exit();							
		$ds = $cmd->executeDataSet();
		//var_dump($ds);
		$resultado = $ds[0]['fun_grabar_metas_eficiencia_colegiaturas'];
		$mensaje = $ds[0]['msj'];
		$con->close();
	}
	catch(exception $ex)
	{
	    $mensaje = "Ocurrió un error al intentar conectarse a la base de datos";
		$resultado = -1;
	}
	
	try {
		$json->resultado = $resultado;
		$json->mensaje = $mensaje;
		echo (json_encode($json));	
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>