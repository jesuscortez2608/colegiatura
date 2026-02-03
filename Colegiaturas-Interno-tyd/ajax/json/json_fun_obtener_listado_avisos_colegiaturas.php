<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');

session_name("Session-Colegiaturas"); 
session_start();
$Session = $_POST['session_name'];

require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
require_once '../../../utilidadesweb/librerias/encode/encoding.php';

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
	$query = utf8_decode("SELECT * FROM fun_obtener_listado_avisos_colegiaturas()");

	$cmd->setCommandText($query);
	$ds = $cmd->executeDataSet();
	$con->close();

	$id=0;
	$respuesta = new stdClass();
	foreach($ds as $fila) {
		$respuesta->rows[$id]['id']=$id;
		$respuesta->rows[$id]['cell']['idu_aviso'] = $fila['idu_aviso'];
		$respuesta->rows[$id]['cell']['des_aviso'] = $fila['des_aviso'];
		$respuesta->rows[$id]['cell']['idu_opcion'] = $fila['idu_opcion'];
		$respuesta->rows[$id]['cell']['des_opcion'] = $fila['des_opcion'];
		$respuesta->rows[$id]['cell']['opcion'] = /*$fila['idu_opcion'].'. '.*/ trim($fila['des_opcion'] == "" ? 'TODAS LAS OPCIONES': strtoupper($fila['des_opcion']));
		if($fila['indefinido']==0)
		{
			$respuesta->rows[$id]['cell']['fec_ini'] = date("d/m/Y", strtotime($fila['fec_ini']));		
			$respuesta->rows[$id]['cell']['fec_fin'] = date("d/m/Y", strtotime($fila['fec_fin']));		
		}
		else
		{
			$respuesta->rows[$id]['cell']['fec_ini'] = '';		
			$respuesta->rows[$id]['cell']['fec_fin'] = '';
		
		}
		// $respuesta->rows[$id]['cell']->fec_ini = date("d/m/Y", strtotime($fila['fec_ini']))=='01/01/1900'?' ':date("d/m/Y", strtotime($fila['fec_ini']));;		
		// $respuesta->rows[$id]['cell']->fec_fin = date("d/m/Y", strtotime($fila['fec_fin'])) == '01/01/1900'?' ':date("d/m/Y", strtotime($fila['fec_fin']));
		$respuesta->rows[$id]['cell']['indefinido'] = $fila['indefinido'];
		$respuesta->rows[$id]['cell']['empleado_capturo'] = $fila['empleado_capturo'];
		$respuesta->rows[$id]['cell']['empleado_capturo_nombre'] = $fila['empleado_capturo']." ". $fila['nom_empleado'];
		
		$id++;
	}
	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
} catch (Exception $ex) {
	echo "Error: Ocurrió un error al conectar a la base de datos";
}
