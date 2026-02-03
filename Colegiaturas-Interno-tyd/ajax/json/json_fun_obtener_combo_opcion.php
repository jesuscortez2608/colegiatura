<?php
 session_name("Session-Colegiaturas");
 session_start();
 header ('Content-type: text/html; charset=utf-8');
 $Session = $_POST['session_name'];
 
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------
		
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
    	
 	$json = new stdClass();
 	

    if($estado != 0)
    {
    	$json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_combo_opcion.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_combo_opcion.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_combo_opcion.txt");
    }
    
	else
	{
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();	    
		
	        $cmd->setCommandText("{CALL fun_obtener_listado_opciones_colegiaturas()}");
	        $ds = $cmd->executeDataSet();
			
			$con->close();
	        
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			$ii = 0;
		
			foreach ($ds as $fila) 
	        {
	        	$json->datos[$ii] = new stdClass();
	        	$json->datos[$ii]->num_opcion = (isset($fila['idu_opcion']))?$fila['idu_opcion']:'';
	        	$json->datos[$ii]->nom_opcion = (trim( strtoupper($fila['snom_opcion'])));
				$ii++; 
				
	        }			
			
	    }
	    catch(exception $ex)
	    {
	        $json->mensaje = "Error al consumir un_obtener_listado_opciones_colegiaturas";
	        $json->estado=-2;
			error_log(date("g:i:s a")." -> Error al consumir un_obtener_listado_opciones_colegiaturas \n",3,"log".date('d-m-Y')."_json_fun_obtener_combo_opcion.txt");
			error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_combo_opcion.txt");
	    }
		
		
	}	
	
	
	 try {
		echo json_encode($json);
	 } catch (\Throwable $th) {
		 echo 'Error en la codificación JSON: ';
	 }
	
 ?>