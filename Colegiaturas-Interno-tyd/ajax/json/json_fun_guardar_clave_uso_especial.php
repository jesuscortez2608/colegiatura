<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_POST['session_name'];
 
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once "../proc/proc_interaccionalfresco.php";
		require_once '../../../utilidadesweb/librerias/encode/encoding.php';
	//Declaracion y asignacion de las variables que obtendran un valor de la base de datos
	$iNumEmp 		=	isset($_POST['iNumEmp']) ? $_POST['iNumEmp'] : 0;
	$sFechaIni 		=	isset($_POST['sFechaIni']) ? $_POST['sFechaIni'] : 0;
	$sFechaFin 		=	isset($_POST['sFechaFin']) ? $_POST['sFechaFin'] : 0;
	$iIndefinido 	=	isset($_POST['iIndefinido']) ? $_POST['iIndefinido'] : 0;
	$sClave_Uso = encodeToIso($_POST['sClave_Uso']) ? encodeToIso($_POST['sClave_Uso']) : '';
	//$cDescripcion = encodeToIso($_POST['Des_uso']) ? encodeToIso($_POST['Des_uso']) : '';
	$iOpcion 	=	isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	
	$iUsuario =	(isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : 0;
	
	$json = new stdClass(); 
	try{
			$CDB            = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
			$estado         = $CDB['estado'];
			$cadenaconexion = $CDB['conexion'];
			$mensaje        = $CDB['mensaje'];	
		
			if($estado != 0){
				throw new Exception($mensaje);
			}
			$con = new OdbcConnection($cadenaconexion);
			$con->open();
			$cmd = $con->createCommand();
			
			// echo("{ CALL fun_afecta_clave_uso_especial (1,$iNumEmp,'$sClave_Uso', $iIndefinido, 0, '$sFechaIni'::DATE, '$sFechaFin'::DATE, $iUsuario)}");
			// exit();
			
			$cmd->setCommandText("{ CALL fun_afecta_clave_uso_especial (1,$iNumEmp,'$sClave_Uso', $iIndefinido, 0, '$sFechaIni'::DATE, '$sFechaFin'::DATE, $iUsuario)}");
			$ds = $cmd->executeDataSet();
			$con->close();
			$estado =$ds[0][0]; 
			// print_r($ds);
			// exit();
		}
		catch(exception $ex){
			$mensaje="Ocurrió un error al intentar conectarse a la base de datos";
			$estado=-2;
		}	
		
		try {
			$json->estado = $estado;
			$json->mensaje = $mensaje;
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
?>