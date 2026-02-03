<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];

		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	//-------------------------------------------------------------------------
	
	$json = new stdClass();
	$sFolioFiscal = isset($_REQUEST['sFolioFiscal']) ? $_REQUEST['sFolioFiscal'] : '';
	
	try{
		$CBD		= obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado		= $CBD['estado'];
		$cadenaconexion = $CBD['conexion'];
		$mensaje	= $CBD['mensaje'];
		if($estado != 0){
			throw new Exception($mensaje);
		}
		
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		
		// echo "<pre>";
		// print_r("{CALL fun_existe_folio_fiscal_colegiaturas('$sFolioFiscal')}");
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText("{CALL fun_existe_folio_fiscal_colegiaturas('$sFolioFiscal')}");
		$ds = $cmd->executeDataSet();
		$estado = $ds[0][0];
		$mensaje = $ds[0][1];
		$estatus = $ds[0][4];
	} catch(Exception $ex){
		$mensaje = '';
		//$mensaje = $ex->getMessage();
		$mensaje = "Error al consultar el folio fiscal de Colegiaturas";
		$estado = -2;
	}
	try{
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	$json->estatus = $estatus;
	
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "error al cargar Json";
		$estado=-2;
	}
?>