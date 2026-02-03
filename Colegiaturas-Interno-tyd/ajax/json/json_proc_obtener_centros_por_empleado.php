<?php
	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
	
	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	$format = isset($_POST['format']) ? $_POST['format'] : '';
	
	//RECOJO LA CADENA DE CONEXION   utilidadesweb/librerias/cnfg/conexiones.php
	//-------------------------------------------------------------------------
	$CDB = obtenConexion(BDPERSONALSQLSERVER);
	$estado = $CDB['estado'];	
	$cadenaconexion_personal_sql = $CDB['conexion'];
	$mensaje = $CDB['mensaje'];	
	
	if($estado != 0)
	{
		try {	
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			$json->resultado = array();
			echo json_encode($json);
			exit();
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}

	// Obtener los centros configurados como suplente
	//-------------------------------------------------------------------------
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
	
	$CDB_ADM = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	$estado_adm = $CDB_ADM['estado'];	
	$cadenaconexion_adm_pg = $CDB_ADM['conexion'];
	$mensaje_adm = $CDB_ADM['mensaje'];	
	
	if($estado_adm != 0)
	{
        try {
			$json->mensaje=$mensaje_adm;
			$json->estado=$estado_adm;
			$json->resultado = array();
			echo json_encode($json);
			exit();
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }
	}
	
	$todos_centros = "";
	$centros_suplente = "";
	try {
		$con = new OdbcConnection($cadenaconexion_adm_pg);
		$con->open();
		$cmd = $con->createCommand();
		$cmd->setCommandText("SELECT idu_centro FROM fun_obtener_centros_suplentes($iUsuario::INTEGER)");
	    $ds = $cmd->executeDataSet();
		
		$cnt = 0;
		foreach($ds as $row) {
			$centro = trim($row["idu_centro"]);
			if ($cnt == 0) {
				$centros_suplente .= $centro;
			} else {
				$centros_suplente .= ",$centro";
			}
			$cnt++;
		}
		
	} catch (Exception $ex) {

        try {
			$json->mensaje="Ocurrió un error al intentar conectar con la base de datos.";
			$json->estado=-1;
			$json->resultado = array();
			echo json_encode($json);
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }

	}

	//declaro el resultado a regresar en el JSon 
	//-------------------------------------------------------------------------
	$respuesta = new stdClass();
	
	$estado = 0;
	$ds="";
	
	$con = new OdbcConnection($cadenaconexion_personal_sql);
	$con->open();
	$cmd = $con->createCommand();
	

	
	try
	{
		
		$cmd->setCommandText("{CALL proc_obtener_centros_por_empleado ($iUsuario, '$centros_suplente')}");
		$ds_2 = $cmd->executeDataSet();
		$mensaje="Ok_consulta_general";
		$aResultado = array();
		
		
		$cnt = 0;
		foreach($ds_2 as $row) {
			if ($cnt == 0) {
				$todos_centros .= $row["idu_centro"];
			} else {
				$todos_centros .= "," . $row["idu_centro"];
			}
			$cnt++;
		}	
		// Solo cuando tiene más de un centro, deberá anexar la opción "TODOS LOS CENTROS"
		if ($cnt > 1) {
			$aResultado[] = array("idu_centro" => $todos_centros
				, "nom_centro" => "TODOS LOS CENTROS");
		}
		
		foreach($ds_2 as $row) {
			$aResultado[] = array("idu_centro" => $row["idu_centro"]
				, "nom_centro" => $row["nom_centro"]);
		}
		
		if ($format == 'select') {
			$select = "";
			foreach($aResultado as $row) {
				$idu_centro = $row["idu_centro"];
				$nom_centro = trim($row["nom_centro"]);
				$select .= "<option value='$idu_centro'>$nom_centro</option>";
			}
			
			echo $select;
		} else {
			try {
				$json = new stdClass();
				$json->estado = 1;
				$json->mensaje = "OK";
				$json->resultado = $aResultado;
				
				echo json_encode($json);
			} catch (\Throwable $th) {
				echo 'Error en la codificación JSON: ';
			}
		}
	} catch(exception $ex) {
		try {	
			$json->mensaje="Ocurrió un error al intentar conectar con la base de datos.";
			$json->estado=-2;
			$json->resultado = array();
			
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
	}
?>