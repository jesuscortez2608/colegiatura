<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');


session_name("Session-Colegiaturas");
session_start();
$Session = $_GET['session_name'];

require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';

$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);

$dFecha = isset($_GET['dFecha']) ? $_GET['dFecha'] : '';
$iTipoDato = isset($_GET['iTipoDato']) ? $_GET['iTipoDato'] : 0;
$iDato = isset($_GET['iDato']) ? $_GET['iDato'] : 0;

if($datos_conexion["estado"] != 0){
	echo "Error en la conexion ".$datos_conexion["mensaje"];
	exit();
}

$cadena_conexion = $datos_conexion["conexion"];

try{
	$con = new OdbcConnection($cadena_conexion);
	$con->open();
	
	$cmd = $con->createCommand();
	
	$query = "SELECT * FROM FUN_CALCULA_INDICADORES_INTERNOS ($iTipoDato
						,  $iDato 
						,  '$dFecha')";
				
	
	// echo "<pre>";
	// print_r($query);
	// echo "</pre>";
	// exit();
	
	
	$cmd->setCommandText($query);
	$matriz = $cmd->executeDataSet();
	$con->close();
	
	$respuesta = new stdClass();
	
	$id=0;
	
	foreach($matriz as $fila) 
	{			
		$per_cumplimiento_mes = isset($fila['per_cumplimiento_mes']) ? (substr($fila['per_cumplimiento_mes'], -3) === '.00' ? substr($fila['per_cumplimiento_mes'], 0, -3) . '%' : $fila['per_cumplimiento_mes'] . '%') : '';
		$per_eficiencia_mes = isset($fila['per_eficiencia_mes']) ? (substr($fila['per_eficiencia_mes'], -3) === '.00' ? substr($fila['per_eficiencia_mes'], 0, -3) . '%' : $fila['per_eficiencia_mes'] . '%') : '';
		$per_cumpli_efic_mes = isset($fila['per_cumpli_efic_mes']) ? (substr($fila['per_cumpli_efic_mes'], -3) === '.00' ? substr($fila['per_cumpli_efic_mes'], 0, -3) . '%' : $fila['per_cumpli_efic_mes'] . '%') : '';

		$per_cumplimiento_acum = isset($fila['per_cumplimiento_acum']) ? (substr($fila['per_cumplimiento_acum'], -3) === '.00' ? substr($fila['per_cumplimiento_acum'], 0, -3) . '%' : $fila['per_cumplimiento_acum'] . '%') : '';
		$per_eficiencia_acum = isset($fila['per_eficiencia_acum']) ? (substr($fila['per_eficiencia_acum'], -3) === '.00' ? substr($fila['per_eficiencia_acum'], 0, -3) . '%' : $fila['per_eficiencia_acum'] . '%') : '';
		$per_cumpli_efic_acum = isset($fila['per_cumpli_efic_acum']) ? (substr($fila['per_cumpli_efic_acum'], -3) === '.00' ? substr($fila['per_cumpli_efic_acum'], 0, -3) . '%' : $fila['per_cumpli_efic_acum'] . '%') : '';

		$per_cumplimiento = isset($fila['per_cumplimiento_movil']) ? (substr($fila['per_cumplimiento_movil'], -3) === '.00' ? substr($fila['per_cumplimiento_movil'], 0, -3) . '%' : $fila['per_cumplimiento_movil'] . '%') : '';
		$per_eficiencia = isset($fila['per_eficiencia_movil']) ? (substr($fila['per_eficiencia_movil'], -3) === '.00' ? substr($fila['per_eficiencia_movil'], 0, -3) . '%' : $fila['per_eficiencia_movil'] . '%') : '';
		$per_cumplim_eficiencia = isset($fila['per_cumpli_efic_movil']) ? (substr($fila['per_cumpli_efic_movil'], -3) === '.00' ? substr($fila['per_cumpli_efic_movil'], 0, -3) . '%' : $fila['per_cumpli_efic_movil'] . '%') : '';
		
		$respuesta->rows[$id]['cell']=
			array(
				$fila['nombre']
			   ,$fila['anio']
			   ,$fila['mes']
			   ,number_format($fila['dias_revision_mes'], 0, '.', ',')
			   ,number_format($fila['solicitudes_mes'], 0, '.', ',')
			   ,$fila['meta_mes']
			   ,$fila['tiempo_promedio_mes']
			   ,$per_cumplimiento_mes
			   ,number_format($fila['rev_tiempo_mes'], 0, '.', ',')
			   ,($fila['eficiencia_mes']) ? $fila['eficiencia_mes'].'%' : ''
			   ,$per_eficiencia_mes
			   ,$per_cumpli_efic_mes

			   ,number_format($fila['dias_revision_acum'], 0, '.', ',')
			   ,number_format($fila['solicitudes_acum'], 0, '.', ',')
			   ,$fila['meta_acum']
			   ,$fila['tiempo_promedio_acum']
			   ,$per_cumplimiento_acum 
			   ,number_format($fila['rev_tiempo_acum'], 0, '.', ',')
			   ,($fila['eficiencia_acum']) ? $fila['eficiencia_acum'].'%' : ''
			   ,$per_eficiencia_acum 
			   ,$per_cumpli_efic_acum

			   ,number_format($fila['dias_revision_movil'], 0, '.', ',')
			   ,number_format($fila['solicitudes_movil'], 0, '.', ',')
			   ,$fila['meta_movil']
			   ,$fila['tiempo_promedio_movil']
			   ,$per_cumplimiento 
			   ,number_format($fila['rev_tiempo_movil'], 0, '.', ',')
			   ,($fila['eficiencia_movil']) ? $fila['eficiencia_movil'].'%' : ''
			   ,$per_eficiencia
			   ,$per_cumplim_eficiencia
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