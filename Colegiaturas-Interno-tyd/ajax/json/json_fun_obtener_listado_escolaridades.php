<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$iEscolaridad = isset($_POST['iEscolaridad']) ? $_POST['iEscolaridad'] : 0;
   
	$estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
         $json = new stdClass();
	
    if($estado != 0)
    {
         $json->estado = $estado;
         $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_escolaridades.txt";
    } else {
			
            try
            {
				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
                $cmd = $con->createCommand();
			
			
                $cmd->setCommandText("{CALL fun_obtener_listado_escolaridades($iEscolaridad)}");
                $ds = $cmd->executeDataSet();
                $con->close();
                $i=0;
                $json->estado = 0;
                $json->mensaje = "OK";
                $json->datos = array();
                $i = 0;
                foreach ($ds as $fila)
                {
					$respuesta->rows[$i]['cell']=array(
						$fila['idu_escolaridad'],
						encodeToUtf8($fila['nom_escolaridad']),
						$fila['fec_captura'],
						$fila['idu_empleado_registro'],
						$fila['idu_empleado_registro']. ' - '.$fila['nom_empleado_registro']);
                    $i++;
                }

                // print_r($respuesta);
                // exit();

            }
            catch(exception $ex)
            {
                $json->mensaje = $ex->getMessage();
                $json->estado=-2;
            }
    }

    try {
        echo json_encode($respuesta);
    } catch (\Throwable $th) {
        echo 'Error en la codificación JSON: ';
    }

?>