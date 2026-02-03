<?php
	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iTipo = isset($_POST['iTipo']) ? $_POST['iTipo'] : 0;
    $respuesta = new stdClass();
    $json = new stdClass();
	
	$iopcion= isset($_POST['iopcion']) ? $_POST['iopcion'] : 0;
	
	$ibeneficiario= isset($_POST['ibeneficiario']) ? $_POST['ibeneficiario'] : 0;
	$itipobeneficiario= isset($_POST['itipobeneficiario']) ? $_POST['itipobeneficiario'] : 0;
	$iescolaridad= isset($_POST['iescolaridad']) ? $_POST['iescolaridad'] : 0;
	$crfc= isset($_POST['crfc']) ? $_POST['crfc'] : '';
	$nEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	
    if($estado != 0)
    {
        $json->estado = $estado;
		//$json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_beneficiario_empleado_rfc.txt";
		//error_log(date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA \n",3,"log".date('d-m-Y')."_json_fun_obtener_beneficiario_empleado_rfc.txt");
		//error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."_json_fun_obtener_beneficiario_empleado_rfc.txt");
    } 
	else 
	{
		// echo ('as');
		// exit();
		try
		{	
			$con = new OdbcConnection($CDB['conexion']);
			$con->open();
			$cmd = $con->createCommand();
			
			// if ($iopcion==5){ 
				 // echo ("SELECT * from FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO($iopcion,'$crfc',$nEmpleado,$ibeneficiario, $itipobeneficiario, $iescolaridad)");
				 // exit();
			// }
			$cmd->setCommandText("SELECT * from FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO($iopcion,'$crfc',$nEmpleado,$ibeneficiario, $itipobeneficiario, $iescolaridad)");
			
			// if ($iopcion == 2) {
				// echo "<pre>";
				// print_r("SELECT * from FUN_OBTENER_DATOS_POR_ESCUELA_EMPLEADO($iopcion,'$crfc',$nEmpleado,$ibeneficiario, $itipobeneficiario, $iescolaridad)");
				// echo "</pre>";
				// exit();
			// }
			
			$ds = $cmd->executeDataSet();
			$con->close();	
			$i=0;
			$json->estado = 0;
			$json->mensaje = "OK";
			$json->datos = array();
			
			
			$arr = array();
			/**
			$iopcion=1 --CARGA BENEFICIARIOS SEGUN ESCUELA-EMPLEADO
			{VALUE=id del beneficiario, NOMBRE=nombre del beneficiario, TIPO= 0 si es de la hoja azul, 1 si es del catalogo, VALOR=id del parentesco del beneficiario}
			$iopcion=2 --CARGA ESCOLARIDADES POR ESCUELA-EMPLEADO
			{VALUE=id escolaridad, NOMBRE=nombre de la escolaridad, TIPO=valor opc_carrera , VALOR=id de la escuela}
			*/
			foreach ($ds as $value)
			{
				$arr[] = array(
					'value' => $value['iid'], 
					'nombre' => encodeToUtf8($value['snombre']),
					'tipo' => encodeToUtf8($value['itipo']),
					'ivalor' => encodeToUtf8($value['ivalor']),
					'bloqueado' => encodeToUtf8($value['ibloqueado'])					
				);
			}		
			$mensaje="Ok";
			
		}
		catch(exception $ex)
		{
			$json->mensaje = "Ocurrió un error al conectar a la base de datos.";
			$json->estado=-2;
			//error_log(date("g:i:s a")." -> Error al consumir fun_obtener_beneficiario_empleado_rfc \n",3,"log".date('d-m-Y')."json_fun_obtener_parentescos.txt");
			//error_log(date("g:i:s a")." -> Error: $estado Tipo: $mensaje   \n",3,"log".date('d-m-Y')."json_fun_obtener_parentescos.txt");
		}
    }
	$json->estado = $estado;
	$json->datos=$arr;
		
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
 ?>