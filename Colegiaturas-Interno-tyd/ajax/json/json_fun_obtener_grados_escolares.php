<?php

	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iEscolaridad = isset($_REQUEST['iEscolaridad']) ? $_REQUEST['iEscolaridad'] : 0;
	$iOpcion = isset($_REQUEST['iOpcion']) ? $_REQUEST['iOpcion'] : 0;
    $respuesta = new stdClass();
    $json = new stdClass();
	// echo('iEscolaridad='.$iEscolaridad);
	// exit();
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_grados_escolares.txt";
    } 
	else 
	{
		try
		{
	
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			// echo("select * from fun_obtener_grados_escolares($iEscolaridad)");
			// exit();
			$cmd->setCommandText("select * from fun_obtener_grados_escolares($iEscolaridad)");
			$ds = $cmd->executeDataSet();
			$con->close();	
			$i=0;
			
			if ( $iOpcion == 1 ) { //Estructura para grid
				$i = 0;
				foreach( $ds as $fila ) {
					$json->rows[$i]['cell'] = array(
						$fila['idu_grado_escolar']
						, encodeToUtf8( trim( $fila['nom_grado_escolar'] ))
					);
					$i++;
				}
				try{
				echo json_encode($json);
				}
				catch(JsonException $ex){
					$mensaje = "no se pudo realizar conexión en línea 53";
					$estado=-2;
				}
			} else { // Estructura para combo
				$json->estado = 0;
				$json->mensaje = "OK";
				$json->datos = array();
				
				$arr = array();
				foreach ($ds as $value) {
					$arr[] = array(
						'value' => $value['idu_grado_escolar'], 'nombre' => encodeToUtf8($value['nom_grado_escolar'])
					);
				}		
				$mensaje="Ok";
				try{
				$json->estado = $estado;
				$json->datos=$arr;
				echo json_encode($json);
				}
				catch(JsonException $ex){
					$mensaje = "no se pudo realizar conexión en línea 74";
					$estado=-2;
				}
			}
		} catch(exception $ex) {
			$json->mensaje = "Error al obtener grados escolares";// $ex->getMessage();
			$json->estado=-2;
		}
    }
?>