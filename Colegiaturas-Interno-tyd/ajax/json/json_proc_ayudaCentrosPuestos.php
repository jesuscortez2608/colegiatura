<?php
 session_start();
 header ('Content-type: text/html; charset=utf-8');
 
  	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
    $respuesta = new stdClass();
	$iOpcion = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 0;
	$Nombre = strtoupper(isset($_GET['Nombre']) ? $_GET['Nombre'] : '');
 	$json = new stdClass();
	//$respuesta = new stdClass();
 	
    if($estado != 0)
    {
    	//$json->estado = $estado;
		//$json->mensaje = date("g:i:s a")." -> Error al conectar BDSYSCOPPELPERSONALSQL ver -> log".date('d-m-Y')."_json_llenarComboPuestos.txt";
		error_log(date("g:i:s a")." -> Error al conectar BDSYSCOPPELPERSONALSQL \n",3,"log".date('d-m-Y')."_json_llenarComboPuestos.txt");
		error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_llenarComboPuestos.txt");
    }
    //-------------------------------------------------------------------------
	else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();		
			
	        $cmd->setCommandText("{CALL proc_ayudaCentrosPuestos $iOpcion, '$Nombre'}");
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			foreach ($ds as $fila) 
	        {
			
				$respuesta->rows[$i]['id']=$i;
				$respuesta->rows[$i]['cell']=array(
					$fila['numero'],
					trim($fila['nombre']));
				$i++;
	        }			
			
	    }
	    catch(exception $ex)
	    {
	        //$json->mensaje = $ex->getMessage();
	        //$json->estado=-2;
			error_log(date("g:i:s a")." -> Error al consumir proc_ayudaCentrosPuestos \n",3,"log".date('d-m-Y')."_json_llenarComboPuestos.txt");
			error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_llenarComboPuestos.txt");
	    }
	}
	
	 try {
		echo json_encode($respuesta);
	 } catch (\Throwable $th) {
		 echo 'Error en la codificación JSON: ';
	 }
 ?>