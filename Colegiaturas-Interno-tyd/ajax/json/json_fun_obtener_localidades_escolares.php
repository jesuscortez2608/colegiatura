<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------
	$iEstado = isset($_POST['iEstado']) ? $_POST['iEstado'] : 0;
	$iMunicipio = isset($_POST['iMunicipio']) ? $_POST['iMunicipio'] : 0;
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
         $json = new stdClass();
	
    if($estado != 0)
     {
         $json->estado = $estado;
                $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_localidades_escuelas.txt";
                // error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_localidades_escuelas.txt");
                // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_localidades_escuelas.txt");
    } else {
		try
	    {
	        $con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
	    
	        $cmd->setCommandText("{CALL fun_obtener_localidades_escuelas($iEstado, $iMunicipio)}");
			// print_r("{CALL fun_obtener_localidades_escuelas($iEstado, $iMunicipio)}");
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
	        	$json->datos[$ii]->numero = $fila['idu_localidad'];
	        	$json->datos[$ii]->nombre = trim($fila['nom_localidad']);
				//$json->datos[$ii]->nombre = trim(mb_convert_encoding($fila['nom_localidad'], 'UTF-8', 'ISO-8859-1'));
	            $ii++; 
	        }
			
	    }
	    catch(exception $ex)
            {
                $json->mensaje = "Ocurrió un error al intentar conectar con la base de datos json_fun_obtener_localidades_escolares";
                $json->estado=-2;
                        // error_log(date("g:i:s a")." -> Error al consumir fun_obtener_localidades_escuelas \n",3,"log".date('d-m-Y')."_json_fun_obtener_municipios_escuelas.txt");
                        // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_localidades_escuelas.txt");
            }
    }

	try {
    echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
		
	
 ?>