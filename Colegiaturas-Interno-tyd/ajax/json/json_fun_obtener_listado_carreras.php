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
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : -1;
	$page = isset($_GET['page']) ? $_GET['page'] : -1;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'nom_carrera';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
	$columns = isset($_GET['columns']) ? $_GET['columns'] :'idu_carrera, nom_carrera, fec_registro, idu_empleado_registro, nom_empleado_registro';	
	
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
	$iOpcion = isset($_REQUEST['iOpcion']) ? $_REQUEST['iOpcion'] : '1';

    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_carreras.txt";
    }else {
		try{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			$query ="SELECT records
				, page
				, pages
				, id
				, idu_carrera
				, nom_carrera
				, fec_registro
				, idu_empleado_registro
				, nom_empleado_registro
			FROM fun_obtener_listado_carreras(
				$rowsperpage
				, $page
				, '$orderby'
				, '$ordertype'
				,'$columns')";
	
			// echo "<pre>";
			// print_r($query);
			// echo "</pre>";
			// exit();
		
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			$con->close();
			
			$json->page = $ds[0]['page'];
			$json->total = $ds[0]['pages'];
			$json->records = $ds[0]['records'];
			
			if($iOpcion == 0){
				//REGRESA ESTRUCTURA PARA GRID
				$i=0;
				foreach($ds as $fila){
					$json->rows[$i]['cell']=array(
						$fila['idu_carrera']
						, encodetoutf8(trim($fila['nom_carrera']))
						, trim($fila['fec_registro'])
						, $fila['idu_empleado_registro']
						, $fila['idu_empleado_registro'].' - '.encodetoutf8(trim($fila['nom_empleado_registro']))
					);
					$i++;
				}
				try {
					echo json_encode($json);
				} catch (\Throwable $th) {
					echo 'Error en la codificación JSON: ';
				}
			}else{
				$json->datos = array();
				
				$arr = array();
				foreach ($ds as $value)
				{
					$arr[] = array(
						'value' => $value['idu_carrera'], 'nombre' => $value['nom_carrera']
					);
				}
					try {
						$json->estado = $estado;
						$json->datos=$arr;
						echo json_encode($json);	
					} catch (\Throwable $th) {
						echo 'Error en la codificación JSON: ';
					}			
			}
						
		}catch(exception $ex){
			$json->mensaje = "Ocurrió un error al intentar conectar con la base de datos json_fun_obtener_listado_carreras";
			$json->estado=-2;			
		}
    }
 ?>