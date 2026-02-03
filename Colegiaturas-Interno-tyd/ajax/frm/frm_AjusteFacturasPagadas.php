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
<script type="text/javascript" src="files/js/frm_AjusteFacturasPagadas.js"></script>
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
	.tooltip {
		z-index: 10000 !important;
	}
</style>
<div class="span12; form-horizontal">
	<div class="span8">
		<div class="span8">
			<br>
			<div class="control-group">
				<label class="control-label">Número Colaborador:</label>
				<div class="controls">
					<input type="text" class="span3 numbersOnly" id="txt_NumEmp" maxlength="8" tabindex="1">
					<input type="text" class="span8 textOnly" id="txt_NomEmp" maxlength="100" tabindex="2">
				</div>
			</div>
			<div class="control-group">
				<label class="control-label">Folio:</label>
				<div class="controls">
					<input type="text" class="span11 textNumbersOnly" id="txt_Folio" style="text-transform:uppercase" maxlength="40" tabindex="3">
				</div>
			</div>			
		</div>	
	</div>
	<div class="span11">
		<div class="span8" align="right">
			<div class="controls">
				<button class="btn btn-small btn-primary" id="btn_Consultar" tabindex="8">
					<i class="icon-search bigger-110"></i>Consultar
				</button>
			</div>
		</div>
	</div>
	
	<!-- GRID FACTURAS -->
	<div class="control-group">
		<div class="span11">
		<br>
			<div id="contenedor_gd_Facturas">				
					<table id="gd_Facturas"></table>
					<div id="gd_Facturas-pager"></div>
			</div>						
		</div>
	</div>
	
	<!-- GRID FACTURAS DETALLE -->
	<div class="control-group">
		<div class="span11">		
			<div id="contenedor_gd_FacturasDetalle">				
					<table id="gd_FacturasDetalle"></table>
					<div id="gd_FacturasDetalle_pager"></div>
			</div>					
		</div>
	</div>
	
	<!-- NUEVO PORCENTAJE A PAGAR -->
	<div class="span11">
		<div class="span10">
			<div class="control-group">
				<div class="span8">
					<label class="control-label">Nuevo porcentaje:</label>
					<div>
						<div class="controls">
							<input type="text" class="span2 textNumbersOnly" align="left" id="txt_porcentaje" style="text-transform:uppercase" maxlength="2" tabindex="3">
						</div>						
					</div>
				</div>
			</div>		
		</div>
		<!-- -->
		<div id="dlg_GuardarAjuste" class="modal hide" tabindex="-1" style="width: 30%; left: 750px; height:300px;" data-backdrop="static">
			<div class="modal-header widget-header">
				<button type="button" class="close" data-dismiss="modal">&times;</button>
				<h4 class="black bigger"><i class="icon-edit"></i>&nbsp;Observaciones</h4>
			</div>
			<div class="modal-body">
				<div class="row-fluid">
					<div class="span12">
						<div class="control-group">
							<div id="Observaciones">								
								<label class="control-label" for="form-field-2"><b>Observaciones:</b></label>
									<textarea id="txt_Justificacion" class="textNumbersOnly" style="text-transform: uppercase; resize: none; width: 520px; height: 60px" maxlength="300" tabindex="2"/>
								<br><br>
								<div id="Guardar_Justificacion" align="right">
									<button id="btn_Grabar" class="btn btn-small btn-primary"><i class="icon-save" tabindex="3"></i> Guardar</button>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		
		<!-- BOTON GUARDAR -->		
		<div class="span10">			
			<div class="span12" align="right">
				<div class="controls">					
					<button class="btn btn-small btn-primary" id="btn_Guardar" tabindex="8">
						<i class="icon-save bigger-110"></i>Guardar
					</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- BOTON GUARDAR
	<div class="span10">
		<div class="span12" align="right">
			<div class="controls">
				<button class="btn btn-small btn-primary" id="btn_Guardar" tabindex="8">
					<i class="icon-search bigger-110"></i>Guardar
				</button>
			</div>
		</div>
	</div> -->
	
</div>