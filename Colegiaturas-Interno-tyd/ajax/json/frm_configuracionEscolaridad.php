<?php
	header( 'X-Frame-Options: SAMEORIGIN' );	
    header("Content-type:text/html;charset=utf-8");
	header("Strict-Transport-Security: max-age=31536000; includeSubDomains; preload");
    date_default_timezone_set('America/Denver');
?>
<!--page specific plugin styles-->

<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->			
<!--page specific plugin scripts-->

<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_configuracionEscolaridad.js"></script>
<style type="text/css" media="screen">

</style>
<div class="page-content">
	<div class="row-fluid">
		<div class="span12">
			<form class="form-horizontal">
				<div class="span6;page-header position-relative">
					<div class="span6">
						<div class="control-group">
							<input class="span3" id="txt_clave" type="hidden" >
							<label class="control-label" >Escolaridad:</label>
							<div class="controls">
								<input class="span9" id="txt_escolaridad" type="text" maxlength='30' style="text-transform:uppercase;">
								<button id="btn_guardar" class="btn  btn-primary btn-small">
									<i class="icon-save bigger-110"></i>Guardar
								</button>
							</div>
						</div>
					</div>
				</div>
				
				<div class="row-fluid">
					<div class="form-horizontal">
						<!--div class="span6;page-header position-relative"-->
						<div class="span4">
							<div class="control-group">
								<div id="gridEscolaridad">
									<table id="gridEscolaridad-table"></table>
									<div id="gridEscolaridad-pager"></div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</form>
		</div>
	</div>
	<div class="row-fluid">
		<div class="span12">
			<hr>
		</div>
	</div>
	
	<div class="row-fluid">
		<div class="span12">
			<form class="form-horizontal">
				<div class="span6;page-header position-relative">
					<div class="span6">
						<div class="control-group">
							<input class="span3" id="txt_grado" type="hidden" >
							<label class="control-label" >Grado:</label>
							<div class="controls">
								<input class="span9" id="txt_NomGrado" type="text" maxlength='30' style="text-transform:uppercase;">
								<button id="btn_guardarGrado" class="btn  btn-primary btn-small">
									<i class="icon-save bigger-110"></i>Guardar
								</button>
							</div>
						</div>
					</div>
				</div>
				
				<div class="row-fluid">
					<div class="form-horizontal">
						<!--div class="span6;page-header position-relative"-->
						<div class="span4">
							<div class="control-group">
								<div id="gridGrados">
									<table id="gridGrados-table"></table>
									<div id="gridGrados-pager"></div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</form>
		</div>
	</div>

</div>

