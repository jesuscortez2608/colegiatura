<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_POST['session_name'];
	
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	
	// $iCarrera = isset($_POST['iCarrera']) ? $_POST['iCarrera']: '0';
	// $sCarrera = encodeToIso($_POST['sCarrera']) ? encodeToIso($_POST['sCarrera']) : '';
	// $iOpt = isset($_POST['iOpt']) ? $_POST['iOpt'] : 0;
	$cRFCescuela = encodeToIso($_POST['cRFCescuela']) ? encodeToIso($_POST['cRFCescuela']) : '';
	$iestado = encodeToIso($_POST['iestado']) ? encodeToIso($_POST['iestado']) : 0;
	$imunicipio = encodeToIso($_POST['imunicipio']) ? encodeToIso($_POST['imunicipio']) : 0;
	$ilocalidad = encodeToIso($_POST['ilocalidad']) ? encodeToIso($_POST['ilocalidad']) : 0;
	$iescolaridad = encodeToIso($_POST['iescolaridad']) ? encodeToIso($_POST['iescolaridad']) : 0;
	//$icarrera = encodeToIso($_POST['icarrera']) ? encodeToIso($_POST['icarrera']) : '';				
	$snombre = encodeToIso($_POST['snombre']) ? encodeToIso($_POST['snombre']) : '';
	$iescuela = encodeToIso($_POST['iescuela']) ? encodeToIso($_POST['iescuela']) : 0;
	$iUsuario		=(isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : 0;
	
	$snombre=strtoupper($snombre);
	$json = new stdClass();
	
	try{
		$CDB            = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado         = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje        = $CDB['mensaje'];
		
		if($estado != 0){
			throw new Exception($mensaje);
		}
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		// echo("{CALL fun_grabar_escolaridad_nueva_escuela('$cRFCescuela'::VARCHAR,$iestado::INTEGER,$imunicipio::INTEGER,$ilocalidad::INTEGER,$iescolaridad::INTEGER,$iUsuario::INTEGER, '$snombre'::VARCHAR,$iescuela::INTEGER)}");
		// exit();
		
		//$cmd->setCommandText("{CALL fun_grabar_escolaridad_nueva_escuela('$cRFCescuela',$iestado,$imunicipio,$ilocalidad,$iescolaridad,$icarrera,$iUsuario)}");
		$cmd->setCommandText("{CALL fun_grabar_escolaridad_nueva_escuela('$cRFCescuela'::VARCHAR,$iestado::INTEGER,$imunicipio::INTEGER,$ilocalidad::INTEGER,$iescolaridad::INTEGER,$iUsuario::INTEGER, '$snombre'::VARCHAR,$iescuela::INTEGER)}");
		$ds = $cmd->executeDataSet();
		
		$estado = $ds[0][0];
		$mensaje = $ds[0][1];
		$con->close();
	}catch(exception $ex){
		$mensaje = "Ocurrió un error al intentar conectar con la base d edatos grabar_escolaridad_nueva_escuela";
		$estado = -2;
	}
		
	try {
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>