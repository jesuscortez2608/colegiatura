<?php
	header( 'X-Frame-Options: SAMEORIGIN' );
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
	
	session_name("Session-Colegiaturas"); 
	session_start();
	$Session = 'Colegiaturas';
	
	$IdEmpleado =(isset($_POST['IdEmpleado']) ? $_POST['IdEmpleado'] : '');
	$FechaInicial =(isset($_POST['FechaInicial']) ? $_POST['FechaInicial'] : '');
	$FechaFinal =(isset($_POST['FechaFinal']) ? $_POST['FechaFinal'] : '');
	
	$iEmpleado = isset($_SESSION[$Session]["USUARIO"]['num_empleado'])?$_SESSION[$Session]['USUARIO']['num_empleado']:'';
?>
<!--page specific plugin styles-->


<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ui.jqgrid.css" />
<!--ace styles-->
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-responsive.min.css" />
<link rel="stylesheet" href="<!--url-->plantilla/coppel/assets/css/ace-skins.min.css" />
<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->			
<!--page specific plugin scripts-->

<!-- VULNERABILIDADES -->
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>


<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />
<script type="text/javascript" src="files/js/accounting.min.js"></script>
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_seguimientoFacturasExternos.js"></script>
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
</style>
<style>
    .tooltip {
		z-index: 10000 !important;
		background-color: #73AD21; 
		color: #FFFFFF; 
		border: 1px solid green;
		padding: 15px;
		font-size: 20px;
	}
</style>
<div class="span12; form-horizontal">
	<div class="span8">
		<div class="span8">
			<br>
			<div class="control-group">
				<label class="control-label">Externo:</label>
				<div class="controls">
					<!--input type="text" class="span3 numbersOnly" id="txt_NumExterno" maxlength="8" tabindex="1" data-placement="bottom" title="Numero de externo"-->
					<input data-rel="tooltip" title="Número de externo" data-placement="top" type="text" class="span3 numbersOnly" id="txt_NumExterno" maxlength="8" tabindex="1">
					<input data-rel="tooltip" title="Nombre de externo" data-placement="top" type="text" class="span8 textOnly" id="txt_NomExterno" style="text-transform:uppercase background:transparent;" maxlength="100" tabindex="2">
					<!--input type="text" class="span8 textOnly" id="txt_NomExterno" style="text-transform:uppercase" maxlength="100" tabindex="2"-->
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Folio Fiscal:</label>
				<div class="controls">
					<!--input type="text" class="span10 textNumbersOnly" id="txt_Folio" style="text-transform:uppercase" maxlength="40" tabindex="3"-->
					<input data-rel="tooltip" title="Folio Fiscal(UUID)" data-placement="top" type="text" class="span10 textNumbersOnly" id="txt_Folio" style="text-transform:uppercase background:transparent" maxlength="40" tabindex="3">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Estatus:</label>
				<div class="controls">
					<select class="span5" id="cbo_estatus" tabindex="4">
						<option value="0">SELECCIONE</option>
					</select>
				</div>
			</div>
		</div>
		<div class="span4">
		<br>
			<div class="control-group">
				<label class="control-label" tabindex="5">Por Fecha:</label>
				<div class="controls">
					<input class="ace ace-checkbox-2" id="ckb_rango" type="checkbox" name="form-field.checkbox" style="width=100px" >
					<span class="lbl"></span>
				</div>
			</div>
		</div>
		<div class="span4">
			<div class="control-group">
				<label class="control-label"> Fecha Inicial: </label>
				<div class="controls">
					<div class="row-fluid input-append">
							<input type="text" id="txt_FechaIni" class="input-small" readonly value="<?php echo date('d/m/Y'); ?>" tabindex="6"/>
							<span class="add-on">
								<i class="icon-calendar"></i>
							</span>
					</div>
				</div>
			</div>
		</div>
		<div class="span3">
			<div class="control-group">
				<label class="control-label"> Fecha Final: </label>
				<div class="controls">
					<div class="row-fluid input-append">
							<input type="text" id="txt_FechaFin" class="input-small" readonly  value="<?php echo date('d/m/Y'); ?>" tabindex="7"/>
							<span class="add-on">
								<i class="icon-calendar"></i>
							</span>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="span10">
		<div class="controls">
			<button class="btn btn-small btn-primary pull-right" id="btn_Consultar" tabindex="8">
				<i class="icon-search bigger-110"></i>Consultar
			</button>
		</div>
	</div>
	<div class="control-group">
		<div class="span11">
			<div id="gridFacturasExternos">
				<br>
					<table id="gridFacturasExternos-table"></table>
					<div id="gridFacturasExternos-pager"></div>
			</div>
			<br>
			<label class="lbl"><b>Observaciones:</b></label>
				<textarea class="span12" id="txt_Motivo" style="resize:none" disabled="disabled"></textarea>			
		</div>
	</div>
	
	<input type="hidden" id="hid_idu_usuario" name="hid_idu_usuario" value="<?php echo $iEmpleado;  ?>"/>
	
	<input type="button" id="btn_ver" name="btn_ver" value="Modal" style="display:none;"/>
	
	<div id="cnt_ver_factura" style="width:1800px;height:900px;display:none;">
		<style>
			.qrcode {
				width: auto\9;
				height: auto;
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
<script>
	$(document).ready(function(){
		$('[data-toggle="tooltip"]').tooltip();
	});
</script>