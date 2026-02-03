<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	//-------------------------------------------------------------------------
	//RECOJO LA CADENA DE CONEXION   utilidadesweb/librerias/cnfg/conexiones.php
	$CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
	$estado = $CDB['estado'];	
	$cadenaconexion_personal_sql = $CDB['conexion'];
	$mensaje = $CDB['mensaje'];	
	$term =(isset($_POST['term']) ? $_POST['term'] : '');
	if($estado != 0)
	{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		
		try {
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}

		exit;
	}
	//-------------------------------------------------------------------------

	//declaro el arreglo a regresar en el JSon 
	$respuesta = new stdClass();
	
	$estado = 0;
	$ds=""; //guardo los datos en la consulta del procedimiento
	//$fechaacomparar = $_POST['fechaacomparar'];  
	
	$iPuesto = isset($_POST['iPuesto']) ? $_POST['iPuesto'] : 0;
	
	   		
	$con = new OdbcConnection($cadenaconexion_personal_sql);
	$con->open();
	$cmd = $con->createCommand();
	
	try
	{
		$cmd->setCommandText("{CALL calConsultaNombrePuesto ($iPuesto)}");
	    $ds = $cmd->executeDataSet();
		$mensaje="Ok_consulta_general";
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectarse a la base de datos";
		$estado=-2;
	}
		
	try {
		echo json_encode($ds[0]);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>