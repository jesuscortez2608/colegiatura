<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');

session_name("Session-Colegiaturas"); 
session_start();
$Session = $_POST['session_name'];

require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);


$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);

$_GETS = filter_input_array(INPUT_GET,FILTER_SANITIZE_SPECIAL_CHARS);

$rowsperpage = isset($_GET['rows']) ? $_GETS['rows'] : 0;
$opc_busqueda = isset($_GET['opc_busqueda']) ? $_GETS['opc_busqueda'] : 1;
$nBusqueda = isset($_GET['nBusqueda']) ? $_GETS['nBusqueda'] : 0;
$nFiltro = isset($_GET['nFiltro']) ? $_GETS['nFiltro'] : 0;
$page = isset($_GET['page']) ? $_GETS['page'] : 0;
$orderby = isset($_GET['sidx']) ? $_GETS['sidx'] : '';
$ordertype = isset($_GET['sord']) ? $_GETS['sord'] : '';
// $columns = 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento, numempregistro, nomempleadoregistro, des_comentario';
$columns = 'numemp, nomempleado, centro, nomcentro, puesto,nompuesto, seccion ,nomseccion, idu_parentesco, parentesco, idu_estudio, estudio, por_descuento, des_comentario';

if ($datos_conexion["estado"] != 0) {
	echo "Error en la conexion " . $datos_conexion["mensaje"];
	exit();
}

$cadena_conexion = $datos_conexion["conexion"];

try {
	$con = new OdbcConnection($cadena_conexion);
	$con->open();
	
	$cmd = $con->createCommand();
	$query = "SELECT records,
		page,
		pages,
		id,
		numemp,
		nomempleado,
		centro,
		nomcentro,
		puesto,
		nompuesto,
		seccion,
		nomseccion,
		idu_parentesco,
		parentesco,
		idu_estudio,
		estudio,
		por_descuento,
		des_comentario
		FROM fun_obtener_listado_configuraciones_descuentos(
		 $opc_busqueda::integer
		, $nBusqueda::integer
		, $nFiltro::integer
		,$rowsperpage::integer
		, $page::integer			
		, '$orderby'
		, '$ordertype'
		, '$columns')";
		

//numempregistro,
// nomempleadoregistro,


	// echo "<pre>";
	// print_r($query);
	// echo "</pre>";
	// exit();
	$cmd->setCommandText($query);
	$ds = $cmd->executeDataSet();
	$_SESSION[$Session]["imprimirpdf"]=$ds;
	//$_SESSION[$Session]["imprimirjesus2"]=$ds;
	//var_dump($_SESSION[$Session]["imprimirpdf"]);
	//exit();
	//$_SESSION[$Session]["imprimirjesus2"]=$ds;
	$respuesta = new stdClass();
	$respuesta->page = $ds[0]['page'];
	$respuesta->total = $ds[0]['pages'];
	$respuesta->records = $ds[0]['records'];
	
	$id=0;
	foreach($ds as $fila) {
		$respuesta->rows[$id]['id']=$id;
		$respuesta->rows[$id]['cell']=array($fila['numemp']
										,$fila['nomempleado']
										,$fila['centro']
										,$fila['nomcentro']
										,$fila['puesto']
										,$fila['nompuesto']
										,$fila['seccion']
										,$fila['nomseccion']
										,$fila['idu_parentesco']
										,$fila['parentesco']
										,$fila['idu_estudio']
										,$fila['estudio']
										,$fila['por_descuento']
										,$fila['numempregistro'].' '.encodeToUtf8(trim($fila['nomempleadoregistro']))
										,encodeToIso($fila['des_comentario']));
		$id++;
	}
		
	try {
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
} catch (Exception $ex) {
	echo "Error: Ocurrió un error al intentar conectarse a la base de datos";
}
