<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_POST['session_name'];
 
		require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
		require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
		require_once "../proc/proc_interaccionalfresco.php";
    //-------------------------------------------------------------------------
	//Declaracion y asignacion de las variables que obtendran un valor de la base de datos
	$iKeyx 		=	isset($_POST['sel_keyx']) ? $_POST['sel_keyx'] : 0;
	$iUsuario		=	(isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : 0;
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
			
			// echo("{ { CALL fun_borrar_clave_uso_permitida ($sel_keyx) }");
			// exit();
			
			$cmd->setCommandText("{ CALL fun_borrar_clave_uso_permitida ($iKeyx) }");
			$ds = $cmd->executeDataSet();			
			$estado =$ds[0][0]; 
			$mensaje = "No hay registro a eliminar";
			// print_r($ds);
			// exit();
		}
		catch(exception $ex){
			$mensaje="Ocurrió un error al intentar conectar a la base de datos.";
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