<?php
    header("Content-type:text/html;charset=utf-8");
    date_default_timezone_set('America/Denver');
?>

<!--[if lte IE 8]>
  <link rel="stylesheet" href="<!--url-->/plantilla/coppel/assets/css/ace-ie.min.css" />
<!--[endif]-->
<script type="text/javascript" src="files/js/utils.js"></script>
<script type="text/javascript" src="files/js/frm_GenerarIncentivosTemp.js"></script>
<script type="text/javascript" src="../utilidadesweb/src/com/coppel/utils/jquery.utils.js"></script>
<script type="text/javascript" src="files/values/parametros_colegiaturas.js"></script>
<style type="text/css" media="screen">
    th.ui-th-column div{
        white-space:normal !important;
        height:auto !important;
        padding:2px;
    }
</style>
<div class="page-content">
	<div class="form-horizontal">				
		<div class="row-fluid">
			<div class="span12">
				<div id="contenedor_gd_incentivosAdmin">
					<table id="gd_incentivosAdmin"></table>
					<div id="gd_incentivosAdmin_pager"></div>
				</div>
			</div>
			<br><br>
			<div class="span9">
				<div id="contenedor_gd_incentivos">
					<table id="gd_incentivos"></table>
					<div id="gd_incentivos_pager"></div>
				</div>
			</div>
		</div>	
	</div> 	
</div>

	<button class="btn btn-small btn-primary no-radius" id="btn_generarIncentivos" style="display:none;">
		<i class="icon-share"></i>
		<span class="hidden-phone">Generar</span>
	</button>
	
	<button class="btn btn-small btn-primary no-radius" id="btn_unir" style="display:none;">
		<i class="icon-link"></i>
		<span class="hidden-phone">Unificar Incentivos</span>
	</button>
	
	<button class="btn btn-small btn-primary no-radius" id="btn_enviar" style="display:none;">
		<i class="icon-ok"></i>
		<span class="hidden-phone">Envíar</span>
	</button>
	<input type="hidden" id="txt_fecha" value="<?php echo date('d/m/Y'); ?>"/>
	
<!--<div id="descargar">descarga</div>
<div id="cnt_exportar_excel" title="Exportar">
	<form id="formgetexcel_file" name="formgetexcel_file" action="../utilidadesweb/src/com/coppel/utils/export/GetExcelFile.php" method="POST">		
		<input type="hidden" id="filename" name="filename" value="archivo">
	</form>	
</div>-->
<!--	
<div id="divexport"></div>

<form id="formgetpdffile" name="formgetpdffile" action="../utilidadesweb/src/com/coppel/utils/export/GetPdfFile.php" method="POST" enctype="multipart/form-data">
</form>
-->