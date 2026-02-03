<?php
// echo("2");
// exit();
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
	$iEmpleado		= isset($_POST['iEmpleado'])?	$_POST['iEmpleado'] : 0;
	$dFecIni		= isset($_POST['dFecIni'])	?	$_POST['dFecIni'] : '19000101';
	$dFecFin		= isset($_POST['dFecFin'])	?	$_POST['dFecFin'] : '19000101';
	$idIndefinido	= isset($_POST['idIndefinido']) ? $_POST['idIndefinido'] : 0;
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
			
			// echo("{ CALL fun_grabar_usuario_para_externos ($iEmpleado, $iBloqueado::SMALLINT, $idIndefinido::SMALLINT, '$dFecIni', '$dFecFin', $iUsuario)}");
			// exit();
			
			$cmd->setCommandText("{ CALL fun_grabar_usuario_para_externos ($iEmpleado, $iBloqueado::SMALLINT, $idIndefinido::SMALLINT, '$dFecIni', '$dFecFin', $iUsuario)}");
			$ds = $cmd->executeDataSet();	
			// var_dump($ds);
			// exit();
			$estado = $ds[0][0]; 
			$mensaje = $ds[0][1];
			$con->close();
			// print_r($mensaje);
			// exit();			
	}
	catch(exception $ex){
		$mensaje="Ocurrió un error al intentar conectar con la base de datos.";
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