<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');

    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------
	$iEscuela	=	isset($_POST['iEscuela']) ? $_POST['iEscuela'] : 0;

	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);

    $estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
         $json = new stdClass();

    if($estado != 0)
     {
         $json->estado = $estado;
                $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_escolaridades_combo.txt";
                // error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_listado_escolaridades_combo.txt");
                // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_listado_escolaridades_combo.txt");
    } else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();

			if ($iEscuela > 0) {
				// echo("{CALL fun_obtener_listado_escolaridades_escuela($iEscuela)}");
				// exit();
				$cmd->setCommandText("{CALL fun_obtener_listado_escolaridades_escuela($iEscuela)}");
			} else {
				// echo("{CALL fun_obtener_listado_escolaridades(0)}");
				// exit();
				$cmd->setCommandText("{CALL fun_obtener_listado_escolaridades(0)}");
			}
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
	        	// $json->datos[$ii]->idu_escolaridad = (isset($fila['idu_escolaridad']))?$fila['idu_escolaridad']:'';
	        	// $json->datos[$ii]->nom_escolaridad = trim(mb_convert_encodeToUtf8($fila['nom_escolaridad'], 'UTF-8', 'ISO-8859-1'));
				// $json->datos[$ii]->opc_carrera = trim(mb_convert_encoding($fila['opc_carrera'],'UTF-8', 'ISO-8859-1'));
	        	$json->datos[$ii]->idu_escolaridad = $fila['idu_escolaridad'];
	        	$json->datos[$ii]->nom_escolaridad = $fila['nom_escolaridad'];
				$json->datos[$ii]->opc_carrera = $fila['opc_carrera'];
	            $ii++;
	        }
	    }
	    catch(exception $ex)
            {
                $json->mensaje = "Error al cargar datos de listados de escolaridades"; //$ex->getMessage();
                $json->estado=-2;
                        // error_log(date("g:i:s a")." -> Error al consumir fun_obtener_listado_escolaridades \n",3,"log".date('d-m-Y')."_json_fun_obtener_listado_escolaridades_combo.txt");
                        // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_listado_escolaridades_combo.txt");
            }
    }
	try{
    echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "Error al cargar datos en Json"; //$ex->getMessage();
		$estado = -1;
	}
 ?>