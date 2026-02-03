<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
         $json = new stdClass();
	
    if($estado != 0)
     {
         $json->estado = $estado;
                $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_estados_escuelas.txt";
                // error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_estados_escuelas.txt");
                // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_estados_escuelas.txt");
    } else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
	    
	        $cmd->setCommandText("{CALL fun_obtener_estados_escuelas()}");
			// print_r("fun_obtener_estados_escuelas()");
			// exit();
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			$ii = 0;
			foreach ($ds as $fila) 
	        {
	        	$json->datos[$ii] = new stdClass();
	        	$json->datos[$ii]->numero = $fila['idu_estado'];
	        	//$json->datos[$ii]->nombre = trim(mb_convert_encoding($fila['nom_estado'], 'UTF-8', 'ISO-8859-1'));
				$json->datos[$ii]->nombre = $fila['nom_estado'];
	            $ii++; 
	        }
			
	    }
	    catch(exception $ex)
            {
                $json->mensaje = "Error al obtener estados de escuelas"; //$ex->getMessage();
                $json->estado=-2;
                        error_log(date("g:i:s a")." -> Error al consumir fun_obtener_estados_escuelas \n",3,"log".date('d-m-Y')."_json_fun_obtener_estados_escuelas.txt");
                        error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_estados_escuelas.txt");
            }
    }
	try{
    echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "no se pudo realizar conexión en línea 60";
		$estado=-2;
	}
 ?>