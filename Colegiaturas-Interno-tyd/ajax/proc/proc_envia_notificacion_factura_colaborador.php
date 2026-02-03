<?php

    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');

    session_name("Session-Colegiaturas"); 
    session_start();
    $Session = $_GET['session_name'];

    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    require_once 'proc_configuracion_envio_correo.php';
	
    $num_empleado = isset($_GET['num_empleado']) ? $_GET['num_empleado'] : $_SESSION[$Session]['USUARIO']['num_empleado'];
    
    $json = new stdClass();
    $enviarCorreo = new EnvioCorreoClass();

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

        $query = "SELECT rcorreo FROM FUN_CONSULTAR_CORREO_COLABORADOR_GERENTE($num_empleado, 1)";
        
        $cmd->setCommandText($query);
        $matriz = $cmd->executeDataSet();

        // ENVIAMOS CORREO
        $correo = $matriz[0][0];        
        
        //CREAMOS CUERPO DEL MENSAJE EN HTML
        $asunto = 'Factura de colegiaturas en estatus aclaración';
        $mensaje = '<body> Colaborador, cuenta con factura de colegiaturas en estatus aclaración:';
        $mensaje .= '<ol><li>Ingresa a seguimiento de Facturas Electrónicas de Colaborador</li>';
        $mensaje .= '<li>Elige estatus aclaración</li><li>Selecciona factura</li>';
        $mensaje .= '<li>Da clic en el icono <b>"Ver aclaraciones"</b></li></ol>';
        $mensaje .= '<br><br><br><br><br><br><br>Correo enviado de forma automática, favor de no responder.</body';
  
        $array = $enviarCorreo->enviarCorreo($asunto, $correo, $mensaje);
       
        $resp = $array[0]['response'];

        [$estatus, $msgEstatus] = explode(' ', $resp, 3);       

    } catch (Exception $ex) {
        $msgEstatus = "Error: Ocurrió un error al intentar conectar con la base de datos.";
        $msgDev = $ex->getMessage();
        $estatus = -2;
        error_log(date("d M Y H:i:s a")." -> Error: $estatus Tipo: $msgDev   \n",3,"log".date('d-m-Y')."_proc_envia_notificacion_factura_colaborador.txt");
    }


    try {
        $json->estatus = $estatus;
        $json->mensaje = $msgEstatus;
        echo json_encode($json,JSON_UNESCAPED_UNICODE);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>