<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	$Usuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	
	$json = new stdClass(); 
	$json->idu_estatus = 0;
	$json->des_estatus = '';
	//$json->movimientos_rechazados = 0;
	$json->movimientos_pagados = 0;
	$json->importe_factura = 0;
	$json->importe_pagado = 0;
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
	
	try {
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$query = "SELECT idu_estatus
			, des_estatus
			, movimientos_pagados
			, importe_factura
			, importe_pagado
		FROM fun_generar_cierre_colegiaturas($Usuario::INTEGER)";
	// echo "<pre>";
	// print_r($query);
	// echo "</pre>";
	// exit();
		$cmd->setCommandText($query);
		
	    $ds = $cmd->executeDataSet();
		
		$json->idu_estatus = $ds[0]["idu_estatus"];
		$json->des_estatus = $ds[0]["des_estatus"];
		//$json->movimientos_rechazados = $ds[0]["movimientos_rechazados"];
		$json->movimientos_pagados = $ds[0]["movimientos_pagados"];
		$json->importe_factura = $ds[0]["importe_factura"];
		$json->importe_pagado = $ds[0]["importe_pagado"];
		
		$con->close();
	} catch(exception $ex) {
		$json->idu_estatus = -2;
		$json->des_estatus = "Ocurrió un error al intentar conectar con la base de datos.";
	}
	

	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>