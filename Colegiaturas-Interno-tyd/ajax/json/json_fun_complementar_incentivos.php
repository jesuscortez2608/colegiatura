<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	// session_name("Session-Colegiaturas"); 
	// session_start();
	// $Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	//VARIABLES DE FILTRADO
	$iOpcion = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 0;
	//$inum_empleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:0;
		
	//VARIABLES DE PAGINACIÓN.
	// $iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	// $iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	// $sOrderColumn = 'nombeneficiario';
	// $sOrderType = 'asc';	
	
	//VARIABLES DE CONEXION
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado = $CDB['estado'];
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
	if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_facturas_colegiaturas_para_traspaso.txt";
    } else 
	{		
		try{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			
			$query = "SELECT inumemp, ntotal FROM fun_complementar_incentivos ($iOpcion) "; //nomempresa, numemp, nombre, importe, isr, total, tipo
			
			// echo($query);
			// exit();
			$cmd->setCommandText($query);			
			$ds = $cmd->executeDataSet();			
			$con->close();
						
			$respuesta = array();						
			$i=0;
			
			/*foreach ($ds as $fila)
			{
				$respuesta->rows[$i]['id']=$i;
				$respuesta->rows[$i]['cell']=array(
												utf8_decode($fila['nomempresa'])
												,utf8_decode($fila['nombre'])
												,'$'.number_format($fila['importe'], 2 ,"." ,"," )
												,'$'.number_format($fila['isr'], 2 ,"." ,"," )
												,'$'.number_format($fila['total'], 2 ,"." ,"," )
												);
				$i++;
			}*/
			
			foreach ($ds as $fila)
			{					
				$respuesta[]=array("numemp" =>$fila['inumemp'],"total"=>(trim($fila['ntotal'])));					
				$i++; 		
			}

			try {
				echo json_encode($respuesta);		
				exit();
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}

			$mensaje="Ok";
	
		}
		catch(exception $ex)
		{
			$json->mensaje = $ex->getMessage();
			$json->estado=-2;			
		}
    }

			try {
				echo json_encode($respuesta);
				exit();
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}		
 ?>