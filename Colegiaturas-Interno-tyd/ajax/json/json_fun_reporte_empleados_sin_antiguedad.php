<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : -1;
	$page = isset($_GET['page']) ? $_GET['page'] : -1;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] :'dfecharegistro';
	$ordertype = isset($_GET['sord']) ? $_GET['sord']: 'asc';
	$columns = isset($_GET['columns']) ? $_GET['columns'] :'iempleado, snombre, scentro, snombrecentro, spuesto, snombrepuesto, dfechaingreso, iusuario, snombreusuario, dfecharegistro';
	
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$iOpcionFecha = isset($_GET['iOpcionFecha']) ? $_GET['iOpcionFecha']: 0;
	$dFechaIni = isset($_GET['dFechaIni']) ? $_GET['dFechaIni'] : '19000101';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '19000101';
	
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']: '';

	$estado = $datos_conexion['estado'];
	$mensaje = $datos_conexion['mensaje'];
	$json = new stdClass();
	
	if($estado != 0){
		$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
        exit;
	}else{
		try{
			$con = new OdbcConnection($datos_conexion['conexion']);
			$con->open();
			$cmd = $con->createCommand();

			$query = "SELECT records
							, page
							, pages
							, id
							, iempleado
							, snombre
							, scentro
							, snombrecentro
							, spuesto
							, snombrepuesto
							, dfechaingreso
							, iusuario
							, snombreusuario
							, dfecharegistro
						FROM fun_reporte_empleados_sin_antiguedad(
						$iEmpleado::INTEGER
						, $iOpcionFecha::SMALLINT
						, '$dFechaIni'::DATE
						, '$dFechaFin'::DATE
						, $rowsperpage
						, $page
						, '$orderby'::VARCHAR
						, '$ordertype'::VARCHAR
						, '$columns'::VARCHAR)";
			// echo "<pre>";
			// print_r($query);
			// echo "</pre>";
			// exit();
			
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			$con->close();
			
			$json->page = $ds[0]['page'];
			$json->total = $ds[0]['pages'];
			$json->record = $ds[0]['records'];
			$i=0;
			foreach($ds as $fila){
				$FechaRegistro = date("d/m/Y H:i:s", strtotime($fila['dfecharegistro']));
				$FechaIngreso = date("d/m/Y", strtotime($fila['dfechaingreso']));
				$json->rows[$i]['cell'] = array(
					$fila['iempleado']
					, encodeToUtf8($fila['snombre'])
					, $fila['scentro']
					, encodeToUtf8($fila['snombrecentro'])
					, $fila['spuesto']
					, encodeToUtf8($fila['snombrepuesto'])
					// , strtotime($fila['dfechaingreso']
					, $FechaIngreso
					, $fila['iusuario']
					, encodeToUtf8($fila['snombreusuario'])
					// , $fila['dfecharegistro']
					, $FechaRegistro
				);
				$i++;
			}
			try {
				echo json_encode($json);
			} catch (\Throwable $th) {
				echo "Ocurrió un error al intentar conectar con la base de datos.";
			}
		}catch(Exception $ex){
			$mensaje = $ex->getMessage();
			$estado = -2;
		}
	}
?>