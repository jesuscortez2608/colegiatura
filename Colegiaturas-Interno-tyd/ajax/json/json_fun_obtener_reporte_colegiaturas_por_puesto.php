<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas");
	session_start();
	$Session = $_GET['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
	
	//VARIABLES DE FILTRADO.
	$_GETS = filter_input_array(INPUT_GET,FILTER_SANITIZE_NUMBER_INT);
	$iRutaPago = isset($_GET['iRutaPago']) ? $_GET['iRutaPago'] : 0;
	$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;
	$iRegion = isset($_GET['iRegion']) ? $_GET['iRegion'] : 0;
	$iCiudad = isset($_GET['iCiudad']) ? $_GETS['iCiudad'] : 0;
	$iTipoDeduccion  = isset($_GET['iTipoDeduccion']) ? $_GET['iTipoDeduccion'] : 0;
	$iEscolaridad = isset($_GET['iEscolaridad']) ? $_GET['iEscolaridad'] : 0;
	$iOpcFecha = isset($_GET['iOpcFecha']) ? $_GET['iOpcFecha'] : 0;
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	$iOpcCiclo = isset($_GET['iOpcCiclo']) ? $_GET['iOpcCiclo'] : 0;
	$iCicloEscolar = isset($_GET['iCicloEscolar']) ? $_GET['iCicloEscolar'] : 0;
	$iCentro = isset($_GET['iCentro']) ? $_GET['iCentro'] : 0;
	$iArea = isset($_GET['iArea']) ? $_GET['iArea'] : 0;
	$Seccion = isset($_GET['Seccion']) ? $_GET['Seccion'] : '';
	$iEmpresa = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : '';
	
	//VARIABLES DE CONEXION.
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $mensaje = $CDB['mensaje'];
	$estado = $CDB['estado'];
	$json = new stdClass();
	$respuesta = new stdClass();
	$json->resultado=array();
	$datos = array();
	
	if($estado != 0)
	{

        try {
			$json->mensaje=$mensaje;
			$json->estado=$estado;
			echo json_encode($json);
			exit;
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }

	}
	try
	{	
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		// $query = "{CALL fun_obtener_reporte_colegiaturas_por_puesto($iRutaPago,	$iEstatus, $iRegion, $iCiudad, $iTipoDeduccion, $iEscolaridad, '$dFechaInicio', '$dFechaFin', $iCicloEscolar)}";
		$query = "SELECT * FROM fun_obtener_reporte_colegiaturas_por_puesto(
					$iRutaPago
					, $iEstatus
					, $iEmpresa
					, $iRegion
					, $iCiudad
					, $iTipoDeduccion
					, $iEscolaridad
					, $iOpcFecha::SMALLINT
					, '$dFechaInicio'::DATE
					, '$dFechaFin'::DATE
					, $iOpcCiclo::SMALLINT
					, $iCicloEscolar
					, $iArea
					, '$Seccion'::VARCHAR
					, $iCentro)";
		// echo "<pre>";
		// print_r($query);
		// echo "</pre>";
		// exit();
		
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		
		$con->close();
		$i = 0;
		
		//TOTALES.
		$TotalColaboradores=0;
		$TotalFacturas=0;
		$TotalBecados=0;
		$TotalImporte=0;
		$TotalReembolso=0;
		
		foreach ($ds as $fila)
		{
			// $TotalColaboradores += $fila['total_colaboradores'];
			// $TotalFacturas += $fila['total_facturas'];
			// $TotalBecados += $fila['total_becados'];
			// $TotalImporte += $fila['total_facturado'];
			// $TotalReembolso += $fila['total_reembolso'];
			if($fila['tipo'] == 1){
				$Empresa = trim(encodeToUtf8($fila['nom_empresa']));
				$Area = trim(encodeToUtf8($fila['nom_area']));
				$Seccion = trim(encodeToUtf8($fila['nom_seccion']));
				$Centro = $fila['idu_centro'].' - '.trim(encodeToUtf8($fila['nom_centro']));
				$Puesto = trim(encodeToUtf8($fila['nom_puesto']));
			} else if($fila['tipo'] == 2){
				$Empresa = '';
				$Area = '';
				$Seccion = '';
				$Centro = '';
				$Puesto = '<b>TOTAL GENERAL</b>';
				
			}
		
			$respuesta->rows[$i]['cell'] = array(
				$Empresa
				, $Area
				, $Seccion
				, $Centro
				, $fila['idu_puesto']
				, $Puesto
				, number_format($fila['total_colaboradores'],0)
				, number_format($fila['total_facturas'],0)
				, number_format($fila['total_beneficiarios'],0)
				, number_format($fila['total_importefactura'],2)
				, number_format($fila['total_importepagado'],2)
			);
			$i++;
		}
	}
	catch(exception $ex)
	{
		$mensaje = "";
		$mensaje = $ex->getMessage();
		$estado = -2;
	}

	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
?>