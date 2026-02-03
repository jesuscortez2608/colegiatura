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
		$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_fun_obtener_claves_uso_especial.txt");</script>');
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
			$cmd->setCommandText("{CALL fun_obtener_claves_uso_especiales()}");
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			foreach ($ds as $fila) {
				$json->rows[$i]['cell']=array(
					trim($fila['icolaborador']).' - '.trim($fila['ncolaborador']),
					trim($fila['picentro']).' - '.trim($fila['ncentro']),
					trim($fila['pipuesto']).' - '.trim($fila['npuesto']),
					encodetoutf8(trim($fila['clave_uso'])),
					($fila['pindefinido']) ? '<font color="#00A400" size="4"><b>&#8730;</b></font>' : '',
					trim($fila['pbloqueado']),
					!($fila['pindefinido']) ? trim($fila['fecha_ini']) : '',
					!($fila['pindefinido']) ? trim($fila['fecha_fin']) : '',
					trim($fila['picolab_registro']).' - '.trim($fila['ncolab_registro']),
					trim($fila['fecha_registro']),
					);
				$i++;
			}
		}catch(exception $ex)
	    {
	        $mensaje = "Ocurrió un error al intentar conectarse a la base de datos";
	        $estado=-2;
			$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaem_json_fun_obtener_claves_uso_especialpleadoabc.txt");</script>');
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