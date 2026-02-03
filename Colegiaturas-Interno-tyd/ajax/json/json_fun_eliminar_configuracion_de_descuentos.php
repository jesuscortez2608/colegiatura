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
	$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0;
	$iEmpleado = isset($_POST['iEmpleado']) ? $_POST['iEmpleado'] : 0;
    $iCentro = isset($_POST['iCentro']) ? $_POST['iCentro'] : 0;
	$iPuesto = isset($_POST['iPuesto']) ? $_POST['iPuesto'] : 0;
	$iSeccion = isset($_POST['iSeccion']) ? $_POST['iSeccion'] : 0;
	$iEscolaridad = isset($_POST['iEscolaridad']) ? $_POST['iEscolaridad'] : 0;
	$iParentesco = isset($_POST['iParentesco']) ? $_POST['iParentesco'] : 0;
	$iPorcentaje = isset($_POST['iPorcentaje']) ? $_POST['iPorcentaje'] : 0;
	$cComentario = isset($_POST['cComentario']) ? $_POST['cComentario'] : '';
	$Numusuario = (isset($_SESSION[$Session]["USUARIO"]['num_empleado']))? $_SESSION[$Session]["USUARIO"]['num_empleado'] : '';
	$cComentario = $cComentario;	
		
	$json = new stdClass(); 
	$datos = array();	
	if($estado != 0)
	{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		
		try {
			echo json_encode($json);
		} catch (\Throwable $th) {
			echo 'Error en la codificación JSON: ';
		}
		exit;
	}
	try
	{
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		// echo("{CALL fun_eliminar_configuracion_de_descuentos($iOpcion,$iEmpleado, $iCentro, $iPuesto,$iSeccion,$iEscolaridad, $iParentesco, $iPorcentaje, '$cComentario', $Numusuario)}");
		// exit;		
		
		$cmd->setCommandText("{CALL fun_eliminar_configuracion_de_descuentos($iOpcion,$iEmpleado, $iCentro, $iPuesto,$iSeccion,$iEscolaridad, $iParentesco, $iPorcentaje, '$cComentario', $Numusuario)}");
	
	    $ds = $cmd->executeDataSet();
		$con->close();
		
		$json->estado = 0;
		$mensaje=$ds[0][0];

	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectarse a la base de datos";
		$estado=-2;
	}
	$json->estado = $estado;
	$json->mensaje = $mensaje;
	
		
	try {
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>