<?php
header("Content-type:text/html;charset=utf-8");
date_default_timezone_set('America/Denver');
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
    //-------------------------------------------------------------------------

    $CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $estado = $CDB['estado'];  
    $mensaje = $CDB['mensaje'];
	$iNumEmp = isset($_GET['iNumEmp']) ? $_GET['iNumEmp'] : 0;
	$iSuplente = isset($_GET['iSuplente']) ? $_GET['iSuplente'] : 0;
	$iIndefinido = isset($_GET['iIndefinido']) ? $_GET['iIndefinido'] : 2;
	$dFechaIni = isset($_GET['dFechaIni']) ? $_GET['dFechaIni'] : '19000101';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '19000101';
    $respuesta = new stdClass();
         $json = new stdClass();
	
    if($estado != 0)
    {
         $json->estado = $estado;
         $json->mensaje = date("g:i:s a")." -> Error al conectar BDPERSONALPOSTGRESQLVERSIONNUEVA ver -> log".date('d-m-Y')."_json_fun_obtener_bitacora_suplentes.txt";
    } else {
			
            try
            {
				
                $con = new OdbcConnection($CDB['conexion']);
                $con->open();
                $cmd = $con->createCommand();
				// print_r("fun_obtener_bitacora_suplentes($iNumEmp,$iSuplente,$iIndefinido,'$dFechaIni','$dFechaFin' )");
				// exit();
                $cmd->setCommandText("{CALL fun_obtener_bitacora_suplentes($iNumEmp,$iSuplente,$iIndefinido,'$dFechaIni','$dFechaFin' ) }");
                $ds = $cmd->executeDataSet();
                $con->close();
                $i=0;
                $json->estado = 0;
                $json->mensaje = "OK";
                $json->datos = array();
                $i = 0;
				// '<font color="#00A400"><b>&#8730;</b></font>',
                foreach ($ds as $fila)
                {
					$respuesta->rows[$i]['id']=$i;
					if ($fila['fecha_baja']=='19000101'){						
						$Fechabaja='';
					}else{
						$Fechabaja=$fila['fecha_baja'];
					}
					if(trim($fila['opc_indefinido'])==1)
					{
					
						$respuesta->rows[$i]['cell']=array(0,
						$fila['idu_id'],
						trim($fila['idu_empleado']),
						trim($fila['idu_empleado']).' '.$fila['nom_empleado'],
						trim($fila['idu_centro']).' '.trim($fila['nom_centro']),
						trim($fila['idu_suplente']),
						trim($fila['idu_suplente']).' '.trim($fila['nom_suplente']),
						trim($fila['idu_centro_suplenete']).' '.trim($fila['nom_centro_suplente']),
						trim($fila['idu_empleado_registro']).' '.trim($fila['nom_empleado_registro']),
						trim($fila['fec_registro']),
						trim($fila['fec_inicial']),
						trim($fila['fec_final']),
						trim($fila['opc_indefinido']),
						'<font color="#00A400" size="4"><b>&#8730;</b></font>',
						$Fechabaja,
						trim($fila['opc_cancelado']),
						//trim($fila['nom_indefinido']),
						0);
					}
					else					
					{
						$respuesta->rows[$i]['cell']=array(0,
						$fila['idu_id'],
						trim($fila['idu_empleado']),
						trim($fila['idu_empleado']).' '.$fila['nom_empleado'],
						trim($fila['idu_centro']).' '.trim($fila['nom_centro']),
						trim($fila['idu_suplente']),
						trim($fila['idu_suplente']).' '.trim($fila['nom_suplente']),
						trim($fila['idu_centro_suplenete']).' '.trim($fila['nom_centro_suplente']),
						trim($fila['idu_empleado_registro']).' '.trim($fila['nom_empleado_registro']),
						trim($fila['fec_registro']),
						trim($fila['fec_inicial']),
						trim($fila['fec_final']),
						trim($fila['opc_indefinido']),
						trim($fila['nom_indefinido']),
						$Fechabaja,
						trim($fila['opc_cancelado']),
						//'<font color="#FF0000" size="4"><b>X</b></font>',
						0);
					}
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