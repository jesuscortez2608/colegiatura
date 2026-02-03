<?php
	header( 'X-Frame-Options: SAMEORIGIN' );
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
?>
<!--[if lte IE 8]>
  <!--link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->			
<!--page specific plugin scripts-->
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/jquery.jqGrid.min.js"></script>
<script src="<!--url-->plantilla/coppel/assets/js/jqGrid/i18n/grid.locale-es.js"></script>
<script type="text/javascript" src="files/js/utils.js"></script>

<!--<script type="text/javascript" src="../../../utilidadesweb/src/com/coppel/utils/jquery.utils.js"></script>-->
<link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/font-awesome.min.css" />
<script type="text/javascript" src="files/js/frm_configuracionMotivosRechazo.js"></script>

<div class="page-content">
	<div class="row-fluid">
		<div class="span12">	
			<div class="form-horizontal">
			<input class="span3" id="txt_claveE" type="hidden" >
				<div class="span10">
					
					<label class="control-label">Descripci&oacute;n del Motivo:</label>
						<div class="controls">
							<input class="span10 textNumbersOnly" id="txt_motivo" type="text" tabIndex="1" maxlength="100" style="text-transform:uppercase;">
							<!---<textarea class="span12" id="txt_motivo" type="text" tabIndex="1"></textarea>--->
						</div>
						<br>
					<label class="control-label" >Tipo Motivo:</label>
					<div class="controls">
						<select class="span5" id="cbo_tipoMotivo"  tabIndex="2"></select>&nbsp;
						<button id="btn_guardar" class="btn btn-small btn-primary" tabIndex="3">
							<i class="icon-save bigger-110"></i>Guardar</button>
					</div><br>
					
				</div>
			</div>
		</div>
			<div class="span9">
				<div class="control-group">
					<div id="gridMotivo">
						<table id="gridMotivo_table"></table>
						<div id="gridMotivo_pager"></div>
					</div>
				</div>
			</div>
			
	</div>
		
	</div>
</div>