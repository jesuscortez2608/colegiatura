<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
    $iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : 0;
	$iFactura = str_replace('"', '', $iFactura);
    $iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
	
	$estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$json = new stdClass();
	
    if($estado != 0)
    {
         $json->estado = $estado;
                $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_activar_aviso_colegiaturas.txt";
                // error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_activar_aviso_colegiaturas.txt");
                // error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_activar_aviso_colegiaturas.txt");
    } else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			// print_r("CALL fun_afecta_notificacion_factura_aclaracion( $iOpcion, ARRAY$iFactura::TEXT[], $iEmpleado)");
			// echo "{CALL fun_afecta_notificacion_factura_aclaracion( $iOpcion, $iEmpleado, $iFactura)}";
			// exit();
			$cmd->setCommandText("{CALL fun_afecta_notificacion_factura_aclaracion( $iOpcion, $iEmpleado, $iFactura)}");
			$ds = $cmd->executeDataSet();
			$con->close();
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();	
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos.";
			$json->estado=-2;
					// error_log(date("g:i:s a")." -> Error al consumir fun_activar_aviso_colegiaturas \n",3,"log".date('d-m-Y')."json_fun_activar_aviso_colegiaturas.txt");
					// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_activar_aviso_colegiaturas.txt");
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