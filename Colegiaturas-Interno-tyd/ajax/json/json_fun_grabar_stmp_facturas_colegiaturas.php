<?php
	// ini_set('display_errors', 1);
	// ini_set('display_startup_errors', 1);
	// error_reporting(E_ALL);
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
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	
	$cFolioFiscal = isset($_POST['cFolioFiscal']) ? $_POST['cFolioFiscal'] : '';
	$cFolioFac = isset($_POST['cFolioFac']) ? $_POST['cFolioFac'] : '';
	$cSerie = isset($_POST['cSerie']) ? $_POST['cSerie'] : '';
	$iPdf = isset($_POST['iPdf']) ? $_POST['iPdf'] : 0;
	$iEscuela = isset($_POST['iEscuela']) ? $_POST['iEscuela'] : 0;
	$cRfc = isset($_POST['cRfc']) ? $_POST['cRfc'] : '';
	$importe = isset($_POST['importe']) ? $_POST['importe'] : 0;
	$cXml = isset($_POST['cXml']) ? $_POST['cXml'] : '';
	$fecha = isset($_POST['fecha']) ? $_POST['fecha'] : '19000101';
	
	$iFacturasEspeciales = isset($_POST['iFacturasEspeciales']) ? $_POST['iFacturasEspeciales'] : 0;
	$Revision = isset($_POST['Revision']) ? $_POST['Revision'] : 0;
	$t_comprobante = isset($_POST['tComprobante']) ? $_POST['tComprobante'] : '';
	$m_pago = isset($_POST['m_pago']) ? $_POST['m_pago'] : '';
	$folioRelacionado = isset($_POST['folRelacion']) ? $_POST['folRelacion'] : '';
	
	if ($iFacturasEspeciales == 1){
		$iUsuario = isset($_POST['iUsuario']) ? $_POST['iUsuario'] : 0;
	} else {
		$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	}
	$json = new stdClass(); 
	$datos = array();	
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
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// print_r("SELECT resultado, factura, mensaje from  fun_grabar_stmp_facturas_colegiaturas($iOpcion::INTEGER,'$cFolioFiscal'::VARCHAR,'$cFolioFac'::VARCHAR,'$cSerie'::VARCHAR, $iUsuario::INTEGER,$iPdf::INTEGER, $iEscuela::INTEGER, '$cRfc'::VARCHAR,$importe::numeric, '$myXML'::TEXT,  '$fecha'::DATE,$Revision::SMALLINT, '$t_comprobante'::VARCHAR, '$m_pago'::VARCHAR,'$folioRelacionado'::VARCHAR)");
		//  exit();	
		//$cmd->setCommandText("SELECT resultado, factura, mensaje from  fun_grabar_stmp_facturas_colegiaturas($iOpcion,'$cFolioFiscal','$cFolioFac','$cSerie', $iUsuario, $iPdf, $iEscuela, '$cRfc',$importe, '$cXml', '$fecha')");
		$cmd->setCommandText("SELECT resultado, factura, mensaje from  fun_grabar_stmp_facturas_colegiaturas($iOpcion::INTEGER,'$cFolioFiscal'::VARCHAR,'$cFolioFac'::VARCHAR,'$cSerie'::VARCHAR, $iUsuario::INTEGER,$iPdf::INTEGER, $iEscuela::INTEGER, '$cRfc'::VARCHAR,$importe::numeric, '$myXML'::TEXT,  '$fecha'::DATE,$Revision::SMALLINT, '$t_comprobante'::VARCHAR, '$m_pago'::VARCHAR,'$folioRelacionado'::VARCHAR)");
	
		$ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = $ds[0]["resultado"];
		$mensaje=$ds[0]["mensaje"];
		$ifactura=$ds[0]["factura"];
	}
	catch(exception $ex)
	{
		//$mensaje= $ex -> getMessage();
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
	}
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	$json->factura =$ifactura;
	
		
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>