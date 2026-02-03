<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iconfig= isset($_POST['iconfig']) ? $_POST['iconfig'] : 0;  //=0 Guarda,!=0  Actualiza
	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
    $iBeneficiario = isset($_POST['iBeneficiario']) ? $_POST['iBeneficiario'] : 0;
	$iEscuela = isset($_POST['iEscuela']) ? $_POST['iEscuela'] : 0;
	$iEscolaridad = isset($_POST['iEscolaridad']) ? $_POST['iEscolaridad'] : 0;
    $iGrado = isset($_POST['iGrado']) ? $_POST['iGrado'] : 0;
	$iCicloEscolar= isset($_POST['iCicloEscolar']) ? $_POST['iCicloEscolar'] : 0;
	$iTipoBeneficiario= isset($_POST['iTipoBeneficiario']) ? $_POST['iTipoBeneficiario'] : 0;
	$iCarrera = isset($_POST['iCarrera']) ? $_POST['iCarrera'] : 0;
	
	
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
		//  print_r("SELECT fun_grabar_beneficiario_escuela_escolaridad($iconfig,$iEmpleado, $iBeneficiario, $iEscuela,$iEscolaridad, $iCicloEscolar, $iGrado, $iTipoBeneficiario,$iCapturo,$iCarrera)");
		//  exit;
		$cmd->setCommandText("SELECT fun_grabar_beneficiario_escuela_escolaridad($iconfig,$iEmpleado, $iBeneficiario, $iEscuela,$iEscolaridad, $iCicloEscolar, $iGrado, $iTipoBeneficiario,$iCapturo,$iCarrera)");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$json->estado = 0;
		$mensaje=$ds[0][0];
		//$json->mensaje = $ds[0][1];
		
		//$mensaje="OK";
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectar a la base de datos json_fun_grabar_beneficiario_escuela_escolaridad.";
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