.<?php

	header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
	$IdEmpleado =(isset($_POST['IdEmpleado']) ? $_POST['IdEmpleado'] : '');
	$FechaInicial =(isset($_POST['dFechaInicial']) ? $_POST['dFechaInicial'] : '');
	$FechaFinal =(isset($_POST['dFechaFinal']) ? $_POST['dFechaFinal'] : '');
	$IdEstatus =(isset($_POST['IdEstatus']) ? $_POST['IdEstatus'] : '');
	//Se agregan estas lineas para el regreso a Seg. Facturas Por Personal Admon.
	$dFechaIni = (isset($_POST['dFechaIni']) ? $_POST['dFechaIni'] : ''); // Se agregan estas 2 de fecha para no afectar mas funcionamiento
	$dFechaFin = (isset($_POST['dFechaFin']) ? $_POST['dFechaFin'] : ''); // Se agregan estas 2 de fecha para no afectar mas funcionamiento
	$iColaborador = (isset($_POST['iColaborador']) ? $_POST['iColaborador'] : '');
	$idRegion =(isset($_POST['idRegion']) ? $_POST['idRegion'] : '');
	$idCiudad =(isset($_POST['idCiudad']) ? $_POST['idCiudad'] : '');
	$idTipoNom =(isset($_POST['idTipoNom']) ? $_POST['idTipoNom'] : '');
?>
<!--page specific plugin styles-->


<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ui.jqgrid.css" />
<!--ace styles-->
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-responsive.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-skins.min.css" />
<!--[if lte IE 8]--> 
  <!--link rel="stylesheet" href=" <--url--><!--/plantilla/coppel/assets/css/ace-ie.min.css" /-->
<!--[endif]-->			
<!--page specific plugin scripts-->

<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />
<script type="text/javascript" src="files/js/accounting.min.js"></script>
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_aceptarRechazarFacturas.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
	
	div.itemdiv.dialogdiv::before {
		-moz-border-bottom-colors: none;
		-moz-border-left-colors: none;
		-moz-border-right-colors: none;
		-moz-border-top-colors: none;
		background-color: #ffffff;
		border-color: #ffffff;
		border-image: none;
		border-style: none;
		border-width: 0 0px;
		bottom: 0;
		content: "";
		display: none;
		left: 19px;
		max-width: 1px;
		position: absolute;
		top: 0;
		width: 1px;
	}
	
	.itemdiv.dialogdiv > .body {
		-moz-border-bottom-colors: none;
		-moz-border-left-colors: none;
		-moz-border-right-colors: none;
		-moz-border-top-colors: none;
		border-color: #dde4ed;
		border-image: none;
		border-style: solid;
		border-width: 1px 1px 1px 2px;
		margin-right: 1px;
		padding: 3px 7px 7px;
		left: -40px;
		width: 95%;
	}
	.modal-header{
		cursor: move;
	}	
</style>
<div class="form-horizontal">
	<div class="span12">	
		<div class="span6">
			<div class="control-group">	
				<label class="control-label">Colaborador:</label>			
				<div class="controls">
					<input type="text" class="span3 numbersOnly" id="txt_Numemp" maxlength="8" value="<?php echo htmlspecialchars($IdEmpleado, ENT_QUOTES, 'UTF-8'); ?>" >
					<input type="hidden" id="hid_estatus" name="hid_estatus" value="<?php echo htmlspecialchars($IdEstatus, ENT_QUOTES, 'UTF-8'); ?>"/>
					<input class="span8"   type="text" id="txt_Nombre" readonly >
				</div><br>
				<label class="control-label">Centro:</label>
				<div class="controls">
					<input type="text" class="span3" id="txt_Centro"  readonly >      
					<input type="text" class="span8" id="txt_NombreCentro" readonly>
				</div><br>
				<label class="control-label">Puesto:</label>
				<div class="controls">
					<input type="text" class="span3" id="txt_Puesto"  readonly >      
					<input type="text" class="span8" id="txt_NombrePuesto" readonly>
				</div><br>
				<div class="controls">
					<button class="btn btn-small btn-success" id="btn_Porcentaje" type="button" style="display: none;">
						<!--<i class="icon-money bigger-110">-->
						Porcentaje especial
					</button>	
				</div>
				
			</div>
		</div>
		<div class="span3">
			<div class="control-group">	
				<label class="control-label">Sueldo Mensual:</label>
					<div class="controls">	
						<input type="text" class="span10" id="txt_Sueldo" style="text-align:right;" readonly > 
					</div><br>
				<label class="control-label">Ruta Pago:</label>			
				<div class="controls">
					<input type="text" class="span10" id="txt_RutaPago" readonly>
				</div></br>
				<label class="control-label" for="txt_Fecha">Fecha Alta:</label>
				<div class="controls">
					<input type="text" id="txt_Fecha" class="span10" tabindex ="3" readonly>
				</div><br>
			</div>	
		</div>
		<div class="span3">
			<div class="control-group">	
				<label class="control-label">  Tope Anual Proporcional:</label>
					<!--<span class="lbl" > Tope Anual Proporcional:</span>-->
				<div class="controls">
					<input type="text" class="span10" id="txt_TopeAnual" style="text-align:right;" readonly >
				</div><br>
				
				<label class="control-label">Tope Mensual:</label>			
				<div class="controls">
					<input type="text" class="span10" id="txt_TopeMensual" style="text-align:right;" readonly>
				</div></br>
				<label class="control-label" for="txt_AcumuladoFacturaPagada">Acumulado Fac. Pagada:</label>
				<div class="controls">
					<input type="text" id="txt_AcumuladoFacturaPagada" class="span10" tabindex ="3" style="text-align:right;" readonly>
				</div><br>
				<div class="TopeRestante">
					<label class="control-label">Tope Anual Restante:</label>
					<div class="controls">
						<input type="text" class="span10" id="txt_TopeAnualRestante" style="text-align:right;" readonly />
					</div>
				</div><br>
				<div class="controls">
					<input class="ace ace-checkbox-2" id="ckb_Limitado" type="checkbox" disabled>
					<label class="lbl" for="ckb_Limitado"> Limitado</label>
				</div>	<br>
				<div class="controls">
					<button class="btn btn-small btn-primary" id="btn_Pagos" type="button">
						<!--<i class="icon-money bigger-110">-->
						<i class="icon-bar-chart"></i>Pagos Mensuales
					</button>	
				</div>
				
			</div>	
		</div>		
	</div>
	<hr>
	<div class="row-fluid">
		<div class="span12">
			<div class="span12">
				<input type="hidden" id="txt_FechaIni" value="<?php echo htmlspecialchars($FechaInicial, ENT_QUOTES, 'UTF-8'); ?>">
				<input type="hidden" id="txt_FechaFin"  value="<?php echo htmlspecialchars($FechaFinal, ENT_QUOTES, 'UTF-8'); ?>">
				<h5><b>F A C T U R A S</b></h5>	
				<!--<span><i class="icon-ok green"></i> Marque las facturas que desea cambiar de estado</span>	-->
			</div>
			<div id="tabs">
				<ul>
					<li><a href="#enProceso" style="font-size: 14px;">
							<!--<i class="blue icon-list bigger-110">-->
							<i class="blue icon-list-alt"></i><b> En proceso</b>
						</a>
					</li>
					<li>
						<a href="#aceptadaPorPagar" style="font-size: 14px;">
							<i class="green icon-check bigger-110"></i><b> Aceptada por pagar </b>
						</a>
					</li>
					<li>
						<a href="#rechazadas" style="font-size: 14px;">
							<i class="red icon-remove bigger-110"></i><b> Rechazadas</b>
						</a>
					</li>
					<li>
						<a href="#aclaracion" style="font-size: 14px;"><!--comments-alt-->
							<i class="green icon-question  bigger-110"></i><b> Aclaración</b>
						</a>
					</li>
					<li>
						<a href="#enRevision" style="font-size: 14px;">
							<i class="orange icon-search  bigger-110"></i><b> Revisión</b>
						</a>
					</li>
					<li>
						<a href="#NotaCredito" style="font-size: 14px;">
							<i class="orange icon-file  bigger-110"></i><b> Nota de Crédito</b>
						</a>
					</li>
				</ul>
				
				
				<div id="enProceso">
					<div id="contenedor_Proceso">
						<table id="gd_Proceso"  ></table>
						<div id="gd_Proceso_pager"></div>
						<span><i class="icon-check green bigger-200"></i> Marque las facturas que desea cambiar de estado</span>
					</div>
				</div>
				<div id="aceptadaPorPagar">
					<div id="contenedor_AceptadaPorPagar">
						<table id="gd_AceptadaPorPagar"></table>
						<div id="gd_AceptadaPorpagar_pager"></div>
						<span><i class="icon-check green bigger-200"></i> Marque las facturas que desea cambiar de estado</span>
					</div>
				</div>

				<div id="rechazadas">
					<div id="contenedor_Rechazadas">
						<table id="gd_Rechazadas"></table>
						<div id="gd_Rechazadas_pager"></div>
						<span><i class="icon-check green bigger-200"></i> Marque las facturas que desea cambiar de estado</span>
					</div>
				</div>
				<div id="aclaracion" >
					<div id="contenedor_Aclaracion">
						<table id="gd_Aclaracion"></table>
						<div id="gd_Aclaracion_pager"></div>
						<span><i class="icon-check green bigger-200"></i> Marque las facturas que desea cambiar de estado</span>
					</div>
				</div>
				<div id="enRevision">
					<div id="contenedor_Revision">
						<table id="gd_Revision"></table>
						<div id="gd_Revision_pager"></div>
						<span><i class="icon-check green bigger-200"></i> Marque las facturas que desea cambiar de estado</span>
					</div>
				</div>
				<div id="NotaCredito">
					<div id="contenedor_NotaCredito">
						<table id="gd_NotaCredito"></table>
						<div id="gd_NotaCredito_pager"></div>
						<span><i class="icon-check green bigger-200"></i> Marque las facturas que desea cambiar de estado</span>
					</div>
				</div>
			</div>
		</div>	
	</div>
	<div class="span12"><!--usd-->
		<div class="control-group">
			<div class="center">
				<button class="btn btn-small btn-primary"  type="button" id="btn_ConsultarCostosEscuela">
					<i class=" icon-money bigger-110"></i>Consultar Costos Escuela
				</button>
				<button class="btn btn-small btn-primary"  type="button" id="btn_ModificarImporte">
					<i class=" icon-money bigger-110"></i> Modificar Importe Concepto
				</button>
				<button class="btn btn-small btn-primary"  type="button" id="btn_Blog" data-toggle="modal" data-target="frm_consultar_blog">
					<i class=" icon-comments-alt bigger-110"></i> Blog
				</button>
				<button class="btn btn-small btn-primary"  type="button" id="btn_Blog_Csc" data-toggle="modal" data-target="frm_consultar_blog">
					<i class=" icon-comments-alt bigger-110"></i> Blog CSC
				</button>
				<!--<button class="btn btn-small btn-primary"  type="button" id="btn_Blog"
				data-toggle="modal" href="ajax/frm/frm_consultar_blog.php" data-target="#dlg_Blog">
					<i class="icon-comments-alt bigger-110"></i> Ver Blog
				</button>-->
				<!--<a data-toggle="modal" href="ajax/frm/frm_consultar_blog.php" data-target="#dlg_Blog">Click me !</a>-->

				<button class="btn btn-small btn-success"  type="button" id="btn_Anexos">
					<!--<i class="icon-paperclip  bigger-110"></i> Ver Anexos-->
					<i class="icon-download-alt  bigger-110"></i> Descargar Anexos
				</button>
				<!-- BOTON VER FACTURA -->
				<button class="btn btn-small btn-primary" type="button" id="btn_verFactura">
					<i class="icon-list bigger-110"></i> Ver Factura
				</button>
				<button class="btn btn-small btn-file" type="button" id="btn_notacredito">
					<!--<i class="icon-file bigger-110"></i>--> Aplicar Nota de Crédito
				</button>
				
				<!--button class="btn btn-warning btn-small" type="button" id="btn_Modificar">
					<i class=" icon-edit  bigger-110"></i>Modificar beneficiarios
				</button-->
			</div>
		</div>	
	</div>
	<div class="row-fluid">
		<div class="span12">
			<div id="contenedor_Beneficiarios">
				<table id="gd_Beneficiarios"></table>
				<div id="gd_Beneficiarios_pager"></div>
			</div>
			<br>
	
			
		</div>
	</div>
	<div class="span12">
		<table style="width:30%">
			<tr>
				<td style="width:15%;text-align:right;">
					<label class="control-label">Tipo Deducción:</label>	
				</td>
				<td style="width:15%;">
					&nbsp;&nbsp;<select id="cbo_Deduccion"></select>
				</td>					
			<tr>
				<td style="width:15%;text-align:right;">
					<label class="control-label">  Aceptado &nbsp;  <input name="rdb_estatus" id="rdb_Aceptado" type="radio" checked></label>
				</td>
				<td>
				</td>
			</tr>
			<tr>
				<td style="width:15%;text-align:right;">
					<label class="control-label">  Rechazado &nbsp; <input name="rdb_estatus"  id="rdb_Rechazado" type="radio"> </label>
				</td>
				<td style="width:15%;">
					&nbsp;&nbsp;<select id="cbo_Rechazo"></select>
				</td>
			</tr>
			
			<tr>
				<td style="width:15%;text-align:right;">
					<label class="control-label">  Aclaración &nbsp;<input name="rdb_estatus"  id="rdb_Aclaracion" type="radio">  </label> 
				</td>
				
			</tr>
			<tr>
				<td style="width:15%;text-align:right;">
					<label class="control-label">  En Revisión &nbsp;<input name="rdb_estatus" id="rdb_Revision" type="radio">  </label>
				</td>
				<td style="width:15%;">
					&nbsp;&nbsp;<select id="cbo_MotivoRevision"></select>
				</td>
			</tr>
		</table>
		<br>
		
	</div>
	<div class="row-fluid">
		<div class="span4">	
			<div class="widget-box">
				<div class="widget-header">
					<h5>Observaciones</h5>
					<span class="widget-toolbar">
						<!--<a href="#" data-action="collapse">
							<i class="icon-chevron-up"></i>
						</a>-->
					</span>
				</div>
				<div class="widget-body">
					<div class="widget-main">
						<div class="row-fluid">
							<textarea class="span12 limited; textNumbersOnly" id="txt_Observaciones" placeholder="OBSERVACIONES" maxlength="300" style="resize:none;text-transform:uppercase;"></textarea>
						</div>
					</div>
				</div>
			</div>	
		</div>
		<div class="span4">	
			<div class="widget-box">
				<div class="widget-header">
					<h5>Comentario Especial</h5>
					<span class="widget-toolbar">
						<!--<a href="#" data-action="collapse">
							<i class="icon-chevron-up"></i>
						</a>-->
					</span>
				</div>
				<div class="widget-body">
					<div class="widget-main">
						<div class="row-fluid">
							<textarea class="span12 limited" id="txt_Comentario_Especial" 
							 style="resize:none;text-transform:uppercase;" maxlength="300" readonly></textarea>
						</div>
					</div>
				</div>
			</div>	
		</div>
		<div class="span4">	
			<div class="widget-box">
				<div class="widget-header">
					<h5>Aclaración de Costos</h5>
					<span class="widget-toolbar">
						<!--<a href="#" data-action="collapse">
							<i class="icon-chevron-up"></i>
						</a>-->
					</span>
				</div>
				<div class="widget-body">
					<div class="widget-main">
						<div class="row-fluid">
							<textarea class="span12 limited " id="txt_AclaracionCostos" style="resize:none;text-transform:uppercase;" maxlength="300" readonly></textarea>
						</div>
					</div>
				</div>
			</div>	
		</div>
	</div>
	<br><br>
	<div class="span12">
		<div class="span3">
			<div class="control-group">		
				
				<button class="btn btn-small btn-success" id="btn_Guardar" type="button">
				<i class="icon-save bigger-110"></i>
					Guardar
				</button>
				<button type="button" class="btn btn-small btn-info pull-right" id="btn_regresarSeg">
					<i class="icon-reply"></i>Regresar
				</button>
			</div>
		</div>
	</div>
	<input type="hidden" id="hid_iColaborador" name="hid_iColaborador" value="<?php echo htmlspecialchars($iColaborador, ENT_QUOTES, 'UTF-8'); ?>"/>
	<input type="hidden" id="hid_region" name="hid_region" value="<?php echo htmlspecialchars($idRegion, ENT_QUOTES, 'UTF-8'); ?>"/>
	<input type="hidden" id="hid_ciudad" name="hid_ciudad" value="<?php echo htmlspecialchars($idCiudad, ENT_QUOTES, 'UTF-8'); ?>"/>
	<input type="hidden" id="hid_tNomina" name="hid_tNomina" value="<?php echo htmlspecialchars($idTipoNom, ENT_QUOTES, 'UTF-8'); ?>"/>
	<input type="hidden" id="hid_FechaIni" name="hid_FechaIni" value="<?php echo htmlspecialchars($dFechaIni, ENT_QUOTES, 'UTF-8'); ?>"/>
	<input type="hidden" id="hid_FechaFin" name="hid_FechaFin" value="<?php echo htmlspecialchars($dFechaFin, ENT_QUOTES, 'UTF-8'); ?>"/>
	<input type="hidden" id="hid_regresa" name="hid_regresa" value="1"/>
	
	
	<input type="button" id="btn_ver" name="btn_ver" value="Modal" style="display:none;"/>
	
	<div id="cnt_ver_factura" style="width:1800px;height:900px;display:none;">
		<style>
			.qrcode {
				width: 200;
				height: 200;
				/* max-width: 100%; */
				vertical-align: middle;
				border: 0;
				width: 135px;
				-ms-interpolation-mode: bicubic;
			}
		</style>
		
		<input type="hidden" id="nIsFactura" name="nIsFactura" value=""/>
		<!--<input type="hidden" id="sFacFiscal" name="sFacFiscal" value=""/>-->
		<input type="hidden" id="idfactura" name="idfactura" value=0/>
		<input type="hidden" id="sFilename" name="sFilename" value=""/>
		<input type="hidden" id="sFiliePath" name="sFiliePath" value=""/>
		
		<div class="widget-box">
			<div class="widget-header widget-header-small">
				<h5 class="lighter"><b id="b_titulo"></b></h5>
			</div>	
			<div class="widget-body">
				<div class="widget-main">
					<div id="div_contenido">
					</div>
					<div class="hr hr-double"></div>
				</div>	
			</div>
		</div>
	</div>
</div>
	
<!--<div id="dlg_PagosMensuales" style="display:none" title="Importe Pagos por Mes">-->
<!--<div id="dlg_PagosMensuales"  class="modal hide" tabindex="-1" style="width:380px; height:680px; position:fixed"  data-backdrop="static">-->
<!--<div id="dlg_Consultar_Costos"  class="modal hide modal-lg" tabindex="-1" style="width: 70%; left: 30%; vertical-align: middle;" data-backdrop="static">-->
<div id="dlg_PagosMensuales"  class="modal hide modal-lg" tabindex="-1" style="width:21%;  left: 50%; vertical-align: middle;" data-backdrop="static">
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-bar-chart "></i>&nbsp;Importes pagados por mes</h4>
	</div>
	<div class="modal-dialog modal-dialog-centered" role="document">
		<div class="modal-body">
			<div class="modal-content">
				<div class="row-fluid ">
					<div class="span12">
						<div class="control-group">
							<div id="contenedor_PagosMensuales">
								<table id="gd_PagosMensuales"></table>
							</div>
						</div>
						<div class="control-group">
							<label class="control-label">Acum. facturas pagadas:</label>			
							<div class="controls">
								<input type="text" class="span10" id="txt_Pagadas" style="text-align:right;" readonly >
							</div>
						</div>
						
						<div class="control-group">
							<label class="control-label">Acum. ajuste facturas pagadas:</label>			
							<div class="controls">
								<input type="text" class="span10" id="txt_ajuste" style="text-align:right;" readonly >
							</div>
						</div>
					
						<div class="control-group">				
							<label class="control-label">Tope restante:</label>			
							<div class="controls">
								<input type="text" class="span10" id="txt_Restante" style="text-align:right;" readonly />
								
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
<!--/div-->
<!--<div id="dlg_ModificarImportes" style="display:none">-->
<!--<div id="dlg_ModificarImportes"  class="modal hide" tabindex="-1" style="width:1150px; height:440px; position:fixed;" >-->

 <!--div id="dlg_ModificarImportes"  class="modal hide" tabindex="-1" style="width: 1170px; left: 550px; height: 440px;" data-backdrop="static"-->
 <div id="dlg_ModificarImportes"  class="modal hide modal-lg" tabindex="-1" style="width: 56%; left: 35%; vertical-align: middle;" data-backdrop="static">
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Modificar Importe Concepto</h4>
	</div>
	<div class="modal-body">
		<div class="row-fluid">
			<div class="form-horizontal">
				
				<div class="control-group">
					<div class="span2">
						<label class="control-label"><FONT FACE="arial" SIZE=4>Importe Concepto:</FONT></label>
					</div>
					<div class="span2">
						<input type="text" id="txt_ImporteActual" class="span11" readonly style="text-align:right;">
					</div>
				</div>
				
				<div class="control-group">
					<div class="span12">
						<table id="gd_ModificarImporteAPagar"></table>
					</div>
				</div>
				
				<div class="control-group">
					<div class="span10"><!-- style="text-align:left;">-->
							<!--<label class="control-label">Justificación:</label>-->
							<font size="4" face="arial">Justificación:</font>
								<textarea class="span12 limited; textNumbersOnly" id="txt_Justificacion" 
								 style="resize:none;text-transform:uppercase;" maxlength="300" ></textarea>
						<input type="hidden" class="currency" id="txt_ImporteNuevo" style="text-align:right;">
						
					</div>
					<div class="span2">
					<br>
					<br>
						<button class="btn btn-small btn-primary pull-left" type="button" id="btn_GuardarImportes">
							<i class="icon-save bigger-110"></i>Guardar
						</button>
					</div>
				</div>				
			</div>
		</div>
	</div>
	<div class="modal-footer">
		<div class="span12 center">
				<font size="4" color="red" face="arial">Para calcular el importe a pagar deberá de capturar el nuevo importe en la columna importe concepto...</font>
		</div>	
	</div>		
</div>

<!-- MODAL PORCENTAJES -->

<div id="dlg_Porcentajes"  class="modal hide modal-lg" tabindex="-1" style="width: 55%; left: 35%; vertical-align: middle;" data-backdrop="static">
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Porcentajes Especiales</h4>
	</div>
	<div class="modal-body">
		<div class="row-fluid">
			<div class="form-horizontal">	
				<div class="control-group">
					<div class="span12">
						<table id="gd_Porcentajes"></table>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Modal blog-->
<div class="modal hide" id="dlg_Blog" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                 <h4 class="modal-title"><i class=" icon-comments-alt bigger-110"></i> B L O G</h4>
            </div>
            <div class="modal-body">
				<div class="form-horizontal">
					<div class="span12">
						<div class="widget-box ">
							<div class="widget-body">
								<div class="widget-main no-padding">
									<div class="dialogs" id="div_Blog">
										
									</div>
								</div><!--/widget-main-->
							</div><!--/widget-body-->
						</div><!--/widget-box-->
					</div><!--/span-->	
				</div>
			</div>
            <div class="modal-footer">
				
				<form id="fmComentario" autocomplete="off" name="fmComentario" action="ajax/json/json_fun_grabar_blog_aclaraciones.php" method="POST" enctype="multipart/form-data">
					<input type="hidden" id="session_name1" name="session_name1">
					<input type="hidden" id="hid_factura" name="hid_factura">
					<input type="hidden" id="iEmpleado" name="iEmpleado">
					<textarea placeholder="ESCRIBIR COMENTARIO ..." type="text" name="txt_mensaje" id="txt_mensaje" class="width-75 textNumbersOnly" style="text-transform:uppercase;" maxlength="600" />
					<button class="btn btn-small btn-primary no-radius" id="btn_EnviarComentario">
						<i class="icon-share-alt"></i>
						<span class="hidden-phone">Enviar</span>
					</button>
				</form>
            </div>
        </div>
        <!-- /.modal-content -->
    </div>
    <!-- /.modal-dialog -->
</div>

<!-- Modal Blog CSC-->
<div class="modal hide" id="dlg_Blog_Csc" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" data-backdrop="static">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                 <h4 class="modal-title"><i class=" icon-comments-alt bigger-110"></i> B L O G</h4>
            </div>
            <div class="modal-body">
				<div class="form-horizontal">
					<div class="span12">
						<div class="widget-box ">
							<div class="widget-body">
								<div class="widget-main no-padding">
									<div class="dialogs" id="div_Blog_Csc">
										
									</div>
								</div><!--/widget-main-->
							</div><!--/widget-body-->
						</div><!--/widget-box-->
					</div><!--/span-->	
				</div>
			</div>
            <div class="modal-footer">
				<form id="fmComentario_csc" autocomplete="off" name="fmComentario_csc" action="ajax/json/json_fun_grabar_blog_revision.php" method="POST" enctype="multipart/form-data">
					<input type="hidden" id="session_name1_csc" name="session_name1_csc">
					<input type="hidden" id="hid_factura_csc" name="hid_factura_csc">
					<input type="hidden" id="hid_empleado_csc" name="hid_empleado_csc">
					<input placeholder="ESCRIBIR COMENTARIO ..." type="text" name="txt_mensaje_csc" id="txt_mensaje_csc" class="width-75" style="text-transform:uppercase;" />
					<button class="btn btn-small btn-primary no-radius" id="btn_EnviarComentario_csc">
						<i class="icon-share-alt"></i>
						<span class="hidden-phone">Enviar</span>
					</button>
				</form>
            </div>
        </div>
    </div>
</div> 



<!-- Modal Consulta Costos-->
<!--div id="dlg_Consultar_Costos"  class="modal hide" tabindex="-1" style="width: 1200px; left: 550px; height: 500px;" data-backdrop="static"-->
<!--div id="dlg_Consultar_Costos"  class="modal hide modal-lg" tabindex="-1" style="width: 1200px; left: 550px; height:500px" data-backdrop="static"-->

<!--div id="dlg_ModificarImportes"  class="modal hide" tabindex="-1" style="width: 56%; left: 35%; vertical-align: middle;" data-backdrop="static"-->
<div id="dlg_Consultar_Costos"  class="modal hide modal-lg" tabindex="-1" style="width: 70%; left: 30%; vertical-align: middle;" data-backdrop="static">
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-file-text-alt "></i>&nbsp;Consultar Costos</h4>
	</div>
	<div class="modal-dialog modal-dialog-centered" role="document">
		<div class="modal-body">
			<div class="modal-content">
				<div class="row-fluid">
					<div class="form-horizontal">
						
						<div class="control-group">
							<div class="span2">
								<label class="control-label"><FONT FACE="arial" SIZE=3>Nombre de la escuela:</FONT></label>
							</div>
							<div class="span2">
								<input type="text" id="txt_cc_escuela" class="span11" readonly style="text-align:right;">
							</div>
							<div class="span2">
								<label class="control-label"><FONT FACE="arial" SIZE=3>Estado:</FONT></label>
							</div>
							<div class="span2">
								<input type="text" id="txt_cc_estado" class="span11" readonly style="text-align:right;">
							</div>
							<div class="span2">
								<label class="control-label"><FONT FACE="arial" SIZE=3>Municipio:</FONT></label>
							</div>
							<div class="span2">
								<input type="text" id="txt_cc_ciudad" class="span11" readonly style="text-align:right;">
							</div>
						</div>
						<div class="control-group">
							<div class="span2">
								<label class="control-label"><FONT FACE="arial" SIZE=3>RFC:</FONT></label>
							</div>
							<div class="span2">
								<input type="text" id="txt_cc_rfc" class="span11" readonly style="text-align:right;">
							</div>
							<div class="span2">
								<label class="control-label"><FONT FACE="arial" SIZE=3>Razon Social:</FONT></label>
							</div>
							<div class="span2">
								<input type="text" id="txt_cc_razon_social" class="span11" readonly style="text-align:right;">
							</div>
							<div class="span2">
								<label class="control-label"><FONT FACE="arial" SIZE=3>Clave SEP:</FONT></label>
							</div>
							<div class="span2">
								<input type="text" id="txt_cc_clavesep" class="span11" readonly style="text-align:right;">
							</div>
						</div>
						<hr>
						<div class="span11">
							<div class="control-group">
								<div class="span5">
									<label class="control-label"><font face="arial" size="3">Ciclo Escolar:</font></label>
									<div class="controls ">
										<select class="span5" id="cbo_CicloEscolar"></select>
									</div>
								</div>
								<div class="span5">
									<label class="control-label"><font face="arial" size="3">Escolaridad:</font></label>
									<div class="controls">
										<select class="span6" id="cbo_Escolaridades"></select>
									</div>
								</div>
							</div>
							<div id="Costos">
								<span class="label label-important arrowed-in" style="font-size:12px">Para consultar costos y descuentos de ciclos diferentes, <b>Favor de seleccionar el ciclo escolar correspondiente</b></span>
								<span class="label label-light arrowed-in-right" style="font-size:12px">Para consultar costos y descuentos de diferentes escolaridades, <b>Favor de seleccionar la escolaridad correspondiente</b></span>									
								<div id="contenedor_Costos">
									<table id="gd_Costos"  ></table>
									<div id="gd_Costos_pager"></div>						
								</div>
							</div>
							<br>
							<div id="Descuentos">
								<div id="contenedor_Descuentos">
									<table id="gd_Descuentos"  ></table>
									<div id="gd_Descuentos_pager"></div>						
								</div>
							</div>
						</div>
						<!--br>
						<div class="control-group" style="right">					
							<div class="span2">					
							<br>
								<button class="btn btn-small btn-primary pull-right" type="button" id="btn_Cerrar_Consulta_Costos">
									<i class="icon-exit bigger-110"></i>Cerrar
								</button>
							</div>
						</div-->				
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="modal-footer">
		<button class="btn btn-small btn-primary pull-right" type="button" id="btn_Cerrar_Consulta_Costos">
			<i class="icon-exit bigger-110"></i>Cerrar
		</button>
	</div>
	
</div>

<form id="frm_descarga_zip" name="frm_descarga_zip" method="POST" action="ajax/proc/proc_descargar_zip.php" enctype="multipart/form-data">
	<input type="hidden" id="txt_ciclo" name="txt_ciclo" />
	<input type="hidden" id="txt_archivo1" name="txt_archivo1" />
	<input type="hidden" id="txt_archivo2" name="txt_archivo2" />
	<input type="hidden" id="txt_empleado" name="txt_empleado" />
</form>
<!--
<div id="dlg_Beneficiarios"  class="modal hide" tabindex="-1" style="width:500; height:200px; position:center; left:700px" >
<div id="dlg_Beneficiarios" style="display:none">
	<form class="form-horizontal">
		<div class="span12">
			<div id="contenedor_Beneficiarios">
				<table id="gd_Beneficiarios"></table>
				<div id="gd_Beneficiarios_pager"></div><br><br>
					<button class="btn btn-small btn-primary" type="button" id="btn_RegresarB" >
					<i class="icon-arrow-left bigger-110"></i>
						Regresar
					</button>
			</div>
		</div>	
	</form>
</div> style="width:1800px;height:600px;display:none;"-->
	
<div id="cnt_notacredito" >
	<style>
		<!--.qrcode {
			width: auto\9;
			height: auto;
			/* max-width: 100%; */
			vertical-align: middle;
			border: 0;
			width: 90px;
			-ms-interpolation-mode: bicubic;
		}-->
			th.ui-th-column div{
			white-space:normal !important;
			height:auto !important;
			padding:2px;
		}
	</style>
				
	<div class="widget-header widget-header-small">
		<h5 class="lighter"><b id="b_titulo"></b></h5>
	</div>	
	<div class="widget-body">
		<div class="widget-main">
			<!-- div id="div_contenido" -->
			<table border="0" >						
				<tr>			
					<div class="row-fluid">
						<div class="span8" id="NotaCreditoAplicar">
							<table id="gd_NotaCreditoAplicar"></table>
							<div id="gd_NotaCreditoAplicar_pager"></div>
						</div>
					</div>
				</tr>
				<br><br>
				<tr>							
					<div class="span2">											
						<label class="control-label">Importe:</label>
					</div>
					<div class="span2">
						<input type="text" class="span2" id="txt_importe_nc" style="text-transform:uppercase"/>					
					</div>
				</tr>						
			</table>								
		</div>
	</div>
</div>