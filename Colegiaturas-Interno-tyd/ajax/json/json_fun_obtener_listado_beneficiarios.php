<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $iEmpleado = isset($_GET['iNumEmp']) ? $_GET['iNumEmp'] : 0;
	$inicializar = isset($_GET['inicializar']) ? $_GET['inicializar'] : 1;
	
	if ($inicializar == 1) {

        try {
			$response = new stdClass();
			echo json_encode($response);
			exit();
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }

	}
	$estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
         $json = new stdClass();
	
    if($estado != 0)
    {
         $json->estado = $estado;
         $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_beneficiarios.txt";
    } else {
			
            try
            {
				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
                $cmd = $con->createCommand();
				// print_r("{CALL fun_obtener_listado_beneficiarios( $iEmpleado)}");
				// exit();
                $cmd->setCommandText("{CALL fun_obtener_listado_beneficiarios( $iEmpleado)}");
                $ds = $cmd->executeDataSet();
                $con->close();
                $i=0;
                $json->estado = 0;
                $json->mensaje = "OK";
                $json->datos = array();
                $i = 0;
                foreach ($ds as $fila)
                {
					if ($fila['idu_especial']==1)
					{
						$respuesta->rows[$i]['cell']=array(
						$iEmpleado,
						$fila['idu_beneficiario'],
						$fila['nom_nombre'],
						$fila['ape_paterno'],
						$fila['ape_materno'],
						$fila['nom_nombre'].' '.$fila['ape_paterno'].' '.$fila['ape_materno'],
						$fila['idu_parentesco'],
						$fila['des_parentesco'],
						$fila['des_observacion'],
						$fila['des_estudios'],
						$fila['idu_especial'],
						'<font color="#00A400" size="4"><b>&#8730;</b></font>'
						);
					}
					else
					{
					$respuesta->rows[$i]['cell']=array(
						$iEmpleado,
						$fila['idu_beneficiario'],
						$fila['nom_nombre'],
						$fila['ape_paterno'],
						$fila['ape_materno'],
						$fila['nom_nombre'].' '.$fila['ape_paterno'].' '.$fila['ape_materno'],
						$fila['idu_parentesco'],
						$fila['des_parentesco'],
						$fila['des_observacion'],
						$fila['des_estudios'],
						$fila['idu_especial'],
						''
					);
					}
                    $i++;
                }

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