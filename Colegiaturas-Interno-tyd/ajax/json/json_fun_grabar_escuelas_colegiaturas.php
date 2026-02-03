<?php
	header("Content-type:text/html;charset=utf-8");	
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	
	//-------------------------------------------------------------------------
	$json = new stdClass();
	//$_POST['param'] = encodeToIso($_POST['param']);
	$opc_tipo = isset($_POST['opc_tipo']) ? $_POST['opc_tipo'] : 0;
	$iUsuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$nombre_escuela = encodeToIso($_POST['nombre_escuela']) ? encodeToIso($_POST['nombre_escuela']) : '';
	$razon_social = encodeToIso($_POST['razon_social']) ? encodeToIso($_POST['razon_social']) : '';
	$rfc_clv_sep = encodeToIso($_POST['rfc_clv_sep']) ? encodeToIso($_POST['rfc_clv_sep']) : '';
	$clave_sep = encodeToIso($_POST['clave_sep']) ? encodeToIso($_POST['clave_sep']) : '';
	$iEstado = isset($_POST['iEstado']) ? $_POST['iEstado'] : 0;
	$iMunicipio = isset($_POST['iMunicipio']) ? $_POST['iMunicipio'] : 0;	
	$iLocalidad = isset($_POST['iLocalidad']) ? $_POST['iLocalidad'] : 0;
	$nombre_contacto = encodeToIso($_POST['nombre_contacto']) ? encodeToIso($_POST['nombre_contacto']) : '';
	$email_contacto = encodeToIso($_POST['email_contacto']) ? encodeToIso($_POST['email_contacto']) : '';
	$telefono = isset($_POST['telefono']) ? $_POST['telefono'] : '';
	$iEscolaridad = isset($_POST['iEscolaridad']) ? $_POST['iEscolaridad'] : 0;
	$extension = encodeToIso($_POST['extension']) ? encodeToIso($_POST['extension']) : '';
	$area_contacto = encodeToIso($_POST['area_contacto']) ? encodeToIso($_POST['area_contacto']) : '';
	
	// Luis Hernandez 90244610
	$nombre_escuela = (strlen($nombre_escuela) > 100) ? substr($nombre_escuela, 0, 100) : $nombre_escuela;// Limitar nombre escuela a 100 caracteres
	
	$estado=0;
	$mensaje='OK';
	try {
		if (trim($iUsuario)  == "" ) {
			throw new Exception(encodeToUtf8("Sesión inválida"));		
		}		
		//$sDesObservaciones = str_replace("'", "", $sDesObservaciones);
		//$sDesObservaciones = encodeToIso($sDesObservaciones);
		
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];	
			
		if($estado != 0) {
			throw new Exception($mensaje);
		}
		
		$ds=""; //guardo los datos en la consulta del procedimiento
		
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		// echo ("{CALL fun_grabar_escuelas_colegiaturas($opc_tipo, '$nombre_escuela', '$razon_social', '$rfc_clv_sep', '$clave_sep', $iEstado, $iMunicipio, $iLocalidad, '$nombre_contacto', '$email_contacto', $iEscolaridad, '$telefono', '$extension', '$area_contacto',$iUsuario)}");
		// exit();
		$cmd->setCommandText("{CALL fun_grabar_escuelas_colegiaturas($opc_tipo, '$nombre_escuela', '$razon_social', '$rfc_clv_sep', '$clave_sep', $iEstado, $iMunicipio, $iLocalidad, '$nombre_contacto', '$email_contacto', $iEscolaridad, '$telefono', '$extension', '$area_contacto',$iUsuario)}");
		$ds=$cmd->executeDataSet();
		$con->close();

		// print_r($ds);
		// exit();
		
		$estado = $ds[0][0];
		$mensaje = $ds[0][1];
		$id_escuela = $ds[0][2];
	} catch(exception $ex) {
	    $mensaje = $ex->getMessage();
		$estado = -1;
	}
		
	try {
	
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		$json->id_escuela =$id_escuela;
		
		echo (json_encode($json));
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>