<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
	
	//Obtener y codificar parametros//
	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
	
    $cNombre = isset($_POST['cNombre']) ? $_POST['cNombre'] : '';
	$cNombre = encodeToIso($cNombre);
	
	$cApePaterno = isset($_POST['cApePaterno']) ? $_POST['cApePaterno'] : '';
	$cApePaterno = encodeToIso($cApePaterno);
	
	$cApeMaterno = isset($_POST['cApeMaterno']) ? $_POST['cApeMaterno'] : '';
	$cApeMaterno = encodeToIso($cApeMaterno);
	
    $iParentesco = isset($_POST['iParentesco']) ? $_POST['iParentesco'] : 0;
	$iEspecial = isset($_POST['iEspecial']) ? $_POST['iEspecial'] : 0;
	
	$cDescripcion = isset($_POST['cDescripcion']) ? $_POST['cDescripcion'] : '';
	$cDescripcion = encodeToIso($cDescripcion);
	
	$iBeneficiario = isset($_POST['iBeneficiario']) ? $_POST['iBeneficiario'] : 0;
	
	$iCapturo = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	
	$json = new stdClass();
	$datos = array();
	if($estado != 0)
	{
		
		try {
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$query = "SELECT fun_grabar_beneficiario_por_empleado($iEmpleado, '$cNombre', '$cApePaterno', '$cApeMaterno', $iParentesco,  $iCapturo, $iEspecial, '$cDescripcion', $iBeneficiario)";
		
		$cmd->setCommandText($query);
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$json->estado = 0;
		$mensaje=$ds[0][0];
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectar a la base de datos json_fun_grabar_beneficiario_por_empleado.";
		$estado=-2;
	}
		
	try {
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>