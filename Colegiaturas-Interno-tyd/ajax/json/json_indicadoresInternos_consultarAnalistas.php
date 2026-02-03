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
    $json = new stdClass();
	
    if($estado != 0)
     {
        $json->estado = $estado;
        $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_indicadoresInternos_ConsultarEstatus.txt";
    } else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
			// echo ("{CALL fun_obtener_analistas_indicadores_internos()}");		
			// exit();
	        $cmd->setCommandText("{CALL fun_obtener_analistas_indicadores_internos(2)}");
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			foreach ($ds as $fila) 
	        {
	        	$json->datos[$i] = new stdClass();
	        	$json->datos[$i]->idu_data = $fila['num_dato'];
	        	$json->datos[$i]->nom_data = trim($fila['nom_dato']);
	            $i++; 
	        }
	    }
	    catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
		}
    }
	
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
 ?>