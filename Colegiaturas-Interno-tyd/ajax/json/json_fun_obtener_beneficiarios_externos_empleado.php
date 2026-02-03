<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	// $Session = $_GET['session_name'];
 
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once "../proc/proc_interaccionalfresco.php";
		require_once '../../../utilidadesweb/librerias/encode/encoding.php';
    //-------------------------------------------------------------------------
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
	
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado']:0;
	$json = new stdClass();	
		
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
	    	
			// echo("{CALL fun_obtener_beneficiarios_externos_empleado($iEmpleado)}");
			// exit();
			$cmd->setCommandText("{CALL fun_obtener_beneficiarios_externos_empleado($iEmpleado)}");
	        $ds = $cmd->executeDataSet();
			$con->close();
	        $i=0;
			foreach ($ds as $fila) {
				$FechaRegistro = $fila['fec_registro'];
				$iDRegistro = $fila['idu_empleado_registro'];
				$iEmp = $fila['idu_empleado'];
				
				if($iEmp <= 1){
					$iEmp = '';
				}
				else{
					$iEmp = $iEmp.' - ';
				}
				if($FechaRegistro == '1900-01-01' || $FechaRegistro == '1900/01/01' || $FechaRegistro == '01/01/1900'){
					$FechaRegistro = '';
				}
				if($iDRegistro == null){
					$iDRegistro = '';
				}
				else{
					$iDRegistro = $iDRegistro.' - ';
				}
				$json->rows[$i]['cell']=array(
					 $fila['opc_seleccionado']
					,$fila['idu_beneficiario']
					// ,$fila['idu_empleado']
					,$iEmp.''.encodetoutf8(trim($fila['nom_beneficiario']))
					,$FechaRegistro
					,$fila['idu_empleado_registro']
					,$iDRegistro.''.encodetoutf8(trim($fila['nom_empleado_registro']))
					);
				$i++;
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
	// print_r($json);
	// exit();

	 try {
		echo json_encode($json);
	 } catch (\Throwable $th) {
		 echo 'Error en la codificación JSON: ';
	 }

?>