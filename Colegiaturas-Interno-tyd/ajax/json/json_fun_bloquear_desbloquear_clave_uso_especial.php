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
	$iBloqueado 	=	isset($_POST['iBloqueado']) ? $_POST['iBloqueado'] : 0;
	$sClave_Uso = encodeToIso($_POST['sClave_Uso']) ? encodeToIso($_POST['sClave_Uso']) : '';
	
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
			
			// echo("{ CALL fun_afecta_clave_uso_especial (2,$iNumEmp,'$sClave_Uso', 0, $iBloqueado, NULL::DATE, NULL::DATE, $iUsuario)}");
			// exit();
			
			$cmd->setCommandText("{ CALL fun_afecta_clave_uso_especial (2,$iNumEmp,'$sClave_Uso', 0, $iBloqueado, NULL::DATE, NULL::DATE, $iUsuario)}");
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