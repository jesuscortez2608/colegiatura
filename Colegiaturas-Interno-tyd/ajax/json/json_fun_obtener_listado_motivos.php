<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	
	// $iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	$iOpcion = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 0;		
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	// echo($iOpcion);
	// exit();
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = "Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA";
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$cmd->setCommandText("select * from fun_obtener_listado_motivos($iOpcion)");
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
				trim($fila['idu_motivo']),
				trim(encodeToUtf8($fila['des_motivo'])),
				trim($fila['idu_tipo_motivo']),
				trim($fila['des_tipo_motivo']),
				$fila['fec_captura'],
				trim($fila['nom_empleado']),
				trim($fila['estatus']));
				$i++;
			}
		}
		catch(exception $ex)
		{
			$json->mensaje = $ex->getMessage();
			$json->estado=-2;
		}
    }
	// print_r($respuesta);
	// exit();
		
	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
 ?>