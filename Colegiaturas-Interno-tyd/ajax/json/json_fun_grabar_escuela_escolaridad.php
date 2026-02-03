<?php	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	//-------------------------------------------------------------------------
	$json = new stdClass();
	$idu_escuela = isset($_POST['idu_escuela']) ? $_POST['idu_escuela'] : 0;
	$tipo_escuela= isset($_POST['tipoescuela']) ? $_POST['tipoescuela'] : 0;	
	
	$iEstado = isset($_POST['iEstado']) ? $_POST['iEstado'] : '';
	$iMunicipio = isset($_POST['iMunicipio']) ? $_POST['iMunicipio'] : '';
	$iLocalidad = isset($_POST['iLocalidad']) ? $_POST['iLocalidad'] : '';
	
	$rfc_clave_sep = isset($_POST['RFC']) ? $_POST['RFC'] : '';
	$nom_escuela = isset($_POST['nombre']) ? $_POST['nombre'] : '';
	$idu_escolaridad = isset($_POST['escolaridad']) ? $_POST['escolaridad'] : 0;
	$idu_tipo_deduccion = isset($_POST['idu_tipo_deduccion']) ? $_POST['idu_tipo_deduccion'] : 0;
	$idu_Carrera = isset($_POST['idu_Carrera']) ? $_POST['idu_Carrera'] : 1;	
	$eduEspecial = isset($_POST['eduEspecial']) ? $_POST['eduEspecial'] : 0;
	$opc_obligatorio_pdf = isset($_POST['pdf']) ? $_POST['pdf'] : 0;
	$opc_notaCredito = isset($_POST['opc_notaCredito']) ? $_POST['opc_notaCredito'] : 0;
	$Numusuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$observaciones = isset($_POST['Motivo']) ? $_POST['Motivo'] : '';
	$nom_escuela = $nom_escuela;
	$opc_escuela_bloqueada= isset($_POST['escuela_bloqueada']) ? $_POST['escuela_bloqueada'] : 0;
	
	$estado=0;
	$mensaje='OK';
	try
	{
		$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje = $CDB['mensaje'];	
			
		if($estado != 0) {
			throw new Exception($mensaje);
		}

		$ds=""; //guardo los datos en la consulta del procedimiento
			
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd = $con->createCommand();
		
		// print_r("{CALL fun_grabar_escuela_escolaridad($idu_escuela, $tipo_escuela, $iEstado, $iMunicipio, $iLocalidad, '$rfc_clave_sep', '$nom_escuela', $idu_escolaridad, $idu_tipo_deduccion, $idu_Carrera, $eduEspecial, $opc_obligatorio_pdf, $opc_notaCredito, $Numusuario, '$observaciones')}");
		// exit();	
		$cmd->setCommandText("{CALL fun_grabar_escuela_escolaridad($idu_escuela, $tipo_escuela, $iEstado, $iMunicipio, $iLocalidad, '$rfc_clave_sep', '$nom_escuela', $idu_escolaridad, $idu_tipo_deduccion, $idu_Carrera, $eduEspecial, $opc_obligatorio_pdf, $opc_notaCredito, $Numusuario, '$observaciones')}");
		$ds = $cmd->executeDataSet();
		$estado = $ds[0]['estado'];
		if($estado=='')
		{
			$estado=-1;
		}
		$mensaje = $ds[0]['mensaje'];
		$con->close();
	}
	catch(exception $ex)
	{
	    $mensaje = "Ocurrió un error al intentar conectar con la base de datos json_fun_grabar_escuela_escolaridad";
		$estado = -1;
	}

	try {
	
		$json->estado = $estado;
		$json->mensaje = $mensaje;
		echo (json_encode($json));
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>