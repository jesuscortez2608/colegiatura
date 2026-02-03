<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
	
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $iEmpleado = isset($_GET['iNumEmp']) ? $_GET['iNumEmp'] : 0;
	$iCentro = isset($_POST['iCentro']) ? $_POST['iCentro'] : 0;
	$iPuesto = isset($_POST['iPuesto']) ? $_POST['iPuesto'] : 0;
	$iSeccion = isset($_POST['iSeccion']) ? $_POST['iSeccion'] : 0;
	$iBeneficiario = isset($_GET['iBeneficiario']) ? $_GET['iBeneficiario'] : 0;
	$inicializar = isset($_GET['inicializar']) ? $_GET['inicializar'] : 0;
	
	if ($inicializar == 1) {
		
        try {
            $response = new stdClass();
            echo json_encode($response);
            exit();
        } catch (\Throwable $th) {
            echo 'Error en la codificación JSON: ';
        }
	}
	
	$estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
         $json = new stdClass();
	
    if($estado != 0)
    {
         $json->estado = $estado;
         $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_listado_beneficiarios_estudios.txt";
    } else {
			
            try
            {
				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
                $cmd = $con->createCommand();
                $cmd->setCommandText("{CALL fun_obtener_listado_beneficiarios_estudios($iEmpleado, $iCentro, $iPuesto, $iSeccion, $iBeneficiario)}");
                $ds = $cmd->executeDataSet();
                $con->close();
                $i=0;
                $json->estado = 0;
                $json->mensaje = "OK";
                $json->datos = array();
                $i = 0;
                foreach ($ds as $fila)
                {
					$respuesta->rows[$i]['cell']=array(
						$fila['idu_empleado'],
						encodeToUtf8($fila['idu_beneficiario']),
						$fila['fec_registro'],
						$fila['por_descuento'],
						$fila['idu_escuela'],
						encodeToUtf8($fila['nom_rfc_escuela']),
						encodeToUtf8($fila['nom_nombre_escuela']),
						$fila['idu_escolaridad'],
						encodeToUtf8($fila['des_escolaridad'])
					);
                    $i++;
                }

            }
            catch(exception $ex)
            {
                $json->mensaje = "Ocurrió un problema al intentar conectar con la base de datos json_fun_obtener_listado_beneficiarios_estudios";
                $json->estado=-2;
            }
    }
		
    try {
        echo json_encode($respuesta);
    } catch (\Throwable $th) {
        echo 'Error en la codificación JSON: ';
    }
	
 ?>