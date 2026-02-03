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
	
	/** 
	 *  Generar archivos de descripciones SAT
	-------------------------------------------------- */
	$config = NULL;
	try {
		require_once("../class/conceptos.class.php");
		$conceptos_sat = new ConceptosSAT($Session);
		$ret = $conceptos_sat->fun_actualizar_catalogos_sat();
		
		try {
			echo json_encode($ret);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	} catch (Exception $ex) {
		$desc_mensaje = $ex->getMessage();
		
		$json = new stdClass();
		$json->estado = -1;
		$json->mensaje = $desc_mensaje;
		$json->datos = array();
		
		
		try {
			echo json_encode($ret);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}
	