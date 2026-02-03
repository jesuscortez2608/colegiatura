	<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');

	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];

	require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
	require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	

	////Variables filtrado
	$iRutaPago = isset($_GET['iRutaPago']) ? $_GET['iRutaPago'] : 0;
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudadParametro = isset($_GET['iCiudadParametro']) ? $_GET['iCiudadParametro'] : 0;
	$iDeduccionParametro = isset($_GET['iDeduccionParametro']) ? $_GET['iDeduccionParametro'] : 0;
	$dFechaIni = isset($_GET['dFechaIni']) ? $_GET['dFechaIni'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	$iEscolaridad = isset($_GET['iEscolaridad']) ? $_GET['iEscolaridad'] : 0;
	$iEscuela = $_GET['iEscuela'] == '' ? 0 : $_GET['iEscuela'];
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	
	////Variables Conexion
	$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);

	if ($datos_conexion["estado"] != 0) {
		echo "Error en la conexion " . $datos_conexion["mensaje"];
		exit();
	}
	
	$cadena_conexion = $datos_conexion["conexion"];
	
	try {
		$con = new OdbcConnection($cadena_conexion);
		$con->open();
		
		$cmd = $con->createCommand();
		
		// $query = "SELECT * FROM fun_obtener_reporte_becas_por_escuela($iRutaPago,$iEstatus,$iRegion,$iCiudadParametro,$iDeduccionParametro,'$dFechaIni','$dFechaFin',$iEscolaridad,$iEscuela,$rowsperpage,$page,'$orderby','$ordertype','$columns')";
		$query = "SELECT * FROM fun_obtener_reporte_becas_por_escuela(
			$iRutaPago
			, $iEstatus
			, $iRegion
			, $iCiudadParametro
			, $iEmpresa
			, $iDeduccionParametro
			, '$dFechaIni'
			, '$dFechaFin'
			, $iEscolaridad
			, $iEscuela)";
		
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		$cmd->setCommandText($query);
		$matriz = $cmd->executeDataSet();
		
		//TOTALES.
		/*$TotalColaboradores=0;
		$TotalFacturasIngresadas=0;
		$TotalImporte=0;
		$TotalPagado=0;*/
		
		$respuesta = new stdClass();
		$respuesta->page = $matriz[0]['page'];
		$respuesta->total = $matriz[0]['pages'];
		$respuesta->records = $matriz[0]['records'];
		
		$id=0;
		
		foreach($matriz as $fila) 
		{
			
			if($fila['tipo']==1)
			{
				if($fila['rfc'] == '' || $fila['nom_escuela'] == ''){
					$Rfc = '';
				} else {
					$Rfc = encodeToUtf8($fila['rfc']).' - '.encodeToUtf8($fila['nom_escuela']);
				}
				$Empresa = encodeToUtf8($fila['nom_empresa']);
			}
			else if($fila['tipo']==2)
			{
				$Rfc="<b>TOTAL GENERAL<b>";
				$Empresa = '';
			}
			
			$respuesta->rows[$id]['cell'] = array(
				$Empresa
				, $Rfc			
				,encodeToUtf8($fila['nom_tipoescuela'])
				,$fila['total_facturas']
				,number_format($fila['total_importefacturas'],2)
				,number_format($fila['total_importepagado'],2)
				,encodeToUtf8($fila['nom_escolaridad'])
				,$fila['total_beneficiarios']
			);
			$id++;
		}
		
       
        try {
			echo json_encode($respuesta);
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }

	} catch (Exception $ex) {
		echo "Error: Al intentar conectarse a la base de datos.";
	}
?>