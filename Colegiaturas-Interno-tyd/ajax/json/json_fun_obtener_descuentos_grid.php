<?php
 header ('Content-type: text/html; charset=utf-8');
 
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];   
    $mensaje = $CDB['mensaje']; 
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

			$cmd->setCommandText("{CALL fun_obtener_descuentos_colegiaturas()}");
	        $ds = $cmd->executeDataSet();
			$con->close();
			$json->datos = array();
	        $i=0;
			 // var_dump($ds);
			// exit();
			foreach ($ds as $fila) {
				$json->rows[$i]['cell']=array(
				 $fila['prc_descuento'],
				 trim($fila['des_descuento']));
				 $i++;
				// var_dump($fila[ciudad]);
				// exit();
			}
		}catch(exception $ex)
	    {
	        $mensaje = "Ocurrió un error al intentar conectarse a la base de datos";
	        $estado=-2;
			$json->rows[0]['cell']=array('<script>alert("Error: '."log".date('d-m-Y').'_json_consultaempleadoabc.txt");</script>');
			error_log(date("g:i:s a")." -> Error al consumir proc_obtenercursosstps \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
			error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_consultaempleadoabc.txt");
	    }
	}
	// var_dump($ds);
	// exit();
	
	 try {
		echo json_encode($ds);
	 } catch (\Throwable $th) {
		 echo 'Error en la codificación JSON: ';
	 }
?>