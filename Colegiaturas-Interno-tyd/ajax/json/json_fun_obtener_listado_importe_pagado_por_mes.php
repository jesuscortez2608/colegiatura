<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	$iEmpleado = isset($_GET['iEmpleado']) ? $_GET['iEmpleado'] : 0;
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_importe_pagado_por_mes.txt";
    } 
	else 
	{
		try
		{
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			// print_r("select  mes, pagado, tope,restante from fun_obtener_listado_importe_pagado_por_mes($iEmpleado)");
			// exit();
			
			//$cmd->setCommandText("select  mes, pagado, tope, restante from fun_obtener_listado_importe_pagado_por_mes($iEmpleado)");
			$cmd->setCommandText("select  mes, pagado_mensual, tope_mensual, restante_mensual, pagado_anual, tope_anual, restante_anual,ajuste from fun_obtener_listado_importe_pagado_por_mes($iEmpleado)");
			$ds = $cmd->executeDataSet();
			$con->close();
			$i=0;
			$respuesta->estado = 0;
			$respuesta->mensaje = "OK";
			//$json->datos = array();
			$i = 0;
			$respuesta->pagado_anual=$ds[0]['pagado_anual'];
			foreach ($ds as $fila)
			{
				if ($fila['restante_mensual']<0){
					$restante_mensual='<font color="#FF0000" size="4"><b>'.number_format($fila['restante_mensual']*(-1),2).' </b></font>';
				}else{
					$restante_mensual=number_format($fila['restante_mensual'],2);
				}
				$respuesta->rows[$i]['cell']=array(
					trim($fila['mes']),
					trim($fila['pagado_mensual']),
					number_format($fila['pagado_mensual'],2),
					trim($fila['tope_mensual']),
					number_format($fila['tope_mensual'],2),
					//number_format($fila['restante_mensual'],2),
					$restante_mensual,
					number_format($fila['restante_anual'],2),
					number_format($fila['ajuste'],2)
				);
				$i++;
			}
		}
		catch(exception $ex)
		{
			$json->mensaje = $ex->getMessage();
			$json->estado=-2;
		}
    }
	try{
    echo json_encode($respuesta);
	}catch(JsonException $ex){
		$mensaje="";
		$mensaje = $ex->getMessage();
	}
 ?>