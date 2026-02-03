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
	$idu_escolaridad = isset($_POST['idu_escolaridad']) ? $_POST['idu_escolaridad'] : 0;
	$nom_escolaridad = $_POST['txt_escolaridad'];
	$nom_escolaridad = encodeToIso($nom_escolaridad);

	$Numusuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
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
		// print_r("{CALL fun_grabar_escolaridad ($idu_escolaridad, '$nom_escolaridad', $Numusuario)}");
		// exit;
		$cmd->setCommandText("{CALL fun_grabar_escolaridad ($idu_escolaridad, '$nom_escolaridad', $Numusuario)}");
		
							
		$ds = $cmd->executeDataSet();
		$estado = $ds[0]['estado'];
		$mensaje = $ds[0]['msj'];
		$con->close();
	}
	catch(exception $ex)
	{
	    $mensaje = $ex->getMessage();
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