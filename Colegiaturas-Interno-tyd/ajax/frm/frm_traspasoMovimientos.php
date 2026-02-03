<?php
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
?>

<!-- VULNERABILIDADES -->
<script>
    if (self === top) {
        document.documentElement.style.display = 'block';
    }
</script>

<!--[if lte IE 8]>
  <link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->
<script type="text/javascript" src="files/js/utils.js"></script>
<!--<script type="text/javascript" src="files/js/bootbox.js"></script>-->
<script type="text/javascript" src="files/js/frm_traspasoMovimientos.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content" style="height=500px;">
	<div class="form-horizontal">
		<div class="row-fluid">
			<div class="span12">
			<input type="hidden" id="txt_TipoNomina" style="width:20px">
				<div class="control-group">
					<label class="control-label">Buscar:</label>
					<div class="controls">
						<select id="cbo_Tipo" class="span3">
							<option value="0">TODOS</option>
							<option value="1">FOLIO FACTURA</option>
							<option value="2">COLABORADOR</option>
						</select>
						<input type="text" id="txt_Buscar" class="span5 textNumbersOnly" style="text-transform:uppercase;" maxlength="100" >
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">Tipo Movimiento:</label>
					<div class="controls">
						<select id="cbo_TipoMovimiento" class="span3">
							<option value="0">TODOS</option>
							<option value="1">FACTURA</option>
							<option value="2">AJUSTE</option>
						</select>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">Tipo Nomina:</label>
					<div class="controls">
						<select id="cbo_TipoNomina" class="span3">
						</select>
					</div>
				</div>
				<div class="span5 control-group pull-right">
					<button class="btn btn-primary btn-small" onclick="return false;" id="btn_buscar">
						<i class="icon-search icon-on-right bigger-110"></i> Consultar
					</button>
					<button class="btn btn-primary btn-small" onclick="return false;" id="btn_QuitarFiltro">
						<i class="icon-remove icon-on-right bigger-110"></i> Quitar Filtro
					</button>
				</div>
			</div>
		</div>		
				
		<div class="row-fluid">
			<div class="span12">
				<div id="contenedor_gd_Facturas">
					<table id="gd_Facturas"></table>
					<div id="gd_Facturas_pager"></div>
				</div>
			</div>
		</div>
		
	</div> 	
</div>

<div id="dlg_Cifras"  class="modal hide" tabindex="-1" style="width:870px; height:400px; position:center;" data-backdrop="static">
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

<div id="dlg_BeneficiariosFactura"  class="modal hide" tabindex="-1" style="width:50%; left: 40%; vertical-align: middle;" data-backdrop="static">
<!--style="width:900px; height:300px; position:center;">-->
	<div class="modal-header widget-header" >
		<button type="button" class="close" data-dismiss="modal">&times;</button>			
		<h4 class="black bigger" ><i class="icon-group "></i>&nbsp;Beneficiarios</h4>
	</div>
	<div class="modal-body">
		<div class="row-fluid ">
			<div class="span12">
				<div class="control-group">
					<div id="contenedor_gd_BeneficiariosFactura">
						<table id="gd_BeneficiariosFactura" class="align-text-bottom"></table>
					</div>
				</div>
			</div>	
		</div>
	</div>
	<div class="modal-footer">
	</div>
</div>

<div id="divexport"></div>

<form id="formgetpdffile" name="formgetpdffile" action="../utilidadesweb/src/com/coppel/utils/export/GetPdfFile.php" method="POST" enctype="multipart/form-data">
</form>
