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
	$orderby = 'idu_empresa, idu_empleado, tipo';
	$ordertype = isset($_GET['sord']) ? $_GET['sord']: 'asc';
	$columns = isset($_GET['columns']) ? $_GET['columns'] :'iempleado, snombre, scentro, snombrecentro, spuesto, snombrepuesto, dfechaingreso, iusuario, snombreusuario, dfecharegistro';
	
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	$dQuincena = isset($_GET['dQuincena']) ? $_GET['dQuincena'] : 0;
	
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado']) ? $_SESSION[$Session]['USUARIO']['num_empleado'] : '';
	
	$estado = $datos_conexion['estado'];
	$mensaje = $datos_conexion['mensaje'];
	$json = new stdClass();
	
	if($estado != 0){
		$json->rows[0]['cell']=array('<script>alert("Error de comunicación, inténtelo más tarde");</script>');
        exit;
	}else{
		try{
			$con = new OdbcConnection($datos_conexion['conexion']);
			$con->open();
			$cmd = $con->createCommand();

			$query = "SELECT records, page, pages, itipo
						, iempresa
						, snombreempresa
						, icolaborador
						, scolaborador
						, icentro
						, scentro
						, ifactura
						, sfactura
						, iimportefactura
						, iimporteincentivo
						, iimporteisr
						, iimporteincentivoisr
						, iajuste
					FROM fun_reporte_incentivos_colegiaturas('$dQuincena'::DATE, $iEmpleado::INTEGER, $iEmpresa::INTEGER, $rowsperpage::INTEGER, $page::INTEGER, '$orderby'::VARCHAR, '$ordertype'::VARCHAR)";

			// 	echo "<pre>";
			// 	print_r("SELECT records, page, pages, itipo
			// 	, iempresa
			// 	, snombreempresa
			// 	, icolaborador
			// 	, scolaborador
			// 	, icentro
			// 	, scentro
			// 	, ifactura
			// 	, sfactura
			// 	, iimportefactura
			// 	, iimporteincentivo
			// 	, iimporteisr
			// 	, iimporteincentivoisr
			// 	, iajuste
			// FROM fun_reporte_incentivos_colegiaturas('$dQuincena'::DATE, $iEmpleado::INTEGER, $iEmpresa::INTEGER, $rowsperpage::INTEGER, $page::INTEGER, '$orderby'::VARCHAR, '$ordertype'::VARCHAR)");
			// 	echo "</pre>";
			// 	exit();
			
			$cmd->setCommandText($query);
			$ds = $cmd->executeDataSet();
			$con->close();
			
			$json->page = $ds[0]['page'];
			$json->total = $ds[0]['pages'];
			$json->records = $ds[0]['records'];
			
			$i=0;
			foreach($ds as $row) {
				$json->rows[$i]['cell'] = array($row['iempresa']
					, ($row['itipo'] == 0) ? encodeToUtf8($row['snombreempresa']) : ''
					, ($row['itipo'] == 0) ? $row['icolaborador'] : ''
					, ($row['itipo'] == 0) ? $row['icolaborador'] . ' ' . encodeToUtf8($row['scolaborador']) : ''
					, ($row['itipo'] == 0) ? $row['icentro'] : 0
					, ($row['itipo'] == 0) ? $row['icentro'] . ' ' . encodeToUtf8($row['scentro']) : ''
					, ($row['itipo'] == 0) ? encodeToUtf8($row['sfactura']) : '<b>' . encodeToUtf8($row['sfactura']) . '</b>'
					, ($row['itipo'] == 0) ? $row['iimportefactura'] : '<b>' . number_format((float) $row['iimportefactura'], 2, '.', ',') . '</b>'
					, ($row['itipo'] == 0) ? $row['iimporteincentivo'] : '<b>' . number_format((float) $row['iimporteincentivo'], 2, '.', ',') . '</b>'
					, ($row['itipo'] == 0) ? '' : '<b>' . number_format((float) $row['iimporteisr'], 2, '.', ',') . '</b>'
					, ($row['itipo'] == 0) ? '' : '<b>' . number_format((float) $row['iimporteincentivoisr'], 2, '.', ',') . '</b>'
					, $row['iajuste']
					, $row['ifactura']
					, $row['itipo']
				);
				$i++;
			}			
			echo json_encode($json);	
		}
		catch(JsonException  $ex){
			$mensaje = "JsonException al conectar con la base de datos.";
			$estado = -2;
		}catch(Exception $ex){
			$mensaje = "Exception al conectar con la base de datos.";
			$estado = -2;
		}

	}
?>