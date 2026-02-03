<?php
 session_start();
 header ('Content-type: text/html; charset=utf-8');
 
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
    $respuesta = new stdClass();
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
 	$json = new stdClass();
 	
    if($estado != 0)
    {
    	$json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDSYSCOPPELPERSONALSQL ver -> log".date('d-m-Y')."_json_proc_colsultaropcionesapagado_hcm.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDSYSCOPPELPERSONALSQL \n",3,"log".date('d-m-Y')."_json_llenarComboCentros.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_llenarComboCentros.txt");
    }
    //-------------------------------------------------------------------------
	else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
			//echo ("{CALL PROC_CONSULTAROPCIONESAPAGADO_HCM (14,".$iOpcion.")}");
			//exit();
	        $cmd->setCommandText("{CALL PROC_CONSULTAROPCIONESAPAGADO_HCM (14,".$iOpcion.")}");
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			$json->estado = 0;
			$json->mensaje = "";
			$json->clave = 0;
			
			//$json->datos = array();
			$ii = 0;
			foreach ($ds as $fila) 
	        {
	        	$json->mensaje = trim(encodeToUtf8( strtoupper($fila['des_mensaje'])));
				$json->clvApagado = (isset($fila['clv_apagado']))?$fila['clv_apagado']:'';
				
	            $ii++; 
	        }			
	    }
	    catch(exception $ex)
	    {
	        $json->mensaje = "Ocurrió un error al intentar conectarse a la base de datos";
	        $json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir PROC_OBTENERCENTROSELPOGPE \n",3,"log".date('d-m-Y')."_json_llenarComboCentros.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_llenarComboCentros.txt");
	    }
	}
	
	 try {
		echo json_encode($json);
	 } catch (\Throwable $th) {
		 echo 'Error en la codificación JSON: ';
	 }
 ?>