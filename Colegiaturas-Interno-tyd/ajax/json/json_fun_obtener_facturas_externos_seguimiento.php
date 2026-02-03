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
$orderby = isset($_GET['sidx']) ? $_GET['sidx']: 'dFechaFactura';
$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'asc';
$columns = isset($_GET['columns']) ? $_GET['columns']: 'dFechaFactura, cFolFiscal, nImporteFactura, iPrcDescuento, nImporteCalculado, iBeneficiarioExterno, cNomBeneficiarioExterno, dFechaRegistro, iEstatus, sNomEstatus	, dFechaMarcoEstatus, ifactura, sObservaciones';


$iUsuarioExterno = isset($_GET['iUsuarioExterno']) ? $_GET['iUsuarioExterno'] : 0;
$iEmpleadoExterno = isset($_GET['iEmpleadoExterno']) ? $_GET['iEmpleadoExterno'] : 0;
$sNomEmpleadoExterno = isset($_GET['sNomEmpleadoExterno']) ? $_GET['sNomEmpleadoExterno'] : '';
$FolioFiscal = isset($_GET['Fol_Fiscal']) ? $_GET['Fol_Fiscal'] : '';
$iOpcRango = isset($_GET['iOpcRango']) ? $_GET['iOpcRango'] : 0;
$dFechaInicial = isset($_GET['dFechaInicial']) ? $_GET['dFechaInicial'] : '19000101';
$dFechaFinal = isset($_GET['dFechaFinal']) ? $_GET['dFechaFinal'] : '19000101';
$iEstatus = isset($_GET['iEstatus']) ? $_GET['iEstatus'] : 0;

if($datos_conexion["estado"] != 0){
	echo "Error en la conexion".$datos_conexion["mensaje"];
}

$cadena_conexion = $datos_conexion["conexion"];

try{
	$con = new OdbcConnection($cadena_conexion);
	$con->open();
	
	$cmd = $con->createCommand();

	$query = "SELECT 
				records
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
				, dFechaRegistro
				, iEstatus
				, sNomEstatus
				, dFechaMarcoEstatus
				, ifactura
				, sObservaciones
			FROM fun_obtener_facturas_externos_seguimiento(
			 $rowsperpage
			 , $page
			 , '$orderby'
			 , '$ordertype'
			 , '$columns'
			 , $iUsuarioExterno
			 , $iEmpleadoExterno
			 , '$sNomEmpleadoExterno'
			 , '$FolioFiscal'
			 , $iOpcRango
			 , '$dFechaInicial'
			 , '$dFechaFinal'
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
		$FechaEstatus = $fila['dfechamarcoestatus'];
		if($FechaEstatus == "01-01-1900"){
			$FechaEstatus = '';
		}
		$respuesta->rows[$id]['cell']=array(
		$fila['dfechafactura']
		, trim($fila['cfolfiscal'])
		,'$'.number_format($fila['nimportefactura'], 2,".", ",")
		, $fila['iprcdescuento'].'%'		
		, $fila['iprcdescuento']
		, '$'.number_format($fila['nimportecalculado'], 2, ".", ",")
		, $fila['ibeneficiarioexterno']
		, trim($fila['cnombeneficiarioexterno'])
		, $fila['dfecharegistro']
		, $fila['iestatus']
		, trim($fila['snomestatus'])
		// , $fila['dfechamarcoestatus']
		, $FechaEstatus
		, $fila['ifactura']
		, trim($fila['sobservaciones'])
		);
		$id++;
	}
		
	try {
		echo json_encode($respuesta);	
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}		 
			 
			 
			 
}catch(Exception $ex){
	echo "Error al intentar conectar con la base de datos.";
}
?>