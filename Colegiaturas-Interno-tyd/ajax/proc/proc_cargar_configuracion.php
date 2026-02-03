<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	// sleep(1);
	
	session_name("Session-Colegiaturas");
	session_start();
	$Session = "Colegiaturas";
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
    
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	/** Cargar el contenido del archivo 
	 *  files/values/config.json
	-------------------------------------------------- */
	$config = NULL;
	try {
		$a = 0;
		
		try {
			$config = file_get_contents ('../../files/values/config.json');
			$aconfig = json_decode($config, true); // Convierte json a arreglo
			$a_debug_users = $aconfig["debug_users"];
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		
		foreach($a_debug_users as $user) {
			if ($iUsuario == $user) {
				$aconfig["debug_mode"] = true;
			}
		}

		try {
		
			echo json_encode($aconfig);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}

		exit();
	} catch (Exception $ex) {
		$desc_mensaje = $ex->getMessage();
	}
	