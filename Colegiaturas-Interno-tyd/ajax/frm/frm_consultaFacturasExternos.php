<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
	$IdEmpleado =(isset($_POST['IdEmpleado']) ? $_POST['IdEmpleado'] : '');
	$FechaInicial =(isset($_POST['FechaInicial']) ? $_POST['FechaInicial'] : '');
	$FechaFinal =(isset($_POST['FechaFinal']) ? $_POST['FechaFinal'] : '');
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

<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />
<script type="text/javascript" src="files/js/accounting.min.js"></script>
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_consultaFacturasExternos.js"></script>

<div class="span12;page-header position-relative; form-horizontal">
	<div class="span8"> 
		<div class="span8"> 
			<br>
			<div class="control-group">
				<label class="control-label">Folio:</label>
				<div class="controls">
					<input type="text" class="span9 textNumbersOnly" id="txt_Folio" style="text-transform:uppercase" maxlength="40" tabindex="1">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Colaborador:</label>
				<div class="controls">
					<input type="text" class="span3 numbersOnly" id="txt_Numemp" maxlength="8" tabindex="2">
					<input type="text" class="span7 textOnly" id="txt_Nombre" style="text-transform:uppercase" maxlength="100" tabindex="3" readonly>
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Estatus:</label>
				<div class="controls">
					<select class="span5" id="cbo_estatus" tabindex="3">
						<option value="0">SELECCIONE</option>
					</select>
				</div>
			</div>
		</div>
		<div class="span4">
		<br>
			<div class="control-group">
				<label class="control-label">Rango de Fechas:</label>
				<div class="controls">
					<input class="ace ace-checkbox-2" id="ckb_rango" type="checkbox" name="form-field.checkbox" style="width=100px">
					<span class="lbl"></span>
				</div>
			</div>			
		</div>
		<div class="span4">
			<div class="control-group">
				<label class="control-label">Fecha Inicial:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaIni" class="input-small" tabindex="4" readonly value="<?php echo date('m-d-y');?>"/>
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
			</div>
		</div>
		<div class="span4">
			<div class="control-group">
				<label class="control-label">Fecha Final:</label>
				<div class="controls">
					<div class="row-fluid input-append">
						<input type="text" id="txt_FechaFin" class="input-small" tabindex="5" readonly value="<?php echo date('m-d-y');?>" />
						<span class="add-on">
							<i class="icon-calendar"></i>
						</span>
					</div>
				</div>
			</div>
			<!--div class="control-group" align="right">
					<div class="controls">
						<button class="btn btn-small btn-primary" id="btn_consultar" tabindex="6">
							<i class="icon-search bigger-110"></i>Consultar
						</button>
					</div>
			</div-->
		</div>		
	</div>
	<div class="span12">
		<div class="span8">
			
			<div class="span11" align="right">
				<div class="control-group">
					<div class="controls">
						<button class="btn btn-small btn-primary" id="btn_consultar" tabindex="6">
							<i class="icon-search bigger-110"></i>Consultar
						</button>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="control-group">
		<div class="span12">
			<div id="gridFacturasExt">
			<br>
				<table id="gridFacturasExt-table"></table>
				<div id="gridFacturasExt-pager"></div>
			</div>
		</div>
	</div>
</div>