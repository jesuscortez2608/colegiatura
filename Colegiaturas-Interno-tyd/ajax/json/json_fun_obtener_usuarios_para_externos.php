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
	$rowsperpage = isset($_GET['rows']) ? $_GET['rows']: -1;
	$page = isset($_GET['page']) ? $_GET['page']: -1;
	$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'dfecharegistro';
	$ordertype = isset($_GET['sord']) ? $_GET['sord']: 'asc';
	$columns = isset($_GET['columns']) ? $_GET['columns'] : 'iempleado, snombre, icentro, snombrecentro, ipuesto, snombrepuesto, iindefinido, ibloqueado, dfechainicial, dfechafinal, dfecharegistro, icolaboradorasignopermiso, scolaboradorasignopermiso';
    $respuesta = new stdClass();
	$json = new stdClass();	
		
	if($estado != 0){
		$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
		error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
		error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
        exit;
    }else{
		try{
			$con = new OdbcConnection($CDB['conexion']);
	        $con->open();
	        $cmd = $con->createCommand();
	    	
			// echo("{CALL fun_obtener_usuarios_para_externos()}");
			// exit();
			// $cmd->setCommandText("{CALL fun_obtener_usuarios_para_externos()}");
			$query = "SELECT records
						, page
						, pages
						, id
						, iempleado
						, snombre
						, icentro
						, snombrecentro
						, ipuesto
						, snombrepuesto
						, iindefinido
						, ibloqueado
						, dfechainicial
						, dfechafinal
						, dfecharegistro
						, icolaboradorasignopermiso
						, scolaboradorasignopermiso
					FROM fun_obtener_usuarios_para_externos(
						$rowsperpage
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
			
			// $con->close();
	        $i=0;
			foreach ($ds as $fila) {
				$FechaIni = $fila['dfechainicial'];
				$FechaFin = $fila['dfechafinal'];
				if($FechaIni == "01-01-1900"){
					$FechaIni = '';
				}
				if($FechaFin == "01-01-1900"){
					$FechaFin = '';
				}
				$json->rows[$i]['cell']=array(
					$fila['iempleado']
					,trim($fila['iempleado']).' - '.encodetoutf8(trim($fila['snombre']))
					,$fila['icentro']
					,trim($fila['icentro']).' - '.encodetoutf8(trim($fila['snombrecentro']))
					,$fila['ipuesto']
					,trim($fila['ipuesto']).' - '.encodetoutf8(trim($fila['snombrepuesto']))
					,$fila['iindefinido']
					,$fila['iindefinido']==1 ? '<font color="#00A400" size="4"><strong>&#8730;</strong><font>':''
					,$fila['ibloqueado']==1 ? '<font color="#00A400" size="4"><strong>&#8730;</strong><font>':''					
					,$fila['ibloqueado']
					// ,date("d/m/Y", strtotime($fila['dfechainicial'])) 
					// ,$fila['dfechainicial']
					,$FechaIni
					,$FechaFin
					,$fila['dfecharegistro']
					,$fila['icolaboradorasignopermiso']
					,trim($fila['icolaboradorasignopermiso']).' - '.trim($fila['scolaboradorasignopermiso'])
					);
				$i++;
			}
		}catch(exception $ex)
	    {
	        $mensaje = $ex->getMessage();
	        $estado=-2;
			$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
			error_log(date("g:i:s a")." -> Error al consumir proc_obtenercursosstps \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
			error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
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