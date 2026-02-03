	<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	

	//Variable de conexi�n
	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
	//Variable de filtrado
	/*$iRutaPago = isset($_GET['iRutaPago']) ? $_GET['iRutaPago'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudadParametro = isset($_GET['iCiudadParametro']) ? $_GET['iCiudadParametro'] : 0;
	$iDeduccionParametro = isset($_GET['iDeduccionParametro']) ? $_GET['iDeduccionParametro'] : 0;
	$dFechaIni = isset($_GET['dFechaIni']) ? $_GET['dFechaIni'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	$iEscolaridad = isset($_GET['iEscolaridad']) ? $_GET['iEscolaridad'] : 0;
	$iParentesco =  isset($_GET['iParentesco']) ? $_GET['iParentesco'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;*/

	$iRutaPago = 			isset($_GET['iRutaPago']) 			? filter_var($_GET['iRutaPago'], FILTER_VALIDATE_INT) : 0;
	$iRegion = 				isset($_GET['iRegion']) 			? filter_var($_GET['iRegion'], FILTER_VALIDATE_INT) : 0;
	$iCiudadParametro = 	isset($_GET['iCiudadParametro']) 	? filter_var($_GET['iCiudadParametro'], FILTER_VALIDATE_INT) : 0;
	$iDeduccionParametro =	isset($_GET['iDeduccionParametro'])	? filter_var($_GET['iDeduccionParametro'], FILTER_VALIDATE_INT) : 0;
	$dFechaIni = 			isset($_GET['dFechaIni']) 			? filter_var($_GET['dFechaIni'], FILTER_SANITIZE_SPECIAL_CHARS) : '';
	$dFechaFin = 			isset($_GET['dFechaFin']) 			? filter_var($_GET['dFechaFin'], FILTER_SANITIZE_SPECIAL_CHARS) : '';
	$iEscolaridad = 		isset($_GET['iEscolaridad'])		? filter_var($_GET['iEscolaridad'], FILTER_VALIDATE_INT) : 0;
	$iParentesco =  		isset($_GET['iParentesco']) 		? filter_var($_GET['iParentesco'], FILTER_VALIDATE_INT) : 0;
	$iEmpresa = 			isset($_GET['iEmpresa']) 			? filter_var($_GET['iEmpresa'], FILTER_VALIDATE_INT) : 0;
	

	if ($datos_conexion["estado"] != 0) {
		echo "Error en la conexion " . $datos_conexion["mensaje"];
		exit();
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		$query = "SELECT * 
		FROM fun_obtener_reporte_becas_por_parentesco(
			$iRutaPago
			,$iRegion
			,$iCiudadParametro
			,$iDeduccionParametro
			,'$dFechaIni'
			,'$dFechaFin'
			,$iEscolaridad
			,$iParentesco
			,$iEmpresa)";
		
		/*echo "<pre>";
		print_r($query);
		echo "</pre>";
		exit();*/
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		
		$respuesta = new stdClass();
		$respuesta->page = $matriz[0]['page'];
		$respuesta->total = $matriz[0]['pages'];
		$respuesta->records = $matriz[0]['records'];
		
		$id=0;
		
		foreach($matriz as $fila) 
		{
			
			if($fila['tipo']==1) {
				$Parentesco = $fila['nom_parentesco'];
			} else if ($fila['tipo'] == 2){
				$Parentesco = '<b>TOTAL<b>';
			} else if($fila['tipo']==3) {
				$Parentesco="<b>TOTAL GENERAL<b>";
			}
			
			$respuesta->rows[$id]['cell'] = array(
				encodeToUtf8(trim($fila['nom_empresa']))
				, $Parentesco
				, $fila['total_beneficiarios']
				, $fila['total_facturas']
				, number_format($fila['prc_beneficiarios'],2).'%'
				, number_format($fila['prc_facturas'],2).'%'
			);
			$id++;
		}
		

        try {
			echo json_encode($respuesta);
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }

	} catch (Exception $ex) {
		echo "Error: Al intentar conectar con la base de datos.";
	}
?>