<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
	$iCapturo = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	if ($iEmpleado==0)
	{
		$iEmpleado = $iCapturo;
	}
	$estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
         $json = new stdClass();
	
    if($estado != 0)
    {
         $json->estado = $estado;
         $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_beneficiarios_colegiaturas_combo.txt";
    } else {
			
            try
            {
				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
                $cmd = $con->createCommand();
                $cmd->setCommandText(" select distinct * from fun_obtener_listado_beneficiarios_colegiaturas( $iEmpleado)");
                $ds = $cmd->executeDataSet();
                $con->close();
                $i=0;
                $json->estado = 0;
                $json->mensaje = "OK";
                $json->datos = array();
                
				$arr = array();

				foreach ($ds as $value)
				{
					$arr[] = array(
						'value' => $value['iidu_beneficiario'],
						'parentesco' => $value['iidu_parentesco'],
						'nombre' => $value['snombre'].' '.$value['sape_paterno'].' '.$value['sape_materno'],
						'des_parentesco'=> $value['sdes_parentesco'],
						'tipo_beneficiario' => $value['itipo_beneficiario'],
						
					);
				}		

            }
            catch(exception $ex)
            {
                $json->mensaje = "Ocurrió un error al intentar conectar con la base de datos listado_beneficiarios_colegiaturas_combo";
                $json->estado=-2;
            }
    }
		
	try {
        $json->estado = $estado;
        $json->datos=$arr;
        echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
 ?>