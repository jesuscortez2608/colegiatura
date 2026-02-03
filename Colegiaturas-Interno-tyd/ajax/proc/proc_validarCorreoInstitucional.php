<?php

    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');

    session_name("Session-Colegiaturas"); 
    session_start();
    $Session = $_GET['session_name'];

    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
    $num_empleado = isset($_GET['num_empleado']) ? $_GET['num_empleado'] : $_SESSION[$Session]['USUARIO']['num_empleado'];
    
    $respuesta = new stdClass();

    $datos_conexion = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);

    if ($datos_conexion["estado"] != 0) {
        echo "Error en la conexion " . $datos_conexion["mensaje"];
        exit();
    }
    
    $cadena_conexion = $datos_conexion["conexion"];
    try{
        $con = new OdbcConnection($cadena_conexion);
        $con->open();
        
        $cmd = $con->createCommand();
        
        $query = "SELECT * FROM FUN_CONSULTAR_CORREO_COLABORADOR_GERENTE($num_empleado, 1)";
        
        // echo "<pre>";
        // print_r($query);
        // echo "</pre>";
        // exit();        
        
        $cmd->setCommandText($query);
        $matriz = $cmd->executeDataSet();
        
        // ENVIAMOS CORREO
        $respuesta = $matriz[0]; 

    } catch (Exception $ex) {
        echo "Error: Ocurrió un error al intentar conectar con la base de datos.";
    }


    try {
        echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>