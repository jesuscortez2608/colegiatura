<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_POST['session_name'];
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once "../proc/proc_interaccionalfresco.php";
		require_once '../../../utilidadesweb/librerias/encode/encoding.php';
		
		// $iKeyx 		=	isset($_POST['sel_keyx']) ? $_POST['sel_keyx'] : 0;
	$iBeneficiario 	= isset($_POST['iBeneficiario']) ? $_POST['iBeneficiario'] : 0;
	$iEmpleado		= isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
	$sNomEmpleado	=  encodeToIso($_POST['sNomEmpleado']) ?  encodeToIso($_POST['sNomEmpleado']) : '';
	$iDescuento		= isset($_POST['iDescuento']) ? $_POST['iDescuento'] : 0;
	$iBloqueado		= isset($_POST['iBloqueado']) ? $_POST['iBloqueado'] : 0;
	$iUsuario		=(isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : 0;

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
			
			// echo("{ CALL fun_grabar_beneficiario_externo ($iBeneficiario, $iEmpleado, '$sNomEmpleado', $iDescuento, $iBloqueado, $iUsuario)}");
			// exit();
			
			$cmd->setCommandText("{ CALL fun_grabar_beneficiario_externo ($iBeneficiario, $iEmpleado, '$sNomEmpleado', $iDescuento, $iBloqueado, $iUsuario)}");
			$ds = $cmd->executeDataSet();	
			
			// var_dump($ds);
			// exit();
			$estado =$ds[0][0]; 
			//$mensaje=utf8_encode($ds[0][1]);
			$mensaje = mb_convert_encoding($ds[0][1],  'UTF-8', 'ISO-8859-1');
			$con->close();
			// print_r($mensaje);
			// exit();			
	}
	catch(exception $ex){
		$mensaje="Error al consultar fun_grabar_beneficiario_externo";
		//$mensaje = $ex->getMessage();
		$estado=-2;
	}
	try{
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo json_encode($json);
		}
		catch(JsonException $ex)
		{
			$mensaje="Error al capturar Json";
			//$mensaje = $ex->getMessage();
			$estado=-2;
		}
?>