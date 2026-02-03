<?php
	header("Content-type:text/html;charset=utf-8");
	date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = $_GET['session_name'];
	
    require_once '../../../utilidadesweb/librerias/data/odbcclient.php';
    require_once '../../../utilidadesweb/librerias/cnfg/conexiones.php';
	
	//VARIABLES DE FILTRADO.
	$iTipoDeduccion  = isset($_GET['iTipoDeduccion']) ? $_GET['iTipoDeduccion'] : 0;
	$iEmpresa  = isset($_GET['iEmpresa']) ? $_GET['iEmpresa'] : 0;
	$dFechaInicio = isset($_GET['dFechaInicio']) ? $_GET['dFechaInicio'] : '';
	$dFechaFin = isset($_GET['dFechaFin']) ? $_GET['dFechaFin'] : '';
	
	//PARAMETROS DE PAGINADO
	$iRowsPerPage = isset($_GET['rows']) ? $_GET['rows'] : 0;
	$iCurrentPage = isset($_GET['page']) ? $_GET['page'] : 0;
	$sOrderColumn = 'idu_empresa, fecha, tipo';
	$sOrderType = 'asc';
	$sColumns = '*';
	
	//VARIABLES DE CONEXION.
	$CDB = obtenConexion(BDPERSONALPOSTGRESQLVERSIONNUEVA);
    $mensaje = $CDB['mensaje'];
	$estado = $CDB['estado'];
	$json = new stdClass();
	$json->resultado=array();
	$datos = array();
	
	if($estado != 0)
	{
		$json->mensaje=$mensaje;
		$json->estado=$estado;
		echo json_encode($json);
		exit;
	}
	try
	{	
		$con = new OdbcConnection($CDB['conexion']);
		$con->open();
		$cmd = $con->createCommand();
		
		$query = "{CALL fun_obtener_reporte_acumulado_colegiaturas('$dFechaInicio', '$dFechaFin', $iTipoDeduccion, $iEmpresa, $iRowsPerPage, $iCurrentPage, '$sOrderColumn', '$sOrderType', '$sColumns')}";
		// print_r($query);
		// exit();
		$cmd->setCommandText($query);
		$ds = $cmd->executeDataSet();
		
		$con->close();
		$i = 0;
		
		$respuesta = new stdClass();
		$respuesta->page = $ds[0]['page'];
		$respuesta->total = $ds[0]['pages'];
		$respuesta->records = $ds[0]['records'];
		
		if(sizeof($ds)>1)
		{
			foreach ($ds as $fila)
			{
				$empresa = $fila['nom_empresa'];
				$fechaC = "";
				$cheques = "";
				$banamex = "";
				$invernomina = "";
				$bancomer = "";
				$bancoppel = "";
				$totalimporte = "";
				$totalprestacion = "";
				$total50 = "";
				$total60 = "";
				$total70 = "";
				$total80 = "";
				$total90 = "";
				$total100 = "";
				$totalfacturas = "";
				$totalempleados = "";
				
				if($fila['tipo']==0)
				{
					$fechaC = date("d/m/Y", strtotime($fila['fecha'])); //$fila['fecha'];
					
					$cheques = number_format($fila['cheques'],2);
					$banamex = number_format($fila['banamex'],2);
					$invernomina = number_format($fila['invernomina'],2);
					$bancomer = number_format($fila['bancomer'],2);
					$bancoppel = number_format($fila['bancoppel'],2);
					$totalimporte = number_format($fila['totalimporte'],2);
					$totalprestacion = number_format($fila['totalprestacion'],2);
					
					$total50 = number_format($fila['total50'], 0);$total51 = number_format($fila['total51'], 0);
					$total52 = number_format($fila['total52'], 0);$total53 = number_format($fila['total53'], 0);
					$total54 = number_format($fila['total54'], 0);$total55 = number_format($fila['total55'], 0);
					$total56 = number_format($fila['total56'], 0);$total57 = number_format($fila['total57'], 0);
					$total58 = number_format($fila['total58'], 0);$total59 = number_format($fila['total59'], 0);
					
					$total60 = number_format($fila['total60'], 0);$total61 = number_format($fila['total61'], 0);
					$total62 = number_format($fila['total62'], 0);$total63 = number_format($fila['total63'], 0);
					$total64 = number_format($fila['total64'], 0);$total65 = number_format($fila['total65'], 0);
					$total66 = number_format($fila['total66'], 0);$total67 = number_format($fila['total67'], 0);
					$total68 = number_format($fila['total68'], 0);$total69 = number_format($fila['total69'], 0);
					
					$total70 = number_format($fila['total70'], 0);$total71 = number_format($fila['total71'], 0);
					$total72 = number_format($fila['total72'], 0);$total73 = number_format($fila['total73'], 0);
					$total74 = number_format($fila['total74'], 0);$total75 = number_format($fila['total75'], 0);
					$total76 = number_format($fila['total76'], 0);$total77 = number_format($fila['total77'], 0);
					$total78 = number_format($fila['total78'], 0);$total79 = number_format($fila['total79'], 0);
					
					$total80 = number_format($fila['total80'], 0);$total81 = number_format($fila['total81'], 0);
					$total82 = number_format($fila['total82'], 0);$total83 = number_format($fila['total83'], 0);
					$total84 = number_format($fila['total84'], 0);$total85 = number_format($fila['total85'], 0);
					$total86 = number_format($fila['total86'], 0);$total87 = number_format($fila['total87'], 0);
					$total88 = number_format($fila['total88'], 0);$total89 = number_format($fila['total89'], 0);
					
					$total90 = number_format($fila['total90'], 0);$total91 = number_format($fila['total91'], 0);
					$total92 = number_format($fila['total92'], 0);$total93 = number_format($fila['total93'], 0);
					$total94 = number_format($fila['total94'], 0);$total95 = number_format($fila['total95'], 0);
					$total96 = number_format($fila['total96'], 0);$total97 = number_format($fila['total97'], 0);
					$total98 = number_format($fila['total98'], 0);$total99 = number_format($fila['total99'], 0);
					
					$total100 = number_format($fila['total100'], 0);
					
					$totalfacturas = number_format($fila['totalfacturas'], 0);
					$totalempleados = number_format($fila['totalempleados'], 0);
				}
				else if($fila['tipo']==1)//Total x mes
				{	
					$MesIniciales = "";
					$MesNumero = substr($fila['fecha_mes'], -2);// SACA EL NUMERO DEL MES DE LA CADENA "yyyy-mm";
					switch ($MesNumero){
						case "01":
							$MesIniciales = "ENE";
						break;
						case "02":
							$MesIniciales = "FEB";
						break;
						case "03":
							$MesIniciales = "MAR";
						break;
						case "04":
							$MesIniciales = "ABR";
						break;
						case "05":
							$MesIniciales = "MAY";
						break;
						case "06":
							$MesIniciales = "JUN";
						break;
						case "07":
							$MesIniciales = "JUL";
						break;
						case "08":
							$MesIniciales = "AGO";
						break;
						case "09":
							$MesIniciales = "SEP";
						break;
						case "10":
							$MesIniciales = "OCT";
						break;
						case "11":
							$MesIniciales = "NOV";
						break;
						case "12":
							$MesIniciales = "DIC";
						break;
					}
					$fechaC = "<b>Total Mes ".$MesIniciales."/".substr($fila['fecha_mes'], -7,4)."</b>";
				} else if ($fila['tipo']==2) {
					$fechaC="<b>TOTAL EMPRESA</b>";
				}
				else
				{
					$fechaC="<b>TOTAL GENERAL</b>";
				}
				
				if($fila['tipo'] >= 1){
					$cheques = "<b>".number_format($fila['cheques'],2)."</b>";
					$banamex = "<b>".number_format($fila['banamex'],2)."</b>";
					$invernomina = "<b>".number_format($fila['invernomina'],2)."</b>";
					$bancomer = "<b>".number_format($fila['bancomer'],2)."</b>";
					$bancoppel = "<b>".number_format($fila['bancoppel'],2)."</b>";
					$totalimporte = "<b>".number_format($fila['totalimporte'],2)."</b>";
					$totalprestacion = "<b>".number_format($fila['totalprestacion'],2)."</b>";
					
					$total50 = "<b>".number_format($fila['total50'], 0)."</b>";	$total51 = "<b>".number_format($fila['total51'], 0)."</b>";
					$total52 = "<b>".number_format($fila['total52'], 0)."</b>";	$total53 = "<b>".number_format($fila['total53'], 0)."</b>";
					$total54 = "<b>".number_format($fila['total54'], 0)."</b>";	$total55 = "<b>".number_format($fila['total55'], 0)."</b>";
					$total56 = "<b>".number_format($fila['total56'], 0)."</b>";	$total57 = "<b>".number_format($fila['total57'], 0)."</b>";
					$total58 = "<b>".number_format($fila['total58'], 0)."</b>";	$total59 = "<b>".number_format($fila['total59'], 0)."</b>";
					
					$total60 = "<b>".number_format($fila['total60'], 0)."</b>";	$total61 = "<b>".number_format($fila['total61'], 0)."</b>";
					$total62 = "<b>".number_format($fila['total62'], 0)."</b>";	$total63 = "<b>".number_format($fila['total63'], 0)."</b>";
					$total64 = "<b>".number_format($fila['total64'], 0)."</b>";	$total65 = "<b>".number_format($fila['total65'], 0)."</b>";
					$total66 = "<b>".number_format($fila['total66'], 0)."</b>";	$total67 = "<b>".number_format($fila['total67'], 0)."</b>";
					$total68 = "<b>".number_format($fila['total68'], 0)."</b>";	$total69 = "<b>".number_format($fila['total69'], 0)."</b>";
					
					$total70 = "<b>".number_format($fila['total70'], 0)."</b>";	$total71 = "<b>".number_format($fila['total71'], 0)."</b>";
					$total72 = "<b>".number_format($fila['total72'], 0)."</b>";	$total73 = "<b>".number_format($fila['total73'], 0)."</b>";
					$total74 = "<b>".number_format($fila['total74'], 0)."</b>";	$total75 = "<b>".number_format($fila['total75'], 0)."</b>";
					$total76 = "<b>".number_format($fila['total76'], 0)."</b>";	$total77 = "<b>".number_format($fila['total77'], 0)."</b>";
					$total78 = "<b>".number_format($fila['total78'], 0)."</b>";	$total79 = "<b>".number_format($fila['total79'], 0)."</b>";
					
					$total80 = "<b>".number_format($fila['total80'], 0)."</b>";	$total81 = "<b>".number_format($fila['total81'], 0)."</b>";
					$total82 = "<b>".number_format($fila['total82'], 0)."</b>";	$total83 = "<b>".number_format($fila['total83'], 0)."</b>";
					$total84 = "<b>".number_format($fila['total84'], 0)."</b>";	$total85 = "<b>".number_format($fila['total85'], 0)."</b>";
					$total86 = "<b>".number_format($fila['total86'], 0)."</b>";	$total87 = "<b>".number_format($fila['total87'], 0)."</b>";
					$total88 = "<b>".number_format($fila['total88'], 0)."</b>";	$total89 = "<b>".number_format($fila['total89'], 0)."</b>";
					
					$total90 = "<b>".number_format($fila['total90'], 0)."</b>";	$total91 = "<b>".number_format($fila['total91'], 0)."</b>";
					$total92 = "<b>".number_format($fila['total92'], 0)."</b>";	$total93 = "<b>".number_format($fila['total93'], 0)."</b>";
					$total94 = "<b>".number_format($fila['total94'], 0)."</b>";	$total95 = "<b>".number_format($fila['total95'], 0)."</b>";
					$total96 = "<b>".number_format($fila['total96'], 0)."</b>";	$total97 = "<b>".number_format($fila['total97'], 0)."</b>";
					$total98 = "<b>".number_format($fila['total98'], 0)."</b>";	$total99 = "<b>".number_format($fila['total99'], 0)."</b>";
					
					$total100 = "<b>".number_format($fila['total100'], 0)."</b>";
					
					$totalfacturas = "<b>".number_format($fila['totalfacturas'], 0)."</b>";
					$totalempleados = "<b>".number_format($fila['totalempleados'], 0)."</b>";
				}
				
				$respuesta->rows[$i]['cell'] = array($empresa,
					$fechaC,
					$cheques,
					$banamex,
					$invernomina,
					$bancomer,
					$bancoppel,
					$totalimporte,
					$totalprestacion,
					
					$total50,$total51,$total52,$total53,$total54,$total55,$total56,$total57,$total58,$total59,
					$total60,$total61,$total62,$total63,$total64,$total65,$total66,$total67,$total68,$total69,
					$total70,$total71,$total72,$total73,$total74,$total75,$total76,$total77,$total78,$total79,
					$total80,$total81,$total82,$total83,$total84,$total85,$total86,$total87,$total88,$total89,
					$total90,$total91,$total92,$total93,$total94,$total95,$total96,$total97,$total98,$total99,
					
					$total100,
					
					$totalfacturas,
					$totalempleados,
				);
				$i++;
			}
		}	
	}
	catch(exception $ex)
	{
		$mensaje = "";
		$mensaje = $ex->getMessage();
		$estado = -2;
	}
	echo json_encode($respuesta);
	
?>