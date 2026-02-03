<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$sNomParametro = isset($_POST['nom_parametro']) ? $_POST['nom_parametro'] : '';
    
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		try{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		echo json_encode($json);
		exit;
		}
		catch(JsonException){
			$json->mensaje = "error al cargar Json en linea 28"; //$ex->getMessage();
			$json->estado=-2;
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$cmd->setCommandText("SELECT * FROM fun_obtener_parametros_colegiaturas('$sNomParametro')");
		$ds = $cmd->executeDataSet();
		$con->close();
		$estado = 0;

		$idParametro=$ds[0][0];
		$sTipoParametro=$ds[0][1];
		$sValorParametro=$ds[0][2];
		if($ds[0][1] == 'INTEGER'){
			$sValorParametro=(INT)$ds[0][2];
		}
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
	}
	try{
	$json->estado = $estado;
	$json->idParametro = $idParametro;
	$json->sTipoParametro=$sTipoParametro;
	$json->sValorParametro=$sValorParametro;
	
	
	echo json_encode($json);
	}
	catch(JsonException){
		$json->mensaje = "error al cargar Json en linea 66"; //$ex->getMessage();
		$json->estado=-2;
	}
?>