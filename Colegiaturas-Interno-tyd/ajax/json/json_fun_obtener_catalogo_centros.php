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
	
	$iCentro = isset($_POST['iCentro']) ? $_POST['iCentro'] : 0;
	$sCentro = encodetoIso($_GET['sCentro']) ? encodetoIso($_GET['sCentro']) : '';
	$iSeccion= isset($_POST['iSeccion'])? $_POST['iSeccion']: 0;
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
	    	
			// echo("{CALL fun_obtener_catalogo_centros($iCentro, '$sCentro', $iSeccion)}");
			// exit();
			$cmd->setCommandText("{CALL fun_obtener_catalogo_centros($iCentro, '$sCentro', $iSeccion)}");
			$ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			foreach ($ds as $fila) {
				$json->rows[$i]['cell']=array(
					$fila['idu_centro']
					,encodetoutf8(trim($fila['nom_centro']))	
					,$fila['idu_estado']
					,$fila['idu_ciudad']
					,$fila['idu_seccion']
					,$fila['idu_gerente']
					);
				$i++;
			}
		}catch(exception $ex){
	        $mensaje = $ex->getMessage();
	        $estado=-2;
			$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
			// error_log(date("g:i:s a")." -> Error al consumir proc_obtenercursosstps \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
	    }
		
		// print_r($ds);
		// exit();
		// $json->$estado[];
	}
	
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>	