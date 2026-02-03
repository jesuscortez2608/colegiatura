<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	$CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
	$estado = $CDB['estado'];	
	$cadenaconexion_personal_sql = $CDB['conexion'];
	$mensaje = $CDB['mensaje'];	
	
	$empleado = isset($_POST['empleado']) ? $_POST['empleado'] : 0;
	
	if($estado != 0)
	{
		try {
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit;
	}
	$respuesta = new stdClass();
	$json = new stdClass();
	$estado = 0;
	$tipo=0;
	$ds=""; //guardo los datos en la consulta del procedimiento
		
	$con = new OdbcConnection($cadenaconexion_personal_sql);
	$con->open();
	$cmd = $con->createCommand();
	
	try
	{
		
		//$cmd->setCommandText("{CALL proc_datosgerente ($empleado)}");
		$cmd->setCommandText("select * from fun_obtener_centros_acargo('$empleado', 1)");
	    $ds = $cmd->executeDataSet();
		// print_r($ds);
		// exit();
		//$tipo=$ds[0][7];
		if($ds[0][0]==-1)
		{
			$tipo=1;// es gerente
		}
		
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectar con la base de datos.";
		$estado=-2;
	}
		
	try {
		$json->estado = $estado;
		$json->tipo = $tipo;
		
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>