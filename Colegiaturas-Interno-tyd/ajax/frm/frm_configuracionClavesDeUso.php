<?php
	header( 'X-Frame-Options: SAMEORIGIN' );	
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
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
<script type="text/javascript" src="files/js/frm_configuracionClavesDeUso.js"></script>

<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="span11">
	<div class="form-horizontal">
		<div class="control-group" style="display:none">
			<label class="control-label">ID:</label>
			<div class="controls">
				<input type="text" id="txt_keyx" width="50px" maxlength = '5' style = "text-transform:uppercase;" value="0" readonly>
			</div>
		</div>
		<div class="control-group">
			<label class="control-label">Clave:</label>
			<div class="controls">
				<input type="text" id="txt_clave" width="50px" maxlength = '5'  style = "text-transform:uppercase;">
				<!--	class="textNumbersOnly" -->
			</div>
		</div>
		<div class="control-group">
			<label class="control-label">Descripción:</label>
			<div class="controls">
				<input type="text" class="span6" id="txt_descripcion" maxlength = '50' style ="text-transform:uppercase;">&nbsp;&nbsp;&nbsp;
				<button class="btn btn-primary btn-small" id="btn_Guardar"><i class="icon-save"></i>Guardar</button>
			</div>
		</div>
		<div class="control-group">
			<div class="row-fluid">
				<div class="span12">
					<div id="contenedor_gd_claves">
						<table id="gd_Claves"></table>
						<div id="gd_Claves_pager"></div>
					</div>
				</div>
			</div>
		</div>
	</div>
</div>
	