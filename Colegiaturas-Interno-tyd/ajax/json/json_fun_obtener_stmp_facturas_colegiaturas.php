<?php  
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	
	$Session = $_GET['session_name'];
	
	$iEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	$cFolio = isset($_GET['cFolio']) ? $_GET['cFolio'] : '';
	$iFactura = isset($_GET['iFactura']) ? $_GET['iFactura'] : 0;
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_stmp_facturas_colegiaturas.txt";
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			// print_r("select * from fun_obtener_stmp_facturas_colegiaturas($iEmpleado, $iFactura,'$cFolio')");
			// exit;
			$cmd->setCommandText("select * from fun_obtener_stmp_facturas_colegiaturas($iEmpleado, $iFactura,'$cFolio')");
			$ds = $cmd->executeDataSet();
			$con->close();
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			$respuesta->totalFactura = array();
			$keyx="";
			$i = 0;
			$TotalDetalle = 0;
			foreach ($ds as $fila)
			{
				if($fila['idu_hoja_azul']==1)//Es beneficiario de la hoja azul
				{
					$keyx=$keyx.$fila['idu_beneficiario'].',';
				}
				
				$nom_periodo = trim($fila['nom_periodo']);
				// $nom_periodo = '"' . trim($fila['nom_periodo']) . '"';
				// $nom_periodo = str_replace(",", '","',$nom_periodo);
				
				$TotalDetalle += $fila['imp_importe'];
				$respuesta->rows[$i]['cell']=array(
					$fila['idu_hoja_azul'],
					$fila['idu_beneficiario'],
					trim($fila['nom_beneficiario']),
					$fila['idu_parentesco'],
					trim($fila['nom_parentesco']),
					$fila['idu_tipo_pago'],
					trim(encodeToUtf8( $fila['des_tipo_pago'])),
					$nom_periodo,
					$fila['idu_escolaridad'],
					$fila['nom_escolaridad'],
					$fila['idu_grado'],
					$fila['nom_grado'],
					$fila['idu_ciclo'],
					trim($fila['nom_ciclo_escolar']),
					$fila['idu_carrera'],
					trim($fila['nom_carrera']),
					$fila['imp_importe'],
					number_format($fila['imp_importe'],2),
					$fila['keyx']
				);
				$i++;
			}
			$respuesta->totalFactura = $TotalDetalle;
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
		}
    }
	/*
	if($keyx!="")
	{
		$keyx = substr($keyx, 0, -1);
		//CONEXION PERSONAL
		$CDB = obtenConexion(BDPERSONALPOSTGRESQL);
		$estado = $CDB['estado'];  
		$mensaje = $CDB['mensaje'];
		$Nombres = new stdClass();
		
	   if($estado != 0)
		{
			$json->estado = $estado;
			$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQL ver -> log".date('d-m-Y')."_json_fun_obtener_beneficiarios_hojaazul_combo.txt";
		} 
		else 
		{
			try
			{
		
				$con = new OdbcConnection($CDB['conexion']);
				$con->open();
				$cmd = $con->createCommand();
				
				$cmd->setCommandText("select * from fun_obtener_beneficiarios_hojaazul($iEmpleado, '$keyx')");
				$dsP = $cmd->executeDataSet();
				$con->close();	
				$i=0;
				// $json->estado = 0;
				// $json->mensaje = "OK";
				$jsonP->datos = array();
				
				$arrP = array();
				
				
				////
				
				foreach ($ds as $fila)
				{
					if($fila['idu_hoja_azul']==1)//Es beneficiario de la hoja azul
					{
						////$keyx+=$fila['idu_beneficiario'].',';
					}
					$respuesta->rows[$i]['cell']=array(
						$fila['idu_hoja_azul'],
						$fila['idu_beneficiario'],
						trim($fila['nom_beneficiario']),
						$fila['idu_parentesco'],
						trim($fila['nom_parentesco']),
						$fila['idu_tipo_pago'],
						trim(utf8_encode( $fila['des_tipo_pago'])),
						trim($fila['nom_periodo']),
						$fila['idu_escolaridad'],
						trim($fila['nom_escolaridad']),
						$fila['idu_grado'],
						trim($fila['nom_grado']),
						$fila['idu_ciclo'],
						trim($fila['nom_ciclo_escolar']),
						$fila['imp_importe']
					);
					$i++;
				}
				
				////
				foreach ($dsP as $value)
				{
					$arr[] = array(
						'value' => $value['parentesco'],'ID' => $value['keyx'], 'nombre' => utf8_encode($value['nom_nombre'].' '.$value['ape_paterno'].' '.$value['ape_materno'])
					);
				}		
				$mensaje="Ok";
				
			}
			catch(exception $ex)
			{
				$json->mensaje = $ex->getMessage();
				$json->estado=-2;
			}
		}
	}
	*/
	try{
    echo json_encode($respuesta);
	}
	catch(JsonException){
		$json->mensaje = "error al cargar Json en linea 178"; //$ex->getMessage();
		$json->estado=-2;
	}
 ?>