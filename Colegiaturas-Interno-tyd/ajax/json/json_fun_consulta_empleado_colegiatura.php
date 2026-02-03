<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

	//-------------------------------------------------------------------------
	//RECOJO LA CADENA DE CONEXION   utilidadesweb/librerias/cnfg/conexiones.php
	
	$iUsuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
	
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];	
	$cadenaconexion_personal_sql = $CDB['conexion'];
	$mensaje = $CDB['mensaje'];	
	
	if($estado != 0)
	{
		try{
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
		}catch(JsonException $ex){
			$mensaje="";
			$mensaje = $ex->getMessage();
		}
	}
	if($iEmpleado==0)
	{
		$iEmpleado=$iUsuario;
	}

	//declaro el arreglo a regresar en el JSon 
	$respuesta = new stdClass();
	
	$estado = 0;
	$ds=""; //guardo los datos en la consulta del procedimiento
	$con = new OdbcConnection($CDB['conexion']);
	try
	{
		$con->open();
		$cmd = $con->createCommand();
		$cmd->setCommandText("{CALL fun_consulta_empleado_colegiatura ($iEmpleado)}");
	    $ds = $cmd->executeDataSet();
		$mensaje="Ok_consulta_general";
		
		$con->close();
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = $ex->getMessage();
		$estado=-2;
	}
	try{
	 echo json_encode($ds[0]);
	}catch(JsonException $ex){
		$mensaje="";
		$mensaje = $ex->getMessage();
		$estado=-2;
	}
?>