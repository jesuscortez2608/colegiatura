<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';// $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
	$mensaje = $CDB['mensaje'];
	
	$iMovimiento = isset($_POST['iMovto']) ? $_POST['iMovto'] : 0;
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']: 0;
	
	if ($iUsuario == 0 || $iUsuario == null || $iUsuario == '') {
		generaResultado(-2,'Se finalizo la sesion para el usuario, favor de ingresar nuevamente');
	}

	if ($estado != 0) {
		generaResultado($estado, $mensaje);
	}
	try {
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$query = "SELECT iestado, smensaje FROM fun_ins_bit_proceso_colegiaturas($iMovimiento::INTEGER, $iUsuario::INTEGER)";
		$cmd->setCommandText($query);
		
		$ds = $cmd->executeDataSet();
		$con->close();
		
		$estado = $ds[0]['iestado'];
		$mensaje = encodeToUtf8($ds[0]['smensaje']);
	} catch (Exception $ex) {
		$estado = -3;
		$mensaje = '';
		$mensaje = 'Ocurrio un error al ingresar el movto a bitacora';
		$mensaje = encodeToUtf8($mensaje);
	}
	generaResultado($estado, $mensaje);
	
	function generaResultado($estado, $mensaje) {	

		try {
			$json = new stdClass();
			
			$json->estado = $estado;
			$json->mensaje = $mensaje;
			echo json_encode($json);
			
			die();
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}	
	}
?>