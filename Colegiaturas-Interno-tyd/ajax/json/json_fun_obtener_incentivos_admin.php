<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');

session_name("Session-Colegiaturas"); 
session_start();
$Session = $_GET['session_name'];
require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);

$datos_conexion = obtenConexion(BDADMINISTRACIONPOSTGRESQL);


if ($datos_conexion["estado"] != 0) {
	echo "Error en la conexion " . $datos_conexion["mensaje"];
	exit();
}

$cadena_conexion = $datos_conexion["conexion"];

try {
	$con = new OdbcConnection($cadena_conexion);
	$con->open();
	
	$cmd = $con->createCommand();
		
	$query = "SELECT numemp, importe, isr, total FROM FUN_OBTENER_INCENTIVOS_ADMIN()";	
	
	$cmd->setCommandText($query);
	$matriz = $cmd->executeDataSet();
	
	$con->close();
	$respuesta = new stdClass();
	
//--SI NO SE HAN GENERADO INCENTIVOS EN EL SISTEMA VIEJO	
	//echo ($ds[0]!=null);
	//exit();
	$bloque = 0;
	$cnt = 0;
	$xml = '';
	$query = '';
	if ($matriz[0]!=null) {
		
		//$datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$CDB            = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
		$estado         = $CDB['estado'];
		$cadenaconexion = $CDB['conexion'];
		$mensaje        = $CDB['mensaje'];
		
		// Crear la conexión a BD 

		if($estado != 0){
			throw new Exception($mensaje);
		}	
		
		$con = new OdbcConnection($cadenaconexion);
		$con->open();
		$cmd2 = $con->createCommand();
		//$id=0;
		$bloque = 0;
		$cnt = 0;
		
		$xml = '<Root>';
		foreach($matriz as $fila) 
		{
			$empleado=$fila['numemp'];
			$importe=$fila['importe'];
			$isr = $fila['isr'];
			$total = $fila['total'];
			$xml .= "<r><e>$empleado</e><i>$importe</i><s>$isr</s><t>$total</t></r>";
			
			$cnt++;
			if ($cnt == 100) {
				$xml .= '</Root>';
				
				$bloque++;
				
				// ejecutar función con XML
				//$query2 = "SELECT fun_grabar_incentivos_administracion($bloque::INTEGER,'$xml'::XML)";
				$query = "{CALL fun_grabar_incentivos_administracion($bloque::INTEGER,'$xml'::XML)}";
				$cmd2->setCommandText("{CALL fun_grabar_incentivos_administracion($bloque::INTEGER,'$xml'::XML)}");
				//$cmd->setCommandText($query2);	
				$ds = $cmd2->executeDataSet();
				
				// Reinicio el XML
				$xml = '<Root>';
				$cnt = 0;
			}
		}
		//echo ($query2);
		//exit();
		
		if ($cnt > 0) {
			$xml .= '</Root>';
			
			$bloque++;
			
			$query = "{CALL fun_grabar_incentivos_administracion($bloque::INTEGER,'$xml'::XML)}";
			$cmd2->setCommandText("{CALL fun_grabar_incentivos_administracion($bloque::INTEGER,'$xml'::XML)}");		
			$ds = $cmd2->executeDataSet();
		}
		$con->close();
		$respuesta->estado = 0;
		$respuesta->mensaje = "Incentivos Admin en BD de Personal";
		$respuesta->movimientos = $cnt;
	}else{
		$respuesta->estado = 1;
		$respuesta->mensaje = "No se han generado los incentivos del sistema anterior";
		$respuesta->movimientos =0;	
	}

	try {
	
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}	
} catch (Exception $ex) {

	try {
		$respuesta->estado = -1;
		$respuesta->mensaje = "Error: Ocurrió un error al intentar conectarse con la base de datos, $query";
		$respuesta->movimientos = -1;
		
		echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}	
}
?>