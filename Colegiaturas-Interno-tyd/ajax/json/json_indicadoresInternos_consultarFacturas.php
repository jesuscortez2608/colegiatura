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
$orderby = isset($_GET['sidx']) ? $_GET['sidx'] : 'dias_respuesta';
$ordertype = isset($_GET['sord']) ? $_GET['sord'] : 'desc';
$columns = 'numemp, nombre,reembolsoConIsr, reembolsoSinIsr, region, folio_fiscal,nom_escolaridad,fecha_solicitud,fecha_autoriza_gerente, fecha_reviso_analista, fecha_pago, nom_estatus,dias_respuesta,
anio, mes,nom_analista, numcentro_analista, nomcentro_analista, mes_rev_analista, anio_rev_analista';

$fechaIni = isset($_GET['FechaIni']) ? $_GET['FechaIni'] : '20200101';
$fechaFin = isset($_GET['FechaFin']) ? $_GET['FechaFin'] : '20240101';
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
	
	$query = "SELECT * FROM FUN_OBTENER_FACTURAS_INDICADORES_INTERNOS ($iEstatus
						, '$fechaIni'
						, '$fechaFin'
						, $rowsperpage
						, $page
						, '$orderby'
						, '$ordertype'
						, '$columns')";
				
	
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
	
	$id=0;

	//CONEXIÓN A SQL SERVER
	$CDB = obtenConexion(BDPERSONALSQLSERVER);
	$CCSS = $CDB['conexion'];
	$con = new OdbcConnection($CCSS);
	$con->open();
	$cmdss = $con->createCommand();
	
	foreach($matriz as $fila) 
	{	
		$numemp = $fila['numemp'];
		$importe = str_replace(".", "", $fila['reembolsosinisr']); 
		
		// CALCULA ISR
		try
		{
			$cmdss->setCommandText("{CALL proc_generar_isr_colegiaturas $numemp, '<Root><r e=\"$numemp\" i=\"$importe\"></r></Root>'}");
			$ds = $cmdss->executeDataSet();
			
		}
		catch(exception $ex)
		{
			$mensaje="Ocurrió un error al intentar conectarse a la base de datos server";
			$estado=-2;
		}

		$isr_colegiatura = number_format($ds[0]['isr_colegiatura'] / 100, 2);
		//CALCULA ISR

		$respuesta->rows[$id]['id']=$id;				
		$respuesta->rows[$id]['cell']=
			array(
				$fila['numemp']
				,$fila['nombre']
				// ,$isr_colegiatura
				,'$'.number_format(($fila['reembolsosinisr']+$isr_colegiatura ),2)
				,'$'.number_format($fila['reembolsosinisr'],2)
				,$fila['region']
				,$fila['folio_fiscal']
				,$fila['nom_escolaridad']
				,$fila['nom_analista']
				,$fila['fecha_solicitud'] //($fila['fecha_solicitud'] == '') ? '' : date("d/m/Y", strtotime($fila['fecha_solicitud']))	
				,$fila['fecha_autoriza_gerente']	
				,($fila['fecha_reviso_analista'] == "01/01/1900") ? '' : $fila['fecha_reviso_analista']
				,$fila['fecha_pago']
				,$fila['nom_estatus']
				,$fila['dias_respuesta']
				,($fila['anio'] == 1900) ? '' : $fila['anio']
				,$fila['mes']
				,($fila['numcentro_analista'] == 0) ? '' : $fila['numcentro_analista']. ' ' .$fila['nomcentro_analista']
				,$fila['mes_rev_analista']
				,$fila['anio_rev_analista']
			);

		$id++;
	}	
	
	$con->close(); //CIERRA CONEXIÓN SERVER

	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}

} catch(Exception $ex){
	echo "Error: Ocurrió un error al intentar conectar con la base de datos.";
}

?>