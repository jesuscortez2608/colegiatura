<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];	
	
	//inc = iNotaCredito
	$inc= isset($_POST['iNotaCredito']) ? $_POST['iNotaCredito'] : 0;  //=0 Guarda,!=0  Actualiza
	$iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;
    $iImporteNota= isset($_POST['iImporteNota']) ? $_POST['iImporteNota'] : 0;
	$iImporteFactura = isset($_POST['iImporteFactura']) ? $_POST['iImporteFactura'] : 0;
	$iPrcDescuento= isset($_POST['iPrcDescuento']) ? $_POST['iPrcDescuento'] : 0;
	$iImporteCalculado = isset($_POST['iImporteCalculado']) ? $_POST['iImporteCalculado'] : 0;
	$iImporteAplicado = isset($_POST['iImporteAplicado']) ? $_POST['iImporteAplicado'] : 0;
	$iImportePagado = isset($_POST['iImportePagado']) ? $_POST['iImportePagado'] : 0;	
    	
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		//echo json_encode($json);
		mb_convert_encoding($json, 'UTF-8', 'ISO-8859-1');
		exit;
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// print_r("SELECT * FROM FUN_GRABAR_APLICAR_NOTA_CREDITO($iNotaCredito,$iFactura,$iImporteNota,$iImporteFactura,$iPrcDescuento,$iImporteCalculado,$iImporteAplicado,$iImportePagado)");
		// exit;
		$cmd->setCommandText("SELECT * FROM FUN_GRABAR_APLICAR_NOTA_CREDITO($inc,$iFactura,$iImporteNota,$iImporteFactura,$iPrcDescuento,$iImporteCalculado,$iImporteAplicado,$iImportePagado)");
	    $ds = $cmd->executeDataSet();
		$con->close();		
		$estado = $ds[0][0];
		//$mensaje=utf8_encode($ds[0][1]);
		$mensaje=mb_convert_encoding($ds[0][1], 'UTF-8', 'ISO-8859-1');
		
		
		//$mensaje="OK";
	}
	catch(exception $ex)
	{
		$mensaje="";
		//$mensaje = $ex->getMessage();
		$mensaje = "Error a Conectar a Base de Datos";
		$estado=-2;
	}
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	try{
	echo json_encode($json);
	}
	catch(JsonException $ex){
	$mensaje="";
	
	}
?>