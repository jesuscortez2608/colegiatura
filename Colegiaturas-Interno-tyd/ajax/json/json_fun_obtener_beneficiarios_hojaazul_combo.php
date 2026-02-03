<?php

	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
	$cBeneficiarios = isset($_POST['cBeneficiarios']) ? $_POST['cBeneficiarios'] : 0;
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
	if($iEmpleado==0)
	{
		$iEmpleado = $iUsuario;
	}
    $respuesta = new stdClass();
    $json = new stdClass();

    if($estado != 0)
    {
        $json->estado = $estado;
		$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_beneficiarios_hojaazul_combo.txt";
		// error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_beneficiarios_hojaazul_combo.txt");
		// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_beneficiarios_hojaazul_combo.txt");
    } 
	else 
	{
		try
		{
	
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			// echo("select * from fun_obtener_beneficiarios_hojaazul($iEmpleado, '$cBeneficiarios')");
			// exit();
			$cmd->setCommandText("select * from fun_obtener_beneficiarios_hojaazul($iEmpleado, '$cBeneficiarios')");
			$ds = $cmd->executeDataSet();
			$con->close();	
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			
			$arr = array();
			foreach ($ds as $value) {
				$arr[] = array(
					'value' => $value['keyx'],
					'parentesco' => $value['parentesco'], 
					'nombre' => mb_convert_encoding($value['nom_nombre'].' '.$value['ape_paterno'].' '.$value['ape_materno'], 'UTF-8', 'ISO-8859-1'),
					'tipo_beneficiario' => 0
				);
			}		
			$mensaje="Ok";
			
		}
		catch(exception $ex)
		{
			$json->mensaje = "Error al obtener datos de Beneficiarios"; //$ex->getMessage();
			$json->estado=-2;
			// error_log(date("g:i:s a")." -> Error al consumir fun_obtener_beneficiarios_hojaazul \n",3,"log".date('d-m-Y')."json_fun_obtener_beneficiarios_hojaazul_combo.txt");
			// error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_beneficiarios_hojaazul_combo.txt");
		}
    }
	try{
	$json->estado = $estado;
	$json->datos=$arr;
	echo json_encode($json);
	}
	catch(JsonException $ex){
		$mensaje = "no se pudo realizar conexión en línea 76";
		$estado=-2;
	}
 ?>