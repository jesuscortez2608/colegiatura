<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	
	$iNumEmp = isset($_POST['iNumEmp']) ? $_POST['iNumEmp'] : 0;
    $respuesta = new stdClass();
    $json = new stdClass();
	
	$ds="";
	$dsP="";
    if($estado != 0)
    {
		$json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_consulta_empleado_co.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_consulta_empleado_co.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_consulta_empleado_co.txt");
    } 
	else 
	{
		$estado = $CDBP['estado'];	
		$mensaje = $CDBP['mensaje'];	
		if($estado != 0)
		{
			$json->estado = $estado;
			$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALSQLSERVER ver -> log".date('d-m-Y')."_json_fun_consulta_empleado_co.txt";
			// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALSQLSERVER \n",3,"log".date('d-m-Y')."_json_fun_consulta_empleado_co.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_consulta_empleado_co.txt");
		} 
		else
		{
			try
			{
				$con = new OdbcConnection($CDB['conexion']);
				$con->open();
				$cmd = $con->createCommand();
				$cmd->setCommandText("{CALL fun_consulta_empleado_co($iNumEmp)}");
				$ds = $cmd->executeDataSet();
				$con->close();
				
				$json->estado = 0;
				$json->mensaje = "OK";
				$json->datos = array();
				
			}
			catch(exception $ex)
			{
				$mensaje = "Ocurrió un error al intentar conectar con la base de datos."; //$ex->getMessage();
				$json->estado=-2;
				// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_listado_escolaridades \n",3,"log".date('d-m-Y')."_json_fun_consulta_empleado_co.txt");
				// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_consulta_empleado_co.txt");
			}
		}	
    }
	try
	{
    	echo json_encode($ds[0]);
	}
	catch (JsonException $ex)
	{
		$mensaje = "Ocurrió un error al codificar JSON."; //$ex->getMessage();
		$json->estado=-2;
	}
 ?>