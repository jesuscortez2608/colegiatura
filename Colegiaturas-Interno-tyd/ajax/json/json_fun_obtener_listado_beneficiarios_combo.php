<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
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
         $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_beneficiarios.txt";
    } else {
			
            try
            {
				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
                $cmd = $con->createCommand();
				// echo("CALL fun_obtener_listado_beneficiarios( $iEmpleado)");
				// exit();
                $cmd->setCommandText(encodeToUtf8("{CALL fun_obtener_listado_beneficiarios( $iEmpleado)}"));
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
						'value' => $value['idu_beneficiario'],
						'parentesco' => $value['idu_parentesco'],
						'nombre' => encodeToUtf8($value['nom_nombre'].' '.$value['ape_paterno'].' '.$value['ape_materno']),
						'des_parentesco'=> $value['des_parentesco'],
						'tipo_beneficiario' => 1
						
					);
				}		

            }
            catch(exception $ex)
            {
                $json->mensaje = "Error al obtener listado de beneficiarios"; //$ex->getMessage();
                $json->estado=-2;
            }
    }
    try{
	$json->estado = $estado;
	$json->datos=$arr;
	echo json_encode($json);
    }
    catch(JsonException $ex){
        $mensaje = "no se pudo realizar conexión en línea 73";
        $estado=-2;
    }
	
 ?>