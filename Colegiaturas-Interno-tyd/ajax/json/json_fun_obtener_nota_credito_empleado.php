<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	//VARIABLES DE FILTRADO.	
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	$FecIni = isset($_GET['FecIni']) ? $_GET['FecIni'] : '19000101';
	$FecFin = isset($_GET['FecFin']) ? $_GET['FecFin'] : '19000101';
	
	//VARIABLES DE CONEXION.
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $mensaje = $CDB['mensaje'];
	$estado = $CDB['estado'];
	$json = new stdClass();
	
	if($estado != 0)
	{
		try{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		echo json_encode($json);
		exit;
		}
		catch(JsonException $ex){
			$mensaje="Error al cargar Json";	
			}
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		// echo ("{CALL FUN_OBTENER_NOTA_CREDITO_EMPLEADO ('$FecIni', '$FecFin', $iEmpleado)}";
		// exit();
		$query = "{CALL FUN_OBTENER_NOTA_CREDITO_EMPLEADO ('$FecIni', '$FecFin', $iEmpleado)}";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		
		$con->close();
		$i = 0;
		
		$respuesta = new stdClass();
		
		foreach ($ds as $fila)
		{		
			$respuesta->rows[$i]['cell'] = array(				
				//trim(utf8_encode($fila['nempleado'])),
				trim(mb_convert_encoding($fila['nempleado'], 'UTF-8', 'ISO-8859-1')),

				//trim(utf8_encode($fila['sempleado'])),
				trim(mb_convert_encoding($fila['sempleado'], 'UTF-8', 'ISO-8859-1')),
				$fila['sfolionota'],
				number_format($fila['iimportenota'],2),

				number_format($fila['iimporteaplicado'],2),
				number_format($fila['iimporteporaplicar'],2),				
				//trim(utf8_encode($fila['cdoctorelacionado'])),
				trim(mb_convert_encoding($fila['cdoctorelacionado'], 'UTF-8', 'ISO-8859-1')),
				//trim(utf8_encode($fila['iidfactura']))			
				trim(mb_convert_encoding($fila['iidfactura'], 'UTF-8', 'ISO-8859-1')),
			);
			$i++;
		}			
	}
	catch(JsonException $ex){
		$mensaje="Error al cargar Json";	
		}
	catch(exception $ex)
	{
		$mensaje = "";
		$mensaje = $ex->getMessage();
		$estado = -2;
	}
	try{
	echo json_encode($respuesta);
	}
	catch(JsonException $ex){
		$mensaje="Error al cargar Json";	
		}
?>