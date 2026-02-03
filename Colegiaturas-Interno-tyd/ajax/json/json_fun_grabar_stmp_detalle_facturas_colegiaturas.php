<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; 

	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	
	$iFacturasEspeciales = isset($_POST['iFacturasEspeciales']) ? $_POST['iFacturasEspeciales'] : 0;
	$cFolioFiscal = isset($_POST['cFolioFiscal']) ? $_POST['cFolioFiscal'] : '';
    $iBeneficiario = isset($_POST['iBeneficiario']) ? $_POST['iBeneficiario'] : 0;
	$iParentesco = isset($_POST['iParentesco']) ? $_POST['iParentesco'] : 0;
	$iTipoPago = isset($_POST['iTipoPago']) ? $_POST['iTipoPago'] : 0;
    $cPeriodo = isset($_POST['cPeriodo']) ? $_POST['cPeriodo'] : '';
	$iEscuela = isset($_POST['iEscuela']) ? $_POST['iEscuela'] : 0;
	$iEscolaridad = isset($_POST['iEscolaridad']) ? $_POST['iEscolaridad'] : 0;
	$iGrado = isset($_POST['iGrado']) ? $_POST['iGrado'] : 0;
    $iCiclo = isset($_POST['iCiclo']) ? $_POST['iCiclo'] : 0;
	$iImporte = isset($_POST['iImporte']) ? $_POST['iImporte'] : 0;
	$iFactura= isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;
	$iKeyx= isset($_POST['iKeyx']) ? $_POST['iKeyx'] : 0;
	$iConfDesc= isset($_POST['iConfDesc']) ? $_POST['iConfDesc'] : 0;
	$iCarrera= isset($_POST['iCarrera']) ? $_POST['iCarrera'] : 0;
	
	if($iFacturasEspeciales == 1){
		$nEmpleado = isset($_POST['iUsuario']) ? $_POST['iUsuario'] : 0;
	} else {
		$nEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	}
	
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
		catch(JsonException $ex){
			$mensaje = "no se pudo realizar conexión en línea 93";
			$estado=-2;
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// print_r("SELECT * FROM fun_grabar_stmp_detalle_facturas_colegiaturas($iKeyx, $nEmpleado, '$cFolioFiscal', $iBeneficiario, $iParentesco, $iTipoPago, '$cPeriodo', $iEscuela, $iEscolaridad, $iGrado, $iCiclo, $iImporte,$iFactura,$iConfDesc, $iCarrera)");
		// exit;
		$cmd->setCommandText("SELECT * FROM fun_grabar_stmp_detalle_facturas_colegiaturas($iKeyx, $nEmpleado, '$cFolioFiscal', $iBeneficiario, $iParentesco, $iTipoPago, '$cPeriodo', $iEscuela, $iEscolaridad, $iGrado, $iCiclo, $iImporte,$iFactura,$iConfDesc, $iCarrera)");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = $ds[0][0];//0
		
		// $mensaje = encodeToIso($ds[0][1]);
	}
	catch(exception $ex)
	{
		$mensaje="";
		$mensaje = "Ocurrió un error al conectar a la base de datos.";
		$estado=-2;
	}
	try{
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "no se pudo realizar conexión en línea 93";
		$estado=-2;
	}
?>