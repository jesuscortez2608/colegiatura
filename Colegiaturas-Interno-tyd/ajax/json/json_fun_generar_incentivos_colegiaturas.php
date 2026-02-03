<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	// session_name("Session-Colegiaturas"); 
	// session_start();
	// $Session = $_GET['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	//VARIABLES DE FILTRADO
	$valor = isset($_GET['valor']) ? $_GET['valor'] : 0;
	//$inum_empleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:0;
		
	//VARIABLES DE PAGINACIÓN.
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	$sOrderColumn = 'nombeneficiario';
	$sOrderType = 'asc';	
	
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
			
			if ($valor == 0) {
				// Cargar en el grid
				$query = "SELECT records, page, pages, id, nomempresa, numemp, nombre, importe, isr, total, tipo FROM FUN_GENERAR_INCENTIVOS_COLEGIATURAS($iCurrentPage,$iRowsPerPage,$valor) ";
			}
			else if($valor == 1){
				// Obtener el listado
				$query = "SELECT records, page, pages, id, numemp, (cast(importe+isr as float)) as total FROM FUN_GENERAR_INCENTIVOS_COLEGIATURAS($iCurrentPage,$iRowsPerPage,$valor) ";
			}
			else
			{
				$query = "SELECT records, page, pages, id, trim(nombre) as Colaborador, trunc((importe::float/100::float)::numeric,2) as importe, trunc((isr::float/100::float)::numeric,2) as isr, trunc((total::float/100::float)::numeric,2) as total, estatus, mensaje FROM FUN_GENERAR_INCENTIVOS_COLEGIATURAS($iCurrentPage,$iRowsPerPage, 0)";
			}
			
			// echo ($query);
			// exit();
			
			$cmd->setCommandText($query);			
			$ds = $cmd->executeDataSet();
			$con->close();
			
			$respuesta = new stdClass();
			$respuesta2 = array();
			
			$respuesta->page = $ds[0]['page'];
			$respuesta->total = $ds[0]['pages'];
			$respuesta->records = $ds[0]['records'];
			
			$i=0;
			if ($valor==0){
				foreach ($ds as $fila)
				{
					$respuesta->rows[$i]['id']=$i;
					$respuesta->rows[$i]['cell']=array(encodeToUtf8($fila['nomempresa'])
													,encodeToUtf8($fila['nombre'])
													,'$'.number_format($fila['importe'], 2 ,"." ,"," )
													,'$'.number_format($fila['isr'], 2 ,"." ,"," )
													,'$'.number_format($fila['total'], 2 ,"." ,"," )
													);
					$i++;
				}
			} else if($valor == 1){
				foreach ($ds as $fila)
				{								
					$respuesta2[]=array("numemp" =>$fila['numemp'],"total"=>(trim($fila['total'])));
					
					$i++; 		
				}
				try {
					echo json_encode($respuesta2);		
					exit();
	
				} catch (\Throwable $th) {
					echo 'Error en la codificación JSON: ';
				}	
			} else {
				$respuesta = new stdClass();
				$respuesta->estatus = $ds[0]['estatus'];
				$respuesta->mensaje = $ds[0]['mensaje'];
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
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}		
 ?>