<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');


session_name("Session-Colegiaturas");
session_start();
$Session = $_GET['session_name'];

require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
$rowsperpage = isset($_GET['rows']) ? $_GET['rows'] : 10;
$page = isset($_GET['page']) ? $_GET['page'] : 1;
$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'dfecharegistro';
$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
$columns = isset($_GET['columns']) ? $_GET['columns'] : 'dfechafactura, cfolfiscal, nimportefactura, iprcdescuento, nimportecalculado, ibeneficiarioexterno, cnombeneficiarioexterno, iempleadocaptura, cnombrecaptura, dfecharegistro';

$FolioFiscal = isset($_GET['Fol_Fiscal']) ? $_GET['Fol_Fiscal'] : '';
$iUsuarioExterno = isset($_GET['iUsuario']) ? $_GET['iUsuario'] : 0;
$iOpcRango = isset($_GET['iOpcion']) ? $_GET['iOpcion'] : 0;
$fechaIni = isset($_GET['FechaIni']) ? $_GET['FechaIni'] : '19000101';
$fechaFin = isset($_GET['FechaFin']) ? $_GET['FechaFin'] : '19000101';
$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;

if($datos_conexion["estado"] != 0){
	echo "Error en la conexion ".$datos_conexion["mensaje"];
	exit();
}

$cadena_conexion = $datos_conexion["conexion"];

try{
	$con = new OdbcConnection($cadena_conexion);
	$con->open();
	
	$cmd = $con->createCommand();
	
	$query = "SELECT records
			, page
			, pages
			, id
			, dFechaFactura
			, cFolFiscal
			, nImporteFactura
			, iPrcDescuento
			, nImporteCalculado
			, iBeneficiarioExterno
			, cNomBeneficiarioExterno
			, iEmpleadoCaptura
			, cNombreCaptura
			, dFechaRegistro
		FROM fun_consultar_facturas_externos(
				$rowsperpage
				, $page
				, '$orderby'
				, '$ordertype'
				, '$columns'
				, '$FolioFiscal'
				, $iUsuarioExterno
				, $iOpcRango
				, '$fechaIni'::DATE
				, '$fechaFin'::DATE
				, $iEstatus)";
				
	
	// echo "<pre>";
	// print_r($query);
	// echo "</pre>";
	// exit();
	
	
	$cmd->setCommandText($query);
	$matriz = $cmd->executeDataSet();
	
	$respuesta = new stdClass();
	$respuesta->page = $matriz[0]['page'];
	$respuesta->total = $matriz[0]['pages'];
	$respuesta->records = $matriz[0]['records'];
	
	$id=0;
	
	foreach($matriz as $fila){
		$respuesta->rows[$id]['cell']=array(
			$fila['dfechafactura']
			, trim($fila['cfolfiscal'])
			// , '$'.$fila['nimportefactura']
			,'$'.number_format($fila['nimportefactura'], 2 ,"." ,"," )
			, $fila['iprcdescuento'].'%'
			, $fila['iprcdescuento']
			// , '$'.$fila['nimportecalculado']
			,'$'.number_format($fila['nimportecalculado'], 2 ,"." ,"," )
			, $fila['ibeneficiarioexterno']
			, trim($fila['cnombeneficiarioexterno'])
			, $fila['iempleadocaptura']
			, $fila['iempleadocaptura'].' - '.trim($fila['cnombrecaptura'])
			, trim($fila['dfecharegistro'])
			);
			$id++;
	}

	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}

} catch(Exception $ex){
	echo "Error: Ocurrió un error al intentar conectar con la base de datos.";
}

?>