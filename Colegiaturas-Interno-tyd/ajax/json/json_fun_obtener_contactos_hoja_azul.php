<?php

/*ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);*/
header("X-Frame-Options: SAMEORIGIN");
header("X-XSS-Protection: 1; mode=block");
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');

session_name("Session-Colegiaturas"); 
session_start();
$Session = $_POST['session_name'];
require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
require_once '../../../utilidadesweb/librerias/sanitizer/Post.php';
//require_once '../../../utilidadesweb/librerias/sanitizer/Session.php';

$post = new Post();
$datos_conexion = obtenConexion(BDHOJADEVIDASQL);


$iOpcion = $post->exist("iOpcion") ? $post->__get("iOpcion") : 0; // Esta opcion se manda de la Captura de Facturas por Personal Admon
//$iOpcion = isset($_POST['iOpcion']) ? $_POST['iOpcion'] : 0; // Esta opcion se manda de la Captura de Facturas por Personal Admon
//, si es 1 el $iEmpleado lo toma del parametro que se envia por POST si es 0 toma el usuario de la SESSION

if ($iOpcion < 1){
	$iEmpleado = ($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
} else {
	$iEmpleado = $post->exist("iColaborador") ? $post->__get("iColaborador") : 0;
	//$iEmpleado = ($_POST['iColaborador']) ? $_POST['iColaborador'] : 0;
}


if ($datos_conexion["estado"] != 0) {
	echo "Error en la conexion " . $datos_conexion["mensaje"];
	exit();
}

$cadena_conexion = $datos_conexion["conexion"];

try {
	$con = new OdbcConnection($cadena_conexion);
	$con->open();
	
	$cmd = $con->createCommand();
		
	//$query = "SELECT numemp, importe, isr, total FROM FUN_OBTENER_INCENTIVOS_ADMIN()";	
	//$query = encodeToUtf8("SELECT bNumemp,iClave,iNumerofamiliares,iParentesco,sApellidopaterno,sApellidomaterno,sNombre,sFechanacimiento,sEscolaridad, sEmpresa,sOcupacion,sTelefonoempresa,sTelefonocasa,bNumeroelp,dFechacaptura,iKeyx,iPersonasdependientes FROM fun_obtener_contactos_hoja_azul ($iEmpleado)");
	//$query = encodeToUtf8("{CALL PROC_OBTENER_CONTACTOS_HOJA_AZUL $iEmpleado}");

	$query = "{CALL PROC_OBTENER_CONTACTOS_HOJA_AZUL $iEmpleado}";
	$cmd->setCommandText($query);
	$matriz = $cmd->executeDataSet();

	$con->close();

	$respuesta = new stdClass();
	
	//if ($matriz[0]!=null) {
		 //echo('Trae Datos');
		// exit();
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
		$cnt = 0;
		$xml = '<Root>';

		foreach($matriz as $fila) 
		{
			$numemp=$fila['bnumemp'];
			$clave=$fila['iclave'];
			$numerofamiliares = $fila['inumerofamiliares'];
			$parentesco = $fila['iparentesco'];
			$apellidopaterno= $fila['sapellidopaterno']; //trim(strtoupper($fila['sapellidopaterno']));
			$apellidomaterno= $fila['sapellidomaterno']; //trim(strtoupper($fila['sapellidomaterno']));
			$nombre = $fila['snombre']; //trim(strtoupper($fila['snombre']));
			//$nombre = $fila['snombre']; //trim(strtoupper($fila['snombre']));
			$fechanacimiento = $fila['sfechanacimiento'];
			$escolaridad=$fila['sescolaridad'];
			$empresa= trim($fila['sempresa']);
			$ocupacion = $fila['socupacion']; //trim($fila['socupacion']);
			$telefonoempresa = $fila['stelefonoempresa'];
			$telefonocasa=$fila['stelefonocasa'];
			$numeroelp=$fila['bnumeroelp'];
			$fechacaptura = $fila['dfechacaptura'];
			$keyx = $fila['idu_familiar'];
			$personasdependientes = $fila['ipersonasdependientes'];
	
			$nombre=str_replace(['Á', 'á'], ['A', 'a'],$nombre);	
			$nombre=str_replace(['É', 'é'], ['E', 'e'],$nombre);
			$nombre=str_replace(['Í', 'í'], ['I', 'i'],$nombre);
			$nombre=str_replace(['Ó', 'ó'], ['O', 'o'],$nombre);	
			$nombre=str_replace(['Ú', 'ú'], ['U', 'u'],$nombre);

			$apellidomaterno=str_replace(['É', 'é'], ['E', 'e'],$apellidomaterno);	
			$apellidomaterno=str_replace(['É', 'é'], ['E', 'e'],$apellidomaterno);
			$apellidomaterno=str_replace(['Í', 'í'], ['I', 'i'],$apellidomaterno);
			$apellidomaterno=str_replace(['Ó', 'ó'], ['O', 'o'],$apellidomaterno);	
			$apellidomaterno=str_replace(['Ú', 'ú'], ['U', 'u'],$apellidomaterno);

			$apellidopaterno=str_replace(['É', 'é'], ['E', 'e'],$apellidopaterno);	
			$apellidopaterno=str_replace(['É', 'é'], ['E', 'e'],$apellidopaterno);
			$apellidopaterno=str_replace(['Í', 'í'], ['I', 'i'],$apellidopaterno);
			$apellidopaterno=str_replace(['Ó', 'ó'], ['O', 'o'],$apellidopaterno);	
			$apellidopaterno=str_replace(['Ú', 'ú'], ['U', 'u'],$apellidopaterno);


			$empresa=str_replace(['É', 'é'], ['E', 'e'],$empresa);	
			$empresa=str_replace(['É', 'é'], ['E', 'e'],$empresa);
			$empresa=str_replace(['Í', 'í'], ['I', 'i'],$empresa);
			$empresa=str_replace(['Ó', 'ó'], ['O', 'o'],$empresa);	
			$empresa=str_replace(['Ú', 'ú'], ['U', 'u'],$empresa);
			$empresa = !empty($empresa) ? $empresa : '';
			
			$ocupacion=str_replace(['É', 'é'], ['E', 'e'],$ocupacion);	
			$ocupacion=str_replace(['É', 'é'], ['E', 'e'],$ocupacion);
			$ocupacion=str_replace(['Í', 'í'], ['I', 'i'],$ocupacion);
			$ocupacion=str_replace(['Ó', 'ó'], ['O', 'o'],$ocupacion);	
			$ocupacion=str_replace(['Ú', 'ú'], ['U', 'u'],$ocupacion);

			$escolaridad=str_replace(['É', 'é'], ['E', 'e'],$escolaridad);	
			$escolaridad=str_replace(['É', 'é'], ['E', 'e'],$escolaridad);
			$escolaridad=str_replace(['Í', 'í'], ['I', 'i'],$escolaridad);
			$escolaridad=str_replace(['Ó', 'ó'], ['O', 'o'],$escolaridad);	
			$escolaridad=str_replace(['Ú', 'ú'], ['U', 'u'],$escolaridad);


			$nombre = str_replace("Ñ","#",$nombre);
			$apellidopaterno=str_replace("Ñ","#",$apellidopaterno);
			$apellidomaterno=str_replace("Ñ","#",$apellidomaterno);
			$empresa=str_replace("Ñ","#",$empresa);
			$ocupacion = str_replace("Ñ","#",$ocupacion);	
			$escolaridad=str_replace("Ñ","#",$escolaridad);

			$xml .= "
			<r>
				<a>$numemp</a>
				<b>$clave</b>
				<c>$numerofamiliares</c>
				<d>$parentesco</d>
				<e>$apellidopaterno</e>
				<f>$apellidomaterno</f>
				<g>$nombre</g>
				<h>$fechanacimiento</h>
				<i>$escolaridad</i>
				<j>$empresa</j>
				<k>$ocupacion</k>
				<l>$telefonoempresa</l>
				<m>$telefonocasa</m>
				<n>$numeroelp</n>
				<o>$fechacaptura</o>
				<p>$keyx</p>
				<q>$personasdependientes</q>
			</r>";
		}
		$xml.= '</Root>';
		

		$query2="SELECT * FROM fun_actualizar_contactos_hoja_azul($iEmpleado::INTEGER,'$xml'::XML)";

		$cmd2->setCommandText($query2);
		$ds = $cmd2->executeDataSet();	
		
		
		$con->close();
		$respuesta->estado = 0;
		$respuesta->mensaje = "Beneficiarios Actualizados";
		$respuesta->movimientos = $cnt;
		
		echo json_encode($respuesta);
} catch (Exception $ex) {

	var_dump($ex);

	$respuesta->estado = -1;
	$respuesta->mensaje = "Ocurrio un problema al consultar la informacion, favor de comunicarte a Mesa de Ayuda";
	error_log(date("g:i:s a")." -> Error: ". $estado." Tipo: ".$ex->getMessage()." \n",3,"log".date('d-m-Y')."_json_fun_obtener_contactos_hoja_azul.txt");
	$respuesta->movimientos = -1;
	
	echo json_encode($respuesta);
}
?>