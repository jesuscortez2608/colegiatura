<?php
    header('X-Frame-Options: SAMEORIGIN');
    header("Content-type:text/html;charset=utf-8;");
    header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>
<!--[if lte IE 8]>
  <link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<[endif]-->
<!--page specific plugin scripts-->
<script type="text/javascript" src="files/js/frm_pagosColegiaturas.js"></script>
<link rel="stylesheet"  href="files/css/frm_pagosColegiaturas.css"/>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content">
	<div class="page-header position-center">
		<h3>Generar Pagos</h3>
	</div>
	<div class="row-fluid">
		<form class="form-horizontal">
			<div class="span12;page-header position-relative">
				<div class="control-group">
					<button id="btn_generar" class="btn btn-bigger btn-primary">Generar</button>
					<button id="btn_rechazos" class="btn btn-bigger btn-primary">Imprimir Rechazos</button>
					<button id="btn_cifras" class="btn btn-bigger btn-primary">Cifras</button>
				</div>		
			</div>
		</form>
	</div>
</div>
<div id="cnt_busquedaPagosColegiatura" style="display:none">
</div>

<div id="divexport">
</div>

<div id="dlg_consultarCifras"  class="modal hide" tabindex="-1" style="width:870px; height:400px; position:center;">
	<div class="modal-body">
		<div class="row-fluid ">
			<div class="span12">
				<div class="control-group">
					<div id="contenedor_gd_Cifras">
						<table id="gd_Cifras"></table>
					</div>
				</div>
			</div>	
		</div>
	</div>
	<div class="modal-footer">
		<button class="btn btn-small btn-primary no-radius" id="btn_ImprimirCifras">
			<i class="icon-print"></i>
			<span class="hidden-phone">Imprimir</span>
		</button>
		<button class="btn btn-small btn-danger no-radius" id="btn_CerrarCifras">
			<i class="icon-remove"></i>
			<span class="hidden-phone">Cerrar</span>
		</button>
	</div>
</div>

<!-- Modal Imprimir Rechazos -->
<div id="dlg_Rechazos" class="modal hide" tabindex="-1" style="width:950px; height:400px; position:center">
	<!-- Modal Header -->
	<div class="modal-header widget-header">
		<button type="button" class="close" data-dismiss="modal">&times;</button>
		<h4 class="black bigger" ><i class="icon-remove red"></i>&nbsp;Rechazos</h4>
	</div>
	<!-- Modal Body -->
	<div class="modal-body">
		<div class="row-fluid">
			<div class="span12">
				<div class="control-group">
					<table id="gd_Rechazos"></table>
				</div>
			</div>
		</div>
	</div>
	<!-- Modal Footer -->
	<div class="modal-footer">
		<button id="btn_ImprimirRechazos" class="btn btn-small btn-primary no-radius">
			<i class="icon-print"></i>
			<span class="hidden-phone">Imprimir</span>
		</button>
		<button id="btn_CerrarRechazos" class="btn btn-small btn-danger no-radius">
			<i class="icon-remove"></i>
			<span class="hidden-phone">Cerrar</span>
		</button>
	</div>
</div>