<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------
	$iTipo = isset($_POST['iTipo']) ? $_POST['iTipo'] : 0;
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
         $json = new stdClass();
	
    if($estado != 0)
     {
         $json->estado = $estado;
                $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_estatus_facturas.txt";
                // error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_estatus_facturas.txt");
                // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_estatus_facturas.txt");
    } else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
			// echo ("{CALL fun_obtener_estatus_facturas($iTipo)}");		
			// exit();
	        $cmd->setCommandText("{CALL fun_obtener_estatus_facturas($iTipo)}");
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			foreach ($ds as $fila) 
	        {
	        	$json->datos[$i] = new stdClass();
	        	$json->datos[$i]->idu_estatus = $fila['estatus'];
	        	$json->datos[$i]->nom_estatus = trim($fila['nom_estatus']);
	            $i++; 
	        }
	    }
	    catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_estatus_facturas \n",3,"log".date('d-m-Y')."_json_fun_obtener_estatus_facturas.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_estatus_facturas.txt");
		}
    }
	
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
 ?>