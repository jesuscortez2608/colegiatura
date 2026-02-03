<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	 
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once '../../../utilidadesweb/librerias/encode/encoding.php';
    //-------------------------------------------------------------------------
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
    $respuesta = new stdClass();
	$json = new stdClass();	
		
	if($estado != 0){
		$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
        exit;
    }else{
		try{
			$con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
	    	
			// echo("{CALL fun_obtener_claves_uso_permitidas()}");
			// exit();
			$cmd->setCommandText("{CALL fun_obtener_claves_uso_permitidas()}");
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			foreach ($ds as $fila) {
				$json->rows[$i]['cell']=array(
					trim($fila['keyx']),
					encodetoutf8(trim($fila['clv_uso'])),
					encodetoutf8(trim($fila['des_uso'])),
					trim($fila['fec_registro']),
					trim($fila['idu_empleado']).' - '.trim($fila['nombreempleado']).'  '.trim($fila['apellidopaterno']).'  '.trim($fila['apellidomaterno'])
					);
				$i++;
			}
		}catch(exception $ex)
	    {
	        $mensaje = "Ocurrió un error al intentar conectarse a la base de datos";
	        $estado=-2;
			$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
			// error_log(date("g:i:s a")." -> Error al consumir proc_obtenercursosstps \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
	    }
	}
	// print_r($json);
	// exit();
		
		try {
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
?>