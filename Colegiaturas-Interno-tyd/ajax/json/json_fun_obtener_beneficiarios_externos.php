<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];
 
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once "../proc/proc_interaccionalfresco.php";
		require_once '../../../utilidadesweb/librerias/encode/encoding.php';
    //-------------------------------------------------------------------------
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : -1;
	$page = isset($_GET['page']) ? $_GET['page'] : -1;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'fec_registro';
	$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
	$columns = isset($_GET['columns']) ? $_GET['columns'] :'idu_beneficiario, idu_empleado, nom_empleado, prc_descuento, opc_beneficiario_bloqueado, fec_registro, idu_empleado_registro, nom_empleado_registro';
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
    $json = new stdClass();	
	
	$iIduEmpleado = isset($_REQUEST['iIduEmpleado']) ? $_REQUEST['iIduEmpleado'] : '0';


	if($estado != 0){
		$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
        exit;
    }else{
		try{
			$con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
			
			// echo "SELECT records
						// , page
						// , pages
						// , id
						// , idu_beneficiario
						// , idu_empleado
						// , nom_empleado
						// , prc_descuento
						// , opc_beneficiario_bloqueado
						// , fec_registro
						// , idu_empleado_registro
						// , nom_empleado_registro
					// FROM fun_obtener_beneficiarios_externos(
					// $iIduEmpleado
					// , $rowsperpage
					// , $page
					// , '$orderby'
					// , '$ordertype'
					// , '$columns')";
					// exit();
	    	
			$query = "SELECT records
						, page
						, pages
						, id
						, idu_beneficiario
						, idu_empleado
						, nom_empleado
						, prc_descuento
						, opc_beneficiario_bloqueado
						, fec_registro
						, idu_empleado_registro
						, nom_empleado_registro
					FROM fun_obtener_beneficiarios_externos(
					$iIduEmpleado
					, $rowsperpage
					, $page
					, '$orderby'
					, '$ordertype'
					, '$columns')";
	// echo "<pre>";
	// print_r($query);
	// echo "</pre>";
	// exit();
			
			$cmd->setCommandText($query);
	        $ds = $cmd->executeDataSet();
			
			$json->page = $ds[0]['page'];
			$json->total = $ds[0]['pages'];
			$json->record = $ds[0]['records'];
			
			if ($iIduEmpleado == 0) {
				// Regresar estructura para grid
				$i=0;
				foreach ($ds as $fila) {
					$iEmp = trim($fila['idu_empleado']);
					if($iEmp <=1){
						$iEmp = '';
					}else{
						$iEmp = $iEmp.' - ';
					}
					$json->rows[$i]['cell']=array(
						$fila['idu_beneficiario']
						,$fila['idu_empleado']
						,$iEmp.''.encodetoutf8(trim($fila['nom_empleado']))
						,encodetoutf8(trim($fila['nom_empleado']))
						,$fila['prc_descuento']
						,$fila['prc_descuento'].' %'
						,$fila['opc_beneficiario_bloqueado']
						,$fila['opc_beneficiario_bloqueado']==1 ? '<font color="#00A400" size="4"><strong>&#8730;</strong><font>':''
						,mb_convert_encoding(trim($fila['fec_registro']), 'UTF-8', 'ISO-8859-1')
						,$fila['idu_empleado_registro']
						,trim($fila['idu_empleado_registro']).' - '.mb_convert_encoding(trim($fila['nom_empleado_registro']), 'UTF-8', 'ISO-8859-1')
						);
					$i++;
				}
				try{
				echo json_encode($json);
				}
				catch(JsonException $ex){
					$mensaje = "no se pudo realizar conexión en línea 118";
					$estado=-2;
				}
			} else {
				// TODO Regresar estructura para un combo
				$i = 0;
				$json->datos = array();
				foreach($ds as $fila){		
					$json->datos[$i] = new stdClass();
					$json->datos[$i]->idu_beneficiario = (isset($fila['idu_beneficiario'])) ? $fila['idu_beneficiario']:'';
					$json->datos[$i]->nom_beneficiario = encodetoutf8(trim($fila['nom_empleado']));
					$json->datos[$i]->prc_descuento = $fila['prc_descuento'];
					$i++;
				}
				try{
				$json->estado = 0;
				$json->mensaje = "OK";
				echo json_encode($json);
				}
				catch(JsonException $ex){
					$mensaje = "no se pudo realizar conexión en línea 138";
					$estado=-2;
				}
			}
		}catch(exception $ex)
	    {
	        $mensaje = $ex->getMessage();
	        $estado=-2;
			$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
			// error_log(date("g:i:s a")." -> Error al consumir proc_obtenercursosstps \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
	    }
	}
?>