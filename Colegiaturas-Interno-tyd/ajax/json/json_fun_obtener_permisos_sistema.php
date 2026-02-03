<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_POST['session_name'];

	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	$iSistema = isset($_POST['iSistema']) ? $_POST['iSistema'] : 0;


	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php';

	try {
		$CDB = obtenConexion(BDSYSCOPPELPERSONALSQL);
		$estado = $CDB['estado'];
		$mensaje = $CDB['mensaje'];

		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();

		$cmd->setCommandText("{CALL proc_verificaestructurajerarquica ($iUsuario)}");
		$ds = $cmd->executeDataSet();
		$con->close();
		$iClave = 0;
		if ($ds[0] != null) {
			$iClave = $ds[0]["CLAVE"];
		}
	} catch (Exception $ex) {
		 $desc_mensaje = "Error en consulta de datos estructura Jerarquica";   //$ex->getMessage();
	}
	
	try {
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$mensaje = $CDB['mensaje'];
		$json = new stdClass();
		$json->respuesta = new stdClass();

		$iEstatus = Array();
		$sSistema = Array();
		$iModulo = Array();
		$iOpcion = Array();
		$sMensaje = Array();
		
		if($estado != 0){
			$json->estado = $estado;
			
		} else {
			try {
				$con = new OdbcConnection($CDB['conexion']);
				$con->open();
				$cmd = $con->createCommand();
				$query = "	SELECT	iestatus
									, smensaje
									, ssistema
									, imodulo
									, smodulo
									, iopcion
									, snomopcion
							FROM	fun_obtener_permisos_sistema($iUsuario, $iSistema, $iClave)";
							
				// echo "<pre>";
				// print_r($query);
				// echo "</pre>";
				// exit();

				$cmd->setCommandText($query);
				$ds = $cmd->executeDataSet();
				$con->close();

				$i = 0;
				$x = 0;
				foreach ($ds as $fila) {
					$iEstatus[$i]	= $fila['iestatus'];
					$sSistema[$i]	= $fila['ssistema'];
					$iModulo[$i]	= $fila['imodulo'];
					$iOpcion[$i]	= $fila['iopcion'];
					$sMensaje[$i]	= $fila['smensaje'];

					$i++;
				}
				$cantidadRespuesta = count($iEstatus);
				
				if ( $cantidadRespuesta > 0 ) {
					for ($x=0; $x < $cantidadRespuesta; $x++) {
						if ( $iEstatus[$x] == 1
							&& $sSistema[$x] == 'Sistemas Intranet / Personal'
							&& $iModulo[$x] == 1
							&& $iOpcion[$x] == 1 ) {
								$json->estado = 1;
								$json->mensaje = $sMensaje[$x];
								$json->respuesta = $iEstatus[$x];
								break;
								
						} else if ( $iEstatus[$x] < 1 ) {
							$json->estado = -1;
							$json->mensaje = $sMensaje[$x];
							$json->respuesta = $iEstatus[$x];
							
							break;
						}
					}
				} else {
					$json->estado = -1;
					$json->mensaje = 'Ocurrio un error al realizar la consulta';
					$json->respuesta = -1;
				}
			} catch (Exception $ex) {
				$json->mensaje = "Error de Conexion";
				$json->estado=-2;
			}
		}

	} catch (Exception $ex) {
		$json->mensaje = "Error de Conexion";
		$json->estado=-2;
	}
		
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}

?>