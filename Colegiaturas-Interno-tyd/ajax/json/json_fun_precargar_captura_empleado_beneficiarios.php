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
	$iEscuela = isset($_POST['iEscuela']) ? $_POST['iEscuela'] : 0;
	$iEscolaridad = isset($_POST['iEscolaridad']) ? $_POST['iEscolaridad'] : 0;
	$iGrado = isset($_POST['iGrado']) ? $_POST['iGrado'] : 0;
	$iBeneficiario=isset($_POST['iBeneficiario']) ? $_POST['iBeneficiario'] : 0;
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
		}
		catch(JsonException){
			$json->mensaje = "error al cargar Json en linea 34"; //$ex->getMessage();
			$json->estado=-2;
		}
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
		// echo "<pre>";
		// print_r("select * from  fun_precargar_captura_empleado_beneficiarios ($iUsuario, $iBeneficiario, $iEscuela, $iEscolaridad, $iGrado)");
		// echo "</pre>";
		// exit();
		$cmd->setCommandText("{CALL fun_precargar_captura_empleado_beneficiarios ($iUsuario, $iBeneficiario, $iEscuela, $iEscolaridad, $iGrado)}");
	    $ds = $cmd->executeDataSet();
		$mensaje="Ok_consulta_general";
		// print_r("fun_precargar_captura_empleado_beneficiarios ($iUsuario, $iBeneficiario, $iEscuela, $iEscolaridad, $iGrado)}");
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
	}
	catch(JsonException){
		$json->mensaje = "error al cargar Json en linea 28"; //$ex->getMessage();
		$json->estado=-2;
	}
?>