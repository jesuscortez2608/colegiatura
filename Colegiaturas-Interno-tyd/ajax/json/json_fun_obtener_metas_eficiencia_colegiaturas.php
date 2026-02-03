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
         $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obener_metas_eficiencia_colegiaturas.txt";
    } else {
			
            try
            {
				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
                $cmd = $con->createCommand();
			
			
                $cmd->setCommandText("{CALL FUN_OBTENER_METAS_EFICIENCIA_COLEGIATURAS()}");
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
						$fila['numemp_reg'],
						$fila['fec_captura'],
						$fila['imeta'],
						$fila['ieficiencia'],
						$fila['ianio'],
						$fila['imes']);
                    $i++;
                }

            }
            catch(exception $ex)
            {
                $json->mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
                $json->estado=-2;
            }
    }

    try {
        echo json_encode($respuesta);
    } catch (\Throwable $th) {
        echo 'Error en la codificación JSON: ';
    }

?>