<?php	
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_POST['session_name'];
		
    //require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    //require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    
	$iUsuario = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';  
	$nombre=$_SESSION[$Session]['USUARIO']['nom_empleado'] . " " . $_SESSION[$Session]['USUARIO']['nom_apellidopaterno'] . " " . $_SESSION[$Session]['USUARIO']['nom_apellidomaterno'];	
	$num_centro = isset($_SESSION[$Session]["USUARIO"]['num_centro'])?$_SESSION[$Session]['USUARIO']['num_centro']:'';  
	$nom_centro = isset($_SESSION[$Session]["USUARIO"]['nomcentro'])?$_SESSION[$Session]['USUARIO']['nomcentro']:'';  
	$num_puesto = isset($_SESSION[$Session]["USUARIO"]['num_puesto'])?$_SESSION[$Session]['USUARIO']['num_puesto']:'';  
	$nom_puesto = isset($_SESSION[$Session]["USUARIO"]['nom_puesto'])?$_SESSION[$Session]['USUARIO']['nom_puesto']:'';  
	$num_seccion = isset($_SESSION[$Session]["USUARIO"]['num_seccion'])?$_SESSION[$Session]['USUARIO']['num_seccion']:''; 
	$json = new stdClass(); 	
	try
	{
		$json->usuario = $iUsuario;		
		$json->nombre = $nombre;
		$json->num_centro = $num_centro;
		$json->nom_centro = $nom_centro;
		$json->num_puesto = $num_puesto;
		$json->nom_puesto = $nom_puesto;
		$json->num_seccion = $num_seccion;
	}
	catch(exception $ex)
	{
		$mensaje="Ocurrió un error al intentar conectar con la base de datos.";
		$estado=-2;
	}	
		
	try {
	
		echo json_encode($json);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
?>