<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	require_once '../../../utilidadesweb/librerias/encode/encoding.php'; // $_POST['param'] = encodeToIso($_POST['param']); $descripcion = encodeToUtf8($fila['descripcion']);
    //-------------------------------------------------------------------------
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
	
	$iEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';	
  	
	$estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
    $respuesta = new stdClass();
    $json = new stdClass();
	
    if($estado != 0)
    {
         $json->estado = $estado;
         $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_gridEscolaridad.txt";
    } else {
			
            try
            {				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
                $cmd = $con->createCommand();
				//echo("{CALL fun_listado_beneficiarios_estudios( $iEmpleado)}");
				//exit();
                $cmd->setCommandText("{CALL fun_listado_beneficiarios_estudios($iEmpleado)}");
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
						$fila['idconfiguracion'],
						$fila['ibeneficiario'],
						$fila['nombrebeneficiario'],
						$fila['iparentesco'],
						$fila['parentesco'],
						$fila['iescuela'],
						$fila['rfc_escuela'],
						$fila['nomescuela'],
						$fila['iescolaridad'],
						$fila['escolaridad'],
						$fila['icarrera'],
						$fila['carrera'],
						$fila['icicloescolar'],
						$fila['cicloescolar'],
						$fila['igradoescolar'],
						$fila['gradoescolar'],
						$fila['fecharegistro'],
						$fila['tipo_beneficiario']
						//utf8_encode($fila['des_escolaridad']
					);					
                    $i++;
                }

            }
            catch(exception $ex)
            {
                $json->mensaje = $ex->getMessage();
                $json->estado=-2;
            }
    }
		
	try {
        echo json_encode($respuesta);
	} catch (\Throwable $th) {
		echo 'Error en la codificación JSON: ';
	}
	
 ?>