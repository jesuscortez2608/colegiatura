<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	
	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);

	
	$iClaveRutaPago = isset($_GET['idClvRutaPago']) ? $_GET['idClvRutaPago'] : 0;
	$iEstatus = isset($_GET['idEstatus']) ? $_GET['idEstatus'] : 0;
	$iRegion = isset($_GET['idRegion']) ? $_GET['idRegion'] : 0;
	$iCiudad = isset($_GET['idCiudad']) ? $_GET['idCiudad'] : 0;
	$iArea = isset($_GET['idArea']) ? $_GET['idArea'] : 0;
	$Seccion = isset($_GET['Seccion']) ? $_GET['Seccion'] : '';
	$iOpcCiclo = isset($_GET['iOpcCiclo']) ? $_GET['iOpcCiclo'] : 0;
	$iCiclo = isset($_GET['iCiclo']) ? $_GET['iCiclo'] : 0;
	$iOpcFecha = isset($_GET['iOpcFecha']) ? $_GET['iOpcFecha'] : 0;
	$iFecinicial = isset($_GET['dFechaInicial']) ? $_GET['dFechaInicial'] : '';
	$iFecfinal = isset($_GET['dFechaFinal']) ? $_GET['dFechaFinal'] : '';
	$iNumescolaridad = isset($_GET['idEscolaridad']) ? $_GET['idEscolaridad'] : 0;
	$iTipodeduccion = isset($_GET['iTipo_deduccion']) ? $_GET['iTipo_deduccion'] : 0;
	$iCentro = isset($_GET['idCentro']) ? $_GET['idCentro'] : 0;
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;

	
	if ($datos_conexion["estado"] != 0) {
		echo "Error en la conexion " . $datos_conexion["mensaje"];
		exit();
	}

	$cadena_conexion = $datos_conexion["conexion"];

	try {
	
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		// $query = "SELECT * FROM fun_obtener_reporte_por_centro($iClaveRutaPago
		// , $iEstatus
		// , $iRegion
		// , $iCiudad
		// , $iTipodeduccion
		// , '$iFecinicial'
		// , '$iFecfinal'
		// , $iNumescolaridad
		// , $iCentro
		// , $iCiclo
		// , $rowsperpage
		// , $page		
		// , '$orderby'
		// , '$ordertype'
		// , '$columns')";
		$query = "SELECT * FROM fun_obtener_reporte_por_centro($iClaveRutaPago::INTEGER
		, $iEstatus::INTEGER
		, $iRegion::INTEGER
		, $iCiudad::INTEGER
		, $iArea ::INTEGER
		, '$Seccion'::VARCHAR
		, $iTipodeduccion::INTEGER
		, $iOpcFecha::SMALLINT
		, '$iFecinicial'::DATE
		, '$iFecfinal'::DATE
		, $iNumescolaridad::INTEGER
		, $iCentro::INTEGER
		, $iOpcCiclo::SMALLINT
		, $iCiclo::INTEGER
		, $iEmpresa::INTEGER)";
			
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		$con->close();
		
			
		$respuesta = new stdClass();
		$respuesta->page = $matriz[0]['page'];
		$respuesta->total = $matriz[0]['pages'];
		$respuesta->records = $matriz[0]['records'];
		
		$id = 0;
		
		foreach($matriz as $fila) 
		{
			
			if($fila['tipo'] == 1)
			{
				$Empresa = trim(encodeToUtf8($fila['nom_empresa']));
				$Area = trim(encodeToUtf8($fila['nom_area']));
				$Seccion = trim(encodeToUtf8($fila['nom_seccion']));
				$ciclofecha = $fila['idu_centro'] .' - '. $fila['nom_centro'];
			}
			else if($fila['tipo'] == 2)
			{
				$ciclofecha = "<b>TOTAL GENERAL<b>";
				$Empresa = '';
				$Area = '';
				$Seccion = '';
				
			}
			
			$respuesta->rows[$id]['cell'] = array(
				$Empresa
				, $Area
				, $Seccion
				, $ciclofecha			
				, $fila['total_colaboradores']
				, $fila['total_facturas']
				, $fila['total_beneficiarios']
				, number_format($fila['total_importefactura'], 2)
				, number_format($fila['total_importepagado'], 2)
				
			);
			$id++;
		}
			

        try {
			echo json_encode($respuesta);
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }

	} catch (Exception $ex) {
		echo "Error: Ocurrió un error al intentar conectarse con la base de datos.";
	}
?>