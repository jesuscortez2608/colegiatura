<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	//-----------------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
	$iFactura = isset($_POST['iFactura']) ? $_POST['iFactura'] : '';
 
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = "Error al conectar con base de datos";
    }else {
		try{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
            $query ="{CALL fun_tipo_moneda_colegiaturas(1, $iFactura, 0, '')}";
            $cmd->setCommandText($query);
            $ds = $cmd->executedataSet();
            $con->close();
            $json->moneda = $ds[0]['fun_tipo_moneda_colegiaturas'];
        }
        catch(exception $ex){
			$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos json_fun_obtener_listado_carreras";
			$json->estado=-2;			
		}
    }
    try {
		echo json_encode($json);
	 } catch (\Throwable $th) {
		 echo 'Error en la codificación JSON: ';
	 }
    
 ?>